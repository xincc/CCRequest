//
//  CCCacheRequest.m
//  CCRequest
//
//  Created by xincc.wang on 3/29/16.
//  Copyright © 2016 xincc.wang. All rights reserved.
//

#import "CCCacheRequest.h"
#import "CCResponseError.h"
#import "CCCacheCenter.h"
#import "CCRequestDispatchCenter.h"
#import "CCRequest+Private.h"

@interface CCCacheRequest ()

@end

@implementation CCCacheRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        self.service = [CCCacheCenter defultCenter];
    }
    return self;
}

- (void)start {
    
    do {
        //发起网络请求
        if (self.requestCachePolicy == CCRequestReloadRemoteDataIgnoringCacheData
            || self.requestCachePolicy == CCRequestReloadRemoteDataElseReturnCacheData) {
            break;
        }
        CCResponse *response = [self readCache];
        if (response) {
            //执行回调
            __weak __typeof(self) weakSelf = self;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf SuccessWithCacheResult:response];
            });
        
            if (self.requestCachePolicy == CCRequestReturnCacheDataElseReloadRemoteData) {
                //结束请求
                return;
            }
        }
        //CCRequestReturnCacheDataThenReloadRemoteData
        //CCRequestReturnCacheDataElseReloadRemoteData
        //发起网络请求
    } while (0);

    [super start];
}

/**
 *  重写网络请求的回调方法,写入缓存数据
 */
- (void)successWithResult:(id)result {
    if (self.dataCachePolicy == CCCachePolicyRawData) {
        [self.service cacheReponse:self.response ForRequest:self];
    } else if (self.dataCachePolicy == CCCachePolicyModel) {
        [self.service cacheReponse:result ForRequest:self];
    }
    [super successWithResult:result];
}

- (void)failWithError:(CCResponseError *)error {
    
    if (error.code == kCCResponseErrorCodeBusinessError) {
        //业务逻辑错误,清理缓存
        [self.service cleanCacheForRequrst:self];
    } else if (error.code == kCCResponseErrorCodeUserCancel) {
        //用户主动取消请求,不处理缓存
    } else {
        //其他错误(系统错误)
        if (self.requestCachePolicy == CCRequestReloadRemoteDataElseReturnCacheData) {
            CCResponse *response = [self readCache];
            if (response) {
                [self SuccessWithCacheResult:response];
                return;
            }
        }
    }

    [super failWithError:error];
}

#pragma mark - Tools

/**
 *  通过读取缓存数据回调
 */
- (void)SuccessWithCacheResult:(id)result {
    
    [[CCRequestDispatchCenter defaultCenter] resolveRequest:self];
    
    [super successWithResult:result];
}

/**
 *  读取缓存
 */
- (id)readCache {
    if (self.returnCachePolicy == CCReturnCacheDataByFireTime) {
        return [self.service getCacheForRequest:self];
    } else if (self.returnCachePolicy == CCReloadRevalidatingCacheData) {
        return [self.service getRevalidatingCacheForRequest:self];
    }
    return nil;
}

#pragma mark - Setter

- (void)setRequestCachePolicy:(CCRequestCachePolicy)requestCachePolicy {
    //请求发出后,不得再修改请求策略
    if (self->_status == CCRequestStatusRunning) {
        CCLogError(@"[%@ >>]Can not set request cache policy while request is running.",NSStringFromClass(self.class));
        return;
    }
    if (requestCachePolicy != _requestCachePolicy) {
        _requestCachePolicy = requestCachePolicy;
    }
}

- (void)setDataCachePolicy:(CCDataCachePolicy)dataCachePolicy {
    //元数据发起的请求,缓存策略过滤为CCCachePolicyRawData
    if (self.respSerializerType == CCResponseSerializerTypeRawData) {
        dataCachePolicy = CCCachePolicyRawData;
    }
    if (_dataCachePolicy != dataCachePolicy) {
        _dataCachePolicy = dataCachePolicy;
    }
}

- (void)setRespSerializerType:(CCResponseSerializerType)respSerializerType {
    if (_respSerializerType != respSerializerType) {
        _respSerializerType = respSerializerType;
    }
    if (respSerializerType == CCResponseSerializerTypeRawData) {
        _dataCachePolicy = CCCachePolicyRawData;
    }
}


@end
