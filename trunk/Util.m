//
//  Util.m
//
//  Copyright plasq LLC 2007 . All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "Util.h"

@implementation Util

/**
 * Round a float to n decimal place
 */

float roundValue(float value, int decimalPlaces)
{
	float power = pow(10.0, (float)decimalPlaces);
	value = round(value*power);
	value = value/power;
	return value;
}

/*
 * Returns a pseudorandom number in the specified range
 */
+(float)randomFloatFrom: (float)min to: (float)max
{
	int randomValue = (rand() >> 4) % 100;
	float scale = randomValue / 100.f;
	float range = max - min;
	float scaledRange = range * scale;
	float newValue = min + scaledRange;
	return newValue;
}
+ (float)percentage:(float)percent of:(float)amount
{
	return (amount - (percent / 100 * amount));	
}

@end


@implementation NSArray (SelectionExtensions)

- (id)firstObject
{
	if([self count] != 0) {
		return [self objectAtIndex:0];
	}
	return nil;
}

@end

@implementation  NSAffineTransform (PQPathExentsions)

+ (NSAffineTransform *)transformToFitPath:(NSBezierPath *)buttonAreaPath toRect:(NSRect)rect
{
	NSAffineTransform *transform = [NSAffineTransform transform];
	NSRect pathBounds = [buttonAreaPath bounds];
	float ratio = 1.0;
	
	ratio = MIN( rect.size.width/pathBounds.size.width,  
				rect.size.height/pathBounds.size.height );
	[transform scaleBy:ratio];
	[transform translateXBy:-pathBounds.origin.x yBy:-pathBounds.origin.y];
	return transform;
}

@end

