//
//  PQButtonPath.h
//  PQIBKit
//
//  Created by Mathieu Tozer on 19/08/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PQButtonPath : NSObject {
	NSString *name;
	NSBezierPath *bezierPath;
	int _type;
	int _pointCount;
	float _pointOffset;
	float _radius;
}
@property (retain) NSString *name;
@property (retain) NSBezierPath *bezierPath;
@property int type, pointCount;
@property float pointOffset, radius;


+ (PQButtonPath *)pathWithBezierPath:(NSBezierPath *)bPath;

@end
