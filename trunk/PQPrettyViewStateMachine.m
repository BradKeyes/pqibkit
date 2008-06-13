//
//  PQPrettyViewStateMachine.m
//  PQIBKit
//
//  Created by Mathieu Tozer on 15/03/08.
//  Copyright 2008 plasq. All rights reserved.
//

#import "PQPrettyViewStateMachine.h"
#import "PQPrettyViewState.h"

@implementation PQPrettyViewStateMachine
- (Class)stateClass
{
	return [PQPrettyViewState class];
}

@end
