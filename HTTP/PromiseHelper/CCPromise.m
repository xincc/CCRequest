//
//  CCPromise.m
//  CCRequest
//
//  Created by xincc.wang on 7/14/16.
//  Copyright © 2016 xincc.wang. All rights reserved.
//

#import "CCPromise.h"
#include "CCRequestConstants.h"

typedef CCPromise*(^CCPromiseWorkEventHandler)();

@interface CCPromise()

@property (nonatomic, copy) void(^done)();

@property (nonatomic, strong) id data;

@property (nonatomic, assign) BOOL called;

@property (nonatomic, assign) CCPromiseResoverStatus status;
@property (nonatomic, strong) NSMutableArray *fulfillQueue;
@property (nonatomic, strong) NSMutableArray *rejectQueue;

@end


@implementation CCPromise


#pragma mark - Lifecycle

- (void)dealloc {
//    NSLog(@"promise dealloc %p", self);
}


- (instancetype)init {
    self = [super init];
    if (self) {
        self.status = CCPromiseResoverStatusPending;
        self.fulfillQueue = [NSMutableArray arrayWithCapacity:0];
        self.rejectQueue  = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}


+ (CCPromise *)promise {
    CCPromise *promise = [[CCPromise alloc] init];
    [promise setup];
    return promise;
}

/**
 *  bind chain
 *
 *  @return a promise node of resover chian
 */
- (CCPromise *)chainNodePromiseWithResover:(CCPromise *)resolver {
    CCPromise *promise = [[CCPromise alloc] init];
    promise.resover = resolver?:self;
    [promise setup];
    return promise;
}


- (void)setup {

    __weak __typeof(self) weakSelf = self;
    
    self.then = ^id(CCPromiseEventHandler onFulfilled,CCPromiseEventHandler onRejected) {
        __strong __typeof(weakSelf) self = weakSelf;
        return [self then:onFulfilled onRejected:onRejected];
    };

    self.next = ^id(CCPromiseEventHandler onFulfilled) {
        __strong __typeof(weakSelf) self = weakSelf;
        return [self next:onFulfilled];
    };
    
    self.catch = ^CCPromise*(void(^onRejected)(id reason)) {
        __strong __typeof(weakSelf) self = weakSelf;

        id(^warpedOnRejected)(id reason) = ^id(id reason) {
            CCPromiseWorkEventHandler work = ^id(){
                onRejected(reason);
                return nil;
            };
            return work();
        };
        
        CCPromise *resover = self.resover?:self;

        [self addListener:CCPromiseResoverStatusRejected callback:warpedOnRejected];
        
        [resover addListener:CCPromiseResoverStatusRejected callback:warpedOnRejected];
        
        return self;
    };
}

#pragma mark - Action

- (CCPromise *)then:(CCPromiseEventHandler)onFulfilled
         onRejected:(CCPromiseEventHandler)onRejected {
    
    CCPromise *promise = [self chainNodePromiseWithResover:self.resover];
    
    __weak __typeof(self) weakPromise = promise;
    if (onFulfilled) {
        onFulfilled = [CCPromise wrapPromise:promise callback:onFulfilled];
    } else {
        onFulfilled = ^id(id data) {
            __strong __typeof(weakPromise) promise = weakPromise;
            return [promise fulfill:data];
        };
    }
    [self addListener:CCPromiseResoverStatusFulfilled callback:onFulfilled];
    
    if (onRejected) {
        onRejected = [CCPromise wrapPromise:promise callback:onRejected];
    } else {
        onRejected = ^id(id reason) {
            __strong __typeof(weakPromise) promise = weakPromise;
            return [promise reject:reason];
        };
    }
    [self addListener:CCPromiseResoverStatusRejected callback:onRejected];
    
//    onExit {
        if (self.run) {
            self.run();
        }
//    };

    return promise;
}

- (CCPromise *)next:(CCPromiseEventHandler)onFulfilled {
    
    CCPromise *promise = [self chainNodePromiseWithResover:self.resover];
    
    __weak __typeof(self) weakPromise = promise;
    if (onFulfilled) {
        onFulfilled = [CCPromise wrapPromise:promise callback:onFulfilled];
    } else {
        onFulfilled = ^id(id data) {
            __strong __typeof(weakPromise) promise = weakPromise;
            return [promise fulfill:data];
        };
    }
    
    [self addListener:CCPromiseResoverStatusFulfilled callback:onFulfilled];
    
    [self addListener:CCPromiseResoverStatusRejected callback:^id(id reason) {
//#warning Need Warp
        __strong __typeof(weakPromise) promise = weakPromise;
        CCPromise *resover = promise.resover;
        if (resover && resover.status == CCPromiseResoverStatusFulfilled) {
            resover.status = CCPromiseResoverStatusPending;
        }
        return [resover reject:reason];
    }];
    
    onExit {
        if (self.run) {
            self.run();
        }
    };
    
    return promise;
}

/**
 *  In Queue
 *
 *  @param callback
 */
- (void)addListener:(CCPromiseResoverStatus)status callback:(CCPromiseEventHandler)callback {
    if (self.status == status) {
        callback(self.data);
    } else if (status == CCPromiseResoverStatusFulfilled) {
        [self.fulfillQueue insertObject:callback atIndex:0];
    } else if (status == CCPromiseResoverStatusRejected) {
        [self.rejectQueue insertObject:callback atIndex:0];
    }
}

- (id)reject:(id)reason{
    if (self.status != CCPromiseResoverStatusPending) {
        return nil;
    }
    self.data = reason;
    self.status = CCPromiseResoverStatusRejected;
    return [self emit];
}

- (id)fulfill:(id)data{
    if (self.status != CCPromiseResoverStatusPending) {
        return nil;
    }
    self.data = data;
    self.status = CCPromiseResoverStatusFulfilled;
    return [self emit];
}

/**
 *  Emit all callbacks but only return the first promise object
 *
 *  @return promise object
 */

- (id)emit {
    
    NSMutableArray *items = self.status == CCPromiseResoverStatusFulfilled?self.fulfillQueue:self.rejectQueue;
    
    if (!items.count) {
        return nil;
    }
    
    CCPromiseEventHandler callback = items.lastObject;
    for (int i = 0; i < items.count-1; i++) {
        CCPromiseEventHandler callback = items[i];
        callback(self.data);
    }
    
    onExit {
        [items removeAllObjects];
    };
    
    return callback(self.data);
    
}


+ (CCPromiseEventHandler)wrapPromise:(CCPromise *)promise
                            callback:(CCPromiseEventHandler)callback {
    
    return ^id(id data) {
        CCPromiseWorkEventHandler work = ^id(){
            id res = callback(data);
            if (res == promise) {
                return [CCPromise rejected];
            }
            return [CCPromise resolve:promise value:res];
        };
        return work();
    };
}

+ (CCPromiseEventHandler)wrapResover:(CCPromise *)resolver
                            callback:(CCPromiseEventHandler)callback {
    return ^id(id data) {
        CCPromiseWorkEventHandler work = ^id(){
            id res = callback(data);
            if (res == resolver) {
                return [CCPromise rejected];
            }
            return res;
        };
        return work();
    };
}


/**
 *
 *  @param promise promise
 *  @param value    promise or data
 *
 *  @return next promise or data
 */
+ (id)resolve:(CCPromise *)promise value:(CCPromise *)value {
    
    __weak __typeof(promise) weakPromise = promise;
    __weak __typeof(value) weakValue = value;
    
    CCPromiseEventHandler onFulfilled = ^id(id data) {
        if (promise && !promise.called) {
            promise.called = YES;
            return [CCPromise resolve:promise value:data];
        }
        return [CCPromise fulfilled];
    };
    
    CCPromiseEventHandler onRejected = ^id(id reason) {
        
        if (promise && !promise.called) {
            promise.called = YES;
            return [promise reject:reason];
        }
        return [CCPromise rejected];
    };
    
    CCPromiseWorkEventHandler work = ^id(){
        __strong __typeof(weakPromise) promise = weakPromise;
        __strong __typeof(weakValue) value = weakValue;
        
        if ([value isKindOfClass:CCPromise.class] && [value respondsToSelector:@selector(then)]) {
            return value.then(onFulfilled, onRejected);
        } else {
            return [promise fulfill:value];
        }
    };
    
    return work();
}

+ (CCPromise *)all:(NSArray<CCPromise *> *)promises {
    
    CCPromise *resolver = [CCPromise promise];
    
    __block NSInteger resolvedCount = 0;
    NSMutableArray *res = [NSMutableArray arrayWithCapacity:promises.count];
    
    CCPromiseEventHandler(^createResolvedHandler)(NSInteger) = ^CCPromiseEventHandler(NSInteger index) {
        return ^id(id data) {
            [res addObject:data];
            if (++resolvedCount >= promises.count) {
                return [resolver fulfill:res];
            }
            return nil;
        };
    };
    
    CCPromiseEventHandler rejectedHandler = ^id(id reason) {
        return [resolver reject:reason];
    };
    
    [promises enumerateObjectsUsingBlock:^(CCPromise * _Nonnull promise, NSUInteger idx, BOOL * _Nonnull stop) {
        NSAssert([promise isKindOfClass:CCPromise.class], @"require instance of CCPromise");
        promise.then(createResolvedHandler(idx), rejectedHandler);
    }];
    
    return resolver;
}

+ (CCPromise *)fulfilled {
    CCPromise *promise = [CCPromise promise];
    promise.status = CCPromiseResoverStatusFulfilled;
    return promise;
}

+ (CCPromise *)rejected {
    CCPromise *promise = [CCPromise promise];
    promise.status = CCPromiseResoverStatusRejected;
    return promise;
}

#pragma mark - Getter

- (void (^)())done {
    if (!_done) {
        __weak __typeof(self) weakSelf = self;
        _done = [^() {
            __strong __typeof(weakSelf) self = weakSelf;
            self.status = CCPromiseResoverStatusFulfilled;
        } copy];
    }
    return _done;
}

@end

