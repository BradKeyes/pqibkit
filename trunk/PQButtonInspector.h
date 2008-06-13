//
//  PQButtonInspector.h
//  PlasqIBPalleteKit
//
//  Created by Mathieu Tozer on 23/06/07.
//  Copyright plasq 2007. All rights reserved.
//

#import "PQIBInspector.h"

@interface PQButtonInspector : PQIBInspector {
	IBOutlet id _gradientWell;
	IBOutlet NSArrayController *_statesArrayController;
	IBOutlet NSArrayController *_selValUnitsArrayController;
	IBOutlet NSTreeController *_layersTreeController;
	float  _scaleTo;
	NSArray *_layersSelectionIndexPaths;
	NSIndexSet *_statesSelectionIndexSet;

}

@property (copy) NSArray *layersSelectionIndexPaths;
@property (copy) NSIndexSet *statesSelectionIndexSet;

@end

@interface PQButton (InspectorIntegration)
@end

@interface PQButtonBaseLayer (InspectorIntegration)

@end

//@interface PQButtonState (InspectorIntegration)
//
//@end
//
//@interface PQButtonValueUnit (InspectorIntegration)
//
//@end