//
//  AliRibutTool.m
//  AliRibutSDK
//
//  Created by 微笑 on 2019/11/30.
//  Copyright © 2019 zhangjc. All rights reserved.
//

#import "AliRibutTool.h"

@implementation AliRibutTool

+ (NSDictionary *)paymentObjectFromJSONString:(NSString *)jsonString
{
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (data) {
        NSError *JSONError = nil;
        NSDictionary *obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
        if (!JSONError) {
            return obj;
        }
    }
    return nil;
}

+ (NSString *)paymentJSONString:(NSDictionary *)json
{
    if([NSJSONSerialization isValidJSONObject:json]){
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:&error];
        if (!error) {
            return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];;
        }
    }
    return nil;
}

@end


