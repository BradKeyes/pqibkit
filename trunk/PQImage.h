/**
 * \file PQImage.h
 *
 * Copyright plasq LLC 2007. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

@class PQImageRep;

/**
 * A reliable replacement for NSImage
 *
 * \ingroup AppKit
 */
@interface PQImage : NSObject <NSCoding> {

	PQImageRep*			_imageRep;
	BOOL				_flipped;
	NSSize				_size;
}

@property (assign) BOOL flipped;
@property (assign) NSSize size;
@property (readonly) BOOL isVector;
@property (readonly) CGImageRef CGImage;
@property (retain) PQImageRep* imageRep;
@property (readonly) BOOL canPopOut;
@property BOOL wantsPopOut;

/** Just like NSImage */
+ (PQImage*)imageNamed: (NSString*)name;

/** Reads PICT data from 'pictURL', converts it to PDF, and writes the result to 'pdfURL' */
+ (void)convertPICTResource: (NSURL*)pictURL toPDF: (NSURL*)pdfURL;

- (id)initByReferencingURL:(NSURL *)url;
- (id)initWithContentsOfURL: (NSURL *)url;
- (id)initWithContentsOfFile: (NSString *)file;
- (id)initWithSize:(NSSize)size;

- (void)lockFocus;
- (void)unlockFocus;

- (void)drawInRect:(NSRect)dstRect operation:(NSCompositingOperation)op fraction:(CGFloat)delta;
- (void)drawPopOutInRect:(NSRect)dstRect operation:(NSCompositingOperation)op fraction:(CGFloat)delta;
- (void)tileWithRect:(NSRect)dstRect operation:(NSCompositingOperation)op fraction:(CGFloat)delta;

- (NSImage *)nsImage;

- (CIImage *)CIImageWithSize:(NSSize)size;
- (CIImage *)CIPopOutImageWithSize:(NSSize)size;

- (PQImage *)colorizeWithColor:(NSColor*)color;

/** Returns TRUE if the file or url looks like an image */
+ (BOOL)isImageFile:(NSString*)file;
+ (BOOL)isImageURL:(NSURL*)url;

@end
