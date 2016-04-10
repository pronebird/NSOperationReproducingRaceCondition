//
//  ViewController.m
//  NSOperationReproducingRaceCondition
//
//  Created by pronebird on 4/10/16.
//  Copyright © 2016 pronebird. All rights reserved.
//

#import "ViewController.h"

#import "OperationQueue.h"
#import "Operation.h"
#import "BlockOperation.h"

@interface OperationQueue (SharedQueue)

+ (instancetype)ma_sharedQueue;

@end

@implementation OperationQueue (SharedQueue)

+ (instancetype)ma_sharedQueue {
    static id queue;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        queue = [[self alloc] init];
    });
    
    return queue;
}

@end

@interface XCStartOperation : BlockOperation @end
@implementation XCStartOperation @end

@interface XCEndOperation : BlockOperation @end
@implementation XCEndOperation @end

@interface XCMaintenanceOperation : Operation
@end

@implementation XCMaintenanceOperation

- (void)main
{
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        [self finish];
    });
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self cycle:1];
}

- (void)cycle:(NSInteger)take
{
    NSMutableArray *operations = [[NSMutableArray alloc] init];
    
    XCStartOperation *startOperation = [[XCStartOperation alloc] initWithMainQueueBlock:^{
        NSLog(@"*** BEGIN TAKE %@ ***", @(take));
    }];
    
    __weak __typeof(self) welf = self;
    
    XCEndOperation *finishOperation = [[XCEndOperation alloc] initWithMainQueueBlock:^{
        NSLog(@"*** END TAKE %@ ***", @(take));
        
        if(take < 1000)
        {
            [welf cycle: (take + 1) ];
        }
        else
        {
            NSLog(@"*** THIS IS IT ***");
        }
    }];
    
    for(NSInteger i = 0; i < 500; i++)
    {
        XCMaintenanceOperation *op = [[XCMaintenanceOperation alloc] init];
        
        [finishOperation addDependency:op];
        
        for(NSOperation *prevOp in operations) {
            [op addDependency:prevOp];
        }
        
        [operations addObject:op];
    }
    
    [operations.firstObject addDependency:startOperation];
    
    [operations addObject:startOperation];
    [operations addObject:finishOperation];
    
    [[OperationQueue ma_sharedQueue] addOperations:operations waitUntilFinished:NO];
}

@end
