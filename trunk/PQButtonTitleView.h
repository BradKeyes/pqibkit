//
//  PQButtonTitleView.h
//  PlasqIBPalleteKit
//
//  Created by Mathieu Tozer on 27/07/07.
//  Copyright 2007 plasq. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "PQButton.h"
/*
 This view will hold an attributed string and draw it when the layer that backs the view calls for it. It can change it's x and y coordinates, but the size will be determined by the length of the attributed string.
 
 The title view should intercept no mouse down events, passing them through to the PQButtonBaseLayer instead.
 */

@interface PQButtonTitleView : PQButtonBaseLayer {
	NSView *baseView; //we ask for state information and send events here
	
	//inactive
	NSAttributedString *inTitle;
	float inOriginX, inOriginY;
	float inToDuration;
	
	// moused over
	NSAttributedString *moTitle;
	float moOriginX, moOriginY;
	float moToDuration;
	
	// active - mouse down
	NSAttributedString *acTitle;
	float acOriginX, acOriginY;
	float acToDuration;
	
	PQButton *rootButton;
}

//inactive
@property (retain) NSAttributedString *inTitle;
@property float inOriginX, inOriginY;
@property float inToDuration;
@property (retain) PQButton *rootButton;

// moused over
@property (retain) NSAttributedString *moTitle;
@property float moOriginX, moOriginY;
@property float moToDuration;

// active - mouse down
@property (retain) NSAttributedString *acTitle;
@property float acOriginX, acOriginY;
@property float acToDuration;

- (void)initialise;
- (void)registerToObserveState;
+ (NSArray *)keypaths;

//inactive
- (NSRect)inactiveRect;
- (NSRect)mouseOverRect;
- (NSRect)activeRect;


@end


