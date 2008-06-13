/**
 * \file PQGradientWell.h
 *
 * Copyright plasq LLC 2007. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

#import "PQGradient.h"

/**
 * Sort of a clone of NSColorWell - shows the gradient and displays the PQGradientPanel if activated
 */
@interface PQGradientWell : NSView {

	PQGradient* _gradient;
	BOOL		_isActive;
	BOOL        _isEnabled;
}

@property(assign) BOOL isEnabled;

- (void)deactivate;
- (void)activate:(BOOL)exclusive;
- (BOOL)isActive;

- (void)drawWellInside:(NSRect)insideRect;

- (void)setGradient:(PQGradient *)gradient;
- (PQGradient *)gradient;

// Update bound objects about the gradient change
- (void)gradientChanged:(id)sender;

@end
