//
//  CCCacheProtocol.h
//  CCRequest
//
//  Created by xincc.wang on 3/25/16.
//  Copyright © 2016 xincc.wang. All rights reserved.
//


/**
 *  给出缓存读写策略的接口,和一个默认实现(CCCacheCenter)
 *  可视业务需求选择自己的缓存读写方案,设计一个实现本接口的类即可
 */

@class CCRequest;

@protocol CCCacheProtocol <NSObject>

@required

- (id)getCacheForRequest:(CCRequest *)request;

- (id)getRevalidatingCacheForRequest:(CCRequest *)request;

- (void)cacheReponse:(id)response ForRequest:(CCRequest *)request;

- (void)cleanCacheForRequrst:(CCRequest *)request;

@optional

- (void)cleanAllCaches;

- (void)cleanAllCachesWithBlock:(void(^)(void))block;

- (void)cleanAllCachesWithProgressBlock:(void(^)(int removedCount, int totalCount))progress
                                 endBlock:(void(^)(BOOL error))end;

@end
