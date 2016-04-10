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

#import "Operation2.h"
#import "BlockOperation2.h"

@interface NSOperationQueue (SharedNSOperationQueue)

+ (instancetype)ma_sharedQueue2;

@end

@implementation NSOperationQueue (SharedNSOperationQueue)

+ (instancetype)ma_sharedQueue2 {
    static id queue;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        queue = [[self alloc] init];
    });
    
    return queue;
}

@end


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
        NSLog(@"finish");
        [self finish];
    });
}

@end

@interface XCStartOperation2 : BlockOperation2 @end
@implementation XCStartOperation2 @end

@interface XCEndOperation2 : BlockOperation2 @end
@implementation XCEndOperation2 @end

@interface XCMaintenanceOperation2 : Operation2
@end

@implementation XCMaintenanceOperation2

- (void)main
{
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        NSLog(@"finish");
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


- (void)cycle2:(NSInteger)take
{
    NSMutableArray *operations = [[NSMutableArray alloc] init];
    
    XCStartOperation2 *startOperation = [[XCStartOperation2 alloc] initWithMainQueueBlock:^{
        NSLog(@"*** BEGIN TAKE %@ ***", @(take));
    }];
    
    __weak __typeof(self) welf = self;
    
    XCEndOperation2 *finishOperation = [[XCEndOperation2 alloc] initWithMainQueueBlock:^{
        NSLog(@"*** END TAKE %@ ***", @(take));
        
        if(take < 1000)
        {
            [welf cycle2: (take + 1) ];
        }
        else
        {
            NSLog(@"*** THIS IS IT ***");
        }
    }];
    
    for(NSInteger i = 0; i < 500; i++)
    {
        XCMaintenanceOperation2 *op = [[XCMaintenanceOperation2 alloc] init];
        
        [finishOperation addDependency:op];
        
        for(NSOperation *prevOp in operations) {
            [op addDependency:prevOp];
        }
        
        [operations addObject:op];
    }
    
    [operations.firstObject addDependency:startOperation];
    
    [operations addObject:startOperation];
    [operations addObject:finishOperation];
    
    [[NSOperationQueue ma_sharedQueue2] addOperations:operations waitUntilFinished:NO];
}

@end
