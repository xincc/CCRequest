//
//  CCPromise.h
//  CCRequest
//
//  Created by xincc.wang on 7/14/16.
//  Copyright © 2016 xincc.wang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CCPromiseResoverStatus) {
    CCPromiseResoverStatusPending,
    CCPromiseResoverStatusFulfilled,
    CCPromiseResoverStatusRejected
};

typedef id(^CCPromiseEventHandler)(id);

/**
 *  Class CCPromise
 */

@interface CCPromise : NSObject

@property (nonatomic, copy) CCPromise*(^then)(CCPromiseEventHandler,CCPromiseEventHandler);

@property (nonatomic, copy) CCPromise*(^next)(CCPromiseEventHandler);

//不能放在链首
@property (nonatomic, copy) CCPromise*(^catch)(void(^)(id reason));

@property (nonatomic, copy) dispatch_block_t done;

@property (nonatomic, copy) dispatch_block_t run;

+ (CCPromise *)all:(NSArray<CCPromise *> *)promises;

+ (CCPromise *)promise;

+ (CCPromise *)fulfilled;

+ (CCPromise *)rejected;

- (id)fulfill:(id)data;

- (id)reject:(id)reason;

@end
