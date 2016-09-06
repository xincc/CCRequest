//
//  CCRequestDispatchCenter.m
//  CCRequest
//
//  Created by xincc.wang on 3/11/16.
//  Copyright © 2016 xincc.wang. All rights reserved.
//

#import "CCRequestDispatchCenter.h"
#import "CCRequest.h"
#import "CCRequestConstants.h"
#import "CCResponseError.h"
#import <AFNetworking/AFNetworking.h>
#import <pthread.h>
#import "CCRequest+Private.h"

@interface CCRequestDispatchCenter () {
    pthread_mutex_t _lock;
    NSMutableDictionary *_requestsHashTable;
}

@end

@implementation CCRequestDispatchCenter

+ (CCRequestDispatchCenter *)defaultCenter {
    static id defaultCenter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultCenter = [[self alloc] init];
    });
    return defaultCenter;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        pthread_mutex_init(&_lock, NULL);
        _requestsHashTable = [NSMutableDictionary dictionary];
        //在程序退出到后台或者即将结束的时候取消请求
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelAllRequests) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelAllRequests) name:UIApplicationWillTerminateNotification object:nil];
    }
    return self;
}


#pragma mark - Dispatch

- (AFHTTPSessionManager *)configManager:(CCRequest *)request {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    request.manager = manager;

    switch (request.respSerializerType) {
        case CCResponseSerializerTypeRawData: {
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
        }
        case CCResponseSerializerTypeJSON: {
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            break;
        }
    }
    
    NSMutableSet* acceptableContentTypeSet = [NSMutableSet setWithSet:manager.responseSerializer.acceptableContentTypes];
    [acceptableContentTypeSet addObject:@"text/html"];
    [acceptableContentTypeSet addObject:@"text/plain"];
    [acceptableContentTypeSet addObject:@"image/*;q=0.8"];
    [manager.responseSerializer setAcceptableContentTypes:acceptableContentTypeSet];
    
    manager.operationQueue.maxConcurrentOperationCount = 4;
    manager.requestSerializer.timeoutInterval = request.timeout;
    manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    // if api need server username and password
    NSArray* authorizationHeaderFieldArray = [request requestAuthorizationHeaderFieldArray];
    if (authorizationHeaderFieldArray != nil) {
        [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:(NSString*)authorizationHeaderFieldArray.firstObject password:(NSString*)authorizationHeaderFieldArray.lastObject];
    }
    
    // if api need add custom value to HTTPHeaderField
    NSDictionary* headerFieldValueDictionary = [request requestHeaderFieldValueDictionary];
    if (headerFieldValueDictionary != nil) {
        for (id httpHeaderField in headerFieldValueDictionary.allKeys) {
            id value = headerFieldValueDictionary[httpHeaderField];
            if ([httpHeaderField isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]]) {
                [manager.requestSerializer setValue:(NSString*)value forHTTPHeaderField:(NSString*)httpHeaderField];
            }
            else {
                CCLogError(@"[%@ >>]Error, class of key/value in headerFieldValueDictionary should be NSString.", NSStringFromClass(self.class));
            }
        }
    }
    return manager;
}

- (void)dispatchRequest:(CCRequest *)request {
    
    NSMutableString *str = [NSMutableString stringWithFormat:@"\r\n%@ <%p>: request start-%@",[[request class] description],request,request.requestUrl];
    [str appendFormat:@"\r\n*********************************************\r\n"];
    [str appendFormat:@"params:%@",request.requestArgument];
    [str appendFormat:@"\r\n*********************************************\r\n"];
    CCLogInfo(@"%@",str);
    
    AFHTTPSessionManager *manager = [self configManager:request];
    
    [request toggleAccessoriesWillStartCallBack];

    __weak __typeof(self) weakSelf = self;
    
    switch (request.requestMethod) {
        case CCRequestMethodGet: {
            request.sessionTask = [manager GET:request.requestUrl parameters:request.requestArgument progress:request.resumableDownloadProgressBlock success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                __strong __typeof(weakSelf) self = weakSelf;
                [self handleRequestResult:task responseObject:responseObject error:nil];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                __strong __typeof(weakSelf) self = weakSelf;
                [self handleRequestResult:task responseObject:nil error:error];
            }];
            break;
        }
        case CCRequestMethodPost: {
            if (!request.resumableUploadProgressBlock) {
                request.sessionTask = [manager POST:request.requestUrl parameters:request.requestArgument progress:request.resumableUploadProgressBlock success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    __strong __typeof(weakSelf) self = weakSelf;
                    [self handleRequestResult:task responseObject:responseObject error:nil];
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    __strong __typeof(weakSelf) self = weakSelf;
                    [self handleRequestResult:task responseObject:nil error:error];
                }];
            } else {
                request.sessionTask = [manager POST:request.requestUrl parameters:request.requestArgument constructingBodyWithBlock:request.constructingBodyBlock progress:request.resumableUploadProgressBlock success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    __strong __typeof(weakSelf) self = weakSelf;
                    [self handleRequestResult:task responseObject:responseObject error:nil];
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    __strong __typeof(weakSelf) self = weakSelf;
                    [self handleRequestResult:task responseObject:nil error:error];
                }];
            }
            break;
        }
        case CCRequestMethodHead: {
            request.sessionTask = [manager HEAD:request.requestUrl parameters:request.requestArgument success:^(NSURLSessionDataTask * _Nonnull task) {
                __strong __typeof(weakSelf) self = weakSelf;
                [self handleRequestResult:task responseObject:nil error:nil];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                __strong __typeof(weakSelf) self = weakSelf;
                [self handleRequestResult:task responseObject:nil error:error];
            }];
            break;
        }
        case CCRequestMethodPut: {
            request.sessionTask = [manager PUT:request.requestUrl parameters:request.requestArgument success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                __strong __typeof(weakSelf) self = weakSelf;
                [self handleRequestResult:task responseObject:responseObject error:nil];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                __strong __typeof(weakSelf) self = weakSelf;
                [self handleRequestResult:task responseObject:nil error:error];
            }];
            break;
        }
        case CCRequestMethodDelete: {
            request.sessionTask = [manager DELETE:request.requestUrl parameters:request.requestArgument success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                __strong __typeof(weakSelf) self = weakSelf;
                [self handleRequestResult:task responseObject:responseObject error:nil];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                __strong __typeof(weakSelf) self = weakSelf;
                [self handleRequestResult:task responseObject:nil error:error];
            }];
            break;
        }
        case CCRequestMethodPatch: {
            request.sessionTask = [manager PATCH:request.requestUrl parameters:request.requestArgument success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                __strong __typeof(weakSelf) self = weakSelf;
                [self handleRequestResult:task responseObject:responseObject error:nil];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                __strong __typeof(weakSelf) self = weakSelf;
                [self handleRequestResult:task responseObject:nil error:error];
            }];
            break;
        }
        default: {
            CCResponseError *error = [CCResponseError errorWithCode:kCCResponseErrorCodeFailRequst userInfo:nil];
            [self failWithParam:[request handleFailParam:nil error:error] RParam:request];
            [self resolveRequest:request];
            return;
        }
    }
    
    [self addRequest:request];
}

- (void)handleRequestResult:(NSURLSessionTask *)task responseObject:(id)responseObject error:(NSError *)error {
    
    NSString *key = [self requestTaskHashKey:task];
    CCRequest *request = _requestsHashTable[key];
    
    if (!request) {
        CCLogError(@"[%@ >>]Can not get reqest in hash table", NSStringFromClass(self.class));
        return;
    }
    
    if (error) {
        //failed
        [self failWithParam:[request handleFailParam:nil error:error] RParam:request];
    } else {
        //succeed
        __weak __typeof(self) weakSelf = self;
        __block CCRequest *b_request = request;
        if ([(NSHTTPURLResponse *)task.response statusCode] > 0) {
            if (responseObject || request.requestMethod == CCRequestMethodHead) {
                //Response object is not null or HTTP method is HEAD
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
                    BOOL success = YES;
                    id result = [b_request handleSuccessParam:responseObject result:&success];
                    if (success) {
                        __strong __typeof(weakSelf) self = weakSelf;
                        [self SuccessWithlParam:result RParam:b_request];
                    } else {
                        __strong __typeof(weakSelf) self = weakSelf;
                        [self failWithParam:[b_request handleFailParam:result error:nil] RParam:b_request];
                    }
                });
            } else {
                //empty response object
                CCResponseError *error = [CCResponseError errorWithCode:kCCResponseErrorCodeEmptyResponse userInfo:nil];
                [self failWithParam:[request handleFailParam:nil error:error] RParam:request];
            }
        } else {
            //invalid status code
            //@see http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
            CCResponseError *error = [CCResponseError errorWithCode:kCCResponseErrorCodeInvalidResponseCode userInfo:nil];
            [self failWithParam:[request handleFailParam:responseObject error:error] RParam:request];
        }
    }
}

//dispatch

- (void)failWithParam:(id)lParam RParam:(CCRequest *)rParam {
    
    CCLogInfo(@"\r\n%@ failure-%@<%p> \r\nparam:\r\n*********************************************\r\nresponse:%@\r\nerror:%@\r\n*********************************************\r\n",
              [[rParam class] description],
              rParam.requestUrl,
              rParam,rParam.
              sessionTask.response,
              lParam);
    
    __block CCRequest *b_request = rParam;
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^(){
        __strong __typeof(weakSelf) self = weakSelf;
        [b_request failWithError:lParam];
        [self removeRequest:b_request];
    });
}

- (void)SuccessWithlParam:(id)lParam RParam:(CCRequest *)rParam {
    
    NSMutableString *str_response = [NSMutableString stringWithFormat:@"\r\n"];
    [str_response appendFormat:@"%@ sucess-<%p> resposnse %zd -%@",[[rParam class] description],rParam,[(NSHTTPURLResponse*)rParam.sessionTask.response statusCode],rParam.sessionTask.currentRequest.URL.absoluteString];
    
    [str_response appendString:@"\r\n*********************************************\r\n"];
    [str_response appendFormat:@"response:\r\n%@\r\n",lParam];
    [str_response appendString:@"\r\n*********************************************\r\n"];
    
    CCLogInfo(@"%@",str_response);
    
    __block CCRequest *b_request = rParam;
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^(){
        __strong __typeof(weakSelf) self = weakSelf;
        [b_request successWithResult:lParam];
        [self removeRequest:b_request];
    });
}

#pragma mark - Hash

- (void)addRequest:(CCRequest *)request {
    
    [self resolveRequest:request];

    if (request.sessionTask != nil) {
        NSString *key = [self requestTaskHashKey:request.sessionTask];
        if (key.length) {
            pthread_mutex_lock(&_lock);
            _requestsHashTable[key] = request;
            pthread_mutex_unlock(&_lock);
        }
    }
}

- (void)removeRequest:(CCRequest *)request {
    [self removeRequest:request hash:nil];
}

- (void)removeRequest:(CCRequest *)request hash:(NSString *)hash {
    //Remove
    NSString *key = [self requestTaskHashKey:request.sessionTask];
    if (hash) {
        key = hash;
    }
    if (key.length) {
        pthread_mutex_lock(&_lock);
        [_requestsHashTable removeObjectForKey:key];
        pthread_mutex_unlock(&_lock);
    }
    
    if (!hash) {
        CCLogInfo(@"[%@ >>]Request queue size = %lu", NSStringFromClass(self.class), (unsigned long)[_requestsHashTable count]);
    }
}

- (void)promiseRequest:(CCRequest *)request {
    
    NSString *key = [self requestHashKey:request];
    if (key.length) {
        pthread_mutex_lock(&_lock);
        _requestsHashTable[key] = request;
        pthread_mutex_unlock(&_lock);
    }
}

- (void)resolveRequest:(CCRequest *)request {
    NSString *hash = [self requestHashKey:request];
    [self removeRequest:request hash:hash];
}

- (NSString*)requestTaskHashKey:(NSURLSessionTask*)task {
    return _S(@"%lu", (unsigned long)[task hash]);
}

- (NSString*)requestHashKey:(CCRequest *)request {
    return _S(@"%lu", (unsigned long)[request hash]);
}


#pragma mark - Cancel

- (void)cancelRequest:(CCRequest *)request {
    [request cancel];
    [self removeRequest:request];
}

- (void)cancelAllRequests {
    NSDictionary *copyHash = [_requestsHashTable copy];
    for (NSString *key in copyHash.allKeys) {
        CCRequest *reqest = copyHash[key];
        [reqest stop];
    }
}


@end
