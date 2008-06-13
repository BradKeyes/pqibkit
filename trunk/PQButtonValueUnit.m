//
//  PQButtonValueUnit.m
//  PlasqIBPalleteKit
//
//  Created by Mathieu Tozer on 10/12/07.
//  Copyright 2007 plasq. All rights reserved.
//

#import "PQButtonValueUnit.h"
#include <Quartz/Quartz.h>
#import <CocoaExtender/CocoaExtender.h>

@implementation PQButtonValueUnit
@synthesize path, gradient;
@synthesize originX, originY, sizeHeight, sizeWidth, cornerRadius, toDuration, fromDuration;
@synthesize scaleSX, scaleSY, scaleSZ, transTX, transTY, transTZ;
@synthesize animationOption;
@synthesize title, titleX, titleY;
@synthesize titleGradient = _titleGradient;
@synthesize hasTrackingArea = _hasTrackingArea;
@synthesize opacity = _opacity, rotation = _rotation, borderWidth = _borderWidth, shadowOpacity = _shadowOpacity, shadowRadius = _shadowRadius, zPosition = _zPosition, icon = _icon, doubleSided = _doubleSided, hidden = _hidden, name = _name, borderColor = _borderColor, shadowColor = _shadowColor, shadowOffsetW = _shadowOffsetW, shadowOffsetH = _shadowOffsetH, iconX = _iconX, iconY = _iconY;
@synthesize show = _show;
@synthesize showHasBeenChanged = _showHasBeenChanged;
@synthesize compositingOp = _compositingOp;
@synthesize iconCompositingOp = _iconCompositingOp;

@synthesize pathType = _pathType;
@synthesize pathPointCount = _pathPointCount;
@synthesize pathPointOffset = _pathPointOffset;
@synthesize pathRadius = _pathRadius;

@synthesize textTruncationMode = _textTruncationMode;
@synthesize textAlignmentMode = _textAlignmentMode;
@synthesize textColor = _textColor;
@synthesize textWrapped = _textWrapped;
@synthesize bounceOp = _bounceOp;
@synthesize hasBounce = _hasBounce;
@synthesize iconName = _iconName;
@synthesize textureImage = _textureImage;
@synthesize textureImageName = _textureImageName;
@synthesize textureCompositingOp = _textureCompositingOp;
@synthesize textureAlpha = _textureAlpha;
@synthesize textureColor = _textureColor;
@synthesize doesDrawGradient = _doesDrawGradient;
@synthesize rotRX, rotRY, rotRZ;
@synthesize distortionInNewmans = _distortionInNewmans;
@synthesize doesFloorIcon = _doesFloorIcon;
@synthesize owner = _owner;

@synthesize anchorPointX = _anchorPointX;
@synthesize anchorPointY = _anchorPointY;
@synthesize positionX = _positionX;
@synthesize positionY = _positionY;
@synthesize masksToBounds = _masksToBounds;

- (void)setupChangeNotficationBindings
{
	//set ourselves to observe any change in the keypaths so we can post a notification if it changes
	for (NSString *keypath in [PQButtonValueUnit keypaths]) {
		[self addObserver:self forKeyPath:keypath options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self) {
		//post a notification
		if (self.owner) [self.owner aValueUnitChanged];
	}
}

+ (NSArray *)attributeKeypaths
{
	return  [NSArray arrayWithObjects:
			 @"originX", @"originY", @"sizeHeight", @"sizeWidth", 
			 @"cornerRadius", @"toDuration", @"fromDuration",
			 @"path",
			 @"gradient",
			 @"animationOption",
			 @"scaleSX", @"scaleSY", @"scaleSZ", @"transTX", @"transTY", @"transTZ", 
			 @"title", @"titleX", @"titleY", @"hasTrackingArea",
			 
			 @"opacity", @"rotation", @"borderWidth", @"shadowOpacity", @"shadowRadius", @"zPosition",
			 @"icon", @"doubleSided", @"hidden", @"show", @"showHasBeenChanged", @"name", @"borderColor", @"shadowColor", @"shadowOffsetW", @"shadowOffsetH", 
			 @"iconX", @"iconY", 
			 
			 @"compositingOp", @"iconCompositingOp",
			 @"pathType", @"pathPointCount", @"pathPointOffset", @"pathRadius", @"titleGradient",
			 
			 @"textTruncationMode", @"textAlignmentMode", @"textColor", @"textWrapped", @"bounceOp", @"hasBounce",
			 
			 @"rotRX", @"rotRY", @"rotRZ", @"iconName", @"textureImage",
			 @"textureImageName", @"textureCompositingOp", @"textureAlpha",
			 @"textureColor", @"doesDrawGradient",
			 @"distortionInNewmans", @"doesFloorIcon", @"anchorPointX", @"anchorPointY", @"positionX",  @"positionY",@"masksToBounds",
			 
			 nil];
	
}

+ (NSArray *)keypaths
{
	return  [NSArray arrayWithObjects:
			@"originX", @"originY", @"sizeHeight", @"sizeWidth", 
			@"cornerRadius", @"toDuration", @"fromDuration",
			@"path",
			@"gradient",
			@"animationOption",
			@"scaleSX", @"scaleSY", @"scaleSZ", @"transTX", @"transTY", @"transTZ", 
			@"title", @"titleX", @"titleY", @"hasTrackingArea",
			
			@"opacity", @"rotation", @"borderWidth", @"shadowOpacity", @"shadowRadius", @"zPosition",
			@"icon", @"doubleSided", @"hidden", @"show", @"showHasBeenChanged", @"name", @"borderColor", @"shadowColor", @"shadowOffsetW", @"shadowOffsetH", 
			@"iconX", @"iconY", 
			
			@"compositingOp", @"iconCompositingOp",
			@"pathType", @"pathPointCount", @"pathPointOffset", @"pathRadius", @"titleGradient",
			
			@"textTruncationMode", @"textAlignmentMode", @"textColor", @"textWrapped", @"bounceOp", @"hasBounce",
			
			@"rotRX", @"rotRY", @"rotRZ", @"iconName", @"textureImage",
			@"textureImageName", @"textureCompositingOp", @"textureAlpha",
			@"textureColor", @"doesDrawGradient",
			@"distortionInNewmans", @"doesFloorIcon", @"anchorPointX", @"anchorPointY", @"positionX",  @"positionY",@"masksToBounds",
			
			nil];
}

+ (NSArray *)scalableKeypaths
{
	NSMutableArray *keypaths = [[[[NSMutableArray alloc] init] retain] autorelease];
	[keypaths addObjectsFromArray:[NSArray arrayWithObjects:@"originX", @"originY", @"sizeHeight", @"sizeWidth", @"cornerRadius", @"titleX", @"titleY", @"iconX", @"iconY", @"rotation", @"borderWidth", @"shadowOffsetW", @"shadowOffsetH", @"pathRadius", nil]];
	return keypaths;
}

- (NSPoint)iconOrigin
{
	return NSMakePoint(self.iconX, self.iconY);
}

- (CGSize)shadowOffset
{
	return CGSizeMake(self.shadowOffsetW, self.shadowOffsetH);
}

- (NSRect)frame
{
	return NSMakeRect(self.originX, self.originY, self.sizeWidth, self.sizeHeight);
}

- (CGPoint)cgAnchorPoint
{
	return CGPointMake(self.anchorPointX, self.anchorPointY);
}

- (CGPoint)cgPosition
{
	return CGPointMake(self.positionX, self.positionY);
}

- (CGRect)cgFrame
{
	return CGRectMake(self.originX, self.originY, self.sizeWidth, self.sizeHeight);
}

- (NSRect)titleFrame
{
	NSSize size = [self.title size];
	return NSMakeRect(self.titleX, self.titleY, size.width, size.height);
}

- (CGRect)cgTitleFrame
{
	NSSize size = [self.title size];
	return CGRectMake(self.titleX, self.titleY, size.width, size.height);
}

- (void)setShow:(BOOL)show
{
	if (_finishedInit) {
		self.showHasBeenChanged = YES;
		_show = show;
	}
}

- (id)initWithCoder:(NSCoder *)coder 
{
	_finishedInit = NO;
	self = [super initWithCoder:coder];
	if ([coder allowsKeyedCoding]) {
		//inactive
		self.originX = [coder decodeFloatForKey:@"originX"];
		self.originY = [coder decodeFloatForKey:@"originY"];
		self.sizeHeight = [coder decodeFloatForKey:@"sizeHeight"];
		self.sizeWidth = [coder decodeFloatForKey:@"sizeWidth"];
		self.cornerRadius = [coder decodeFloatForKey:@"cornerRadius"];
		self.toDuration = [coder decodeFloatForKey:@"toDuration"];
		self.fromDuration = [coder decodeFloatForKey:@"fromDuration"];
		self.path = [coder decodeObjectForKey:@"path"];
	    self.gradient = [coder decodeObjectForKey:@"gradient"];
		self.animationOption = [coder decodeBoolForKey:@"animationOption"];
		self.scaleSX = [coder decodeFloatForKey:@"scaleSX"];
	    self.scaleSY = [coder decodeFloatForKey:@"scaleSY"];
	    self.scaleSZ = [coder decodeFloatForKey:@"scaleSZ"];
		self.transTX = [coder decodeFloatForKey:@"transTX"];
		self.transTY = [coder decodeFloatForKey:@"transTY"];
		self.transTZ = [coder decodeFloatForKey:@"transTZ"];
		self.titleX = [coder decodeFloatForKey:@"titleX"];
		self.titleY = [coder decodeFloatForKey:@"titleY"];
		self.title = [coder decodeObjectForKey:@"title"];
		self.hasTrackingArea = [coder decodeBoolForKey:@"hasTrackingArea"];
		
		self.opacity = [coder decodeFloatForKey:@"opacity"];
		self.rotation = [coder decodeFloatForKey:@"rotation"];
		self.borderWidth = [coder decodeFloatForKey:@"borderWidth"];
		self.shadowOpacity = [coder decodeFloatForKey:@"shadowOpacity"];
		self.shadowRadius = [coder decodeFloatForKey:@"shadowRadius"];
		self.zPosition = [coder decodeFloatForKey:@"zPosition"];
		self.icon = [coder decodeObjectForKey:@"icon"];
		self.name = [coder decodeObjectForKey:@"name"];
		self.borderColor = [coder decodeObjectForKey:@"borderColor"];
		self.shadowColor = [coder decodeObjectForKey:@"shadowColor"];
		self.shadowOffsetW = [coder decodeFloatForKey:@"shadowOffsetW"];
		self.shadowOffsetH = [coder decodeFloatForKey:@"shadowOffsetH"];
		self.hidden = [coder decodeBoolForKey:@"hidden"];
		self.show = [coder decodeBoolForKey:@"show"];
		self.showHasBeenChanged = [coder decodeBoolForKey:@"showHasBeenChanged"];
		self.doubleSided = [coder decodeBoolForKey:@"doubleSided"];
		self.iconX = [coder decodeFloatForKey:@"iconX"];
		self.iconY = [coder decodeFloatForKey:@"iconY"];
		self.compositingOp = [coder decodeIntForKey:@"compositingOp"];
		self.iconCompositingOp = [coder decodeIntForKey:@"iconCompositingOp"];

		self.pathType = [coder decodeIntForKey:@"pathType"];
		self.pathPointCount = [coder decodeIntForKey:@"pathPointCount"];
		self.pathPointOffset = [coder decodeFloatForKey:@"pathPointOffset"];
		self.pathRadius = [coder decodeFloatForKey:@"pathRadius"];
		self.titleGradient = [coder decodeObjectForKey:@"titleGradient"];
		
		self.textTruncationMode = [coder decodeObjectForKey:@"textTruncationMode"];
		self.textAlignmentMode = [coder decodeObjectForKey:@"textAlignmentMode"];
		self.textColor = [coder decodeObjectForKey:@"textColor"];
		self.textWrapped = [coder decodeBoolForKey:@"textWrapped"];

		self.bounceOp = [coder decodeObjectForKey:@"bounceOp"];
		self.hasBounce = [coder decodeBoolForKey:@"hasBounce"];
		
		self.rotRX = [coder decodeFloatForKey:@"rotRX"];
		self.rotRY = [coder decodeFloatForKey:@"rotRY"];
		self.rotRZ = [coder decodeFloatForKey:@"rotRZ"];
		
		self.iconName = [coder decodeObjectForKey:@"iconName"];
		
		self.textureImage = [coder decodeObjectForKey:@"textureImage"];
		self.textureImageName = [coder decodeObjectForKey:@"textureImageName"];
		self.textureCompositingOp = [coder decodeIntForKey:@"textureCompositingOp"];
		self.textureAlpha = [coder decodeFloatForKey:@"textureAlpha"];
		self.textureColor = [coder decodeObjectForKey:@"textureColor"];
		self.doesDrawGradient = [coder decodeBoolForKey:@"doesDrawGradient"];
		self.distortionInNewmans = [coder decodeFloatForKey:@"distortionInNewmans"];

		self.doesFloorIcon = [coder decodeBoolForKey:@"doesFloorIcon"];
		
		self.anchorPointX = [coder decodeFloatForKey:@"anchorPointX"];
		self.anchorPointY = [coder decodeFloatForKey:@"anchorPointY"];
		
		self.positionX = [coder decodeFloatForKey:@"positionX"];
		self.positionY = [coder decodeFloatForKey:@"positionY"];
		
		self.masksToBounds = [coder decodeBoolForKey:@"masksToBounds"];
		
	}
	[self setupChangeNotficationBindings];
	_finishedInit = YES;
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder 
{
	[super encodeWithCoder:coder];
    if ([coder allowsKeyedCoding]) {
		[coder encodeFloat:self.originX forKey:@"originX"];
		[coder encodeFloat:self.originY forKey:@"originY"];
		[coder encodeFloat:self.sizeHeight forKey:@"sizeHeight"];
		[coder encodeFloat:self.sizeWidth forKey:@"sizeWidth"];
		[coder encodeFloat:self.cornerRadius forKey:@"cornerRadius"];
		[coder encodeFloat:self.toDuration forKey:@"toDuration"];
		[coder encodeFloat:self.fromDuration forKey:@"fromDuration"];
		[coder encodeObject:self.path forKey:@"path"];
		[coder encodeObject:self.gradient forKey:@"gradient"];
		[coder encodeBool:self.animationOption forKey:@"animationOption"];
		[coder encodeFloat:self.scaleSX forKey:@"scaleSX"];
		[coder encodeFloat:self.scaleSY forKey:@"scaleSY"];
		[coder encodeFloat:self.scaleSZ forKey:@"scaleSZ"];
		[coder encodeFloat:self.transTX forKey:@"transTX"];
		[coder encodeFloat:self.transTY forKey:@"transTY"];
		[coder encodeFloat:self.transTZ forKey:@"transTZ"];
		[coder encodeFloat:self.titleX forKey:@"titleX"];
		[coder encodeFloat:self.titleY forKey:@"titleY"];
		[coder encodeObject:self.title forKey:@"title"];
		[coder encodeBool:self.hasTrackingArea forKey:@"hasTrackingArea"];
		
		[coder encodeFloat:self.opacity forKey:@"opacity"];
		[coder encodeFloat:self.rotation forKey:@"rotation"];
		[coder encodeFloat:self.borderWidth forKey:@"borderWidth"];
		[coder encodeFloat:self.shadowOpacity forKey:@"shadowOpacity"];
		[coder encodeFloat:self.shadowRadius forKey:@"shadowRadius"];
		[coder encodeFloat:self.zPosition forKey:@"zPosition"];
		[coder encodeObject:self.icon forKey:@"icon"];
		[coder encodeObject:self.name forKey:@"name"];
		[coder encodeObject:self.borderColor forKey:@"borderColor"];
		[coder encodeObject:self.shadowColor forKey:@"shadowColor"];
		[coder encodeFloat:self.shadowOffsetW forKey:@"shadowOffsetW"];
		[coder encodeFloat:self.shadowOffsetH forKey:@"shadowOffsetH"];
		[coder encodeBool:self.hidden forKey:@"hidden"];
		[coder encodeBool:self.show forKey:@"show"];
		[coder encodeBool:self.showHasBeenChanged forKey:@"showHasBeenChanged"];
		[coder encodeBool:self.doubleSided forKey:@"doubleSided"];
		[coder encodeFloat:self.iconX forKey:@"iconX"];
		[coder encodeFloat:self.iconY forKey:@"iconY"];
		[coder encodeInt:self.compositingOp forKey:@"compositingOp"];
		[coder encodeInt:self.iconCompositingOp forKey:@"iconCompositingOp"];
		
		[coder encodeInt:self.pathType forKey:@"pathType"];
		[coder encodeInt:self.pathPointCount forKey:@"pathPointCount"];
		[coder encodeFloat:self.pathPointOffset forKey:@"pathPointOffset"];
		[coder encodeFloat:self.pathRadius forKey:@"pathRadius"];
		[coder encodeObject:self.titleGradient forKey:@"titleGradient"];
		
		[coder encodeObject:self.textTruncationMode forKey:@"textTruncationMode"];
		[coder encodeObject:self.textAlignmentMode forKey:@"textAlignmentMode"];
		[coder encodeObject:self.textColor forKey:@"textColor"];
		[coder encodeBool:self.textWrapped forKey:@"textWrapped"];
		[coder encodeObject:self.bounceOp forKey:@"bounceOp"];
		[coder encodeBool:self.hasBounce forKey:@"hasBounce"];
		
		[coder encodeFloat:self.rotRX forKey:@"rotRX"];
		[coder encodeFloat:self.rotRY forKey:@"rotRY"];
		[coder encodeFloat:self.rotRZ forKey:@"rotRZ"];
		
		[coder encodeObject:self.iconName forKey:@"iconName"];
		
		[coder encodeObject:self.textureImage forKey:@"textureImage"];
		[coder encodeObject:self.textureImageName forKey:@"textureImageName"];
		[coder encodeFloat:self.textureAlpha forKey:@"textureAlpha"];
		[coder encodeInt:self.textureCompositingOp forKey:@"textureCompositingOp"];
		[coder encodeObject:self.textureColor forKey:@"textureColor"];
		[coder encodeBool:self.doesDrawGradient forKey:@"doesDrawGradient"];
		[coder encodeFloat:self.distortionInNewmans forKey:@"distortionInNewmans"];
		[coder encodeBool:self.doesFloorIcon forKey:@"doesFloorIcon"];
		
		[coder encodeFloat:self.anchorPointX forKey:@"anchorPointX"];
		[coder encodeFloat:self.anchorPointY forKey:@"anchorPointY"];
		
		[coder encodeFloat:self.positionX forKey:@"positionX"];
		[coder encodeFloat:self.positionY forKey:@"positionY"];
		[coder encodeBool:self.masksToBounds forKey:@"masksToBounds"];
    }
	return;
}

- (id) init
{
	_finishedInit = NO;
	self = [super init];
	if (self != nil) {
		self.owner = nil; //nil until the button sets it.
		// Initialization code here.
		self.originX = 0.0;
		self.originY = 0.0;
		self.sizeHeight = 50.0;
		self.sizeWidth = 50.0;
		self.cornerRadius = 9.0;
		self.toDuration = 0.2;
		self.fromDuration = 0.5;
		self.gradient = [PQGradient randomGradient];
		self.scaleSX = 1.0;
		self.scaleSY = 1.0;
		self.scaleSZ = 1.0;
		self.transTX = 0.0;
		self.transTY = 0.0;
		self.transTZ = 1.0;
		self.animationOption = YES;
		self.title = [[[[NSAttributedString alloc] initWithString:@""] retain] autorelease];
		self.titleX = 0.0;
		self.titleY = 0.0;
		self.titleGradient = [PQGradient randomGradient];
		self.hasTrackingArea = YES;
		
		self.opacity = 1.0;
		self.rotation = 0.0;
		self.borderWidth = 0.0;
		self.shadowOpacity = 0.0; //off by default because most layers won't need one. User should decide which should have shadow and add it.
		self.shadowRadius = 7.0;
		self.zPosition = 0.0;
		self.icon = nil;
		self.name = nil;
		self.borderColor = [NSColor blackColor];
		self.shadowColor = [NSColor shadowColor];
		self.shadowOffsetW = 0.0;
		self.shadowOffsetH = -4.0;
		self.hidden = NO;
		self.show = YES;
		self.showHasBeenChanged = NO;
		self.doubleSided = NO;
		self.iconX = 0.0;
		self.iconY = 0.0;
		
		self.compositingOp = NSCompositeSourceOver;
		self.iconCompositingOp = NSCompositeSourceOver;
		
		self.pathType = kSmartShapeTypeRounded;
		self.pathPointCount = 5.0;
		self.pathPointOffset = 1.0;
		self.pathRadius = 5.0;
	
		self.textTruncationMode = kCATruncationNone;
		self.textAlignmentMode = kCAAlignmentCenter;
		self.textColor = [NSColor whiteColor];
		self.textWrapped = YES;
		self.bounceOp = @""; //no bounce.
		self.hasBounce = NO;
		
		self.rotRX = 1;
		self.rotRY = 1;
		self.rotRZ = 1;
		
		self.iconName = nil;
		
		self.textureImage = nil;
		self.textureImageName = nil;
		self.textureAlpha = 1.0;
		self.textureCompositingOp = NSCompositeSourceOver;
		self.textureColor = nil;
		self.doesDrawGradient = YES;
		
		self.distortionInNewmans = 0.0;
		
		self.doesFloorIcon = NO;
		
		self.anchorPointX = 0.5;
		self.anchorPointY = 0.5;
		
		self.positionX = 0.0;
		self.positionY = 0.0;
		
		self.masksToBounds = NO;
		
	}
	[self setupChangeNotficationBindings];
	_finishedInit = YES;
	return self;
}

@end
