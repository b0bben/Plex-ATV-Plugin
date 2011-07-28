
#define PreferencesDomain @"com.plex.client-plugin"


#define PreferencesMachinesExcludedFromServerList @"PreferencesMachinesExcludedFromServerList"

#define PreferencesViewTypeForTvShows @"PreferencesViewTypeForTvShows"
#define PreferencesViewTypeForMovies @"PreferencesViewTypeForMovies"

#define PreferencesViewThemeMusicEnabled @"PreferencesViewThemeMusicEnabled"
#define PreferencesViewThemeMusicLoopEnabled @"PreferencesViewThemeMusicLoopEnabled"
#define PreferencesViewListPosterZoomingEnabled @"PreferencesViewListPosterZoomingEnabled"
#define PreferencesViewPreplayFanartEnabled @"PreferencesViewPreplayFanartEnabled"
#define PreferencesViewHiddenSummary @"PreferencesViewHiddenSummary"

#define PreferencesPlaybackAudioAC3Enabled @"PreferencesPlaybackAudioAC3Enabled"
#define PreferencesPlaybackAudioDTSEnabled @"PreferencesPlaybackAudioDTSEnabled"
#define PreferencesPlaybackVideoQualityProfile @"PreferencesPlaybackVideoQualityProfile"

#define PreferencesSecuritySettingsLockEnabled @"PreferencesSecuritySettingsLockEnabled"
#define PreferencesSecurityPasscode @"PreferencesSecurityPasscode"




#define PersistedTabBarLastSelections @"PersistedTabBarLastSelections"



#define TabBarCurrentItemsIdentifier @"current"
#define TabBarCurrentItemsIndex 0
#define TabBarUnwatchedItemsIdentifier @"unwatched"
#define TabBarUnwatchedItemsIndex 1
#define TabBarOtherFiltersItemsIdentifier @"otherfilters"
#define TabBarOtherFiltersItemsIndex 2


//additional keyboard commands
#define kBREventRemoteActionPlayPause2 16

typedef enum {
	kATVPlexViewTypeList = 0,
	kATVPlexViewTypeGrid,
	kATVPlexViewTypeBookcase,
    FINAL_kATVPlexViewTypeBookcase_MAX
} ATVPlexViewTypes;


typedef enum {
	kATVPlexTabBarLastSelectionAll = 0,
	kATVPlexTabBarLastSelectionUnwatched,
    FINAL_kATVPlexTabBarLastSelection_MAX
} ATVPlexTabBarLastSelection;


typedef enum {
	kBRMediaPlayerStateStopped = 0,
	kBRMediaPlayerStatePaused = 1,
	kBRMediaPlayerStateSkipping = 2,
	kBRMediaPlayerStatePlaying = 3,
	kBRMediaPlayerStateForwardSeeking = 4,  
	kBRMediaPlayerStateForwardSeekingFast = 5,
	kBRMediaPlayerStateForwardSeekingFastest = 6,
	kBRMediaPlayerStateBackSeeking = 7,  
	kBRMediaPlayerStateBackSeekingFast = 8,
	kBRMediaPlayerStateBackSeekingFastest = 9,
} BRMediaPlayerState;



//These keyboard types are for the keyboardType property of an instance of BRDeviceKeyboardMessage
typedef enum {
    //0 same as 1
	kBRDeviceKeyboardTypeFullMainScreen              = 1, //full-keyboard (main screen)
    kBRDeviceKeyboardTypeFullNumberScreen            = 2, //full-keyboard ("123" / number screen)
    kBRDeviceKeyboardTypeInternetFull                = 3, //full internet keyboard (shortcut for ".com", etc)
    kBRDeviceKeyboardTypePasscodeEntry               = 4, //passcode entry keyboard (digit keyboard & four character input only)
    kBRDeviceKeyboardTypePhoneDial                   = 5, //phone dial keyboard (digits, +, *, #, wait, etc.)
    kBRDeviceKeyboardTypeFullMainScreenDisabledShift = 6, //full-keyboard with disabled shift (main screen)
    kBRDeviceKeyboardTypeEmailFull                   = 7, //full email keyboard (shortcut for "@", etc)
    kBRDeviceKeyboardTypeIPAddress                   = 8, //ip address entry (digits + period)
    //9 and above same as 1
} BRDeviceKeyboardType;



//These text entry styles are for the textEntryStyle property of an instance of BRTextEntryControl
typedef enum {
    //0 is none
	kBRTextEntryStyleFull                            = 1, //full keyboard
    kBRTextEntryStyleCompactWithSpaceLowercaseOnly   = 2, //compact keyboard (lowercase, digits, space and symbols). No done button
    kBRTextEntryStyleHex                             = 3, //hex keyboard (1-9, A-F)
    kBRTextEntryStyleInternetFull                    = 4, //full keyboard (with ".com")
    kBRTextEntryStyleInternetCurrencyFullWeird       = 5, //full keyboard (with ".com", currency and weird buttons). No textfield
    kBRTextEntryStyleCompactNoSpace                  = 6, //compact keyboard (lowercase, digits, uppercase and symbols). No done button
    kBRTextEntryStyleNumpad                          = 7, //numpad keyboard (1-9)
    //8 and above is none
} BRTextEntryStyle;