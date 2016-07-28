//
//  CCError.m
//  CCRequest
//
//  Created by xincc.wang on 3/11/16.
//  Copyright © 2016 xincc.wang. All rights reserved.
//

#import "CCResponseError.h"

#ifndef CCResponseErrorLocalizedStrings
#define CCResponseErrorLocalizedStrings(key) \
NSLocalizedStringFromTable(key, @"CCRequest", nil)
#endif

NSString * const kCCResponseErrorCodeDomain = @"cn.com.CCREQEST";

@interface CCResponseError ()

@property (nonatomic, strong) NSString *_localizedDescription;

@end

@implementation CCResponseError
@synthesize _localizedDescription;

- (id)initWithDomain:(NSString *)domain code:(CCResponseErrorCode)code userInfo:(NSDictionary *)dict description:(NSString *)description {
    self = [super initWithDomain:domain code:code userInfo:dict];
    if (self) {
        self._localizedDescription = description;
    }
    return self;
}

+ (id)errorWithCode:(CCResponseErrorCode)code userInfo:(NSDictionary *)userInfo {
    CCResponseError *error = [[CCResponseError alloc] initWithDomain:kCCResponseErrorCodeDomain code:code userInfo:userInfo description:[self descriptionForCode:code]];
    return error;
}

+ (NSString *)descriptionForCode:(CCResponseErrorCode)code {
    switch (code) {
        case kCCResponseErrorCodeEmptyResponse:
            return CCResponseErrorLocalizedStrings(@"empty response");
        case kCCResponseErrorCodeResponseNotJsonString:
            return CCResponseErrorLocalizedStrings(@"response is not json");
        case kCCResponseErrorCodeNoConnection:
            return CCResponseErrorLocalizedStrings(@"no connection");
        case kCCResponseErrorCodeUserCancel:
            return CCResponseErrorLocalizedStrings(@"user cancel");
        case kCCResponseErrorCodeInternalError:
            return CCResponseErrorLocalizedStrings(@"internal error");
        case kCCResponseErrorCodeBusinessError:
            return CCResponseErrorLocalizedStrings(@"business error");
        case kCCResponseErrorCodeFailRequst:
            return CCResponseErrorLocalizedStrings(@"invalid request");
        case kCCResponseErrorCodeTimeOut:
            return CCResponseErrorLocalizedStrings(@"time out");
        case kCCResponseErrorCodeInvalidResponseCode:
            return CCResponseErrorLocalizedStrings(@"invalid response");
        case kCCResponseErrorUnkowenError:
        default:
            return CCResponseErrorLocalizedStrings(@"unkown error");
    }
}

- (NSString *)localizedDescription {
    return self._localizedDescription;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\r\nDomain: %@\r\nCode: %zd\r\nLocalized: %@\r\nUserInfo: %@",self.domain,self.code,self.localizedDescription,self.userInfo];
}

@end

