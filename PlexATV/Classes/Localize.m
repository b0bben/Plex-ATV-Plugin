//
//  Localize.c
//  plex
//
//  Created by Björn Skoglund on 2011-07-17.
//  Copyright 2011 Atex Polopoly. All rights reserved.
//

#import <objc/runtime.h>
#import "Localize.h"

@implementation Localizer


+ (NSString*)localizeKey:(NSString*)key {
    NSBundle* bundle = [NSBundle bundleWithIdentifier:@"com.apple.frontrow.appliance.plex"];
    NSString* x = [bundle localizedStringForKey:(key) value:@"" table:nil];
    if ([x isEqualToString:key]) {
        NSString *basePath = [bundle bundlePath];
        NSString *englishBundle = [NSString stringWithFormat:@"%@/en.lproj", basePath];
        bundle = [NSBundle bundleWithPath:englishBundle];
        return [bundle localizedStringForKey:(key) value:@"" table:nil];
    }
    return x;
}

@end