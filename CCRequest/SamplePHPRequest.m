//
//  SamplePHPRequest.m
//  CCRequest
//
//  Created by xincc.wang on 7/27/16.
//  Copyright © 2016 xincc.wang. All rights reserved.
//


#import "SamplePHPRequest.h"

@implementation SamplePHPRequest

- (CCRequest *)requestWithSuccess:(CCSuccessHandler)success failure:(CCFailureHandler)failure {
    
    if (self.requestArgument) {
        //将self.requestArgument 转成字典格式
    }
    
    self.requestUrl = @"http://nj03-vip-sandbox.nj03.baidu.com:8008/common-api/data/Superproductrecommendlist";
    self.requestMethod = CCRequestMethodPost;
    self.requestCachePolicy = CCRequestReloadRemoteDataIgnoringCacheData;

    return [super requestWithSuccess:success failure:failure];
}

- (CCConstructingBlock)constructingBodyBlock {
    
    return ^(id<CCMultipartFormData> formData) {
        
        NSMutableDictionary *reqData = [NSMutableDictionary dictionaryWithCapacity:0];
        [reqData setObject:@(1) forKey:@"pageNum"];
        [reqData setObject:@(20) forKey:@"pageSize"];
        [reqData setObject:@(1) forKey:@"type"];
        [reqData setObject:@(1) forKey:@"sort"];
        [reqData setObject:@(1) forKey:@"productType"];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
        [params setObject:@{@"clientTerminal":@"ios"} forKey:@"clientInfo"];
        [params setObject:reqData forKey:@"reqData"];
        
        NSError *err = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:params
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&err];
        if (!data || err) {return;}
        [formData appendPartWithFormData:data name:@"request"];
        
    };
}

- (id)handleSuccessParam:(id)responseObject
{
    id response = [super handleSuccessParam:responseObject];
    //model解析
    //...
    return response;
}


@end
