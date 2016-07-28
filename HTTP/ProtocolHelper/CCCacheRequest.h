//
//  CCCacheRequest.h
//  CCRequest
//
//  Created by xincc.wang on 3/29/16.
//  Copyright © 2016 xincc.wang. All rights reserved.
//

#import "CCRequest.h"
@protocol CCCacheProtocol;

/**
 *  缓存相关需求的网络请求可继承此类
 */
@interface CCCacheRequest : CCRequest

/**
 *  网络请求策略
 */
@property (nonatomic, assign) CCRequestCachePolicy requestCachePolicy;

/**
 *  缓存读取策略
 */
@property (nonatomic, assign) CCReturnCachePolicy returnCachePolicy;

/**
 *  缓存数据策略
 */
@property (nonatomic, assign) CCDataCachePolicy dataCachePolicy;

/**
 *  缓存处理服务
 *  用于缓存数据的读写操作
 *  Default @see CCCacheCenter
 */
@property (nonatomic, strong) id<CCCacheProtocol> service;



@end