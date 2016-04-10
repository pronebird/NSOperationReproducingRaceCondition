//
//  Operation.m
//  NSOperationReproducingRaceCondition
//
//  Created by pronebird on 4/10/16.
//  Copyright © 2016 pronebird. All rights reserved.
//

#import "Operation.h"

typedef NS_ENUM(NSInteger, OperationState) {
    OperationStateInitialized,
    OperationStatePending,
    OperationStateEvaluatingConditions,
    OperationStateReady,
    OperationStateExecuting,
    OperationStateFinished
};

NSString *NSStringFromOperationState(OperationState state)
{
    switch (state) {
        case OperationStateInitialized:
            return @"Initialized";
            
        case OperationStateReady:
            return @"Ready";
            
        case OperationStatePending:
            return @"Pending";
            
        case OperationStateFinished:
            return @"Finished";
            
        case OperationStateExecuting:
            return @"Executing";
            
        case OperationStateEvaluatingConditions:
            return @"EvaluatingConditions";
    }
}

@interface Operation ()

@property (nonatomic) OperationState state;

@end

@implementation Operation

@synthesize state = _state;

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@ (%@)", [super debugDescription], NSStringFromOperationState(self.state)];
}

- (instancetype)init {
    self = [super init];
    if(!self) {
        return nil;
    }
    
    _state = OperationStateInitialized;
    
    return self;
}

- (void)start {
    if ([self isCancelled]) {
        self.state = OperationStateFinished;
        return;
    }
    
    self.state = OperationStateExecuting;
    
    [self main];
}

- (void)main
{
    NSAssert(![self isMemberOfClass:[Operation class]], @"Operation is abstract class that must be subclassed");
    NSAssert(false, @"Operation subclasses must override `main`.");
}

- (void)willEnqueue
{
    self.state = OperationStatePending;
}

- (void)evaluateConditions {
    self.state = OperationStateEvaluatingConditions;
    
    // pretend we evaluate conditions.
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        self.state = OperationStateReady;
    });
}

- (void)finish
{
    self.state = OperationStateFinished;
}

#pragma mark - NSOperation methods

- (BOOL)isAsynchronous {
    return YES;
}

- (BOOL)isReady {
    switch(self.state) {
            
        case OperationStateInitialized:
            return [self isCancelled];
            
        case OperationStatePending:
            if ([self isCancelled]) {
                return YES;
            }
            
            if([super isReady]) {
                [self evaluateConditions];
            }
            
            return NO;
            
        case OperationStateReady:
            return [super isReady] || [self isCancelled];
            
        default:
            return NO;
    }
}

- (BOOL)isExecuting {
    return self.state == OperationStateExecuting;
}

- (BOOL)isFinished {
    return self.state == OperationStateFinished;
}

- (OperationState)state {
    @synchronized (self) {
        return _state;
    }
}

- (void)setState:(OperationState)state
{
    [self willChangeValueForKey:@"state"];
    
    @synchronized (self) {
        _state = state;
    }
    
    [self didChangeValueForKey:@"state"];
}

+ (BOOL)automaticallyNotifiesObserversOfState
{
    return NO;
}

+ (NSSet *)keyPathsForValuesAffectingIsReady
{
    return [NSSet setWithObject:NSStringFromSelector(@selector(state))];
}

+ (NSSet *)keyPathsForValuesAffectingIsExecuting
{
    return [NSSet setWithObject:NSStringFromSelector(@selector(state))];
}

+ (NSSet *)keyPathsForValuesAffectingIsFinished
{
    return [NSSet setWithObject:NSStringFromSelector(@selector(state))];
}

@end
