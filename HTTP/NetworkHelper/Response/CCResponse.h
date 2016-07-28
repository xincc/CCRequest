//
//  CCResponse.h
//  CCRequest
//
//  Created by xincc.wang on 3/11/16.
//  Copyright © 2016 xincc.wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCRequestEnumrator.h"

@interface CCResponse : NSObject <NSCoding>

- (instancetype)initWithRespType:(CCResponseSerializerType)type
                     sessionTask:(NSURLSessionTask *)task
                  responseObject:(id)responseObject;

@property (nonatomic, strong, readonly) NSString *responseString;

@property (nonatomic, strong, readonly) NSObject<NSCoding> *responseJSONObject;

@property (nonatomic, strong, readonly) NSData *responseData;

@property (nonatomic, strong, readonly) NSDictionary *responseHeaders;

@property (nonatomic, strong, readonly) NSString *suggestedFilename;

@property (nonatomic, assign, readonly) NSInteger statusCode;

@end
