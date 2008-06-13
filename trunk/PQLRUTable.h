/**
 * \file PQLRUTable.h
 *
 * Copyright plasq LLC 2008. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

/**
 * A key->object hash table with limited size
 * (key,object) pairs are removed using a LRU algorithm
 * - objects are retained by the table
 * - key are retained by the table
 */
#import <Cocoa/Cocoa.h>


@interface PQLRUTable : NSObject {
	int	_capacity;
	NSMapTable* _table;
	NSPointerArray* _lruTable;
}
/** Create a new LRU table */
+ (PQLRUTable *)LRUTableWithCapacity: (int)capacity;

/** Returns the object for the key and marks it as recently used */
- (id)objectForKey: (id)key;
/** Set the object for the key and marks it as recently used */
- (void)setObject: (id)object forKey: (id)key;
/** Remove the object/key entry */
- (void)removeObjectForKey: (id)key;
/** Clear the table */
- (void)clear;
@end
