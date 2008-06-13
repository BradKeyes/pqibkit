//
//  PQLRUTable.m
//  Comic Life
//
//  Created by Airy ANDRE on 31/01/08.
//  Copyright 2008 plasq LLC. All rights reserved.
//

#import "PQLRUTable.h"

@implementation PQLRUTable
- (id)initWithCapacity: (int)capacity
{
	self = [super init];
	if (self) {
		_capacity = capacity;
		// The key->value table
		_table = [NSMapTable mapTableWithKeyOptions: NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPersonality valueOptions:NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPersonality];
		// The LRU table
		_lruTable = [NSPointerArray pointerArrayWithOptions: NSPointerFunctionsZeroingWeakMemory|NSPointerFunctionsObjectPersonality];
	}
	return self;
}

+ (PQLRUTable *)LRUTableWithCapacity: (int)capacity
{
	return [[PQLRUTable alloc] initWithCapacity: capacity];
}

- (void)_updateLRUForKey: (id)key removed: (BOOL)removed
{
	id obj = [_lruTable pointerAtIndex: [_lruTable count] - 1];
	if ([obj isEqualTo: key]) {
		return;
	}
	
	// Update our lruTable by moving the key to the end of the table
	// Start by the end : chances are the object has been recently referenced
	int count = [_lruTable count];
	int i = 0;
	for (i = count - 1; i >= 0; i--) {
		id obj = [_lruTable pointerAtIndex: i];
		if ([obj isEqualTo: key]) {
			[_lruTable replacePointerAtIndex: i withPointer: NULL];
			break;
		}
	}
	if (!removed) {
		// Move our object to the end of the table
		[_lruTable addPointer: key];
		// Do some cleaning
		if ([_lruTable count] > _capacity * 2) {
			[_lruTable compact];
		}
	}
}

- (id)objectForKey: (id)key
{
	id object = nil;
	@synchronized (self) {
		object = [_table objectForKey: key];
		if (object) {
			// Update our lru table
			[self _updateLRUForKey: key removed: NO];
		}
	}
	return object;
}

- (void)setObject: (id)object forKey: (id)key
{
	@synchronized (self) {
		id oldValue = [_table objectForKey: key];
		if (oldValue == nil)
		{
			// We may need to make room for the new object
			[_lruTable compact];
			if ([_lruTable count] >= _capacity) {
				id oldestObject = [_lruTable pointerAtIndex: 0];
				//NSLog(@"[%p]Full [%d]:removing %@", self, _capacity, oldestObject);
				// Remove our oldest object from our tables
				[_lruTable replacePointerAtIndex: 0 withPointer: NULL];
				// This will also release the value for this key
				[_table removeObjectForKey: oldestObject];
			}
		}
		[_table setObject: object forKey: key];
		// This will update our LRU table
		[self _updateLRUForKey: key removed: NO];
	}
}

- (void)removeObjectForKey: (id)key
{
	@synchronized (self) {
		if ([_table objectForKey: key]) {
			[_table removeObjectForKey: key];
			// Clean our lru table
			[self _updateLRUForKey: key removed: YES];
		}
	}
}
			
- (void)clear
{
	// Just recreate our tables - this will release everything
	@synchronized (self) {
		// The key->value table
		_table = [NSMapTable mapTableWithKeyOptions: NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPersonality valueOptions:NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPersonality];
		// The LRU table
		_lruTable = [NSPointerArray pointerArrayWithOptions: NSPointerFunctionsZeroingWeakMemory|NSPointerFunctionsObjectPersonality];
	}
}
			
@end
