//
//  PQIBKitPalette.m
//  PQIBKit
//
//  Created by Mathieu Tozer on 23/06/07.
//  Copyright plasq 2007 . All rights reserved.
//

#import "PQIBKitPalette.h"

@implementation PQIBKitPalette
- (NSArray *)libraryNibNames {
    return [NSArray arrayWithObjects:@"PQButtonLibrary", @"PQPrettyViewLibrary", nil];
}

- (NSArray*)requiredFrameworks 
{ 
	NSBundle* frameworkBundle = [NSBundle 
								 bundleWithIdentifier:@"com.plasq.PQIBKit"]; 
	return [NSArray arrayWithObject:frameworkBundle]; 
} 

@end
