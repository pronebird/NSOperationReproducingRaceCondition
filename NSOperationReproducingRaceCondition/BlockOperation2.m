//
//  BlockOperation2.m
//  NSOperationReproducingRaceCondition
//
//  Created by pronebird on 4/10/16.
//  Copyright © 2016 pronebird. All rights reserved.
//

#import "BlockOperation2.h"

@implementation BlockOperation2 {
    void(^_executionBlock)(void(^completeOperation)(void));
}

- (instancetype)initWithBlock:(void(^)(void(^completeOperation)(void)))block
{
    NSCParameterAssert(block);
    
    self = [super init];
    if(!self) {
        return nil;
    }
    
    _executionBlock = [block copy];
    
    return self;
}

- (instancetype)initWithMainQueueBlock:(void(^)(void))executionBlock
{
    void(^mainQueueBlock)() = ^(void(^completeOperation)(void)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            executionBlock();
            completeOperation();
        });
    };
    
    return [self initWithBlock:mainQueueBlock];
}

- (void)main
{
    _executionBlock(^{
        [self finish];
    });
}


@end
