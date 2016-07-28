//
//  CCRequestConstants.h
//  CCRequest
//
//  Created by xincc.wang on 3/11/16.
//  Copyright © 2016 xincc.wang. All rights reserved.
//

#ifdef LOG_LEVEL_DEF
//可选载入CocoaLumberjack
#import <CocoaLumberjack/CocoaLumberjack.h>
#endif

#import <Foundation/Foundation.h>

@class CCRequest;
@class CCResponse;
@class CCResponseError;
@protocol CCMultipartFormData;
typedef void (^CCEventHandler)(CCRequest *request);
typedef void (^CCSuccessHandler)(id result, CCRequest *request);
typedef void (^CCFailureHandler)(CCResponseError *error, CCRequest *request);
typedef void (^CCConstructingBlock)(id<CCMultipartFormData> formData);
typedef void (^CCDownloadProgressBlock)(NSProgress *downloadProgress);
typedef void (^CCUploadProgressBlock)(NSProgress *uploadProgress);

static int const ddLogLevel = 1111;

FOUNDATION_EXTERN void CCLog(NSString* format, ...) NS_FORMAT_FUNCTION(1, 2);


void blockCleanUp(__strong void(^*block)(void));

#ifndef onExit
#define onExit\
    __strong void(^block)(void) __attribute__((cleanup(blockCleanUp), unused)) = ^
#endif

#ifdef LOG_LEVEL_DEF

#define CCLogInfo    DDLogInfo
#define CCLogError   DDLogError
#define CCLogWarn    DDLogWarn
#define CCLogDebug   DDLogDebug
#define CCLogVerbose DDLogVerbose

#else

#define CCLogInfo    CCLog
#define CCLogError   CCLog
#define CCLogWarn    CCLog
#define CCLogDebug   CCLog
#define CCLogVerbose CCLog

#endif

#ifndef _S
#define _S(str,...) [NSString stringWithFormat:str,##__VA_ARGS__]
#endif

#define HandlerDeclare Success:(CCSuccessHandler)success failure:(CCFailureHandler)failure

#define kCCCacheName @"cn_com_cache_ccrequest"