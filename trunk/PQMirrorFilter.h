/**
 * \file PQMirrorFilter.h
 *
 * Copyright 2007 plasq LLC. All rights reserved.
 */

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

/**
 * class PQMirrorFilter : custom CIFilter extending its input to an infinite extent using mirrored copies.
 */

@interface PQMirrorFilter : CIFilter {
	CIImage   *inputImage;
}

@end
