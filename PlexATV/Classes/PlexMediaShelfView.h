//
//  PlexMediaShelfView.h
//  plex
//
//  Created by Tobias Hieta on 8/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlexMediaShelfView : BRMediaShelfView
{
    id controller;
}

@property (retain) id controller;
@property (retain) id provider;
@property (retain) id focusedIndexCompat;

@end
