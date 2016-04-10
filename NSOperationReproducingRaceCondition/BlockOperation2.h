//
//  BlockOperation2.h
//  NSOperationReproducingRaceCondition
//
//  Created by pronebird on 4/10/16.
//  Copyright © 2016 pronebird. All rights reserved.
//

#import "Operation2.h"

@interface BlockOperation2 : Operation2

- (instancetype)initWithMainQueueBlock:(void(^)(void))block;

- (instancetype)initWithBlock:(void(^)(void(^completeOperation)(void)))block;

@end
