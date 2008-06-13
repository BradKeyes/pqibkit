//
//  PQGradientsView.m
//  Comic Life
//
//  Created by Robert Grant on 8/29/07.
//  Copyright 2007 plasqLLC. All rights reserved.
//

#import "PQGradientsView.h"

static const int cellWidth = 21;
static const int cellHeight = 21;
static const int columns = 10;
static const int rows = 10;

@implementation PQGradientsView

- (void)loadGradients
{
	// Load the gradients bundled with the app
	NSArray* paths = [[NSBundle mainBundle] pathsForResourcesOfType: @"gradient" inDirectory: @"gradients"];
	for (NSString* path in paths) {
		NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile: path];
		PQGradient* gradient = [[PQGradient alloc] initWithDictionary: dict];
		[_gradients addObject: gradient];
	}
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		_gradients = [[[NSMutableArray alloc] init] retain];
		[self loadGradients];
    }
    return self;
}

- (BOOL)isFlipped
{
	return YES;
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (BOOL)becomeFirstResponder
{
	return YES;
}

- (BOOL)resignFirstResponder
{
	return YES;
}

- (PQGradient*)_gradientAtX:(int)x y:(int)y
{
	int index = (y  * columns) + x;
	// Are we off the end of the list?
	if (index >= [_gradients count]) {
		// return a cached default gradient
		static PQGradient* gradient = nil;
		if (gradient == nil)
			gradient = [[PQGradient alloc] init];
		return [[gradient retain] autorelease];
	}
	
	// Else return a gradient in the array
	return [_gradients objectAtIndex: index];
}

- (void)drawRect:(NSRect)rect
{
	NSRect bounds = [self bounds];
	[[NSColor whiteColor] set];
	NSRectFill(bounds);
	
	// Draw the gradient swatches
	unsigned int x = 0;
	unsigned int y = 0;
	for (x = 0; x < columns; x++) {
		for (y = 0; y < rows; y++) {
			PQGradient* gradient = [self _gradientAtX: x y: y];
			NSRect cell = NSMakeRect(x * cellWidth, y * cellHeight, cellWidth, cellHeight);
			NSBezierPath* path = [NSBezierPath bezierPathWithRect: cell];
			[gradient fillPath: path];
		}
	}
	
	// Now overlay the black grid
	NSBezierPath* grid = [NSBezierPath bezierPathWithRect: bounds];
	[[NSColor blackColor] set];
	for (x = 0; x < columns; x++) {
		[grid moveToPoint: NSMakePoint(x * cellWidth, 0)];
		[grid lineToPoint: NSMakePoint(x * cellWidth, bounds.size.height)];
	}
	for (y = 0; y < rows; y++) {
		[grid moveToPoint: NSMakePoint(0, y * cellHeight)];
		[grid lineToPoint: NSMakePoint(bounds.size.width, y * cellHeight)];
	}
	[grid stroke];
	
	// Finally if the user has selected a gradient - show which one they selected
	if (NSPointInRect(_curPoint, [self bounds])) {
		int gridX = _curPoint.x / cellWidth;
		int gridY = _curPoint.y / cellHeight;
		NSRect cell = NSMakeRect(gridX * cellWidth, gridY * cellHeight, cellWidth, cellHeight);
		cell = NSInsetRect(cell, 1, 1);
		[[NSColor blackColor] set];
		NSFrameRect(cell);
		cell = NSInsetRect(cell, 1, 1);
		[[NSColor whiteColor] set];
		NSFrameRect(cell);
	}
}

- (void)_processEvent:(NSEvent*)event
{
	// Figure out which color swatch is under the cursor
	NSPoint point = [event locationInWindow];
	point = [self convertPoint: point fromView: nil];
	
	// if the cursor is outside of the view - bail
	if (!NSPointInRect(point, [self bounds])) return;

	_curPoint = point;
	
	point.x /= cellWidth;
	point.y /= cellHeight;
	
	PQGradient* gradient = [self _gradientAtX: point.x y: point.y];
	[_delegate gradientsView: self didChooseGradient: gradient];
	[self setNeedsDisplay: YES];
}

- (void)mouseDown:(NSEvent*)event
{
	// Start our own event loop until mouseup to avoid getting continuous
	// color changes added to the undo group
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
	[_delegate gradientsViewDidMouseUp: self];		
}

@end
