/**
 * \file PQCGImageRep.h
 *
 * Copyright plasq LLC 2007. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

#import "PQImageRep.h"

/**
 * A wrapper for a CGImageRef image representation
 *
 * \ingroup AppKit
 */
@interface PQCGImageRep : PQImageRep <NSCoding> {

	id			_imageRef;
	NSURL*				_url;
	CGContextRef		_focusContext;
	NSGraphicsContext*  _oldContext;
	
	CIImage*			_cachedCIImage;
	CGFloat				_dpiX;
	CGFloat				_dpiY;
}

@property (assign) NSURL* url;
@property (retain) CIImage* cachedCIImage;
@property CGImageRef imageRef;
@property CGImageSourceRef imageSource;

- (id)initByReferencingURL:(NSURL *)url;
- (id)initWithContentsOfURL: (NSURL *)url;
- (id)initWithSize: (NSSize)size flipped:(BOOL)flipped;

- (void)lockFocus;
- (void)unlockFocus;

@end
