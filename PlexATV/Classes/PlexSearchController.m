//
//  PlexSearchController.m
//  plex
//
//  Created by ccjensen on 29/04/2011.
//
//  Ideas stolen from: 
//      SMFCustomQueryMenu
//      Created by Thomas Cool on 5/10/11.
//      Copyright 2011 Thomas Cool. All rights reserved.


#import "PlexSearchController.h"
#import "Constants.h"
#import <plex-oss/Machine.h>
#import "PlexNavigationController.h"
#import "PlexMediaObject+Assets.h"
#import "Localize.h"

@implementation PlexSearchController
@synthesize totalResults, textEntry, previewContainer, currentSearchTerm, items;
@synthesize machine, currentSearchMediaContainer;


#pragma mark -
#pragma mark Object/Class Lifecycle

- (id)init {
    self = [super init];
    if (self) {
        self.items = nil;
        [self.list setDatasource:self];
        
        [self setListTitle:localize(@"searchScreenTitle")];
		NSString *plexIcon = [[NSBundle bundleForClass:[self class]] pathForResource:@"PlexIcon" ofType:@"png"];
		BRImage *listIcon = [BRImage imageWithPath:plexIcon];
		[self setListIcon:listIcon horizontalOffset:0.0 kerningFactor:0.15];
    }
    return self;
}

- (id)initWithMachine:(Machine *)aMachine {
    self = [self init];
    if (self) {
        self.machine = aMachine;
        self.currentSearchMediaContainer = nil;
    }
    return self;
}

-(void)dealloc {    
    self.totalResults = nil;
    self.textEntry = nil;
    self.previewContainer = nil;
    self.currentSearchTerm = nil;
    self.items = nil;
    
    self.machine = nil;
    self.currentSearchMediaContainer = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Controller Lifecycle behaviour
- (void)wasPushed {
	[[MachineManager sharedMachineManager] setMachineStateMonitorPriority:NO];
	[super wasPushed];
}

- (void)wasPopped {
	[super wasPopped];
}

- (void)wasExhumed {
	[[MachineManager sharedMachineManager] setMachineStateMonitorPriority:NO];
	[super wasExhumed];
}

- (void)wasBuried {
	[super wasBuried];
}

- (void)controlWasActivated {
    [super controlWasActivated];
    [self refresh];
}


#pragma mark -
#pragma mark Search Interface Methods
- (void)hideSearchInterface:(BOOL)hide {
    [self.textEntry setHidden:hide];
    [self.totalResults setHidden:hide];
    
    if (hide) {
        //preview is going to be shown, we better make sure it is up-to-date
        [self.previewContainer setHidden:NO];
        [self _updatePreview];
    } else {
        [self.previewContainer setHidden:YES];
    }
}

- (void)refresh {
    int listCount = [self.items count];
    if (listCount > 0) {
        [self.list setAcceptsFocus:YES];
    } else {
        [self.list setAcceptsFocus:NO];
    }
    
    NSString *results = @"";
    if (listCount > 0 || [self.currentSearchTerm length] > 0) {
        //if user has actually tried searching for something or there is something in the list
        results = [NSString stringWithFormat:@"%d Results", listCount];
    }
    
    [self.totalResults setText:results withAttributes:[[BRThemeInfo sharedTheme] metadataLabelAttributes]];
    [self.list reload];
}


#pragma mark -
#pragma mark Controller Drawing and Events
- (void)layoutSubcontrols {
    [super layoutSubcontrols];

    //CGRect masterFrame = [BRWindow interfaceFrame];
	
    //============================ TEXT ENTRY ============================
    if (!self.textEntry) {
        BRTextEntryControl *aTextEntry;
        if ([[[UIDevice currentDevice] systemVersion] isEqualToString:@"4.3"]) {
            aTextEntry = [[BRTextEntryControl alloc] initWithTextEntryStyle:9];
            aTextEntry.frame = CGRectMake(140, 
                                      53, 
                                      400, 
                                      534);
            aTextEntry.canWrapHorizontally = NO;
        } else {
            aTextEntry = [[BRTextEntryControl alloc] initWithTextEntryStyle:2];
            aTextEntry.frame = CGRectMake(108, 
                                          70, 
                                          460, 
                                          499);
        }
        self.textEntry = aTextEntry;
        
        [self addControl:aTextEntry];
        self.textEntry.textField.delegate = self;
        [aTextEntry release];
        [self setFocusedControl:self.textEntry];
    }
    
    //============================ TOTAL RESULTS ============================
    
    if (!self.totalResults) {
        BRTextControl *aTextControl = [[BRTextControl alloc] init];
        CGFloat width = 148.0f; //room for 7 digit result
        CGFloat height = 24.0f;
        if ([[[UIDevice currentDevice] systemVersion] isEqualToString:@"4.3"]) {
        aTextControl.frame = CGRectMake(392, 
                                        612, 
                                        width, 
                                        height);
        } else {
            aTextControl.frame = CGRectMake(CGRectGetMaxX(self.textEntry.frame)-width, 
                                            CGRectGetMaxY(self.textEntry.frame), 
                                            width, 
                                            height);
        }
        
        [self addControl:aTextControl];
        self.totalResults = aTextControl;
        [aTextControl release];
    }
    
    
    //============================ LINE IMAGE ============================
        
    
    //======================== MODIFY CURRENT CONTROLS ========================
    
    //============================ LIST ============================
    self.list.frame = CGRectMake(600, 
                                 22, 
                                 640, 
                                 612);

    
    //============================ PREVIEW ============================
    if (!self.previewContainer) {
        self.previewContainer = [self valueForKey:@"_previewContainer"];
        self.previewContainer.hidden = YES;
    }
    CGRect frame = previewContainer.frame;
    frame.origin.y -= 18.0;
    self.previewContainer.frame = frame;
}


-(BOOL)brEventAction:(BREvent *)action
{
    int remoteAction = [action remoteAction];
    if ([(BRControllerStack *)[self stack] peekController] != self)
		remoteAction = 0;
    
    int itemCount = [[(BRListControl *)[self list] datasource] itemCount];
    switch (remoteAction)
    {	
        case kBREventRemoteActionMenu:
            break;
        case kBREventRemoteActionSwipeLeft:
        case kBREventRemoteActionLeft:
        {
            BRControl *old = [self focusedControl];
            BOOL r = [super brEventAction:action];
            BRControl *new = [self focusedControl];
            if (new==self.textEntry && old!=self.textEntry) {
                [self hideSearchInterface:NO];
                //TODO: should be improved, we want to focus clear action button
                [self.textEntry setFocusToGlyphNamed:@"r"];
            }
            return r;
        }
        case kBREventRemoteActionSwipeRight:
        case kBREventRemoteActionRight:
        {
            BRControl *old = [self focusedControl];
            BOOL r = [super brEventAction:action];
            BRControl *new = [self focusedControl];
            if (old==self.textEntry && new!=self.textEntry) {
                [self hideSearchInterface:YES];
            }
            return r;
        }
        case kBREventRemoteActionPlayPause:
        case kBREventRemoteActionPlayPause2:
            if (self.list.focused) {
                if([action value] == 1)
                    [self playPauseActionForRow:[self getSelection]];
                return YES;
            }
            break;
		case kBREventRemoteActionUp:
		case kBREventRemoteActionHoldUp:
			if([self getSelection] == 0 && [action value] == 1 && [self focusedControl]==[self list])
			{
				[self setSelection:itemCount-1];
				return YES;
			}
			break;
		case kBREventRemoteActionDown:
		case kBREventRemoteActionHoldDown:
			if([self getSelection] == itemCount-1 && [action value] == 1&& [self focusedControl]==[self list])
			{
				[self setSelection:0];
				return YES;
			}
			break;
    }
	return [super brEventAction:action];
}


#pragma mark -
#pragma mark Search Methods

#define kSearchTermKey @"kSearchTermKey"
#define kSearchRequestKey @"kSearchRequestKey"
#define kSearchResultsKey @"kSearchResultsKey"
- (void)finishedSearch:(NSDictionary *)data {
    [self.textEntry stopSpinning];
    
    self.currentSearchMediaContainer = [data objectForKey:kSearchResultsKey];
    self.items = self.currentSearchMediaContainer.directories;
    [self refresh];
    
    //free the passed data
    [data release];
}

- (void)performSearch:(NSMutableDictionary *)data {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *searchTerm = [data objectForKey:kSearchTermKey];
    PlexRequest *searchRequest = [data objectForKey:kSearchRequestKey];
    
    PlexMediaContainer *searchResult = [searchRequest search:searchTerm];
    [data setObject:searchResult forKey:kSearchResultsKey];
    [self performSelectorOnMainThread:@selector(finishedSearch:) withObject:data waitUntilDone:YES];
    [pool drain];
}

- (void)startSearch {
    //start spinner
    [self.textEntry startSpinning];
    
    PlexRequest* searchRequest = self.machine.request;
    
    //is freed after the search finished
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithObjectsAndKeys:self.currentSearchTerm, kSearchTermKey, searchRequest, kSearchRequestKey, nil];
    [self performSelectorInBackground:@selector(performSearch:) withObject:data];
}


#pragma mark -
#pragma mark BRTextField Delegate Methods
- (void)textDidChange:(id)text {
    BRTextFieldControl *textField = (BRTextFieldControl *)text;
    
    self.currentSearchTerm = textField.stringValue;
    
    //perform new search
    [self startSearch];
}

- (void)textDidEndEditing:(id)text {
    //nothing needed
}

#pragma mark -
#pragma mark List Provider Methods
- (float)heightForRow:(long)row {
    PlexMediaObject *pmo = [self.items objectAtIndex:row];
    return pmo.heightForMenuItem;
}

- (long)itemCount {
    return [self.items count];
}

- (id)itemForRow:(long)row {
    
    PlexMediaObject *pmo = [self.items objectAtIndex:row];
    return pmo.menuItem;
}

- (id)previewControlForItem:(long)item {
    id preview = nil;
    if ([self.textEntry isHidden]) {
        PlexMediaObject *pmo = [self.items objectAtIndex:item];
        preview = pmo.previewControl;
    }
    return preview;
}

- (id)titleForRow:(long)row {
    PlexMediaObject *pmo = [self.items objectAtIndex:row];
	return pmo.name;
}


#pragma mark -
#pragma mark BRMenuListItemProvider Delegate
- (BOOL)rowSelectable:(long)selectable {
	return TRUE;
}

- (void)itemSelected:(long)selected; {
	PlexMediaObject* pmo = [self.items objectAtIndex:selected];
    [[PlexNavigationController sharedPlexNavigationController] navigateToObjectsContents:pmo];
}

-(void)playPauseActionForRow:(long)row {
    PlexMediaObject* pmo = [self.items objectAtIndex:row];
    if (pmo.hasMedia) {
        //play media
        [[PlexNavigationController sharedPlexNavigationController] initiatePlaybackOfMediaObject:pmo];
    } else {
        //not media, pretend it was a selection
        [self.list.datasource itemSelected:row];
    }
}


#pragma mark -
#pragma mark List Action Methods
- (void)setSelection:(int)selection {
    BRListControl *list = [self list];
    NSMethodSignature *signature = [list methodSignatureForSelector:@selector(setSelection:)];
    NSInvocation *selInv = [NSInvocation invocationWithMethodSignature:signature];
    [selInv setSelector:@selector(setSelection:)];
    if(strcmp([signature getArgumentTypeAtIndex:2], "l"))
    {
        double dvalue = selection;
        [selInv setArgument:&dvalue atIndex:2];
    }
    else
    {
        long lvalue = selection;
        [selInv setArgument:&lvalue atIndex:2];
    }
    [selInv invokeWithTarget:list];
}

-(int)getSelection {
	BRListControl *list = [self list];
	int row;
	NSMethodSignature *signature = [list methodSignatureForSelector:@selector(selection)];
	NSInvocation *selInv = [NSInvocation invocationWithMethodSignature:signature];
	[selInv setSelector:@selector(selection)];
	[selInv invokeWithTarget:list];
	if([signature methodReturnLength] == 8)
	{
		double retDoub = 0;
		[selInv getReturnValue:&retDoub];
		row = retDoub;
	}
	else
		[selInv getReturnValue:&row];
	return row;
}

@end
