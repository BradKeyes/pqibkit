/**
 * \file PQGradientPositionEditor.h
 *
 * Copyright plasq LLC 2007. All rights reserved.
 */

#import <Cocoa/Cocoa.h>
#import "PQGradient.h"

/**
 * Simple class for providing a linear or circular gradient editing controls
 * for either the angle or the offset.
 */
 
@interface PQGradientPositionEditor : NSView {

	IBOutlet id _delegate;

	PQGradient* _gradient;
}

@property(assign) PQGradient* gradient;

@end

@interface NSObject (PQGradientPositionEditor)

- (void)gradientPositionEditorDidChangeGradient:(PQGradientPositionEditor*)editor;

@end
