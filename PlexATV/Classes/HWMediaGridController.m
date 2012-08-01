//
//  HWMediaShelfController.m
//  atvTwo
//
//  Created by bob on 2011-01-29.
//  Copyright 2011 Band's gonna make it!. All rights reserved.
//

#import "HWMediaGridController.h"
#import "PlexMediaAsset.h"
#import "PlexMediaObject+Assets.h"
#import <plex-oss/PlexMediaObject.h>
#import <plex-oss/PlexMediaContainer.h>
#import "PlexControlFactory.h"
#import "PlexNavigationController.h"
#import "Localize.h"

#define LOCAL_DEBUG_ENABLED 1
#define MAX_RECENT_ITEMS 20

//these are in the AppleTV.framework, but cannot #import <AppleTV/AppleTV.h> due to
//naming conflicts with Backrow.framework. below is a hack!
@interface BRThemeInfo (PlexExtentions)
- (id)storeRentalPlaceholderImage;
@end

@implementation HWMediaGridController
@synthesize shelfMediaContainer, shelfMediaObjects, gridMediaContainer, gridMediaObjects;

void checkNil(NSObject *ctrl)
{
	if (ctrl!=nil) {
		[ctrl release];
		ctrl=nil;
	}
}

#pragma mark -
#pragma mark Object/Class Lifecycle
-(id)initWithPath:(NSString *)path {
	return self;
}

- (id)initWithPlexAllMovies:(PlexMediaContainer *)allMovies andRecentMovies:(PlexMediaContainer *)recentMovies {
	self = [self init];
    if (self) {
        self.shelfMediaContainer = recentMovies;
        self.gridMediaContainer = allMovies;
        
        // we'll cut the recent movies down to MAX_RECENT_ITEMS, since recent actually has all movies, only sorted by added date
        //and shelf isn't actually usable with bunch of items
        NSArray *fullRecentMovies = recentMovies.directories;
        NSRange theRange;  
        theRange.location = 0;
        theRange.length = [fullRecentMovies count] > MAX_RECENT_ITEMS ? MAX_RECENT_ITEMS : [fullRecentMovies count];
        
        self.shelfMediaObjects = [fullRecentMovies subarrayWithRange:theRange];
        self.gridMediaObjects = allMovies.directories;
        _lastFocusedControlIndex = 0; //set inital focused control
    }
	return self;
}

-(void)dealloc {
#if LOCAL_DEBUG_ENABLED
	DLog(@"deallocing HWMediaShelfController");
#endif
    self.shelfMediaContainer = nil;
    self.gridMediaContainer = nil;
	self.shelfMediaObjects = nil;
	self.gridMediaObjects = nil;
    [_spinner release];
    [_cursorControl release];
    [_scroller release];
	[_gridControl release];
	[_shelfControl release];
	[_panelControl release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark Controller Lifecycle behaviour
- (void)wasPushed {
	[[MachineManager sharedMachineManager] setMachineStateMonitorPriority:NO];
	[super wasPushed];
}

- (void)wasPopped {
    _gridControl = nil;
    _shelfControl = nil;
	[super wasPopped];
}

- (void)wasExhumed {
	[[MachineManager sharedMachineManager] setMachineStateMonitorPriority:NO];
	[super wasExhumed];
}

- (void)wasBuried {
	[super wasBuried];
}

-(void)controlWasActivated
{
	DLog(@"controlWasActivated");
    [self _removeAllControls];
	[self drawSelf];
            
	[super controlWasActivated];
	
}

#pragma mark -
- (void) drawSelf
{
	DLog(@"drawSelf");
	[self _removeAllControls];
	
	CGRect masterFrame = [BRWindow interfaceFrame];
	
	/*
	 * Controls init
	 */
	
	DLog(@"controls init");
	
	_spinner=[[BRWaitSpinnerControl alloc]init];
	
	_cursorControl=[[BRCursorControl alloc] init];
	
	_scroller=[[BRScrollControl alloc] init];
	
	_gridControl=[[BRGridControl alloc] init];
	
	_shelfControl = [[BRMediaShelfControl alloc]init];
	
	_panelControl = [[BRPanelControl alloc]init];
	
	
	[self addControl:_scroller];
	[self addControl:_spinner];
	
	
	
	[_panelControl setFrame:masterFrame];
	[_panelControl setPanelMode:1];
	
	/* Scroller
	 * - Panel
	 *  - Spacer (44px)
	 *  - Box1 (divider + shelf)
	 *  - Box2 (divider + grid)
	 *  - Spacer
	 */
	BRSpacerControl *spacerTop=[BRSpacerControl spacerWithPixels:44.f];
	[_panelControl addControl:spacerTop];
	
	/*
	 *  Text control (recently added)
	 */
	BRDividerControl *div1=[[BRDividerControl alloc] init];
	div1.drawsLine = YES;
	[div1 setStartOffsetText:0];
	[div1 setAlignmentFactor:0.5f];
	[div1 setLabel:self.shelfMediaContainer.name];
	
	
	/*
	 * Shelf
	 */
	DLog(@"shelf");
	_shelfControl = [[BRMediaShelfControl alloc] init];
	[_shelfControl setProvider:[self getProviderForShelf]];
	[_shelfControl setColumnCount:7];
	[_shelfControl setCentered:NO];
    [_shelfControl setCoverflowMargin:0.05000000074505806f];
	
    
	
	DLog(@"box");
	BRBoxControl *shelfBox = [[BRBoxControl alloc] init];
	[shelfBox setAcceptsFocus:YES];
    [shelfBox setSpace:0.0f];
	[shelfBox setDividerSuggestedHeight:46.f];
	[shelfBox setDividerMargin:0.05000000074505806f];
	[shelfBox setContent:_shelfControl];
	[shelfBox setDivider:div1];
	[shelfBox layoutSubcontrols];
	CGRect boxFrame = shelfBox.frame;
	boxFrame.size.height = 261.0f;
	[shelfBox setFrame:boxFrame];
	[_panelControl addControl:shelfBox];
	
	
    
	
	/*
	 * Grid
	 */ 
	BRDividerControl *div2=[[BRDividerControl alloc] init];
	div2.drawsLine = YES;
	[div2 setStartOffsetText:0];
	[div2 setAlignmentFactor:0.5f];
    NSString *gridLabel = [NSString stringWithFormat:@"%@ %@", localize(@"mediaGridAll"), self.gridMediaContainer.name];
	[div2 setLabel:gridLabel];
	
	CGRect dividerFrame = CGRectMake(0, boxFrame.size.height+10.f, 0, 0);
	[div2 setFrame:dividerFrame];
	
	
	DLog(@"grid");
	[_gridControl setProvider:[self getProviderForGrid]];
	[_gridControl setColumnCount:7];
	[_gridControl setWrapsNavigation:YES];
	[_gridControl setHorizontalGap:0];
	[_gridControl setVerticalGap:20.0f];
	[_gridControl setLeftMargin:0.05000000074505806];
	[_gridControl setRightMargin:0.05000000074505806];
	[_gridControl setAcceptsFocus:YES];
	[_gridControl setProviderRequester:_gridControl];
    //[_gridControl layoutSubcontrols];
    
	CGRect gridFrame = CGRectMake(dividerFrame.origin.y-25, [_gridControl _totalHeight] + 50.f, 0, 0);
	[_gridControl setFrame:masterFrame];
	
	CGRect gridBoxFrame;
	gridBoxFrame.origin.x = 0;
	
	BRBoxControl *gridBox = [[BRBoxControl alloc] init];
	[gridBox setAcceptsFocus:YES];
	[gridBox setDividerSuggestedHeight:40.f];
	[gridBox setDividerMargin:0.05f];
	[gridBox setContent:_gridControl];
	[gridBox setDivider:div2];
	[gridBox setFrame:gridFrame];
	
	
	
	[gridBox layoutSubcontrols];

	[_panelControl addControl:gridBox];
	
    
	
	BRSpacerControl *spacerBottom=[BRSpacerControl spacerWithPixels:44.f];
	CGRect spacerFrame = CGRectMake(0, 0, 0, 44.f);
	[spacerBottom setFrame:spacerFrame];
	
	[_panelControl addControl:spacerBottom];
	[_panelControl layoutSubcontrols];
	
	[self addControl:_cursorControl];
	
	[_scroller setFrame:masterFrame];
	[_scroller setFollowsFocus:YES];
	[_scroller setContent:_panelControl]; 
	[_scroller setAcceptsFocus:YES];
	
	[self layoutSubcontrols];
	
#if LOCAL_DEBUG_ENABLED
	DLog(@"drawSelf done");
#endif
	
	
}

-(id)getProviderForShelf {
#if LOCAL_DEBUG_ENABLED
	DLog(@"getProviderForShelf_start");
#endif
	NSSet *_set = [NSSet setWithObject:[BRMediaType photo]];
	NSPredicate *_pred = [NSPredicate predicateWithFormat:@"mediaType == %@",[BRMediaType photo]];
	BRDataStore *store = [[BRDataStore alloc] initWithEntityName:@"Hello" predicate:_pred mediaTypes:_set];
	
	for (int i=0;i<[self.shelfMediaObjects count];i++)
	{
		PlexMediaObject *pmo = [self.shelfMediaObjects objectAtIndex:i];
		[store addObject:pmo.previewAsset];
	}
#if LOCAL_DEBUG_ENABLED
	DLog(@"getProviderForShelf - have assets, creating datastore and provider");
#endif
    PlexControlFactory *controlFactory = [[PlexControlFactory alloc] initForMainMenu:NO];
	controlFactory.defaultImage = [[BRThemeInfo sharedTheme] storeRentalPlaceholderImage];
	
	BRPhotoDataStoreProvider* provider = [BRPhotoDataStoreProvider providerWithDataStore:store 
																		  controlFactory:controlFactory];
	
	
    [controlFactory release];
	[store release];
    [controlFactory release];
	return provider;
	
}

-(id)getProviderForGrid
{
#if LOCAL_DEBUG_ENABLED
	DLog(@"getProviderForGrid_start");
#endif
	NSSet *_set = [NSSet setWithObject:[BRMediaType movie]];
	NSPredicate *_pred = [NSPredicate predicateWithFormat:@"mediaType == %@",[BRMediaType movie]];
	BRDataStore *store = [[BRDataStore alloc] initWithEntityName:@"Hello2" predicate:_pred mediaTypes:_set];
	
	for (int i=0;i<[self.gridMediaObjects count];i++)
	{
		PlexMediaObject *pmo = [self.gridMediaObjects objectAtIndex:i];
		[store addObject:pmo.previewAsset];
	}
#if LOCAL_DEBUG_ENABLED
	DLog(@"getProviderForGrid - have assets, creating datastore and provider");
#endif
    
    
    PlexControlFactory *controlFactory = [[PlexControlFactory alloc] initForMainMenu:NO];
	controlFactory.defaultImage = [[BRThemeInfo sharedTheme] storeRentalPlaceholderImage];
	
    BRPhotoDataStoreProvider* provider = [BRPhotoDataStoreProvider providerWithDataStore:store 
																		  controlFactory:controlFactory];
    [store release];
    [controlFactory release];
    
#if LOCAL_DEBUG_ENABLED
	DLog(@"getProviderForGrid_end");
#endif
	
	return provider;
}

-(BOOL)brEventAction:(BREvent *)action
{
	if ([[self stack] peekController]!=self)
		return [super brEventAction:action];
	int remoteAction = [action remoteAction];
	if (remoteAction==kBREventRemoteActionPlay && action.value==1)
	{
		int index;
		NSArray *mediaObjects = nil;
		
		if ([_shelfControl isFocused]) {
			index = [_shelfControl focusedIndex];
			mediaObjects = self.shelfMediaObjects;
#if LOCAL_DEBUG_ENABLED
			DLog(@"item in shelf selected. mediaObjects: %d, index:%d",[mediaObjects count], index);
#endif      
		}
		
		else if ([_gridControl isFocused]) {
			_lastFocusedControlIndex = [_gridControl _indexOfFocusedControl];
			mediaObjects = self.gridMediaObjects;
#if LOCAL_DEBUG_ENABLED
			DLog(@"item in grid selected. mediaObjects: %d, index:%d",[mediaObjects count], _lastFocusedControlIndex);
#endif      
			
		}
		
		if (mediaObjects) {
#if LOCAL_DEBUG_ENABLED
			DLog(@"brEventaction. have %d mediaObjects and index %d, showing movie preview ctrl",[mediaObjects count], _lastFocusedControlIndex);
#endif      
			
            [[PlexNavigationController sharedPlexNavigationController] navigateToObjectsContents:[[mediaObjects objectAtIndex:_lastFocusedControlIndex] retain]];
		}
		else {
			DLog(@"error: no selected mediaObject");
		}
		
		
		return YES;
	}
	return [super brEventAction:action];
	
}

@end
