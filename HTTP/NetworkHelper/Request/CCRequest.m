//
//  CCRequest.m
//  CCRequest
//
//  Created by xincc.wang on 3/11/16.
//  Copyright © 2016 xincc.wang. All rights reserved.
//

#import "CCRequest.h"
#import "CCRequestDispatchCenter.h"
#import "CCResponseError.h"
#import "CCRequest+Private.h"

@interface CCRequest () {
    CCPromise *_promise;
}

@property (nonatomic, assign) CCRequestStatus status;

@property (nonatomic, strong) CCResponse *response;

@property (nonatomic, copy) NSHashTable *callbacks;

@property (nonatomic, strong) NSHashTable *accesoris;

@property (nonatomic, strong) CCResponseError *error;

@end

@implementation CCRequest

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        self.accesoris = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
        self.callbacks = [NSHashTable hashTableWithOptions:NSHashTableCopyIn];
        self.timeout = 60.f;
        self.respSerializerType = CCResponseSerializerTypeJSON;
    }
    return self;
}

#pragma mark - Action

- (void)start {
    [[CCRequestDispatchCenter defaultCenter] dispatchRequest:self];
    self.status = CCRequestStatusRunning;
}

- (void)stop {
    [self toggleAccessoriesWillStopCallBack];
    [[CCRequestDispatchCenter defaultCenter] cancelRequest:self];
    self.status = CCRequestStatusStop;
    [self toggleAccessoriesDidStopCallBack];
}

- (void)cancel {
    [self.sessionTask cancel];
    self.successHandler = nil;
    self.failureHandler = nil;
    self.delegate = nil;
    self.status = CCRequestStatusCanceled;
    [self toggleAccessoriesCanceledCallBack];
}

- (CCRequest *)appendAccessory:(id<CCRequestAccessory>)accessory {
    [self.accesoris addObject:accessory];
    return self;
}
- (CCRequest *)removeAccessory:(id<CCRequestAccessory>)accessory {
    [self.accesoris removeObject:accessory];
    return self;
}

- (CCRequest *)requestWithSuccess:(CCSuccessHandler)success failure:(CCFailureHandler)failure {
    self.successHandler = success;
    self.failureHandler = failure;
    [self start];
    return self;
}

- (CCRequest *)appendCallback:(CCEventHandler)callback {
    [self.callbacks addObject:callback];
    return self;
}

#pragma mark - Overwrite Me

- (id)handleSuccessParam:(id)responseObject {
    return responseObject;
}

- (CCReachabilityLevel)getReachabilityLevel {
    return CCReachabilityLevelLocal;
}

//Validator
- (NSString *)responseStatusCode {
    return _S(@"%zd",self.response.statusCode);
}

- (NSString *)responseMessage {
    //该方法需要子类视具体接口业务而定
    return nil;
}

- (BOOL)statusCodeValidator {
    //[!] 当HTTP请求方法为HEAD时,最好不要重写此逻辑
    NSInteger statusCode = [[self responseStatusCode] integerValue];
    return statusCode >= 200 && statusCode <= 299;
}


- (NSArray*)requestAuthorizationHeaderFieldArray { return nil; }

- (NSDictionary*)requestHeaderFieldValueDictionary { return nil; }

- (CCConstructingBlock)constructingBodyBlock { return nil; }

- (CCUploadProgressBlock)resumableUploadProgressBlock { return nil; }

- (CCDownloadProgressBlock)resumableDownloadProgressBlock { return nil; }

@end


@implementation CCRequest (Promise)

- (CCPromise *)promise {
    
    if (!_promise) {
        _promise = ({
            CCPromise *promise = [CCPromise promise];
            
            __weak __typeof(self) weakSelf = self;
            promise.run = ^(){
                __strong __typeof(weakSelf) self = weakSelf;
                [self requestWithSuccess:NULL failure:NULL];
            };
            
            promise.done = ^() {
                __strong __typeof(weakSelf) self = weakSelf;
                if (self.status == CCRequestStatusRunning) {
                    [self stop];
                }
            };
            
            //[!]若不持有一个Request的引用
            //[!]将产生空指针中断promise链
            
            [[CCRequestDispatchCenter defaultCenter] promiseRequest:self];
            
            promise;
        });
    }
    return _promise;
}

- (CCRequest *)bindRequestArgument:(id)argument {
    self.requestArgument = argument;
    return self;
}

@end


@implementation CCRequest(Private)

- (void)complete {
    if (_status != CCRequestStatusRunning) {
        return;
    }
    for (CCEventHandler handler in _callbacks) {
        handler(self);
    }
    [self toggleAccessoriesDidCompleteCallBack];
}

- (id)handleSuccessParam:(id)responseObject result:(BOOL *)result {
    
    //刷新Response对象
    if (self.response) {
        self.response = nil;
    }
    self.response = [[CCResponse alloc] initWithRespType:self.respSerializerType
                                             sessionTask:self.sessionTask
                                          responseObject:responseObject];
    
    //状态码合法性验证
    *result = [self statusCodeValidator];
    
    return [self handleSuccessParam:responseObject];
}

- (id)handleFailParam:(id)responseObject error:(NSError*)error {
    
    CCResponseError *handleError = nil;
    
    if (responseObject) {
        
        /// 服务端业务/系统错误
        
        NSString *desp = [self responseMessage]?:NSLocalizedStringFromTable(@"business error", @"CCResponseError", nil);
        handleError = [[CCResponseError alloc] initWithDomain:kCCResponseErrorCodeDomain
                                                         code:kCCResponseErrorCodeBusinessError
                                                     userInfo:nil
                                                  description:desp];
    } else {
        
        /// NA端系统请求失败
        /// 默认未知错误
        
        NSInteger code = kCCResponseErrorUnkowenError;
        
        if (error) {
            
            code = error.code;
            
            if (code == NSURLErrorCancelled) {
                //用户主动cancel请求
                code = kCCResponseErrorCodeUserCancel;
            } else if (code == NSURLErrorNotConnectedToInternet){
                //网络连接失败
                code = kCCResponseErrorCodeNoConnection;
            } else if (code == NSURLErrorTimedOut) {
                //请求超时
                code = kCCResponseErrorCodeTimeOut;
            }
        }
        
        NSDictionary *userInfo = self.respSerializerType==CCResponseSerializerTypeJSON?responseObject:nil;
        handleError = [CCResponseError errorWithCode:code userInfo:userInfo];
    }
    
    return self.error = handleError;
}

- (void)successWithResult:(id)result{
    [self toggleAccessoriesWillStopCallBack];
    if (self.successHandler) {
        @autoreleasepool {
            self.successHandler(result, self);
        }
    }
    if ([self.delegate respondsToSelector:@selector(requestFinished:)]) {
        @autoreleasepool {
            [self.delegate requestFinished:self];
        }
    }
    
    //promise
    if (_promise) {
        [_promise fulfill:result];
    }
    
    [self complete];
    [self toggleAccessoriesDidStopCallBack];
}

- (void)failWithError:(id)error {
    [self toggleAccessoriesWillStopCallBack];
    if (self.failureHandler) {
        @autoreleasepool {
            self.failureHandler(error, self);
        }
    }
    if ([self.delegate respondsToSelector:@selector(requestFinished:)]) {
        @autoreleasepool {
            [self.delegate requestFinished:self];
        }
    }
    
    //promise
    if (_promise) {
        [_promise reject:error];
    }
    [self complete];
    [self toggleAccessoriesDidStopCallBack];
}

- (void)toggleAccessoriesWillStartCallBack {
    for (id<CCRequestAccessory> accessory in _accesoris) {
        if ([accessory respondsToSelector:@selector(requestWillStart:)]) {
            [accessory requestWillStart:self];
        }
    }
}
- (void)toggleAccessoriesCanceledCallBack {
    for (id<CCRequestAccessory> accesory in _accesoris) {
        if ([accesory respondsToSelector:@selector(requestCanceled:)]) {
            [accesory requestCanceled:self];
        }
    }
}
- (void)toggleAccessoriesWillStopCallBack {
    for (id<CCRequestAccessory> accesory in _accesoris) {
        if ([accesory respondsToSelector:@selector(requestWillStop:)]) {
            [accesory requestWillStop:self];
        }
    }
}
- (void)toggleAccessoriesDidStopCallBack {
    for (id<CCRequestAccessory> accessory in _accesoris) {
        if ([accessory respondsToSelector:@selector(requestDidStop:)]) {
            [accessory requestDidStop:self];
        }
    }
}
- (void)toggleAccessoriesDidCompleteCallBack {
    for (id<CCRequestAccessory> accessory in _accesoris) {
        if ([accessory respondsToSelector:@selector(requestDidComplete:)]) {
            [accessory requestDidComplete:self];
        }
    }
}

@end


