//
//  Operation2.m
//  NSOperationReproducingRaceCondition
//
//  Created by pronebird on 4/10/16.
//  Copyright © 2016 pronebird. All rights reserved.
//

#import "Operation2.h"

@interface Operation2 ()

@property (nonatomic, getter = isFinished, readwrite)  BOOL finished;
@property (nonatomic, getter = isExecuting, readwrite) BOOL executing;

@end

@implementation Operation2

@synthesize finished  = _finished;
@synthesize executing = _executing;

- (NSString *)debugDescription {
    NSString *stateString = @"Pending";
    
    if([self isExecuting]) {
        stateString = @"Executing";
    }
    else if([self isFinished]) {
        stateString = @"Finished";
    }
    else if([self isReady])
    {
        stateString = @"Ready";
    }
    
    return [NSString stringWithFormat:@"%@ (%@)", [super debugDescription], stateString];
}

- (id)init {
    self = [super init];
    if (self) {
        _finished  = NO;
        _executing = NO;
    }
    return self;
}

- (void)start {
    if ([self isCancelled]) {
        self.finished = YES;
        return;
    }
    
    self.executing = YES;
    
    [self main];
}

- (void)main {
    NSAssert(![self isMemberOfClass:[Operation2 class]], @"Operation2 is abstract class that must be subclassed");
    NSAssert(false, @"Operation2 subclasses must override `main`.");
}

- (void)finish {
    self.executing = NO;
    self.finished  = YES;
}

#pragma mark - NSOperation methods

- (BOOL)isAsynchronous {
    return YES;
}

- (BOOL)isExecuting {
    @synchronized(self) {
        return _executing;
    }
}

- (BOOL)isFinished {
    @synchronized(self) {
        return _finished;
    }
}

- (void)setExecuting:(BOOL)executing {
    if (_executing != executing) {
        [self willChangeValueForKey:@"isExecuting"];
        @synchronized(self) {
            _executing = executing;
        }
        [self didChangeValueForKey:@"isExecuting"];
    }
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    @synchronized(self) {
        if (_finished != finished) {
            _finished = finished;
        }
    }
    [self didChangeValueForKey:@"isFinished"];
}

@end
