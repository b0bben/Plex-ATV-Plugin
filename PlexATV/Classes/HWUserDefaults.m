//
//  HWUserDefaults.m
//  atvTwo
//
//  Created by ccjensen on 24/01/2011.
//

#import "HWUserDefaults.h"
#import <plex-oss/PlexClientCapabilities.h>
#import <plex-oss/PlexStreamingQuality.h>
#import <plex-oss/PlexRequest + Security.h>
#import "Constants.h"


@implementation HWUserDefaults
#pragma mark -
#pragma mark PlexPrefs Methods
-(void)removeValueForKey:(NSString *)key {
	[[HWUserDefaults preferences] removeObjectForKey:key];
}


- (id)objectForKey:(NSString*)key {
	return [[HWUserDefaults preferences] objectForKey:key];
}

- (void)setObject:(id)obj forKey:(NSString*)key {
	[[HWUserDefaults preferences] setObject:obj forKey:key];
}


- (NSInteger)integerForKey:(NSString*)key {
	return [[HWUserDefaults preferences] integerForKey:key];
}

- (void)setInteger:(NSInteger)v forKey:(NSString*)key {
	[[HWUserDefaults preferences] setInteger:v forKey:key];
}


-(BOOL)boolForKey:(NSString *)key {
    return [[HWUserDefaults preferences] boolForKey:key];
}

-(void)setBool:(BOOL)value forKey:(NSString *)key {
    [[HWUserDefaults preferences] setBool:value forKey:key];
}


-(double)doubleForKey:(NSString *)key {
    return [[HWUserDefaults preferences] doubleForKey:key];
}

-(void)setDouble:(double)value forKey:(NSString *)key {
    [[HWUserDefaults preferences] setDouble:value forKey:key];
}


-(float)floatForKey:(NSString *)key {
    return [[HWUserDefaults preferences] floatForKey:key];
}

-(void)setFloat:(float)value forKey:(NSString *)key {
    [[HWUserDefaults preferences] setFloat:value forKey:key];
}


#pragma mark -
#pragma mark User Defaults Methods

+ (NSInteger)lastTabBarSelectionForViewGroup:(NSString *)viewGroup {
    NSInteger lastTabBarSelection = 0;
    NSDictionary *selections = [[[self class] preferences] objectForKey:PersistedTabBarLastSelections];
    if ([selections valueForKey:viewGroup] != nil) {
        lastTabBarSelection = [[selections objectForKey:viewGroup] intValue];
    }
    return lastTabBarSelection;
}

+ (void)setLastTabBarSelection:(NSInteger)selectedIndex forViewGroup:(NSString *)viewGroup {
    NSDictionary *oldSelections = [[[self class] preferences] objectForKey:PersistedTabBarLastSelections];
    NSMutableDictionary *selections = [NSMutableDictionary dictionaryWithDictionary:oldSelections];
    
    [selections setObject:[NSNumber numberWithInteger:selectedIndex] forKey:viewGroup];
    [[[self class] preferences] setObject:selections forKey:PersistedTabBarLastSelections];
}

- (void)syncSettings {
	[[HWUserDefaults preferences] synchronize];
}

- (void)_setDefaults {}


+ (void)setupPlexClient {
    DLog(@"registering ourselves with the PMS");
    [PlexRequest setApplicationName:@"Plex-ATV" version:@"0.8RC1"];
    
    //tell pms we like direct-stream and we will be sending caps to it
    [[PlexPrefs defaultPreferences] setAllowDirectStreaming:YES];

    DLog(@"direct-streaming: %@",[[PlexPrefs defaultPreferences] allowDirectStreaming] ? @"YES" : @"NO");
    
    DLog(@"setting up client caps");  
    BOOL wantsAC3 = [[HWUserDefaults preferences] boolForKey:PreferencesPlaybackAudioAC3Enabled];
    BOOL wantsDTS = [[HWUserDefaults preferences] boolForKey:PreferencesPlaybackAudioDTSEnabled];  
    
    //reset everything, we'll redo all that we need below
    [[PlexClientCapabilities sharedPlexClientCapabilities] resetCaps];
    
    if (wantsAC3) {
        DLog(@"wants AC3");
        [[PlexClientCapabilities sharedPlexClientCapabilities] setAudioDecoderForCodec:PlexClientDecoderName_AC3 bitrate:PlexClientBitrateAny channels:PlexClientAudioChannels_7_1Surround];
    } else {
        DLog(@"don't want AC3");
        [[PlexClientCapabilities sharedPlexClientCapabilities] removeAudioCodec:PlexClientDecoderName_AC3];
    }
    
    if (wantsDTS) {
        DLog(@"wants DTS");
        [[PlexClientCapabilities sharedPlexClientCapabilities] setAudioDecoderForCodec:PlexClientDecoderName_DTS bitrate:PlexClientBitrateAny channels:PlexClientAudioChannels_7_1Surround];
    } else {
        DLog(@"don't want DTS");
        [[PlexClientCapabilities sharedPlexClientCapabilities] removeAudioCodec:PlexClientDecoderName_DTS];
    }
    
    [[PlexClientCapabilities sharedPlexClientCapabilities] setAudioDecoderForCodec:PlexClientDecoderName_AAC bitrate:PlexClientBitrateAny channels:PlexClientAudioChannels_5_1Surround];
    
    
    [[PlexClientCapabilities sharedPlexClientCapabilities] resetCaps];
    /*
    NSArray *machines = [[MachineManager sharedMachineManager] threadSafeMachines];
    for (Machine *m in machines) {
        DLog(@"machine caps %@", [[PlexClientCapabilities sharedPlexClientCapabilities] capStringForMachine:m]);
    }
    */
}

+ (NSArray *)plexStreamingQualities {
    return [NSArray arrayWithObjects:
            [PlexStreamingQualityDescriptor quality3GLow], 
            [PlexStreamingQualityDescriptor quality3GMed], 
            [PlexStreamingQualityDescriptor quality3GHigh], 
            [PlexStreamingQualityDescriptor qualityWiFiLow], 
            [PlexStreamingQualityDescriptor qualityWiFiMed], 
            [PlexStreamingQualityDescriptor qualityiPhoneWiFi], 
            [PlexStreamingQualityDescriptor qualityiPadWiFi], 
            [PlexStreamingQualityDescriptor quality720pLow], 
            [PlexStreamingQualityDescriptor quality720pHigh], 
            [PlexStreamingQualityDescriptor quality1080pLow], 
            [PlexStreamingQualityDescriptor quality1080pMed], 
            [PlexStreamingQualityDescriptor quality1080pHigh], 
            nil];
}

+ (NSDictionary *)defaultValues {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSArray array], PreferencesMachinesExcludedFromServerList,
            [NSNumber numberWithInt:0], PreferencesViewTypeForMovies,
            [NSNumber numberWithInt:0], PreferencesViewTypeForTvShows,
            [NSNumber numberWithBool:YES], PreferencesViewThemeMusicEnabled,
            [NSNumber numberWithBool:NO], PreferencesViewThemeMusicLoopEnabled,
            [NSNumber numberWithBool:YES], PreferencesViewPreplayFanartEnabled,
            [NSNumber numberWithBool:YES], PreferencesViewListPosterZoomingEnabled,
            [NSNumber nubmerWithBool:NO], PreferencesViewHiddenSummary,
            [NSNumber numberWithBool:NO], PreferencesPlaybackAudioAC3Enabled,
            [NSNumber numberWithBool:NO], PreferencesPlaybackAudioDTSEnabled,
            [NSNumber numberWithInt:8], PreferencesPlaybackVideoQualityProfile,
            [NSNumber numberWithBool:NO], PreferencesSecuritySettingsLockEnabled,
            [NSNumber numberWithInt:0], PreferencesSecurityPasscode,
            [NSDictionary dictionary], PersistedTabBarLastSelections,
            nil];
}

+ (SMFPreferences *)preferences {
	static SMFPreferences *_preferences = nil;
    if(!_preferences) {
		//setup user preferences
        _preferences = [[SMFPreferences alloc] initWithPersistentDomainName:PreferencesDomain];		
		[_preferences registerDefaults:[HWUserDefaults defaultValues]];
        
    }
    return _preferences;
}
@end
