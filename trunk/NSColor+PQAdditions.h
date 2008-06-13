/**
 * \file NSColor+PQAdditions.h
 *
 * Copyright plasq LLC 2007. All rights reserved.
 */
#import <Cocoa/Cocoa.h>

/**
 * Category for implementing Plasq extensions
 *
 * \ingroup AppKitCategories
 */
@interface NSColor (PQAdditions)

#pragma mark Equality

/** 
 * Returns YES if the two objects are =
 */
- (BOOL)isEqualToValueOfObject: (id)object;

// Returns a color that gives good contrast to this color.
- (NSColor*)monoContrastColor;

#pragma mark crisColor

/** Returns a color from a 0xRRGGBB+alpha format */
+ (NSColor *)crisColor:(uint32_t)color alpha:(float)alpha;

@end

NSColor* NSColorFromString(NSString* string);
NSString* NSStringFromColor(NSColor* color);
