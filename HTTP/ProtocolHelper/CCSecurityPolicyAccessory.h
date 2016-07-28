//
//  CCSecurityPolicyAccessory.h
//  CCRequest
//
//  Created by xincc.wang on 7/26/16.
//  Copyright © 2016 xincc.wang. All rights reserved.
//

#import <AFSecurityPolicy.h>
#import "CCRequestProtocol.h"

/**
 *  自签名证书 HTTPS 双向认证
 *
 *  自行更改:
 *      由CA签发的含有服务器公钥的数字证书
 *      由CA签发的含有客户端公钥的数字证书
 *      客户端私钥
 *  
 *  使用方法:
 *      调用CCRequest的实例方法 
 *      - (CCRequest *)appendAccessory:(id<CCRequestAccessory>)accessory;
 *      并将defaultAccessory加入Accessory队列中
 */

@interface CCSecurityPolicyAccessory : NSObject <CCRequestAccessory>

+ (CCSecurityPolicyAccessory *)defaultAccessory;

@end
