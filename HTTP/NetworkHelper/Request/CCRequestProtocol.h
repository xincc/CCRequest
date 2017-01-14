//
//  CCRequestProtocol.h
//  CCRequest
//
//  Created by xincc.wang on 3/11/16.
//  Copyright © 2016 xincc.wang. All rights reserved.
//

#ifndef CCRequestProtocol_h
#define CCRequestProtocol_h

@class CCRequest;
@protocol AFMultipartFormData;

@protocol CCRequestDelegate <NSObject>

- (void)requestFinished:(CCRequest*)request;
- (void)requestFailed:(CCRequest*)request;

@end

@protocol CCRequestAccessory <NSObject>

@optional
- (void)requestWillStart:(CCRequest*)request;
- (void)requestCanceled:(CCRequest*)request;
- (void)requestWillRetry:(CCRequest*)request;
- (void)requestWillStop:(CCRequest*)request;
- (void)requestDidStop:(CCRequest*)request;
- (void)requestDidComplete:(CCRequest*)request;
@end

@protocol CCMultipartFormData <AFMultipartFormData>

@end

#endif /* CCRequestProtocol_h */
