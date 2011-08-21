//
//  PlexMediaShelfView.m
//  plex
//
//  Created by Tobias Hieta on 8/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PlexMediaShelfView.h"

@implementation PlexMediaShelfView
@synthesize adapter;

- (id)init {
    
    if ([SMF_COMPAT usingFourPointFourPlus]) {
        self = [super init];        
    } else {
        self = [[NSClassFromString(@"BRMediaShelfControl") alloc] init];
    }
    if (self) {
    }
    return self;
}

- (id)provider
{
    return nil;
}

- (void)dealloc {
    [self.adapter release];
    [super dealloc];
}

- (void)setProvider:(id)provider
{
    if ([SMF_COMPAT usingFourPointFourPlus]) {
        DLog(@"Using 4.4 provider settings!");
        BRProviderDataSourceAdapter *_adapter = [[NSClassFromString(@"BRProviderDataSourceAdapter") alloc] init];
        [_adapter setProviders:[NSArray arrayWithObjects:provider, nil]];
        [self setDelegate:_adapter];
        [self setDataSource:_adapter];
        self.adapter = adapter;
    } else {
        [(id)self setProvider:provider];
    }    
}

- (id)focusedIndexCompat
{
    if ([SMF_COMPAT usingFourPointFourPlus]) {
        return [self focusedIndexPath];
    } else {
        return [(id)self focusedIndex];
    }
}

- (void)setFocusedIndexCompat:(id)focusedIndexCompat
{
    if ([SMF_COMPAT usingFourPointFourPlus]) {
        self.focusedIndexPath = focusedIndexCompat;
    } else {
        [(id)self setFocusedIndex:focusedIndexCompat];
    }
}

@end
