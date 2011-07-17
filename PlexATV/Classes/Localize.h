//
//  Localize.h
//  plex
//
//  Created by Björn Skoglund on 2011-07-17.
//

#define localize(key) \
[[NSBundle bundleWithIdentifier:@"com.apple.frontrow.appliance.plex"] localizedStringForKey:(key) value:@"" table:nil]