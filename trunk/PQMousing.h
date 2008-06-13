//
//  PQMousing.h
//  Table
//
//  Created by Mathieu Tozer on 13/07/07.
//  Copyright 2007 plasq. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSObject (PQMousing)

- (void)dispatchCorrectMouseDownActionForEvent:(NSEvent *)event toObject:(id)object;
- (void)dispatchCorrectMouseUpActionForEvent:(NSEvent *)event toObject:(id)object;

- (void)mouseDraggingStarted:(NSEvent *)event;
- (void)doubleClick:(NSEvent *)event;
- (void)basicMouseDown:(NSEvent *)event;
- (void)shiftMouseUp:(NSEvent *)event;
- (void)shiftMouseDown:(NSEvent *)event;
- (void)willDrag:(NSEvent *)event;
- (void)basicMouseUp:(NSEvent *)event;

@end 

