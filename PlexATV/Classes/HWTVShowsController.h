//
//  HWTVShowsController.h
//  plex
//
//  Created by ccjensen on 26/02/2011.
//

#import <Foundation/Foundation.h>
#import "Plex_SMFBookcaseController.h"
#import "PlexMediaShelfView.h"

@class PlexMediaContainer, PlexMediaObject;
@interface HWTVShowsController : Plex_SMFBookcaseController <Plex_SMFBookcaseControllerDatasource, Plex_SMFBookcaseControllerDelegate> {
	PlexMediaContainer *tvShows;
	NSMutableArray *allTvShowsSeasonsPlexMediaContainer;
    
    BOOL allShelvesLoaded;
    BOOL shouldPlayInitialThemeSong;
}
@property (nonatomic, retain) PlexMediaContainer *seasonsForSelectedTVShow;
@property (nonatomic, retain) NSTimer *themeMusicTimer;

- (id)initWithPlexAllTVShows:(PlexMediaContainer *)allTVShows;

- (void)playThemeMusicForMediaObjectInTimer:(NSTimer *)theTimer;

@end
