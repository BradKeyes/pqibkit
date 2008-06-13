//
//  PQState.m
//  PlasqIBPalleteKit
//
//  Created by Mathieu Tozer on 15/03/08.
//  Copyright 2008 plasq. All rights reserved.
//

#import "PQState.h"


@implementation PQState
@synthesize stateName = _stateName;
@synthesize stateKey = _stateKey;
@synthesize isFirstState = _isFirstState;

+ (NSArray *)keypaths
{
	return [NSArray arrayWithObjects:
			@"selectorToActivate", @"stateName", @"anchorPoint", @"isFirstState",
			nil];
}

+ (PQState *)state
{
	return [[PQState alloc] init];
}

- (id)initWithCoder:(NSCoder *)coder 
{
	if ([coder allowsKeyedCoding]) {
		self.stateName = [coder decodeObjectForKey:@"stateName"];
		self.stateKey = [coder decodeObjectForKey:@"stateKey"];
		self.isFirstState = [coder decodeBoolForKey:@"isFirstState"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder 
{
    if ([coder allowsKeyedCoding]) {
		[coder encodeObject:self.stateName forKey:@"stateName"];
		[coder encodeObject:self.stateKey forKey:@"stateKey"];
		[coder encodeBool:self.isFirstState forKey:@"isFirstState"];
    }
	return;
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		self.stateName = @"New State";
		self.isFirstState = NO;
	}
	return self;
}


- (NSString *)name
{
	return self.stateName;
}

- (void)scaleKeypath:(NSString *)key byPercentage:(float)percent
{
	float value = [[self valueForKey:key] floatValue];
	value = value + (value * (percent / 100));
	[self setValue:[NSNumber numberWithFloat:value] forKey:key];
}

@end
