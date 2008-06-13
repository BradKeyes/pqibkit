//
//  PlasqIBPalleteKit.m
//  PlasqIBPalleteKit
//
//  Created by Mathieu Tozer on 23/06/07.
//  Copyright plasq 2007 . All rights reserved.
//

#import "PlasqIBPalleteKit.h"

@implementation PlasqIBPalleteKit
- (NSArray *)libraryNibNames {
    return [NSArray arrayWithObjects:@"PQButtonLibrary", @"PQPrettyViewLibrary", nil];
}

- (NSArray*)requiredFrameworks 
{ 
	NSBundle* frameworkBundle = [NSBundle 
								 bundleWithIdentifier:@"com.plasq.PlasqIBPalleteKitFramework"]; 
	return [NSArray arrayWithObject:frameworkBundle]; 
} 

@end
