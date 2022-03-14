//
//  AliRibutManager.m
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

#import "AliRibutManager.h"
#import "AliSocketService.h"
#import "AliChannelManager.h"
NSString* const AliRibutConnectNotification = @"RIBUT_SOCKET_NOTIFICATION";
NSString* const AliRibutToolChannelSelectedEvent = @"RIBUT_TOOL_CHANNEL_SELECTED_EVENT";

@interface AliRibutManager ()
@property (nonatomic, strong) NSMutableArray *toolChannels;
@end

@implementation AliRibutManager

+ (instancetype)shareInstance {
    static AliRibutManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        manager.toolChannels = [NSMutableArray array];
    });
    return manager;
}

- (void)connectWithURL:(NSString *)url
{
    if (url.length) {
        // 建立Ribut连接
        [[AliSocketService shareInstance] setup:url];
    }
}

- (void)registerChannel:(NSString *)channel delegate:(id)delegate
{
    [[AliSocketService shareInstance] addChannel:channel delegate:delegate];
    [_toolChannels addObject:channel];
}

- (void)sendMessage:(id)message withChannel:(NSString *)channel callback:(void (^)(NSError * _Nonnull))callback
{
    [[AliSocketService shareInstance] sendMessage:message
                                            withChannel:channel
                                               callback:callback];
}

- (void)setupToolChannels
{
    if (_toolChannels.count == 0) {
        return;
    }
    NSMutableArray *toolChannels = [NSMutableArray array];
    for (NSString *channel in _toolChannels) {
        [toolChannels addObject:channel];
        
    }
    NSDictionary *message = @{
        @"channels":toolChannels
    };
    [[AliSocketService shareInstance] sendMessage:message
                                            withChannel:@"Tool"
                                        callback:^(NSError * _Nonnull error) {
        
    }];
}



@end
