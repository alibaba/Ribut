//
//  AliRibutManager.h
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

#import <Foundation/Foundation.h>
#import "AliRibutProtocol.h"

#pragma mark - Notification
/*
 Ribut Mac Connect Notification
 Sending Format:
    notification.userInfo[@"url"] = the ribut connect url;
 Receiving Format:
    notification.userInfo[@"url"] = the ribut connect url;
*/
FOUNDATION_EXPORT NSString *const AliRibutConnectNotification;/**< = @"AliRibutConnectNotification" */

#pragma mark - Event
/*
    Ribut Event
    Select Tool Channel Event
 */
FOUNDATION_EXPORT NSString* const AliRibutToolChannelSelectedEvent;/**< = @"AliRibutToolChannelSelectedEvent" */

NS_ASSUME_NONNULL_BEGIN

@interface AliRibutManager : NSObject

/**
 Singleton.
 
 @return Singleton
 */
+ (instancetype)shareInstance;

/**
 Connect Ribut Mac
 @param url：Ribut Mac ip:port ws://169.254.203.177:5622
*/
- (void)connectWithURL:(NSString *)url;

/**
 Disconnect
*/
- (void)disConnect;

/**
 Register a Channel for ToolPage
 @param channel name.
 @param delegate <YKRibutProtocol>
 */
- (void)registerChannel:(NSString *)channel delegate:(id<AliRibutProtocol>)delegate;

/**
 *  send Ribut Mac Message
 *  @param message The message to Ribut Mac
 *  @param channel name
 *  @param callback ribut callback.
 */
- (void)sendMessage:(id)message
        withChannel:(NSString *)channel
           callback:(void(^)(NSError *error))callback;

@end

NS_ASSUME_NONNULL_END
