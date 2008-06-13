/**
 * \file PQGradientsPalette.h
 *
 * Copyright plasq LLC 2007. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

@class PQGradientWell;
@class PQGradientsView;
@class PQTitlelessKeyWindow;

#import "PQGradient.h"

/**
 * Generously copied from PQColorPalette - shows a pop-up palette of predefined gradients
 * with a button to access the full gradient panel if the user wants to access that.
 */
@interface PQGradientsPalette : NSObject {

	IBOutlet	NSWindow*	_sourceWindow;
	IBOutlet	PQGradientsView* _gradientsView;
	PQTitlelessKeyWindow*	_window;
	PQGradientWell*			_selectedWell;
	PQGradient*				_selectedGradient;
}

+ (id)sharedGradientsPaletteForGradientWell:(PQGradientWell*)well;

- (void)showGradientsPalette;

- (IBAction)showGradientPanel:(id)sender;

- (PQGradient*)gradient;

@end
