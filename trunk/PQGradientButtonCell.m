//
//  PQGradientButtonCell.m
//  Comic Life
//
//  Created by Airy ANDRE on 17/08/07.
//  Copyright 2007 plasq LLC. All rights reserved.
//

#import "PQGradientButtonCell.h"

static const kTickWidth = 2.f;
static const kMaximumBezelRadius = 20.f;

@implementation PQGradientButtonCell
/*
 * Our color is the color of our first ancestor which can respond to "color" selector
 * Returns gray if no such ancestor can be found
 */
- (NSColor *)color
{
	id view = [[self controlView] superview];
	while (view && ![view respondsToSelector:@selector(color)])
		view = [view superview];
	if (view)
		return [view color];
	else
		return [NSColor grayColor];
}

/*
 * The gradient to use for the check part of the control
 */
- (NSGradient *)checkGradient
{
	NSGradient *gradient = [[NSGradient alloc] initWithColorsAndLocations: 
							[[NSColor whiteColor] colorWithAlphaComponent:0.2f], 0.0f, 
							[[NSColor blackColor] colorWithAlphaComponent:0.1f], 0.5f, 
							[[NSColor blackColor] colorWithAlphaComponent:0.2f], 1.f, 
							nil];
	return gradient;
}

/*
 * The gradient to use for the bezel part of the control
 */
- (NSGradient *)bezelGradient
{
	static NSGradient* gradient = nil;
	if (gradient == nil) {
		gradient = [[NSGradient alloc] initWithColorsAndLocations: 
							[[NSColor whiteColor] colorWithAlphaComponent:0.1f], 0.0f, 
							[[NSColor blackColor] colorWithAlphaComponent:0.0f], 0.1f, 
							[[NSColor blackColor] colorWithAlphaComponent:0.4f], 1.f, 
							nil];
	}
	return gradient;
}

/*
 * Return YES if the cell is a toggle
 */
- (BOOL)isToggle
{
	return ![self cellAttribute:NSPushInCell] && [self cellAttribute:NSCellChangesContents];
}

/*
 * Return YES if the cell is a push button
 */
- (BOOL)isPushButton
{
	return [self cellAttribute:NSPushInCell];
}

/*
 * Draw the bezel using a gradient
 */
- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView*)controlView
{
	frame = NSInsetRect(frame, 0.5, 0.5);
	
	float radius = frame.size.height * .5f;
	if (radius > kMaximumBezelRadius)
		radius = kMaximumBezelRadius;

	// Our assumption is that we're round by default. Here even our square style has rounded corners.

	if (self.bezelStyle == NSTexturedSquareBezelStyle)
		radius = 3;

	NSBezierPath *oval = [NSBezierPath bezierPathWithRoundedRect: frame xRadius:radius yRadius:radius];
	
	// Draw background
	NSGradient *gradient = [self bezelGradient];
	[[self color] set];
	[oval fill];
	[gradient drawInBezierPath: oval angle: 90.f];
	
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
}

/*
 * Draw the title using white as the main color for an enabled control
 */
- (NSRect)drawTitle:(NSAttributedString*)title withFrame:(NSRect)frame inView:(NSView*)controlView
{
	// Get the current title to add the new attribute to it
	NSMutableAttributedString *newTitle = [title mutableCopy];

    // Set the color attribute
	NSRange range = NSMakeRange(0, [title length]);

	if ([self isEnabled]) {
		NSColor *color = [newTitle attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:NULL];
		float alpha = [color alphaComponent];
		
		// Recessed buttons draw their titles differently
		float threshold = (self.bezelStyle == NSRecessedBezelStyle) ? 0.5 : 1.0;

		// Change color to white, with black shadow
		if (alpha < threshold) {
			// We're drawing the shadow : use a black one
			[newTitle addAttribute: NSForegroundColorAttributeName value: [[NSColor blackColor] colorWithAlphaComponent:alpha] range: range];
		} else {
			[newTitle addAttribute: NSForegroundColorAttributeName value: [NSColor whiteColor] range: range];
		}
	}

	return [super drawTitle: newTitle withFrame: frame inView: controlView];
}


/*
 * Draw an image : if the button is a toggle, then replace the image with a gradient
 *					and draw the check mark using a bezier path
 */
- (void)drawImage:(NSImage*)image withFrame:(NSRect)frame inView:(NSView*)controlView
{
	if ([self isToggle]) {
		// Draw the toggle box instead of using the image
		frame = NSInsetRect(frame, 3, 3);
		NSBezierPath *oval = [NSBezierPath bezierPathWithRoundedRect: frame xRadius:2.f yRadius:2.f];

		// Draw background
		NSGradient *gradient = [self checkGradient];
		[[self color] set];
		[oval fill];
		[gradient drawInBezierPath: oval angle: 90.f];

		// Draw border
		[[NSColor blackColor] set];
		[oval stroke];
		
		// Draw the checkbox if it's ON
		if ([self intValue]) {
			NSRect tickRect = NSInsetRect(frame, 2, 2);
			NSBezierPath *tick = [[[[NSBezierPath alloc] init] retain] autorelease];
			[tick moveToPoint:NSMakePoint(NSMinX(tickRect), NSMidY(frame))];
			[tick lineToPoint:NSMakePoint(NSMinX(tickRect) + tickRect.size.width * .3, NSMaxY(tickRect) - 2)];
			[tick lineToPoint:NSMakePoint(NSMaxX(tickRect), NSMinY(tickRect))];
			[tick setLineWidth:kTickWidth];
			[tick setLineCapStyle:NSRoundLineCapStyle];
			[[NSColor whiteColor] set];
			[tick stroke];
		}

		// Draw selected and highlighted state by darkening/lightening
		if (![self isEnabled]) {
			[[[NSColor whiteColor] colorWithAlphaComponent:0.1f] set];
			[oval fill];
		}
		if ([self isHighlighted]) {
			[[[NSColor blackColor] colorWithAlphaComponent:0.2f] set];
			[oval fill];
		}
	} else {
		[super drawImage: image withFrame: frame inView: controlView];
	}
}
@end
