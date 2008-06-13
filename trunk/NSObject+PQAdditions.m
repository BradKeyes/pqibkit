//
//  NSObject+PQAdditions.m
//  Comic Life
//
//  Created by Airy ANDRE on 19/08/07.
//  Copyright 2007 plasq LLC. All rights reserved.
//

#import "NSObject+PQAdditions.h"
#import <objc/runtime.h>

@implementation NSObject (PQAdditions)

#pragma mark Bindings

/**
 * Notify any bound object of the property change
 */
- (void)notifyBoundObjectForKey:(NSString *)key
{
	NSDictionary* info = [self infoForBinding: key];
	if (info) {
		id value = [self valueForKey: key];
		/* NOTE : needs some work here to support transformers */
		NSString *keyPath = [info objectForKey: NSObservedKeyPathKey];
		[[info valueForKey:NSObservedObjectKey] setValue: value forKeyPath: keyPath];
	}	
}

#pragma mark Equality

/*
 * Defers to -isEqualTo: -- for subclasses to override.
 *
 * Otherwise, return isEqualToValue.
 */
- (BOOL)isEqualToValueOfObject: (id)object
{
	return [self isEqualTo: object];
}

#pragma mark Property Introspection
+ (BOOL)shouldObserve:(NSString *)propertyName
{
	return YES;
}

/* 
 * This method returns an array of NSString names of all this class's 
 * properties, which can be observed via KVO.
 */
+ (NSArray*)observableProperties
{
	// Returns a malloc()d array of objcProperties -- number of elements is in count.

	unsigned int count = 0;
	objc_property_t* objcProperties = class_copyPropertyList(self, &count);

	// Add each property's name to an NSArray...

	int i;
	NSMutableArray* properties = [NSMutableArray arrayWithCapacity: count];

	for (i = 0; i < count; i++) {
		NSString* name = [NSString stringWithCString: property_getName(objcProperties[i]) encoding: NSUTF8StringEncoding];
		if ([self shouldObserve: name])
			[properties addObject: name];
	}

	// Free memory allocated by the runtime...
	free(objcProperties);

	// and return the NSArray
	return properties;
}

/**
 * Walks the class hierarchy for the object adding each 
 * class to the array.
 */
- (NSArray*)_classHierarchy
{
	NSMutableArray* array = [NSMutableArray array];
	Class class = [self class];
	[array addObject: class];
	while (class = [class superclass]) {
		[array addObject: class];
	}
	return array;
}

/**
 * This method returns an array of all the properties for an object
 * including properties in a super class
 */
- (NSArray*)allObservableProperties
{
	NSMutableArray* allProperties = [NSMutableArray array];
	
	NSArray* classes = [self _classHierarchy];
	for (Class class in classes) {
		NSArray* properties = [class observableProperties];
		[allProperties addObjectsFromArray: properties];
	}
	return allProperties;
}

/**
 * KVO convenience method for watching all properties of an object
 */
- (void)addPropertyObserver: (id)observer options: (NSKeyValueObservingOptions)options context: (void*)context
{
	NSArray* properties = [self allObservableProperties];	
	for (NSString* property in properties) {
		[self addObserver: observer
			forKeyPath: property
			options: options
			context: context];
	}
}

/**
 * KVO convenience method for removing an observer of all properties
 */
- (void)removePropertyObserver:(id)observer
{
	NSArray* properties = [self allObservableProperties];
	for (NSString* property in properties) {
		[self removeObserver: observer
			forKeyPath: property];
	}
}

@end
