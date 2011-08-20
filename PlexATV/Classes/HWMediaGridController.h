//
//  HWMediaShelfController.h
//  atvTwo
//
//  Created by bob on 2011-01-29.
//  Copyright 2011 Band's gonna make it!. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Backrow/BRMediaShelfControl.h"
#import "PlexMediaShelfView.h"

@class PlexMediaContainer;

@interface HWMediaGridController : BRController {
    BRGridControl*          _gridControl;
    PlexMediaShelfView *    _shelfControl;
    BRWaitSpinnerControl *  _spinner;
    BRCursorControl *       _cursorControl;
    BRScrollControl *       _scroller;
    BRPanelControl *        _panelControl;
}

@property (retain) PlexMediaContainer *shelfMediaContainer;
@property (retain) PlexMediaContainer *gridMediaContainer;
@property (retain) NSArray *shelfMediaObjects;
@property (retain) NSArray *gridMediaObjects;

-(void)drawSelf;
- (id)getProviderForGrid;
-(id)getProviderForShelf;
//our own stuff
- (id)initWithPlexAllMovies:(PlexMediaContainer *)allMovies andRecentMovies:(PlexMediaContainer *)recentMovies;

@end
