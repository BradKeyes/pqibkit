/**
 * \file PQGradient.h
 *
 * Copyright plasq LLC 2007. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

/**
 * Tracks a color/offset pair
 *
 * \ingroup AppKit
 */
@interface PQColorStop : NSObject <NSCopying, NSCoding> {
	
	float		_offset;
	NSColor*	_color;
}

@property(assign) float offset;
@property(copy) NSColor* color;

- (id)initWithColor:(NSColor*)color offset:(float)offset;

@end

enum {
	kPQLinearGradientType = 0,
	kPQCircularGradientType = 1
};

/**
 * A facade for NSGradient that remembers the desired settings and
 * provides a simple drawing interface
 *
 * \ingroup AppKit
 */

@interface NSColor (RandomColor)

// Generate a random color (good for locating redraws when debugging).
+ (NSColor *)randomColor;

@end

@interface PQGradient : NSObject <NSCopying, NSCoding> {

	NSUInteger	_type;
	float		_angle;		// used for linear gradients
	NSPoint		_offset;	// used for circular gradients

	NSMutableArray *_colorStops;
}

@property(assign) NSUInteger type;
@property(assign) float angle;
@property(assign) NSPoint offset;
@property(retain) NSMutableArray *colorStops;

+ (PQGradient *)randomGradient;

- (void)addColorStopWithColor: (NSColor*)color atOffset:(float)offset;

- (void)fillPath:(NSBezierPath*)path;

- (NSGradient*)gradient;

// KVO support
- (int)countOfColorStops;

- (void)insertObject:(id)object inColorStopsAtIndex:(unsigned)index;

- (void)removeObjectFromColorStopsAtIndex:(unsigned)index;

// Plist support
- (id)initWithDictionary:(NSDictionary*)dictionary;

- (NSDictionary*)dictionary;

@end
