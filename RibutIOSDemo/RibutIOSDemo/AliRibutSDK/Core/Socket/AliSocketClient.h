//
//  AliSocketClient.h
//  AliRibutSDK
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@class AliSocketClient;

typedef NS_ENUM(NSInteger, AliWebSocketStatus){
    AliWebSocketStatusDefault = 0, //初始状态，未连接
    AliWebSocketStatusConnect,     //已连接
    AliWebSocketStatusDisConnect,  //断开连接
};

@protocol AliSocketClientDelegate<NSObject>

@optional


/**
 *  接受到消息信息
 *  @param client 客户端socket.
 *  @param templateInfo 模板信息.
 */
-(void)socketClient:(AliSocketClient *)client didReceiveMessage:(NSDictionary *)message;

/**
 *scoket连接出错
 *  @param client 客户端socket.
 *  @param error  错误.
 */
-(void)socketClient:(AliSocketClient *)client didFailWithError:(NSError *)error;
/**
 *scoket连接成功
 *  @param client 客户端socket.
 */
-(void)socketClientDidConnect:(AliSocketClient *)client;
/**
 *scoket取消连接
 *  @param client 客户端socket.
 */
-(void)socketClientDidDisconnect:(AliSocketClient *)client;

@end



@interface AliSocketClient : NSObject

//是否连接
@property(nonatomic, assign) BOOL isConnect;
//socket状态
@property(nonatomic, assign) AliWebSocketStatus socketStatus;
//socket代理
@property(nonatomic, weak) id<AliSocketClientDelegate> delegate;

//初始化
- (instancetype)initWithURL:(NSURL *)url delegate:(id<AliSocketClientDelegate>)delegate;

//建立长连接
- (void)connectServer;
//重新连接
- (void)reConnectServer;
//关闭连接
- (void)webSocketClose;
//向服务器发送数据
- (void)sendDictToServer:(NSDictionary *)msg;

@end

NS_ASSUME_NONNULL_END
