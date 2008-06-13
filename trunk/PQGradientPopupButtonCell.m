//
//  PQGradientPopupButtonCell.m
//  Comic Life
//
//  Created by Robert Grant on 8/21/07.
//  Copyright 2007 plasq LLC. All rights reserved.
//

#import "PQGradientPopUpButtonCell.h"

static const kTickWidth = 2.f;
static const kMaximumBezelRadius = 20.f;

@implementation PQGradientPopUpButtonCell
- (void)_updateIconForItem:(NSMenuItem *)item
{
	if ([item image] == nil && iconProvider && [iconProvider respondsToSelector:@selector(iconForControl:forMenuItem:)]) {
		if ([item representedObject]) {
			[item setImage: [iconProvider iconForControl: [self controlView] forMenuItem: item]];
		}
	}
}

- (void)attachPopUpWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
{
	NSMenuItem *item;
	for (item in [[controlView menu] itemArray]) {
		[self _updateIconForItem: item];
	}
	[super attachPopUpWithFrame:(NSRect)cellFrame inView:(NSView *)controlView];
}

- (NSInteger)indexOfItemWithRepresentedObject:(id)obj
{
	NSInteger index = [super indexOfItemWithRepresentedObject: obj];
	// Ensure the item has an icon with it if any is available
	[self _updateIconForItem: [self itemAtIndex: index]];
	 return index;
}

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
	static NSGradient* gradient = nil;
	if (gradient == nil) {
		gradient = [[NSGradient alloc] initWithColorsAndLocations: 
							[[NSColor whiteColor] colorWithAlphaComponent:0.5f], 0.0f, 
							[[NSColor whiteColor] colorWithAlphaComponent:0.0f], 0.1f, 
							[[NSColor blackColor] colorWithAlphaComponent:0.4f], 1.f, 
							nil];
	}
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

static const float kControlInset = 3.5;
static const float kArrowXInset = 3;
static const float kArrowYInset = 1;

- (NSBezierPath*)_controlArrowsInRect: (NSRect)rect
{
	NSBezierPath* path = [NSBezierPath bezierPath];
	NSRect topRect;
	NSRect bottomRect;
	rect = NSInsetRect(rect, kControlInset, kControlInset);
	if (rect.size.height > 20) {
		rect = NSInsetRect(rect, 0, (rect.size.height - 20)*.5f);
	}
	NSDivideRect(rect, &topRect, &bottomRect, rect.size.height/2, NSMinYEdge);

	topRect = NSInsetRect(topRect, kArrowXInset, kArrowYInset);
	bottomRect = NSInsetRect(bottomRect, kArrowXInset, kArrowYInset);
	
	[path moveToPoint: NSMakePoint(NSMinX(topRect), NSMaxY(topRect))];
	[path lineToPoint: NSMakePoint(NSMidX(topRect), NSMinY(topRect))];
	[path lineToPoint: NSMakePoint(NSMaxX(topRect), NSMaxY(topRect))];
	[path closePath];
	
	[path moveToPoint: NSMakePoint(NSMinX(bottomRect), NSMinY(bottomRect))];
	[path lineToPoint: NSMakePoint(NSMidX(bottomRect), NSMaxY(bottomRect))];
	[path lineToPoint: NSMakePoint(NSMaxX(bottomRect), NSMinY(bottomRect))];
	[path closePath];
	
	return path;
}

static const float kControlSize = 20;

/*
 * Draw the bezel using a gradient
 */
- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView*)controlView
{
	frame = NSInsetRect(frame, 0.5, 0.5);
	
	float radius = frame.size.height * .5f;
	if (radius > kMaximumBezelRadius)
		radius = kMaximumBezelRadius;
	NSBezierPath *oval = [NSBezierPath bezierPathWithRoundedRect: frame xRadius:radius yRadius:radius];
	
	// Draw background
	NSGradient *gradient = [self bezelGradient];
	[[self color] set];
	[oval fill];
	
	// Draw popup control
	NSRect controlRect = NSMakeRect(NSMaxX(frame)-kControlSize, NSMinY(frame), kControlSize, frame.size.height);
	[NSGraphicsContext saveGraphicsState];
	[oval addClip];
	[[NSColor colorWithCalibratedWhite: .2 alpha: 1] set];
	NSRectFill(controlRect);
	[NSGraphicsContext restoreGraphicsState];
	
	NSBezierPath* arrowPath = [self _controlArrowsInRect: controlRect];
	[[NSColor whiteColor] set];
	[arrowPath fill];
	
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
	// If we have an image and we draw only the image, then forget about the title
	if ([self image] && [self imagePosition] == NSImageOnly)
		return frame;

	// Get the current title to add the new attribute to it
	NSMutableAttributedString *newTitle = [title mutableCopy];
	
    // Set the color attribute
	NSRange range = NSMakeRange(0, [title length]);
	if ([self isEnabled]) {
		NSColor *color = [newTitle attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:NULL];
		float alpha = [color alphaComponent];
		
		// Change color to white, with black shadow
		if (alpha < 1.f) {
			// We're drawing the shadow : use a black one
			[newTitle addAttribute: NSForegroundColorAttributeName value: [[NSColor blackColor] colorWithAlphaComponent:alpha] range: range];
		} else {
			[newTitle addAttribute: NSForegroundColorAttributeName value: [NSColor whiteColor] range: range];
		}
	}
	return [super drawTitle: newTitle withFrame: frame inView: controlView];
}

@end
