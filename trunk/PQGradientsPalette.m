//
//  PQCGradientsPalette.m
//
//  Created by Robert Grant on 8/17/07.
//  Copyright 2007 plasq LLC. All rights reserved.
//

#import "PQTitlelessKeyWindow.h"
#import "PQGradientsPalette.h"
#import "PQGradientWell.h"
#import "PQGradientsView.h"
#import "PQGradientPanel.h"

static PQGradientsPalette* _sharedPalette;

@implementation PQGradientsPalette

- (id)init
{
	if (self = [super init]) {
	//	Load the palette window nib and assign the contents to our title-less window
		[NSBundle loadNibNamed: @"GradientsPalette" owner: self];
		NSView* contentView = [_sourceWindow contentView];
		NSRect bounds = [contentView bounds];

		_window = [[PQTitlelessKeyWindow alloc] initWithContentRect: bounds styleMask: NSBorderlessWindowMask backing: NSBackingStoreBuffered defer: NO];
		[_window setContentView: contentView];
	}
	return self;
}

// Amount to 
static const float kPaletteOffset = 2;

- (void)_setSelectedWell:(PQGradientWell*)well
{
	// Position the gradients palette next to the selected well and
	// keep a reference so we know where to send the gradient back to.
	_selectedWell = well;
	[_window displayNextToView: well];

	// The color view is on a buffered window so kick it in the pants to force
	// it to redraw
	[_gradientsView setNeedsDisplay: YES];
	[_window setDelegate: self];
}

- (void)showGradientsPalette
{
	[_window makeKeyAndOrderFront: self];
}

+ (id)sharedGradientsPaletteForGradientWell:(PQGradientWell*)well
{
	if (_sharedPalette == nil) {
		_sharedPalette = [[PQGradientsPalette alloc] init];
	}

	[_sharedPalette _setSelectedWell: well];
	
	return [[_sharedPalette retain] autorelease];
}

- (IBAction)showGradientPanel:(id)sender
{
	// The user wants to show the full gradient panel so switch to that.
	[[_selectedWell window] removeChildWindow: _window];

	[_selectedWell activate: YES];
	
	[_window orderOut: self];

}

- (PQGradient*)gradient
{
	return _selectedGradient;
}

- (void)gradientsView:(PQGradientsView*)view didChooseGradient:(PQGradient*)gradient
{
	// Update the color well with the new gradient (if it's different)
	if (_selectedGradient != gradient) {
		_selectedGradient = gradient;
		[_selectedWell gradientChanged: self];
	}
}

- (void)gradientsViewDidMouseUp:(PQGradientsView*)view
{
	[[_selectedWell window] removeChildWindow: _window];
	[_window orderOut: self];
}

- (void)windowDidResignKey: (NSNotification*)notification
{
	// if the user clicks anywhere outside of the palette window remove it.
	[[_selectedWell window] removeChildWindow: _window];
	[_window orderOut: self];
}

@end
