//
//  PlexViewSettingsController.m
//  atvTwo
//
//  Created by ccjensen on 10/01/2011.
//
//  Inspired by 
//
//		MLoader.m
//		MextLoader
//
//		Created by Thomas Cool on 10/22/10.
//		Copyright 2010 tomcool.org. All rights reserved.
//

#import "PlexViewSettingsController.h"
#import "HWUserDefaults.h"
#import "Constants.h"

@implementation PlexViewSettingsController

//----------- general -----------
#define ViewTypeSettingIndex                        0
#define DisableThemeMusicIndex                      1
//----------- list -----------
#define EnableSkipFilteringOptionsMenuIndex         2
#define DisablePosterZoomingInListViewIndex         3
//----------- detailed metadata -----------
#define DisableFanartInDetailedMetadataViewIndex    4

#pragma mark -
#pragma mark Object/Class Lifecycle
- (id) init {
	if((self = [super init]) != nil) {
		[self setLabel:@"Plex View Settings"];
		[self setListTitle:@"Plex View Settings"];
		
		[self setupList];
        [[self list] addDividerAtIndex:0 withLabel:@"General"];
        [[self list] addDividerAtIndex:2 withLabel:@"List"];
        [[self list] addDividerAtIndex:4 withLabel:@"Detailed Metadata"];
	}	
	return self;
}

- (void)dealloc {
	[super dealloc];	
}


#pragma mark -
#pragma mark Controller Lifecycle behaviour
- (void)wasPushed {
	[[MachineManager sharedMachineManager] setMachineStateMonitorPriority:NO];
	[super wasPushed];
}

- (void)wasPopped {
	[super wasPopped];
}

- (void)wasExhumed {
	[[MachineManager sharedMachineManager] setMachineStateMonitorPriority:NO];
	[self setupList];
	[self.list reload];
	[super wasExhumed];
}

- (void)wasBuried {
	[super wasBuried];
}

- (void)setupList {
	[_items removeAllObjects];
    
    // =========== general ===========
  	// =========== view type setting ===========
	SMFMenuItem *viewTypeSettingMenuItem = [SMFMenuItem menuItem];
	
	NSString *viewTypeSetting = [[HWUserDefaults preferences] objectForKey:PreferencesViewTypeSetting];
	if (viewTypeSetting == nil) {
		[[HWUserDefaults preferences] setObject:@"Grid" forKey:PreferencesViewTypeSetting];
		viewTypeSetting = [[HWUserDefaults preferences] objectForKey:PreferencesViewTypeSetting];
	}

	[viewTypeSettingMenuItem setTitle:@"Video view"];
    [viewTypeSettingMenuItem setRightText:viewTypeSetting];
	[_items addObject:viewTypeSettingMenuItem];
    

    // =========== disable poster zooming in list view ===========
	SMFMenuItem *disableThemeMusicMenuItem = [SMFMenuItem menuItem];
	
	[disableThemeMusicMenuItem setTitle:@"Disable theme music"];
	NSString *disableThemeMusic = [[HWUserDefaults preferences] boolForKey:PreferencesViewDisableThemeMusic] ? @"Yes" : @"No";
    [disableThemeMusicMenuItem setRightText:disableThemeMusic];
	[_items addObject:disableThemeMusicMenuItem];
    
    
    // =========== list ===========
	// =========== "skip filtering options" menu ===========
	SMFMenuItem *skipFilteringOptionsMenuItem = [SMFMenuItem menuItem];
	
	[skipFilteringOptionsMenuItem setTitle:@"Skip filtering menu"];
	NSString *skipFilteringOptions = [[HWUserDefaults preferences] boolForKey:PreferencesViewEnableSkipFilteringOptionsMenu] ? @"Yes" : @"No";
    [skipFilteringOptionsMenuItem setRightText:skipFilteringOptions];
	[_items addObject:skipFilteringOptionsMenuItem];
	
	
	// =========== disable poster zooming in list view ===========
	SMFMenuItem *disablePosterZoomMenuItem = [SMFMenuItem menuItem];
	
	[disablePosterZoomMenuItem setTitle:@"Disable poster zoom"];
	NSString *disablePosterZoom = [[HWUserDefaults preferences] boolForKey:PreferencesViewDisablePosterZoomingInListView] ? @"Yes" : @"No";
    [disablePosterZoomMenuItem setRightText:disablePosterZoom];
	[_items addObject:disablePosterZoomMenuItem];
    
    
    // =========== detailed metadata ===========
    // =========== disable fanart in detailed metadata view ===========
	SMFMenuItem *disableFanartInMetadataScreenMenuItem = [SMFMenuItem menuItem];
	
	[disableFanartInMetadataScreenMenuItem setTitle:@"Disable fanart"];
	NSString *disableFanartInMetadataScreen = [[HWUserDefaults preferences] boolForKey:PreferencesViewDisableFanartInDetailedMetadataView] ? @"Yes" : @"No";
    [disableFanartInMetadataScreenMenuItem setRightText:disableFanartInMetadataScreen];
	[_items addObject:disableFanartInMetadataScreenMenuItem];
}


#pragma mark -
#pragma mark List Delegate Methods
- (void)itemSelected:(long)selected {
	switch (selected) {
        case ViewTypeSettingIndex: {
            NSString *viewTypeSetting = [[HWUserDefaults preferences] objectForKey:PreferencesViewTypeSetting];
            
            if ([viewTypeSetting isEqualToString:@"List"]) {
                [[HWUserDefaults preferences] setObject:@"Grid" forKey:PreferencesViewTypeSetting];
            } else {
                [[HWUserDefaults preferences] setObject:@"List" forKey:PreferencesViewTypeSetting];
            }
            
            
            [self setupList];
            [self.list reload];      
            break;
        }
		case DisableThemeMusicIndex: {
			BOOL isTurnedOn = [[HWUserDefaults preferences] boolForKey:PreferencesViewDisableThemeMusic];
			[[HWUserDefaults preferences] setBool:!isTurnedOn forKey:PreferencesViewDisableThemeMusic];			
			[self setupList];
			[self.list reload];
			break;
        }
		case EnableSkipFilteringOptionsMenuIndex: {
			BOOL isTurnedOn = [[HWUserDefaults preferences] boolForKey:PreferencesViewEnableSkipFilteringOptionsMenu];
			[[HWUserDefaults preferences] setBool:!isTurnedOn forKey:PreferencesViewEnableSkipFilteringOptionsMenu];			
			[self setupList];
			[self.list reload];
			break;
		}
		case DisablePosterZoomingInListViewIndex: {
			BOOL isTurnedOn = [[HWUserDefaults preferences] boolForKey:PreferencesViewDisablePosterZoomingInListView];
			[[HWUserDefaults preferences] setBool:!isTurnedOn forKey:PreferencesViewDisablePosterZoomingInListView];			
			[self setupList];
			[self.list reload];
			break;
        }
		case DisableFanartInDetailedMetadataViewIndex: {
			BOOL isTurnedOn = [[HWUserDefaults preferences] boolForKey:PreferencesViewDisableFanartInDetailedMetadataView];
			[[HWUserDefaults preferences] setBool:!isTurnedOn forKey:PreferencesViewDisableFanartInDetailedMetadataView];			
			[self setupList];
			[self.list reload];
			break;
		}
		default:
			break;
	}
}


-(id)previewControlForItem:(long)item
{
	SMFBaseAsset *asset = [[SMFBaseAsset alloc] init];
	switch (item) {
        case ViewTypeSettingIndex: {
            [asset setTitle:@"Select the video listing view type"];
            [asset setSummary:@"Sets the type of view for videos, choose between list view or grid view ie. cover art view."];
            break;
        }
		case DisableThemeMusicIndex: {
			[asset setTitle:@"Toggles whether theme music plays"];
			[asset setSummary:@"Enables/Disables the playback of theme music upon entering a section that has theme music available"];
			break;
		}
		case EnableSkipFilteringOptionsMenuIndex: {
			[asset setTitle:@"Toggles whether to skip the menu"];
			[asset setSummary:@"Enables/Disables the skipping of the menus with 'all', 'unwatched', 'newest', etc. (currently experimental)"];
			break;
		}
		case DisablePosterZoomingInListViewIndex: {
			[asset setTitle:@"Toggles whether to zoom the poster"];
			[asset setSummary:@"Enables/Disables the image starting out full screen and animating to show the metadata"];
			break;
		}
		case DisableFanartInDetailedMetadataViewIndex: {
			[asset setTitle:@"Toggles whether to zoom the poster"];
			[asset setSummary:@"Enables/Disables the image starting out full screen and animating to show the metadata"];
			break;
		}
		default:
			break;
	}
	[asset setCoverArt:[BRImage imageWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"PlexSettings" ofType:@"png"]]];
	SMFMediaPreview *p = [[SMFMediaPreview alloc] init];
	[p setShowsMetadataImmediately:YES];
	[p setAsset:asset];
	[asset release];
	return [p autorelease];  
}


@end
