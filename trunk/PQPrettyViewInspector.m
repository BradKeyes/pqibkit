//
//  PQPrettyViewInspector.m
//  PlasqIBPalleteKit
//
//  Created by Mathieu Tozer on 15/03/08.
//  Copyright 2008 plasq. All rights reserved.
//

#import "PQPrettyViewInspector.h"
#import "PQPrettyView.h"

@implementation PQPrettyViewInspector

- (void)awakeFromNib
{
	[_gradientWell bind:@"gradient" toObject:self withKeyPath:@"inspectedObjectsController.selection.stateMachine.currentState.gradient" options:nil];
}

- (NSString *)viewNibName {
    return @"PQPrettyViewInspector";
}

- (void)refresh {
	// Synchronize your inspector's content view with the currently selected objects
	[super refresh];
}


- (void)ibPopulateKeyPaths:(NSMutableDictionary *)keyPaths 
{ 
	// Always call super. 
	[super ibPopulateKeyPaths:keyPaths]; 
	// Add any custom attributes. 
 	NSMutableArray *keys = [[[[NSMutableArray alloc] init] retain] autorelease];
	[keys addObjectsFromArray:[PQPrettyView keypaths]];
	[[keyPaths objectForKey:IBAttributeKeyPaths] addObjectsFromArray: keys];
}


@end

@implementation PQPrettyView (InspectorIntegration) 

- (void)ibPopulateAttributeInspectorClasses:(NSMutableArray *)classes 
{ 
	[super ibPopulateAttributeInspectorClasses:classes]; 
	[classes addObject:[PQPrettyViewInspector class]]; 
} 

- (NSView *)ibDesignableContentView
{
	return self;
}


- (NSString *)ibDefaultLabel
{
	return @"PQPrettyView";
}

@end

