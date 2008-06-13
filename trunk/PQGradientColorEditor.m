//
//  PQGradientColorEditor.m
//  Comic Life
//
//  Created by Robert Grant on 8/26/07.
//  Copyright 2007 plasq LLC. All rights reserved.
//

#import "PQGradientColorEditor.h"


@implementation PQGradientColorEditor

@synthesize gradient = _gradient;

const float kStopWidth = 12;

// Determines the balance between the gradient bar and the colorstops below it
const float kGradientRatio = .5;

// gradient changed - sync up
- (void)setGradient:(PQGradient*)gradient
{
	_gradient = gradient;
	PQColorStop* stop = [[gradient colorStops] objectAtIndex: 0];
	[_colorWell setColor: stop.color];
	[self setNeedsDisplay: YES];
}

// Where should this color stop be shown in the control
- (NSRect)rectForColorStop: (PQColorStop*)stop
{
	float offset = stop.offset;
	NSRect bounds = NSInsetRect([self bounds], kStopWidth, 0);
	NSRect stopRect = NSZeroRect;
	stopRect.origin.x = bounds.origin.x + (offset * bounds.size.width) - (kStopWidth/2);
	stopRect.size.height = bounds.size.height * (1 - kGradientRatio);
	stopRect.size.width = kStopWidth;
	return stopRect;
}

// Draw a color stop
- (void)drawColorStop: (PQColorStop*)stop selected:(BOOL)isSelected
{
	NSRect rect = [self rectForColorStop: stop];
	rect = NSOffsetRect(rect, 0.5, 0.5);

	NSBezierPath* path = [NSBezierPath bezierPath];
	
	float height = rect.size.height;
	[path moveToPoint: NSMakePoint(NSMidX(rect), NSMaxY(rect))];
	[path lineToPoint: NSMakePoint(NSMaxX(rect), NSMaxY(rect) - height * .4)];
	[path lineToPoint: NSMakePoint(NSMaxX(rect), NSMinY(rect))];
	[path lineToPoint: NSMakePoint(NSMinX(rect), NSMinY(rect))];
	[path lineToPoint: NSMakePoint(NSMinX(rect), NSMaxY(rect) - height * .4)];
	[path closePath];

	if (!isSelected)
		[[NSColor whiteColor] set];
	else
		[[NSColor darkGrayColor] set];
	
	[path fill];

	[[NSColor darkGrayColor] set];
	[path stroke];

		
	NSRect colorRect = rect;
	colorRect.size.height = height *.6;
	colorRect = NSInsetRect(colorRect, 1, 1);
	[[NSColor whiteColor] set];
	NSRectFill(colorRect);
	// Now draw the color
	colorRect = NSInsetRect(colorRect, 1, 1);
	[stop.color set];
	NSRectFill(colorRect);
}

// Draw the gradient and color stops
- (void)drawRect:(NSRect)rect
{
	// draw the raw gradient - we don't want to have an angle or offset applied
	NSGradient* gradient = [_gradient gradient];
	NSRect gradientRect = NSInsetRect([self bounds], kStopWidth, 0);
	gradientRect.size.height *= kGradientRatio;
	gradientRect = NSOffsetRect(gradientRect, 0, [self bounds].size.height - gradientRect.size.height);
	[gradient drawInRect:  gradientRect angle: 0];

	[[NSColor grayColor] set];
	NSFrameRect(gradientRect);
	// Now draw the color stops
	int i = 0;
	for (PQColorStop* stop in [_gradient colorStops]) {
		// If the user has dragged the colorstop off the control then don't draw it
		if (i == _selectedColorStop && _draggedOff) {
			// don't draw it
		} else {
			[self drawColorStop: stop selected: i == _selectedColorStop];
		}
		i++;
	}
}

// Which (if any) colorstop is under this point
- (int)_colorStopAtPoint:(NSPoint)point
{
	int i = 0;
	for (PQColorStop* stop in [_gradient colorStops]) {
		NSRect rect = [self rectForColorStop: stop];
		if (NSPointInRect(point, rect))
			return i;
		i++;
	}
	return NSNotFound;
}

// Calculate the stop offset for this point
- (float)_offsetAtPoint:(NSPoint)point
{
	// if the user drags the stop above or below the control then consider it dragged off for now
	_draggedOff = (point.y < NSMinY([self bounds]) || point.y > NSMaxY([self bounds]));

	if (point.x < kStopWidth) point.x = kStopWidth;
	point.x -= kStopWidth;
	NSRect bounds = NSInsetRect([self bounds], kStopWidth, 0);
	if (point.x > bounds.size.width) point.x = bounds.size.width;
	return point.x / bounds.size.width;
}

// Process the mouseDown/dragging
- (void)_processEvent: (NSEvent*)event
{
	NSPoint point = [event locationInWindow];
	point = [self convertPoint: point fromView: nil];
	float offset = [self _offsetAtPoint: point];
	
	if (_draggedOff) {
		// If the stop has been dragged off - warn the user with the disappearing cursor
		[[NSCursor disappearingItemCursor] set];
	} else {
		// Else update the offset and tell people about it
		[[NSCursor resizeLeftRightCursor] set];
		PQColorStop* stop = [[_gradient colorStops] objectAtIndex: _selectedColorStop];
		stop.offset = offset;
		[_delegate gradientColorEditorDidChangeGradient: self];
	}
	
	[self setNeedsDisplay: YES];
}


// Handle the mouse down
- (void)mouseDown:(NSEvent*)event
{
	NSPoint point = [event locationInWindow];
	point = [self convertPoint: point fromView: nil];

	// Figure out if they clicked on a colorstop
	_selectedColorStop = [self _colorStopAtPoint: point];
	if (_selectedColorStop == NSNotFound) {
		if ([event clickCount] == 2) {
			// if they didn't and they double clicked then add a colorstop with the
			// current color well color and select it
			float offset = [self _offsetAtPoint: point];
			[_gradient addColorStopWithColor: [_colorWell color] atOffset: offset];
			
			_selectedColorStop = [_gradient countOfColorStops] - 1;
			PQColorStop* stop = [[_gradient colorStops] objectAtIndex: _selectedColorStop];
			
			// Sync everyone up
			[_colorWell setColor: stop.color];
			[self setNeedsDisplay: YES];
			[_delegate gradientColorEditorDidChangeGradient: self];
		}
	} else {
		// well they clicked on a color stop
		_draggedOff = FALSE;
		
		// Update the color well
		PQColorStop* stop = [[_gradient colorStops] objectAtIndex: _selectedColorStop];
		[_colorWell setColor: stop.color];

		// Save the current cursor - we're going to mess with it in the processEvent code
		[[NSCursor currentCursor] push];

		// Process the drags
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
		// process the mouseUp
		[self _processEvent: event];
		
		if (_draggedOff && [_gradient countOfColorStops] > 1) {
			// If the user dragged off the colorstop and it's not the last one - delete it with a poof
			NSShowAnimationEffect(NSAnimationEffectDisappearingItemDefault, [NSEvent mouseLocation], NSZeroSize, nil, nil, nil );
			[_gradient removeObjectFromColorStopsAtIndex: _selectedColorStop];
			[self setNeedsDisplay: YES];
			[_delegate gradientColorEditorDidChangeGradient: self];
		}
		[NSCursor pop];
		_draggedOff = FALSE;
	}
}

// sync the color change
- (IBAction)setColor:(id)sender
{
	PQColorStop* stop = [[_gradient colorStops] objectAtIndex: _selectedColorStop];
	stop.color = [sender color];
	[self setNeedsDisplay: YES];
	[_delegate gradientColorEditorDidChangeGradient: self];
}

@end
