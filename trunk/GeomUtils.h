/**
 * \file GeomUtils.h
 *
 * Geometry-related (point, rect, etc) functions are collected here
 *
 * Copyright plasq LLC 2004, 2007. All rights reserved.
 */
#import <Foundation/Foundation.h>

/** Returns a rect given the specified center and size. \ingroup CFuncs */
NSRect PQMakeRectFromCenterAndSize(NSPoint center, NSSize size);

/** Calculates the angle (in degrees) between the two points, zero is 12 o'clock. \ingroup CFuncs */
float PQAngleBetweenPoints(NSPoint originPt, NSPoint endPt);

/** Calculates the bounds of a rectangle rotated around the specified point \ingroup CFuncs */
NSRect PQBoundsOfRotatedRectAroundPoint(NSRect rect, float angle, NSPoint point);

/** Calculates the bounds of a rotated rectangle. \ingroup CFuncs */
NSRect PQBoundsOfRotatedRect(NSRect rect, float angle);

/** Calculates the center point of a rect. \ingroup CFuncs */
NSPoint PQCenterOfRect(NSRect rect);

/** Calculates the distance between two points \ingroup CFuncs */
float PQDistanceBetweenPoints(NSPoint aPoint, NSPoint bPoint);

/**
 * Calculates the distance between the edges of two rects - the vertical
 * flag indicates the vertical distance is required - otherwise it returns
 * the horizontal distance between the max and min edges. \ingroup CFuncs
 */
float PQDistanceBetweenRects(NSRect recta, NSRect rectb, BOOL vertical);

/** Fits recta into rectb - preserving recta's aspect ratio - fillRect option ensures that rectb is fully covered \ingroup CFuncs */
NSRect PQFitRectInRect(NSRect recta, NSRect rectb, BOOL fillRect);

/**
 * Constant to describe an invalid point
 */
extern const NSPoint kInvalidPoint;

/**
 * Test is a point is valid
 */
BOOL PQPointIsValid(NSPoint point);

/**
 * Calculates the four corners of a rectangle
 */
void PQRectCornersAsPoints(NSRect rect, NSPoint *topLeft, NSPoint *topRight, NSPoint *bottomLeft, NSPoint *bottomRight);

NSPoint PQOffsetPoint(NSPoint p, float xOffset, float yOffset);

/**
 * Returns a rect centered in 'aRect' with the specified aspectRatio
 */
NSRect PQMakeCenteredRectInRectWithAspectRatio(NSRect aRect, float aspectRatio);

/**
 * Centers bRect in aRect
 */
NSRect PQCenterInRect(NSRect aRect, NSRect bRect);

/**
 * Calculates aspect ratio of rect
 */
float PQCalcAspectRatio(NSRect rect);
