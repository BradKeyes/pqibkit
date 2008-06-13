//
//  PQStateMachine.h
//  PQIBKit
//
//  Created by Mathieu Tozer on 15/03/08.
//  Copyright 2008 plasq. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PQState.h" 
@protocol StateMachineOwner

- (void)stateChangedTo:(PQState *)state;
- (void)someValueChanged;

@end

//@class PQState;

@interface PQStateMachine : NSObject {
	NSMutableArray *_states;
	PQState *_currentState;
	NSIndexSet *_selectionIndexSet;
	int _nextStateID;
	id <StateMachineOwner> _owner;
}

@property (retain) PQState *currentState;
@property int nextStateID;
@property (retain) NSIndexSet *selectionIndexSet;
@property (assign) id owner;

- (id) initWithOwner:(id)owner;

- (unsigned int)countOfStates;
- (id)objectInStatesAtIndex:(unsigned int)index;
- (void)removeObjectFromStatesAtIndex:(unsigned int)index;
- (void)insertObject:(id)anObject inStatesAtIndex:(unsigned int)index;
- (NSArray *)states;
- (void)setStates:(NSArray *)states;

- (void)setStateByName:(NSString *)stateName;
- (PQState *)stateWithStateName:(NSString *)stateName;
- (void)moveToNextState;
- (void)duplicateStates:(NSArray *)state;
@end
