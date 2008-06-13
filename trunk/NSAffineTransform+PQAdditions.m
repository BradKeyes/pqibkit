//
//  NSAffineTransform+PQAdditions.m
//  Comic Life
//
//  Created by Robert Grant on 6/25/07.
//  Copyright 2007 plasq LLC. All rights reserved.
//

#import "NSAffineTransform+PQAdditions.h"


@implementation NSAffineTransform (PQAdditions)

#pragma mark Common Transforms

/* Creates a transform that transforms a rect to another rect */
+ (NSAffineTransform*)transformFromRect: (NSRect)from toRect: (NSRect)to
{
	NSAffineTransform* transform = [NSAffineTransform transform];
	NSAffineTransform* translateIn = [NSAffineTransform transform];
	NSAffineTransform* scale = [NSAffineTransform transform];
	NSAffineTransform* translateOut = [NSAffineTransform transform];
	[translateIn translateXBy: -from.origin.x yBy: -from.origin.y];
	[scale scaleXBy: to.size.width/from.size.width yBy: to.size.height/from.size.height];
	[translateOut translateXBy: to.origin.x yBy: to.origin.y];
	[transform appendTransform: translateIn];
	[transform appendTransform: scale];
	[transform appendTransform: translateOut];
	return transform;
}

/* Creates a transform that scales around a particular point */
+ (NSAffineTransform*)transformToScaleXBy:(float)deltaX yBy:(float)deltaY aroundPoint:(NSPoint)point
{
	NSAffineTransform* transform = [NSAffineTransform transform];
	NSAffineTransform* translateIn = [NSAffineTransform transform];
	NSAffineTransform* scale = [NSAffineTransform transform];
	NSAffineTransform* translateOut = [NSAffineTransform transform];
	[translateIn translateXBy: -point.x yBy: -point.y];
	[scale scaleXBy: deltaX yBy: deltaY];
	[translateOut translateXBy: point.x yBy: point.y];
	[transform appendTransform: translateIn];
	[transform appendTransform: scale];
	[transform appendTransform: translateOut];
	return transform;
}

/* Creates a transform the rotates around a particular point */
+ (NSAffineTransform*)transformToRotateByDegrees:(float)angle aroundPoint:(NSPoint)point
{
	NSAffineTransform* transform = [NSAffineTransform transform];
	NSAffineTransform* translateIn = [NSAffineTransform transform];
	NSAffineTransform* rotate = [NSAffineTransform transform];
	NSAffineTransform* translateOut = [NSAffineTransform transform];
	[translateIn translateXBy: -point.x yBy: -point.y];
	[rotate rotateByDegrees: angle];
	[translateOut translateXBy: point.x yBy: point.y];
	[transform appendTransform: translateIn];
	[transform appendTransform: rotate];
	[transform appendTransform: translateOut];
	return transform;
}

/*
 * This method applies the specified transform to the top left and bottom
 * right midpoints of the specified rect, and then makes a new rect that uses
 * the transformed values as its top left and bottom right corners, and
 * returns it
 */
- (NSRect)transformRect: (NSRect)rect
{
	NSPoint left = NSMakePoint(NSMinX(rect), NSMidY(rect));
	NSPoint right = NSMakePoint(NSMaxX(rect), NSMidY(rect));
	NSPoint top = NSMakePoint(NSMidX(rect), NSMinY(rect));
	NSPoint bottom = NSMakePoint(NSMidX(rect), NSMaxY(rect));
	left = [self transformPoint: left];
	right = [self transformPoint: right];
	top = [self transformPoint: top];
	bottom = [self transformPoint: bottom];
	return NSMakeRect(left.x, top.y, right.x - left.x, bottom.y - top.y);
}

/* Dumps transform matrix to NSLog */
- (void)dump
{
	NSAffineTransformStruct ts;
	ts = [self transformStruct];
	NSLog(@"transform dump:");
	NSLog(@"m11: %f m12: %f", ts.m11, ts.m12);
	NSLog(@"m21: %f m22: %f", ts.m21, ts.m22);
	NSLog(@"tX: %f tY: %f", ts.tX, ts.tY);
}

@end
