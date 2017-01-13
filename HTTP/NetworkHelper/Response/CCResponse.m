//
//  CCResponse.m
//  CCRequest
//
//  Created by xincc.wang on 3/11/16.
//  Copyright © 2016 xincc.wang. All rights reserved.
//

#import "CCResponse.h"
#import "CCRequestConstants.h"

@interface CCResponse ()

@property (nonatomic, strong) id responseObject;
@property (nonatomic, assign) CCResponseSerializerType respSerializerType;
@property (nonatomic, strong) NSURLSessionTask *task;

@property (nonatomic, strong) NSString *responseString;
@property (nonatomic, strong) NSObject<NSCoding> *responseJSONObject;
@property (nonatomic, strong) NSData *responseData;
@property (nonatomic, strong) NSDictionary *responseHeaders;
@property (nonatomic, strong) NSString *suggestedFilename;
@property (nonatomic, assign) NSInteger statusCode;

@end

@implementation CCResponse

- (instancetype)initWithRespType:(CCResponseSerializerType)type
                     sessionTask:(NSURLSessionTask *)task
                  responseObject:(id)responseObject {
    self = [super init];
    if (self) {
        self.respSerializerType = type;
        self.responseObject = responseObject;
        self.task = task;
    }
    return self;
}

- (NSDictionary *)responseHeaders {
    return [(NSHTTPURLResponse *)self.task.response allHeaderFields];
}

- (NSString *)suggestedFilename {
    return self.task.response.suggestedFilename;
}

- (NSInteger)statusCode {
    return [(NSHTTPURLResponse *)self.task.response statusCode];
}

- (id)responseJSONObject {
    if (!_responseJSONObject && self.responseObject) {
        switch (self.respSerializerType) {
            case CCResponseSerializerTypeJSON: {
                self.responseJSONObject = self.responseObject;
                break;
            }
            case CCResponseSerializerTypeRawData: {
                NSError *err = nil;
                self.responseJSONObject = [NSJSONSerialization JSONObjectWithData:self.responseObject options:NSJSONReadingMutableContainers error:&err];
                if (err) {
                    CCLogError(@"[%@ >>]Can not convert response data to JSONObject, Error: %@",NSStringFromClass(self.class),err);
                    self.responseJSONObject = nil;
                }
                break;
            }
        }
    }
    return _responseJSONObject;
}

- (NSData *)responseData {
    if (!_responseData && self.responseObject) {
        switch (self.respSerializerType) {
            case CCResponseSerializerTypeJSON: {
                NSError *err = nil;
                self.responseData = [NSJSONSerialization dataWithJSONObject:self.responseObject options:NSJSONWritingPrettyPrinted error:&err];
                if (err) {
                    CCLogError(@"[%@ >>]Can not convert response object to NSData, Error: %@",NSStringFromClass(self.class),err);
                    self.responseData = nil;
                }
                break;
            }
            case CCResponseSerializerTypeRawData: {
                self.responseData = self.responseObject;
                break;
            }
        }
    }
    return _responseData;
}

- (NSString *)responseString {
    if (!_responseString && self.responseData) {
        self.responseString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
    }
    return _responseString;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [[CCResponse alloc] init];
    if (self) {
        self.respSerializerType = [coder decodeIntegerForKey:NSStringFromSelector(@selector(respSerializerType))];
        self.responseString     = [coder decodeObjectForKey:NSStringFromSelector(@selector(responseString))];
        self.responseHeaders    = [coder decodeObjectForKey:NSStringFromSelector(@selector(responseHeaders))];
        self.suggestedFilename  = [coder decodeObjectForKey:NSStringFromSelector(@selector(suggestedFilename))];
        self.statusCode         = [coder decodeIntegerForKey:NSStringFromSelector(@selector(statusCode))];
        if (self.respSerializerType == CCResponseSerializerTypeJSON) {
            self.responseJSONObject = [coder decodeObjectForKey:NSStringFromSelector(@selector(responseJSONObject))];
        } else {
            self.responseData       = [coder decodeObjectForKey:NSStringFromSelector(@selector(responseData))];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.responseString forKey:NSStringFromSelector(@selector(responseString))];
    [aCoder encodeObject:self.responseHeaders forKey:NSStringFromSelector(@selector(responseHeaders))];
    [aCoder encodeObject:self.suggestedFilename forKey:NSStringFromSelector(@selector(suggestedFilename))];
    [aCoder encodeInteger:self.statusCode forKey:NSStringFromSelector(@selector(statusCode))];
    [aCoder encodeInteger:self.respSerializerType forKey:NSStringFromSelector(@selector(respSerializerType))];
    if (self.respSerializerType == CCResponseSerializerTypeJSON) {
        [aCoder encodeObject:self.responseJSONObject forKey:NSStringFromSelector(@selector(responseJSONObject))];
    } else {
        [aCoder encodeObject:self.responseData forKey:NSStringFromSelector(@selector(responseData))];
    }
}

@end
