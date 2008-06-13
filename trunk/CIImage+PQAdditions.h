//
//  CIImage+PQAdditions.h
//  Comic Life
//
//  Created by Airy ANDRE on 07/12/07.
//  Copyright 2007 plasq LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CIImage (PQAdditions)

/** 
 * Returns the image with an infinite extent, using a mirror filter
 */
- (CIImage *)imageWithInfiniteExtent;
- (CIImage *)imageWithAffineClamp;
@end
