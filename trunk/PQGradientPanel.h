/**
 * \file PQGradientPanel.h
 *
 * Copyright plasq LLC 2007. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

#import "PQGradient.h"
#import "PQGradientWell.h"
#import "PQGradientColorEditor.h"
#import "PQGradientPositionEditor.h"

/**
 * A simple gradient panel for designing linear and circular gradients
 */
@interface PQGradientPanel : NSPanel {

	IBOutlet id _panel;

	IBOutlet PQGradientColorEditor* _colorEditor;
	IBOutlet PQGradientPositionEditor* _positionEditor;

	IBOutlet NSSegmentedControl* _segmentCtrl;

	IBOutlet NSToolbarItem*	_saveButton;
	IBOutlet NSToolbarItem*	_typeCtrl;
	
	BOOL _continuous;
	PQGradient*	_gradient;
	PQGradientWell* _gradientWell;
	
	SEL	_action;
	id	_target;
}

+ (PQGradientPanel *)sharedGradientPanel;

/** sets whether the panel continuously sends changes via the target-action */
- (void)setContinuous:(BOOL)flag;
- (BOOL)isContinuous;

/** Connects a gradient well to the panel */
- (void)setGradientWell:(PQGradientWell*)well;

- (void)setGradient:(PQGradient*)gradient;
- (PQGradient*)gradient;

- (void)setAction:(SEL)aSelector;
- (void)setTarget:(id)anObject;

- (IBAction)setType:(id)sender;

- (IBAction)exportGradient:(id)sender;

@end

/**
 * Helper object for loading the panel from the nib
 */
@interface PQGradientPanelAnchor : NSObject {

	IBOutlet PQGradientPanel* _panel;
}

- (PQGradientPanel*)panel;

@end

