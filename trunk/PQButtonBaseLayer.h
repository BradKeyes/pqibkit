//
//  PQButtonBaseLayer.h
//  PlasqIBPalleteKit
//
//  Created by Mathieu Tozer on 23/06/07.
//  Copyright 2007 plasq. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface CALayer (PQButtonBaseLayer)

- (NSArray *)allLayers;

@end


@class PQButton, PQButtonState, PQButtonValueUnit;

@interface PQButtonBaseLayer : CALayer {
	PQButton *_buttonBase; //kind of like the controller for the button
	NSMutableDictionary *_statesToValueUnits;
	NSString *_layerName;
	BOOL _isBaseLayer;
	
	CATextLayer *_textLayer;
	
	NSValue *_current3DTransformation;
}

@property (retain) PQButton *buttonBase;
@property (retain) NSMutableDictionary *statesToValueUnits;
@property (retain) NSString *layerName;
@property (retain) CATextLayer *textLayer;
@property (retain) NSValue *current3DTransformation;
@property BOOL isBaseLayer;

+ (NSArray *)scalableKeypaths;
- (PQButtonState *)state;
- (id)initWithButtonBase:(PQButton *)buttonBase;
//keeping up with bindings 
- (BOOL)hasValueObjectForState:(PQButtonState *)state;
- (PQButtonValueUnit *)createValueObjectForState:(PQButtonState *)state;
//called once the object knows enough about its environment to start observing things.
- (void)setValuesToReflectCurrentState;
- (PQButtonValueUnit *)valueUnitForState:(PQButtonState *)state;

- (unsigned int)countOfLayers;
- (id)objectInLayersAtIndex:(unsigned int)index;
- (void)removeObjectFromLayersAtIndex:(unsigned int)index;
- (void)insertObject:(id)anObject inLayersAtIndex:(unsigned int)index;
- (NSArray *)layers;
- (void)setLayers:(NSArray *)layers;

- (BOOL)validateNewParent:(id)proposedParent;
- (BOOL)canBeDragged;
- (BOOL)addChild:(id)child atIndex:(int)index;
- (void)animateAnimation:(CAAnimation *)animation;

@end



