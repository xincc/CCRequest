
# CCRequest

[中文介绍](https://github.com/xincc/CCRequest/blob/master/README-CN.md)

A dancing HTTP request framework base on AFNetworking 3.x for iOS & MacOS

## Features
* Promise
* Cache
* HTTPS
* Asynchronous Model Serializing
* Request Log convenient for Debug
* Request Exception Catching

## Installation 
* Add HTTP finder to your project.
* Add AFNetworking & YYCache to your podfile. (YYCache is a default cache service and you can use your own cache service by implementing [CCCacheProtocol](https://github.com/xincc/CCRequest/blob/master/HTTP/NetworkHelper/Cache/CCCacheProtocol.h) protocol, CocoaLumberjack is recommendatory Log framework but you can ignore it too)


## Usage

Dancing with promice

#### Promise.then

```objc
// Start first request task.

SamplePHPRequest.new.promise.then(^id(id data){

    // Get result(`Model` or `RawData`) finish by first task.
    // Then start sencond request task within promise.
    
    return SamplePHPRequest.new.promise;
    
},^id(CCResponseError *reason){
    
    // If some bad things happend to first task you can catch it in this scope.
    // But the error can't stop the promise chain.
    // Exception(or some thing) will send to next promise(if exist) in return value.
    
    return reason;
    
}).then(^id(id data){
    
    // Got result(`Model` or `RawData` or `Exception`) finish by previous promise.
    // Then start third request task within promise.
    // The result finish by third task will not be deal by Fornt End (Just send to server whithout care succeed or not).

    return [[[SamplePHPRequest new] bindRequestArgument:nil] promise];
    
},NULL);
```

#### Promise.next
```objc
// start primise chain

SamplePHPRequest.new.promise.next(^id(id data) {
    

    // Get result(`Model` or `RawData`) finish by first promised task.
    // These scope will never get errors.    
    CCLogInfo(@"%@",data);
    
    // Send data to next node in promise chain encapsulated in return value
    return data;
    
}).next(^id(id data){
    
    // Get result finish by previous promised node.    
    // Then start third request task within promise.

    return SamplePHPRequest.new.promise;
    
}).next(^id(id data) {
    
    // Get result(`Model` or `RawData`) finish by previous promised node.    
    CCLogInfo(@"Promise chain succeed");
    
    // Must return something, but will not sent to the `catch` node
    return data;
    
}).catch(^(CCResponseError *reason) {
    
    // If some bad things happend to `the whole promise chain`, you can catch it in this scope.
    // Peomise chain will be interrupted when catching any exception, 
    // which meanse the rest of promise nodes will not be excuted forever.

    CCLogError(@"Promise chain failed: %@",reason);
});
```

####Promise.all
```objc
[CCPromise all:@[SampleRequest.new.promise, SamplePHPRequest.new.promise]].then(^id(id data) {
    
    // If all of the promsie succeed, you can catch their result in this scope.
    // The data is an unordered array.
    // Maybe Dictionary is more appropriate, the key is ordered by index in promises.

    CCLogInfo(@"Get data: %@",data);
    
    // Must return something.
    // I want to optimize it, please send me any suggestions.
    return CCPromise.fulfilled;
    
}, ^id(CCResponseError *reason) {
    
    // If some bad things happend to `any promise in anof the promise`, you can catch it in this scope.
    CCLogError(@"Catched Error: %@",reason);
    return CCPromise.rejected;
    
});
```


####Normal Way
```objc
SamplePHPRequest *request = [SamplePHPRequest new];
[[request requestWithSuccess:^(id result, CCRequest *request) {
    
} failure:^(CCResponseError *error, CCRequest *request) {
    CCLogInfo(@"Never invoke the callback if you cancel the request");
}] appendAccessory:self];
```

####Surported Cache Policy
```objc
typedef NS_ENUM(NSUInteger, CCRequestCachePolicy) {
    
    // Request server immediately
    CCRequestReloadRemoteDataIgnoringCacheData,
    
    // Searching cache data first, return if hited data; otherwise request server data
    CCRequestReturnCacheDataElseReloadRemoteData,
    
    // Searching cache data first, invoke callbacks if hited data
    // No matter succeed or not we request server data
    CCRequestReturnCacheDataThenReloadRemoteData,
    
    // Request server data first, searching cache data if failed
    CCRequestReloadRemoteDataElseReturnCacheData,
};

// Cache Hitting Policy:

typedef NS_ENUM(NSUInteger, CCReturnCachePolicy) {
    
    // hit by fire time
    CCReturnCacheDataByFireTime,
    
    // hit by revalidating fired time if exist
    CCReloadRevalidatingCacheData
};

// Cache Write Policy:

typedef NS_ENUM(NSUInteger, CCDataCachePolicy) {
    
    // Cache Models 
    // Implement NSCoding protocol if you use the default cache service
    CCCachePolicyModel,
    
    // Cache raw data
    // JSON object for CCResponseSerializerTypeJSON
    // RawData for CCResponseSerializerTypeRawData
    CCCachePolicyRawData,
};

```

####Other advantages
* Surporting implement your request custom validator
* Surporting custom authorization or HTTP header
* Saving your time when facing to dazzling server frameworks


####Sample Codes
* [SampleRequest](https://github.com/xincc/CCRequest/blob/master/CCRequest/SampleRequest.m)
* [SamplePHPRequest](https://github.com/xincc/CCRequest/blob/master/CCRequest/SamplePHPRequest.m)

####Time to Fill knife

* Please check [CCRequest](https://github.com/xincc/CCRequest/blob/master/HTTP/NetworkHelper/Request/CCRequest.h) for more details
* The most recommend way is creating your own Base Class recommend inherited[CCCacheRequest](https://github.com/xincc/CCRequest/blob/master/HTTP/ProtocolHelper/CCCacheRequest.h)
* There are many places need to optimize.Welcome to create ISSUE or [send me a emial](mailto://xincc.wang@gmail.com). My original intention is resove `the vast majority of Networking Request` `politely`, and I am eager for communicating with your design philosophy.

## TODO

* Mock solution

## License

CCRequest is release under the MIT license. See LICENSE for details.
