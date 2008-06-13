//
//  PQGradientView.m
//  Comic Life
//
//  Created by Airy ANDRE on 20/07/07.
//  Copyright 2007 plasq LLC. All rights reserved.
//

#import "PQGradientView.h"


@implementation PQGradientView
@synthesize color = _color;
@synthesize gradient = _gradient;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
	
    if (self) {
        // Initialization code here.
		self.color = [NSColor grayColor];
		self.gradient = [[NSGradient alloc] initWithColorsAndLocations: 
						 [[NSColor whiteColor] colorWithAlphaComponent:0.f], 0.0f, 
						 [[NSColor whiteColor] colorWithAlphaComponent:.2f], 0.2f, 
						 [[NSColor blackColor] colorWithAlphaComponent:0.f], 1.f, 
						 nil];
		
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    // Fill
	[self.color set];
	NSRectFill(rect);
	
	// Draw our gradient
	[self.gradient drawInRect:[self bounds] angle:0.f];
	
	// Slightly darken the frame
	[[[NSColor blackColor] colorWithAlphaComponent:.5f] set];
	[NSBezierPath setDefaultLineWidth:.5];
	[NSBezierPath strokeRect:[self bounds]];
}
@end
