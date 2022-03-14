//
//  RBRibutTool.h
//  YKRibutSDK
//
//  Created by 微笑 on 2019/11/30.
//  Copyright © 2019 zhangjc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AliRibutTool : NSObject
+ (NSDictionary *)ributObjectFromJSONString:(NSString *)jsonString;
+ (NSString *)ributJSONString:(NSDictionary *)json;
@end

NS_ASSUME_NONNULL_END
