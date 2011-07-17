//
//  HWSettingsController.m
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

#import "HWSettingsController.h"
#import "HWServersController.h"
#import "PlexViewSettingsController.h"
#import "PlexPlaybackSettingsController.h"
#import "PlexSecuritySettingsController.h"
#import "HWUserDefaults.h"
#import "Constants.h"
#import "Localize.h"

@implementation HWSettingsController
@synthesize topLevelController;

#define PlexPluginVersion @"0.0.9.0.1"

#define ServersIndex                0
#define ViewSettingsIndex           1
#define PlaybackSettingsIndex       2
#define SecuritySettingsIndex       3
#define PluginVersionNumberIndex    4


#pragma mark -
#pragma mark Object/Class Lifecycle
- (id) init {
	if((self = [super init]) != nil) {
		topLevelController = nil;
		[self setLabel:@"Plex Settings"];
		[self setListTitle:@"Plex Settings"];
		
		[self setupList];
	}	
	return self;
}

- (void)dealloc {
	[super dealloc];	
}

- (NSString *)description {
    return localize(@"settingsHeader");
}

#pragma mark -
#pragma mark Controller Lifecycle behaviour
- (void)wasPushed {
	[[MachineManager sharedMachineManager] setMachineStateMonitorPriority:NO];
	[super wasPushed];
}

- (void)wasPopped {
	[[MachineManager sharedMachineManager] setMachineStateMonitorPriority:YES];
	[topLevelController reloadCategories];
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
	
	// =========== servers ===========
	SMFMenuItem *serversMenuItem = [SMFMenuItem folderMenuItem];
	[serversMenuItem setTitle:localize(@"settingsManageServers")];
	[_items addObject:serversMenuItem];    
	
    // =========== view settings ===========
	SMFMenuItem *viewSettingsMenuItem = [SMFMenuItem folderMenuItem];
	[viewSettingsMenuItem setTitle:localize(@"settingsView")];
	[_items addObject:viewSettingsMenuItem];
    
    
    // =========== playback settings ===========
	SMFMenuItem *playbackSettingsMenuItem = [SMFMenuItem folderMenuItem];
	[playbackSettingsMenuItem setTitle:localize(@"settingsPlayback")];
	[_items addObject:playbackSettingsMenuItem];
    
    
    // =========== security settings ===========
	SMFMenuItem *securitySettingsMenuItem = [SMFMenuItem folderMenuItem];
	[securitySettingsMenuItem setTitle:localize(@"settingsSecurity")];
	[_items addObject:securitySettingsMenuItem];
	
    
	// =========== version number ===========
	SMFMenuItem *pluginVersionNumberMenuItem = [SMFMenuItem menuItem];
	
	[pluginVersionNumberMenuItem setTitle:localize(@"settingsVersion")];
	[pluginVersionNumberMenuItem setRightText:PlexPluginVersion];
    [_items addObject:pluginVersionNumberMenuItem];
	
    
	//this code can be used to find all the accessory types
//    	for (int i = 0; i<32; i++) {
//    		BRMenuItem *tempSettingMenuItem = [[BRMenuItem alloc] init];
//    		[tempSettingMenuItem addAccessoryOfType:i];
//    		
//    		NSString *tempSettingTitle = [[NSString alloc] initWithFormat:@"temp %d", i];
//    		[tempSettingMenuItem setText:tempSettingTitle withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
//    		[tempSettingTitle release];
//    		[_items addObject:tempSettingMenuItem];
//    	}
}

#pragma mark -
#pragma mark List Delegate Methods
- (void)itemSelected:(long)selected {
	switch (selected) {
		case ServersIndex: {
			HWServersController* menuController = [[HWServersController alloc] init];
			[[[BRApplicationStackManager singleton] stack] pushController:menuController];
			[menuController autorelease];
			break;
		}
		case ViewSettingsIndex: {
			PlexViewSettingsController* menuController = [[PlexViewSettingsController alloc] init];
			[[[BRApplicationStackManager singleton] stack] pushController:menuController];
			[menuController release];
			break;
		}
        case PlaybackSettingsIndex: {
			PlexPlaybackSettingsController* menuController = [[PlexPlaybackSettingsController alloc] init];
			[[[BRApplicationStackManager singleton] stack] pushController:menuController];
			[menuController release];
			break;
        }
        case SecuritySettingsIndex: {
			PlexSecuritySettingsController* menuController = [[PlexSecuritySettingsController alloc] init];
			[[[BRApplicationStackManager singleton] stack] pushController:menuController];
			[menuController release];
			break;
        }
		case PluginVersionNumberIndex: {
			//do nothing
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
		case ServersIndex: {
			// =========== servers ===========
			[asset setTitle:@"Manage server list"];
			[asset setSummary:@"Add new or modify current servers, their connections and their 'inclusion in main menu' status"];
			break;
		}
		case ViewSettingsIndex: {
			// =========== view settings ===========
			[asset setTitle:@"Modify view settings"];
			[asset setSummary:@"Alter UI behavior, views to use, etc."];
			break;
		}
		case PlaybackSettingsIndex: {
			// =========== audio settings ===========
			[asset setTitle:@"Modify playback settings"];
			[asset setSummary:@"Setup the kind of multi-channel audio you want to output, video quality, etc"];
			break;
		}
		case SecuritySettingsIndex: {
			// =========== security settings ===========
			[asset setTitle:@"Modify security settings"];
			[asset setSummary:@"Change passcode and activate security measures"];
			break;
		}
		case PluginVersionNumberIndex: {
			// =========== quality setting ===========
			[asset setTitle:@"Credit to:"];
			[asset setSummary:@"quequick, b0bben and ccjensen"];
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
