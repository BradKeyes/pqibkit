//
//  PQPrettyViewInspector.h
//  PlasqIBPalleteKit
//
//  Created by Mathieu Tozer on 15/03/08.
//  Copyright 2008 plasq. All rights reserved.
//

#import "PQIBInspector.h"
#import "PQPrettyView.h"

@interface PQPrettyViewInspector : PQIBInspector {
	IBOutlet id _gradientWell;
}
@end

@interface PQPrettyView (InspectorIntegration)

@end