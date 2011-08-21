//
//  PlexMediaShelfView.m
//  plex
//
//  Created by Tobias Hieta on 8/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PlexMediaShelfView.h"

@implementation PlexMediaShelfView
@synthesize controller;

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

- (void)setProvider:(id)provider
{
    if ([SMF_COMPAT usingFourPointFourPlus]) {
        BRProviderDataSourceAdapter *adapter = [[NSClassFromString(@"BRProviderDataSourceAdapter") alloc] init];
        [adapter setProviders:[NSArray arrayWithObjects:provider, nil]];
        [self setDelegate:adapter];
        [self setDataSource:adapter];
        [adapter release];
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
