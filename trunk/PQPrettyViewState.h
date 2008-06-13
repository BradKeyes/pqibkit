//
//  PQPrettyViewState.h
//  PlasqIBPalleteKit
//
//  Created by Mathieu Tozer on 15/03/08.
//  Copyright 2008 plasq. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PQButtonValueUnit.h"

@interface PQPrettyViewState : PQButtonValueUnit {
	float _regularRotation;
	BOOL _animateBetweenSiblingView;
	float _fadeRandomThreshold;
}

@property float regularRotation, fadeRandomThreshold;
@property BOOL animateBetweenSiblingView;

@end
