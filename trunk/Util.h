/**
 * \file Util.h
 *
 * Copyright plasq LLC 2007. All rights reserved.
 */
#import <Cocoa/Cocoa.h>

/**
 * Placeholder class for additional scaffolding required by
 * Rects-on-Pages
 *
 * \ingroup Utilities
 */
@interface Util : NSObject
{
}

/**
 * Round a float to n decimal place
 */

float roundValue(float value, int decimalPlaces);

/**
 * Returns a random float in the specified range
 */
+ (float)randomFloatFrom: (float)min to: (float)max;
+ (float)percentage:(float)percent of:(float)amount;

@end

@interface NSArray (SelectionExtensions)

- (id)firstObject;

@end

@interface NSAffineTransform (PQPathExentsions)

+ (NSAffineTransform *)transformToFitPath:(NSBezierPath *)buttonAreaPath toRect:(NSRect)rect;

@end