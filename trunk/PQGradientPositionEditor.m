//
//  PQGradientPositionEditor.m
//  Comic Life
//
//  Created by Robert Grant on 8/26/07.
//  Copyright 2007 plasq LLC. All rights reserved.
//

#import "NSAffineTransform+PQAdditions.h"
#import "GeomUtils.h"
#import "PQGradientPositionEditor.h"


@implementation PQGradientPositionEditor

@synthesize gradient = _gradient;

- (void)setGradient:(PQGradient*)gradient
{
	_gradient = gradient;
	[self setNeedsDisplay: YES];
}

- (BOOL)isFlipped
{
	return YES;
}

- (NSRect)squareWithinBounds
{
	NSRect bounds = [self bounds];
	NSPoint center = PQCenterOfRect(bounds);
	float smallestEdge = bounds.size.width < bounds.size.height ? bounds.size.width : bounds.size.height;
	NSRect square = PQMakeRectFromCenterAndSize(center, NSMakeSize(smallestEdge, smallestEdge));
	return square;
}

static const float kHeadDepth = 20;
static const float kHeadInset = 5;
// Draws the angle arrow - waiting for final UI design on this.
- (void)drawAngleArrow
{
	[[NSGraphicsContext currentContext] saveGraphicsState];
	NSRect bounds = [self squareWithinBounds];
	NSRect triangle = NSInsetRect(bounds, bounds.size.width * .45, bounds.size.width * .2);

	NSBezierPath* path = [NSBezierPath bezierPath];
	// tip of the back end
	[path moveToPoint: NSMakePoint(NSMidX(triangle), NSMaxY(triangle))];
	[path lineToPoint: NSMakePoint(NSMinX(triangle) + kHeadInset, NSMinY(triangle) + kHeadDepth)];
	[path lineToPoint: NSMakePoint(NSMinX(triangle), NSMinY(triangle) + kHeadDepth)];
	// top of the front end
	[path lineToPoint: NSMakePoint(NSMidX(triangle), NSMinY(triangle))];
	[path lineToPoint: NSMakePoint(NSMaxX(triangle), NSMinY(triangle) + kHeadDepth)];
	[path lineToPoint: NSMakePoint(NSMaxX(triangle) - kHeadInset, NSMinY(triangle) + kHeadDepth)];
	[path closePath];
	NSAffineTransform* transform = [NSAffineTransform transformToRotateByDegrees: _gradient.angle + 90 aroundPoint: NSMakePoint(NSMidX(bounds), NSMidY(bounds))];
	[path transformUsingAffineTransform: transform];
	NSShadow* shadow = [[[[NSShadow alloc] init] retain] autorelease];
	[shadow setShadowOffset: NSMakeSize(0, -2)];
	[shadow set];
	[[[NSColor blackColor] colorWithAlphaComponent: .5] set];
	[path fill];
	[[NSGraphicsContext currentContext] restoreGraphicsState];
	bounds = PQMakeRectFromCenterAndSize(NSMakePoint(NSMidX(bounds), NSMidY(bounds)), NSMakeSize(7, 7));
	NSBezierPath* oval = [NSBezierPath bezierPathWithOvalInRect: bounds];
	[[[NSColor blackColor] colorWithAlphaComponent: .7] set];
	[oval fill];
}

- (void)drawPositionIndicator
{
	// scales the gradient offset up to the area in which we're drawing
	float scaleFactor = [self squareWithinBounds].size.width/2;
	NSRect bounds = [self squareWithinBounds];
	NSPoint center = NSMakePoint(NSMidX(bounds), NSMidY(bounds));
	center.x += (_gradient.offset.x * scaleFactor);
	center.y += (_gradient.offset.y * scaleFactor);
	NSRect rect = PQMakeRectFromCenterAndSize(center, NSMakeSize(10, 10));
	[[NSGraphicsContext currentContext] saveGraphicsState];
	NSBezierPath* path = [NSBezierPath bezierPath];
	// vertical
	[path moveToPoint: NSMakePoint(NSMidX(rect), NSMinY(rect))];
	[path lineToPoint: NSMakePoint(NSMidX(rect), NSMaxY(rect))];

	// horizontal
	[path moveToPoint: NSMakePoint(NSMinX(rect), NSMidY(rect))];
	[path lineToPoint: NSMakePoint(NSMaxX(rect), NSMidY(rect))];

	[path setLineWidth: 2];

	NSShadow* shadow = [[[[NSShadow alloc] init] retain] autorelease];
	[shadow setShadowOffset: NSMakeSize(0, -2)];
	[shadow set];

	[[[NSColor blackColor] colorWithAlphaComponent: .5] set];
	[path stroke];

	[[NSGraphicsContext currentContext] restoreGraphicsState];

}

// Draw the gradient in the appropriate manner for the type - overlay the arrow if needed
- (void)drawRect:(NSRect)rect
{
	NSBezierPath* path = nil;
	if ([_gradient type] == kPQLinearGradientType) {
		path = [NSBezierPath bezierPathWithRect: [self squareWithinBounds]];
	} else {
		path = [NSBezierPath bezierPathWithOvalInRect: [self squareWithinBounds]];
	}
	[_gradient fillPath: path];
	if ([_gradient type] == kPQLinearGradientType) {
		[self drawAngleArrow];
	} else {
		[self drawPositionIndicator];
	}
}

// Process the events coming in from the user dragging
- (void)_processEvent: (NSEvent*)event
{
	NSPoint point = [event locationInWindow];
	point = [self convertPoint: point fromView: nil];

	// scales the event offset down to the normalized gradient limit
	float scaleFactor = [self squareWithinBounds].size.width/2;
	NSRect bounds = [self bounds];
	NSPoint center = NSMakePoint(NSMidX(bounds), NSMidY(bounds));
	if ([_gradient type] == kPQLinearGradientType) {
		// If we're linear figure out the angle
		float angle = PQAngleBetweenPoints(center, point);
		_gradient.angle = angle - 90;
	} else {
		// Otherwise figure out the offset. dividing by 100 seems to give a nice correlation between mouse position and shiny spot
		NSPoint offset = NSMakePoint((point.x - center.x) / scaleFactor, (point.y - center.y) / scaleFactor);
		_gradient.offset = offset;
	}
	[_delegate gradientPositionEditorDidChangeGradient: self];
	[self setNeedsDisplay: YES];
}

- (void)mouseDown:(NSEvent*)event
{
	NSPoint point = [event locationInWindow];
	point = [self convertPoint: point fromView: nil];
	if ([event clickCount] == 2) {
		// A double click resets the angle or offset to 0
		if ([_gradient type] == kPQLinearGradientType)
			_gradient.angle = 0;
		else
			_gradient.offset = NSZeroPoint;

		[self setNeedsDisplay: YES];
		[_delegate gradientPositionEditorDidChangeGradient: self];
	} else {
		// Otherwise the user is probably dragging so let's track it.
		[[NSCursor crosshairCursor] push];
		[self _processEvent: event];
		while (event = [NSApp nextEventMatchingMask: NSLeftMouseUpMask | NSLeftMouseDraggedMask 
									  untilDate: [NSDate distantFuture] 
										 inMode: NSEventTrackingRunLoopMode 
										dequeue: YES]) {
			if ([event type] == NSLeftMouseUp) {
				break;
			}
			[self _processEvent: event];
		}
		[NSCursor pop];
	}
}

@end
