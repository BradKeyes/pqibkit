//
//  CIImage+PQAdditions.m
//  Comic Life
//
//  Created by Airy ANDRE on 07/12/07.
//  Copyright 2007 plasq LLC. All rights reserved.
//

#import "CIImage+PQAdditions.h"
#import "PQMirrorFilter.h"
#import <QuartzCore/QuartzCore.h>

@implementation CIImage (PQAdditions)
- (CIImage *)imageWithInfiniteExtent
{
	CIFilter *extendFilter = [[PQMirrorFilter alloc] init];
	[extendFilter setDefaults];
	[extendFilter setValue: self forKey:@"inputImage"];
	return [extendFilter valueForKey: @"outputImage"];
}

- (CIImage *)imageWithAffineClamp
{
	CIFilter *extendFilter = [CIFilter filterWithName:@"CIAffineClamp"];
	[extendFilter setDefaults];
	[extendFilter setValue:[NSAffineTransform transform] forKey:@"inputTransform"];
	[extendFilter setValue: self forKey: @"inputImage"];
	return [extendFilter valueForKey: @"outputImage"];
}

@end
