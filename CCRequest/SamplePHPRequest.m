//
//  SamplePHPRequest.m
//  CCRequest
//
//  Created by xincc.wang on 7/27/16.
//  Copyright © 2016 xincc.wang. All rights reserved.
//


#import "SamplePHPRequest.h"
#import "SampleRequestModel.h"

@implementation SamplePHPRequest

- (CCRequest *)requestWithSuccess:(CCSuccessHandler)success failure:(CCFailureHandler)failure {
    
    if (self.requestArgument) {
        
        SampleRequestModel *model = self.requestArgument;
        if (![model isKindOfClass:SampleRequestModel.class]) {
            //若参数拼接发生错误,可在此抛出异常,并阻止发起请求.
            CCResponseError *error = [CCResponseError errorWithCode:kCCResponseErrorCodeBusinessError
                                                           userInfo:nil];
            if (failure) {
                failure(error, self);
            }
            return self;
        }
        
        //将self.requestArgument 转成字典格式
        self.requestArgument = model.dictionaryValue;
    }
    
    self.requestUrl = @"http://www.chojer.com/sys.php/api/hot_search";
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
    //model解析, 该方法将在后台线程运行, 无需额外的线程操作
    //...
    return response;
}


@end
