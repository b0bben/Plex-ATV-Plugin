//
//  HWPlexDir.h
//  atvTwo
//
//  Created by Frank Bauer on 22.10.10.
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



@class PlexMediaObject;
@interface HWPlexDir: SMFMediaMenuController <BRTabControlDelegate> {
	PlexMediaContainer* rootContainer;
	PlexMediaObject* playbackItem;
}

@property (retain) BRTabControl *tabBar;
@property (retain) PlexMediaContainer* rootContainer;
@property (retain) NSArray *items;

- (id)initWithRootContainer:(PlexMediaContainer*)container andTabBar:(BRTabControl *)aTabBar;
- (void)log:(NSNotificationCenter *)note;
- (void)showModifyViewedStatusViewForRow:(long)row;
- (void)showAudioAndSubStreamChooserForRow:(long)row;
- (void)reselectCurrentTabBarItem;


//list provider
- (float)heightForRow:(long)row;
- (long)itemCount;
- (id)itemForRow:(long)row;
- (BOOL)rowSelectable:(long)selectable;
- (id)titleForRow:(long)row;

@end
