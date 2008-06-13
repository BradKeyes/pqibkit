//
//  PQMirrorFilter.m
//  Comic Life
//
//  Created by Airy ANDRE on 22/11/07.
//  Copyright 2007 plasq LLC. All rights reserved.
//

#import "PQMirrorFilter.h"


@implementation PQMirrorFilter
static CIKernel *_kernel = nil;

// Register our filter name so we can find it by its name
+ (void)initialize
{
	[CIFilter registerFilterName: [self className]
					 constructor: self
				 classAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
								   @"Plasq Mirror", kCIAttributeFilterDisplayName,
								   [NSArray arrayWithObjects:
									kCICategoryStillImage,
									kCICategoryNonSquarePixels,nil], kCIAttributeFilterCategories,
								   nil]
	 ];
}

+ (CIFilter *)filterWithName: (NSString *)name
{
    CIFilter  *filter;
	
    filter = [[self alloc] init];
    return [filter autorelease];
}

- (id)init
{
    if(_kernel == nil)
    {
        NSBundle    *bundle = [NSBundle bundleForClass: [self class]];
        NSString    *code = [NSString stringWithContentsOfFile: [bundle
																 pathForResource: [self className]
																 ofType: @"cikernel"]];
        NSArray     *kernels = [CIKernel kernelsWithString: code];
		
        _kernel = [kernels objectAtIndex:0];
		
		// set up ROI calculation for the kernel
		[_kernel setROISelector:@selector(regionOf:destRect:userInfo:)];

    }
	
    return [super init];
}

- (NSDictionary *)customAttributes
{
    return [NSDictionary dictionary];
}

- (CGRect)regionOf: (int)sampler  destRect: (CGRect)dstRect  userInfo: (id)info
{
	// Stolen from Apple mirror filter used for PhotoBooth
	CGRect srcRect = inputImage.extent;
	if ((dstRect.size.width == 0.) || (dstRect.size.height == 0.))
		return CGRectZero;
	CGRect roiRect = dstRect;
	// Mod to get origin in the source image rect
	roiRect.origin.x = fmod((roiRect.origin.x - srcRect.origin.x),srcRect.size.width) + srcRect.origin.x;
	roiRect.origin.y = fmod((roiRect.origin.y - srcRect.origin.y),srcRect.size.height) + srcRect.origin.y;
	if (dstRect.origin.x < 0)
		roiRect.origin.x += srcRect.size.width;
	if (dstRect.origin.y < 0)
		roiRect.origin.y += srcRect.size. height;
	// If roiRect goes further than source image origin_x + width, adapt its origin_x and width
	if (roiRect.size.width > srcRect.size.width + srcRect.origin.x - roiRect.origin.x) {
		roiRect.size.width = srcRect.size.width + srcRect.origin.x - roiRect.origin.x;
		roiRect.origin.x = MAX(MIN (srcRect.size.width + srcRect.origin.x - (dstRect.size.width - roiRect.size.width), roiRect.origin.x), srcRect.origin.x);
		roiRect.size.width = srcRect.size.width + srcRect.origin.x- roiRect.origin.x;
	}
	// If roiRect goes further than source image origin_y + height, adapt its origin_y and height
	if (roiRect.size. height > srcRect.size. height + srcRect.origin.y - roiRect.origin.y){
		roiRect.size. height = srcRect.size. height + srcRect.origin.y - roiRect.origin.y;
		roiRect.origin.y = MAX(MIN (srcRect.size. height + srcRect.origin.y - (dstRect.size. height - roiRect.size. height), roiRect.origin.y), srcRect.origin.y);
		roiRect.size. height = srcRect.size. height + srcRect.origin.y - roiRect.origin.y;
	}
	// When the dstRect corresponds to mirrored region, mirror the roiRect
	if ((((int)fabs((dstRect.origin.x - srcRect.origin.x)/srcRect.size.width) % 2 >= 1) && (dstRect.origin.x >= 0.))|| (((int)fabs((dstRect.origin.x - srcRect.origin.x)/srcRect.size.width) % 2 < 1) && (dstRect.origin.x < 0.)))  {
		roiRect.origin.x = srcRect.size.width - (roiRect.origin.x - srcRect.origin.x) + srcRect.origin.x - roiRect.size.width;
	}
	if ((((int)fabs((dstRect.origin.y - srcRect.origin.y)/srcRect.size. height) % 2 >= 1) && (dstRect.origin.y >= 0.)) || (((int)fabs((dstRect.origin.y - srcRect.origin.y)/srcRect.size. height) % 2 < 1) && (dstRect.origin.y < 0.))) {
		roiRect.origin.y = srcRect.size. height - (roiRect.origin.y - srcRect.origin.y) + srcRect.origin.y - roiRect.size. height;
	}
	return roiRect;
}

- (CIImage *)outputImage
{
	if (inputImage == nil || CGRectIsInfinite(inputImage.extent)) {
		return inputImage; // No need to extend the input
	} else {
		CGRect extent = inputImage.extent;
	    CISampler *src = [CISampler samplerWithImage: inputImage];
		return [self apply: _kernel, src, [CIVector vectorWithX: extent.origin.x Y: extent.origin.y  Z:extent.size.width W: extent.size.height], 
				kCIApplyOptionDefinition, [CIFilterShape shapeWithRect: CGRectInfinite],
				nil];
	}
}
@end
