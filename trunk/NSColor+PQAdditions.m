//
//  NSColor+PQAdditions.m
//
//  Copyright plasq LLC 2007. All rights reserved.

#import <Cocoa/Cocoa.h>
#import "NSColor+PQAdditions.h"

@implementation NSColor (PQAdditions)

#pragma mark Equality

/*
 * If 'object' is not an NSColor, returns [super isEqualTo: object].
 *
 * If it is an NSColor, returns YES if components and colorspace 
 * are equal (in terms of ==) -- unless that throws an exception, which it
 * will for system colors. In that case, we check colorSpaceName and 
 */
- (BOOL)isEqualToValueOfObject: (id)object
{
	// Defer to super unless self and other are both NSColors

	if (![object isKindOfClass: [NSColor class]])
		return [super isEqualTo: object];
	
	NSColor* other = (NSColor*)object;

	// Here we start down the path that is valid for custom colors. If we've hit
	// a system-defined color, NSColor will throw an exception in -colorSpace

	@try {
		if (![[self colorSpaceName] isEqualToString: [other colorSpaceName]])
			return NO;

		int numberOfSelfComponents = [self numberOfComponents];
		int numberOfOtherComponents = [other numberOfComponents];
		
		if (numberOfSelfComponents != numberOfOtherComponents) 
			return NO;
		
		CGFloat* selfComponents = malloc(sizeof(CGFloat*) * numberOfSelfComponents);
		[self getComponents: selfComponents];
		
		CGFloat* otherComponents = malloc(sizeof(CGFloat*) * numberOfOtherComponents);
		[other getComponents: otherComponents];
		
		int i;
	
		BOOL equal = YES;

		for (i = 0; i < numberOfSelfComponents; i++) 
			if (selfComponents[i] != otherComponents[i])
				equal = NO;

		free(selfComponents);
		free(otherComponents);

		return equal;
	}
	@catch (NSException* exception) {

		// System-defined colors have names looked up in tables. So look 'em up.

		NSString* selfCatalogName = [self localizedCatalogNameComponent];	
		NSString* selfName = [self localizedColorNameComponent];
		NSString* otherCatalogName = [other localizedCatalogNameComponent];
		NSString* otherName = [other localizedColorNameComponent];

		return [selfCatalogName isEqualToString: otherCatalogName] && [selfName isEqualToString: otherName];
	}
	return NO;
}

- (NSColor*)monoContrastColor
{
	NSColor* color = [self colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
	float brightness = [color brightnessComponent];
	if (brightness > .5)
		brightness = 0;
	else
		brightness = 1;
	return [NSColor colorWithCalibratedWhite: brightness alpha: 1];
}

#pragma mark crisColor

+ (NSColor *)crisColor:(uint32_t)color alpha:(float)alpha
{
	float red = ((color>>16)&0xff)/255.f;
	float green = ((color>>8)&0xff)/255.f;
	float blue = ((color)&0xff)/255.f;
	return [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:alpha];
}

@end

NSColor* NSColorFromString(NSString* string)
{
	const char* str = [string UTF8String];
	float r, g, b, a;
	sscanf(str, "%f %f %f %f", &r, &g, &b, &a);
	return [NSColor colorWithCalibratedRed: r green: g blue: b alpha: a];
}

NSString* NSStringFromColor(NSColor* color)
{
	float r, g, b, a;
	NSColor* c = [color colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
	[c getRed: &r green: &g blue: &b alpha: &a];
	return [NSString stringWithFormat: @"%f %f %f %f", r, g, b, a];
}
