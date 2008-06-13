//
//  PQPDFImageRep.m
//  Comic Life
//
//  Created by Robert Grant on 9/6/07.
//  Copyright 2007 plasq LLC. All rights reserved.
//

#import "PQPDFImageRep.h"
#import "PQImage.h"

@implementation PQPDFImageRep

@synthesize url = _url;

#pragma mark Cache filling
// Read the image off disk -- Quartz book chapter 13 -- and cache it
- (id)_loadImage
{
	CGDataProviderRef dataProvider = NULL;
	
	dataProvider = CGDataProviderCreateWithURL((CFURLRef)self.url);
	
	if (dataProvider == NULL) {
		NSLog(@"Couldn't create data provider");
		return nil;
	}
	
	id docRef = NSMakeCollectable(CGPDFDocumentCreateWithProvider(dataProvider));
	CGDataProviderRelease(dataProvider);
	
	if (docRef == nil) {
		NSLog(@"Couldn't create PDF document from data provider");
		return nil;
	}
	
	CGPDFPageRef page = CGPDFDocumentGetPage((CGPDFDocumentRef)docRef, 1);
	CGRect rect = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
	_pixelSize = NSSizeFromCGSize(rect.size);
	// Update our cache with that
	self.docRef = (CGPDFDocumentRef)docRef;
	
	return docRef;
}

#pragma mark Setter and getter for our caches access
- (CGPDFDocumentRef)docRef
{
	id obj = [[PQImageRep imagesCache] objectForKey: _url];
	if (!obj) {
		obj = [self _loadImage];
	}
	return (CGPDFDocumentRef)obj;
}

- (void)setDocRef: (CGPDFDocumentRef)docRef
{
	if (docRef == nil) {
		[[PQImageRep imagesCache] removeObjectForKey: _url];
	} else {
		[[PQImageRep imagesCache] setObject: (id)docRef forKey: _url];
	}
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

- (NSSize)pixelSize
{
	if (_pixelSize.width == 0.f && _pixelSize.height == 0.f) {
		[self _loadImage];
	}
	return _pixelSize;
}

- (NSSize)pointSize
{
	return [self pixelSize];
}

/*
 * NSCoding support -- we just decode the _url and (re)load the image.
 * We trust this will intialize all other ivars appropriately.
 *
 * Note that it assumes the resource identified by URL still exists,
 * which works because we've spooled everything to our temp cache.
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

/*
 * Quartz book chapter 13. Sure, there's
 * CGPDFPageGetDrawingTransform(), but it won't scale *up*, only
 * down. I've modified the code from the good book to use PDFPage
 * rather than deprecated PDFDocument functions.
 */
CGAffineTransform pdfPageGetDrawingTransform(CGPDFPageRef pdfPage, 
					CGPDFBox boxType, CGRect destRect,
					int rotate, bool  preserveAspectRatio)
{
    CGAffineTransform fullTransform, rTransform, sTransform, t1Transform, t2Transform;
    float boxOriginX, boxOriginY, boxWidth, boxHeight;
    float destOriginX, destOriginY, destWidth, destHeight;
    float scaleX, scaleY;

    // First intersect the boundary rectangle of boxType with the media box. This is
    // to conform with the meaning of a given boundary rectangle in the PDF spec.
    CGRect boxRect = CGPDFPageGetBoxRect(pdfPage, boxType);
    if(boxType != kCGPDFMediaBox){
		CGRect mediaBox = CGPDFPageGetBoxRect(pdfPage, kCGPDFMediaBox);
		boxRect = CGRectIntersection(boxRect, mediaBox);
    }
    
    // Obtain the origin, width and height of the PDF box to transform.
    boxOriginX = CGRectGetMinX(boxRect);
    boxOriginY = CGRectGetMinY(boxRect);
    boxWidth = CGRectGetWidth(boxRect);
    boxHeight = CGRectGetHeight(boxRect);

    // Construct a transformation that translates the center of the box
    // to the origin.
    t1Transform = CGAffineTransformMakeTranslation( -(boxOriginX + boxWidth/2), 
						-(boxOriginY + boxHeight/2) );

    // Add the intrinsic page rotation to the rotation requested.
    rotate += CGPDFPageGetRotationAngle(pdfPage);
    // Adjust the page rotation angle to ensure that it is between 0-360 degrees.
    rotate %= 360;
    if (rotate < 0)
	rotate += 360;
    
    // Construct a transformation that rotates by the rotation angle. Since a positive
    // requested rotation is clockwise and Quartz considers clockwise rotations to be
    // negative angles, this code negates the rotation angle when creating the rotation
    // matrix.
    rTransform = CGAffineTransformMakeRotation(-rotate * (M_PI/180));
        
    // If the rotation is +90 or -90 degrees then the rotation 
    // interchanges the width and height.
    if(rotate == 90 || rotate == 270){
	float tmp = boxWidth;
	boxWidth = boxHeight;
	boxHeight = tmp;
    }

    // Obtain the origin, width and height of the destination rect.
    destOriginX = CGRectGetMinX(destRect);
    destOriginY = CGRectGetMinY(destRect);
    destWidth = CGRectGetWidth(destRect);
    destHeight = CGRectGetHeight(destRect);

    // This computes x and y scaling factors to scale the box dimensions
    // into the destination dimensions. Using the MIN function in
    // this manner ensures that the minimum scaling will be 1. This
    // makes sure that the box is never scaled up to fit, only down.

    scaleX = destWidth/boxWidth;
    scaleY = destHeight/boxHeight;
    
    // If there is a request to preserve the aspect ratio then the scale factors
    // must be the same and in order to ensure that both dimensions fit 
    // in the destination, the minimum scaling must be used.
    if(preserveAspectRatio){
		scaleX = scaleY = MIN(scaleX, scaleY);
    }

    // Construct an affine transform that represents this scaling.
    sTransform = CGAffineTransformMakeScale(scaleX, scaleY);

    // Now construct a transform that transforms the origin to the center
    // of destRect.
    t2Transform = CGAffineTransformMakeTranslation( destOriginX + destWidth/2, 
							destOriginY + destHeight/2);

    // Concatenate translation with the rotation. This is 
    // (t1Transform x rTransform). 
    fullTransform = CGAffineTransformConcat(t1Transform, rTransform);

    // Concatenate the previous result with the scaling, that is 
    // (t x sTransform). In this case t is the result of the previous 
    // calculations and sTransform is the scaling matrix just created.

    fullTransform = CGAffineTransformConcat(fullTransform, sTransform);

    // Concatenate the previous result with translation 2, that is 
    // (t x t2Transform). In this case t is the result of the previous 
    // calculations and t2Transform is the translation matrix just created.
    fullTransform = CGAffineTransformConcat(fullTransform, t2Transform);
    
    return fullTransform;
}

/*
 * Draws the PDF (specifically the 1st page, within its crop
 * box). This code also largely from the Quartz book.
 */
- (void)drawInRect:(NSRect)dstRect
{
	CGContextRef c = [[NSGraphicsContext currentContext] graphicsPort]; 

	// Use first page of document
	CGPDFPageRef pdfPage = CGPDFDocumentGetPage(self.docRef, 1);


	// Scale the crop box to the dstRect
	CGAffineTransform t = pdfPageGetDrawingTransform(pdfPage, kCGPDFCropBox, NSRectToCGRect(dstRect), 0, NO);

	CGContextSaveGState(c);

	CGContextConcatCTM(c, t);

	// Clip to intersection of cropBox and mediaBox
	CGRect cropRect = CGPDFPageGetBoxRect(pdfPage, kCGPDFCropBox);
	CGRect mediaBox = CGPDFPageGetBoxRect(pdfPage, kCGPDFMediaBox);
	CGRect clipRect = CGRectIntersection(cropRect, mediaBox);
	CGContextClipToRect(c, clipRect);

	// Do the drawing
    CGContextDrawPDFPage(c, pdfPage);

	CGContextRestoreGState(c);
}

- (void)tileWithRect:(NSRect)tileRect
{
	NSAssert(0, @"no tiling");
}

- (CIImage *)CIImageWithSize: (NSSize)size
{
	return nil;
}

- (BOOL)pointIsInside: (NSPoint)point
{
	NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData: [[[NSImage alloc] initWithContentsOfURL: self.url] TIFFRepresentation]];
	NSColor *color = [rep colorAtX: point.x y: point.y];
	return color == nil || [color alphaComponent] > .05;
}	


- (BOOL)isVector
{
	return YES;
}

- (NSString*)description
{
	return [NSString stringWithFormat: @"PQPDFImageRep docRef: %p _url: %@", self.docRef, _url];
}

@end
