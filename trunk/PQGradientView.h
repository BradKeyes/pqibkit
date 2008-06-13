/**
 * \file PQGradientView.h
 *
 * Copyright plasq LLC 2007. All rights reserved.
 */

#import <Cocoa/Cocoa.h>


@interface PQGradientView : NSView {
	NSColor* _color;
	NSGradient* _gradient;
}
/** Background color */
@property(retain) NSColor *color;

/** Border gradient */
@property(retain) NSGradient *gradient;

@end
