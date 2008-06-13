//
//  PQButtonPath.m
//  PlasqIBPalleteKit
//
//  Created by Mathieu Tozer on 19/08/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PQButtonPath.h"

@implementation PQButtonPath
@synthesize name, bezierPath;
@synthesize type = _type;
@synthesize pointCount = _pointCount;
@synthesize pointOffset = _pointOffset;
@synthesize radius = _radius;

+ (PQButtonPath *)pathWithBezierPath:(NSBezierPath *)bPath
{
	PQButtonPath *new = [[[[PQButtonPath alloc] init] retain] autorelease];
	[new setBezierPath:bPath];
	return new;
}


- (id)initWithCoder:(NSCoder *)coder 
{
    if ([coder allowsKeyedCoding]) {
		self.name = [coder decodeObjectForKey:@"name"];
		self.bezierPath = [coder decodeObjectForKey:@"bezierPath"];	
		self.type = [coder decodeIntForKey:@"type"];
		self.pointCount = [coder decodeIntForKey:@"pointCount"];
		self.pointOffset = [coder decodeFloatForKey:@"pointOffset"];
		self.radius = [coder decodeFloatForKey:@"radius"];
	}
    return self;
}


- (void)encodeWithCoder:(NSCoder *)coder 
{
	[coder encodeObject:self.name forKey:@"name"];
	[coder encodeObject:self.bezierPath forKey:@"bezierPath"];
	[coder encodeInt:self.type forKey:@"type"];
	[coder encodeInt:self.pointCount forKey:@"pointCount"];
	[coder encodeFloat:self.pointOffset forKey:@"pointOffset"];
	[coder encodeFloat:self.radius forKey:@"radius"];
	return;
}
@end
