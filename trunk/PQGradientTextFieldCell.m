//
//  PQGradientTextFieldCell.m
//  Comic Life
//
//  Created by Airy ANDRE on 20/08/07.
//  Copyright 2007 plasq LLC. All rights reserved.
//

#import "PQGradientTextFieldCell.h"


@implementation PQGradientTextFieldCell

- (BOOL)isActive
{
	// See "Event Handling Basics"

	NSWindow* window = self.controlView.window;
	id firstResponder = window.firstResponder;

	if ( [[window firstResponder] isKindOfClass: [NSTextView class]] && [window fieldEditor: NO forObject: nil] != nil ) {
        
		NSTextField *field = [firstResponder delegate];

        if (field.cell == self) 
            return YES;
	}
	return NO;
}

/*
 * Our color is the color of our first ancestor which can respond to "color" selector
 * Returns green if no such ancestor can be found
 */
- (NSColor *)color
{
	if (self.isActive)
		return [NSColor whiteColor];
	else {
		id view = [[self controlView] superview];
		while (view && ![view respondsToSelector:@selector(color)])
			view = [view superview];
		if (view)
			return [view color];
		else
			return [NSColor grayColor];
	}
}

/*
 * The gradient to use for the background part of the control
 */
- (NSGradient *)backgroundGradient
{
	static NSGradient *cachedGradient = nil;
	if (cachedGradient == nil) {
		cachedGradient = [[NSGradient alloc] initWithColorsAndLocations: 
											 [[NSColor whiteColor] colorWithAlphaComponent:0.1f],  0.0f, 
											 [[NSColor blackColor] colorWithAlphaComponent:0.1f],  1.f, 
											 nil];
	}
	return cachedGradient;
}

/*
 * Override default setting : we're doing our own background drawing
 */
- (BOOL)drawsBackground
{
	return NO;
}

/*
 * Draw the interior of the cell
 */
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
{
	NSRect interiorFrame = NSInsetRect(cellFrame, 0.5, 0.5);
	NSBezierPath *oval = [NSBezierPath bezierPathWithRoundedRect: interiorFrame xRadius:2.f yRadius:2.f];
	
	// Draw background
	NSGradient *gradient = [self backgroundGradient];
	[[self color] set];
	[oval fill];

	if (!self.isActive) {
		[gradient drawInBezierPath: oval angle: 90.f];
	}

	// Draw border
	[[NSColor blackColor] set];
	[oval stroke];
	
	// Draw selected and highlighter state by darkening/lightening
	if (![self isEnabled]) {
		[[[NSColor whiteColor] colorWithAlphaComponent:0.1f] set];
		[oval fill];
	}

	if ([self isHighlighted]) {
		[[[NSColor blackColor] colorWithAlphaComponent:0.2f] set];
		[oval fill];
	}

	if (self.isActive)
		self.textColor = [NSColor blackColor];
	else
		self.textColor = [NSColor whiteColor];

	// Draw the rest of the control
	[super drawInteriorWithFrame: cellFrame inView:controlView];
}

/*
 * Draw the interior, then the focus if it's first responder
 */
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
{
	[self drawInteriorWithFrame:cellFrame inView:controlView];
	if ([self showsFirstResponder]) {
		// showsFirstResponder is set for us by the NSControl that is drawing  us.
        NSRect focusRingFrame = cellFrame;
        focusRingFrame.size.height -= 2.0;
        [NSGraphicsContext saveGraphicsState];
        NSSetFocusRingStyle(NSFocusRingOnly);
        [[NSBezierPath bezierPathWithRect: focusRingFrame] fill];
        [NSGraphicsContext restoreGraphicsState];
    }	
}
@end
