//
//  HWTVShowsController.m
//  plex
//
//  Created by ccjensen on 26/02/2011.
//

#import "HWTVShowsController.h"
#import <plex-oss/PlexMediaContainer.h>
#import <plex-oss/PlexMediaObject.h>
#import "PlexMediaObject+Assets.h"
#import "PlexNavigationController.h"
#import "PlexThemeMusicPlayer.h"
#import "PlexControlFactory.h"
#import "Localize.h"

#define LOCAL_DEBUG_ENABLED 0

#define PlexMediaObjectTvShowKey @"tvshow"

@interface BRThemeInfo (PlexExtentions)
- (id)storeRentalPlaceholderImage;
@end

@implementation HWTVShowsController
@synthesize seasonsForSelectedTVShow;
@synthesize themeMusicTimer;

// this is a hack to make sure all the shelfs are loaded correctly
-(BOOL)brEventAction:(BREvent *)action {
    if (!allShelvesLoaded) {
        NSArray *shelves = [self valueForKey:@"_shelfControls"];
        int shelfCount = [shelves count];
        int firstShelfToReload = [shelves count];
        
        //we only need to reload ~ the last half of the shelves
        if (shelfCount > 4) {
            firstShelfToReload = ceil(shelfCount/2);
            //examples:
            // ceil(5/2)   =   firstShelfToReload=3
            // ceil(6/2)   =   firstShelfToReload=3
        } else {
            //allShelvesLoaded = YES;
#if LOCAL_DEBUG_ENABLED
            DLog(@"Shelf count is %d. No reloading needed", shelfCount);
#endif
        }
        //if 4 or less, then this won't loop at all
        int startIndex = firstShelfToReload - 2; // -2 since we are wish to reload i+2
        for (int i = startIndex; i<shelfCount; i++) {
            BRMediaShelfControl *shelf = [shelves objectAtIndex:i];
            if ([shelf isFocused]) {
                if (i+2 == shelfCount) {
                    //last item, all prior ones will have been re-layout too. 
                    //Will not need to redo this hack again until view is reloaded
                    allShelvesLoaded = YES;
#if LOCAL_DEBUG_ENABLED
                    DLog(@"Reloaded last shelf. Our work here is done");
#endif
                } else {
#if LOCAL_DEBUG_ENABLED
                    DLog(@"Reloading shelf at index %d/%d", i+2, shelfCount-1);
#endif
                    [[shelves objectAtIndex:i+2] setNeedsLayout];
                }
                break; //only need to refresh one
            }
        }
    }
    return [super brEventAction:action];
}

#pragma mark -
#pragma mark Object/Class Lifecycle
- (id)initWithPlexAllTVShows:(PlexMediaContainer *)allTVShows {
	if ((self = [super init])) {
		tvShows = [allTVShows retain];
		allTvShowsSeasonsPlexMediaContainer = [[NSMutableArray alloc] init];
		self.datasource = self;
		self.delegate = self;
        shouldPlayInitialThemeSong = YES;
	}
	return self;
}

- (void)dealloc {
	self.datasource = nil;
	self.delegate = nil;
    self.seasonsForSelectedTVShow = nil;
    [self.themeMusicTimer invalidate];
    self.themeMusicTimer = nil;
	
	[allTvShowsSeasonsPlexMediaContainer release];
	[tvShows release];
	
	[super dealloc];
}

- (void)rebuildBookcase {
    NSDate *startTime = [NSDate date]; 
    
    [super rebuildBookcase];
    
    NSTimeInterval elapsedTime = [startTime timeIntervalSinceNow];  
    DLog(@"Elapsed time: %f", -elapsedTime);
}


#pragma mark -
#pragma mark Controller Lifecycle behaviour
- (void)wasPushed {
	[[MachineManager sharedMachineManager] setMachineStateMonitorPriority:NO];
	[super wasPushed];
}

- (void)wasPopped {
    [[PlexThemeMusicPlayer sharedPlexThemeMusicPlayer] stopPlayingThemeMusicForMediaObject:nil];
	[super wasPopped];
}

- (void)wasExhumed {
	[[MachineManager sharedMachineManager] setMachineStateMonitorPriority:NO];
	[super wasExhumed];
}

- (void)wasBuried {
	[super wasBuried];
}

#pragma mark -
#pragma mark Plex_SMFBookcaseController Datasource Methods
- (NSString *)headerTitleForBookcaseController:(Plex_SMFBookcaseController *)bookcaseController {
	return localize(@"tvShowsHeader");
}

- (BRImage *)headerIconForBookcaseController:(Plex_SMFBookcaseController *)bookcaseController {
	NSString *headerIcon = [[NSBundle bundleForClass:[HWTVShowsController class]] pathForResource:@"PlexTextLogo" ofType:@"png"];
	return [BRImage imageWithPath:headerIcon];
}

- (NSInteger)numberOfShelfsInBookcaseController:(Plex_SMFBookcaseController *)bookcaseController {
	[allTvShowsSeasonsPlexMediaContainer removeAllObjects];
#if LOCAL_DEBUG_ENABLED
    DLog(@"tvShows.directories: %d",[tvShows.directories count]);
#endif
	return [tvShows.directories count];
}

- (NSString *)bookcaseController:(Plex_SMFBookcaseController *)bookcaseController titleForShelfAtIndex:(NSInteger)index {
	PlexMediaObject *tvshow = [tvShows.directories objectAtIndex:index];
    if (shouldPlayInitialThemeSong && index == 0) {
        [[PlexThemeMusicPlayer sharedPlexThemeMusicPlayer] startPlayingThemeMusicIfAppropiateForMediaObject:tvshow];
        shouldPlayInitialThemeSong = NO;
    }
	return tvshow.name;
}

- (BRPhotoDataStoreProvider *)bookcaseController:(Plex_SMFBookcaseController *)bookcaseController datastoreProviderForShelfAtIndex:(NSInteger)index {
	NSSet *_set = [NSSet setWithObject:[BRMediaType photo]];
	NSPredicate *_pred = [NSPredicate predicateWithFormat:@"mediaType == %@",[BRMediaType photo]];
	BRDataStore *store = [[BRDataStore alloc] initWithEntityName:@"Hello" predicate:_pred mediaTypes:_set];
	
	
	PlexMediaObject *tvshow = [tvShows.directories objectAtIndex:index];
	PlexMediaContainer *seasonsContainer = [tvshow contents];
	[allTvShowsSeasonsPlexMediaContainer addObject:seasonsContainer];
	NSArray *seasons = [seasonsContainer directories];
#if LOCAL_DEBUG_ENABLED
    DLog(@"index: %d, seasons: %d", index, [seasons count]);
#endif
	for (PlexMediaObject *season in seasons) {
		[store addObject:season.previewAsset];
	}
	
    PlexControlFactory *controlFactory = [[PlexControlFactory alloc] initForMainMenu:NO];
	controlFactory.defaultImage = [[BRThemeInfo sharedTheme] storeRentalPlaceholderImage];
	
    BRPhotoDataStoreProvider* provider = [BRPhotoDataStoreProvider providerWithDataStore:store 
																		  controlFactory:controlFactory];
    [store release];
	return provider; 
}

- (void)playThemeMusicForMediaObjectInTimer:(NSTimer *)theTimer {
    PlexMediaObject *mediaObject = [[theTimer userInfo] objectForKey:PlexMediaObjectTvShowKey];
    [[PlexThemeMusicPlayer sharedPlexThemeMusicPlayer] startPlayingThemeMusicIfAppropiateForMediaObject:mediaObject];
}

#pragma mark -
#pragma mark Plex_SMFBookcaseController Delegate Methods
-(void)bookcaseController:(Plex_SMFBookcaseController *)bookcaseController shelf:(BRMediaShelfControl *)shelfControl noLongerFocusedAtIndex:(NSInteger)index {
    PlexMediaObject *tvshow = [tvShows.directories objectAtIndex:index];
    [[PlexThemeMusicPlayer sharedPlexThemeMusicPlayer] stopPlayingThemeMusicForMediaObject:tvshow];
}

-(void)bookcaseController:(Plex_SMFBookcaseController *)bookcaseController shelf:(BRMediaShelfControl *)shelfControl focusedAtIndex:(NSInteger)index {
    PlexMediaObject *tvshow = [tvShows.directories objectAtIndex:index];
    [self.themeMusicTimer invalidate]; //cancel the old timer if it hasn't already fired
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:tvshow forKey:PlexMediaObjectTvShowKey];
    self.themeMusicTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(playThemeMusicForMediaObjectInTimer:) userInfo:userInfo repeats:NO];
}

-(BOOL)bookcaseController:(Plex_SMFBookcaseController *)bookcaseController allowSelectionForShelf:(BRMediaShelfControl *)shelfControl atIndex:(NSInteger)index {
    return YES;
}

-(void)bookcaseController:(Plex_SMFBookcaseController *)bookcaseController selectionWillOccurInShelf:(BRMediaShelfControl *)shelfControl atIndex:(NSInteger)index {
#if LOCAL_DEBUG_ENABLED
	DLog(@"select will occur");
#endif
}

-(void)bookcaseController:(Plex_SMFBookcaseController *)bookcaseController selectionDidOccurInShelf:(BRMediaShelfControl *)shelfControl atIndex:(NSInteger)index {
#if LOCAL_DEBUG_ENABLED
	DLog(@"select did occur at index: %d and shelfindex: %ld",index, [shelfControl focusedIndex]);	
#endif
    
    PlexMediaObject *tvshow = [tvShows.directories objectAtIndex:index];
    
    self.seasonsForSelectedTVShow = [tvshow contents];
    
    PlexMediaObject *season = [self.seasonsForSelectedTVShow.directories objectAtIndex:[shelfControl focusedIndex]];
    
    if ([[season contents] hasOnlyEpisodes]) {
        [[PlexNavigationController sharedPlexNavigationController] navigateToObjectsContents:season];
    }
}

@end
