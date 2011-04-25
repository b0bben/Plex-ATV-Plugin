//
//  HWUserDefaults.m
//  atvTwo
//
//  Created by ccjensen on 24/01/2011.
//

#import "HWUserDefaults.h"
#import <plex-oss/PlexClientCapabilities.h>
#import "Constants.h"


@implementation HWUserDefaults
#pragma mark -
#pragma mark PlexPrefs Methods
- (void)setObject:(id)obj forKey:(NSString*)key {
	[[HWUserDefaults preferences] setObject:obj forKey:key];
}

- (id)objectForKey:(NSString*)key {
	return [[HWUserDefaults preferences] objectForKey:key];
}

- (void)setInteger:(NSInteger)v forKey:(NSString*)key {
	[[HWUserDefaults preferences] setInteger:v forKey:key];
}

- (NSInteger)integerForKey:(NSString*)key {
	return [[HWUserDefaults preferences] integerForKey:key];
}

- (void)syncSettings {
	[[HWUserDefaults preferences] synchronize];
}

- (void)_setDefaults {}

+ (void)setupPlexClientCapabilities {
  DLog(@"setting up client caps");
  
  BOOL wantsAC3 = [[HWUserDefaults preferences] boolForKey:PreferencesAudioEnableAC3];
  BOOL wantsDTS = [[HWUserDefaults preferences] boolForKey:PreferencesAudioEnableDTS];  
  
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
  
  [[PlexClientCapabilities sharedPlexClientCapabilities] supports:CLIENT_CAP_HTTP_LIVE_STREAMING];
  [[PlexClientCapabilities sharedPlexClientCapabilities] supports:CLIENT_CAP_720p_PLAYBACK];
  [[PlexClientCapabilities sharedPlexClientCapabilities] supports:CLIENT_CAP_HTTP_MP4_STREAMING];
  [[PlexClientCapabilities sharedPlexClientCapabilities] supports:CLIENT_CAP_DECODER_CAPS];
  
}

#pragma mark -
#pragma mark User Defaults Methods

+ (SMFPreferences *)preferences {
	static SMFPreferences *_preferences = nil;
    if(!_preferences) {
		//setup user preferences
        _preferences = [[SMFPreferences alloc] initWithPersistentDomainName:PreferencesDomain];		
		[_preferences registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
										[NSArray array], PreferencesMachinesExcludedFromServerList,
										@"Good", PreferencesQualitySetting,
										@"Grid", PreferencesViewTypeSetting,
										NO, PreferencesViewEnableSkipFilteringOptionsMenu,
										NO, PreferencesViewDisablePosterZoomingInListView,
                                        NO, PreferencesAudioEnableAC3,
                                        NO, PreferencesAudioEnableDTS,
                                        0, PreferencesSecurityPasscode,
                                        NO, PreferencesSettingsEnableLock,
										nil]];
    }
    return _preferences;
}
@end
