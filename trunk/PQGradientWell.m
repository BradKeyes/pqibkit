//
//  PQGradientWell.m
//  Comic Life
//
//  Created by Robert Grant on 8/26/07.
//  Copyright 2007 plasq LLC. All rights reserved.
//

#import "NSObject+PQAdditions.h"
#import "PQGradientPanel.h"
#import "PQGradientWell.h"
#import "PQGradientsPalette.h"


@implementation PQGradientWell

@synthesize isEnabled = _isEnabled;

+ (void)initialize
{
	[self exposeBinding:@"gradient"];
	[self exposeBinding:@"isEnabled"];
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		_gradient = [[[PQGradient alloc] init] retain];
    }
    return self;
}

- (BOOL)isFlipped
{
	return YES;
}

- (void)deactivate
{
	_isActive = FALSE;
	PQGradientPanel* panel = [PQGradientPanel sharedGradientPanel];
	[panel setTarget: nil]; 
	[panel setAction: nil];
	[self setNeedsDisplay: YES];	
}

- (void)activate:(BOOL)exclusive
{
	PQGradientPanel* panel = [PQGradientPanel sharedGradientPanel];
	[panel setGradientWell: self];
	[panel setTarget: self];
	[panel setAction: @selector(gradientChanged:)];
	[panel makeKeyAndOrderFront: self];
	_isActive = TRUE;
	[self setNeedsDisplay: YES];
}

- (BOOL)isActive
{
	return _isActive;
}

- (NSColor *)bgcolor
{
	id view = [self superview];
	while (view && ![view respondsToSelector:@selector(color)])
		view = [view superview];
	if (view)
		return [view color];
	else
		return [NSColor greenColor];
}

- (NSGradient*)bevelGradient
{
	static NSGradient* gradient = nil;
	if (gradient == nil) {
		gradient = [[NSGradient alloc] initWithColorsAndLocations: 
							[[NSColor blackColor] colorWithAlphaComponent:0.1f], 0.f, 
							[[NSColor whiteColor] colorWithAlphaComponent:0.1f], 0.95f, 
							[[NSColor whiteColor] colorWithAlphaComponent:0.5f], 1.0f, 
							nil];
	}
	return gradient;
}

static const int kWellInset = 4;

- (void)drawRect:(NSRect)rect
{
	[[self bgcolor] set];
	NSRectFill(rect);
	// Inset and offset slightly to ensure that the frame is solidly stroked
	NSRect bounds = NSOffsetRect(NSInsetRect([self bounds], 1, 1), 0.5, 0.5);
	NSBezierPath* path = [NSBezierPath bezierPathWithRoundedRect: bounds xRadius: 1 yRadius: 1];
	
	// Draw the gradient from top to bottom (i.e. 90 deg)
	[[self bevelGradient] drawInBezierPath: path angle: -90];
	
	bounds = NSInsetRect(bounds, kWellInset, kWellInset);
	[self drawWellInside: bounds];

	if (!self.isEnabled) {
		[[[NSColor whiteColor] colorWithAlphaComponent:0.3f] set];
		[NSBezierPath fillRect: bounds];
	}

	[[NSColor blackColor] set];
	[path stroke];
}

- (void)drawWellInside:(NSRect)insideRect
{
	NSBezierPath* path = [NSBezierPath bezierPathWithRect: insideRect];
	[_gradient fillPath: path];
}

- (void)setGradient:(PQGradient *)gradient
{
	if (gradient)
		_gradient = gradient;
	else
		_gradient = [[[PQGradient alloc] init] retain];
	
	[self setNeedsDisplay: YES];
}

- (PQGradient *)gradient
{
	return _gradient;
}

- (void)mouseDown:(NSEvent*)event
{
	// Intercept the mouse click so we can show our palette
	PQGradientsPalette *palette = [PQGradientsPalette sharedGradientsPaletteForGradientWell: self];
	[palette showGradientsPalette];
}

// Update bound objects about the gradient change
- (void)gradientChanged:(id)sender
{
	// getting a warning about ObjC type to cast the result.
	PQGradient* gradient = (PQGradient*)[sender gradient];
	if (gradient) {
		[self setGradient: gradient];
		[self notifyBoundObjectForKey:@"gradient"];
	}
}

@end
