//
//  PQCGImageRep.m
//  Comic Life
//
//  Created by Robert Grant on 9/6/07.
//  Copyright 2007 plasq LLC. All rights reserved.
//

#import "PQCGImageRep.h"
#import <QuartzCore/QuartzCore.h>
#import "PQImage.h"
#import "NSScreen+PQAdditions.h"
#import "CIImage+PQAdditions.h"

@implementation PQCGImageRep

@synthesize url = _url;

#pragma mark Cache filling
- (void)_setDPIFromSource: (CGImageSourceRef)source
{
	// Fill the dpi info
	BOOL found = NO;
	if (source) {
		CFDictionaryRef dict = CGImageSourceCopyPropertiesAtIndex(source, 0, 0);
		if (dict) {
			// toll-free bridge
			NSDictionary* nsdict = (NSDictionary*)dict;
			NSNumber* dpiX = [nsdict objectForKey: (NSString *)kCGImagePropertyDPIWidth];
			NSNumber* dpiY = [nsdict objectForKey: (NSString *)kCGImagePropertyDPIHeight];
			if (dpiX && dpiY) {
				_dpiX = [dpiX floatValue];
				_dpiY = [dpiY floatValue];
				found = YES;
			}
			CFRelease(dict);
		}
	}
	if (!found) {
		// assume screen resolution
		NSScreen* screen = [NSScreen mainScreen];
		NSSize dpi = [screen dpi];
		_dpiX = dpi.width;
		_dpiY = dpi.height;
	}
}

// Read the images off disk and fill the cache with it
- (id)_loadImage
{
	CGImageSourceRef source = self.imageSource;
	id imageRef = nil;
	if (source) {
		imageRef  = NSMakeCollectable(CGImageSourceCreateImageAtIndex(source, 0, nil));
		if (imageRef) {
			_pixelSize.width = CGImageGetWidth((CGImageRef)imageRef);
			_pixelSize.height = CGImageGetHeight((CGImageRef)imageRef);
			self.imageRef = (CGImageRef)imageRef;
		}
		[self _setDPIFromSource: source];
	}
	return imageRef;
}

- (id)_loadCachedCIImage
{
	CIImage *cachedCIImage = [CIImage imageWithCGImage: self.imageRef];
	// Update our cache with that
	self.cachedCIImage = cachedCIImage;
	return cachedCIImage;
}

- (id)_loadImageSource
{
	id source = NSMakeCollectable(CGImageSourceCreateWithURL((CFURLRef)self.url, nil));
	// Update our cache with that
	self.imageSource = (CGImageSourceRef)source;
	return source;
}

// Defers loading the contents of the image until the image data is needed
- (id)initByReferencingURL:(NSURL *)url
{
	if (self = [super init]) {
		self.url = url;
	}
	return self;
}

// Immediately loads the contents on the image into memory
- (id)initWithContentsOfURL: (NSURL *)url
{
	if (self = [self initByReferencingURL: url]) {
		[self _loadImage];
	}
	return self;
}

- (id)initWithSize: (NSSize)size flipped:(BOOL)flipped
{
	if (self = [super init]) {
		_pixelSize.width = size.width;
		_pixelSize.height = size.height;
		// assume screen resolution
		NSScreen* screen = [NSScreen mainScreen];
		NSSize dpi = [screen dpi];
		_dpiX = dpi.width;
		_dpiY = dpi.height;
		_flipped = flipped;
	}
	return self;
}

- (NSSize)pixelSize
{
	if (_pixelSize.width == 0.f && _pixelSize.height == 0.f) {
		if (!_imageRef) {
			CGImageSourceRef source = self.imageSource;
			id obj = [[PQImageRep imagesCache] objectForKey: _url];
			if (!obj) {
				if (source) {
					CGImageRef imageRef  = CGImageSourceCreateImageAtIndex(source, 0, nil);
					if (imageRef) {
						_pixelSize.width = CGImageGetWidth(imageRef);
						_pixelSize.height = CGImageGetHeight(imageRef);
						CGImageRelease(imageRef);
					}
				}
			} else {
				// No need to recreate another imageRef - we have one cached - use that
				// to set our size
				CGImageRef imageRef = (CGImageRef)obj;
				_pixelSize.width = CGImageGetWidth(imageRef);
				_pixelSize.height = CGImageGetHeight(imageRef);
			}
			[self _setDPIFromSource: source];
		}
	}
	return _pixelSize;
}

- (NSSize)pointSize
{
	NSSize size = [self pixelSize];
	size.width *= 72.f / _dpiX;
	size.height *= 72.f / _dpiY;
	return size;
}

#pragma mark Setter and getter for our caches access
- (void)setImageRef: (CGImageRef)imageRef
{
	_imageRef = nil;
	// only url-based CGImageRep are cached
	if (_url) {
		if (imageRef == nil) {
			[[PQImageRep imagesCache] removeObjectForKey: _url];
		} else {
			[[PQImageRep imagesCache] setObject: (id)imageRef forKey: _url];
		}
	}
}

- (CGImageRef)imageRef
{
	if (_imageRef || !_url)
		return (CGImageRef)_imageRef;
	else {
		id obj = [[PQImageRep imagesCache] objectForKey: _url];
		if (!obj) {
			obj = [self _loadImage];
		}
		return (CGImageRef)obj;
	}
}

- (void)setCachedCIImage: (CIImage *)image
{
	// only url-based CGImageRep are cached
	if (image == nil) {
		[[PQImageRep imagesCache] removeObjectForKey: [NSValue valueWithPointer: self]];
	} else {
		[[PQImageRep imagesCache] setObject: image forKey: [NSValue valueWithPointer: self]];
	}
}

- (CIImage *)cachedCIImage
{
	id cachedCIImage = [[PQImageRep imagesCache] objectForKey: [NSValue valueWithPointer: self]];
	if (!cachedCIImage) {
		cachedCIImage = [self _loadCachedCIImage];
	}
	return cachedCIImage;
}

- (void)setImageSource: (CGImageSourceRef)imageSource
{
	if (imageSource == nil) {
		[[PQImageRep imageSourcesCache] removeObjectForKey: _url];
	} else {
		[[PQImageRep imageSourcesCache] setObject: (id)imageSource forKey: _url];
	}
}

- (CGImageSourceRef)imageSource
{
	id res = [[PQImageRep imageSourcesCache] objectForKey: _url];
	if (res == nil) {
		res = [self _loadImageSource];
	}
	return (CGImageSourceRef)res;
}
/*
 * NSCoding support -- we just decode the _url and (re)load the image.
 * We trust this will intialize all other ivars appropriately.
 */ 
- (id)initWithCoder:(NSCoder*)coder
{
	self = [super init];
	if (self) {
		NSURL* url = [coder decodeObjectForKey: @"_url"];
		[self initWithContentsOfURL: url];
	}
	return self;
}

/*
 * NSCoding support -- just encode the _url.
 */
- (void)encodeWithCoder:(NSCoder*)coder
{
	[coder encodeObject: _url forKey: @"_url"];
}

#define BEST_BYTE_ALIGNMENT 16
#define COMPUTE_BEST_BYTES_PER_ROW(bpr) \
	( (bpr) + (BEST_BYTE_ALIGNMENT - 1) ) & ( ~(BEST_BYTE_ALIGNMENT - 1) )

- (CGContextRef)_createFocusContextWithSize: (NSSize)size
{
	size.width = ceilf(size.width);
	size.height = ceilf(size.height);
	
	// copied from Quartz book pg: 353-4

	int bytesPerRow = 4 * size.width;
	bytesPerRow = COMPUTE_BEST_BYTES_PER_ROW(bytesPerRow);
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);

	CGContextRef cgContext = CGBitmapContextCreate(NULL,
		size.width,
		size.height,
		8, // bitsPerComponent
		bytesPerRow,
		colorSpace,
		kCGImageAlphaPremultipliedFirst);

	CGColorSpaceRelease(colorSpace);
	CGContextClearRect(cgContext, CGRectMake(0, 0, size.width, size.height));
	return cgContext;
}

- (void)_createImageFromFocusContext
{
	_imageRef = NSMakeCollectable(CGBitmapContextCreateImage(_focusContext));
	NSAssert(_imageRef != nil, @"got no image from CGImageCreate()");
}

- (void)lockFocus
{
	_focusContext = [self _createFocusContextWithSize: _pixelSize];
	NSGraphicsContext* nsContext = [NSGraphicsContext graphicsContextWithGraphicsPort: _focusContext flipped: _flipped];
	_oldContext = [NSGraphicsContext currentContext];
	[NSGraphicsContext setCurrentContext: nsContext];
}

- (void)unlockFocus
{
	[self _createImageFromFocusContext];
	[NSGraphicsContext setCurrentContext: _oldContext];
	CGContextRelease(_focusContext);
	_focusContext = nil;
	_oldContext = nil;
}

- (void)drawInRect:(NSRect)dstRect
{
	CGRect rect = *(CGRect*)&dstRect;
	CGContextRef c = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextDrawImage (c, rect, self.imageRef);
}

- (void)tileWithRect:(NSRect)tileRect
{
	CGRect rect = *(CGRect*)&tileRect;
	CGContextRef c = [[NSGraphicsContext currentContext] graphicsPort]; 
    CGContextDrawTiledImage (c, rect, self.imageRef);
}

- (CIImage *)CIImageWithSize: (NSSize)size
{
	NSSize pixelSize = [self pixelSize];
	CIImage* image = self.cachedCIImage;
	CGAffineTransform transform = CGAffineTransformMakeScale(size.width/pixelSize.width, size.height/pixelSize.height);
	image = [image imageByApplyingTransform: transform];
	return image;
}

- (BOOL)isVector
{
	return NO;
}

- (BOOL)pointIsInside: (NSPoint)point
{
	CGImageRef image = self.imageRef;
	CGImageAlphaInfo alpha = CGImageGetAlphaInfo(image);
	NSColor *color = nil;
	if (alpha != kCGImageAlphaNone) {
		NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithCGImage: image];
		color = [rep colorAtX: point.x y: point.y];
	}
	return color == nil || [color alphaComponent] > .05;
}	

- (NSString*)description
{
	return [NSString stringWithFormat: @"_imageRef: %p, _url: %@", _imageRef, _url];
}

@end
