//
//  PlexNavigationController.m
//  plex
//
//  Created by ccjensen on 18/04/2011.
//

#import "PlexNavigationController.h"
#import "Plex_SynthesizeSingleton.h"
#import "Constants.h"
#import "HWUserDefaults.h"
#import "PlexThemeMusicPlayer.h"
//#import <plex-oss/PlexRequest + Security.h>

//view/controller types
#import "HWSettingsController.h"
#import "PlexChannelsController.h"
#import "PlexSearchController.h"
#import "HWBasicMenu.h"
#import "HWPlexDir.h"
#import "PlexSongListController.h"
#import "HWTVShowsController.h"
#import "HWMediaGridController.h"
#import "PlexPreplayController.h"
#import <SMFramework/SMFControllerPasscodeController.h>
#import "PlexPlaybackController.h"
#import "PlexMediaObject+Assets.h"

@implementation PlexNavigationController
@synthesize waitControl;
@synthesize targetMediaObject;
@synthesize targetController;
@synthesize promptText;

PLEX_SYNTHESIZE_SINGLETON_FOR_CLASS(PlexNavigationController);

- (id)init {
    self = [super init];
    if (self) {
        //this will allow us to have a nice 'wait spinner' when we
        //refactor the code so it can be loaded on a background thread
        BRWaitPromptControl *ctrl = [BRWaitPromptControl new];
        self.waitControl = ctrl;
        [ctrl release];
        
        [self.waitControl setFrame:[BRWindow interfaceFrame]];
        [self addControl:self.waitControl];
    }
    return self;
}

- (void)dealloc {
    [waitControl release];
    [super dealloc];
}

#pragma mark -
#pragma mark Controller Lifecycle behaviour
- (void)wasPushed {
	[[MachineManager sharedMachineManager] setMachineStateMonitorPriority:NO];
	[super wasPushed];
    
    [self.waitControl setPromptText:self.promptText];
    
    //determine view/controller type for target container if not already determined before we were pushed
    //(some types are pre-set like settings, server list, etc)
    if (!self.targetController && self.targetMediaObject) {
        BRController *controller = [self newControllerForObject:self.targetMediaObject];
        self.targetController = controller;
        [controller release];
    }
    
    DLog(@"Navigating using controller type: [%@]", [self.targetController class]);
    [[[BRApplicationStackManager singleton] stack] swapController:self.targetController];
}

- (void)wasPopped {
	[super wasPopped];
}

- (void)wasExhumed {
    //should never get called as we always swap self out of the stack
	[[MachineManager sharedMachineManager] setMachineStateMonitorPriority:NO];
	[super wasExhumed];
}

- (void)wasBuried {
    //should never get called as we always swap self out of the stack
	[super wasBuried];
}

- (void)controlWasActivated {
    [super controlWasActivated];
}

#pragma mark -
#pragma mark Navigation Methods

- (void)initiatePlaybackOfMediaObject:(PlexMediaObject *)aMediaObject {
    DLog(@"Navigating to: [Playback of %@]", aMediaObject);
    self.targetController = nil;
    self.targetMediaObject = nil;
    self.promptText = [NSString stringWithFormat:@"Loading playback of \"%@\"...", self.targetMediaObject.name];
    
    PlexPlaybackController *playbackController = [[PlexPlaybackController alloc] initWithPlexMediaObject:aMediaObject];
    self.targetController = playbackController;
    [playbackController release];
    
    [[[BRApplicationStackManager singleton] stack] pushController:self];
}

- (void)navigateToObjectsContents:(PlexMediaObject *)aMediaObject {
    DLog(@"Navigating to: [%@]", aMediaObject);
    self.targetController = nil;
    self.targetMediaObject = aMediaObject;
    self.promptText = [NSString stringWithFormat:@"Loading \"%@\"...", self.targetMediaObject.name];
    
    [[[BRApplicationStackManager singleton] stack] pushController:self];
}

- (void)navigateToSearchForMachine:(Machine *)aMachine {
    DLog(@"Navigating to: [Search], for machine: [%@]", aMachine.userName);
    self.targetController = nil;
    self.targetMediaObject = nil;
    self.promptText = @"Loading \"Search\"...";
    
    PlexSearchController *searchController = [[PlexSearchController alloc] initWithMachine:aMachine];
    self.targetController = searchController;
    [searchController release];
    
    [[[BRApplicationStackManager singleton] stack] pushController:self];
}

- (void)navigateToChannelsForMachine:(Machine *)aMachine {
    DLog(@"Navigating to: [Channels], for machine: [%@]", aMachine.userName);
    self.targetController = nil;
    self.targetMediaObject = nil;
    self.promptText = @"Loading \"Channels\"...";
    
    PlexMediaContainer* channelsContainer = [aMachine.request channels];
    PlexChannelsController *channelsController = [[PlexChannelsController alloc] initWithRootContainer:channelsContainer];
    self.targetController = channelsController;
    [channelsController release];
    
    [[[BRApplicationStackManager singleton] stack] pushController:self];
}

- (void)navigateToSettingsWithTopLevelController:(BRBaseAppliance *)topLevelController {
    DLog(@"Navigating to: [Settings]");
    self.targetController = nil;
    self.targetMediaObject = nil;
    self.promptText = @"Loading \"Settings\"...";
    
    HWSettingsController *settingsController = [[HWSettingsController alloc] init];
    settingsController.topLevelController = topLevelController;
    
    if ([[HWUserDefaults preferences] boolForKey:PreferencesSecuritySettingsLockEnabled]) {
        NSInteger securityPasscode = [[HWUserDefaults preferences] integerForKey:PreferencesSecurityPasscode];
        SMFControllerPasscodeController *passcodeController = [[SMFControllerPasscodeController alloc] initForController:settingsController withPasscode:securityPasscode];
        [settingsController release];
        self.targetController = passcodeController;
        [passcodeController release];
    } else {
        self.targetController = settingsController;
        [settingsController release];
    }
    
    [[[BRApplicationStackManager singleton] stack] pushController:self];
}

- (void)navigateToServerList {
    DLog(@"Navigating to: [Server List]");
    self.targetController = nil;
    self.targetMediaObject = nil;
    self.promptText = @"Loading \"Server List\"...";
    
    HWBasicMenu *serverList = [[HWBasicMenu alloc] init];
    self.targetController = serverList;
    [serverList release];
    
    [[[BRApplicationStackManager singleton] stack] pushController:self];
}


#pragma mark -
#pragma mark Determine View Type Methods
- (BRController *)newControllerForObject:(PlexMediaObject *)aMediaObject {
    BRController *controller = nil;
    
    //play theme music if we're entering a tv show
    if (aMediaObject.isTVShow || aMediaObject.isSeason || aMediaObject.isEpisode) {
        [[PlexThemeMusicPlayer sharedPlexThemeMusicPlayer] startPlayingThemeMusicIfAppropiateForMediaObject:aMediaObject];
    }
    // ========== movie, initiate movie pre-play view ============
    if (aMediaObject.hasMedia || [@"Video" isEqualToString:aMediaObject.containerType]) {
        return [[PlexPreplayController alloc] initWithPlexMediaObject:aMediaObject];
    }
    // ============ sound plugin or other type of sound, initiate playback ============
    else if ([@"Track" isEqualToString:aMediaObject.containerType]){
        return [[PlexPlaybackController alloc] initWithPlexMediaObject:aMediaObject];
	}
    
    PlexMediaContainer *contents = [aMediaObject contents];
    
    // ============ music view ============
    if ([PlexViewGroupAlbum isEqualToString:aMediaObject.mediaContainer.viewGroup] 
        || [@"albums" isEqualToString:aMediaObject.mediaContainer.content] 
        || [@"playlists" isEqualToString:aMediaObject.mediaContainer.content]) {
        return [[PlexSongListController alloc] initWithPlexContainer:contents title:aMediaObject.name];
    }
    
    // ============ tv or movie view ============
    NSInteger requestedViewType = 0;
    if (aMediaObject.isMovie) {
        requestedViewType = [[HWUserDefaults preferences] integerForKey:PreferencesViewTypeForMovies];
    } else {
        requestedViewType = [[HWUserDefaults preferences] integerForKey:PreferencesViewTypeForTvShows];
    }
    
    BRTabControl *tabBar = nil;
    switch (requestedViewType) {
        case kATVPlexViewTypeList: {
            //only filter and create tab bar if we are navigating plex's built in stuff
            if ([contents.identifier isEqualToString:@"com.plexapp.plugins.library"]) {
                contents = [self applySkipFilteringOnContainer:contents];
                tabBar = [self newTabBarForContents:contents];
            }
            
            controller = [[HWPlexDir alloc] initWithRootContainer:contents andTabBar:tabBar];
            break;
        }
        case kATVPlexViewTypeGrid: {
            if (aMediaObject.isMovie) {
                controller = [self newGridController:contents withShelfKeyString:@"recentlyAdded"];
            } else {
                controller = [self newGridController:contents withShelfKeyString:@"recentlyViewedShows"];
            }
            break;
        }
        case kATVPlexViewTypeBookcase: {
            controller = [self newTVShowsController:contents];
            break;
        }
        default:
            break;
    }
    
    if (!controller) {
        //if all else fails, use list view
        controller = [[HWPlexDir alloc] initWithRootContainer:contents andTabBar:tabBar];
    }
    return controller;
}

- (BRTabControl *)newTabBarForContents:(PlexMediaContainer *)someContents {
    BRTabControl *tabBar = nil;

    if (![someContents.viewGroup isEqualToString:PlexViewGroupSecondary]) { 
        //now that we are skipping the filtering menu, this if should always come back true (maybe remove it?)
        tabBar = [[BRTabControl menuTabControl] retain];
        
        BRTabControlItem *i = [[BRTabControlItem alloc] init];
        NSString *currentlySelectedFilterName;
        if (someContents.parentFilterContainer) {
            PlexMediaObject *parentMediaObject = someContents.parentObject;
            //store the selection for future reference
            NSString *filter = parentMediaObject.lastKeyComponent;
            [someContents.request.machine setFilter:filter forSection:parentMediaObject.mediaContainer.key];
            
            //custom name if we are one step below the filters (which we skip)
            //so this would be used in the tv shows listing, movies listing, etc
            currentlySelectedFilterName = parentMediaObject.name;
        } else {
            //the user will not be given the option of other filters (tab item "Other Filters")
            //so we only give them the generic "All" and "Unwatched"
            currentlySelectedFilterName = @"All";
        }
        [i setLabel:currentlySelectedFilterName];
        [i setIdentifier:TabBarCurrentItemsIdentifier];
        [tabBar addTabItem:i];
        [i release];
        
        //this one is always added, though perhaps needs to not be included in the music views?
        i = [[BRTabControlItem alloc] init];
        [i setLabel:@"Unwatched"];
        [i setIdentifier:TabBarUnwatchedItemsIdentifier];
        [tabBar addTabItem:i];
        [i release];
        
        
        if (someContents.parentFilterContainer) {
            //only add third item if we are navigating to one step below the filters (which we skip)
            //so this would be visible in the tv shows listing, movies listing, etc
            i = [[BRTabControlItem alloc] init];
            [i setLabel:@"Other Filters"];
            [i setIdentifier:someContents.parentFilterContainer];
            [tabBar addTabItem:i];
            [i release];
        }
    }
    return tabBar;
}


#pragma mark -
#pragma mark Container Manipulation Methods
- (BRController *)newTVShowsController:(PlexMediaContainer *)tvShowCategory {
	BRController *menuController = nil;
	PlexMediaObject *allTvShows=nil;
	if (tvShowCategory.directories > 0) {
		NSUInteger i, count = [tvShowCategory.directories count];
		for (i = 0; i < count; i++) {
			PlexMediaObject * obj = [tvShowCategory.directories objectAtIndex:i];
			NSString *key = [obj.attributes objectForKey:@"key"];
			DLog(@"obj_type: %@",key);
			if ([key isEqualToString:@"all"]) {
				allTvShows = obj;
				break;
			}
		}
	}
	
	if (allTvShows) {
		menuController = [[HWTVShowsController alloc] initWithPlexAllTVShows:[allTvShows contents]];
	}
	return menuController;
}

- (BRController *)newGridController:(PlexMediaContainer *)movieCategory withShelfKeyString:(NSString *)shelfKey {
	BRController *menuController = nil;
	PlexMediaObject *recent=nil;
	PlexMediaObject *allMovies=nil;
    DLog(@"showGridListControl_movieCategory_directories: %@", movieCategory.directories);
	if (movieCategory.directories > 0) {
		NSUInteger i, count = [movieCategory.directories count];
		for (i = 0; i < count; i++) {
			PlexMediaObject * obj = [movieCategory.directories objectAtIndex:i];
			NSString *key = [obj.attributes objectForKey:@"key"];
			DLog(@"obj_type: %@",key);
			if ([key isEqualToString:@"all"])
				allMovies = obj;
			else if ([key isEqualToString:shelfKey])
				recent = obj;
		}
	}
	
	if (recent && allMovies){
		menuController = [[HWMediaGridController alloc] initWithPlexAllMovies:[allMovies contents] andRecentMovies:[recent contents]];
	}
	return menuController;
}


- (PlexMediaContainer *)applySkipFilteringOnContainer:(PlexMediaContainer *)container {
	PlexMediaContainer *pmc = container;

	if (pmc.sectionRoot && !pmc.requestsMessage) { 
		//open "/library/section/x/all or the first item in the list"
		//bypass the first filter node
		
        //TODO: store filtering selection
		Machine *currentMachine = container.request.machine;
		const NSString* filterWeAreLookingFor = [currentMachine filterForSection:pmc.key]; //all, unwatched, recentlyAdded, etc
		BOOL handled = NO;
		PlexMediaContainer* newPmc = nil;
		
		for(PlexMediaObject* po in pmc.directories){
			if ([filterWeAreLookingFor isEqualToString:po.lastKeyComponent]) { //po.lastKeyComponent == one of [all, unwatched, recentlyAdded, etc]
				PlexMediaContainer* potentialNewPmc = [po contents]; //the contents like all the tv shows, movies, etc
				if (potentialNewPmc.directories.count>0) 
                    newPmc = potentialNewPmc; //if it contains at least some stuff, then use it
				handled = YES;
				break;
			}
		}
		
		if (handled && newPmc==nil) 
            newPmc = [[pmc.directories objectAtIndex:0] contents]; //if we did find it, but it was empty, use the "default"
        
		if (newPmc==nil || newPmc.directories.count==0) { //if it wasn't "handled"
			for (PlexMediaObject* po in pmc.directories) { //iterate over all again
				PlexMediaContainer* potentialNewPmc = [po contents]; //the contents like all the tv shows, movies, etc
				if (potentialNewPmc.directories.count>0) { //find the first one who has some contents
					newPmc = potentialNewPmc;
					handled = YES;
					break;
				}
			}
		}
		
		if (newPmc) {
			pmc = newPmc; //if found, store it
		}
		
		if (!handled && pmc.directories.count>0) pmc = [[pmc.directories objectAtIndex:0] contents]; //we have failed, just use the "default
        DLog(@"done filtering: [%@] vs [%@], handled: [%@]", container, pmc, handled ? @"YES" : @"NO");
	}
	return pmc;
}

@end
