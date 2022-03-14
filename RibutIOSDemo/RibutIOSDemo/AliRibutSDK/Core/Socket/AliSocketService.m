//
//  AliSocketService.m
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
//  furnished to do so, subject to the following conditions:
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

#import "AliSocketService.h"
#import "AliSocketClient.h"
#import "AliChannelManager.h"
#import "AliRibutManager.h"
@interface AliSocketService ()
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) AliSocketClient *client;
@property (nonatomic) NSUInteger requestId;
@property (nonatomic) NSMutableDictionary<NSString*,  NSObject<AliRibutProtocol>*> *channelList;
@property (nonatomic, assign) BOOL isPopAlertView;
@property (nonatomic) dispatch_semaphore_t sema;
@end

@implementation AliSocketService

+ (void)load
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [AliSocketService shareInstance];
    });
}

+ (instancetype)shareInstance {
    static AliSocketService *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        manager.channelList = [NSMutableDictionary dictionary];
        manager.sema = dispatch_semaphore_create(1);
        [[NSNotificationCenter defaultCenter] addObserver:manager selector:@selector(noti:) name:AliRibutConnectNotification object:nil];
       
        NSString *url = [[NSUserDefaults standardUserDefaults] objectForKey:[manager ributKey]];
        if (url.length > 0) {
            [manager setup:url];
        }
    });
    return manager;
}

- (void)noti:(NSNotification *)noti
{
   
    NSDictionary *userInfo = noti.userInfo;
    NSString *url = userInfo[@"url"];
    [self setup:url];
}

- (void)setup:(NSString *)url
{
    url = url.stringByRemovingPercentEncoding;
    if (url.length) {
        _url = url;
        [self setupScoket:url];
    }
}

- (void)setupScoket:(NSString *)url
{
    // 1.创建socket对象
    _client = [[AliSocketClient alloc] initWithURL:[NSURL URLWithString:url] delegate:self];
    
    // 2.开启socket连接
    [_client connectServer];
        
}

- (void)addChannel:(NSString *)channel delegate:(NSObject *)delegate {
    
    //判空
    if ([channel isKindOfClass:[NSString class]]
        && [channel length]
        && delegate) {
        
        if ([self.channelList objectForKey:channel] == delegate) {
            return;
        }
        
        //线程安全处理
        if ([[NSThread currentThread] isMainThread]) {
            [self.channelList setValue:delegate forKey:channel];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.channelList setValue:delegate forKey:channel];
            });
        }
    }
}

#pragma mark -AliSocketClientDelegate
- (void)socketClientDidConnect:(AliSocketClient *)client
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 添加chanenl
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [AliChannelManager setup];
            [[AliRibutManager shareInstance] performSelector:@selector(setupToolChannels)];
        });
        NSString *ributKey = [self ributKey];
        NSString *url = [[NSUserDefaults standardUserDefaults] objectForKey:ributKey];
        [[NSUserDefaults standardUserDefaults] setObject:_url forKey:ributKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    
    
        [self sendMessage:@{@"device":[UIDevice currentDevice].model} withChannel:@"device" callback:^(NSError * _Nonnull error) {
            
        }];
    
        [self.channelList enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSObject<AliRibutProtocol> * _Nonnull obj, BOOL * _Nonnull stop) {
            
            NSObject<AliRibutProtocol> *channelDelegate = obj;
            
            if ([channelDelegate respondsToSelector:@selector(ributDidConnect:)]) {
                [channelDelegate ributDidConnect:self];
            }
        }];
     
    });
    
}

- (void)socketClient:(AliSocketClient *)client didFailWithError:(NSError *)error
{
   
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    
        [self.channelList enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSObject<AliRibutProtocol> * _Nonnull obj, BOOL * _Nonnull stop) {
            
            NSObject<AliRibutProtocol> *channelDelegate = obj;
            
            if ([channelDelegate respondsToSelector:@selector(ributDidFailConnect:)]) {
                [channelDelegate ributDidFailConnect:self];
            }
        }];
     
    });
    NSString *url = [[NSUserDefaults standardUserDefaults] objectForKey:[self ributKey]];
    // 弹Toust 限制只弹一次
    if (_isPopAlertView == NO && !url) {
        ;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"连接失败" message:@"请重新扫码连接，如果连接不上，请重启Ribut！" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        [alert show];
        _isPopAlertView = YES;
    }
}

- (void)socketClient:(AliSocketClient *)client didReceiveMessage:(nonnull NSDictionary *)message
{
    if ([message isKindOfClass:[NSDictionary class]]
        && [message.allKeys containsObject:@"channel"]) {
        NSString *channel = message[@"channel"];
        NSObject<AliRibutProtocol> *channelDelegate = self.channelList[channel];
        
        if ([channelDelegate respondsToSelector:@selector(ribut:receiveData:)]) {
            [channelDelegate ribut:self receiveData:message];
        }
    }
}

- (void)sendMessage:(id)message
        withChannel:(NSString *)channel
           callback:(nonnull void (^)(NSError * ))callback{
    
    if(!channel || ![channel isKindOfClass:[NSString class]] || !channel.length){
        if (callback) {
            callback([NSError errorWithDomain:@"channelError" code:EINVAL userInfo:nil]);
        }
        return;
    }
    
    if(!message
       ||!([message isKindOfClass:[NSString class]]
           ||[message isKindOfClass:[NSDictionary class]]
           ||[message isKindOfClass:[NSArray class]]
           ||[message isKindOfClass:[NSData class]]))
    {
        if (callback) {
            callback([NSError errorWithDomain:@"msgError" code:EINVAL userInfo:nil]);
        }
        return;
    }
    
    if(!_client) {
        if (callback) {
            callback([NSError errorWithDomain:@"socketError" code:EINVAL userInfo:nil]);
        }
        return;
    }
    
    __weak __typeof(self)  weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_time_t t = dispatch_time(DISPATCH_TIME_NOW, (int64_t)1 * NSEC_PER_SEC);
        
        dispatch_semaphore_wait(weakSelf.sema, t);

        NSDictionary *msg = @{
                              @"channel": channel,
                              @"message": message
                              };
        
        [weakSelf.client sendDictToServer:msg];
        
        dispatch_semaphore_signal(self.sema);
        
    });
}

- (NSString *)ributKey
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
      
    NSString *str = [formatter stringFromDate:date];
    NSString *key = [NSString stringWithFormat:@"ribut:%@",str];
    return key;
}


- (void)socketClientDidDisconnect:(AliSocketClient *)client
{
    
}

- (void)dealloc {
    
    if (_client) {
        [_client webSocketClose];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
