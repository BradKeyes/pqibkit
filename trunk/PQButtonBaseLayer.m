//
//  PQButtonBaseLayer.m
//  PQIBKit
//
//  Created by Mathieu Tozer on 23/06/07.
//  Copyright 2007 plasq. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "PQButtonBaseLayer.h"
#import "PQButtonPath.h"
#import "PQButton.h"
#import "PQButtonState.h"
#import "PQButtonValueUnit.h"
#import <CocoaExtender/CocoaExtender.h>

@implementation CALayer (PQButtonBaseLayer)

- (NSArray *)allLayers
{
	//recurse through the layer tree
	NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
	[array addObject:self];
	for (PQButtonBaseLayer *layer in [(PQButtonBaseLayer *)self layers]) {
		[array addObjectsFromArray:[layer allLayers]];
	}
	return array;
}

//for backwards compatability
- (NSArray *)layers
{
	return self.sublayers;
}

- (BOOL)isButtonLayer
{
	return [self isKindOfClass:[PQButtonBaseLayer class]];
}

@end


@implementation PQButtonBaseLayer

// uses this to inspect the state of the button when drawing.
@synthesize buttonBase = _buttonBase;
@synthesize statesToValueUnits = _statesToValueUnits;
@synthesize layerName = _layerName;
@synthesize textLayer = _textLayer;
@synthesize current3DTransformation = _current3DTransformation;
@synthesize isBaseLayer = _isBaseLayer;

- (id)animationForKey:(NSString *)key {
	NSLog(@"asking for animation for key: %@", key);
	return [super animationForKey:key];
}

+ (NSArray *)keypaths
{
	return [NSArray arrayWithObjects:@"statesToValueUnits", @"layerName", @"selValUnit", @"subviews", @"isBaseLayer", nil];
}

+ (NSArray *)attributeKeypaths
{
	return [NSArray arrayWithObjects: @"layerName", @"isBaseLayer", nil];
}

+ (NSArray *)toManyKeypaths
{
	return [NSArray arrayWithObjects:@"subviews", nil];
}

+ (NSArray *)scalableKeypaths
{
	NSMutableArray *keypaths = [[[[NSMutableArray alloc] init] retain] autorelease];
	[keypaths addObjectsFromArray:[PQButtonValueUnit scalableKeypaths]];
	return keypaths;
}

#pragma mark Layers

- (unsigned int)countOfLayers
{
	return [[self layers] count];
}

- (id)objectInLayersAtIndex:(unsigned int)index
{
	if (index >= [self countOfLayers])
        return nil;
	return [[self layers] objectAtIndex:index];
}

- (void)removeObjectFromLayersAtIndex:(unsigned int)index
{
	PQButtonBaseLayer *layer = [[self layers] objectAtIndex:index];
	[layer removeFromSuperlayer];
}

- (void)insertObject:(id)anObject inLayersAtIndex:(unsigned int)index
{
	[(PQButtonBaseLayer *)anObject setButtonBase: self.buttonBase];
	[self insertSublayer:anObject atIndex:index];
	[self.buttonBase makeSureEachValueUnitIsOwnedByUs];
}

- (NSArray *)layers
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isButtonLayer == YES"];
    return [[self sublayers] filteredArrayUsingPredicate:predicate];
}

- (void)setLayers:(NSArray *)layers
{
}


- (BOOL)hasValueObjectForState:(PQButtonState *)state
{
	NSMutableDictionary *dict = self.statesToValueUnits;
	PQButtonValueUnit * unit = [dict objectForKey:state.stateKey];
	if (unit) return YES;
	return NO;
}

- (PQButtonValueUnit *)createValueObjectForState:(PQButtonState *)state
{
	NSMutableDictionary *dict = self.statesToValueUnits;
	PQButtonValueUnit *newUnit = [[[[PQButtonValueUnit alloc] init] retain] autorelease];
	[dict setObject:newUnit forKey:state.stateKey];
	self.statesToValueUnits = dict;
	return newUnit;
}

- (void)commonInit
{
	_current3DTransformation = nil;
	self.statesToValueUnits = [[[[NSMutableDictionary alloc] init] retain] autorelease];
	self.layerName = @"New Layer";
	self.isBaseLayer = NO;
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		[self commonInit];
	}
	return self;
}


- (id)initWithButtonBase:(PQButton *)buttonBase
{
	self = [super init];
	if (self != nil) {
		[self commonInit];
		self.buttonBase = buttonBase;
	}
	return self;
}

		 
//that's one of my favorite shots of me. - Mr. G
- (id)initWithCoder:(NSCoder *)coder 
{
	self = [super initWithCoder:coder];
	if ([coder allowsKeyedCoding]) {
		_current3DTransformation = nil;
		self.statesToValueUnits = [[[[NSMutableDictionary alloc] initWithDictionary:[coder decodeObjectForKey:@"statesToValueUnits"]] retain] autorelease];
		self.layerName = [coder decodeObjectForKey:@"layerName"];
		self.isBaseLayer = [coder decodeBoolForKey:@"isBaseLayer"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder 
{
    [super encodeWithCoder:coder];
    if ([coder allowsKeyedCoding]) {
		[coder encodeObject:self.layerName forKey:@"layerName"];
		[coder encodeObject:self.statesToValueUnits forKey:@"statesToValueUnits"];
		[coder encodeBool:self.isBaseLayer forKey:@"isBaseLayer"];
    }
	return;
}

#pragma mark Drawing

- (void)drawIcon:(PQButtonValueUnit *)unit
{
	
	//ask the delegate for an icon
	id delegate = [_buttonBase delegate];
	if ([delegate respondsToSelector:@selector(drawIconInLayer:)]) {
		[delegate drawIconInLayer:self];
		return;
	}
	
	NSImage *icon = nil;
	NSString *iconName = unit.iconName;
	if (iconName) {
		icon = [NSImage imageNamed:iconName];
		NSRect imgRect = NSRectFromCGRect([self frame]);
		imgRect.origin = NSZeroPoint;
		[icon drawInRect:imgRect fromRect:NSZeroRect operation:unit.iconCompositingOp fraction:1.0];
		return;
	}
	
	//nothing named that so look for an an icon NSImage
	icon = unit.icon;
	if (icon) {
		NSRect imgRect = NSRectFromCGRect([self bounds]);
		[icon drawInRect:imgRect fromRect:NSZeroRect operation:unit.iconCompositingOp fraction:1.0];
		return;
	}

}

//also set ourselves to be the delegate of our layer, so we are asked to draw its contents. This will likely change when 
//we get around to removing layer backed-ness and going for a cleaner and probably more efficient all layer implementation.
- (void)drawInContext:(CGContextRef)ctx
{
	NSGraphicsContext *nsGraphicsContext;
	nsGraphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:ctx
																   flipped:NO];
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:nsGraphicsContext];
	PQButtonState *curState = self.buttonBase.currentState;
	PQButtonValueUnit *valueUnit = [self.statesToValueUnits objectForKey:curState.stateKey];
	
	if (valueUnit.doesDrawGradient && !self.isBaseLayer) {
		id delegate = [_buttonBase delegate];
		if ([delegate respondsToSelector:@selector(drawLayer:)]) {
			[delegate drawLayer:self];
		} else {
			NSBezierPath *buttonAreaPath = nil;
			
			[[NSGraphicsContext currentContext] setCompositingOperation:valueUnit.compositingOp];
			if ([delegate respondsToSelector:@selector(bezierPathForLayer:)]) {
				buttonAreaPath = [delegate bezierPathForLayer:self];
			} else {
				if (valueUnit.path == nil) {
					//see if we can get a path drawn using the values instead
					buttonAreaPath = [NSBezierPath bezierPathWithType:valueUnit.pathType rect:valueUnit.frame radius:valueUnit.pathRadius pointCount:valueUnit.pathPointCount pointOffset:valueUnit.pathPointOffset];
				} else {
					buttonAreaPath = [valueUnit.path bezierPath];	
				}	
			}
			
			//might have to scale to the right and current layer size?
			if (!buttonAreaPath) {
				//this should never actually be the case anymore.
				buttonAreaPath = [NSBezierPath bezierPathWithRoundedRect:NSRectFromCGRect(self.bounds) xRadius:valueUnit.cornerRadius yRadius:valueUnit.cornerRadius];	
			} else {
				[buttonAreaPath transformUsingAffineTransform:[NSAffineTransform transformToFitPath:buttonAreaPath toRect:NSRectFromCGRect(self.bounds)]];
			}
			
//			if (valueUnit.rotation != 0.0) {
//				NSAffineTransform *pathRotation = [NSAffineTransform transformToRotateByDegrees:valueUnit.rotation aroundPoint:NSMakePoint(NSMidX(NSRectFromCGRect(self.bounds)), NSMidY(NSRectFromCGRect(self.bounds)))];
//				[buttonAreaPath transformUsingAffineTransform:pathRotation];
//			}
			
			[valueUnit.gradient fillPath:buttonAreaPath];		
		}		
	}
		

	//draw the icon 
	[self drawIcon:valueUnit];
	[NSGraphicsContext restoreGraphicsState];
}

static CGColorRef CGColorCreateFromNSColor (CGColorSpaceRef colorSpace, NSColor *color) {
	NSColor *deviceColor = [color colorUsingColorSpaceName:NSDeviceRGBColorSpace];
	
	float components[4];
	[deviceColor getRed: &components[0] green: &components[1] blue: &components[2] alpha: &components[3]];
	
	return CGColorCreate (colorSpace, components);
}

- (PQButtonState *)state
{
	return _buttonBase.currentState;
}

/*
 // create the path for the keyframe animation 
 CGMutablePathRef thePath = CGPathCreateMutable();
 CGPathMoveToPoint(thePath,NULL,15.0f,15.f);
 CGPathAddCurveToPoint(thePath,NULL,
 15.f,250.0f,
 295.0f,250.0f,
 295.0f,15.0f);
 
 // create an explicit keyframe animation that
 // animates the target layer's position property
 // and set the animation's path property
 CAKeyframeAnimation *theAnimation=[CAKeyframeAnimation 
 animationWithKeyPath:@"position"];
 theAnimation.path=thePath;
 
 // create an animation group and add the keyframe animation
 CAAnimationGroup *theGroup = [CAAnimationGroup animation];
 theGroup.animations=[NSArray arrayWithObject:theAnimation];
 
 // set the timing function for the group and the animation duration
 theGroup.timingFunction=[CAMediaTimingFunction 
 functionWithName:kCAMediaTimingFunctionEaseIn];
 theGroup.duration=15.0;
 
 // adding the animation to the target layer causes it 
 // to begin animating
 [theLayer addAnimation:theGroup forKey:@"animatePosition"];
 */

//so my policy is to use the CATransforms for little bursts where the path does not need to scale and change - IE be redrawn?

- (PQButtonValueUnit *)valueUnitForState:(PQButtonState *)state
{
	PQButtonValueUnit *unit = [self.statesToValueUnits objectForKey:state.stateKey];
	if (!unit) {
		unit = [self createValueObjectForState:state];
	}
	return unit;
}



- (CAKeyframeAnimation *)bounceAnimationWithBounceName:(NSString *)bounceOpName andValueUnit:(PQButtonValueUnit *)valUnit
{
	NSValue *initialRect = nil;
	if (self.current3DTransformation) {
		initialRect = self.current3DTransformation;
	} else {
		initialRect = [NSValue valueWithCATransform3D: CATransform3DMakeScale(valUnit.scaleSX, valUnit.scaleSY, valUnit.scaleSZ)];
	}
	//it's either the current (ie the precvious last frame) or something initial. Probably wont ever see that state.
	NSValue *frame = [NSValue valueWithCATransform3D: CATransform3DMakeScale(valUnit.scaleSX, valUnit.scaleSY, valUnit.scaleSZ)];  //this is our end size.
	NSValue *largeBounceFrame = [NSValue valueWithCATransform3D: CATransform3DMakeScale(valUnit.scaleSX+.3, valUnit.scaleSY+.2, valUnit.scaleSZ)];
	NSValue *smallBounceFrame = [NSValue valueWithCATransform3D: CATransform3DMakeScale(valUnit.scaleSX-.3, valUnit.scaleSY-.2, valUnit.scaleSZ)];
	CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
	popAnimation.values = [NSArray arrayWithObjects:
						   initialRect, 
						   largeBounceFrame, 
						   smallBounceFrame, 
						   frame, 
						   nil];
	
	popAnimation.keyTimes = [NSArray arrayWithObjects:
							 [NSNumber numberWithFloat:0.0], 
							 [NSNumber numberWithFloat:0.75], 
							 [NSNumber numberWithFloat:1.0], 
//							 [NSNumber numberWithFloat:1.0], 
							 nil];
	[popAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	return [[popAnimation retain] autorelease];
}

- (void)animateFrameChange
{
	[NSAnimationContext beginGrouping];
	PQButtonState *curState = self.buttonBase.currentState;
	
	PQButtonValueUnit *valueUnit = [self.statesToValueUnits objectForKey:curState.stateKey];
	NSAssert(@"value unit was nil and never should be", nil);
	if (!valueUnit) return;

	[[NSAnimationContext currentContext] setDuration:valueUnit.toDuration];
	NSRect rect = valueUnit.frame;
	if (valueUnit.animationOption) {
		CATransform3D scale = CATransform3DMakeScale(valueUnit.scaleSX, valueUnit.scaleSY, valueUnit.scaleSZ);
		self.current3DTransformation = [NSValue valueWithCATransform3D:scale];
		CATransform3D translate = CATransform3DMakeTranslation(valueUnit.transTX, valueUnit.transTY, valueUnit.transTZ);
		self.transform = CATransform3DConcat(scale, translate);
		self.frame = *(CGRect*)&rect;
	} else {
		self.frame = *(CGRect*)&rect;
		self.cornerRadius = valueUnit.cornerRadius;	
	}
	[NSAnimationContext endGrouping];
}

- (void)animateRotation
{
	PQButtonState *curState = self.buttonBase.currentState;
	PQButtonValueUnit *valueUnit = [self.statesToValueUnits objectForKey:curState.stateKey];
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:valueUnit.toDuration] forKey:kCATransactionAnimationDuration];
	
	//		float scaleSX, scaleSY, scaleSZ;
	//		float transTX, transTY, transTZ;
	//		float rotRX, rotRY, rotRZ;
	
	CATransform3D transform = CATransform3DMakeScale(valueUnit.scaleSX, valueUnit.scaleSY, valueUnit.scaleSZ);
	float radians = valueUnit.rotation * (M_PI / 180);
	transform = CATransform3DRotate(transform, radians, valueUnit.rotRX, valueUnit.rotRY, valueUnit.rotRZ);
	transform = CATransform3DTranslate(transform, valueUnit.transTX, valueUnit.transTY, valueUnit.transTZ);
	self.transform = transform;
	
	CATransform3D perspectiveTransform = CATransform3DIdentity;
	if (valueUnit.distortionInNewmans)
		perspectiveTransform.m34 = 1.0 / valueUnit.distortionInNewmans;
	
	self.superlayer.sublayerTransform = perspectiveTransform;
	
	[CATransaction commit];
}

#pragma mark Title Layer

- (void)removeTitleLayer
{
	//remove any exiting 'stuck' ones
	NSArray *titles = [[self sublayers] copy];
	for (CALayer *layer in titles) {
		if ([layer isKindOfClass:[CATextLayer class]]) {
			[layer removeFromSuperlayer];
		}
	}
	if (self.textLayer) {
		[self.textLayer removeFromSuperlayer];
		self.textLayer = nil;
	}
}

- (void)createAndConfigureTitleLayer
{
	[self removeTitleLayer]; //remove the old one
	CATextLayer *titleLayer = [[[[CATextLayer alloc] init] retain] autorelease];
	self.textLayer = titleLayer;
	[self addSublayer:titleLayer];
}

- (void)addTitleLayerFromUnit:(PQButtonValueUnit *)unit
{
	//first determine if there is actually an attributedString to place on the layer
	if ([unit.title length] > 0) {
		//create the layer if there isn't one already
		if (!self.textLayer) {
			[self createAndConfigureTitleLayer];
		}
		self.textLayer.frame = unit.cgTitleFrame;
		if (unit.title) {
			self.textLayer.string = unit.title;	
		} else {
			self.textLayer.string = @"";	
		}
		self.textLayer.alignmentMode = unit.textAlignmentMode;
		self.textLayer.truncationMode = unit.textTruncationMode;
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB ();
		self.textLayer.foregroundColor = CGColorCreateFromNSColor(colorSpace, unit.textColor);
		CGColorSpaceRelease (colorSpace);
		self.textLayer.wrapped = unit.textWrapped;
	} else {
		// the string here is nothing, so get rid of the layer
		[self removeTitleLayer];	
	}
}

- (void)configureLayerWithUnit:(PQButtonValueUnit *)unit
{	
	if (!self.isBaseLayer) {
		self.frame = unit.cgFrame;
		//assign the property values, the drawing only properties can be fished out from the state at draw time.	
		self.cornerRadius = unit.cornerRadius;
		self.masksToBounds = unit.masksToBounds;
		self.hidden = unit.hidden;
		self.opacity = unit.opacity;
		[self addTitleLayerFromUnit:unit];
		self.borderWidth = unit.borderWidth;
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB ();
		self.borderColor = CGColorCreateFromNSColor(colorSpace, unit.borderColor);
		self.zPosition = unit.zPosition;
		self.shadowColor = CGColorCreateFromNSColor(colorSpace, unit.shadowColor);
		self.shadowOpacity = unit.shadowOpacity;
		self.shadowRadius = unit.shadowRadius;
		self.shadowOffset = unit.shadowOffset;
		self.doubleSided = unit.doubleSided;
		self.anchorPoint = unit.cgAnchorPoint;
		self.name = unit.name;
		CGColorSpaceRelease (colorSpace);	
		[self setNeedsDisplay];
		[self animateFrameChange];
		[self animateRotation];		
	}
}

- (void)animateAnimation:(CAAnimation *)animation
{
	[self addAnimation:animation forKey:@"animation"];
}


- (void)setValuesToReflectCurrentState
{
	PQButtonValueUnit *unit = [self valueUnitForState:self.buttonBase.currentState];
	[self configureLayerWithUnit:unit];

}

- (void)setCurrentState
{
	//what state?
	NSDictionary *statesVals = self.statesToValueUnits;
	PQButtonValueUnit *valUnit = [statesVals objectForKey:self.buttonBase.currentState.stateKey];
	if (!valUnit) {
		[self createValueObjectForState:self.buttonBase.currentState];
		valUnit = [self.statesToValueUnits objectForKey:self.buttonBase.currentState.stateKey];
	}
//	[self setSelValueUnitIfThisIsTheSelectedlayer:valUnit];
}

- (PQButtonValueUnit *)currentValueUnit
{
	return [self.statesToValueUnits objectForKey:self.buttonBase.currentState.stateKey];
}



- (void)dealloc
{
	[self.statesToValueUnits release]; self.statesToValueUnits = nil;
	[super dealloc];
}

#pragma mark Convenience Methods

- (IBAction)up:(id)sender 
{
	PQButtonValueUnit *unit = [self currentValueUnit];
	[unit setValue:[NSNumber numberWithFloat:[[unit valueForKey:@"originY"] floatValue] +1.0] forKey:@"originY"];
}

- (IBAction)down:(id)sender 
{
	PQButtonValueUnit *unit = [self currentValueUnit];
	[unit setValue:[NSNumber numberWithFloat:[[unit valueForKey:@"originY"] floatValue] -1.0] forKey:@"originY"];	
}

- (IBAction)left:(id)sender 
{
	PQButtonValueUnit *unit = [self currentValueUnit];
	[unit setValue:[NSNumber numberWithFloat:[[unit valueForKey:@"originX"] floatValue] -1.0] forKey:@"originX"];
}

- (IBAction)right:(id)sender 
{
	PQButtonValueUnit *unit = [self currentValueUnit];
	[unit setValue:[NSNumber numberWithFloat:[[unit valueForKey:@"originX"] floatValue] +1.0] forKey:@"originX"];	
}

- (IBAction)fatter:(id)sender
{
	PQButtonValueUnit *unit = [self currentValueUnit];
	[unit setValue:[NSNumber numberWithFloat:[[unit valueForKey:@"sizeWidth"] floatValue] +1.0] forKey:@"sizeWidth"];		
}

- (IBAction)higher:(id)sender
{
	PQButtonValueUnit *unit = [self currentValueUnit];
	[unit setValue:[NSNumber numberWithFloat:[[unit valueForKey:@"sizeHeight"] floatValue] +1.0] forKey:@"sizeHeight"];
}


- (IBAction)skinnier:(id)sender
{
	PQButtonValueUnit *unit = [self currentValueUnit];
	[unit setValue:[NSNumber numberWithFloat:[[unit valueForKey:@"sizeWidth"] floatValue] -1.0] forKey:@"sizeWidth"];		
}

- (IBAction)shorter:(id)sender
{
	PQButtonValueUnit *unit = [self currentValueUnit];
	[unit setValue:[NSNumber numberWithFloat:[[unit valueForKey:@"sizeHeight"] floatValue] -1.0] forKey:@"sizeHeight"];	
}

#pragma mark Outline View Model Dragging protocol
- (BOOL)validateNewParent:(id)proposedParent
{
	if (proposedParent != self) return YES;
	return NO;
}

- (BOOL)canBeDragged
{
	return YES; //always can, even if just to move
}

- (BOOL)addChild:(id)child atIndex:(int)index
{
	[(PQButtonBaseLayer *)child setButtonBase:self.buttonBase]; //this isn't archived on the drag's copy.
	self.buttonBase.isInsertingDuplicateLayer = YES;
	[self insertObject:child inLayersAtIndex:index];
	return YES;
}

- (void)removeFromParent
{
	[(PQButtonBaseLayer *)[self superlayer] removeObjectFromLayersAtIndex:[[[self superlayer] sublayers] indexOfObject:self]];
}


@end
