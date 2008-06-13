//
//  PQButtonState.h
//  PQIBKit
//
//  Created by Mathieu Tozer on 9/12/07.
//  Copyright 2007 plasq. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PQButtonState : NSObject {
	NSString *_selectorToActivate, *_stateName;
	NSString *_rules;
	NSString *_stateKey; //immutable
}

+ (PQButtonState *)inactiveState;
+ (PQButtonState *)mouseOverState;
+ (PQButtonState *)activeState;

//An action command must have the following format to be valid
// 

//there is a finite and definable set of events that an object could recieve, and these map to some selector.
//when invoked, the selector will search the button for state which has a matching selectorToActivate

@property (copy) NSString *selectorToActivate, *stateName, *rules, *stateKey;

+ (NSArray *)keypaths;

- (NSString *)name;

@end
