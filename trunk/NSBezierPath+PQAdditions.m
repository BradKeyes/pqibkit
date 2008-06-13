//
//  NSBezierPath+PQAdditions.m
//  Comic Life
//
//  Created by Airy ANDRE on 21/08/07.
//  Copyright 2007 plasq LLC. All rights reserved.
//

//#import <plasqPathKit/NSBezierPath+pqIntersect.h>
#import "NSBezierPath+PQAdditions.h"
#import "Util.h"
#import "GeomUtils.h"

@implementation NSBezierPath (PQAdditions)

#pragma mark Strings

/*
 * Returns a bezier path from the given string and font
 */
+ (NSBezierPath *) bezierPathFromString: (NSString *)string
                              forFont: (NSFont *)font
{
	if (string == nil)
		return nil;
	
    NSTextView *textview;
    textview = [[[NSTextView alloc] init] autorelease];
    [textview setString: string];
    if (font)
        [textview setFont: font];
    
    NSLayoutManager *layoutManager;
    layoutManager = [textview layoutManager];
    
    NSRange range;
    range = [layoutManager glyphRangeForCharacterRange:
             NSMakeRange (0, [string length])
                                  actualCharacterRange: NULL];
    NSGlyph glyphs[range.length * 2]; // Should be big enough
    [layoutManager getGlyphs: glyphs  range: range];
    
    NSBezierPath *path;
    path = [NSBezierPath bezierPath];
    
    [path moveToPoint: NSZeroPoint];
    [path appendBezierPathWithGlyphs: glyphs
                               count: range.length  inFont: font];
    
    return path;
    
}

- (void) appendBezierPathWithInsetRoundedRect:(NSRect)aRect radius:(float) radius
{
	radius = MIN(radius, (aRect.size.width/2 - 2));
	radius = MIN(radius, (aRect.size.height/2 - 2));
    NSPoint topMid = NSMakePoint(NSMidX(aRect), NSMaxY(aRect));
    NSPoint topLeft = NSMakePoint(NSMinX(aRect), NSMaxY(aRect));
    NSPoint topRight = NSMakePoint(NSMaxX(aRect), NSMaxY(aRect));
    NSPoint bottomRight = NSMakePoint(NSMaxX(aRect), NSMinY(aRect));
	NSPoint bottomLeft = NSMakePoint(NSMinX(aRect), NSMinY(aRect));
    [self moveToPoint:topMid];
    [self appendBezierPathWithArcWithCenter: topRight radius: radius startAngle: 180 endAngle: 270];
    [self appendBezierPathWithArcWithCenter: bottomRight radius: radius startAngle: 90 endAngle: 180];
    [self appendBezierPathWithArcWithCenter: bottomLeft radius: radius startAngle: 0 endAngle: 90];
    [self appendBezierPathWithArcWithCenter: topLeft radius: radius startAngle: 270 endAngle: 0];
    [self closePath];
}

+ (NSBezierPath*)bezierPathWithInsetRoundedRect:(NSRect)rect radius: (float)radius;
{
    NSBezierPath* path = [NSBezierPath bezierPath];

    [path appendBezierPathWithInsetRoundedRect: rect radius: radius];
    return path;
    
}

- (void) appendBezierPathWithBeveledRect:(NSRect)aRect radius:(float) radius
{
    NSPoint topMid = NSMakePoint(NSMidX(aRect), NSMinY(aRect));

	radius = MIN(radius, (aRect.size.width/2 - 2));
	radius = MIN(radius, (aRect.size.height/2 - 2));
	NSRect insetRect = NSInsetRect(aRect, radius, radius);

    [self moveToPoint:topMid];
	[self lineToPoint: NSMakePoint(NSMaxX(insetRect), NSMinY(aRect))];
	[self lineToPoint: NSMakePoint(NSMaxX(aRect), NSMinY(insetRect))];
	[self lineToPoint: NSMakePoint(NSMaxX(aRect), NSMaxY(insetRect))];
	[self lineToPoint: NSMakePoint(NSMaxX(insetRect), NSMaxY(aRect))];
	[self lineToPoint: NSMakePoint(NSMinX(insetRect), NSMaxY(aRect))];
	[self lineToPoint: NSMakePoint(NSMinX(aRect), NSMaxY(insetRect))];
	[self lineToPoint: NSMakePoint(NSMinX(aRect), NSMinY(insetRect))];
	[self lineToPoint: NSMakePoint(NSMinX(insetRect), NSMinY(aRect))];
	[self closePath];
}

+ (NSBezierPath*)bezierPathWithBeveledRect:(NSRect)rect radius: (float)radius;
{
    NSBezierPath* path = [NSBezierPath bezierPath];

    [path appendBezierPathWithBeveledRect: rect radius: radius];
    return path;
    
}

- (void) appendBezierPathWithSkewedRect:(NSRect)aRect radius:(float) radius
{
	radius = MIN(radius, (aRect.size.width/2 - 2));

	NSRect insetRect = NSInsetRect(aRect, radius, radius);

    [self moveToPoint: NSMakePoint(NSMinX(insetRect), NSMinY(aRect))];
    [self lineToPoint: NSMakePoint(NSMaxX(aRect), NSMinY(aRect))];
    [self lineToPoint: NSMakePoint(NSMaxX(insetRect), NSMaxY(aRect))];
    [self lineToPoint: NSMakePoint(NSMinX(aRect), NSMaxY(aRect))];
	[self closePath];
}

+ (NSBezierPath*)bezierPathWithSkewedRect:(NSRect)rect radius: (float)radius;
{
    NSBezierPath* path = [NSBezierPath bezierPath];

    [path appendBezierPathWithSkewedRect: rect radius: radius];
    return path;
    
}

- (void) appendBezierPathWithTwistedRect:(NSRect)aRect radius:(float) radius
{
	radius = MIN(radius, (aRect.size.width/2 - 2));
	radius = MIN(radius, (aRect.size.height/2 - 2));
	NSRect insetRect = NSInsetRect(aRect, radius, radius);

    [self moveToPoint: NSMakePoint(NSMinX(insetRect), NSMinY(aRect))];
    [self lineToPoint: NSMakePoint(NSMaxX(aRect), NSMinY(insetRect))];
    [self lineToPoint: NSMakePoint(NSMaxX(insetRect), NSMaxY(aRect))];
    [self lineToPoint: NSMakePoint(NSMinX(aRect), NSMaxY(insetRect))];
	[self closePath];
}

+ (NSBezierPath*)bezierPathWithTwistedRect:(NSRect)rect radius: (float)radius;
{
    NSBezierPath* path = [NSBezierPath bezierPath];

    [path appendBezierPathWithTwistedRect: rect radius: radius];
    return path;
    
}

- (void) appendBezierPathWithInsetSquareRect:(NSRect)aRect radius:(float) radius
{
	radius = MIN(radius, (aRect.size.width/2 - 2));
	radius = MIN(radius, (aRect.size.height/2 - 2));
	NSRect insetRect = NSInsetRect(aRect, radius, radius);
	//top
    [self moveToPoint: NSMakePoint(NSMinX(insetRect), NSMinY(aRect))];
	[self lineToPoint: NSMakePoint(NSMaxX(insetRect), NSMinY(aRect))];
	[self lineToPoint: NSMakePoint(NSMaxX(insetRect), NSMinY(insetRect))];
	// right
	[self lineToPoint: NSMakePoint(NSMaxX(aRect), NSMinY(insetRect))];
	[self lineToPoint: NSMakePoint(NSMaxX(aRect), NSMaxY(insetRect))];
	[self lineToPoint: NSMakePoint(NSMaxX(insetRect), NSMaxY(insetRect))];
	// bottom
	[self lineToPoint: NSMakePoint(NSMaxX(insetRect), NSMaxY(aRect))];
	[self lineToPoint: NSMakePoint(NSMinX(insetRect), NSMaxY(aRect))];
	[self lineToPoint: NSMakePoint(NSMinX(insetRect), NSMaxY(insetRect))];
	// left
	[self lineToPoint: NSMakePoint(NSMinX(aRect), NSMaxY(insetRect))];
	[self lineToPoint: NSMakePoint(NSMinX(aRect), NSMinY(insetRect))];
	[self lineToPoint: NSMakePoint(NSMinX(insetRect), NSMinY(insetRect))];
	[self closePath];
}

+ (NSBezierPath*)bezierPathWithInsetSquareRect:(NSRect)rect radius: (float)radius
{
    NSBezierPath* path = [NSBezierPath bezierPath];

    [path appendBezierPathWithInsetSquareRect: rect radius: radius];
    return path;
    
}

+ (NSBezierPath*)bezierPathWithDiamondInRect:(NSRect)rect
{
    NSBezierPath* path = [NSBezierPath bezierPath];

    [path appendBezierPathWithDiamondInRect: rect];
    return path;
}

- (void) appendBezierPathWithDiamondInRect:(NSRect)aRect
{
    [self moveToPoint: NSMakePoint(NSMidX(aRect), NSMinY(aRect))];
	[self lineToPoint: NSMakePoint(NSMaxX(aRect), NSMidY(aRect))];
	[self lineToPoint: NSMakePoint(NSMidX(aRect), NSMaxY(aRect))];
	[self lineToPoint: NSMakePoint(NSMinX(aRect), NSMidY(aRect))];
	[self closePath];
}

+ (NSBezierPath*)bezierPathWithTriangleInRect:(NSRect)rect
{
    NSBezierPath* path = [NSBezierPath bezierPath];

    [path appendBezierPathWithTriangleInRect: rect];
    return path;
}

- (void) appendBezierPathWithTriangleInRect:(NSRect)aRect
{
    [self moveToPoint: NSMakePoint(NSMidX(aRect), NSMinY(aRect))];
	[self lineToPoint: NSMakePoint(NSMaxX(aRect), NSMaxY(aRect))];
	[self lineToPoint: NSMakePoint(NSMinX(aRect), NSMaxY(aRect))];
	[self closePath];
}

+ (NSBezierPath*)bezierPathWithRightTriangleInRect:(NSRect)rect
{
    NSBezierPath* path = [NSBezierPath bezierPath];

    [path appendBezierPathWithRightTriangleInRect: rect];
    return path;
}

- (void) appendBezierPathWithRightTriangleInRect:(NSRect)aRect
{
    [self moveToPoint: NSMakePoint(NSMinX(aRect), NSMinY(aRect))];
	[self lineToPoint: NSMakePoint(NSMaxX(aRect), NSMaxY(aRect))];
	[self lineToPoint: NSMakePoint(NSMinX(aRect), NSMaxY(aRect))];
	[self closePath];
}

+ (NSBezierPath*)bezierPathWithArrowInRect: (NSRect)rect inset: (NSPoint)point
{
    NSBezierPath* path = [NSBezierPath bezierPath];

    [path appendBezierPathWithArrowInRect: rect inset: point];
    return path;
}

- (void)appendBezierPathWithArrowInRect: (NSRect)rect inset: (NSPoint)point
{
	point.x = MIN(point.x, rect.size.width);
	point.y = MIN(point.y, (rect.size.height/2 - 2));
	NSRect insetRect = NSInsetRect(rect, point.x, point.y);
	[self moveToPoint: NSMakePoint(NSMinX(rect), NSMinY(insetRect))];
	[self lineToPoint: NSMakePoint(NSMaxX(insetRect), NSMinY(insetRect))];
	[self lineToPoint: NSMakePoint(NSMaxX(insetRect), NSMinY(rect))];
	[self lineToPoint: NSMakePoint(NSMaxX(rect), NSMidY(rect))];
	[self lineToPoint: NSMakePoint(NSMaxX(insetRect), NSMaxY(rect))];
	[self lineToPoint: NSMakePoint(NSMaxX(insetRect), NSMaxY(insetRect))];
	[self lineToPoint: NSMakePoint(NSMinX(rect), NSMaxY(insetRect))];
	[self closePath];
}

+ (NSBezierPath*)bezierPathWithArrowheadInRect: (NSRect)rect inset: (float)inset
{
    NSBezierPath* path = [NSBezierPath bezierPath];

    [path appendBezierPathWithArrowheadInRect: rect inset: inset];
    return path;
}

- (void)appendBezierPathWithArrowheadInRect: (NSRect)rect inset: (float)inset
{
	if (inset > rect.size.width) inset = rect.size.width;
	[self moveToPoint: NSMakePoint(NSMinX(rect), NSMinY(rect))];
	[self lineToPoint: NSMakePoint(NSMaxX(rect), NSMidY(rect))];
	[self lineToPoint: NSMakePoint(NSMinX(rect), NSMaxY(rect))];
	[self lineToPoint: NSMakePoint(NSMinX(rect) + inset, NSMidY(rect))];
	[self closePath];
}

+ (NSBezierPath*)bezierPathWithDoubleArrowInRect: (NSRect)rect inset: (NSPoint)point
{
    NSBezierPath* path = [NSBezierPath bezierPath];

    [path appendBezierPathWithDoubleArrowInRect: rect inset: point];
    return path;
}

- (void)appendBezierPathWithDoubleArrowInRect: (NSRect)rect inset: (NSPoint)point
{
	// Fix up the point to make sure it fits
	point.x = MIN(point.x, (rect.size.width/2 - 2));
	point.y = MIN(point.y, (rect.size.height/2 - 2));
	NSRect insetRect = NSInsetRect(rect, point.x, point.y);
	[self moveToPoint: NSMakePoint(NSMinX(rect), NSMidY(rect))];
	[self lineToPoint: NSMakePoint(NSMinX(insetRect), NSMinY(rect))];
	[self lineToPoint: NSMakePoint(NSMinX(insetRect), NSMinY(insetRect))];
	[self lineToPoint: NSMakePoint(NSMaxX(insetRect), NSMinY(insetRect))];
	[self lineToPoint: NSMakePoint(NSMaxX(insetRect), NSMinY(rect))];
	[self lineToPoint: NSMakePoint(NSMaxX(rect), NSMidY(rect))];
	[self lineToPoint: NSMakePoint(NSMaxX(insetRect), NSMaxY(rect))];
	[self lineToPoint: NSMakePoint(NSMaxX(insetRect), NSMaxY(insetRect))];
	[self lineToPoint: NSMakePoint(NSMinX(insetRect), NSMaxY(insetRect))];
	[self lineToPoint: NSMakePoint(NSMinX(insetRect), NSMaxY(rect))];
	[self closePath];
}

+ (NSBezierPath*)bezierPathWithStarInRect: (NSRect)rect offset: (float)offset count: (int)count
{
    NSBezierPath* path = [NSBezierPath bezierPath];

    [path appendBezierPathWithStarInRect: rect offset: offset count: count];
    return path;
}

- (void)appendBezierPathWithStarInRect: (NSRect)rect offset: (float)offset count: (int)count
{
	float xOffset = ((rect.size.width/2)/100) * offset;
	float yOffset = ((rect.size.height/2)/100) * offset;
	NSRect insetRect = NSInsetRect(rect, xOffset, yOffset);
	float angle = 360.f / (count * 2);
	int i = 0;
	float curAngle = 0;
	NSPoint point = NSMakePoint(0, -1);

	[self moveToPoint: NSMakePoint(NSMidX(rect), NSMinY(rect))];
	for (i = 1; i < count * 2; i++) {
		curAngle += angle;
		NSAffineTransform* transform = [NSAffineTransform transform];
		[transform rotateByDegrees: curAngle];
		NSPoint newPoint = [transform transformPoint: point];
		if (i % 2) {
			// odd so use the insetRect
			newPoint.x *= (insetRect.size.width/2);
			newPoint.y *= (insetRect.size.height/2);
		} else {
			// even so use the regular rect
			newPoint.x *= (rect.size.width/2);
			newPoint.y *= (rect.size.height/2);
		}
		newPoint.x += NSMidX(rect);
		newPoint.y += NSMidY(rect);
		[self lineToPoint: newPoint];
	}
	[self closePath];
}

+ (NSBezierPath*)bezierPathWithCogInRect: (NSRect)rect offset: (float)offset count: (int)count
{
    NSBezierPath* path = [NSBezierPath bezierPath];

    [path appendBezierPathWithCogInRect: rect offset: offset count: count];
    return path;
}

- (void)appendBezierPathWithCogInRect: (NSRect)rect offset: (float)offset count: (int)count
{
	float xOffset = ((rect.size.width/2)/100) * offset;
	float yOffset = ((rect.size.height/2)/100) * offset;
	NSRect insetRect = NSInsetRect(rect, xOffset, yOffset);
	float angle = 360.f / (count * 2);
	int i = 0;
	// offset the starting angle to make sure the first tooth is centered at the top
	float curAngle = angle;
	NSPoint leftPoint = NSMakePoint(-1.f/count, -1);
	NSPoint rightPoint = NSMakePoint(1.f/count, -1);

	BOOL movedToPoint = FALSE;
	for (i = 0; i < count * 2; i++) {
		curAngle += angle;
		NSAffineTransform* transform = [NSAffineTransform transform];
		[transform rotateByDegrees: curAngle];
		NSPoint newLeftPoint = [transform transformPoint: leftPoint];
		if (i % 2) {
			// odd so use the insetRect
			newLeftPoint.x *= (insetRect.size.width/2);
			newLeftPoint.y *= (insetRect.size.height/2);
		} else {
			// even so use the regular rect
			newLeftPoint.x *= (rect.size.width/2);
			newLeftPoint.y *= (rect.size.height/2);
		}
		newLeftPoint.x += NSMidX(rect);
		newLeftPoint.y += NSMidY(rect);
		if (!movedToPoint) {
			[self moveToPoint: newLeftPoint];
			movedToPoint = TRUE;
		}
		else
			[self lineToPoint: newLeftPoint];
		// Now do the right point
		NSPoint newRightPoint = [transform transformPoint: rightPoint];
		if (i % 2) {
			// odd so use the insetRect
			newRightPoint.x *= (insetRect.size.width/2);
			newRightPoint.y *= (insetRect.size.height/2);
		} else {
			// even so use the regular rect
			newRightPoint.x *= (rect.size.width/2);
			newRightPoint.y *= (rect.size.height/2);
		}
		newRightPoint.x += NSMidX(rect);
		newRightPoint.y += NSMidY(rect);
		[self lineToPoint: newRightPoint];
	}
	[self closePath];
}

+ (NSBezierPath*)bezierPathWithHedronInRect: (NSRect)rect count: (int)count
{
    NSBezierPath* path = [NSBezierPath bezierPath];

    [path appendBezierPathWithHedronInRect: rect count: count];
    return path;
}

- (void)appendBezierPathWithHedronInRect: (NSRect)rect count: (int)count
{
	float angle = 360.f / count;
	int i = 0;
	float curAngle = 0;
	NSPoint point = NSMakePoint(0, -1);
	
	[self moveToPoint: NSMakePoint(NSMidX(rect), NSMinY(rect))];
	for (i = 1; i < count; i++) {
		curAngle += angle;
		NSAffineTransform* transform = [NSAffineTransform transform];
		[transform rotateByDegrees: curAngle];
		NSPoint newPoint = [transform transformPoint: point];
		newPoint.x *= (rect.size.width/2);
		newPoint.y *= (rect.size.height/2);
		newPoint.x += NSMidX(rect);
		newPoint.y += NSMidY(rect);
		[self lineToPoint: newPoint];
	}
	[self closePath];
}

+ (NSBezierPath*)bezierPathWithArcInRect: (NSRect)rect
{
    NSBezierPath* path = [NSBezierPath bezierPath];

    [path appendBezierPathWithArcInRect: rect];
    return path;
}

- (void)appendBezierPathWithArcInRect: (NSRect)rect
{
	[self moveToPoint: NSMakePoint(NSMinX(rect), NSMinY(rect))];
	[self curveToPoint: NSMakePoint(NSMaxX(rect), NSMaxY(rect))
			controlPoint1: NSMakePoint(NSMidX(rect), NSMinY(rect))
			controlPoint2:NSMakePoint(NSMaxX(rect), NSMidY(rect))];
	[self lineToPoint: NSMakePoint(NSMinX(rect), NSMaxY(rect))];
	[self closePath];
}

+ (NSBezierPath*)bezierPathWithSemiOvalInRect: (NSRect)rect
{
    NSBezierPath* path = [NSBezierPath bezierPath];

    [path appendBezierPathWithSemiOvalInRect: rect];
    return path;
}

- (void)appendBezierPathWithSemiOvalInRect: (NSRect)rect
{
	[self moveToPoint: NSMakePoint(NSMinX(rect), NSMaxY(rect))];
	[self curveToPoint: NSMakePoint(NSMaxX(rect), NSMaxY(rect))
			controlPoint1: NSMakePoint(NSMinX(rect), NSMinY(rect) - (rect.size.height/3))
			controlPoint2:NSMakePoint(NSMaxX(rect), NSMinY(rect) - (rect.size.height/3))];
	[self closePath];
}

+ (NSBezierPath*)bezierPathWithBulgingRect:(NSRect)rect bulge: (float)bulge
{
    NSBezierPath* path = [NSBezierPath bezierPath];

    [path appendBezierPathWithBulgingRect: rect bulge: bulge];
    return path;
}

- (void) appendBezierPathWithBulgingRect:(NSRect)aRect bulge:(float) bulge
{
	bulge = MIN(bulge, MIN(aRect.size.height/2 - 2, aRect.size.width/2 - 2));
	NSRect insetRect = NSInsetRect(aRect, bulge, bulge);
	NSRect cpRect = NSInsetRect(aRect, aRect.size.width * .25, aRect.size.height * .25);
	[self moveToPoint: NSMakePoint(NSMaxX(insetRect), NSMinY(insetRect))];
	[self curveToPoint: NSMakePoint(NSMaxX(insetRect), NSMaxY(insetRect))
			controlPoint1: NSMakePoint(NSMaxX(aRect), NSMinY(cpRect))
			controlPoint2: NSMakePoint(NSMaxX(aRect), NSMaxY(cpRect))];
	[self curveToPoint: NSMakePoint(NSMinX(insetRect), NSMaxY(insetRect))
			controlPoint1: NSMakePoint(NSMaxX(cpRect), NSMaxY(aRect))
			controlPoint2: NSMakePoint(NSMinX(cpRect), NSMaxY(aRect))];
	[self curveToPoint: NSMakePoint(NSMinX(insetRect), NSMinY(insetRect))
		controlPoint1: NSMakePoint(NSMinX(aRect), NSMaxY(cpRect))
		controlPoint2: NSMakePoint(NSMinX(aRect), NSMinY(cpRect))];
	[self curveToPoint: NSMakePoint(NSMaxX(insetRect), NSMinY(insetRect))
			controlPoint1: NSMakePoint(NSMinX(cpRect), NSMinY(aRect))
			controlPoint2: NSMakePoint(NSMaxX(cpRect), NSMinY(aRect))];
	[self closePath];
}

+ (NSBezierPath*)bezierPathWithTrapezoidInRect:(NSRect)rect inset: (float)inset
{
    NSBezierPath* path = [NSBezierPath bezierPath];

    [path appendBezierPathWithTrapezoidInRect: rect inset: inset];
    return path;
}

- (void) appendBezierPathWithTrapezoidInRect:(NSRect)aRect inset:(float) inset
{
	inset = MIN(inset, (aRect.size.width/2 - 2));
	NSRect insetRect = NSInsetRect(aRect, inset, 0);
	
	[self moveToPoint: NSMakePoint(NSMinX(insetRect), NSMinY(aRect))];
	[self lineToPoint: NSMakePoint(NSMaxX(insetRect), NSMinY(aRect))];
	[self lineToPoint: NSMakePoint(NSMaxX(aRect), NSMaxY(aRect))];
	[self lineToPoint: NSMakePoint(NSMinX(aRect), NSMaxY(aRect))];
	[self closePath];
}

//#if 0
//- (void)appendBezierPathWithCloudInRect:(NSRect)aRect offset:(float)offset count:(int)count
//{
//	// Algorithm builds the puffs within a 100x100 square and then scales the resulting
//	// bezier path to fit the desired rect
//	
////	NSSize size = aRect.size;
//	// A base balloon would fill the center of the rect.
//	float baseRadius = 100;
//		
//	NSPoint center = NSMakePoint(50, 50);
////	NSBezierPath* path = [NSBezierPath bezierPathWithOvalInRect: NSInsetRect(aRect, count, count)];
//	int i = 0;
//	srand(100);
//	NSMutableArray* puffPaths = [NSMutableArray array];
////	[puffPaths addObject: path];
//	for (i = 0; i < count; i++) {
//		float angle = i * (360.f/count);
//		float radius = (baseRadius/count) * [Util randomFloatFrom: .9 to: 1.1];
//		float centerOffset = 50-radius;
//		NSPoint p = NSMakePoint(centerOffset, 0);
//		NSAffineTransform* transform = [NSAffineTransform transform];
//		[transform rotateByDegrees: angle];
//		p = [transform transformPoint: p];
////		p.x *= 50;
////		p.y *= 50;
//		NSBezierPath* puff = [NSBezierPath bezierPathWithOvalInRect: NSMakeRect(- (radius/2), -(radius/2), radius, radius)];
//		transform = [NSAffineTransform transform];
//		[transform translateXBy: center.x + p.x yBy: center.y + p.y];
//		puff = [transform transformBezierPath: puff];
//		NSLog(@"puff: %@", puff);
//		[puffPaths addObject: puff];
//	}
//	NSAffineTransform* transform = [NSAffineTransform transform];
//	NSAffineTransform* translate = [NSAffineTransform transform];
//	[translate translateXBy: aRect.origin.x yBy: aRect.origin.y];
//	NSAffineTransform* scale = [NSAffineTransform transform];
//	[scale scaleXBy: aRect.size.width/100 yBy: aRect.size.height/100];
//	[transform appendTransform: scale];
//	[transform appendTransform: translate];
//	NSBezierPath* path = [NSBezierPath combineBezierPaths: puffPaths];
//	path = [transform transformBezierPath: path];
//	[self appendBezierPath: path];
//}
//#else
//- (void)appendBezierPathWithCloudInRect:(NSRect)aRect offset:(float)offset count:(int)count
//{
//	float xOffset = ((aRect.size.width/2)/100) * offset;
//	float yOffset = ((aRect.size.height/2)/100) * offset;
//	NSSize size = aRect.size;
//	float fraction = (100 - offset)/100.f;
//	size.width *= fraction;
//	size.height *= fraction;
//	NSPoint center = NSMakePoint(NSMidX(aRect), NSMidY(aRect));
//	NSBezierPath* path = [NSBezierPath bezierPathWithOvalInRect: NSInsetRect(aRect, xOffset, yOffset)];
//	int i = 0;
//	srand(100);
//	float baseRadius = MIN(size.width, size.height) * (1 - fraction);
//	NSMutableArray* puffPaths = [NSMutableArray array];
//	[puffPaths addObject: path];
//	for (i = 0; i < count; i++) {
//		float angle = i * (360.f/count);
//		float radius = baseRadius + ((rand() / (float)RAND_MAX) * baseRadius);
//		NSPoint p = NSMakePoint(1, 0);
//		NSAffineTransform* transform = [NSAffineTransform transform];
//		[transform rotateByDegrees: angle];
//		p = [transform transformPoint: p];
//		p.x *= (size.width / 2);
//		p.y *= (size.height / 2);
//		NSBezierPath* puff = [NSBezierPath bezierPathWithOvalInRect: NSMakeRect(- (radius/2), -(radius/2), radius, radius)];
//		transform = [NSAffineTransform transform];
//		[transform translateXBy: center.x + p.x yBy: center.y + p.y];
//		puff = [transform transformBezierPath: puff];
//		[puffPaths addObject: puff];
//	}
//	[self appendBezierPath: [NSBezierPath combineBezierPaths: puffPaths]];
//}
//#endif

+ (NSBezierPath*)bezierPathWithExclaimInRect:(NSRect)aRect offset:(float)offset count:(int)count
{
    NSBezierPath* path = [NSBezierPath bezierPath];

    [path appendBezierPathWithExclaimInRect: aRect offset: offset count: count];

    return path;
}

- (void)appendBezierPathWithExclaimInRect:(NSRect)aRect offset:(float)offset count:(int)count
{
	float xOffset = ((aRect.size.width/2)/100) * offset;
	float yOffset = ((aRect.size.height/2)/100) * offset;
	NSRect insetRect = NSInsetRect(aRect, xOffset, yOffset);
	float angle = 360.f / (count * 2);
	int i = 0;
	float curAngle = 0;
	srand(301);

	[self moveToPoint: NSMakePoint(NSMidX(aRect), NSMinY(aRect))];
	for (i = 1; i < count * 2; i++) {
		curAngle += angle;
		NSPoint point = NSMakePoint(0, -1 * [Util randomFloatFrom: .9 to: 1.1]);
		NSAffineTransform* transform = [NSAffineTransform transform];
		curAngle += [Util randomFloatFrom: -2 to: 2];
		[transform rotateByDegrees: curAngle];
		NSPoint newPoint = [transform transformPoint: point];
		if (i % 2) {
			// odd so use the insetRect
			newPoint.x *= (insetRect.size.width/2);
			newPoint.y *= (insetRect.size.height/2);
		} else {
			// even so use the regular rect
			newPoint.x *= (aRect.size.width/2);
			newPoint.y *= (aRect.size.height/2);
		}
		newPoint.x += NSMidX(aRect);
		newPoint.y += NSMidY(aRect);
		[self lineToPoint: newPoint];
	}
	[self closePath];
}

+ (NSBezierPath*)bezierPathWithExclaim2InRect:(NSRect)aRect offset:(float)offset count:(int)count
{
    NSBezierPath* path = [NSBezierPath bezierPath];

    [path appendBezierPathWithExclaim2InRect: aRect offset: offset count: count];

    return path;
}

- (void)appendBezierPathWithExclaim2InRect:(NSRect)rect offset:(float)offset count:(int)count
{
	int i = 0;
	srand(150);
	NSPoint curvePoint;
	NSPoint origin;
	float fraction = (100 - offset)/100.f;
	int points = (count * 2) + 1;
	for (i = 0; i < points; i++) {
		float angle = i * (360.f / points);
		float radius = 0;
		if ((i % 2))
			// Odd indexes we do the inside points
			radius = [Util randomFloatFrom: fraction - .1 to: fraction + .1];
		else
			// Even indexes we do the outside points
			radius = [Util randomFloatFrom: .9 to: 1.1];
		
		NSPoint p = NSMakePoint(radius, 0);
		NSAffineTransform* transform = [NSAffineTransform transform];
		[transform rotateByDegrees: angle];

		// Calculate the location of the point within the rect
		p = [transform transformPoint: p];
		p.x *= rect.size.width /2 ;
		p.y *= rect.size.height /2 ;
		p.x += NSMidX(rect);
		p.y += NSMidY(rect);
		if (i == 0) {
			// The first index? Move to the point - and it's even so the 
			[self moveToPoint: p];
			// Remember it because we'll need to curve to it later
			origin = p;
		}
		else if (i == points - 1)
			// Last index - finish the last curve back to the beginning
			[self curveToPoint: origin controlPoint1: curvePoint controlPoint2: curvePoint];
		else if (!(i % 2))
			// If we're even draw a curve
			[self curveToPoint: p controlPoint1: curvePoint controlPoint2: curvePoint];
		else
			// Odd - remember this point as the curve point.
			curvePoint = p;
	}
	[self closePath];
}

+ (NSBezierPath*)bezierPathWithRoughOvalInRect:(NSRect)aRect roughness:(int)roughness
{
    NSBezierPath* path = [NSBezierPath bezierPath];

    [path appendBezierPathWithRoughOvalInRect: aRect roughness: roughness];

    return path;
}

- (void)appendBezierPathWithRoughOvalInRect:(NSRect)rect roughness:(int)roughness
{
	NSRect insetRect = NSInsetRect(rect, 5, 5);
	NSPoint center = NSMakePoint(NSMidX(rect), NSMidY(rect));
	srand(275);
	roughness *= 2;
	float delta = 360.f/roughness;
	int i = 0;
	for (i = 0; i < roughness + 1; i++) {
		float angle = delta * i;
		float cpdelta = .75 / roughness; 
		NSPoint cp1 = NSMakePoint(-(cpdelta * 3), [Util randomFloatFrom: -1.1 to: -.9]);
		NSPoint cp2 = NSMakePoint(-cpdelta, [Util randomFloatFrom: -1.1 to: -.9]);
		NSPoint p = NSMakePoint(0, -1);
		NSAffineTransform* transform = [NSAffineTransform transform];
		[transform rotateByDegrees: angle];
		cp1 = [transform transformPoint: cp1];
		cp2 = [transform transformPoint: cp2];
		p = [transform transformPoint: p];
		cp1.x *= insetRect.size.width/2;
		cp1.y *= insetRect.size.height/2;
		cp1 = PQOffsetPoint(cp1, center.x, center.y);
		cp2.x *= insetRect.size.width/2;
		cp2.y *= insetRect.size.height/2;
		cp2 = PQOffsetPoint(cp2, center.x, center.y);
		p.x *= insetRect.size.width/2;
		p.y *= insetRect.size.height/2;
		p = PQOffsetPoint(p, center.x, center.y);
		if (i == 0) {
			[self moveToPoint: p];
		} else {
			[self curveToPoint: p controlPoint1: cp1 controlPoint2: cp2];
		}
	}
}

+ (NSBezierPath*)bezierPathWithSpaceOvalInRect:(NSRect)aRect offset:(float)offset
{
    NSBezierPath* path = [NSBezierPath bezierPath];

    [path appendBezierPathWithSpaceOvalInRect: aRect offset: offset];

    return path;
}

- (void)appendBezierPathWithSpaceOvalInRect:(NSRect)rect offset:(float)offset
{
	float xOffset = ((rect.size.width/2)/100) * offset;
	float yOffset = ((rect.size.height/2)/100) * offset;
	// Inset rect tells us where to place the center of the squiggle
	NSRect outsetRect = NSInsetRect(rect, xOffset, yOffset);
	NSRect insetRect = NSInsetRect(rect, xOffset+10, yOffset+10);
//	NSRect baseRect = NSInsetRect(rect, xOffset, yOffset);
	
	[self moveToPoint:NSMakePoint(NSMinX(outsetRect), NSMinY(insetRect))];

/*
	// Top left squiggle
	// Curve in to line
	[self curveToPoint: NSMakePoint(NSMinX(outsetRect), NSMinY(outsetRect))
			controlPoint1: NSMakePoint(NSMinX(insetRect) - NSMinX(outsetRect), NSMinY(insetRect))
			controlPoint2: NSMakePoint(NSMinX(insetRect) - NSMinX(outsetRect), NSMinY(insetRect))];
	[self lineToPoint: NSMakePoint(NSMinX(insetRect), NSMinY(insetRect))];
	// Curve out of line
	[self curveToPoint: NSMakePoint(NSMinX(insetRect), NSMinY(outsetRect))
			controlPoint1: NSMakePoint(NSMinX(insetRect) - NSMinX(outsetRect), NSMinY(outsetRect))
			controlPoint2: NSMakePoint(NSMinX(insetRect) - NSMinX(outsetRect), NSMinY(outsetRect))];
*/
	// Top main curve
	[self curveToPoint: NSMakePoint(NSMaxX(insetRect), NSMinY(outsetRect))
			controlPoint1: NSMakePoint(NSMidX(rect), NSMinY(rect))
			controlPoint2: NSMakePoint(NSMidX(rect), NSMinY(rect))];
	
	/*
	// Top right squiggle
	// Curve in to line
	[self curveToPoint: NSMakePoint(NSMaxX(outsetRect), NSMinY(outsetRect))
			controlPoint1: NSMakePoint(NSMaxX(outsetRect) - NSMaxX(insetRect), NSMinY(insetRect))
			controlPoint2: NSMakePoint(NSMaxX(outsetRect) - NSMaxX(insetRect), NSMinY(insetRect))];
	// line
	[self lineToPoint: NSMakePoint(NSMaxX(insetRect), NSMinY(insetRect))];
	// Curve out of line
	[self curveToPoint: NSMakePoint(NSMaxX(insetRect), NSMinY(outsetRect))
			controlPoint1: NSMakePoint(NSMaxX(outsetRect) - NSMaxX(insetRect), NSMinY(insetRect))
			controlPoint2: NSMakePoint(NSMaxX(outsetRect) - NSMaxX(insetRect), NSMinY(insetRect))];
*/

	// right main curve
	[self curveToPoint: NSMakePoint(NSMaxX(insetRect), NSMaxY(insetRect))
			controlPoint1: NSMakePoint(NSMaxX(rect), NSMidY(rect))
			controlPoint2: NSMakePoint(NSMaxX(rect), NSMidY(rect))];

	// bottom main curve
	[self curveToPoint: NSMakePoint(NSMinX(insetRect), NSMaxY(insetRect))
			controlPoint1: NSMakePoint(NSMidX(rect), NSMaxY(rect))
			controlPoint2: NSMakePoint(NSMidX(rect), NSMaxY(rect))];

	// left main curve
	[self curveToPoint: NSMakePoint(NSMinX(insetRect), NSMinY(insetRect))
			controlPoint1: NSMakePoint(NSMinX(rect), NSMidY(rect))
			controlPoint2: NSMakePoint(NSMinX(rect), NSMidY(rect))];

	[self closePath];
}

+ (NSBezierPath*)bezierPathWithSmartShapeRect:(NSRect)rect forObject:(id)object
{
	// Configure and create a smart shape from the style shape params
	NSNumber* value = [object valueForKey: @"shape_type"];
	int type = [value intValue];
	
	value = [object valueForKey: @"shape_handleX"];
	float radius = [value floatValue];

	float handleX = [value floatValue];

	value = [object valueForKey: @"shape_handleY"];
	float handleY = [value floatValue];

	NSPoint point = NSMakePoint(handleX, handleY);

	value = [object valueForKey: @"shape_pointCount"];
	int count = [value intValue];
	
	value = [object valueForKey: @"shape_pointOffset"];
	float pointOffset = [value floatValue];
	
	switch (type) {
		case kSmartShapeTypeOval:
			return [NSBezierPath bezierPathWithOvalInRect: rect];
			break;
		case kSmartShapeTypeDiamond:
			return [NSBezierPath bezierPathWithDiamondInRect: rect];
			break;
		case kSmartShapeTypeTriangle:
			return [NSBezierPath bezierPathWithTriangleInRect: rect];
			break;
		case kSmartShapeTypeRightTriangle:
			return [NSBezierPath bezierPathWithRightTriangleInRect: rect];
			break;
		case kSmartShapeTypeArc:
			return [NSBezierPath bezierPathWithArcInRect: rect];
			break;
		case kSmartShapeTypeSemiOval:
			return [NSBezierPath bezierPathWithSemiOvalInRect: rect];
			break;
		case kSmartShapeTypeRounded:
			return [NSBezierPath bezierPathWithRoundedRect: rect xRadius: radius yRadius: radius];
			break;
		case kSmartShapeTypeInsetRounded:
			return [NSBezierPath bezierPathWithInsetRoundedRect: rect radius: radius];
			break;
		case kSmartShapeTypeBeveled:
			return [NSBezierPath bezierPathWithBeveledRect: rect radius: radius];
			break;
		case kSmartShapeTypeSkewed:
			return [NSBezierPath bezierPathWithSkewedRect: rect radius: radius];
			break;
		case kSmartShapeTypeBulge:
			return [NSBezierPath bezierPathWithBulgingRect: rect bulge: radius];
			break;
		case kSmartShapeTypeInsetSquare:
			return [NSBezierPath bezierPathWithInsetSquareRect: rect radius: radius];
			break;
		case kSmartShapeTypeArrow:
			return [NSBezierPath bezierPathWithArrowInRect: rect inset: point];
			break;
		case kSmartShapeTypeArrowHead:
			return [NSBezierPath bezierPathWithArrowheadInRect: rect inset: point.x];
			break;
		case kSmartShapeTypeDoubleArrow:
			return [NSBezierPath bezierPathWithDoubleArrowInRect: rect inset: point];
			break;
		case kSmartShapeTypeStar:
			return [NSBezierPath bezierPathWithStarInRect: rect offset: pointOffset count: count];
			break;
		case kSmartShapeTypeCog:
			return [NSBezierPath bezierPathWithCogInRect: rect offset: pointOffset count: count];
			break;
		case kSmartShapeTypeHedron:
			return [NSBezierPath bezierPathWithHedronInRect: rect count: count];
			break;
		case kSmartShapeTypeTrapezoid:
			return [NSBezierPath bezierPathWithTrapezoidInRect: rect inset: point.x];
			break;
		case kSmartShapeTypeExclaim:
			return [NSBezierPath bezierPathWithExclaimInRect: rect offset: pointOffset count: count];
			break;
		case kSmartShapeTypeExclaim2:
			return [NSBezierPath bezierPathWithExclaim2InRect: rect offset: pointOffset count: count];
			break;
		case kSmartShapeTypeRough:
			return [NSBezierPath bezierPathWithRoughOvalInRect: rect roughness: count];
			break;
		case kSmartShapeTypeSpace:
			return [NSBezierPath bezierPathWithSpaceOvalInRect: rect offset: pointOffset];
			break;
		case kSmartShapeTypeRectangle:
			break;
		default:
			NSLog(@"unknown smart shape type: %d", type);
			break;
	}
	return [NSBezierPath bezierPathWithRect: rect];
}

+ (NSBezierPath *)bezierPathWithType:(int)type rect:(NSRect)rect radius:(float)radius pointCount:(int)count pointOffset:(float)pointOffset
{
	NSPoint point = NSMakePoint(0.0, 0.0);

	switch (type) {
		case kSmartShapeTypeOval:
			return [NSBezierPath bezierPathWithOvalInRect: rect];
			break;
		case kSmartShapeTypeDiamond:
			return [NSBezierPath bezierPathWithDiamondInRect: rect];
			break;
		case kSmartShapeTypeTriangle:
			return [NSBezierPath bezierPathWithTriangleInRect: rect];
			break;
		case kSmartShapeTypeRightTriangle:
			return [NSBezierPath bezierPathWithRightTriangleInRect: rect];
			break;
		case kSmartShapeTypeArc:
			return [NSBezierPath bezierPathWithArcInRect: rect];
			break;
		case kSmartShapeTypeSemiOval:
			return [NSBezierPath bezierPathWithSemiOvalInRect: rect];
			break;
		case kSmartShapeTypeRounded:
			return [NSBezierPath bezierPathWithRoundedRect: rect xRadius: radius yRadius: radius];
			break;
		case kSmartShapeTypeInsetRounded:
			return [NSBezierPath bezierPathWithInsetRoundedRect: rect radius: radius];
			break;
		case kSmartShapeTypeBeveled:
			return [NSBezierPath bezierPathWithBeveledRect: rect radius: radius];
			break;
		case kSmartShapeTypeSkewed:
			return [NSBezierPath bezierPathWithSkewedRect: rect radius: radius];
			break;
		case kSmartShapeTypeBulge:
			return [NSBezierPath bezierPathWithBulgingRect: rect bulge: radius];
			break;
		case kSmartShapeTypeInsetSquare:
			return [NSBezierPath bezierPathWithInsetSquareRect: rect radius: radius];
			break;
		case kSmartShapeTypeArrow:
			return [NSBezierPath bezierPathWithArrowInRect: rect inset: point];
			break;
		case kSmartShapeTypeArrowHead:
			return [NSBezierPath bezierPathWithArrowheadInRect: rect inset: point.x];
			break;
		case kSmartShapeTypeDoubleArrow:
			return [NSBezierPath bezierPathWithDoubleArrowInRect: rect inset: point];
			break;
		case kSmartShapeTypeStar:
			return [NSBezierPath bezierPathWithStarInRect: rect offset: pointOffset count: count];
			break;
		case kSmartShapeTypeCog:
			return [NSBezierPath bezierPathWithCogInRect: rect offset: pointOffset count: count];
			break;
		case kSmartShapeTypeHedron:
			return [NSBezierPath bezierPathWithHedronInRect: rect count: count];
			break;
		case kSmartShapeTypeTrapezoid:
			return [NSBezierPath bezierPathWithTrapezoidInRect: rect inset: point.x];
			break;
		case kSmartShapeTypeExclaim:
			return [NSBezierPath bezierPathWithExclaimInRect: rect offset: pointOffset count: count];
			break;
		case kSmartShapeTypeExclaim2:
			return [NSBezierPath bezierPathWithExclaim2InRect: rect offset: pointOffset count: count];
			break;
		case kSmartShapeTypeRough:
			return [NSBezierPath bezierPathWithRoughOvalInRect: rect roughness: count];
			break;
		case kSmartShapeTypeSpace:
			return [NSBezierPath bezierPathWithSpaceOvalInRect: rect offset: pointOffset];
			break;
		case kSmartShapeTypeRectangle:
			break;
		default:
			NSLog(@"unknown smart shape type: %d", type);
			break;
	}
	return [NSBezierPath bezierPathWithRect: rect];
}

// From http://developer.apple.com/documentation/Cocoa/Conceptual/CocoaDrawingGuide/Paths/chapter_6_section_7.html
- (CGPathRef)quartzPath
{
    int i, numElements;
    CGPathRef           immutablePath = NULL;
	
    // If there are elements to draw, create a CGMutablePathRef and draw.
    numElements = [self elementCount];
    if (numElements > 0)
    {
        CGMutablePathRef    path = CGPathCreateMutable();
        NSPoint             points[3];
		
        // Iterate over the points and add them to the mutable path object.
        for (i = 0; i < numElements; i++)
        {
            switch ([self elementAtIndex:i associatedPoints:points])
		{
			case NSMoveToBezierPathElement:
				CGPathMoveToPoint(path, NULL, points[0].x, points[0].y);
				break;
				
			case NSLineToBezierPathElement:
				CGPathAddLineToPoint(path, NULL, points[0].x, points[0].y);
				break;
				
			case NSCurveToBezierPathElement:
				CGPathAddCurveToPoint(path, NULL, points[0].x, points[0].y,
									  points[1].x, points[1].y,
									  points[2].x, points[2].y);
				break;
				
			case NSClosePathBezierPathElement:
				CGPathCloseSubpath(path);
				break;
		}
        }
		
        // Return an immutable copy of the path.
        immutablePath = CGPathCreateCopy(path);
        CGPathRelease(path);
    }
	
    return immutablePath;
}

/**
 * Returns the bounds of the path, including the stroke property (line width, etc)
 */
- (NSRect) strokedBounds
{
	CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
	CGPathRef cgPath = [self quartzPath];
	CGContextSaveGState(context);
	CGContextBeginPath(context);
	CGContextAddPath(context, cgPath);
	CGContextSetLineWidth(context, [self lineWidth]);
	CGContextSetLineJoin(context, [self lineJoinStyle]);
	CGContextSetLineCap(context, [self lineCapStyle]);
	CGContextSetMiterLimit(context, [self miterLimit]);
	int count;
	[self getLineDash:nil count:&count phase:nil];
	if (count > 0)	{
		float pattern[count];
		float phase;
		[self getLineDash:pattern count:&count phase:&phase];
		CGContextSetLineDash(context, phase, pattern, count);
	}		
	CGContextReplacePathWithStrokedPath(context);
	CGRect bbox = CGContextGetPathBoundingBox(context);
	CGContextRestoreGState(context);
	CGPathRelease(cgPath);

	return NSRectFromCGRect(bbox);
}	
@end
