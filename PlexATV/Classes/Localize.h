//
//  Localize.h
//  plex
//
//  Created by Björn Skoglund on 2011-07-17.
//

#define localize(key) [Localizer localizeKey:key]

@interface Localizer : NSObject

+ (NSString *)localizeKey:(NSString*)key;

@end
