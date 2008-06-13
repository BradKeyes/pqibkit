//
//  LayersOutlineViewDelegate.m
//  PQIBKit
//
//  Created by Mathieu Tozer on 1/05/08.
//  Copyright 2008 plasq. All rights reserved.
//

#import "LayersOutlineViewDelegate.h"
#import "PQButtonBaseLayer.h"
#import <Quartz/Quartz.h>

#define PQButtonBaseViewType @"PQButtonBaseViewType"

@implementation LayersOutlineViewDelegate

- (void)registerDragTypes
{
	[_outlineView registerForDraggedTypes:[NSArray arrayWithObjects:PQButtonBaseViewType, nil]];
}

- (void)writeObject:(id)object toPasteboard:(NSPasteboard *)pboard
{
	//It's a PQButtonBaseLayer
	[pboard declareTypes:[NSArray arrayWithObject:PQButtonBaseViewType] owner:self];
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
	[pboard setData:data forType:PQButtonBaseViewType];
}

- (BOOL)outlineView:(NSOutlineView *)ov acceptDrop:(id)info item:(id)item childIndex:(int)aIndex tryDefaultHandling:(BOOL*)doDefault
{
	//item is the proposed parent
	NSPasteboard *pb = [info draggingPasteboard];
	NSData *data = [pb dataForType:PQButtonBaseViewType];
	CALayer *layer = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	CALayer *theItemLayer = [self theObjectWithNodeItem:item];
	if (item) {
		[(PQButtonBaseLayer *)theItemLayer insertObject:layer inLayersAtIndex:aIndex];		
	} else {
		//we're probably just reordering.
	}
	
	return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id)info proposedItem:(id)item proposedChildIndex:(int)aIndex tryDefaultHandling:(BOOL*)doDefault
{
	NSPasteboard *pb = [info draggingPasteboard];
	NSData *data = [pb dataForType:PQButtonBaseViewType];
	CALayer *layer = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	if (layer == item) return NSDragOperationNone; //can't drop onto self
	
	return NSDragOperationMove;
}

@end
