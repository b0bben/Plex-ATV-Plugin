/**
 * This header is generated by class-dump-z 0.2a.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/BackRow.framework/BackRow
 */

#import "BackRow-Structs.h"
#import "BRTextEntryController.h"
#import "BRTextFieldDelegate.h"

@class NSString;

@interface BRTextEntryDialog : BRTextEntryController <BRTextFieldDelegate> {
@private
	NSString *_dialogID;	// 108 = 0x6c
	BOOL _canceled;	// 112 = 0x70
}
@property(readonly, retain) NSString *dialogID;	// G=0x32de6215; converted property
- (BOOL)brEventAction:(id)action;	// 0x32de613d
- (void)dealloc;	// 0x32de61cd
// converted property getter: - (id)dialogID;	// 0x32de6215
- (id)runModal;	// 0x32de609d
- (void)textDidChange:(id)text;	// 0x32de6065
- (void)textDidEndEditing:(id)text;	// 0x32de6069
@end
