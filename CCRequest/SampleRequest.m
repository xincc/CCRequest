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
    //model解析, 该方法将在后台线程运行, 无需额外的线程操作
    //...
    return response;
}



- (NSString *)responseMessage {
    
    //当发生服务器宕机,抛出一些乱码,可重写盖方法在这里过滤为友好的网络错误提示
    //CCRequest有默认文案,亦可获取self.response.responseJSONObject 自行过滤
    //修改默认文案请参阅 CCRequest.string
    
    return [super responseMessage];//这就用默认文案了
}

- (NSString *)responseStatusCode {
    
    //1.(或许是某个接口or后端换了一个架构)后端不按原有协议返回数据结构
    //2.换了一个项目,换了数据结构
    //...
    //需要对数据合法性做校验的时候(一般根据数据中的statuCode, 但结构不是固定的,或因人,因项目而大同小异)
    //可在此以一个接口为粒度重新适配新的数据结构
    //如果大部分接口返回数据都一致,建议创建的自己的[业务基类]重写该方法 而不必每个接口文件都单独处理

    return [super responseStatusCode];//代码示例就用super的了
}

// 若服务端有特殊的访问控制,可重写下面两个方法对应实现
// 这两个方法是HTTP Header层面做访问控制
// 当需要对url做特殊加密时 可以实现自己的Accessory
// 仿照 CCSecurityPolicyAccessory的设计 以及用法
- (NSArray*)requestAuthorizationHeaderFieldArray { return nil; }

- (NSDictionary*)requestHeaderFieldValueDictionary { return nil; }


// 需要手动拼接HTTP Body时, 重写该方法 例如:
// 1.文件上传
// 2.特殊参数拼接 (参见SamplePHPRequest.m的实现)
- (CCConstructingBlock)constructingBodyBlock { return nil; }

// 重写如下方法可监听上传/下载进度
- (CCUploadProgressBlock)resumableUploadProgressBlock { return nil; }

- (CCDownloadProgressBlock)resumableDownloadProgressBlock { return nil; }


@end
