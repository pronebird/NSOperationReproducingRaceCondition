//
//  Operation.h
//  NSOperationReproducingRaceCondition
//
//  Created by pronebird on 4/10/16.
//  Copyright © 2016 pronebird. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Operation : NSOperation

- (void)willEnqueue;

- (void)finish;

@end
