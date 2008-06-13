//
//  PQImage.m
//  PQImage
//
//  Created by Robert Grant on 6/14/07.
//  Copyright 2007 plasq LLC. All rights reserved.
//


#import <QuartzCore/CIImage.h>
#import <QuartzCore/CIFilter.h>
#import <QuartzCore/CIContext.h>
#import "PQImage.h"
#import "PQCGImageRep.h"
#import "PQPDFImageRep.h"
#import "PQMagiqImageRep.h"

@implementation PQImage

@synthesize flipped = _flipped;
@synthesize size	= _size;
@synthesize imageRep	= _imageRep;

/*
 * Returns image with the given name. Pass it an image name without an
 * extension (i.e. for file 'foo.tiff', pass @"foo" as the
 * name). Common image file suffixes will be tried.
 */
+ (PQImage*)imageNamed: (NSString*)name
{
	NSString* path = nil;
   
	for (NSString* extension in [NSArray arrayWithObjects: @"jpeg", @"jpg", @"gif", @"png", @"tiff", @"magiq", nil]) {
		path = [[NSBundle mainBundle] pathForResource: name ofType: extension];
		if (path) {
			NSURL* url = [NSURL fileURLWithPath: path];
			return [[PQImage alloc] initWithContentsOfURL: url]; 
		}
	}
	return nil;
}

/* Reads PICT data from 'pictURL', converts it to PDF, and writes the result to 'pdfURL' */
+ (void)convertPICTResource: (NSURL*)pictURL toPDF: (NSURL*)pdfURL
{
    CGContextRef context = NULL;

	QDPictRef pict = QDPictCreateWithURL((CFURLRef)pictURL);
    CGRect bounds = QDPictGetBounds(pict);

    bounds.origin.x = 0;
    bounds.origin.y = 0;

    context = CGPDFContextCreateWithURL((CFURLRef)pdfURL, &bounds, NULL);

    if (context != NULL) {
        CGContextBeginPage(context, &bounds);
        QDPictDrawToCGContext(context, bounds, pict);
        CGContextEndPage(context);
        CGContextRelease(context);
    }
}

- (id)_imageRepFactoryForURL: (NSURL*)url
{
	NSString* extension = url.absoluteString.pathExtension;

	if ([extension isEqualTo: @"pdf"]) 
		return [PQPDFImageRep class];
	else if ([extension isEqualTo: @"magiq"]) 
		return [PQMagiqImageRep class];
	else
		return [PQCGImageRep class];
}

// Defers loading the contents of the image until the image data is needed
- (id)initByReferencingURL:(NSURL *)url
{
	if (self = [super init]) {
		id imageRepFactory = [self _imageRepFactoryForURL: url];
		_imageRep = [[imageRepFactory alloc] initByReferencingURL: url];
		_size = [_imageRep pointSize];
	}
	return self;
}

// Immediately loads the contents on the image into memory
- (id)initWithContentsOfURL: (NSURL *)url
{
	if (self = [self init]) {
		id imageRepFactory = [self _imageRepFactoryForURL: url];
		_imageRep = [[imageRepFactory alloc] initWithContentsOfURL: url];
		_size = [_imageRep pointSize];
	}
	return self;
}

- (id)initWithContentsOfFile: (NSString *)file
{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@", [file stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	return [self initWithContentsOfURL:url];
}

- (id)initWithSize: (NSSize)size
{
	if (self = [super init]) {
		_size = size;
	}
	return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
	self = [super init];
	if (self) {
		_imageRep = [coder decodeObjectForKey: @"_imageRep"];
		_flipped = [coder decodeBoolForKey: @"_flipped"];
		_size = [coder decodeSizeForKey: @"_size"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
	[coder encodeObject: _imageRep forKey: @"_imageRep"];
	[coder encodeBool: _flipped forKey: @"_flipped"];
	[coder encodeSize: _size forKey: @"_size"];
}

- (void)finalize
{
// Clear out the images
	_imageRep = nil;

	[super finalize];
}

- (CGImageRef)CGImage
{
	if ([_imageRep isKindOfClass: [PQCGImageRep class]]) 
		return [(PQCGImageRep*)_imageRep imageRef];
	else
		return NULL;
}

- (void)lockFocus
{
#if 1
	PQCGImageRep* rep = [[PQCGImageRep alloc] initWithSize: _size flipped: _flipped];
#else
	PQCGLayerRep* rep = [[PQCGLayerRep alloc] initWithSize: _size flipped: _flipped];
#endif
	_imageRep = rep;
	[rep lockFocus];
	if (_flipped) {
		// Position the origin at the top left
		CGContextRef c = [[NSGraphicsContext currentContext] graphicsPort]; 
		CGContextTranslateCTM(c, 0, _size.height);
		CGContextScaleCTM(c, 1, -1);
	}
}

- (void)unlockFocus
{
#if 1
	[(PQCGImageRep*)_imageRep unlockFocus];
#else
	[(PQCGLayerRep*)_imageRep unlockFocus];
#endif
}


// map between Cocoa and Quartz compositing modes
- (CGBlendMode)_compositeOperationToBlendMode: (NSCompositingOperation)op
{
	CGBlendMode mode = kCGBlendModeNormal;
	switch (op) {
		case NSCompositeClear:
			mode = kCGBlendModeClear;
			break;
		case NSCompositeCopy:
			mode = kCGBlendModeCopy;
			break;
		case NSCompositeSourceOver:
			mode = kCGBlendModeNormal;
			break;
		case NSCompositeSourceIn:
			mode = kCGBlendModeSourceIn;
			break;
		case NSCompositeSourceOut:
			mode = kCGBlendModeSourceOut;
			break;
		case NSCompositeSourceAtop:
			mode = kCGBlendModeSourceAtop;
			break;
		case NSCompositeDestinationOver:
			mode = kCGBlendModeDestinationOver;
			break;
		case NSCompositeDestinationIn:
			mode = kCGBlendModeDestinationIn;
			break;
		case NSCompositeDestinationOut:
			mode = kCGBlendModeDestinationOut;
			break;
		case NSCompositeDestinationAtop:
			mode = kCGBlendModeDestinationAtop;
			break;
		case NSCompositeXOR:
			mode = kCGBlendModeXOR;
			break;
		case NSCompositePlusDarker:
			mode = kCGBlendModePlusDarker;
			break;
		case NSCompositeHighlight:
			mode = kCGBlendModeNormal;
			break;
		case NSCompositePlusLighter:
			mode = kCGBlendModePlusLighter;
			break;
	}
	return mode;
}

- (void)_configureContextForOperation: (NSCompositingOperation)op withFraction: (float) delta forRect: (NSRect)rect
{
	// need to do some CGContext tweaking
	CGContextRef c = [[NSGraphicsContext currentContext] graphicsPort]; 
	if (_flipped) {
		CGContextTranslateCTM(c, NSMinX(rect), NSMaxY(rect));
		CGContextScaleCTM(c, 1, -1);
	}
	// Make sure we draw the image at the desired offset
	CGContextTranslateCTM(c, -rect.origin.x, -rect.origin.y);

	// Apply the requested blend mode
	CGBlendMode mode = [self _compositeOperationToBlendMode: op];
	CGContextSetBlendMode(c, mode);
    
	// Apply the requested alpha transparency
	CGContextSetAlpha(c, delta);
}

- (void)drawInRect:(NSRect)dstRect operation:(NSCompositingOperation)op fraction:(CGFloat)delta
{
	
	// need to do some CGContext tweaking
	CGContextRef c = [[NSGraphicsContext currentContext] graphicsPort]; 
	
    // We're going to fiddle with the Graphics Context so save it first
	CGContextSaveGState(c);
	
	// Set up the blend mode, alpha etc.
	[self _configureContextForOperation: op withFraction: delta forRect: dstRect];
	[_imageRep drawInRect: dstRect];
    
	// restore the graphics state
	CGContextRestoreGState(c);
}

- (void)drawPopOutInRect:(NSRect)dstRect operation:(NSCompositingOperation)op fraction:(CGFloat)delta
{
	
	// need to do some CGContext tweaking
	CGContextRef c = [[NSGraphicsContext currentContext] graphicsPort]; 
	
    // We're going to fiddle with the Graphics Context so save it first
	CGContextSaveGState(c);
	
	// Set up the blend mode, alpha etc.
	[self _configureContextForOperation: op withFraction: delta forRect: dstRect];
	[_imageRep drawPopOutInRect: dstRect];
    
	// restore the graphics state
	CGContextRestoreGState(c);
}

- (void)tileWithRect:(NSRect)dstRect operation:(NSCompositingOperation)op fraction:(CGFloat)delta
{
    
	// need to do some CGContext tweaking
	CGContextRef c = [[NSGraphicsContext currentContext] graphicsPort]; 

    // We're going to fiddle with the Graphics Context so save it first
	CGContextSaveGState(c);

	// Set up the blend mode, alpha etc.
	[self _configureContextForOperation: op withFraction: delta forRect: dstRect];
        
    [_imageRep tileWithRect: dstRect];
    
	// restore the graphics state
	[[NSGraphicsContext currentContext] restoreGraphicsState];
}

- (NSImage *)nsImageWithSize:(NSSize)size
{
	NSRect rect = NSZeroRect;
	rect.size = size;
	NSImage* image = [[NSImage alloc] initWithSize: size];
	// Make sure the image understands the coordinate system coming in
	[image setFlipped: _flipped];
	[image lockFocus];
	[self drawInRect: rect operation: NSCompositeSourceOver fraction: 1];
	[image unlockFocus];
	return image;
}

- (NSImage *)nsImage
{
	return [self nsImageWithSize: _size];
}

- (CIImage *)CIImageWithSize:(NSSize)size
{
	size.width = ceilf(size.width);
	size.height = ceilf(size.height);
	return [_imageRep CIImageWithSize: size];
}

- (CIImage *)CIPopOutImageWithSize:(NSSize)size
{
	size.width = ceilf(size.width);
	size.height = ceilf(size.height);
	return [_imageRep CIPopOutImageWithSize: size];
}

- (NSString*)description
{
	return [NSString stringWithFormat: @"_size: %@ _imageRep: %@", NSStringFromSize(_size), _imageRep];
}

- (PQImage*)colorizeWithColor:(NSColor*)color
{
	NSRect colorizeRect = NSZeroRect;
	colorizeRect.origin = NSZeroPoint;
	colorizeRect.size = self.size;
	PQImage* colorizedImage = [[PQImage alloc] initWithSize: colorizeRect.size];
	[colorizedImage setFlipped: [self flipped]];
	[colorizedImage lockFocus];
	// Fill with the colorizing color
	[[color colorWithAlphaComponent: .5] set];
	NSRectFill(colorizeRect);
	[self drawInRect: colorizeRect operation: NSCompositePlusDarker fraction: 1];
	[self drawInRect: colorizeRect operation: NSCompositeDestinationIn fraction: 1];
	[colorizedImage unlockFocus];
	return colorizedImage;
}

- (BOOL)isVector
{
	return [_imageRep isVector];
}


- (BOOL)canPopOut
{
	return [_imageRep canPopOut];
}

- (void)setWantsPopOut: (BOOL)popOut
{
	[_imageRep setWantsPopOut: popOut];
}

- (BOOL)wantsPopOut
{
	return [_imageRep wantsPopOut];
}

/** Returns TRUE if the file or url looks like an image */
+ (BOOL)isImageFile:(NSString*)file
{
	NSArray* supportedTypes = [NSImage imageFileTypes];
	BOOL imageFile = [supportedTypes containsObject:[file pathExtension]] ||
		[supportedTypes containsObject:NSHFSTypeOfFile(file)];
	return imageFile;
}

+ (BOOL)isImageURL:(NSURL*)url
{
	NSArray* supportedTypes = [NSImage imageFileTypes];
	NSString* path = [url path];
	
	BOOL imageFile = [supportedTypes containsObject:[path pathExtension]];
	if (imageFile == NO) {
		if ([url isFileURL]) {
			// We can only pass real paths to NSHFSTypeOfFile()
			imageFile = [supportedTypes containsObject:NSHFSTypeOfFile(path)];
		}
	}
	return imageFile;
}


@end
