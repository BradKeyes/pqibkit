/**
 * \file PQImageRep.h
 *
 * Copyright plasq LLC 2007. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

@class PQLRUTable;

/**
 * An abstract base class for implementing the different image rep types needed
 *
 * \ingroup AppKit
 */
@interface PQImageRep : NSObject {

	NSSize				_pixelSize;
	BOOL				_flipped;
	BOOL				_wantsPopOut;
}
@property (readonly) BOOL isVector;
@property (readonly) BOOL canPopOut;
@property BOOL wantsPopOut;

/** Cache for our images and image sources */
+ (PQLRUTable *)imagesCache;
+ (PQLRUTable *)imageSourcesCache;

- (NSSize)pointSize;
- (NSSize)pixelSize;

- (void)drawPopOutInRect:(NSRect)rect;
- (void)drawInRect:(NSRect)rect;
- (void)tileWithRect:(NSRect)rect;

- (CIImage *)CIImageWithSize: (NSSize)size;
- (CIImage *)CIPopOutImageWithSize: (NSSize)size;

- (BOOL)pointIsInside: (NSPoint)point;
@end
