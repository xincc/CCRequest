//
//  CCRequestEnumrator.h
//  CCRequest
//
//  Created by xincc.wang on 3/11/16.
//  Copyright © 2016 xincc.wang. All rights reserved.
//

#ifndef CCRequestEnumrator_h
#define CCRequestEnumrator_h

typedef NS_ENUM(NSInteger, CCRequestMethod) {
    CCRequestMethodGet = 0,
    CCRequestMethodPost,
    CCRequestMethodHead,
    CCRequestMethodPut,
    CCRequestMethodDelete,
    CCRequestMethodPatch
};

typedef NS_ENUM(NSInteger, CCResponseSerializerType) {
    //适用与普通请求
    CCResponseSerializerTypeJSON = 0,
    //适用于文件传输
    CCResponseSerializerTypeRawData,
};

typedef NS_ENUM(NSInteger, CCReachabilityLevel) {
    CCReachabilityLevelLocal,
    //待实现
    CCReachabilityLevelReal
};

typedef NS_ENUM(NSInteger, CCRequestStatus) {
    //默认状态
    CCRequestStatusNone,
    //正在运行
    CCRequestStatusRunning,
    //手动结束
    CCRequestStatusStop,
    //手动取消
    CCRequestStatusCanceled,
    //正常结束
    CCRequestStatusComplete
};

// 网络请求策略:

typedef NS_ENUM(NSUInteger, CCRequestCachePolicy) {
    
    // 永远忽略缓存,仅读远程数据
    CCRequestReloadRemoteDataIgnoringCacheData,
    
    // 优先先读取缓存,若读取成功,不再发起请求,反之读远程数据
    CCRequestReturnCacheDataElseReloadRemoteData,
    
    // 优先先读取缓存,若读取成功,先执行回调逻辑,再读远程数据,反之读远程数据
    CCRequestReturnCacheDataThenReloadRemoteData,
    
    // 优先读取远程数据,若读取失败,读取缓存
    CCRequestReloadRemoteDataElseReturnCacheData,
};

// 缓存读取策略:

typedef NS_ENUM(NSUInteger, CCReturnCachePolicy) {
    
    // 按设置的缓存过期时间读取
    CCReturnCacheDataByFireTime,
    
    // 若有缓存,强制重新激活缓存后读取
    CCReloadRevalidatingCacheData
};

// 数据缓存策略:

typedef NS_ENUM(NSUInteger, CCDataCachePolicy) {
    
    // 缓存解析后的模型(如果使用默认的缓存服务,要求模型层实现NSCoding协议)
    CCCachePolicyModel,
    
    // 缓存JSON对象或者元数据,取决于CCResponseSerializerType
    CCCachePolicyRawData,
};

#endif /* CCRequestEnumrator_h */
