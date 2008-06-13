/**
 * \file PQGradientColorEditor.h
 *
 * Copyright plasq LLC 2007. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

#import "PQGradient.h"

/**
 * Shows the gradient in a horizontal strip and lets a user position/add/remove colorstops
 * and set the color of the color stops.
 */
@interface PQGradientColorEditor : NSView {

	IBOutlet id _delegate;
	IBOutlet NSColorWell* _colorWell;
	
	PQGradient* _gradient;
	int			_selectedColorStop;
	BOOL		_draggedOff;
}

@property(retain) PQGradient* gradient;

// Color change coming in from the color well
- (IBAction)setColor:(id)sender;

@end

@interface NSObject (PQGradientColorEditorDelegate)

- (void)gradientColorEditorDidChangeGradient:(PQGradientColorEditor*)editor;

@end