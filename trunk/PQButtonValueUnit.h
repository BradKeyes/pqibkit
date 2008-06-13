//
//  PQButtonValueUnit.h
//  PQIBKit
//
//  Created by Mathieu Tozer on 10/12/07.
//  Copyright 2007 plasq. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PQState.h"

@interface NSObject (PQButtonValueUnitOwner)

- (void)aValueUnitChanged; //to recieve notifications

@end

@class PQGradient, PQButtonPath;

@interface PQButtonValueUnit : PQState <NSCoding> {
	PQGradient *gradient;
	float originX, originY, sizeHeight, sizeWidth, cornerRadius;
	float toDuration, fromDuration;
	PQButtonPath *path;
	float scaleSX, scaleSY, scaleSZ;
	float transTX, transTY, transTZ;
	float rotRX, rotRY, rotRZ;
	float _distortionInNewmans;
	BOOL animationOption;
	
	NSAttributedString *title;
	float titleX, titleY;
	PQGradient *_titleGradient;
	NSColor *_textColor;
	BOOL _textWrapped;
	NSString *_textTruncationMode;
	NSString *_textAlignmentMode;
	
	BOOL _hasTrackingArea;

	id _icon;
	float _iconX;
	float _iconY;
	int _compositingMode; //to use when drawing the layer
	
	//CALayer properties (ones defined in the framework - we can just plop them right into the layer)
	float _opacity;
	float _rotation;
	float _borderWidth;
	NSColor *_borderColor;
	BOOL _doubleSided;
	BOOL _hidden;
	NSString *_name;
	NSColor *_shadowColor;
	float _shadowOffsetW;
	float _shadowOffsetH; //a size
	float _shadowOpacity;
	float _shadowRadius;
	float _zPosition;
	
	int _compositingOp;
	int _iconCompositingOp;

	int _pathType;
	int _pathPointCount;
	float _pathPointOffset;
	float _pathRadius;
	
	NSString *_bounceOp;
	BOOL _hasBounce;
	
	NSString *_iconName;
	BOOL _doesFloorIcon;
	
	id _textureImage;
	NSString *_textureImageName;
	int _textureCompositingOp;
	float _textureAlpha;
	NSColor *_textureColor;
	
	BOOL _doesDrawGradient;
	
	id _owner;
	
	float _anchorPointX;
	float _anchorPointY;
	float _positionX;
	float _positionY;
	
	BOOL _show, _showHasBeenChanged;
	BOOL _finishedInit;
	BOOL _masksToBounds;
}

@property (assign) id owner;
@property float originX, originY, sizeHeight, sizeWidth, cornerRadius;
@property float toDuration, fromDuration;
@property (retain) PQButtonPath *path;
@property (retain) PQGradient *gradient, *titleGradient;
@property float scaleSX, scaleSY, scaleSZ, transTX, transTY, transTZ, rotRX, rotRY, rotRZ, distortionInNewmans;
@property BOOL animationOption;
@property (retain) NSAttributedString *title;
@property float titleX, titleY;
@property BOOL hasTrackingArea;
@property BOOL doesFloorIcon;
@property float opacity, rotation, borderWidth, shadowOpacity, shadowRadius, zPosition;
@property (retain) id icon, textureImage;
@property BOOL doubleSided, hidden;
@property (copy) NSString *name, *bounceOp;
@property (retain) NSColor *borderColor, *shadowColor; 
@property float shadowOffsetW, shadowOffsetH, iconX, iconY;
@property float anchorPointX, anchorPointY, positionX, positionY;

@property int compositingOp, iconCompositingOp;

@property int pathType, pathPointCount;
@property float pathPointOffset, pathRadius;

@property (copy) NSString *textTruncationMode, *textAlignmentMode;	
@property (retain) NSColor *textColor;
@property BOOL textWrapped, hasBounce;
@property (copy) NSString  *iconName;
@property (copy) NSString *textureImageName;
@property int textureCompositingOp;
@property float textureAlpha;
@property (retain) NSColor *textureColor;

@property BOOL show, showHasBeenChanged;

@property BOOL doesDrawGradient;
@property BOOL masksToBounds;

+ (NSArray *)keypaths;
+ (NSArray *)attributeKeypaths;
+ (NSArray *)scalableKeypaths;

- (NSRect)frame;
- (CGRect)cgFrame;

- (CGPoint)cgAnchorPoint;
- (CGPoint)cgPosition;

- (NSRect)titleFrame;
- (CGRect)cgTitleFrame;

- (NSPoint)iconOrigin;
- (CGSize)shadowOffset;
@end
