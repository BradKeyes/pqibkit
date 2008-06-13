/**
 * \file PQGradientPopupButtonCell.h
 *
 * Copyright plasq LLC 2007. All rights reserved.
 */


#import <Cocoa/Cocoa.h>

/** PQGradientPopupButtonCell 
 * NSPopupButtonCell with a white label and gradients
 *
 * \ingroup Views
 */


@protocol PQIconProvider
- (NSImage *)iconForControl:(NSView *)control forMenuItem:(NSMenuItem *)menuItem;
@end

@interface PQGradientPopUpButtonCell : NSPopUpButtonCell {
	id iconProvider;
}

@end
