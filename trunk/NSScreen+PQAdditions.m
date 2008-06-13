//
//  NSScreen+PQAdditions.m
//  Comic Life Magiq
//
//  Created by Robert Grant on 2/24/08.
//  Copyright 2008 plasq LLC. All rights reserved.
//

#import "NSScreen+PQAdditions.h"


@implementation NSScreen (PQAdditions)

+ (NSScreen*)menuBarScreen
{
	return [[NSScreen screens] objectAtIndex: 0];
}

- (NSSize)dpi
{
	static NSMutableDictionary* _cachedDPIs = nil;
	if (_cachedDPIs == nil) {
		_cachedDPIs = [NSMutableDictionary dictionaryWithCapacity: 5];
	}
	NSSize dpi = NSZeroSize;
	NSDictionary* description = [self deviceDescription];
	NSNumber* screenNum = [description objectForKey:@"NSScreenNumber"];

	if ([_cachedDPIs objectForKey: screenNum]) {
		NSValue* value = [_cachedDPIs objectForKey: screenNum];
		dpi = [value sizeValue];
	} else {
		if ([NSThread isMainThread]) {
			CGDirectDisplayID displayID = (CGDirectDisplayID)[screenNum pointerValue];
	
			CGSize physicalSize = CGDisplayScreenSize(displayID);
			NSSize currentResolution = [[description objectForKey:NSDeviceResolution] sizeValue];
			if(!CGSizeEqualToSize(physicalSize, CGSizeZero)) {
				NSSize physicalResolution = NSMakeSize((CGDisplayPixelsWide(displayID) / (physicalSize.width / 25.4f)),
											   (CGDisplayPixelsHigh(displayID) / (physicalSize.height / 25.4f)));
				dpi.width = 72 * (physicalResolution.width/currentResolution.width);
				dpi.height = 72 * (physicalResolution.height/currentResolution.height);
			}
			NSAssert(!NSEqualSizes(dpi, NSZeroSize), @"Couldn't calculate the screen dpi!");

			// Saved the calc'd value for access during background threads.
			NSValue* value = [NSValue valueWithSize: dpi];
			[_cachedDPIs setObject: value forKey: screenNum];
		} else {
			// Return the menubarscreen dpi - we've always got that one cached.
			dpi = [[NSScreen menuBarScreen] dpi];
		}
	}
	return dpi;
}

@end
