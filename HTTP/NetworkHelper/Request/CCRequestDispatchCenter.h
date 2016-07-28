//
//  CCRequestDispatchCenter.h
//  CCRequest
//
//  Created by xincc.wang on 3/11/16.
//  Copyright © 2016 xincc.wang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CCRequest;

@interface CCRequestDispatchCenter : NSObject

+ (CCRequestDispatchCenter *)defaultCenter;

- (void)dispatchRequest:(CCRequest *)request;

- (void)cancelRequest:(CCRequest *)request;
- (void)cancelAllRequests;

- (void)promiseRequest:(CCRequest *)request;
- (void)resolveRequest:(CCRequest *)request;

@end
