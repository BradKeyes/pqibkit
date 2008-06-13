//
//  GeomUtils.c
//
//  Created by Robert Grant on Tue Feb 17 2004.
//  Copyright (c) 2004, 2007 plasq. All rights reserved.
//
#import "NSAffineTransform+PQAdditions.h"

#import "GeomUtils.h"
const NSPoint kInvalidPoint = {MAXFLOAT, MAXFLOAT};

/* Returns a rect given the specified center and size */
NSRect PQMakeRectFromCenterAndSize(NSPoint center, NSSize size)
{
    NSRect rect = NSZeroRect;
    rect.size = size;
    rect.origin.x = center.x - (size.width / 2);
    rect.origin.y = center.y - (size.height / 2);
    return rect;
}

/** Calculates the angle (in degrees) between the two points, zero is 12 o'clock */
float PQAngleBetweenPoints(NSPoint originPt, NSPoint endPt)
{
	// Get the angle and ensure it's in 0..2*PI
	float angle = fmod(atan2(originPt.y - endPt.y, originPt.x - endPt.x) - M_PI_2 + M_PI * 2.f, M_PI * 2.f);
	// Convert to degres
	angle *= 180.f / M_PI;
    return angle;
}

/** Calculates the bounds of a rectangle rotated around the specified point */
NSRect PQBoundsOfRotatedRectAroundPoint(NSRect rect, float angle, NSPoint point)
{
	NSPoint tl = NSMakePoint(NSMinX(rect), NSMinY(rect));
	NSPoint tr = NSMakePoint(NSMaxX(rect), NSMinY(rect));
	NSPoint bl = NSMakePoint(NSMinX(rect), NSMaxY(rect));
	NSPoint br = NSMakePoint(NSMaxX(rect), NSMaxY(rect));
	NSAffineTransform* transform = [NSAffineTransform transformToRotateByDegrees: angle aroundPoint: point];
	tl = [transform transformPoint: tl];
	tr = [transform transformPoint: tr];
	bl = [transform transformPoint: bl];
	br = [transform transformPoint: br];
	float minX = MIN(tl.x, MIN(tr.x, MIN(bl.x, br.x)));
	float minY = MIN(tl.y, MIN(tr.y, MIN(bl.y, br.y)));
	float maxX = MAX(tl.x, MAX(tr.x, MAX(bl.x, br.x)));
	float maxY = MAX(tl.y, MAX(tr.y, MAX(bl.y, br.y)));
	rect.origin.x = minX;
	rect.origin.y = minY;
	rect.size.width = maxX - minX;
	rect.size.height = maxY - minY;
	
	return rect;
}

/** Calculates the bounds of a rectangle rotated around its center */
NSRect PQBoundsOfRotatedRect(NSRect rect, float angle)
{
	NSPoint center = PQCenterOfRect(rect);
    return PQBoundsOfRotatedRectAroundPoint(rect, angle, center);
}

/** Calculates the center point of a rect */
NSPoint PQCenterOfRect(NSRect rect)
{
	return NSMakePoint(NSMidX(rect), NSMidY(rect));
}


float PQDistanceBetweenPoints(NSPoint aPoint, NSPoint bPoint)
{
	float maxY = MAX(aPoint.y, bPoint.y);
	float minY = MIN(aPoint.y, bPoint.y);
	float lengthY = maxY - minY;
	
	float maxX = MAX(aPoint.x, bPoint.x);
	float minX = MIN(aPoint.x, bPoint.x);
	float lengthX = maxX - minX;
	return sqrt( (lengthX * lengthX) + (lengthY * lengthY));
}

float PQDistanceBetweenRects(NSRect recta, NSRect rectb, BOOL vertical)
{
	if (vertical) {
		if (NSMaxY(recta) < NSMinY(rectb)) {
			return NSMinY(rectb) - NSMaxY(recta);
		}
		if (NSMinY(recta) > NSMaxY(rectb)) {
			return NSMinY(recta) - NSMaxY(rectb);
		}
	}
	else {
		if (NSMaxX(recta) < NSMinX(rectb)) {
			return NSMinX(rectb) - NSMaxX(recta);
		}
		if (NSMinX(recta) > NSMaxX(rectb)) {
			return NSMinX(recta) - NSMaxX(rectb);
		}
	}
	return MAXFLOAT;
}

NSRect PQFitRectInRect(NSRect recta, NSRect rectb, BOOL fillRect)
{
	float aspectRatio = recta.size.width/recta.size.height;
	float newHeight = rectb.size.height;
	float newWidth = newHeight * aspectRatio;
	if (fillRect) {
		if (newWidth < rectb.size.width) {
			newWidth = rectb.size.width;
			newHeight = rectb.size.width/aspectRatio;
		}
	} else {
		if (newWidth > rectb.size.width) {
			newWidth = rectb.size.width;
			newHeight = rectb.size.width/aspectRatio;
		}
	}
	NSPoint center = NSMakePoint(NSMidX(rectb), NSMidY(rectb));
	return PQMakeRectFromCenterAndSize(center, NSMakeSize(newWidth, newHeight));
}

BOOL PQPointIsValid(NSPoint point)
{
    return !NSEqualPoints(point, kInvalidPoint);
}

void PQRectCornersAsPoints(NSRect rect, NSPoint *topLeft, NSPoint *topRight, NSPoint *bottomLeft, NSPoint *bottomRight)
{
	*topLeft = NSMakePoint(NSMinX(rect), NSMinY(rect));
	*topRight = NSMakePoint(NSMaxX(rect), NSMinY(rect));
	*bottomLeft = NSMakePoint(NSMinX(rect), NSMaxY(rect));
	*bottomRight = NSMakePoint(NSMaxX(rect), NSMaxY(rect));
}

NSPoint PQOffsetPoint(NSPoint p, float xOffset, float yOffset)
{
	return NSMakePoint(p.x + xOffset, p.y + yOffset);
}

NSRect PQCenterInRect(NSRect aRect, NSRect bRect)
{
    NSRect rect = NSZeroRect;
    float ar = PQCalcAspectRatio(bRect);
    if (bRect.size.height > aRect.size.height) {
        bRect.size.height = aRect.size.height;
        bRect.size.width = bRect.size.height * ar;
    }
    if (bRect.size.width > aRect.size.width) {
        bRect.size.width = aRect.size.width;
        bRect.size.height =bRect.size.width / ar;
    }
    rect.origin = NSMakePoint(aRect.origin.x + (aRect.size.width - bRect.size.width)/2, aRect.origin.y + (aRect.size.height - bRect.size.height)/2);
    rect.size = bRect.size;
    return rect;
}

NSRect PQMakeCenteredRectInRectWithAspectRatio(NSRect aRect, float aspectRatio)
{
    NSRect rect = aRect;
    if ((rect.size.width / aspectRatio) > aRect.size.height) {
        rect.size.width = rect.size.height * aspectRatio;
        rect.origin.x += (rect.size.width - rect.size.width)/2;
    } else {
        rect.size.height = rect.size.width / aspectRatio;
        rect.origin.y += (aRect.size.height - rect.size.height) / 2;
    }
    return rect;
}


float PQCalcAspectRatio(NSRect rect)
{
    return rect.size.width / rect.size.height;
}

