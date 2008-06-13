//
//  PQStateMachine.m
//  PQIBKit
//
//  Created by Mathieu Tozer on 15/03/08.
//  Copyright 2008 plasq. All rights reserved.
//

#import "PQStateMachine.h"
#import "PQState.h"
#import "NSArray+PQAdditions.h"

@implementation PQStateMachine
@synthesize nextStateID = _nextStateID;
@synthesize currentState = _currentState;
@synthesize selectionIndexSet = _selectionIndexSet;
@synthesize owner = _owner;


- (Class)stateClass
{
	return [PQState class];
}

- (void)setupInitialStates
{
	PQState *initialState = [[[self stateClass] alloc] init];
	initialState.stateName = @"First State";
	initialState.isFirstState = YES;
	[self insertObject:initialState inStatesAtIndex:0];
}

- (void)setupObservations
{
	[self addObserver:self forKeyPath:@"selectionIndexSet" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
	[self addObserver:self forKeyPath:@"currentState" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
}

- (id) initWithOwner:(id)owner
{
	self = [super init];
	if (self != nil) {
		_owner = owner;
		self.nextStateID = 0;
		_states = [[[NSMutableArray alloc] init] retain];
		[self setupObservations];
		[self setupInitialStates];
		self.currentState = [[self states] firstObject];
	}
	return self;
}


- (id)initWithCoder:(NSCoder *)coder 
{	
    if ([coder allowsKeyedCoding]) {
		[self setupObservations];
		_states = [[[NSMutableArray alloc] init] retain];
		[_states addObjectsFromArray:[coder decodeObjectForKey:@"states"]];
		self.nextStateID = [coder decodeIntForKey:@"nextStateID"];
		self.currentState = [[self states] firstObject];	
	}
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder 
{
	[coder encodeObject:[self states] forKey:@"states"];
	[coder encodeInt:self.nextStateID forKey:@"nextStateID"];
	return;
}


+ (NSArray *)keypaths
{
	return [NSArray arrayWithObjects:@"states", @"nextStateID", nil];
}

- (NSString *)uniqueStateID
{
	self.nextStateID++;
	return [NSString stringWithFormat:@"%d", self.nextStateID];
}


#pragma mark States

- (unsigned int)countOfStates
{
	return [_states count];
}

- (id)objectInStatesAtIndex:(unsigned int)index
{
	if (index >= [self countOfStates])
        return nil;
	return [_states objectAtIndex:index];
}

- (void)removeObjectFromStatesAtIndex:(unsigned int)index
{
	[_states removeObjectAtIndex:index];
}

- (void)insertObject:(id)anObject inStatesAtIndex:(unsigned int)index
{
	[(PQState *)anObject setStateKey:[self uniqueStateID]];
	[_states insertObject:anObject atIndex:index];
}

- (NSArray*)states
{
    return [[_states retain] autorelease];
}

- (void)setStates:(NSArray *)states
{
	if (_states) [_states release];
	_states = [[[NSMutableArray alloc] initWithArray:states] retain];
}

- (void)setStateByName:(NSString *)stateName
{
	NSArray *states = self.states;
	for (PQState *state in states) {
		if ([state.stateName isEqualToString:stateName]) {
			self.currentState = state; 
			break;
		}
	}
}

- (PQState *)stateWithStateName:(NSString *)stateName
{
	NSArray *states = self.states;
	for (PQState *state in states) {
		if ([state.stateName isEqualToString:stateName]) {
			return state;
		}
	}
	return nil;
}

- (void)setupObservationsOnKeypathsForState:(PQState *)state
{
	NSArray *keys = [[state class] keypaths];
	for (NSString *key in keys) {
		[state addObserver:self forKeyPath:key options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:@"propertyChange"];
	}
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (object == self && [keyPath isEqualToString:@"selectionIndexSet"]) {
		self.currentState = [[self.states objectsAtIndexes:self.selectionIndexSet] firstObject];
		[self setupObservationsOnKeypathsForState:self.currentState];
		return;
	}
	
	if (object == self.currentState && [(NSString *)context isEqualToString:@"propertyChange"]) {
		if (_owner) [_owner someValueChanged];
		return;
	}
	
    if (object == self && [keyPath isEqualToString:@"currentState"]) {
		if (_owner) [_owner stateChangedTo:self.currentState];
		return;
	}
}

- (void)duplicateStates:(NSArray *)states;
{
	for (PQState *state in states) {
		PQState *newState = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:state]];
		[self insertObject:newState inStatesAtIndex:0];
	}
	
}

- (void) dealloc
{
	if (_states) [_states release];				  
	[super dealloc];
}

- (void)moveToNextState
{
	int selectionIndex = [self.states indexOfObject:self.currentState] +1;
	if (selectionIndex > [self.states count]-1) {
		selectionIndex = 0;
	}
	self.selectionIndexSet = [NSIndexSet indexSetWithIndex:selectionIndex];
}
@end
