//
//  PQButtonInspector.m
//  PQIBKit
//
//  Created by Mathieu Tozer on 23/06/07.
//  Copyright plasq 2007 . All rights reserved.
//

#import "PQButton.h"
#import "PQButtonBaseLayer.h"
#import "PQButtonPath.h"
#import "PQButtonInspector.h"
#import "PQButtonState.h"
#import "PQButtonValueUnit.h"

@implementation PQButtonInspector
@synthesize layersSelectionIndexPaths = _layersSelectionIndexPaths;
@synthesize statesSelectionIndexSet = _statesSelectionIndexSet;


- (id)curSelectedObject
{
	NSArrayController *inspectedObjects = self.inspectedObjectsController;
	NSArray *selectedObjects = [inspectedObjects selectedObjects];
	if ([selectedObjects count] >= 1) {
		return [selectedObjects objectAtIndex:0];
	} else {
		return nil;
	}
}

	//we need to observe changes in the selectionIndexes of the array controllers in the editing nib, and notifify the object proper of that change when they change
	//The button itself need no concept of selection with the layers, only with the states, in which it keeps the 'curState' variable to tell it what is selected at run time. Must remember that at button run time, we don't have any NSArrayController.
	//layersTreeController

- (void)recalculateSelValUnits
{
	//then update the selected value units, so that the inspector can be ready to edit the selection
	
	//first remove them all
	[_selValUnitsArrayController removeObjects:[_selValUnitsArrayController arrangedObjects]];
	
	NSMutableArray *selUnitsBag = [[[NSMutableArray alloc] init] autorelease];
	for (PQButtonBaseLayer *layer in [_layersTreeController selectedObjects]) {
		for (PQButtonState *state in [_statesArrayController selectedObjects]) {
			[selUnitsBag addObject:[layer valueUnitForState:state]];
		}
	}
	[_selValUnitsArrayController addObjects:selUnitsBag];
	[_selValUnitsArrayController setSelectedObjects:selUnitsBag];
}

- (void)setSelectedLayers:(NSArray *)layers
{
	[self recalculateSelValUnits];
}

- (void)setSelectedStates:(NSArray *)states
{
	//first of all, if there is a single object in the array, make it the selValUnit in the button proper so that
	//the button moves to that state and changes visibly.
	if ([states count] == 1) {
		[[self curSelectedObject] setCurrentState:[states lastObject]];	
	}
	[self recalculateSelValUnits];
	
}

//these methods are fired by bindings in the controllers in the nib.
- (void)setLayersSelectionIndexPaths:(NSArray *)value 
{
    if (_layersSelectionIndexPaths != value) {
        [_layersSelectionIndexPaths release];
        _layersSelectionIndexPaths = [value copy];
		//grab the actual objects
		NSArray *selectedLayers = [_layersTreeController selectedObjects];
		[self setSelectedLayers:selectedLayers]; //kick of a selValUnits calculation
    }
}

- (void)setStatesSelectionIndexSet:(NSIndexSet *)value 
{
    if (_statesSelectionIndexSet != value) {
        [_statesSelectionIndexSet release];
        _statesSelectionIndexSet = [value copy];
		NSArray *selectedStates = [_statesArrayController selectedObjects];
		[self setSelectedStates:selectedStates]; //kick off a selValUnits calculation
    }
}

- (void)awakeFromNib
{
	[_gradientWell bind:@"gradient" toObject:_selValUnitsArrayController withKeyPath:@"selection.gradient" options:nil];
}

- (NSString *)viewNibName 
{
	return @"PQButtonInspector";
}

- (void)refresh {
	// Synchronize your inspector's content view with the currently
	// selected objects
	[super refresh];
}


- (void)ibPopulateKeyPaths:(NSMutableDictionary *)keyPaths 
{ 
	// Always call super. 
	[super ibPopulateKeyPaths:keyPaths]; 
	// Add any custom attributes. 
 	NSMutableArray *keys = [[[[NSMutableArray alloc] init] retain] autorelease];
	[keys addObjectsFromArray:[PQButton keypaths]];
	[keys addObjectsFromArray:[PQButtonState keypaths]];
	[keys addObjectsFromArray:[PQButtonValueUnit keypaths]];
	[[keyPaths objectForKey:IBAttributeKeyPaths] addObjectsFromArray: keys];
	[[keyPaths objectForKey:IBToOneRelationshipKeyPaths] addObjectsFromArray: [NSArray arrayWithObjects:@"parentView", nil]]; 
}

- (void) dealloc
{
	[super dealloc];
}


@end

@implementation PQButton (InspectorIntegration) 

- (void)ibPopulateAttributeInspectorClasses:(NSMutableArray *)classes 
{ 
	[super ibPopulateAttributeInspectorClasses:classes]; 
	[classes addObject:[PQButtonInspector class]]; 
} 

- (NSArray *)ibDefaultChildren
{
	return [self allLayers];
}

- (void)setScaleTo:(float)scale
{
	if (scale != 0.0) [self scaleByPercent:scale];
}

- (NSString *)ibDefaultLabel
{
	return @"PQButton";
}

- (NSImage *)ibDefaultImage
{
	return [NSImage imageNamed:@"pqButton"];
}

- (NSView *)ibDesignableContentView
{
	return self;
}

- (void)ibPopulateKeyPaths:(NSMutableDictionary *)keyPaths
{
	[super ibPopulateKeyPaths:keyPaths];
	NSMutableSet *attributesSet = [keyPaths objectForKey:IBAttributeKeyPaths];
	//need to add the attributes for PQButton, PQButtonBaseLayer, and PQState, PQButtonState, PQButtonValueUnit, in a keypath notifyable way.
	[attributesSet addObjectsFromArray:[PQButton attributeKeypaths]];
	//add the attributes from the selValUnits
	NSMutableArray *conjoinedArray = [[[NSMutableArray alloc] init] autorelease];
	for (NSString *keypath in [PQButtonValueUnit attributeKeypaths]) {
	}
	[attributesSet addObjectsFromArray:conjoinedArray];
	
}

@end

@implementation PQButtonBaseLayer (InspectorIntegration) 
- (void)ibPopulateAttributeInspectorClasses:(NSMutableArray *)classes 
{ 
	[super ibPopulateAttributeInspectorClasses:classes]; 
	[classes addObject:[PQButtonInspector class]]; 
} 
@end 

