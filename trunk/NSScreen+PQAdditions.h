/**
 * \file NSScreen+PQAdditions.h
 *
 * Copyright plasq LLC 2008 All rights reserved.
 */

#import <Cocoa/Cocoa.h>


/**
 * Category for implementing Plasq extensions
 * Provide a simple method of detecting the DPI for a screen
 *
 * \ingroup AppKitCategories
 */

@interface NSScreen (PQAdditions)

+ (NSScreen*)menuBarScreen;
- (NSSize)dpi;

@end
