//
//  NSString+PathAdditions.m
//  Manybooks
//
//  Created by Mathieu Tozer on 1/04/08.
//  Copyright 2008 plasq. All rights reserved.
//

#import "NSString+PathAdditions.h"


@implementation NSString (PathAdditions)

- (NSImage *)iconAtPath
{
	//ask for an icon representing the 
	return [NSImage imageWithPreviewOfFileAtPath:self ofSize:NSMakeSize(200, 200) asIcon:YES];
}

@end
