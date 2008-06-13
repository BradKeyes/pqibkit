//
//  PQMagiqImageRep.m
//  Comic Life
//
//  Created by Airy ANDRE on 15/11/07.
//  Copyright 2007 plasq LLC. All rights reserved.
//

#import "PQMagiqImageRep.h"
#import "NSAffineTransform+PQAdditions.h"
#import "NSScreen+PQAdditions.h"
#import <QuartzCore/QuartzCore.h>

@implementation PQMagiqImageRep

static NSString *kMagiqSettingsFilename = @"magiq.dat";

static NSString *kMagiqSourceKey = @"source";
static NSString *kMagiqResultKey = @"result";

@synthesize url = _url;
@synthesize extent = _extent;

- (NSURL *)settingsURL
{
	NSString *path = [[self.url path] stringByAppendingPathComponent: kMagiqSettingsFilename];
	return [NSURL fileURLWithPath: path];
}

- (NSURL *)sourceURL
{
	// NOTE: this will have to be changed if Magiq file format changes
	// Just read the key giving the filename for the source image
	NSData *data = [[NSData alloc] initWithContentsOfURL: self.settingsURL];
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData: data];
	NSString *path = [[self.url path] stringByAppendingPathComponent: [unarchiver decodeObjectForKey: kMagiqSourceKey]];
	return [NSURL fileURLWithPath: path];	
}

- (NSURL *)resultURL
{
	// NOTE: this will have to be changed if Magiq file format changes
	// Just read the key giving the filename for the result image
	NSData *data = [[NSData alloc] initWithContentsOfURL: self.settingsURL];
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData: data];
	NSString *path = [[self.url path] stringByAppendingPathComponent: [unarchiver decodeObjectForKey: kMagiqResultKey]];
	return [NSURL fileURLWithPath: path];	
}

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

#pragma Cache filling
// Build the images and fill the cache
- (id)_loadImage
{
	CGImageSourceRef source = self.imageSource;
	id imageRef = nil;
	if (source) {
		imageRef  = NSMakeCollectable(CGImageSourceCreateImageAtIndex(source, 0, nil));
		if (imageRef) {
			_pixelSize.width = CGImageGetWidth((CGImageRef)imageRef);
			_pixelSize.height = CGImageGetHeight((CGImageRef)imageRef);
			// Update our cache with that
			self.imageRef = (CGImageRef)imageRef;
		}
	}
	return imageRef;
}

- (id)_loadOriginalImage
{
	CGImageSourceRef source = self.originalImageSource;
	id imageRef = nil;
	if (source) {
		imageRef  = NSMakeCollectable(CGImageSourceCreateImageAtIndex(source, 0, nil));
		// Update our cache with that
		self.originalImageRef = (CGImageRef)imageRef;
		[self _setDPIFromSource: source];
	}
	return imageRef;
}

- (id)_loadCIImage
{
	CIImage *cachedCIImage = [CIImage imageWithCGImage: self.imageRef];
	// Update our cache with that
	self.cachedCIImage = cachedCIImage;
	return cachedCIImage;
}

- (id)_loadOriginalCIImage
{
	CIImage *cachedCIImage = [[CIImage imageWithCGImage: self.originalImageRef] imageByCroppingToRect: NSRectToCGRect(self.extent)];
	CGAffineTransform translate = CGAffineTransformMakeTranslation(-self.extent.origin.x, -self.extent.origin.y);
	cachedCIImage = [cachedCIImage imageByApplyingTransform: translate];
	// Compose with the pop-out
	CIFilter *compositing = [CIFilter filterWithName: @"CISourceOverCompositing"];
	[compositing setValue: [self CIPopOutImageWithSize: [self pixelSize]] forKey: kCIInputImageKey];
	[compositing setValue: cachedCIImage forKey: kCIInputBackgroundImageKey];
	cachedCIImage = [compositing valueForKey: kCIOutputImageKey];
	// Update our cache with that
	self.cachedOriginalCIImage = cachedCIImage;
	return cachedCIImage;
}

- (id)_loadImageSource
{
	id source = NSMakeCollectable(CGImageSourceCreateWithURL((CFURLRef)self.resultURL, nil));
	// Update our cache with that
	self.imageSource = (CGImageSourceRef)source;
	return source;
}

- (id)_loadOriginalImageSource
{
	id source = NSMakeCollectable(CGImageSourceCreateWithURL((CFURLRef)self.sourceURL, nil));
	// Update our cache with that
	self.originalImageSource = (CGImageSourceRef)source;
	return source;
}

#pragma mark Setter and getter for our caches access
- (CGImageRef)imageRef
{
	id obj = [[PQImageRep imagesCache] objectForKey: self.url];
	if (!obj) {
		obj = [self _loadImage];
	}
	return (CGImageRef)obj;
}

- (void)setImageRef: (CGImageRef)imageRef
{
	if (imageRef == nil) {
		[[PQImageRep imagesCache] removeObjectForKey: self.url];
	} else {
		[[PQImageRep imagesCache] setObject: (id)imageRef forKey: self.url];
	}
}

- (CGImageRef)originalImageRef
{
	id obj = [[PQImageRep imagesCache] objectForKey: self.sourceURL];
	if (!obj) {
		obj = [self _loadOriginalImage];
	}
	return (CGImageRef)obj;
}

- (void)setOriginalImageRef: (CGImageRef)imageRef
{
	if (imageRef == nil) {
		[[PQImageRep imagesCache] removeObjectForKey: self.sourceURL];
	} else {
		[[PQImageRep imagesCache] setObject: (id)imageRef forKey: self.sourceURL];
	}
}

- (void)setCachedCIImage: (CIImage *)image
{
	// Use the URL path as the key for cached CIImage, as the url is already used to cache the CGImageRef
	if (image == nil) {
		[[PQImageRep imagesCache] removeObjectForKey: [self.url path]];
	} else {
		[[PQImageRep imagesCache] setObject: image forKey: [self.url path]];
	}
}

- (CIImage *)cachedCIImage
{
	// Use the URL path as the key for cached CIImage, as the url is already used to cache the CGImageRef
	id cachedCIImage = [[PQImageRep imagesCache] objectForKey: [self.url path]];
	if (!cachedCIImage) {
		cachedCIImage = [self _loadCIImage];
	}
	return cachedCIImage;
}

- (void)setCachedOriginalCIImage: (CIImage *)image
{
	// Use the URL path as the key for cached CIImage, as the url is already used to cache the CGImageRef
	if (image == nil) {
		[[PQImageRep imagesCache] removeObjectForKey: [self.sourceURL path]];
	} else {
		[[PQImageRep imagesCache] setObject: image forKey: [self.sourceURL path]];
	}
}

- (CIImage *)cachedOriginalCIImage
{
	// Use the URL path as the key for cached CIImage, as the url is already used to cache the CGImageRef
	id cachedCIImage = [[PQImageRep imagesCache] objectForKey: [self.sourceURL path]];
	if (!cachedCIImage) {
		cachedCIImage = [self _loadOriginalCIImage];
	}
	return cachedCIImage;
}

- (void)setImageSource: (CGImageSourceRef)imageSource
{
	if (imageSource == nil) {
		[[PQImageRep imageSourcesCache] removeObjectForKey: self.url];
	} else {
		[[PQImageRep imageSourcesCache] setObject: (id)imageSource forKey: self.url];
	}
}

- (CGImageSourceRef)imageSource
{
	id res = [[PQImageRep imageSourcesCache] objectForKey: self.url];
	if (res == nil) {
		res = [self _loadImageSource];
	}
	return (CGImageSourceRef)res;
}

- (void)setOriginalImageSource: (CGImageSourceRef)imageSource
{
	if (imageSource == nil) {
		[[PQImageRep imageSourcesCache] removeObjectForKey: self.sourceURL];
	} else {
		[[PQImageRep imageSourcesCache] setObject: (id)imageSource forKey: self.sourceURL];
	}
}

- (CGImageSourceRef)originalImageSource
{
	id res = [[PQImageRep imageSourcesCache] objectForKey: self.sourceURL];
	if (res == nil) {
		res = [self _loadOriginalImageSource];
	}
	return (CGImageSourceRef)res;
}

- (BOOL)canPopOut
{
	return YES;
}

// Defers loading the contents of the image until the image data is needed
- (id)initByReferencingURL:(NSURL *)url
{
	if (self = [super init]) {
		self.url = url;
		// Load the extent for the cropped part of the image - this is needed to properly compose our result
		// image on its background for the pop-out effect
		// We could decode a full IFDocument and ask for its properties but that's going to be very inefficient
		// And that's allowing us to draw a PQImage referencing a Magiq document without having to include all
		// the Magiq source code
		NSData *data = [[NSData alloc] initWithContentsOfURL: self.settingsURL];
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData: data];	
		self.extent = [unarchiver decodeRectForKey: @"extent"];
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

- (NSSize)pixelSize
{
	if (_pixelSize.width == 0.f && _pixelSize.height == 0.f) {
		CGImageSourceRef source = self.imageSource;
		if (source) {
			CGImageRef imageRef  = CGImageSourceCreateImageAtIndex(source, 0, nil);
			if (imageRef) {
				_pixelSize.width = CGImageGetWidth(imageRef);
				_pixelSize.height = CGImageGetHeight(imageRef);
				CGImageRelease(imageRef);
			}
		}
		[self _setDPIFromSource: self.originalImageSource];
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

- (void)drawPopOutInRect:(NSRect)dstRect
{
	CGRect rect = *(CGRect*)&dstRect;
	CGContextRef c = [[NSGraphicsContext currentContext] graphicsPort]; 
    CGContextDrawImage (c, rect, self.imageRef);	
}

- (void)drawInRect:(NSRect)dstRect
{
	if (!self.wantsPopOut) {
		// If pop-up is disabled, then our pop-up image is our normal (result) image
		[self drawPopOutInRect: dstRect];
		return;
	}
	CGContextRef c = [[NSGraphicsContext currentContext] graphicsPort];
	// Offset/Resize and clip the original image size to the pop-up extent
	CGImageRef originalImageRef = self.originalImageRef;
	NSRect originalRect = NSMakeRect(0, 0, CGImageGetWidth(originalImageRef), CGImageGetHeight(originalImageRef));
	NSAffineTransform *transform = [NSAffineTransform transformFromRect: self.extent toRect: dstRect];
	originalRect = [transform transformRect: originalRect];

	CGContextSaveGState(c);
	CGContextClipToRect(c, NSRectToCGRect(dstRect));
    CGContextDrawImage (c, NSRectToCGRect(originalRect), self.originalImageRef);
    CGContextDrawImage (c, NSRectToCGRect(dstRect), self.imageRef);	
	CGContextRestoreGState(c);
}

- (void)tileWithRect:(NSRect)tileRect
{
	CGRect rect = *(CGRect*)&tileRect;
	CGContextRef c = [[NSGraphicsContext currentContext] graphicsPort]; 
    CGContextDrawTiledImage (c, rect, self.imageRef);
}

- (CIImage *)CIPopOutImageWithSize: (NSSize)size
{
	NSSize pixelSize = [self pixelSize];

	// Use an affine transform filter to resize the CIImage to the wanted size
	CIFilter *filter = [CIFilter filterWithName: @"CIAffineTransform"];
	[filter setDefaults];
	NSAffineTransform *transform = [NSAffineTransform transform];
	[transform scaleXBy:size.width/pixelSize.width yBy:size.height/pixelSize.height];
	[filter setValue: transform forKey: kCIInputTransformKey];
	[filter setValue: self.cachedCIImage forKey: kCIInputImageKey];
	CIImage* image = [filter valueForKey: kCIOutputImageKey];	
	return image;
}

- (CIImage *)CIImageWithSize: (NSSize)size
{
	if (!self.wantsPopOut) {
		// If pop-up is disabled, then our pop-up image is our normal (result) image
		return [self CIPopOutImageWithSize: size];
	}
		
	NSSize pixelSize = [self pixelSize];

	// Use an affine transform filter to resize the CIImage to the wanted size
	CIFilter *filter = [CIFilter filterWithName: @"CIAffineTransform"];
	[filter setDefaults];
	NSAffineTransform *transform = [NSAffineTransform transform];
	[transform scaleXBy:size.width/pixelSize.width yBy:size.height/pixelSize.height];
	[filter setValue: transform forKey: kCIInputTransformKey];
	[filter setValue: self.cachedOriginalCIImage forKey: kCIInputImageKey];
	CIImage* image = [filter valueForKey: kCIOutputImageKey];
	return image;
}

- (BOOL)isVector
{
	return NO;
}

- (BOOL)pointIsInside: (NSPoint)point
{
	CGImageRef image = self.wantsPopOut ? self.originalImageRef : self.imageRef;
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
	return [NSString stringWithFormat: @"<%@:%p: _url: %@>", [self class], self, _url];
}
@end
