//
//  PlasqIBPalleteKitWidget.h
//  PlasqIBPalleteKit
//
//  Created by Mathieu Tozer on 23/06/07.
//  Copyright plasq 2007 . All rights reserved.
//

/*
 A PQButton is essentially a long list of instance variables that describe the visual appearance of an animated button which changes its appearance based on the state and the said instance variables. 
 
 The variables can be set up in interface builder, using the inspector pallete, and then built and run in your project.
 */

#import <Cocoa/Cocoa.h>

extern const NSString *kPQButtonMouseDown;
extern const NSString *kPQButtonMouseUp;
extern const NSString *kPQButtonMouseEntered;
extern const NSString *kPQButtonMouseExited;
extern const NSString *kPQButtonRightMouseDown;
extern const NSString *kPQButtonScroll;
extern const NSString *kPQButtonKeyDown;
extern const NSString *kPQButtonDoubleClick;
extern const NSString *kPQButtonShiftMouseDown;
extern const NSString *kPQButtonShiftMouseUp;
extern const NSString *kPQButtonMouseDragged;

@class PQButtonBaseLayer, PQButtonTitleView, PQButtonPath, PQButtonEffectView, PQButtonState, PQButtonValueUnit;

@protocol PQButtonDrawingDelegate

- (void)drawIconInLayer:(PQButtonBaseLayer *)layer;
- (void)drawLayer:(PQButtonBaseLayer *)layer;
- (NSBezierPath *)bezierPathForLayer:(PQButtonBaseLayer *)layer;

@end

@interface PQButton : NSButton {	
	//the various views
	NSColor *color;
	BOOL drawBorder;
	
	NSMutableArray *_paths;
	IBOutlet id <PQButtonDrawingDelegate> delegate; //todo also set up bindings?
	
	NSMutableArray *_states;
	PQButtonState *_currentState;
	id _selectedLayer;
	PQButtonBaseLayer *_previousLayerSelection;
	
	BOOL _isInsertingDuplicateLayer;
	
	int _nextStateID;
	
	BOOL _isPureLayerButton;
	BOOL _isInInterfaceBuilder;
	
	BOOL _isDragging;
	
	NSEvent *_originalMouseEvent;
	
	float _scaleTo;
}

+ (NSArray *)keypaths;
+ (NSArray *)attributeKeypaths;
+ (NSArray *)toManyKeypaths;
//returns an array of strings to selectors which the button responds, for use in setting up state changes
- (NSArray *)humanReadableSelectorsForActions;

//views
@property (retain) PQButtonState *currentState;
//attributes - this class doesn't actually draw anything.
@property (retain) NSColor *color;
@property BOOL drawBorder, isPureLayerButton, isInInterfaceBuilder, isInsertingDuplicateLayer;

@property (retain) PQButtonBaseLayer *previousLayerSelection;
@property int nextStateID;
@property float scaleTo;

- (id<PQButtonDrawingDelegate>)delegate;
#pragma mark Bindings Compatability
- (unsigned int)countOfPaths;
- (id)objectInPathsAtIndex:(unsigned int)index;
- (void)removeObjectFromPathsAtIndex:(unsigned int)index;
- (void)insertObject:(id)anObject inPathsAtIndex:(unsigned int)index;
- (NSArray *)paths;
- (void)setPaths:(NSArray *)paths;

- (unsigned int)countOfStates;
- (id)objectInStatesAtIndex:(unsigned int)index;
- (void)removeObjectFromStatesAtIndex:(unsigned int)index;
- (void)insertObject:(id)anObject inStatesAtIndex:(unsigned int)index;
- (NSArray *)states;
- (void)setStates:(NSArray *)states;

- (void)handleDroppedPath:(NSBezierPath *)path;

- (void)aValueUnitChanged;

- (PQButtonBaseLayer *)newLayer;

- (void)forAllLayersSetObjectValue:(id)object forKey:(NSString *)key inState:(PQButtonState *)state;

- (void)duplicateLayer:(PQButtonBaseLayer *)layer;
//this goes through all atributes and transforms them by a certain delta.
//- (void)scaleObjectByDelta:(float)delta;
//logs an objective-c code PQButton class method for the current button.
//- (void)logTheClassInitializer;

//set the current state with this exterior name
- (void)setStateCalled:(NSString *)stateName;
//NSOffState, NSOnState, or NSMixedState
- (void)setNSState:(int)nsState;

- (void)moveLayerUp:(PQButtonBaseLayer *)layer;
- (void)moveLayerDown:(PQButtonBaseLayer *)layer;

- (void)saveButtonArchiveToDesktop;

- (void)scaleByPercent:(float)percent;
- (NSArray *)allLayers;
- (void)makeSureEachValueUnitIsOwnedByUs;

@end