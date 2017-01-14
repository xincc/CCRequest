//
//  CCRequest+Private.h
//  CCRequest
//
//  Created by xincc.wang on 7/28/16.
//  Copyright © 2016 xincc.wang. All rights reserved.
//

#import "CCRequest.h"

@interface CCRequest(Private)

- (id)handleSuccessParam:(id)responseObject result:(BOOL *)result;

- (id)handleFailParam:(id)responseObject error:(NSError*)error;

- (void)successWithResult:(id)result;

- (void)failWithError:(id)error;

- (void)complete;

- (void)toggleAccessoriesWillStartCallBack;

- (void)toggleAccessoriesCanceledCallBack;

- (void)toggleAccessoriesWillStopCallBack;

- (void)toggleAccessoriesDidStopCallBack;

- (void)toggleAccessoriesDidCompleteCallBack;

- (void)toggleAccessoriesWillRetryCallBack;

@end
