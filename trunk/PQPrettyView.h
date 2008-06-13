//
//  PQPrettyView.h
//  PlasqIBPalleteKit
//
//  Created by Mathieu Tozer on 15/03/08.
//  Copyright 2008 plasq. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PQPrettyViewStateMachine.h"
//@class PQStateMachine, PQState;
/*
 A State based view where the user can dynamically create states in interface builder and give each state different attributes. Then the application can direct each state simply by calling it by name
 
 [myPrettyView setState:kWarpedState];
 
 and the view will adjust itself.
 
 It is like a PQButton but not a button subclass. The state machine will be shared.
*/

@class PQPrettyViewState;
@interface PQPrettyView : NSView <StateMachineOwner> { 
	PQPrettyViewStateMachine *_stateMachine;
	IBOutlet id delegate;
	IBOutlet PQPrettyView *siblingView;
	IBOutlet PQPrettyView *reverseView;
	
	NSString *_initialState;
	
	NSTimer *_timerForNextFade;
	BOOL _isFadingOut;
	
	id _icon;
	
	PQPrettyViewState *_stateBeforeAnimation;
}

@property (retain) PQStateMachine *stateMachine;
@property (copy) NSString *initialState;
@property BOOL isFadingOut;
@property (retain) id icon;
@property (retain) PQPrettyViewState *stateBeforeAnimation;

+ (NSArray *)keypaths;
- (void)setStateByName:(NSString *)stateName;

// <StateMachineOwner> protocol
- (void)stateChangedTo:(PQState *)state;
- (void)someValueChanged;

- (IBAction)stopAnimationBetweenSiblingView:(id)sender;
- (IBAction)startAnimationBetweenSiblingView:(id)sender;

- (IBAction)moveToNextState:(id)sender;
- (void)startFadeToggleWithDuration:(NSTimer *)timer;

- (IBAction)logDrawingCode:(id)sender;

- (IBAction)flipOverToShowReverseView:(id)sender;
- (void)flipOverToShowView:(PQPrettyView *)aReverseView usingFlipStateNamed:(NSString *)stateName andTargetFlipStateNamed:(NSString *)targetFlipStateName;
@end

@protocol PQPrettyViewDrawingDelegate

- (void)drawIconInView:(PQPrettyView *)view;
- (void)drawView:(PQPrettyView *)view;
- (NSBezierPath *)bezierPathForView:(PQPrettyView *)layer;

@end