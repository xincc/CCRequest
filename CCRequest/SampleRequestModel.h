//
//  SampleRequestModel.h
//  CCRequest
//
//  Created by xincc.wang on 7/31/16.
//  Copyright © 2016 xincc.wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SampleRequestModel : NSObject

@property (nonatomic, copy) NSString *foo;

- (NSDictionary *)dictionaryValue;

@end
