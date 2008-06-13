
//
//  PQMousing.m
//  Table
//
//  Created by Mathieu Tozer on 13/07/07.
//  Copyright 2007 plasq. All rights reserved.
//

#import "PQMousing.h"

const NSTimeInterval kTimeToWaitForDrag = .1;
@implementation NSObject (PQMousing)

- (void)dispatchCorrectMouseDownActionForEvent:(NSEvent *)event toObject:(id)object
{
	//have a look for double click actions
	if ([event clickCount] == 2) {
		if ([object respondsToSelector:@selector(doubleClick:)]) {
			[object doubleClick:event];
			return;
		}
	}
	
	BOOL extending = (([event modifierFlags] & NSShiftKeyMask) ? YES : NO);
	if (extending) {
		if ([object respondsToSelector:@selector(shiftMouseDown:)]) [object shiftMouseDown:event];	
	} else {
		if ([object respondsToSelector:@selector(basicMouseDown:)]) [object basicMouseDown:event];
	}
}

- (void)dispatchCorrectMouseUpActionForEvent:(NSEvent *)event toObject:(id)object
{
	BOOL extending = (([event modifierFlags] & NSShiftKeyMask) ? YES : NO);
	if (extending) {
		if ([object respondsToSelector:@selector(shiftMouseUp:)]) [object shiftMouseUp:event];	
	} else {
		if ([object respondsToSelector:@selector(basicMouseUp:)]) [object basicMouseUp:event];
	}
}


//subclasses may implement these
- (void)mouseDraggingStarted:(NSEvent *)event
{
	
}
- (void)doubleClick:(NSEvent *)event
{
	
}
- (void)basicMouseDown:(NSEvent *)event
{
	
}
- (void)shiftMouseUp:(NSEvent *)event
{
	
}
- (void)shiftMouseDown:(NSEvent *)event
{
	
}
- (void)willDrag:(NSEvent *)event
{
	
}
- (void)basicMouseUp:(NSEvent *)event
{
	
}

@end
