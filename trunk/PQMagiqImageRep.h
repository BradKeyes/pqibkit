/**
 * \file PQMagiqImageRep.h
 *
 * Copyright plasq LLC 2007. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

#import "PQImageRep.h"

/**
 * An image represented by a Magiq file
 *
 * \ingroup AppKit
 */

@interface PQMagiqImageRep : PQImageRep {
	NSURL*				_url;
	NSRect				_extent;
	CGFloat				_dpiX;
	CGFloat				_dpiY;
}

@property(assign) NSURL* url;
@property(readonly) NSURL* settingsURL;
@property(readonly) NSURL* sourceURL;
@property(readonly) NSURL* resultURL;
@property CGImageRef imageRef;
@property CGImageSourceRef imageSource;
@property CGImageRef originalImageRef;
@property CGImageSourceRef originalImageSource;
@property(assign) CIImage* cachedCIImage;
@property(assign) CIImage* cachedOriginalCIImage;
@property NSRect extent;

- (id)initByReferencingURL:(NSURL *)url;
- (id)initWithContentsOfURL: (NSURL *)url;
@end
