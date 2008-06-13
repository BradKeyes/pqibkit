//
//  PQPrettyViewState.m
//  PlasqIBPalleteKit
//
//  Created by Mathieu Tozer on 15/03/08.
//  Copyright 2008 plasq. All rights reserved.
//

#import "PQPrettyViewState.h"
#import "NSBezierPath+PQAdditions.h"


@implementation PQPrettyViewState

@synthesize regularRotation = _regularRotation;
@synthesize animateBetweenSiblingView = _animateBetweenSiblingView;
@synthesize fadeRandomThreshold = _fadeRandomThreshold;
- (id)initWithCoder:(NSCoder *)coder 
{	
	self = [super initWithCoder:coder];
	if ([coder allowsKeyedCoding]) {
		self.regularRotation = [coder decodeFloatForKey:@"regularRotation"];
		self.fadeRandomThreshold = [coder decodeFloatForKey:@"fadeRandomThreshold"];
		self.animateBetweenSiblingView = [coder decodeBoolForKey:@"animateBetweenSiblingView"];
	}
	return self;
}
- (void)encodeWithCoder:(NSCoder *)coder 
{
	[super encodeWithCoder:coder];
	[coder encodeFloat:self.regularRotation forKey:@"regularRotation"];
	[coder encodeFloat:self.fadeRandomThreshold forKey:@"fadeRandomThreshold"];
	[coder encodeBool:self.animateBetweenSiblingView forKey:@"animateBetweenSiblingView"];
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		// Initialization code here.
		self.sizeHeight = 0.0;
		self.sizeWidth = 0.0;
		self.fadeRandomThreshold = 30.0; //%
		self.regularRotation = 0.0;
		self.pathType = kSmartShapeTypeRounded;
		self.animateBetweenSiblingView = NO;
		self.toDuration = 5.0;
	}
	return self;
}


@end
