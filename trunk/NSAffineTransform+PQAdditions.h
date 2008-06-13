/**
 * \file NSAffineTransform+PQAdditions.h
 *
 * Copyright plasq LLC 2007. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

/**
 * Category for implementing Plasq extensions
 *
 * \ingroup AppKitCategories
 */
@interface NSAffineTransform (PQAdditions)

#pragma mark Common Transforms

/** Creates a transform that scales around a particular point */
+ (NSAffineTransform*)transformToScaleXBy:(float)delta yBy:(float)deltaY aroundPoint:(NSPoint)point;

/** Creates a transform the rotates around a particular point */
+ (NSAffineTransform*)transformToRotateByDegrees:(float)angle aroundPoint:(NSPoint)point;

/**
 * This method applies the specified transform to the top left and bottom
 * right midpoints of the specified rect, and then makes a new rect that uses
 * the transformed values as its top left and bottom right corners, and
 * returns it
 */
- (NSRect)transformRect: (NSRect)rect;
+ (NSAffineTransform*)transformFromRect: (NSRect)from toRect: (NSRect)to;

/** Dumps transform matrix to NSLog */
- (void)dump;

@end
