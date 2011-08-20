//
//  HWDetailedMovieMetadataController.h
//  atvTwo
//
//  Created by ccjensen on 2/7/11.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//  

#import <Foundation/Foundation.h>
#import <plex-oss/PlexMediaContainer.h>
#import <plex-oss/PlexMediaObject.h>
#import <plex-oss/PlexMediaStream.h>
#import "Plex_SMFMoviePreviewController.h"
#import "PlexMediaShelfView.h"

@interface PlexPreplayController : Plex_SMFMoviePreviewController<Plex_SMFMoviePreviewControllerDatasource, Plex_SMFMoviePreviewControllerDelegate, SMFListDropShadowDatasource, SMFListDropShadowDelegate> {
	BOOL shelfIsSelected;
	int currentSelectedIndex;
	int lastFocusedIndex;
 	SMFListDropShadowControl *listDropShadowControl; //popup
}
@property (retain) PlexMediaContainer *relatedMediaContainer;
@property (retain) PlexMediaObject *selectedMediaObject;

- (id)initWithPlexMediaObject:(PlexMediaObject *)aMediaObject;
- (void)changeMetadataViewToShowDataForIndex:(int)index;

@end