/**
 * This header is generated by class-dump-z 0.2a.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/BackRow.framework/BackRow
 */

#import "BRSelectionHandler.h"
//

@class NSSet;

@interface BRSeriesMainMenuShelfSelectionHandler : NSObject <BRSelectionHandler> {
@private
	NSSet *_mediaTypes;	// 4 = 0x4
	BOOL _filterOutWatched;	// 8 = 0x8
}
+ (id)selectionHandlerForTypes:(id)types;	// 0x32e308c1
- (id)_initWithTypes:(id)types filteringOutWatched:(BOOL)watched;	// 0x32e30905
- (void)dealloc;	// 0x32e3096d
- (BOOL)handleSelectionForControl:(id)control;	// 0x32e306f9
@end
