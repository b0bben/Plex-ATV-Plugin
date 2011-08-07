//
//  PlexMediaObject+Assets.m
//  plex
//
//  Created by ccjensen on 03/05/2011.
//

#import "PlexMediaObject+Assets.h"
#import "PlexBaseMetadataAsset.h"
#import "PlexTVEpisodeMetadataAsset.h"
#import "PlexMediaAsset.h"
#import "PlexSongAsset.h"
#import "HWUserDefaults.h"
#import "Constants.h"

@implementation PlexMediaObject (Assets)


#pragma mark -
#pragma mark Assets
- (PlexBaseMetadataAsset *)previewAsset {
    PlexBaseMetadataAsset *asset = nil;
    NSString *plexMediaType = [self.attributes valueForKey:@"type"];
    
    if ([PlexMediaObjectTypeEpisode isEqualToString:plexMediaType]) {
        //tv show episode
        asset = [[PlexTVEpisodeMetadataAsset alloc] initWithURL:nil mediaProvider:nil mediaObject:self];

    } else {
        asset = [[PlexBaseMetadataAsset alloc] initWithURL:nil mediaProvider:nil mediaObject:self];
    }
    
    return [asset autorelease];
}

- (PlexMediaAsset *)mediaAsset {
    return [[[PlexMediaAsset alloc] initWithURL:nil mediaProvider:nil mediaObject:self] autorelease];
}

//- (PlexSongAsset *)songAsset {
//    
//}


#pragma mark -
#pragma mark List Items

- (float)heightForMenuItem {
	float height;
	
	if (self.hasMedia || [@"Video" isEqualToString:self.containerType]) {
		height = 70.0f;
	} else {
		height = 0.0f;
	}
	return height;
}

- (BRMenuItem *)menuItem {
    BRMenuItem *menuItem = nil;
    
	if (self.hasMedia || [@"Video" isEqualToString:self.containerType]) {
		menuItem = [[NSClassFromString(@"BRPlayButtonEnabledMenuItem") alloc] init];
        
		if ([self seenState] == PlexMediaObjectSeenStateUnseen) {
            [menuItem setImage:[[BRThemeInfo sharedTheme] unplayedVideoImage]];
		} else if ([self seenState] == PlexMediaObjectSeenStateInProgress) {
            [menuItem setImage:[[BRThemeInfo sharedTheme] partiallyplayedVideoImage]];
		} else {
            //image will be invisible, but we need it to get the text to line up with ones who have a
            //visible image
			[menuItem setImage:[[BRThemeInfo sharedTheme] partiallyplayedVideoImage]];
            BRImageControl *imageControl = [menuItem valueForKey:@"_imageControl"];
            [imageControl setHidden:YES];
		}
        [menuItem setImageAspectRatio:0.5];
		
        [menuItem setText:[self name] withAttributes:nil];
		
        //used to get details about the show, instead of gettings attrs here manually
        PlexBaseMetadataAsset *previewAsset = [self previewAsset];
        
		if ([self.type isEqualToString:PlexMediaObjectTypeEpisode]) {
            NSString *detailedText = [NSString stringWithFormat:@"Season %d, Episode %d (%@)", [previewAsset season], [previewAsset episode], [previewAsset seriesName]];
			[menuItem setDetailedText:detailedText withAttributes:nil];
            [menuItem setRightJustifiedText:[previewAsset datePublishedString] withAttributes:nil];
		} else {
            NSString *detailedText = previewAsset.year ? previewAsset.year : @" ";
			[menuItem setDetailedText:detailedText withAttributes:nil];
            if ([previewAsset isHD]) {
                [menuItem addAccessoryOfType:11];
            }
		}
        
    } else {
        //not a media item
        menuItem = [[BRMenuItem alloc] init];
		
		if ([self.type isEqualToString:PlexMediaObjectTypeShow] || [self.type isEqualToString:PlexMediaObjectTypeSeason]) {
			if ([self.attributes valueForKey:@"agent"] == nil) {
				if ([self seenState] == PlexMediaObjectSeenStateUnseen) {
					[menuItem addAccessoryOfType:15];
				} else if ([self seenState] == PlexMediaObjectSeenStateInProgress) {
					[menuItem addAccessoryOfType:16];
				}
			}
		}
		
		[menuItem setText:[self name] withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
		
		[menuItem addAccessoryOfType:1];
	}
	return [menuItem autorelease];
}

- (id)previewControl {
    id preview = nil;
    
    preview = [[[SMFMediaPreview alloc] init] autorelease];
//    preview = [[BRMetadataPreviewControl alloc] init];
    [preview setShowsMetadataImmediately:![[HWUserDefaults preferences] boolForKey:PreferencesViewListPosterZoomingEnabled]];
    [preview setAsset:self.previewAsset];
    
    return preview;
}

@end
