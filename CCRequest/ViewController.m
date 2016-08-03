//
//  ViewController.m
//  CCRequest
//
//  Created by xincc.wang on 3/11/16.
//  Copyright © 2016 xincc.wang. All rights reserved.
//

#import "ViewController.h"
#import "Samples.h"
#import "SampleRequestModel.h"

@interface ViewController () <CCRequestAccessory>

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //这是一个网络层解决方案, 该Demo不提供UI
    //默认是测试next的catch功能(任务链上将会发生异常)
    //若希望看到正常的任务链 请将 SampleRequestModel.m 文件中的requestUrl设置修改为将会成功的case
    
//    [self testNext];
    
//    [self testThen];
    [self testAll];
//    [self testNormal];
    
}

- (void)testThen
{
    //开始第一个异步任务
    SamplePHPRequest.new.promise.then(^id(id data){
        //获取第一个数据的返回结果
        //开始第二个异步任务
        return SamplePHPRequest.new.promise;
        
    },^id(CCResponseError *reason){
        
        //捕获第一个任务的异常
        //即使发生异常也会开始下一个任务, 并且向下一个任务(第三个)传入 reason
        return reason;
        
    }).then(^id(id bar){
        
        //获取上一个任务的返回结果
        //开始第三个任务(后续没有Promise任务, 将不会处理这个异步任务的返回数据)
        
        SampleRequestModel *model = [SampleRequestModel new];
        model.foo = bar;
        return [[[SamplePHPRequest new] bindRequestArgument:model] promise];
        
    },NULL);
}

- (void)testNext
{
    SamplePHPRequest.new.promise.next(^id(id data) {
        
        //处理第一个请求的response 并将处理结果传入下一个promise
        CCLogInfo(@"%@",data);
        return data;
        
    }).next(^id(id data){
        
        //获取上一个promise的处理结果
        //开始下一个网络请求
        
        return SamplePHPRequest.new.promise;
        
    }).next(^id(id data) {
        
        //处理第二个请求的response
        
        CCLogInfo(@"任务链完成");
        return data;
        
    }).catch(^(CCResponseError *reason) {
        
        //捕获整个promis链上的异常(发生一个异常就会结束promise任务链)
        
        CCLogError(@"任务链失败: %@",reason);
    });
}

- (void)testAll
{
    [CCPromise all:@[SampleRequest.new.promise, SamplePHPRequest.new.promise]].then(^id(id data) {
        
        //任务蔟都完成后调用逻辑
        CCLogInfo(@"获得数据: %@",data);
        return CCPromise.fulfilled;
        
    }, ^id(CCResponseError *reason) {
        
        //捕获整个任务簇的异常(发生一个异常就会结束所有任务)
        CCLogError(@"捕获异常: %@",reason);
        return CCPromise.rejected;
        
    });
}

- (void)testNormal
{
    SamplePHPRequest *request = [SamplePHPRequest new];
    [[request requestWithSuccess:^(id result, CCRequest *request) {
        
    } failure:^(CCResponseError *error, CCRequest *request) {
        CCLogInfo(@"Cancel后将不会调用回调函数");
    }] appendAccessory:self];
    
    CCLogInfo(@"start");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [request cancel];
    });
    
    /**
     
     2016-07-27 21:30:23.739 CCRequest[13574:585998]
     SamplePHPRequest <0x7ffdbad7cb10>: request start-http://nj03-vip-sandbox.nj03.baidu.com:8008/common-api/data/Superproductrecommendlist
     *********************************************
     params:(null)
     *********************************************
     2016-07-27 21:30:23.747 CCRequest[13574:585998] start
     2016-07-27 21:30:23.857 CCRequest[13574:585998]
     SamplePHPRequest failure-http://nj03-vip-sandbox.nj03.baidu.com:8008/common-api/data/Superproductrecommendlist<0x7ffdbad7cb10>
     param:
     *********************************************
     response:(null)
     error:
     Domain: cn.com.CCREQEST
     Code: -995
     Localized: 取消请求
     UserInfo: {
     }
     *********************************************
     2016-07-27 21:30:23.858 CCRequest[13574:585998] [CCRequestDispatchCenter >>]Request queue size = 0
    
     */
}

@end
