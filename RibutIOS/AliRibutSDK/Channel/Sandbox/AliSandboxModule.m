//
//  AliSandboxMoudle.m
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

#import "AliSandboxModule.h"
#import "AliSocketService.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "AliRibutProtocol.h"
@interface AliSandboxModule ()<AliRibutProtocol>
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation AliSandboxModule

+ (instancetype)shareInstance
{
    static AliSandboxModule *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[AliSandboxModule alloc] init];
    });
    return _instance;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)ributDidConnect:(AliSocketService *)service
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *homeDir = NSHomeDirectory();
        NSArray *sanboxArray =  [self getAllSandBoxFile:homeDir];
        if (sanboxArray.count == 0) {
            return;
        }
        NSError *error = nil;
        NSDictionary *dict = @{@"name":@"root",@"toggled":@(YES),@"children":[sanboxArray copy]};
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
        if (jsonData == nil) {
            return;
        }
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [[AliSocketService shareInstance] sendMessage:@{@"event":@"yksc.event.ribut.querySandBoxListEvent",@"message":jsonString} withChannel:@"sandbox" callback:^(NSError * _Nonnull error) {
            
        }];
    });
}

- (void)ribut:(nonnull AliSocketService *)service receiveData:(nonnull NSDictionary *)data {
    if (![data isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    NSDictionary *value = [data valueForKey:@"value"];
    NSString *event = [value valueForKey:@"event"];
    NSString *path = [value valueForKey:@"path"];
    NSString *name = [value valueForKey:@"name"];
    NSArray *paramsArray = [value valueForKey:@"params"];
    if (!(paramsArray && [paramsArray isKindOfClass:[NSArray class]])) {
        paramsArray = @[];
    }
    
    NSMutableDictionary *paramsDict = nil;
    if (paramsArray.count) {
        paramsDict = [NSMutableDictionary dictionary];
        for (int i = 0; i < paramsArray.count; i++) {
            NSDictionary *paramInfo = paramsArray[i];
            if (![paramInfo isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            
            NSString *paramName = [paramInfo valueForKey:@"paramName"];
            id paramValue = [paramInfo objectForKey:@"paramValue"];
            if (paramName.length && paramValue) {
                [paramsDict setValue:paramValue forKey:paramName];
            }
        }
    }
    
    if ([event isEqualToString:@"yksc.event.ribut.querySandBoxListEvent"]) { // 调试事件：获取沙盒文件树形列表
        [self querySandBoxListEvent:path name:name];
    }else if ([event isEqualToString:@"yksc.event.ribut.querySandBoxSingleFileEvent"]){
        [self querySandBoxSingleFileEvent:path name:name];
    }
}

- (void)querySandBoxListEvent:(NSString *)path name:(NSString *)name
{
    NSString *homeDir = NSHomeDirectory();
    NSArray *sanboxArray =  [self getAllSandBoxFile:homeDir];
    if (sanboxArray.count == 0) {
        return;
    }
    NSError *error = nil;
    NSDictionary *dict = @{@"name":@"root",@"toggled":@(YES),@"children":[sanboxArray copy]};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    if (jsonData == nil) {
        return;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [[AliSocketService shareInstance] sendMessage:@{@"event":@"yksc.event.ribut.querySandBoxListEvent",@"message":jsonString} withChannel:@"sandbox" callback:^(NSError * _Nonnull error) {
        
    }];
}

- (void)querySandBoxSingleFileEvent:(NSString *)path name:(NSString *)name
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData *data= [fileManager contentsAtPath:path] ;
    if (data == nil) {
        return;
    }
    NSString *dadaString;
    BOOL isUtf8Encode = YES;
    if ([name hasSuffix:@".plist"]) { // plist
        NSArray *plistArray = [[NSArray alloc] initWithContentsOfFile:path];
        NSDictionary *plistDict = [[NSDictionary alloc] initWithContentsOfFile:path];
        NSData *plistJsonData;
        NSString *plistJsonString ;
        NSError *error = nil;
        if (plistArray) {
            plistJsonData = [NSJSONSerialization dataWithJSONObject:plistArray options:kNilOptions error:&error];
            plistJsonString = [[NSString alloc] initWithData:plistJsonData encoding:NSUTF8StringEncoding];
        }else if (plistDict){
            plistJsonData = [NSJSONSerialization dataWithJSONObject:plistDict options:kNilOptions error:&error];
            plistJsonString = [[NSString alloc] initWithData:plistJsonData encoding:NSUTF8StringEncoding];
        }
        //暂时只显示原编码，使用上述方式可以将plist转换为json格式展示，后续根据情况定
        isUtf8Encode = [self adapterUtf8OAliase64:data :&dadaString];
    }else if ([name hasSuffix:@".png"]){ // png
        NSString *base64JsonString = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
        NSString *stripString =[base64JsonString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.alphanumericCharacterSet];
        dadaString = [NSString stringWithFormat:@"data:image/png;base64,%@", stripString];
    }else if ([name hasSuffix:@".jpeg"]){ // jpeg
        NSString *base64JsonString = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
        NSString *stripString =[base64JsonString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.alphanumericCharacterSet];
        dadaString = [NSString stringWithFormat:@"data:image/jpeg;base64,%@", stripString];
    }else{
        isUtf8Encode = [self adapterUtf8OAliase64:data :&dadaString];
    }
    [[AliSocketService shareInstance] sendMessage:@{@"event":@"yksc.event.ribut.querySandBoxSingleFileEvent",@"message":dadaString?:@"",@"name":name,@"utf8encode":@(isUtf8Encode)} withChannel:@"sandbox" callback:^(NSError * _Nonnull error) {
        
    }];

}

- (BOOL)adapterUtf8OAliase64:(NSData *) sourceData :(NSString **)resourceString{
    *resourceString = [[NSString alloc] initWithData:sourceData
                                            encoding:NSUTF8StringEncoding];
    if ((*resourceString).length>0) {
        return YES;
    }else{
        NSString *stringBase64 = [sourceData base64EncodedStringWithOptions:0];
        *resourceString = [stringBase64 stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.alphanumericCharacterSet];
        return NO;
    }
}

// 方法实现
- (NSString *)mimeTypeForFileAtPath:(NSString *)path
{
    // 这里使用文件管理者的相关方法判断文件路径是否有后缀名
    if (![[[NSFileManager alloc] init] fileExistsAtPath:path]) {
        return nil;
    }
    // [path pathExtension] 获得文件的后缀名 MIME类型字符串转化为UTI字符串
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[path pathExtension], NULL);
    // UTI字符串转化为后缀扩展名
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    // application/octet-stream，此参数表示通用的二进制类型。
    if (!MIMEType) {
        return @"application/octet-stream";
    }
    return (__bridge NSString *)(MIMEType);
}

- (NSArray*)getFileList:(NSString*)path{
    if (path.length==0) {
        return nil;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:path error:&error];
    if (error) {
        
    }
    return fileList;
}
- (NSArray*)getAllFileList:(NSString*)path{
    if (path.length==0) {
        return nil;
    }
    NSArray *fileArray = [self getFileList:path];
    NSMutableArray *fileArrayNew = [NSMutableArray array];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSString *aPath in fileArray) {
        NSString * fullPath = [path stringByAppendingPathComponent:aPath];
        BOOL isDir = NO;
        if ([fileManager fileExistsAtPath:fullPath isDirectory:&isDir]) {
            if (isDir) {
                [fileArrayNew addObjectsFromArray:[self getAllFileList:fullPath]];
            }else{
                [fileArrayNew addObject:fullPath];
            }
        }
    }
    return fileArrayNew;
}

- (NSArray*)getAllSandBoxFile:(NSString*)path{
    
    if (path.length==0) {
        return nil;
    }
    NSArray *fileArray = [self getFileList:path];
    NSMutableArray *fileArrayNew = [NSMutableArray array];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    @try {
        for (NSString *aPath in fileArray) {
            NSString * fullPath = [path stringByAppendingPathComponent:aPath];
            BOOL isDir = NO;
            if ([fileManager fileExistsAtPath:fullPath isDirectory:&isDir]) {
                NSError *error;
                NSDictionary *fileDetail = [fileManager attributesOfItemAtPath:fullPath error:&error];
                if (fileDetail.allKeys.count == 0) {
                    continue;
                }
                NSNumber *fileSize = [fileDetail objectForKey:NSFileSize];
                NSDate *date =[fileDetail objectForKey:NSFileModificationDate];
                NSString *strDate = @"";
                if (date) {
                    strDate = [self.dateFormatter stringFromDate:date];
                }
                if (isDir) {
                    [fileArrayNew addObject: @{@"name":aPath,@"size":[self folderSizeFormat:fullPath],@"date":strDate?:@"",@"type":@"dir",@"path":fullPath,@"children":[self getAllSandBoxFile:fullPath]}];
                }else{
                    [fileArrayNew addObject:@{@"name":aPath,@"size":[self sizeFormat:fileSize.longLongValue],@"date":strDate?:@"",@"type":@"file",@"path":fullPath}];
                }
            }
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    return fileArrayNew;
}

- (long long)getFileSize:(NSString*)path{
    unsigned long long fileLength = 0;
    @try {
        NSNumber *fileSize;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:path error:nil];
        if ((fileSize = [fileAttributes objectForKey:NSFileSize])) {
            fileLength = [fileSize unsignedLongLongValue]; //单位是 B
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    return fileLength;
}

- (NSDictionary*)getFileInfo:(NSString*)path{
    NSError *error;
    NSDictionary *reslut =  [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
    if (error) {
        return nil;
    }
    return reslut;
}

- (NSString *)sizeFormat:(unsigned long long) size{
    if (size < 1024) {
        return [NSString stringWithFormat:@"%llu ",size];
    }else if (size >= 1024 && size< 1024*1024){
        return [NSString stringWithFormat:@"%.2f K",size/1024.];
    }else if (size >= 1024*1024){
        return [NSString stringWithFormat:@"%.2f M",size/(1024.*1024)];
    }
    return @"0 B";
}

- (NSString *)folderSizeFormat:(NSString *)folderPath{
    unsigned long long floderSize = [self folderSizeAtPath:folderPath];
    if (floderSize < 1024) {
        return [NSString stringWithFormat:@"%llu ",floderSize];
    }else if (floderSize >= 1024 && floderSize< 1024*1024){
        return [NSString stringWithFormat:@"%.2f K",floderSize/1024.];
    }else if (floderSize >= 1024*1024){
        return [NSString stringWithFormat:@"%.2f M",floderSize/(1024.*1024)];
    }
    return @"0 B";
}

// 文件夹大小(字节)
- (unsigned long long)folderSizeAtPath:(NSString *)folderPath{
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString *fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString *fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self getFileSize:fileAbsolutePath];
    }
    return folderSize;
}


- (NSDateFormatter *)dateFormatter{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    return _dateFormatter;
}
@end
