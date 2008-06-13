//
//  PQGradient.m
//  Comic Life
//
//  Created by Robert Grant on 8/26/07.
//  Copyright 2007 plasq LLC. All rights reserved.
//

#import "NSColor+PQAdditions.h"

#import "PQGradient.h"

@implementation NSColor (RandomColor)

+ (NSColor *)randomColor
{
	float r1, r2, r3;
	srandomdev();
	r1 = (float)((double)random()/(double)LONG_MAX);
	r2 = (float)((double)random()/(double)LONG_MAX);
	r3 = (float)((double)random()/(double)LONG_MAX);
	return [NSColor colorWithCalibratedRed:r1 green:r2 blue:r3 alpha:1.0];
}

@end


@implementation PQColorStop

@synthesize offset = _offset;
@synthesize color = _color;


- (id)initWithColor:(NSColor*)color offset:(float)offset
{
	if (self = [super init]) {
		self.offset = offset;
		self.color = color;
	}
	return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
	if (self = [super init]) {
		self.offset = [coder decodeFloatForKey: @"offset"];
		self.color = [coder decodeObjectForKey: @"color"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
	[coder encodeFloat: self.offset forKey: @"offset"];
	[coder encodeObject: self.color forKey: @"color"];
}

- (id)copyWithZone:(NSZone *)zone
{
	PQColorStop *copy = [[[self class] allocWithZone:zone] init];
	copy.offset = self.offset;
	copy.color = [self.color copy];
	return copy;
}

- (NSString*)description
{
	return [NSString stringWithFormat: @"c: %@ o: %f", self.color, self.offset];
}

@end

@implementation PQGradient

@synthesize type = _type;
@synthesize angle = _angle;
@synthesize offset = _offset;
@synthesize	colorStops = _colorStops;


+ (PQGradient *)randomGradient
{
	PQGradient *grad = [[PQGradient alloc] init];
	[grad addColorStopWithColor:[NSColor randomColor] atOffset:0.0];
	[grad addColorStopWithColor:[NSColor randomColor] atOffset:1.0];
	return [[grad retain] autorelease];
}

// Default initializer creates a linear gradient between white and black
- (id)init
{
	if (self = [super init]) {
		self.colorStops = [[[NSMutableArray alloc] init] retain];
		[self addColorStopWithColor: [NSColor whiteColor] atOffset: 0];
		[self addColorStopWithColor: [NSColor blackColor] atOffset: 1];
		_type = kPQCircularGradientType;
	}
	return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
	if (self = [super init]) {
		self.type = [coder decodeIntegerForKey: @"type"];
		self.angle = [coder decodeFloatForKey: @"angle"];
		self.offset = [coder decodePointForKey: @"offset"];
		self.colorStops = [coder decodeObjectForKey: @"colorStops"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
	[coder encodeInteger: self.type forKey: @"type"];
	[coder encodeFloat: self.angle forKey: @"angle"];
	[coder encodePoint: self.offset forKey: @"offset"];
	[coder encodeObject: self.colorStops forKey: @"colorStops"];
}

- (id)copyWithZone:(NSZone *)zone
{
	PQGradient *copy = [[[self class] allocWithZone:zone] init];

	while ([copy countOfColorStops])
		[copy removeObjectFromColorStopsAtIndex: 0];
		
	for (PQColorStop* stop in self.colorStops) {
		[copy addColorStopWithColor: stop.color atOffset: stop.offset];
	}
	
	copy.angle =  self.angle;
	copy.offset = self.offset;
	copy.type = self.type;
	
	return copy;
}

- (void)addColorStopWithColor: (NSColor*)color atOffset: (float)offset
{
	PQColorStop* stop = [[PQColorStop alloc] initWithColor: color offset: offset];
	[self insertObject: stop inColorStopsAtIndex: [self countOfColorStops]];
}

// Convert all colorstops to RGB and return them in an array - gradients like to be in a single colorspace
- (NSArray*)_rgbColors
{
	NSMutableArray* rgbColors = [[[NSMutableArray alloc] init] autorelease];
	if (self.colorStops) {
		for (PQColorStop* stop in self.colorStops) {
			id obj = [stop.color colorUsingColorSpace: [NSColorSpace genericRGBColorSpace]];
			if (obj)[rgbColors addObject:obj];
		}	
		return rgbColors;
	}
	return nil;
	

}

// Put all the offsets into a pre-alloc'd CGFloat array
- (void)_offsets:(CGFloat*)offsets
{
	int i = 0;
	for (PQColorStop* stop in self.colorStops) {
		offsets[i] = stop.offset;
		i++;
	}
}

// Create a gradient object from our settings
- (NSGradient*)gradient
{
	NSArray* colors = [self _rgbColors];
	CGFloat* offsets = malloc(sizeof(CGFloat)*[colors count]);
	[self _offsets: offsets];
	NSGradient* gradient = [[NSGradient alloc] initWithColors: colors atLocations: offsets colorSpace: [NSColorSpace genericRGBColorSpace]];
	free(offsets);
	return gradient;
}

- (void)fillPath:(NSBezierPath*)path
{
	NSGradient* gradient = [self gradient];

	if (_type == kPQLinearGradientType) {
		[gradient drawInBezierPath: path angle: self.angle];
	}
	else if (_type == kPQCircularGradientType) {
		[gradient drawInBezierPath: path relativeCenterPosition: _offset];
	}
	else {
		NSAssert(_type, @"Unknown PQGradient type");
	}
}

// KVO
- (int)countOfColorStops
{
	return [self.colorStops count];
}

- (void)insertObject:(id)object inColorStopsAtIndex:(unsigned)index
{
	[self.colorStops insertObject: object atIndex: index];
}

- (void)removeObjectFromColorStopsAtIndex:(unsigned)index
{
	[self.colorStops removeObjectAtIndex: index];
}

// Plist support

static NSString* kGradientTypeKey = @"GradientType";
static NSString* kGradientAngleKey = @"GradientAngle";
static NSString* kGradientOffsetKey = @"GradientOffset";
static NSString* kGradientColorStopsKey = @"GradientColorStops";
static NSString* kColorStopOffsetKey = @"ColorStopOffset";
static NSString* kColorStopColorKey = @"ColorStopColor";

- (id)initWithDictionary:(NSDictionary*)dictionary
{
	if (self = [super init]) {
		_type = [[dictionary objectForKey: kGradientTypeKey] intValue];
		_angle = [[dictionary objectForKey: kGradientAngleKey] floatValue];
		_offset = NSPointFromString([dictionary objectForKey: kGradientOffsetKey]);
		self.colorStops = [[[NSMutableArray alloc] init] retain];
		NSArray* colorDicts = [dictionary objectForKey: kGradientColorStopsKey];
		for (NSDictionary* colorDict in colorDicts) {
			float offset = [[colorDict objectForKey: kColorStopOffsetKey] floatValue];
			NSColor* color = NSColorFromString([colorDict objectForKey: kColorStopColorKey]);
			[self addColorStopWithColor: color atOffset: offset];
		}
	}
	return self;
}

- (NSDictionary*)dictionary
{
	NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
	[dictionary setObject: [NSNumber numberWithInt: _type] forKey: kGradientTypeKey];
	[dictionary setObject: [NSNumber numberWithFloat: _angle] forKey: kGradientAngleKey];
	[dictionary setObject: NSStringFromPoint(_offset) forKey: kGradientOffsetKey];
	NSMutableArray* colorstops = [[[[NSMutableArray alloc] init] retain] autorelease];
	for (PQColorStop* stop in self.colorStops) {
		NSMutableDictionary* stopDict = [[[[NSMutableDictionary alloc] init] retain] autorelease];
		[stopDict setObject: [NSNumber numberWithFloat: stop.offset] forKey: kColorStopOffsetKey];
		[stopDict setObject: NSStringFromColor( stop.color ) forKey: kColorStopColorKey];
		[colorstops addObject: stopDict];
	}
	[dictionary setObject: colorstops forKey: kGradientColorStopsKey];
	
	return [[dictionary retain] autorelease];
}

@end
