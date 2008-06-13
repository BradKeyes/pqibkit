//
//  NSArray+PQAdditions.m
//  Comic Life
//
//  Created by Airy ANDRE on 07/01/08.
//  Copyright 2008 plasq LLC. All rights reserved.
//

#import "NSArray+PQAdditions.h"
#import "NSObject+PQAdditions.h"


@implementation NSArray(PQAdditions)
/**
 * KVO convenience method for watching all properties of an object
 */
- (void)addPropertyObserver: (id)observer options: (NSKeyValueObservingOptions)options context: (void*)context
{
	// We sort all the objects from the array by classes, and do only one call for each property for all the elements of the classes
	// That will reduce a lot the number of calls to addObserver, which is expensive
	NSMutableArray *classes = [NSMutableArray array];
	for (id object in self) {
		if (![classes containsObject: [object class]])
			[classes addObject: [object class]];
	}
	for (id class in classes) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat: @"self.class == %@", class];
		NSArray *objects = [self filteredArrayUsingPredicate: predicate];
		NSObject *firstObject = [objects objectAtIndex: 0];
		NSArray *properties = [firstObject allObservableProperties];
		for (NSString* keyPath in properties) {
			[objects addObserver: observer toObjectsAtIndexes: [NSIndexSet indexSetWithIndexesInRange: NSMakeRange(0, [objects count])] forKeyPath: keyPath options: options context: context];
		}
	}
}

- (void)removePropertyObserver:(id)observer
{
	// We sort all the objects from the array by classes, and do only one call for each property for all the elements of the classes
	// That will reduce a lot the number of calls to addObserver, which is expensive
	NSMutableArray *classes = [NSMutableArray array];
	for (id object in self) {
		if (![classes containsObject: [object class]])
			[classes addObject: [object class]];
	}
	for (id class in classes) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat: @"self.class == %@", class];
		NSArray *objects = [self filteredArrayUsingPredicate: predicate];
		NSObject *firstObject = [objects objectAtIndex: 0];
		NSArray *properties = [firstObject allObservableProperties];
		for (NSString* keyPath in properties) {
			[objects removeObserver: observer fromObjectsAtIndexes: [NSIndexSet indexSetWithIndexesInRange: NSMakeRange(0, [objects count])] forKeyPath: keyPath];
		}
	}
}

- (id)firstObject
{
	if ([self count] > 0) {
		return [self objectAtIndex:0];
	}
	return nil;
}
@end
