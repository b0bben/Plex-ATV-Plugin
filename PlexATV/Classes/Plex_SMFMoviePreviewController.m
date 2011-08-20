//
//  Plex_SMFMoviePreviewController.m
//  plex
//
//  Created by ccjensen on 04/04/2011.
//

#import "Plex_SMFMoviePreviewController.h"
#import "HWUserDefaults.h"
#import "Constants.h"

@implementation Plex_SMFMoviePreviewController

@dynamic datasource, delegate, flags;

-(void)controlWasActivated
{
    DLog();
    //these 2 are called in SMF on controlWasActivated, so don't call them again here...
    //[self reload];
    //[self reloadShelf];
    //[self _removeAllControls];
    [super controlWasActivated];
}


-(BOOL)brEventAction:(BREvent *)action {
    BRControl *c = [self focusedControl];
    if ([[self stack] peekController]!=self)
        return [super brEventAction:action];
    int remoteAction = [action remoteAction];
	if([c isKindOfClass:[SMFListDropShadowControl class]]) {
		return [super brEventAction:action];
	}
	
    if ((remoteAction == kBREventRemoteActionPlayPause || remoteAction == kBREventRemoteActionPlayPause2) && 
        self.delegate != nil && 
        action.value == 1 && 
        [self.delegate conformsToProtocol:@protocol(Plex_SMFMoviePreviewControllerDelegate)] &&
        [self.delegate respondsToSelector:@selector(controller:buttonSelectedAtIndex:)]) {
        id selectedC = [self focusedControl];
        for (int j=0;j<[_buttons count];j++) {
            if([_buttons objectAtIndex:j]==selectedC) {
                [self.delegate controller:self playButtonEventOnButtonAtIndex:j];
                return YES;
            }
        }
    }
    if ((remoteAction == kBREventRemoteActionPlayPause || remoteAction == kBREventRemoteActionPlayPause2) && 
        self.delegate != nil && 
        action.value == 1 && 
        [self.delegate conformsToProtocol:@protocol(Plex_SMFMoviePreviewControllerDelegate)] &&
        [self.delegate respondsToSelector:@selector(controller:playButtonEventInShelf:)] &&
        [c isKindOfClass:[PlexMediaShelfView class]]) {
            
        [self.delegate controller:self playButtonEventInShelf:(PlexMediaShelfView *)c];
        return YES;
    }
    return [super brEventAction:action];
}

-(void)reload {
    DLog();
    [super reload];
    
    CGRect masterFrame = [BRWindow interfaceFrame];
    CGRect mtcf = _metadataTitleControl.frame;
    
    
    /*
     *  Custom Divider 1
     */
    BRDividerControl *cdiv1 = [[BRDividerControl alloc] init];
    CGRect cdiv1Frame = CGRectMake(mtcf.origin.x, 
                                   348.f, 
                                   mtcf.size.width,
                                   masterFrame.size.height*(10.f/720.f));
    [cdiv1 setFrame:cdiv1Frame];
    [self addControl:cdiv1];
    [_hideList addObject:cdiv1];
    [cdiv1 release];
    
    
    /*
     *  Custom Divider 2
     */
    BRDividerControl *cdiv2 = [[BRDividerControl alloc] init];
    CGRect cdiv2Frame = CGRectMake(cdiv1Frame.origin.x, 
                                   cdiv1Frame.origin.y+55.f, 
                                   cdiv1Frame.size.width,
                                   cdiv1Frame.size.height);
    [cdiv2 setFrame:cdiv2Frame];
    [self addControl:cdiv2];
    [_hideList addObject:cdiv2];
    [cdiv2 release];
    
    /*
     *  Flags
     */    
    if (!self.flags) {
        self.flags = [self.datasource flags];
    }
    
    BRPanelControl *flagPanel = [[BRPanelControl alloc] init];
    flagPanel.panelMode = 0;
    flagPanel.horizontalSpacing = 10.f;
    flagPanel.acceptsFocus = NO;
    //flagPanel.horizontalMargin = 10.f;
    flagPanel.frame = CGRectMake(cdiv1Frame.origin.x, 
                                 CGRectGetMaxY(cdiv1Frame), 
                                 cdiv1Frame.size.width, 
                                 CGRectGetMinY(cdiv2Frame)-CGRectGetMaxY(cdiv1Frame));
    
    float maxHeight = 28.f;
    for (BRImage *flagImage in self.flags) {
        BRImage *image = nil;
        CGSize flagSize = [flagImage pixelBounds];
        if (flagSize.height > maxHeight) { 
            //if too tall, reduce it so it will fit within the scaled width and maxHeight
            float scalingRatio = maxHeight/flagSize.height;
            flagSize = CGSizeMake(flagSize.width*scalingRatio, maxHeight);
            image = [flagImage croppedImageForSize:flagSize];
        } else {
            image = flagImage;
        }
        
        BRImageControl *imageControl = [[BRImageControl alloc] init];
        imageControl.image = image;
        
        [flagPanel addControl:imageControl];
        [imageControl release];
    }
    [self addControl:flagPanel];
    [_hideList addObject:flagPanel];
    [flagPanel release];    
}

-(void)layoutSubcontrols {
    [super layoutSubcontrols];
    
    BOOL fanartEnabled = [[HWUserDefaults preferences] boolForKey:PreferencesViewPreplayFanartEnabled];
    if (fanartEnabled) {
        //background image
        NSURL *artworkUrl = [self.datasource backgroundImageUrl];
        
        //no point in doing all the work if we have no hope of getting an image
        if (artworkUrl) {
            BRURLImageProxy *imageProxy = [BRURLImageProxy proxyWithURL:artworkUrl];
            
            BRAsyncImageControl *backgroundImageControl = [[BRAsyncImageControl alloc] initWithImageProxy:imageProxy];
            backgroundImageControl.frame = [BRWindow interfaceFrame];
            backgroundImageControl.opacity = 0.5f;
            
            //FIXME: why is it not stretching?!
            [backgroundImageControl setContentMode:UIViewContentModeScaleAspectFill];
            
            [self insertControl:backgroundImageControl atIndex:0];
            [backgroundImageControl release];
            
            
            //shadings behind controls
            BRControl *control = [[BRControl alloc] init];
            control.backgroundColor = [[UIColor blackColor] CGColor];            
            control.frame = self.frame;
            
            control.opacity = 0.5f;
            [self insertControl:control atIndex:1];
            [control release];
            
            //remove background from textbox
            _summaryControl.backgroundColor = [[UIColor clearColor] CGColor];
        }
    }
}

- (void)dealloc {
    self.flags = nil;
    self.datasource = nil;
    
    [super dealloc];
}

@end
