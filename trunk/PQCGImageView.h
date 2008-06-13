/**
 * \file PQCGImageView.h
 *
 * Copyright plasq LLC 2007. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

@class PQImage;

/**
 * Like an NSImageView, but shows CGImages
 *
 * \ingroup Views
 */
@interface PQCGImageView : NSView {

	/** The image */
	CGImageRef _imageRef;
}

@property(assign) CGImageRef imageRef;

@end
