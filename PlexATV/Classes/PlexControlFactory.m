//
//  Plex_SMFControlFactory.m
//  plex
//
//  Created by bob on 2011-04-08.
//

#import "PlexControlFactory.h"

@implementation PlexControlFactory
@synthesize _alwaysShowTitles;
@synthesize defaultImage=_defaultImage;

-(id)initForMainMenu:(BOOL)arg1 {
    self = [super initForMainMenu:arg1];
    self.defaultImage = nil;
    self._alwaysShowTitles = NO;
    return self;
}

- (void)dealloc {
    self.defaultImage = nil;
    [super dealloc];
}

- (id)controlForData:(id)arg1 currentControl:(id)arg2 requestedBy:(id)arg3 {
    id returnObj = nil;
    if([arg1 isKindOfClass:[BRPhotoMediaAsset class]]) {
        BRPhotoMediaAsset *mediaAsset = arg1;
        returnObj = [self controlForImageProxy:[mediaAsset imageProxy] title:[mediaAsset title]];
    }
    return returnObj;
}

- (float)heightForControlForData:(id)data requestedBy:(id)by {
    return 206.0f;
}

-(BRControl *)controlForImageProxy:(BRURLImageProxy *)imageProxy title:(NSString *)title {
        BRPosterControl *returnObj = [[BRPosterControl alloc] init];
        returnObj.posterStyle = 1;
        NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:title 
                                                                      attributes:[[BRThemeInfo sharedTheme] menuTitleSubtextAttributes]];
        returnObj.title = attrStr;
        [attrStr release]; /* we have given the reference to the returnObject which defines it as a retained property */
        returnObj.imageProxy=imageProxy;
        returnObj.defaultImage=self.defaultImage;
        returnObj.alwaysShowTitles=self._alwaysShowTitles;
        returnObj.posterBorderWidth=1.0f;
        returnObj.titleWidthScale=1.0f;
        returnObj.titleVerticalOffset=0.0f;
        returnObj.reflectionAmount=0.14000000059604645;
        return [returnObj autorelease];
}

@end
