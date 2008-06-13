//
//  BezierPathDropperView.m
//  PlasqIBPalleteKit
//
//  Created by Mathieu Tozer on 19/08/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "BezierPathDropperView.h"

@implementation BezierPathDropperView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		[self registerForDraggedTypes:[NSArray arrayWithObjects:@"NSBezierPathDragType", nil]];
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
	
	[[NSColor blueColor] set];
	[NSBezierPath fillRect:[self bounds]];
}

- (NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender
{
	return NSDragOperationCopy;
}

- (void)draggingExited:(id < NSDraggingInfo >)sender
{
	
}

- (BOOL)prepareForDragOperation:(id < NSDraggingInfo >)sender
{
	return YES;
}

- (BOOL)performDragOperation:(id < NSDraggingInfo >)sender
{
	NSPasteboard *pb = [sender draggingPasteboard];
	NSArray *types = [NSArray arrayWithObjects:@"NSBezierPathDragType", nil];
	NSString *bestType = [pb availableTypeFromArray:types];
	if (bestType != nil) {
	//	NSData *pathData = [pb dataForType:bestType];
	//	[delegate handleDroppedPath:[NSKeyedUnarchiver unarchiveObjectWithData:pathData]];
		//		[[[[delegate inspectedObjectsController] selection] baseView] handleDroppedPaths:filenames];
		
	}
	return YES;
}

@end

