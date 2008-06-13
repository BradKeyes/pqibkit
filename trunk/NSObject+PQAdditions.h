/**
 * \file NSObject+PQAdditions.h
 *
 * Copyright plasq LLC 2007. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

/**
 * Category for implementing Plasq extensions
 *
 * \ingroup AppKitCategories
 */

@interface NSObject (PQAdditions)

#pragma mark Bindings

/**
 * Notify any bound object of the property change
 */
- (void)notifyBoundObjectForKey:(NSString *)key;

#pragma mark Equality

/** 
 * Returns YES if the two objects are =
 */
- (BOOL)isEqualToValueOfObject: (id)object;
 
#pragma mark Property Introspection

/**
 * Return FALSE if the property should not be included in the observable properties.
 * Default implementation returns TRUE.
 */
+ (BOOL)shouldObserve:(NSString *)propertyName;

/** 
 * This method returns an array of NSString names of all this class's 
 * properties, which can be observed via KVO.
 */
+ (NSArray*)observableProperties;

/**
 * This method returns an array of all the properties for an object
 * including properties in a super class
 */
- (NSArray*)allObservableProperties;

/**
 * KVO convenience method for watching all properties of an object
 */
- (void)addPropertyObserver: (id)observer options: (NSKeyValueObservingOptions)options context: (void*)context;

/**
 * KVO convenience method for removing an observer of all properties
 */
- (void)removePropertyObserver:(id)observer;
 
@end
