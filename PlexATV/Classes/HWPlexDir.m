//
//  HWPlexDir.m
//  atvTwo
//
//  Created by Frank Bauer on 22.10.10.
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//  

#import "HWPlexDir.h"
#import "Constants.h"
#import <plex-oss/PlexMediaObject.h>
#import <plex-oss/PlexMediaContainer.h>
#import <plex-oss/PlexImage.h>
#import <plex-oss/PlexRequest.h>
#import <plex-oss/Preferences.h>
#import "PlexMediaProvider.h"
#import "PlexMediaObject+Assets.h"
#import "HWUserDefaults.h"
#import "PlexNavigationController.h"
#import "PlexThemeMusicPlayer.h"
#import "PlexAudioSubsController.h"

#define LOCAL_DEBUG_ENABLED 1
#define ModifyViewStatusOptionDialog @"ModifyViewStatusOptionDialog"

@implementation HWPlexDir
@synthesize rootContainer;
@synthesize tabBar;
@synthesize items;
@synthesize previewControlData;

#pragma mark -
#pragma mark Object/Class Lifecycle

- (id)init {
    self = [super init];
    if (self) {
        [self setListTitle:@"PLEX"];
		
		NSString *plexIcon = [[NSBundle bundleForClass:[HWPlexDir class]] pathForResource:@"PlexIcon" ofType:@"png"];
		BRImage *listIcon = [BRImage imageWithPath:plexIcon];
		[self setListIcon:listIcon horizontalOffset:0.0 kerningFactor:0.15];
        
		rootContainer = nil;        
        [self.list setDatasource:self];
    }
    return self;
}

- (id)initWithRootContainer:(PlexMediaContainer*)container andTabBar:(BRTabControl *)aTabBar {
	self = [self init];
	self.rootContainer = container;
    self.listTitle = self.rootContainer.name;
    self.items = [self.rootContainer directories];
    self.tabBar = aTabBar;
    if (self.tabBar) {
        [self.tabBar setAcceptsFocus:NO];
        [self.tabBar setTabControlDelegate:self];
        [self addControl:self.tabBar];
        
        //find last selected tab item [defaulted to 0]
        NSInteger lastTabBarSelection = [HWUserDefaults lastTabBarSelectionForViewGroup:self.rootContainer.viewGroup];
        [self.tabBar selectTabItemAtIndex:lastTabBarSelection];
    }
	return self;
}

-(void)dealloc {
	[playbackItem release];
	[rootContainer release];
    [tabBar release];
    [items release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark Controller Lifecycle behaviour
- (void)wasPushed {
	[[MachineManager sharedMachineManager] setMachineStateMonitorPriority:NO];
	[super wasPushed];
}

- (void)wasPopped {
    [[PlexThemeMusicPlayer sharedPlexThemeMusicPlayer] stopPlayingThemeMusicForMediaObject:self.rootContainer.parentObject];
	[super wasPopped];
}

- (void)wasExhumed {
	[[MachineManager sharedMachineManager] setMachineStateMonitorPriority:NO];
    
    //refresh tab bar in case any items have changed
    [self reselectCurrentTabBarItem];
	[super wasExhumed];
}

- (void)wasBuried {
	[super wasBuried];
}

#pragma mark -
#pragma mark Controller Drawing and Events
-(void)layoutSubcontrols {
    [super layoutSubcontrols];
    
    if (self.tabBar) {
        //if there is a tab bar, move the list down to make room for it
        //thanks to tom for the layout code
        CGRect listFrame = [self list].frame;
        listFrame.size.height = 550.0f;
        listFrame.size.width = listFrame.size.width; //don't change the width
        listFrame.origin.x = listFrame.origin.x;
        id l = [self list];
        [l setFrame:listFrame];
        
        //tab bar same width as list

        [self.tabBar setFrame:CGRectMake(listFrame.origin.x+36.f, 567.f, 516.f, 25.f)];
    }
}

//handle custom event
-(BOOL)brEventAction:(BREvent *)event {
	int remoteAction = [event remoteAction];
#if LOCAL_DEBUG_ENABLED
    DLog(@"remoteaction [%d] with event value [%d]", remoteAction, [event value]);
#endif
	if ([(BRControllerStack *)[self stack] peekController] != self)
		remoteAction = 0;
	
	int listItemCount = [[(BRListControl *)[self list] datasource] itemCount];
	switch (remoteAction)
	{
		case kBREventRemoteActionSelectHold: {
			if([event value] == 1) {
				//get the index of currently selected row
				long selected = [self getSelection];
				[self showModifyViewedStatusViewForRow:selected];
			}
			break;
		}
		case kBREventRemoteActionSwipeLeft:
		case kBREventRemoteActionLeft:
            if([event value] == 1) {
                [self.tabBar selectPreviousTabItem];
                return YES;
            }
			break;
		case kBREventRemoteActionSwipeRight:
		case kBREventRemoteActionRight:
            if([event value] == 1) {
                [self.tabBar selectNextTabItem];
                return YES;
            }
			break;
		case kBREventRemoteActionPlayPause:
        case kBREventRemoteActionPlayPause2:
			if([event value] == 1) {
				[self playPauseActionForRow:[self getSelection]];
            }
			return YES;
			break;
		case kBREventRemoteActionUp:
		case kBREventRemoteActionHoldUp:
			if([self getSelection] == 0 && [event value] == 1)
			{
				[self setSelection:listItemCount-1];
				return YES;
			}
			break;
		case kBREventRemoteActionDown:
		case kBREventRemoteActionHoldDown:
			if([self getSelection] == listItemCount-1 && [event value] == 1)
			{
				[self setSelection:0];
				return YES;
			}
			break;
	}
	return [super brEventAction:event];
}


#pragma mark -
#pragma mark BRTabBarControllerDelegate Methods
- (void)tabControl:(id)control willSelectTabItem:(id)item {
    //nothing needed
}

- (void)tabControl:(id)control didSelectTabItem:(id)item {
    //change tab
    NSInteger newTabSelection = [self.tabBar selectedTabItemIndex];
    
    //persist the selection for this section type
    NSString *viewGroup = self.rootContainer.viewGroup;
    
    
    NSArray *allItems = self.rootContainer.directories;    
    switch (newTabSelection) {
        case TabBarCurrentItemsIndex: {
            [HWUserDefaults setLastTabBarSelection:TabBarCurrentItemsIndex forViewGroup:viewGroup];
            self.items = allItems;
            break;
        }
        case TabBarUnwatchedItemsIndex: {
            [HWUserDefaults setLastTabBarSelection:TabBarUnwatchedItemsIndex forViewGroup:viewGroup];
            NSPredicate *unwatchedItemsPredicate = [NSPredicate predicateWithFormat:@"seenState != %d", PlexMediaObjectSeenStateSeen];
            self.items = [allItems filteredArrayUsingPredicate:unwatchedItemsPredicate];
            break;
        }
        case TabBarOtherFiltersItemsIndex: {
            PlexMediaContainer *filters = (PlexMediaContainer *)[item identifier];
            self.items = filters.directories;
            break;
        }
    }
    [self.list reload];
}

- (void)tabControlDidChangeNumberOfTabItems:(id)tabControl {
    //not possible at this stage
}

- (void)reselectCurrentTabBarItem {
    //call the delegate methods to kick of a refresh of what items should be listed in the list
    [self tabControl:self.tabBar willSelectTabItem:[self.tabBar selectedTabItem]];
    [self tabControl:self.tabBar didSelectTabItem:[self.tabBar selectedTabItem]];
}

#pragma mark -
#pragma mark BRMenuListItemProvider Datasource
- (long)itemCount {
	return [self.items count];
}

- (float)heightForRow:(long)row {
    PlexMediaObject *pmo = [self.items objectAtIndex:row];
	return pmo.heightForMenuItem; 
}

- (id)titleForRow:(long)row {
	PlexMediaObject *pmo = [self.items objectAtIndex:row];
	return pmo.name;
}

- (id)itemForRow:(long)row {
	if(row > [self.items count])
		return nil;
	
	PlexMediaObject *pmo = [self.items objectAtIndex:row];
	return pmo.menuItem;
}

#define kParadeItemIndex @"kParadeItemIndex"
#define kParadeItem @"kParadeItem"
#define kParadeControl @"kParadeControl"
- (id)previewControlForItem:(long)item {    
    id preview = nil;
    
    //stop the timer for parade control, which was setup for previously selected item
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
	PlexMediaObject* pmo = [self.items objectAtIndex:item];
    
    //we force set the hash so two movies with same title don't end up with the same preview
    [self setValue:[pmo description] forKey:@"_previewControlItemHash"];
    
    if ([tabBar selectedTabItemIndex] == TabBarOtherFiltersItemsIndex) {
        //show parade only after it's been built in the background
        //see ticket #108 - Tab switching can be slow
        
        if (self.previewControlData != nil && [[self.previewControlData objectForKey:kParadeItemIndex] longValue] == item) {
            //we have already created preview for this item, just return that
            return [self.previewControlData objectForKey:kParadeControl];
        }
        NSNumber *itemIndex = [NSNumber numberWithLong:item]; //need object to be able to store it in dict
        NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithObjectsAndKeys:pmo, kParadeItem, itemIndex, kParadeItemIndex, nil];
        
        //creating parade in bg, once done this will set self.previewControlData and refresh the preview control
        [self performSelectorInBackground:@selector(createParadeForData:) withObject:data];
        
    } else {
        //single coverart
        preview = pmo.previewControl; //already autoreleased
        DLog();
    }
	return preview;
}

- (void)finishedCreatingParade:(NSDictionary *)data {
    self.previewControlData = data;
    [self updatePreviewController];
}

- (void)createParadeForData:(NSMutableDictionary *)data {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    PlexMediaObject *pmo = [data objectForKey:kParadeItem];
    
    NSMutableArray *imageProxies = [NSMutableArray array];
    PlexMediaContainer *subItemsContainer = [pmo contents];
    NSArray *subItems = subItemsContainer.directories;
    
    for (PlexMediaObject *pmo in subItems) {
        PlexPreviewAsset *previewAsset = [pmo previewAsset];
        [imageProxies addObject:[previewAsset imageProxy]];
    }   
    
    id preview = [[[BRMediaParadeControl alloc] init] autorelease];
    [preview setImageProxies:imageProxies];
    
#if LOCAL_DEBUG_ENABLED
    DLog(@"parade control created");
#endif
    
    [data setObject:preview forKey:kParadeControl];
    [self performSelectorOnMainThread:@selector(finishedCreatingParade:) withObject:data waitUntilDone:NO];
    
    [pool drain];
}

#pragma mark -
#pragma mark BRMenuListItemProvider Delegate
- (BOOL)rowSelectable:(long)selectable {
	return TRUE;
}

- (void)itemSelected:(long)selected; {
	PlexMediaObject* pmo = [self.items objectAtIndex:selected];
    [[PlexNavigationController sharedPlexNavigationController] navigateToObjectsContents:pmo];
}

-(void)playPauseActionForRow:(long)row {
    PlexMediaObject* pmo = [self.items objectAtIndex:row];
    if (pmo.hasMedia) {
        //play media
        [[PlexNavigationController sharedPlexNavigationController] initiatePlaybackOfMediaObject:pmo];
    } else {
        //not media, pretend it was a selection
        [self.list.datasource itemSelected:row];
    }
}

#pragma mark -
#pragma mark Actions
- (void)showModifyViewedStatusViewForRow:(long)row {
    //get the currently selected row
	PlexMediaObject* pmo = [self.items objectAtIndex:row];
	NSString *plexMediaObjectType = [pmo.attributes valueForKey:@"type"];
	
	if (pmo.hasMedia 
        || [@"Video" isEqualToString:pmo.containerType]
        || [@"show" isEqualToString:plexMediaObjectType]
        || [@"season" isEqualToString:plexMediaObjectType]) {
		//show dialog box
		BROptionDialog *optionDialogBox = [[BROptionDialog alloc] init];
		[optionDialogBox setIdentifier:ModifyViewStatusOptionDialog];
		
		[optionDialogBox setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                      pmo, @"mediaObject",
                                      nil]];
		
		[optionDialogBox setPrimaryInfoText:@"Modify View Status"];
		[optionDialogBox setSecondaryInfoText:pmo.name];
		
		
		NSString *watchOption = nil;
		NSString *unwatchOption = nil;
		if (pmo.hasMedia || [@"Video" isEqualToString:pmo.containerType]) {
			//modify single media item
			watchOption = @"Mark as Watched";
			unwatchOption = @"Mark as Unwatched";
		} else if (!pmo.hasMedia && [@"show" isEqualToString:plexMediaObjectType]) {
			//modify all seasons within show
			watchOption = @"Mark entire show as Watched";
			unwatchOption = @"Mark entire show as Unwatched";
		} else if (!pmo.hasMedia && [@"season" isEqualToString:plexMediaObjectType]) {
			//modify all episodes within season
			watchOption = @"Mark entire season as Watched";
			unwatchOption = @"Mark entire season as Unwatched";
		}
		
		[optionDialogBox addOptionText:watchOption];
		[optionDialogBox addOptionText:unwatchOption];
		[optionDialogBox addOptionText:@"Go back"];
		[optionDialogBox setActionSelector:@selector(optionSelected:) target:self];
		[[self stack] pushController:optionDialogBox];
		[optionDialogBox autorelease];
	}
}

- (void)optionSelected:(id)sender {
	BROptionDialog *option = sender;
	PlexMediaObject *pmo = [option.userInfo objectForKey:@"mediaObject"];
	if ([option.identifier isEqualToString:ModifyViewStatusOptionDialog]) {		
		if([[sender selectedText] hasSuffix:@"Watched"]) {
			//mark item(s) as watched
			[[[BRApplicationStackManager singleton] stack] popController]; //need this so we don't go back to option dialog when going back
			DLog(@"Marking as watched: %@", pmo.name);
            [pmo markSeen];            
            [self reselectCurrentTabBarItem];
		} else if ([[sender selectedText] hasSuffix:@"Unwatched"]) {
			//mark item(s) as unwatched
			[[self stack] popController]; //need this so we don't go back to option dialog when going back
			DLog(@"Marking as unwatched: %@", pmo.name);
			[pmo markUnseen];
            [self reselectCurrentTabBarItem];
            //[self tabControlChangedTo:[self.tabBar selectedTabItemIndex]];
		} else if ([[sender selectedText] isEqualToString:@"Go back"]) {
			//go back to movie listing...
			[[[BRApplicationStackManager singleton] stack] popController];
		}
	}
}

@end
