//
//  AliSocketClient.m
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
// 

#import "AliSocketClient.h"
#import <AFNetworking/AFNetworking.h>
#import "SRWebSocket.h"
#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

@interface AliSocketClient ()<SRWebSocketDelegate>
@property(nonatomic, strong) SRWebSocket *webScoket;
@property(nonatomic, strong) NSTimer *headeAlieatTimer; //心跳定时器
@property(nonatomic, strong) NSTimer *networkTestingTimer; //没有网络的时候检测定时器
@property(nonatomic, assign) NSTimeInterval reConnectTime; //重连时间
@property(nonatomic, strong) NSMutableArray *sendDataArray; //存储要发送给服务器的数据
@property(nonatomic, assign) BOOL isActiveClose; //用于判断是否主动关闭长连接，如果是主动断开连接，连接失败的代理中，就不用执行 重新连接方法
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) dispatch_queue_t processingQueue;

@end

@implementation AliSocketClient

- (instancetype)initWithURL:(NSURL *)url delegate:(id<AliSocketClientDelegate>)delegate
{
    self = [self init];
    if (self) {
        _url = url;
        _delegate = delegate;
        _processingQueue = dispatch_queue_create("eu.nubomedia.websocket.processing", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}


- (instancetype)init{
    self = [super init];
    if (self) {
        self.reConnectTime = 0;
        self.isActiveClose = NO;
        self.sendDataArray = [[NSMutableArray alloc] init];
    }
    return self;
}

//建立长连接
- (void)connectServer{
    if(self.webScoket){
        return;
    }
    
    self.webScoket = [[SRWebSocket alloc] initWithURL:_url];
    [self.webScoket setDelegateDispatchQueue:self.processingQueue];
    self.webScoket.delegate = self;
    [self.webScoket open];
}

- (void)sendPing:(id)sender{
    NSData *heartData = [[NSData alloc] initWithBase64EncodedString:@"heart" options:NSUTF8StringEncoding];
    if ([self.webScoket respondsToSelector:@selector(sendPing:)]) {
        [self.webScoket sendPing:heartData];
    }
    if ([self.webScoket respondsToSelector:@selector(sendPing:error:)]) {
        [self.webScoket performSelector:@selector(sendPing:error:) withObject:heartData withObject:nil];
    }
    
}

//关闭长连接
- (void)webSocketClose{
    self.isActiveClose = YES;
    self.isConnect = NO;
    self.socketStatus = AliWebSocketStatusDefault;
    
    if (self.webScoket) {
        [self.webScoket close];
        self.webScoket = nil;
        
    }
    //关闭心跳定时器
    [self destoryHeartBeat];
    //关闭网络检测定时器
    [self destoryNetWorkStartTesting];
}

#pragma mark socket delegate

//已经连接
- (void)webSocketDidOpen:(SRWebSocket *)webSocket{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(socketClientDidConnect:)]) {
            [self.delegate socketClientDidConnect:self];
        }
    });

    self.isConnect = YES;
    self.socketStatus = AliWebSocketStatusConnect;
    [self initHeartBeat];//开始心跳
}

//连接失败
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    self.isConnect = NO;
    self.socketStatus = AliWebSocketStatusDisConnect;
    
    //判断网络环境
    if (AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        //没有网络,开启网络监测定时器
        [self noNetWorkStartTesting];//开启网络检测定时器
    }else{
//        [self reConnectServer];//连接失败，重新连接
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(socketClient:didFailWithError:)]) {
            [self.delegate socketClient:self didFailWithError:error];
        }
    });
}

//接收消息
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)messageData{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *messageDictionary;
        
        if ([messageData isKindOfClass:[NSString class]]) {
            messageDictionary = [self socket_dictionaryWithJSONString:messageData];
        }
        
        // 接受消息
        if (messageDictionary && [messageDictionary isKindOfClass:[NSDictionary class]]) {
            if ([self.delegate respondsToSelector:@selector(socketClient:didReceiveMessage:)]) {
                [self.delegate socketClient:self didReceiveMessage:messageDictionary];
            }
        }
        
    });
}


//关闭连接
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    self.isConnect = NO;
    if (self.isActiveClose) {
        self.socketStatus = AliWebSocketStatusDefault;
        return;
    }else{
        self.socketStatus = AliWebSocketStatusDisConnect;
    }
    
    [self destoryHeartBeat];  //断开时销毁心跳
    
    //判断网络
    if (AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        //没有网络,开启网络监测定时器
        [self noNetWorkStartTesting];
    }else{
        //有网络
        self.webScoket = nil;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(socketClientDidDisconnect:)]) {
            [self.delegate socketClientDidDisconnect:self];
        }
    });
    
}


/**
 接受服务端发生Pong消息，我们在建立长连接之后会建立与服务器端的心跳包
 心跳包是我们用来告诉服务端：客户端还在线，心跳包是ping消息，于此同时服务端也会返回给我们一个pong消息
 */
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongData{
    
}

#pragma mark NSTimer
//初始化心跳
- (void)initHeartBeat{
    if (self.headeAlieatTimer) {
        return;
    }
    [self destoryHeartBeat];
    dispatch_main_async_safe(^{
        self.headeAlieatTimer = [NSTimer timerWithTimeInterval:10 target:self selector:@selector(senderheartBeat) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.headeAlieatTimer forMode:NSRunLoopCommonModes];
    });
}

//重新连接
- (void)reConnectServer{
    
    //关闭之前的连接
    [self webSocketClose];
    
    //重连10次 2^10 = 1024
    if (self.reConnectTime > 1024) {
        self.reConnectTime = 0;
        return;
    }
    
    __weak typeof(self)ws = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.reConnectTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (ws.webScoket.readyState == SR_OPEN && ws.webScoket.readyState == SR_CONNECTING) {
            return ;
        }
        
        [ws connectServer];
        
        if (ws.reConnectTime == 0) {//重连时间2的指数级增长
            ws.reConnectTime = 2;
        }else{
            ws.reConnectTime *= 2;
        }
    });
}

//发送心跳
- (void)senderheartBeat{
    
    //和服务端约定好发送什么作为心跳标识，尽可能的减小心跳包大小
    __weak typeof (self) ws = self;
    dispatch_main_async_safe(^{
        if (ws.webScoket.readyState == SR_OPEN) {
            if ([ws respondsToSelector:@selector(sendPing:)]) {
                [ws sendPing:nil];
            }
        }else if (ws.webScoket.readyState == SR_CONNECTING){
            [ws reConnectServer];
        }else if (ws.webScoket.readyState == SR_CLOSED || ws.webScoket.readyState == SR_CLOSING){
            [ws reConnectServer];
        }else{
        }
    });
}

//取消心跳
- (void)destoryHeartBeat{
    __weak typeof(self) ws = self;
    dispatch_main_async_safe(^{
        if (ws.headeAlieatTimer) {
            [ws.headeAlieatTimer invalidate];
            ws.headeAlieatTimer = nil;
        }
    });
}

//没有网络的时候开始定时 -- 用于网络检测
- (void)noNetWorkStartTestingTimer{
    __weak typeof(self)ws = self;
    dispatch_main_async_safe(^{
        ws.networkTestingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(noNetWorkStartTesting) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:ws.networkTestingTimer forMode:NSDefaultRunLoopMode];
    });
}

//定时检测网络
- (void)noNetWorkStartTesting{
    if (AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus != AFNetworkReachabilityStatusNotReachable) {
        //关闭网络检测定时器
        [self destoryNetWorkStartTesting];
        //重新连接
        [self reConnectServer];
    }
}
//取消网络检测
- (void)destoryNetWorkStartTesting{
    __weak typeof(self) ws = self;
    dispatch_main_async_safe(^{
        if (ws.networkTestingTimer) {
            [ws.networkTestingTimer invalidate];
            ws.networkTestingTimer = nil;
        }
    });
}

- (NSString *)toJSONString:(NSDictionary *)msg {
    NSString * str = nil;
    if (msg && [msg isKindOfClass:[NSDictionary class]]) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:msg
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
        str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    return str;
    
}

- (void)sendDictToServer:(NSDictionary *)msg
{
    NSString *msgStr = [self toJSONString:msg];
    
    if (!msgStr.length) return;
    
    [self.sendDataArray addObject:msgStr];
    
    if (self.webScoket == nil) {
        return;
    }
    
    //没有网络
    if(AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable){
        //开启网络检测定时器
        [self noNetWorkStartTesting];
    }else{
        if (self.webScoket != nil) {
            //只有长连接OPEN开启状态才能调用send方法
            if (self.webScoket.readyState == SR_OPEN) {
                [self.webScoket send:msgStr];
            }else if (self.webScoket.readyState == SR_CONNECTING){
                //正在连接
            }else if(self.webScoket.readyState == SR_CLOSING || self.webScoket.readyState == SR_CLOSED){
                //调用 reConnectServer 方法重连,连接成功后 继续发送数据
//                [self reConnectServer];
            }
        }
    }
}

- (NSDictionary *)socket_dictionaryWithJSONString:(NSString *)jsonString {
    NSParameterAssert(jsonString.length > 0);
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *dict =
    [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
        return nil;
    }
    return dict;
}

@end
