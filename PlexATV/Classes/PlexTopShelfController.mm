//
//  PlexTopShelfController.m
//  plex
//
//  Created by tomcool
//  Modified by ccjensen
//

#define LOCAL_DEBUG_ENABLED 1

#import "PlexTopShelfController.h"
#import "HWAppliance.h"
#import "BackRowExtras.h"
#import "PlexBaseMetadataAsset.h"
#import <plex-oss/PlexMediaContainer.h>
#import <plex-oss/PlexMediaObject.h>
#import <plex-oss/PlexRequest.h>
#import "PlexMediaObject+Assets.h"
#import "PlexNavigationController.h"
#import "Localize.h"

#pragma mark -
#pragma mark BRTopShelfView Category
@interface BRTopShelfView (specialAdditions)
- (BRImageControl *)productImage;
@end

@implementation BRTopShelfView (specialAdditions)
- (BRImageControl *)productImage {
	return MSHookIvar<BRImageControl *>(self, "_productImage");
}
@end



#pragma mark -
#pragma mark PlexTopShelfController Implementation
@implementation PlexTopShelfController
@synthesize containerName;
@synthesize onDeckMediaContainer;
@synthesize recentlyAddedMediaContainer;


#pragma mark -
#pragma mark Object/Class Lifecycle
- (void)dealloc {
	[topShelfView release];
	self.onDeckMediaContainer = nil;
	self.recentlyAddedMediaContainer = nil;
    
	[super dealloc];
}

- (BRTopShelfView *)topShelfView {
    if (!topShelfView) {
        topShelfView = [[BRTopShelfView alloc] init];
        
        BRImageControl *imageControl = [topShelfView productImage];
        BRImage *theImage = [BRImage imageWithPath:[[NSBundle bundleForClass:[PlexTopShelfController class]] pathForResource:@"PmsMainMenuLogo" ofType:@"png"]];
        [imageControl setImage:theImage];
        
        shelfView = MSHookIvar<BRMediaShelfView*>(topShelfView, "_shelf");
        shelfView.scrollable = YES;
        shelfView.dataSource = self;
        shelfView.delegate = self;
        
        [self refresh];
    }
	return topShelfView;
}

- (void)setContentToContainer:(PlexMediaContainer *)aMediaContainer {
    self.containerName = aMediaContainer.name;
    
    NSString *onDeckQuery = [NSString stringWithFormat:@"%@/onDeck", aMediaContainer.key];
    PlexMediaContainer *onDeckContainer = [aMediaContainer.request query:onDeckQuery callingObject:nil ignorePresets:YES timeout:20 cachePolicy:NSURLRequestUseProtocolCachePolicy];
    self.onDeckMediaContainer = onDeckContainer;
    
    NSString *recentlyAddedQuery = [NSString stringWithFormat:@"%@/recentlyAdded", aMediaContainer.key];
    PlexMediaContainer *recentlyAddedContainer = [aMediaContainer.request query:recentlyAddedQuery callingObject:nil ignorePresets:YES timeout:20 cachePolicy:NSURLRequestUseProtocolCachePolicy];
    self.recentlyAddedMediaContainer = recentlyAddedContainer;
}

- (void)refresh {
#if LOCAL_DEBUG_ENABLED
    DLog(@"on deck: [%@] count [%d]", self.onDeckMediaContainer, [self.onDeckMediaContainer.directories count]);
    DLog(@"recently added: [%@] count [%d]", self.recentlyAddedMediaContainer, [self.recentlyAddedMediaContainer.directories count]);
#endif
    if ([self.onDeckMediaContainer.directories count] > 0 || [self.recentlyAddedMediaContainer.directories count] > 0) {
#if LOCAL_DEBUG_ENABLED
        DLog(@"Activate main menu shelf");
#endif
        [topShelfView setState:1]; //shelf
		[shelfView reloadData];
	} else {
#if LOCAL_DEBUG_ENABLED
        DLog(@"Activate main menu banner");
#endif
		[topShelfView setState:0]; //banner image
    }
}


#pragma mark -
#pragma mark BRMediaShelf Datasource Methods
-(long)numberOfFlatColumnsInMediaShelf:(BRMediaShelfView *)view {
    return 7;
}

-(float)horizontalGapForMediaShelf:(BRMediaShelfView *)view {
    return 30.0f;
}

-(float)coverflowMarginForMediaShelf:(BRMediaShelfView *)view {
    return 0.05000000074505806;
}

-(long)numberOfSectionsInMediaShelf:(BRMediaShelfView *)view {
    return 2;
}

-(id)mediaShelf:(BRMediaShelfView *)view sectionHeaderForSection:(long)section {
    return nil;
}

-(id)mediaShelf:(BRMediaShelfView *)view titleForSectionAtIndex:(long)section {
    //PlexMediaContainer *aMediaContainer = section == 0 ? self.onDeckMediaContainer : self.recentlyAddedMediaContainer;
    NSString *title = [NSString stringWithFormat:@"%@ : %@", self.containerName, section == 0 ? localize(@"topShelfOnDeck") : localize(@"topShelfRecentlyAdded")];
    
    BRTextControl *titleControl = [[BRTextControl alloc] init];
    
    NSMutableDictionary *titleAttributes = [NSMutableDictionary dictionary];
    [titleAttributes setValue:@"HelveticaNeueATV" forKey:@"BRFontName"];
    [titleAttributes setValue:[NSNumber numberWithInt:21] forKey:@"BRFontPointSize"];
    [titleAttributes setValue:[NSNumber numberWithInt:4] forKey:@"BRLineBreakModeKey"];
    [titleAttributes setValue:[NSNumber numberWithInt:0] forKey:@"BRTextAlignmentKey"];
    [titleAttributes setValue:(id)[[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f] CGColor] forKey:@"CTForegroundColor"];
    [titleAttributes setValue:[NSValue valueWithCGSize:CGSizeMake(0, -2)] forKey:@"BRShadowOffset"];
    
    [titleControl setText:title withAttributes:titleAttributes];
	return [titleControl autorelease];
}

-(long)mediaShelf:(BRMediaShelfView *)view numberOfColumnsInSection:(long)section {
    PlexMediaContainer *aMediaContainer = section == 0 ? self.onDeckMediaContainer : self.recentlyAddedMediaContainer;
    return [aMediaContainer.directories count];
}


-(id)mediaShelf:(BRMediaShelfView *)view itemAtIndexPath:(NSIndexPath *)indexPath {
    int section = [indexPath indexAtPosition:0];
    int row = [indexPath indexAtPosition:1];
    
    PlexMediaContainer *aMediaContainer = section == 0 ? self.onDeckMediaContainer : self.recentlyAddedMediaContainer;
    
    PlexMediaObject *pmo = [aMediaContainer.directories objectAtIndex:row];
    PlexBaseMetadataAsset *asset = pmo.previewAsset;
	NSString *title = [asset title];
    
    BRPosterControl *poster = [[BRPosterControl alloc] init];
    poster.posterStyle = 1;
    poster.cropAspectRatio = 0.66470599174499512;
    
    poster.imageProxy = [asset imageProxy];
    poster.defaultImage = [asset defaultImage];
    poster.reflectionAmount = 0.10000000149011612;
    poster.reflectionBaseline = 0.072999998927116394;
    
    poster.titleVerticalOffset = 0.039999999105930328;
    [poster setNonAttributedTitleWithCrossfade:title];
    
    return poster;
}


#pragma mark -
#pragma mark BRMediaShelf Delegate Methods
- (void)mediaShelf:(id)shelf didSelectItemAtIndexPath:(id)indexPath {
    int section = [indexPath indexAtPosition:0];
    int row = [indexPath indexAtPosition:1];
    
    PlexMediaContainer *aMediaContainer = section == 0 ? self.onDeckMediaContainer : self.recentlyAddedMediaContainer;
    
    PlexMediaObject* pmo = [aMediaContainer.directories objectAtIndex:row];
    
#if LOCAL_DEBUG_ENABLED
    DLog(@"selecting [%@]", pmo);
#endif
    
    [[SMFThemeInfo sharedTheme] playSelectSound];
    [[PlexNavigationController sharedPlexNavigationController] navigateToObjectsContents:pmo];
}

- (void)mediaShelf:(id)shelf didPlayItemAtIndexPath:(id)indexPath {
    int section = [indexPath indexAtPosition:0];
    int row = [indexPath indexAtPosition:1];
    
    PlexMediaContainer *aMediaContainer = section == 0 ? self.onDeckMediaContainer : self.recentlyAddedMediaContainer;
    
    PlexMediaObject* pmo = [aMediaContainer.directories objectAtIndex:row];
    
#if LOCAL_DEBUG_ENABLED
    DLog(@"playing [%@]", pmo);
#endif
    
    if (pmo.hasMedia) {
        //play media
        [[PlexNavigationController sharedPlexNavigationController] initiatePlaybackOfMediaObject:pmo];
    } else {
        //not media, pretend it was a selection
        [self mediaShelf:shelf didSelectItemAtIndexPath:indexPath];
    }
}

//methods below are never called
- (void)mediaShelf:(id)shelf didFocusItemAtIndexPath:(id)indexPath {
	DLog(@"didFocusItemAtIndexPath never called");
    //int section = [indexPath indexAtPosition:0];
    //int row = [indexPath indexAtPosition:1];
}

- (BOOL)handleObjectSelection:(id)selection userInfo:(id)info {
	DLog(@"handleObjectSelection never called");
    return NO;
}

- (void)selectCategoryWithIdentifier:(id)identifier {
	DLog(@"selectCategoryWithIdentifier never called");
}

@end