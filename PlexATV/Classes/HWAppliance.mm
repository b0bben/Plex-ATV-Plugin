#define LOCAL_DEBUG_ENABLED 0

#import "HWAppliance.h"
#import <Foundation/Foundation.h>
#import <plex-oss/PlexRequest + Security.h>
#import <plex-oss/MachineManager.h>
#import "HWUserDefaults.h"
#import "Constants.h"
#import "PlexNavigationController.h"
#import "PlexTopShelfController.h"

#define SERVER_LIST_ID @"hwServerList"
#define SETTINGS_ID @"hwSettings"
#define SERVER_LIST_CAT [BRApplianceCategory categoryWithName:NSLocalizedString(@"Server List", @"Server List") identifier:SERVER_LIST_ID preferredOrder:98]
#define SETTINGS_CAT [BRApplianceCategory categoryWithName:NSLocalizedString(@"Settings", @"Settings") identifier:SETTINGS_ID preferredOrder:99]

//dictionary keys
NSString * const CategoryPathKey = @"PlexAppliancePath";
NSString * const CategoryNameKey = @"PlexApplianceName";
NSString * const MachineIDKey = @"PlexMachineID";
NSString * const MachineNameKey = @"PlexMachineName";

@interface UIDevice (ATV)
+(void)preloadCurrentForMacros;
@end


@implementation PlexAppliance
@synthesize topShelfController, currentApplianceCategories, otherServersApplianceCategory, settingsApplianceCategory;

NSString * const CompoundIdentifierDelimiter = @"|||";

+ (void)initialize {
    [PlexPrefs setBaseClassForPlexPrefs:[HWUserDefaults class]];
}


- (id)init {
    self = [super init];
	if(self) {
		[UIDevice preloadCurrentForMacros];
		//#warning Please check elan.plexapp.com/2010/12/24/happy-holidays-from-plex/?utm_source=feedburner&utm_medium=feed&utm_campaign=Feed%3A+osxbmc+%28Plex%29 to get a set of transcoder keys
		[PlexRequest setStreamingKey:@"k3U6GLkZOoNIoSgjDshPErvqMIFdE0xMTx8kgsrhnC0=" forPublicKey:@"KQMIY6GATPC63AIMC4R2"];
		//instrumentObjcMessageSends(YES);
		
        //tell PMS what kind of codecs and media we can play
        [HWUserDefaults setupPlexClient];
		
		DLog(@"==================== plex client starting up - init [%@] ====================", self);
        
		self.topShelfController = [[PlexTopShelfController alloc] init];
		self.currentApplianceCategories = [[NSMutableArray alloc] init];
		
		self.otherServersApplianceCategory = [SERVER_LIST_CAT retain];
		self.settingsApplianceCategory = [SETTINGS_CAT retain];
        
        
        [[ProxyMachineDelegate shared] removeAllDelegates];
        [[ProxyMachineDelegate shared] registerDelegate:self];
        if (![[MachineManager sharedMachineManager] autoDetectionActive]) {
            [[MachineManager sharedMachineManager] startAutoDetection];
            [[MachineManager sharedMachineManager] startMonitoringMachineState];
            [[MachineManager sharedMachineManager] setMachineStateMonitorPriority:YES];
        }
        
        [self reloadCategories];
	} 
    return self;
}

- (id)controllerForIdentifier:(id)identifier args:(id)args {
    PlexNavigationController *navigationController = [PlexNavigationController sharedPlexNavigationController];
    
	if ([SERVER_LIST_ID isEqualToString:identifier]) {
		[navigationController navigateToServerList];
        
	} else if ([SETTINGS_ID isEqualToString:identifier]) {
        [navigationController navigateToSettingsWithTopLevelController:self];
		return nil;
        
	} else {
		// ====== get the name of the category and identifier of the machine selected ======
		NSDictionary *compoundIdentifier = (NSDictionary *)identifier;
		
		NSString *categoryName = [compoundIdentifier objectForKey:CategoryNameKey];
        NSString *categoryPath = [compoundIdentifier objectForKey:CategoryPathKey];
		NSString *machineId = [compoundIdentifier objectForKey:MachineIDKey];
		//NSString *machineName = [compoundIdentifier objectForKey:MachineNameKey];
		
		// ====== find the machine using the identifer (uid) ======
		Machine *machineWhoCategoryBelongsTo = [[MachineManager sharedMachineManager] machineForMachineID:machineId];
		if (!machineWhoCategoryBelongsTo) return nil;
		
		// ====== find the category selected ======
        if ([categoryName isEqualToString:@"Refresh"]) {
            self.topShelfController.onDeckMediaContainer = nil;
            self.topShelfController.recentlyAddedMediaContainer = nil;
            [self.topShelfController refresh];
            [self rebuildCategories];
            
        } else if ([categoryName isEqualToString:@"Search"]) {
            [navigationController navigateToSearchForMachine:machineWhoCategoryBelongsTo];
            
        } else if ([categoryName isEqualToString:@"Channels"]) {
                [navigationController navigateToChannelsForMachine:machineWhoCategoryBelongsTo];
            
        } else {
            NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:@"name == %@ AND key == %@", categoryName, categoryPath];
            NSArray *categories = [[machineWhoCategoryBelongsTo.request rootLevel] directories];
            NSArray *matchingCategories = [categories filteredArrayUsingPredicate:categoryPredicate];
            if ([matchingCategories count] != 1) {
                DLog(@"ERROR: incorrect number of category matches to selected appliance with name [%@]", categoryName);
                return nil;
            }
            
            //HAZAA! we found it! 
            PlexMediaObject* matchingCategory = [matchingCategories objectAtIndex:0];
            [navigationController navigateToObjectsContents:matchingCategory];
            return nil;
        }
	}
	return nil;
}

- (id)applianceCategories {
	//sort the array alphabetically
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[self.currentApplianceCategories sortUsingDescriptors:sortDescriptors];
	[sortDescriptor release];
	[sortDescriptors release];
	
	//update the appliance ordering variable so they are listed in alphabetically order in the menu.
	//this is done and saved to the mutuable array, so should be pretty fast as only the recently added
	//items (which are appended to the end of the array) will need to be moved.
	BRApplianceCategory *appliance;
	for (int i = 0; i<[self.currentApplianceCategories count]; i++) {
		appliance = [self.currentApplianceCategories objectAtIndex:i];
        if ([appliance.name isEqualToString:@"Refresh"]) {
            [appliance setPreferredOrder:0];
        } else if ([appliance.name isEqualToString:@"Search"]) {
            [appliance setPreferredOrder:1];
        } else {
            [appliance setPreferredOrder:i+2]; //+2 so we reserve 0 for refresh and 1 for search
        }
	}
	//other servers appliance category, set it to the second to last
	[self.otherServersApplianceCategory setPreferredOrder:[self.currentApplianceCategories count]];
	//settings appliance category, set it to the end of the list
	[self.settingsApplianceCategory setPreferredOrder:[self.currentApplianceCategories count]+1];
	
	//we need to add in the "special appliances"
	NSMutableArray *allApplianceCategories = [NSMutableArray arrayWithArray:self.currentApplianceCategories];
	[allApplianceCategories addObject:otherServersApplianceCategory];
	[allApplianceCategories addObject:settingsApplianceCategory];
	return allApplianceCategories;
}

- (id)identifierForContentAlias:(id)contentAlias { return @"Plex"; }
- (id)selectCategoryWithIdentifier:(id)ident { return nil; }
- (BOOL)handleObjectSelection:(id)fp8 userInfo:(id)fp12 { return YES; }
- (id)applianceSpecificControllerForIdentifier:(id)arg1 args:(id)arg2 { return nil; }
- (id)localizedSearchTitle { return @"Plex"; }
- (id)applianceName { return @"Plex"; }
- (id)moduleName { return @"Plex"; }
- (id)applianceKey { return @"Plex"; }
- (void)reloadCategories { [super reloadCategories]; }

- (void)rebuildCategories {
	[self.currentApplianceCategories removeAllObjects];
	
	NSArray *machines = [[MachineManager sharedMachineManager] threadSafeMachines];
	NSArray *machinesExcludedFromServerList = [[HWUserDefaults preferences] objectForKey:PreferencesMachinesExcludedFromServerList];
    
#if LOCAL_DEBUG_ENABLED
    DLog(@"Reloading categories with machines [%@]", machines);
#endif
	for (Machine *machine in machines) {
		NSString *machineID = [machine.machineID copy];
		NSString *machineName = [machine.serverName copy];
		
		//check if the user has added this machine to the exclusion list
		if ([machinesExcludedFromServerList containsObject:machineID]) {
			//machine specifically excluded, skip
#if LOCAL_DEBUG_ENABLED
			DLog(@"Machine [%@] is included in the server exclusion list, skipping", machineID);
#endif
            [machineID release];
            [machineName release];
			continue;
		} else if (!machine.canConnect) {
			//machine is not connectable
#if LOCAL_DEBUG_ENABLED
			DLog(@"Cannot connect to machine [%@], skipping", machine);
#endif
            [machineName release];
            [machineID release];
			continue;
		}

#if LOCAL_DEBUG_ENABLED
        DLog(@"Adding categories for machine [%@]", machine);
#endif
		
		//================== add all it's categories to our appliances list ==================
		//not using machine.request.rootLevel.directories because it might not work,
		//instead get the two arrays seperately and merge
		NSMutableArray *allDirectories = [NSMutableArray arrayWithArray:machine.librarySections.directories];
		//[allDirectories addObjectsFromArray:machine.rootLevel.directories];
		
		//for (PlexMediaObject *pmo in allDirectories) {
        int totalItems = [allDirectories count] + 3; //refresh + search + channels
        for (int i=0; i<totalItems; i++) {
            NSString *categoryPath = nil;
            NSString *categoryName = nil;

            if (i == [allDirectories count]) {
                //add special search appliance
                categoryName = @"Refresh";
                categoryPath = @"refresh";
            } else if (i == [allDirectories count]+1) {
                //add special search appliance
                categoryName = @"Search";
                categoryPath = @"search";
            } else if (i == [allDirectories count]+2) {
                //add special channels appliance
                categoryName = @"Channels";
                categoryPath = @"channels";
            } else {
                //add all others
                PlexMediaObject *pmo = [allDirectories objectAtIndex:i];
                categoryName = [pmo.name copy];
                categoryPath = [pmo.key copy];
                
                //TODO: should check for most recently selected category name
                if ([categoryName isEqualToString:@"TV"]) {
                    [self.topShelfController setContentToContainer:[pmo contents]];
                    [self.topShelfController refresh];
                }
            }
            
#if LOCAL_DEBUG_ENABLED
            DLog(@"Adding category [%@] for machine id [%@]", categoryName, machineID);
#endif
            
            //create the compoundIdentifier for the appliance identifier
            NSMutableDictionary *compoundIdentifier = [NSMutableDictionary dictionary];
            [compoundIdentifier setObject:categoryName forKey:CategoryNameKey];
            [compoundIdentifier setObject:machineID forKey:MachineIDKey];
            [compoundIdentifier setObject:machineName forKey:MachineNameKey];
            [compoundIdentifier setObject:categoryPath forKey:CategoryPathKey];
			
			//================== add the appliance ==================
			
			//the appliance order will be the highest number (ie it will be put at the end of the menu.
			//this will be readjusted when the array is sorted in the (id)applianceCategories
			float applianceOrder = [self.currentApplianceCategories count];
			
			BRApplianceCategory *appliance = [BRApplianceCategory categoryWithName:categoryName identifier:compoundIdentifier preferredOrder:applianceOrder];
			[self.currentApplianceCategories addObject:appliance];
			
			// find any duplicate names of the one currently being added.
			// if found, append machine name to them all
			NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:@"name == %@", categoryName];
			NSArray *duplicateNameCategories = [self.currentApplianceCategories filteredArrayUsingPredicate:categoryPredicate];
			if ([duplicateNameCategories count] > 1) {
				//================== found duplicate category names ==================
#if LOCAL_DEBUG_ENABLED
				DLog(@"Found [%d] duplicate categories with name [%@]", [duplicateNameCategories count], categoryName);
#endif
				//iterate over all of them updating their names
				for (BRApplianceCategory *appl in duplicateNameCategories) {			
					
					NSDictionary *compoundIdentifierBelongingToDuplicateAppliance = (NSDictionary *)appl.identifier;
					NSString *nameOfMachineThatCategoryBelongsTo = [compoundIdentifierBelongingToDuplicateAppliance objectForKey:MachineNameKey];
					if (!nameOfMachineThatCategoryBelongsTo) break;
					
					// update the name
					// name had format:       "Movies"
					// now changing it to be: "Movies (Office)"
					NSString *nameWithPms = [[NSString alloc] initWithFormat:@"%@ (%@)", categoryName, nameOfMachineThatCategoryBelongsTo];
					[appl setName:nameWithPms];
					[nameWithPms release];
				}
			}
			[categoryName release];
            [categoryPath release];
		}
		
		[machineID release];
		[machineName release];
	}
}

#pragma mark -
#pragma mark Machine Delegate Methods
-(void)machineWasRemoved:(Machine*)m{
#if LOCAL_DEBUG_ENABLED
	DLog(@"MachineManager: Removed machine [%@], so reload", m);
#endif
    [self rebuildCategories];
}

-(void)machineWasAdded:(Machine*)m {   
#if LOCAL_DEBUG_ENABLED
	DLog(@"MachineManager: Added machine [%@]", m);
#endif
	BOOL machineIsOnlineAndConnectable = m.isComplete;
	
	if (machineIsOnlineAndConnectable) {
#if LOCAL_DEBUG_ENABLED
        DLog(@"MachineManager: Reload machines as machine [%@] was added", m);
#endif
		[self rebuildCategories];
	}
}

- (void)machineWasChanged:(Machine *)m {
    if (m.isOnline && m.canConnect) {
        //machine is available
    } else {
        //machine is not available
    }
}

-(void)machine:(Machine *)m updatedInfo:(ConnectionInfoType)updateMask {
#if LOCAL_DEBUG_ENABLED
	DLog(@"MachineManager: Updated Info with update mask [%d] from machine [%@]", updateMask, m);
#endif
	BOOL machinesLibrarySectionsWasUpdated = (updateMask & ConnectionInfoTypeLibrarySections) != 0;
	BOOL machinesRecentlyAddedWasUpdated = (updateMask & ConnectionInfoTypeRecentlyAddedMedia) != 0;
	BOOL machineHasEitherGoneOnlineOrOffline = (updateMask & ConnectionInfoTypeCanConnect) != 0;
	
	if ( machinesLibrarySectionsWasUpdated || machineHasEitherGoneOnlineOrOffline ) {
#if LOCAL_DEBUG_ENABLED
        DLog(@"MachineManager: Reload machines as machine [%@] list was updated [%@] or came online/offline [%@]", m, machinesLibrarySectionsWasUpdated ? @"YES" : @"NO", machineHasEitherGoneOnlineOrOffline ? @"YES" : @"NO");
#endif
		[self rebuildCategories];
	} 
	
	if (machinesRecentlyAddedWasUpdated) {
#if LOCAL_DEBUG_ENABLED
        DLog(@"MachineManager: Machine [%@] recentlyAdded was updated", m);
#endif
	}
}
@end
