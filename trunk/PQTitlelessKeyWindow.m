//
//  PQTitlelessKeyWindow.m
//
//  Copyright 2007 plasq LLC. All rights reserved.
//

#import "PQTitlelessKeyWindow.h"

@implementation PQTitlelessKeyWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
	if (self = [super initWithContentRect: contentRect styleMask: aStyle backing: bufferingType defer: flag]) {
		[self setOpaque: YES];
		[self setHasShadow: YES];
		[self setBackgroundColor: [NSColor colorWithCalibratedWhite: .14 alpha: 1]];
	}
	return self;
}	

// This is required for title-less windows to become key
- (BOOL)canBecomeKeyWindow
{
	return YES;
}

// Amount to nudge the window to get it to line up on the y-axis
static const float kPaletteOffset = 2;

- (void)displayNextToView:(NSView*)view
{
	// Position the color palette next to the selected well and
	// keep a reference so we know where to send the color back to.
	NSRect frame = [view bounds];
	frame = [view convertRect: frame toView: nil];
	NSRect windowFrame = [[view window] frame];
	frame = NSOffsetRect(windowFrame, frame.origin.x, frame.origin.y);
	NSRect paletteFrame = [self frame];
	paletteFrame.origin = frame.origin;

	// by default position the palette below the well
	NSRect destFrame = NSOffsetRect(paletteFrame, kPaletteOffset, -(paletteFrame.size.height - kPaletteOffset));
	NSScreen* screen = [[view window] screen];
	NSRect screenFrame = [screen visibleFrame];
	// But let's check with the screen to make sure it's visible
	if (NSMinY(destFrame) < NSMinY(screenFrame)) {
		// it's below the bottom of the screen so move it above the well
		destFrame = NSOffsetRect(paletteFrame, kPaletteOffset,  NSMaxY([view bounds]) - kPaletteOffset);
	}
	if (NSMinX(destFrame) < NSMinX(screenFrame)) {
		// it's beyond the left edge of the screen to move it to the right
		destFrame = NSOffsetRect(destFrame, NSMaxX([view bounds]),  0);
	} else if (NSMaxX(destFrame) > NSMaxX(screenFrame)) {	
		// it's beyond the right edge of the screen to move it to the left
		destFrame = NSOffsetRect(destFrame, -(paletteFrame.size.width - (NSMaxX([view bounds]) - kPaletteOffset)),  0);
	}
	[self setFrameOrigin: destFrame.origin];
	[[view window] addChildWindow: self ordered: NSWindowAbove];
	[self invalidateShadow];
}

@end
