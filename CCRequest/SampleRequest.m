//
//  SampleRequest.m
//  CCRequest
//
//  Created by xincc.wang on 3/30/16.
//  Copyright © 2016 xincc.wang. All rights reserved.
//

#import "SampleRequest.h"
#import "CCSecurityPolicyAccessory.h"

@implementation SampleRequest

- (CCRequest *)requestWithSuccess:(CCSuccessHandler)success failure:(CCFailureHandler)failure {
    
    if (self.requestArgument) {
        //将self.requestArgument 转成字典格式
    }
    self.requestUrl = @"http://www.chojer.com/sys.php/api/hot_search";
    self.requestMethod = CCRequestMethodPost;
    self.requestCachePolicy = CCRequestReturnCacheDataElseReloadRemoteData;
    
    //HTTPS就是一行代码这么简单
    [self appendAccessory:[CCSecurityPolicyAccessory defaultAccessory]];
    
    return [super requestWithSuccess:success failure:failure];
}

- (id)handleSuccessParam:(id)responseObject
{
    id response = [super handleSuccessParam:responseObject];
    //模型解析 不解释了
    //...
    return response;
}

- (NSString *)responseMessage {
    
    //例如发生服务器宕机,抛出一些乱码,在这里干掉他们
//    self.response.responseJSONObject...
    
    return [super responseMessage];//这就用默认的了,默认文案可以自己在CCResponseError.string文件里面改
}

- (NSString *)responseStatusCode {
    //你们后端要特殊处理每一个接口的校验字段? 在这里处理不就可以了
//    return self.response.responseJSONObject[@"statusCode"];
    
    return [super responseStatusCode];//代码示例就用super的了
}

// 这几个方法假设你们server有特殊的访问控制 对应实现就行了
- (NSArray*)requestAuthorizationHeaderFieldArray { return nil; }

- (NSDictionary*)requestHeaderFieldValueDictionary { return nil; }


//这几个方法是上传下载相关的  看API名字就知道什么鬼了
- (CCConstructingBlock)constructingBodyBlock { return nil; }

- (CCUploadProgressBlock)resumableUploadProgressBlock { return nil; }

- (CCDownloadProgressBlock)resumableDownloadProgressBlock { return nil; }


@end
