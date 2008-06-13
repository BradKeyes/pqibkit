//
//  PQCGImageView.m
//
//  Copyright 2007 plasq LLC. All rights reserved.
//

#import "PQCGImageView.h"

@implementation PQCGImageView

@synthesize imageRef = _imageRef;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)setImageRef: (CGImageRef)imageRef
{
	_imageRef = imageRef;
	[self setNeedsDisplay: YES];
}

/**
 */
- (void)drawRect:(NSRect)dirtyRect
{
	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
	CGRect rect = NSRectToCGRect(self.bounds);
	CGContextDrawImage(context, rect, self.imageRef);
}

@end
