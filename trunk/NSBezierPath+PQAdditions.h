/**
 * \file NSBezierPath+PQAdditions.h
 *
 * Copyright plasq LLC 2007. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

/**
 * Category for implementing Plasq extensions
 *
 * \ingroup AppKitCategories
 */
@interface NSBezierPath (PQAdditions)

#pragma mark Strings

+ (NSBezierPath *)bezierPathWithType:(int)type rect:(NSRect)rect radius:(float)radius pointCount:(int)count pointOffset:(float)pointOffset;

/*
 * Returns a bezier path from the given string and font
 */
+ (NSBezierPath *) bezierPathFromString: (NSString *)string
								forFont: (NSFont *)font;

+ (NSBezierPath*)bezierPathWithInsetRoundedRect:(NSRect)rect radius: (float)radius;
- (void) appendBezierPathWithInsetRoundedRect:(NSRect)aRect radius:(float) radius;

+ (NSBezierPath*)bezierPathWithBeveledRect:(NSRect)rect radius: (float)radius;
- (void) appendBezierPathWithBeveledRect:(NSRect)aRect radius:(float) radius;

+ (NSBezierPath*)bezierPathWithSkewedRect:(NSRect)rect radius: (float)radius;
- (void) appendBezierPathWithSkewedRect:(NSRect)aRect radius:(float) radius;

+ (NSBezierPath*)bezierPathWithInsetSquareRect:(NSRect)rect radius: (float)radius;
- (void) appendBezierPathWithInsetSquareRect:(NSRect)aRect radius:(float) radius;

+ (NSBezierPath*)bezierPathWithDiamondInRect:(NSRect)rect;
- (void) appendBezierPathWithDiamondInRect:(NSRect)aRect;

+ (NSBezierPath*)bezierPathWithTriangleInRect:(NSRect)rect;
- (void) appendBezierPathWithTriangleInRect:(NSRect)aRect;

+ (NSBezierPath*)bezierPathWithRightTriangleInRect:(NSRect)rect;
- (void) appendBezierPathWithRightTriangleInRect:(NSRect)aRect;

+ (NSBezierPath*)bezierPathWithArrowInRect: (NSRect)rect inset: (NSPoint)point;
- (void)appendBezierPathWithArrowInRect: (NSRect)rect inset: (NSPoint)point;

+ (NSBezierPath*)bezierPathWithDoubleArrowInRect: (NSRect)rect inset: (NSPoint)point;
- (void)appendBezierPathWithDoubleArrowInRect: (NSRect)rect inset: (NSPoint)point;

+ (NSBezierPath*)bezierPathWithArrowheadInRect: (NSRect)rect inset: (float)inset;
- (void)appendBezierPathWithArrowheadInRect: (NSRect)rect inset: (float)inset;

+ (NSBezierPath*)bezierPathWithStarInRect: (NSRect)rect offset: (float)offset count: (int)count;
- (void)appendBezierPathWithStarInRect: (NSRect)rect offset: (float)offset count: (int)count;

+ (NSBezierPath*)bezierPathWithCogInRect: (NSRect)rect offset: (float)offset count: (int)count;
- (void)appendBezierPathWithCogInRect: (NSRect)rect offset: (float)offset count: (int)count;

+ (NSBezierPath*)bezierPathWithHedronInRect: (NSRect)rect count: (int)count;
- (void)appendBezierPathWithHedronInRect: (NSRect)rect count: (int)count;

+ (NSBezierPath*)bezierPathWithArcInRect: (NSRect)rect;
- (void)appendBezierPathWithArcInRect: (NSRect)rect;

+ (NSBezierPath*)bezierPathWithSemiOvalInRect: (NSRect)rect;
- (void)appendBezierPathWithSemiOvalInRect: (NSRect)rect;

+ (NSBezierPath*)bezierPathWithBulgingRect:(NSRect)rect bulge: (float)bulge;
- (void) appendBezierPathWithBulgingRect:(NSRect)aRect bulge:(float) bulge;

+ (NSBezierPath*)bezierPathWithTrapezoidInRect:(NSRect)rect inset: (float)inset;
- (void) appendBezierPathWithTrapezoidInRect:(NSRect)aRect inset:(float) inset;

//+ (NSBezierPath*)bezierPathWithCloudInRect:(NSRect)aRect offset:(float)offset count:(int)count;
//- (void)appendBezierPathWithCloudInRect:(NSRect)aRect offset:(float)offset count:(int)count;

+ (NSBezierPath*)bezierPathWithExclaimInRect:(NSRect)aRect offset:(float)offset count:(int)count;
- (void)appendBezierPathWithExclaimInRect:(NSRect)aRect offset:(float)offset count:(int)count;

+ (NSBezierPath*)bezierPathWithExclaim2InRect:(NSRect)aRect offset:(float)offset count:(int)count;
- (void)appendBezierPathWithExclaim2InRect:(NSRect)rect offset:(float)offset count:(int)count;

+ (NSBezierPath*)bezierPathWithRoughOvalInRect:(NSRect)aRect roughness:(int)roughness;
- (void)appendBezierPathWithRoughOvalInRect:(NSRect)rect roughness:(int)roughness;

+ (NSBezierPath*)bezierPathWithSpaceOvalInRect:(NSRect)aRect offset:(float)offset;
- (void)appendBezierPathWithSpaceOvalInRect:(NSRect)rect offset:(float)offset;

/** clump in groups of 5 for easy mapping to the palette order */
enum {
	kSmartShapeTypeRectangle,
	kSmartShapeTypeOval,
	kSmartShapeTypeDiamond,
	kSmartShapeTypeTriangle,
	kSmartShapeTypeHedron,

	kSmartShapeTypeRightTriangle,
	kSmartShapeTypeArc,
	kSmartShapeTypeSemiOval,
	kSmartShapeTypeBulge,
	kSmartShapeTypeTrapezoid,
	
	kSmartShapeTypeRounded,
	kSmartShapeTypeInsetRounded,
	kSmartShapeTypeBeveled,
	kSmartShapeTypeInsetSquare,
	kSmartShapeTypeSkewed,
	
	kSmartShapeTypeStar,
	kSmartShapeTypeCog,
	kSmartShapeTypeArrow,
	kSmartShapeTypeDoubleArrow,
	kSmartShapeTypeArrowHead,
	
	kSmartShapeTypeExclaim,
	kSmartShapeTypeExclaim2,
	kSmartShapeTypeRough,
	kSmartShapeTypeSpace,
	
	kSmartShapeTypeEnd
};

+ (NSBezierPath*)bezierPathWithSmartShapeRect:(NSRect)rect forObject:(id)object;

/**
 * Returns the bounds of the path, including the stroke property (line width, etc)
 */
- (NSRect) strokedBounds;

@end
