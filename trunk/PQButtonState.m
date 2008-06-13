//
//  PQButtonState.m
//  PQIBKit
//
//  Created by Mathieu Tozer on 9/12/07.
//  Copyright 2007 plasq. All rights reserved.
//

#import "PQButton.h"
#import "PQButtonState.h"
#import <CocoaExtender/CocoaExtender.h>

@implementation PQButtonState

//inactive
@synthesize selectorToActivate = _selectorToActivate;
@synthesize stateName = _stateName;
@synthesize rules = _rules;
@synthesize stateKey = _stateKey;

+ (PQButtonState *)inactiveState
{
	PQButtonState *inactiveState = [[[[PQButtonState alloc] init] retain] autorelease];
	inactiveState.stateName = @"Inactive";
	inactiveState.selectorToActivate = (NSString *)kPQButtonMouseExited;
	return inactiveState;
	
}

+ (PQButtonState *)mouseOverState
{
	PQButtonState *mouseOverState = [[[[PQButtonState alloc] init] retain] autorelease];
	mouseOverState.stateName = @"Mouse Over";
	mouseOverState.selectorToActivate = (NSString *)kPQButtonMouseEntered;
	return mouseOverState;
}

+ (PQButtonState *)activeState
{
	PQButtonState *activeState = [[[[PQButtonState alloc] init] retain] autorelease];
	activeState.stateName = @"Active";
	activeState.selectorToActivate = (NSString *)kPQButtonMouseDown;
	activeState.rules = [NSString stringWithFormat:@"wait:1.0, invoke:%@;", kPQButtonMouseExited];
	return activeState;
}

+ (NSArray *)keypaths
{
	return [NSArray arrayWithObjects:
			@"selectorToActivate", @"stateName",
			nil];
}


- (id)initWithCoder:(NSCoder *)coder 
{
	if ([coder allowsKeyedCoding]) {
		self.selectorToActivate = [coder decodeObjectForKey:@"selectorToActivate"];
		self.stateName = [coder decodeObjectForKey:@"stateName"];
		self.stateKey = [coder decodeObjectForKey:@"stateKey"];
		self.rules = [coder decodeObjectForKey:@"rules"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder 
{
    if ([coder allowsKeyedCoding]) {
		[coder encodeObject:self.selectorToActivate forKey:@"selectorToActivate"];
		[coder encodeObject:self.stateName forKey:@"stateName"];
		[coder encodeObject:self.stateKey forKey:@"stateKey"];
		[coder encodeObject:self.rules forKey:@"rules"];
    }
	return;
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		self.selectorToActivate = @"mouseDown";
		self.stateName = @"state name";
		self.rules = @"";
		self.selectorToActivate = (NSString *)kPQButtonMouseDown;
		//stateKey should be initialised by the client.
	}
	return self;
}


- (NSString *)name
{
	return self.stateName;
}
@end
