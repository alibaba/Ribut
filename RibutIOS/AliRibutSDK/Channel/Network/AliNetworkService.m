//
//  AliNetworkService.m
//  AliRibutSDK
//
//  Created by 微笑 on 2021/10/21
//  Copyright © 2020 Youku. All rights reserved.
//
//  MIT License
//
//  Copyright (c) 2021 Alibaba
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  fuAliished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "AliNetworkService.h"
#import "AliSocketService.h"
#import <objc/message.h>
#import "AliNetworkItem.h"

#import "AFNetworking.h"


@interface AliNetworkService ()
@property (atomic, strong) NSMutableDictionary *mockList;
@end
@implementation AliNetworkService
static AliNetworkService *_instance = nil;
static dispatch_queue_t  _q;

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _q = dispatch_queue_create("network_queue",NULL);
        _instance = [[AliNetworkService alloc] init];
    });
    return  _instance;
}

+ (void)reigisterHookNetwork
{
                        
    @try {
        Class mtopClass = NSClassFromString(@"AFHTTPSessionManager");
        Method origMethod = class_getInstanceMethod(mtopClass, @selector(GET:parameters:headers:progress:success:failure:));
        Method selfMethod = class_getInstanceMethod(mtopClass, @selector(ali_GET:parameters:headers:progress:success:failure:));
        if (origMethod && selfMethod) {
            method_exchangeImplementations(origMethod, selfMethod);
        }
            
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [AliNetworkService reigisterHookNetwork];
    }
    return self;
}

- (NSMutableDictionary *)mockList
{
    @synchronized (self) {
        if (_mockList == nil) {
            _mockList = [NSMutableDictionary dictionary];
        }
    }
    return _mockList;
}


+ (void)sendMsgWithApiName:(NSString *)apiName
                parameters:(nullable id)parameters
                   headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                      json:(nullable NSDictionary *)json
{
    NSMutableDictionary *msgParams = [NSMutableDictionary dictionary];
    NSMutableDictionary *header = [NSMutableDictionary dictionary];
    if (apiName.length) {
        [msgParams setValue:apiName forKey:@"apiName"];
    }
    if (parameters) {
        [msgParams setValue:parameters forKey:@"bizParameters"];
    }else {
        [msgParams setValue:@{@"自定义参数":@"无参数"} forKey:@"bizParameters"];
    }
    
    if (headers) {
        [header addEntriesFromDictionary:headers];
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterFullStyle;
//    formatter.dateFormat = @"YYYY-mm-dd HH:MM:SS";
    NSString *time = [formatter stringFromDate:[NSDate date]];
    [header setObject:time forKey:@"Date"];
    [msgParams setObject:header forKey:@"headers"];
    
    if (json) {
        [msgParams setValue:json forKey:@"body"];
    }
    
    [[AliSocketService shareInstance] sendMessage:msgParams withChannel:@"network" callback:^(NSError * _Nonnull error) {
        
    }];
}

- (void)ribut:(AliSocketService *)service receiveData:(NSDictionary *)data
{
    NSDictionary *value = [data valueForKey:@"value"];
    NSString *event = [value valueForKey:@"event"];
    // yksc.event.ribut.DeleteAllMockMtopEvent
    if ([event isEqualToString:@"yksc.event.ribut.mockMtopEvent"]) {
        // Mtop ApiName都是小写
        NSString *apiName = [[value valueForKey:@"apiName"] lowercaseString];
        BOOL enableMock = [[value valueForKey:@"enableMock"] boolValue];
        NSDictionary *json = [value valueForKey:@"json"];
        AliNetworkMockItem *mockItem = [[AliNetworkMockItem alloc] init];
        mockItem.apiName = apiName;
        mockItem.enableMock = enableMock;
        mockItem.json = json;
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:&error];
        mockItem.body = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];;
        [self.mockList setValue:mockItem forKey:apiName];
    } else if ([event isEqualToString:@"yksc.event.ribut.DeleteAllMockMtopEvent"]) {
        [self.mockList removeAllObjects];
    }
    
     
}

@end

@implementation AFHTTPSessionManager(Ribut)

- (NSURLSessionDataTask *)ali_GET:(NSString *)URLString
                   parameters:(nullable id)parameters
                      headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                     progress:(nullable void (^)(NSProgress * _Nonnull))downloadProgress
                      success:(nullable void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                      failure:(nullable void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure
{
    
    @synchronized (self) {
        
        NSURLSessionDataTask *task = [self ali_GET:URLString parameters:parameters headers:headers progress:downloadProgress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            NSDictionary *mockList = [AliNetworkService shareInstance].mockList;
            AliNetworkMockItem *mockItem = [mockList valueForKeyPath:URLString];
            if (mockItem.enableMock) {
                responseObject = mockItem.json;
            }
            if (success) {
                success(task,responseObject);
            }
            [AliNetworkService sendMsgWithApiName:URLString parameters:parameters headers:headers json:responseObject];
                    
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failure) {
                    failure(task,error);
                }
            }];

        return task;
    }

}

@end
