//
//  CCRequest.h
//  CCRequest
//
//  Created by xincc.wang on 3/11/16.
//  Copyright © 2016 xincc.wang. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "CCRequestConstants.h"
#import "CCRequestEnumrator.h"
#import "CCResponse.h"
#import "CCRequestProtocol.h"
#import "CCResponseError.h"
#import "CCPromise.h"

@interface CCRequest : NSObject {
    
    @protected
    CCResponseSerializerType _respSerializerType;
}

// URL
@property (nonatomic, copy) NSString *requestUrl;

// Request arguments
@property (nonatomic, strong) id requestArgument;

// Request method
@property (nonatomic, assign) CCRequestMethod requestMethod;

// Request session manager
@property (nonatomic, strong) AFHTTPSessionManager *manager;

// Request session task
@property (nonatomic, strong) NSURLSessionTask *sessionTask;

// Request delegate
@property (nonatomic, weak) id<CCRequestDelegate> delegate;

// Request timeout stamp
@property (nonatomic, assign) NSTimeInterval timeout;

// Retry times
@property (nonatomic, assign) NSInteger retryTimes;

// status
@property (nonatomic, assign, readonly) CCRequestStatus status;

/**
 *  Request serializer type.
 *  You should better use CCResponseSerializerTypeRawData
 *  for files download task such as image
 */
@property (nonatomic, assign) CCResponseSerializerType respSerializerType;

/**
 *  Response object
 *  This object is nil until get data from server succeed
 */
@property (nonatomic, strong, readonly) CCResponse *response;

/**
 *  Response error
 *  There are some default error types catched by CCRequest.
 *  You can get the object no matter what bad things happend.
 *  And you can get error info in this object.
 */
@property (nonatomic, strong, readonly) CCResponseError *error;

/**
 *  @param result the final result for this request (serialized if you
 *  implamented - (id)handleSuccessParam:(id)responseObject )
 *
 *  @param request  the request instance
 */
@property (nonatomic, copy) CCSuccessHandler successHandler;
/**
 *  @param error    the request's error
 *  @param request  the request instance
 */
@property (nonatomic, copy) CCFailureHandler failureHandler;



#pragma mark - Operate

/**
 *  Add into dispatch center and start request.
 */
- (void)start;

/**
 *  Remove the request from dispatch center and cancel it,
 *  so the request may be dealloced.
 */
- (void)stop;

/**
 *  Clear delegets, callbacks and cancel session task,
 *  but accessories still exist.
 */
- (void)cancel;

/**
 *  Request Action
 *  You can overwrite this method but call super 
 *  in every subclasses to get a better Programming Experience
 *
 *  @see samples
 *
 *  @return the request instance
 */
- (CCRequest *)requestWithSuccess:(CCSuccessHandler)success failure:(CCFailureHandler)failure;

/**
 *  Append more callback
 *  These callbacks's only have one param: the request instance
 *
 *  @return the request instance
 */
- (CCRequest *)appendCallback:(CCEventHandler)callback;


/**
 *  Append/Remove one accessory to hook the request action.
 *  Inclueding will start, will stop, did stop and complete
 *
 *  @return the request instance
 */
- (CCRequest *)appendAccessory:(id<CCRequestAccessory>)accessory;
- (CCRequest *)removeAccessory:(id<CCRequestAccessory>)accessory;



#pragma mark - Overwrite Me

/**
 *  Model serialize operate, overwrite this method if needed
 *  Success with cache data will not call this mothod.
 *  The Mothod is called in background thread.
 *
 *  @param responseObject Networking response object
 *
 *  @return Serialized model
 */
- (id)handleSuccessParam:(id)responseObject;

/**
 *  Validate current response
 *  Defaut condition is `statusCode >= 200 && statusCode <= 299`
 *
 *  Overwrite it to implement your custom validator
 *
 *  @return validate or not
 */
- (BOOL)statusCodeValidator;

/**
 *  Default is self.sessionTask.response.statusCode
 *
 *  Overwrite it in the way of an agreement knocked by you and yor server
 *
 *  @return statusCode
 */
- (NSString *)responseStatusCode;

/**
 *  Default is nil, and the final massage will be 
 *  `business error` in ../Exception/CCRequest.strings.
 *  You can also change default massages in this file.
 *
 *  Overwrite it to show a suitable message for the 
 *  request when your server is not that friendly
 *
 *  @return the massage
 */
- (NSString *)responseMessage;

/**
 *  Overwrite it if your server api need server username and password
 *  Inser username at first index and password in the last
 *  Default is nil
 *
 *  @return Authorization fields
 */
- (NSArray*)requestAuthorizationHeaderFieldArray;

/**
 *  Overwrite it if api need add custom value to HTTPHeaderField
 *
 *  @return HTTP Header fields
 */
- (NSDictionary*)requestHeaderFieldValueDictionary;

/**
 *  Overwrite it to construct your HTTP Body by your self
 *
 *  @return CCConstructingBlock
 */
- (CCConstructingBlock)constructingBodyBlock;

/**
 *  Overwrite it to catch progress of upload request
 *
 *  @return CCUploadProgressBlock
 */
- (CCUploadProgressBlock)resumableUploadProgressBlock;

/**
 *  Overwrite it to catch progress of download request
 *
 *  @return CCDownloadProgressBlock
 */
- (CCDownloadProgressBlock)resumableDownloadProgressBlock;


/**
 *  Overwrite it to generate the reachability level
 *  @default CCReachabilityLevelLocal
 *  @see CCReachabilityLevel
 *
 *  @return CCReachabilityLevel
 */
- (CCReachabilityLevel)getReachabilityLevel;

@end


@interface CCRequest (Promise)

/**
 *  Generate the request to act as Promise
 *  @see API in CCPromise
 *
 *  @return the promise object
 */
- (CCPromise *)promise;
+ (CCPromise *)promise;

/**
 *  Set request argument, use this mthod replace setRequestArgument: 
 *  and you can get a better Programming Experience
 *
 *  @param argument argument
 *
 *  @return the request instance
 */
- (CCRequest *)bindRequestArgument:(id)argument;

@end
