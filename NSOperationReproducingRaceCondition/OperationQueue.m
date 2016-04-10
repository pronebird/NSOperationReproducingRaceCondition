//
//  OperationQueue.m
//  NSOperationReproducingRaceCondition
//
//  Created by pronebird on 4/10/16.
//  Copyright © 2016 pronebird. All rights reserved.
//

#import "OperationQueue.h"
#import "Operation.h"

@implementation OperationQueue

- (void)addOperation:(NSOperation *)operation
{
    if([operation isKindOfClass:[Operation class]])
    {
        Operation *op = (Operation *)operation;
        
        [op willEnqueue];
    }
    
    [super addOperation:operation];
}

- (void)addOperations:(NSArray *)operations waitUntilFinished:(BOOL)wait
{
    /**
     *  The base implementation of this method does not call `-addOperation:`,
     *  so we'll call it ourselves.
     */
    for (NSOperation *operation in operations) {
        [self addOperation:operation];
    }
    
    if (wait) {
        for (NSOperation *operation in operations) {
            [operation waitUntilFinished];
        }
    }
}

@end
