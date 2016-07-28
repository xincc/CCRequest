//
//  CCCacheCenter.h
//  CCRequest
//
//  Created by xincc.wang on 3/25/16.
//  Copyright © 2016 xincc.wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCCacheProtocol.h"
@class CCResponse;

@interface CCCacheCenter : NSObject<CCCacheProtocol>

+ (id)defultCenter;

@end
