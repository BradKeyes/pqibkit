/**
 * \file PQGradientsView.h
 *
 * Copyright plasq LLC 2007. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

#import "PQGradient.h"

/**
 * Shows up to 100 gradients in a grid for quick access
 */
@interface PQGradientsView : NSView {

	IBOutlet id _delegate;
	NSMutableArray* _gradients;
	NSPoint			_curPoint;
}

@end

@interface NSObject (PQGradientsViewDelegate)

- (void)gradientsView:(PQGradientsView*)view didChooseGradient:(PQGradient*)gradient;
- (void)gradientsViewDidMouseUp:(PQGradientsView*)view;
- (PQGradient*)selectedGradientForGradientsView:(PQGradientsView*)view;

@end