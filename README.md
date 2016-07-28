# CCRequest
一个不用和后端干架的HTTP(S)网络库,基于AFNetworking 3.0

## Features
* Promise
* Cache
* HTTPS

## Installation 
* 将工程中的HTTP文件夹拖入工程
* 在你的Pod文件中加入AFNetworking和YYCache(YYCache是默认的缓存库,可以遵循CCCacheProtocol协议,根据实际使用场景,无缝替换为原有的缓存库)

## Usage

先看几个用Promise发起请求的姿势

#### Promise.then

```objc
//开始第一个异步任务
SamplePHPRequest.new.promise.then(^id(id data){
    //获取第一个数据的返回结果
    //开始第二个异步任务
    return SamplePHPRequest.new.promise;
    
},^id(CCResponseError *reason){
    
    //捕获第一个任务的异常
    //即使发生异常也会开始下一个任务, 并且向下一个任务(第三个)传入 reason
    return reason;
    
}).then(^id(id data){
    
    //获取上一个任务的返回结果
    //开始第三个任务(后续没有Promise任务, 将不会处理这个异步任务的返回数据)
    return [[[SamplePHPRequest new] bindRequestArgument:nil] promise];
    
},NULL);
```

#### Promise.next
```objc
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
```

####Promise.all
```objc
[CCPromise all:@[SampleRequest.new.promise, SamplePHPRequest.new.promise]].then(^id(id data) {
    
    //任务蔟都完成后调用逻辑
    CCLogInfo(@"获得数据: %@",data);
    return CCPromise.fulfilled;
    
}, ^id(CCResponseError *reason) {
    
    //捕获整个任务簇的异常(发生一个异常就会结束所有任务)
    CCLogError(@"捕获异常: %@",reason);
    return CCPromise.rejected;
    
});
```

当然也可以用常规方式发起请求
####常规方式
```objc
SamplePHPRequest *request = [SamplePHPRequest new];
[[request requestWithSuccess:^(id result, CCRequest *request) {
    
} failure:^(CCResponseError *error, CCRequest *request) {
    CCLogInfo(@"Cancel后将不会调用回调函数");
}] appendAccessory:self];
```

####支持的Cache方案
```objc
// 网络请求策略:

typedef NS_ENUM(NSUInteger, CCRequestCachePolicy) {
    
    // 永远忽略缓存,仅读远程数据
    CCRequestReloadRemoteDataIgnoringCacheData,
    
    // 优先先读取缓存,若读取成功,不再发起请求,反之读远程数据
    CCRequestReturnCacheDataElseReloadRemoteData,
    
    // 优先先读取缓存,若读取成功,先执行回调逻辑,再读远程数据,反之读远程数据
    CCRequestReturnCacheDataThenReloadRemoteData,
    
    // 优先读取远程数据,若读取失败,读取缓存
    CCRequestReloadRemoteDataElseReturnCacheData,
};

// 缓存读取策略:

typedef NS_ENUM(NSUInteger, CCReturnCachePolicy) {
    
    // 按设置的缓存过期时间读取
    CCReturnCacheDataByFireTime,
    
    // 若有缓存,强制重新激活缓存后读取
    CCReloadRevalidatingCacheData
};

// 数据缓存策略:

typedef NS_ENUM(NSUInteger, CCDataCachePolicy) {
    
    // 缓存解析后的模型(如果使用默认的缓存服务,要求模型层实现NSCoding协议)
    CCCachePolicyModel,
    
    // 缓存JSON对象或者元数据,取决于CCResponseSerializerType
    CCCachePolicyRawData,
};

```

####其他特性
* 支持自定义请求合法性验证
* 支持自定义网络访问控制书写
* 支持应对五花八门的后端框架的方案


####补刀的时候到了

```objc
详细设计请参阅CCRequest类
```

## TODO

* Mock数据方案

## License

CCRequest is release under the MIT license. See LICENSE for details.
