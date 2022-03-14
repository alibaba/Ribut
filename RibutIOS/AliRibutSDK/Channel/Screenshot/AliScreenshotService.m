//
//  AliScreenshotService.m
//  YKRibutSDK
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

#import "AliScreenshotService.h"
#import "AliSocketService.h"
#import <Photos/Photos.h>
#import <UIKit/UIKit.h>
#import "AliRibutProtocol.h"
static AliScreenshotService *_instance = nil;

@interface AliScreenshotService()<AliRibutProtocol>

@end

@implementation AliScreenshotService

- (instancetype)init
{
    if (self = [super init]) {
        // 监听系统屏幕截屏
        [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(userDidScreenshot:)
            name:UIApplicationUserDidTakeScreenshotNotification
          object:nil];
    }
    return self;
}

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[AliScreenshotService alloc] init];
    });
    return _instance;
}

#pragma mark - 用户截屏通知事件
// 截屏
- (void)userDidScreenshot:(NSNotification *)notification {
    
    UIImage *mainScreenshot = [self screenShot];
    NSData *data = UIImagePNGRepresentation(mainScreenshot);
    NSString *base64JsonString = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    NSString *stripString =[base64JsonString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.alphanumericCharacterSet];
    NSMutableDictionary *msgParams = [NSMutableDictionary dictionary];
    [msgParams setValue:stripString forKey:@"img"];
    
    [[AliSocketService shareInstance] sendMessage:msgParams withChannel:@"screenshot" callback:^(NSError * _Nonnull error) {
        
    }];
    
}



- (void)ribut:(AliSocketService *)service receiveData:(NSDictionary *)data
{
    
}

- (UIImage *)screenShot
{
    UIImage * image[2];
    for (int i = 0; i < 2; i++) {
        if (i == 0) {
            // 获得状态栏view的上下文以绘制图片
            UIView *statusBarView = [[UIApplication sharedApplication] valueForKey:@"_statusBar"];
            UIGraphicsBeginImageContextWithOptions(statusBarView.frame.size, NO, [UIScreen mainScreen].scale);
            [statusBarView.layer renderInContext:UIGraphicsGetCurrentContext()];
            image[i] = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        } else {
            // 获得其他所有window，包括键盘，的上下文并绘制图片
            CGSize roomViewSize = [UIScreen mainScreen].bounds.size;
            UIGraphicsBeginImageContextWithOptions(roomViewSize, NO, [UIScreen mainScreen].scale);
            for (UIWindow *window in [UIApplication sharedApplication].windows) {
                if (![window respondsToSelector:@selector(screen)] || window.screen == [UIScreen mainScreen]) {
                    [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
                }
            }
            image[i] = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
    }
    // 将上面得到的两张图片合并绘制为一张图片，最终得到screenshotImage
    UIGraphicsBeginImageContextWithOptions(image[1].size, NO, [UIScreen mainScreen].scale);
    [image[1] drawInRect:CGRectMake(0, 0, image[1].size.width, image[1].size.height)];
    [image[0] drawInRect:CGRectMake(0, 0, image[0].size.width, image[0].size.height)];
    UIImage *screenshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData = UIImagePNGRepresentation(screenshotImage);
    screenshotImage = [UIImage imageWithData:imageData];

    return screenshotImage;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    
}

/**
 *  相册中最新的一张图片
 */
- (void)latestAssetImageWithSuccess:(void(^)(UIImage *))success {
  
    // 获取所有资源的集合，并按资源的创建时间排序
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    PHAsset *asset = [assetsFetchResults firstObject];
    // 使用PHImageManager从PHAsset中请求图片
    PHImageManager *imageManager = [[PHImageManager alloc] init];
    [imageManager requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (result) {
           // result 即为查找到的图片,也是此时的截屏图片
            if (success) {
                success(result);
            }
        }
    }];
}


@end
