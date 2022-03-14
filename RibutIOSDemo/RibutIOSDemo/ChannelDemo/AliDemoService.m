//
//  AliDemoService.m
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

#import "AliDemoService.h"



@interface AliDemoService()

@property (nonatomic,strong) NSArray *columns;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,assign) NSInteger rows;

@end

@implementation AliDemoService

+ (instancetype)shareInstance
{
    static AliDemoService *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[AliDemoService alloc] init];
    });
    return _instance;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _rows = 1;
        [self setupData];
    }
    return self;
}

- (void)setupData
{
    // 创建列数组
    NSArray *columns = @[
        @{
            @"title":@"列1",
            @"key":@"column1"
        },
        @{
            @"title":@"列2",
            @"key":@"column2"
        },
        @{
            @"title":@"列3",
            @"key":@"column3"
        },
        @{
            @"title":@"查看",
            @"key":@"more"
        }
    ];
    _columns = columns;
    
    
    // 创建行数据
    NSMutableArray *dataSource = [NSMutableArray array];
    for (int i = 0; i < _rows; i++) {
        NSString *col1 = [NSString stringWithFormat:@"第%d行第1列数据",i];
        NSString *col2 = [NSString stringWithFormat:@"第%d行第2列数据",i];
        NSString *col3 = [NSString stringWithFormat:@"第%d行第3列数据",i];
        NSDictionary *row = @{
            @"column1"  : col1,
            @"column2"  : col2,
            @"column3"  : col3,
            @"content"  : @{@"详情key1":@"详情value1",@"详情key2":@"详情value2",@"详情key3":@"详情value3",@"详情key4":@"详情value4"}
        };
        [dataSource addObject:row];
    }
    _dataSource = dataSource;
}

// 连接成功
- (void)ributDidConnect:(AliRibutManager *)service
{
        
}

/*
    ribut数据回调:
    data数据结构:
    {
        channel:注册频道,
        value:{
            channel:注册频道,
            event:Ribut回调事件,比如点击频道事件
        }
        
    }
 */
- (void)ribut:(YKRibutManager *)manager receiveData:(NSDictionary *)data
{
    NSDictionary *value = data[@"value"];
    if (value == nil || ![value isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSString *event = value[@"event"];
    // 点击频道，传递当前频道数据
    if ([event isEqualToString:AliRibutToolChannelSelectedEvent]) {
        // 创建消息字典
        NSMutableDictionary *message = [NSMutableDictionary dictionary];
        
        // 设置列数据
        [message setObject:_columns forKey:@"columns"];
        
        // 设置行数据
        [message setObject:_dataSource forKey:@"dataSource"];
        
        [[AliRibutManager shareInstance] sendMessage:message
                                         withChannel:@"Demo"
                                            callback:^(NSError * _Nonnull error) {
        }];
    }

}

- (void)addOneRow
{
    _rows++;
    NSString *col1 = [NSString stringWithFormat:@"第%ld行第1列数据",_rows - 1];
    NSString *col2 = [NSString stringWithFormat:@"第%ld行第2列数据",_rows - 1];
    NSString *col3 = [NSString stringWithFormat:@"第%ld行第3列数据",_rows - 1];
    NSDictionary *row = @{
        @"column1"  : col1,
        @"column2"  : col2,
        @"column3"  : col3,
        @"content"  : @{@"详情key1":@"详情value1",@"详情key2":@"详情value2",@"详情key3":@"详情value3",@"详情key4":@"详情value4"}
    };
    [_dataSource addObject:row];
    
    // 创建消息字典
    NSMutableDictionary *message = [NSMutableDictionary dictionary];
    
    // 设置列数据
    [message setObject:_columns forKey:@"columns"];
    
    // 设置行数据
    [message setObject:_dataSource forKey:@"dataSource"];
    
    [[AliRibutManager shareInstance] sendMessage:message
                                     withChannel:@"Demo"
                                        callback:^(NSError * _Nonnull error) {
    }];
}
@end
