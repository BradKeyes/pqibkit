//
//  PQState.h
//  PQIBKit
//
//  Created by Mathieu Tozer on 15/03/08.
//  Copyright 2008 plasq. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PQState : NSObject <NSCoding> {
	NSString *_stateName;
	NSString *_stateKey; //immutable
	BOOL _isFirstState;
	}

@property (copy) NSString *stateName, *stateKey;
@property BOOL isFirstState;
+ (NSArray *)keypaths;

+ (PQState *)state;
- (NSString *)name;

- (void)scaleKeypath:(NSString *)key byPercentage:(float)percent;
@end
