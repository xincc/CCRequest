//
//  SampleRequestModel.m
//  CCRequest
//
//  Created by xincc.wang on 7/31/16.
//  Copyright © 2016 xincc.wang. All rights reserved.
//

#import "SampleRequestModel.h"

@implementation SampleRequestModel

- (NSDictionary *)dictionaryValue {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:self.foo?:@"" forKey:@"foo"];
    return params;
}

@end
