//
//  LBXScanBaseViewController.m
//  LBXScanDemo
//
//  Created by 夏利兵 on 2020/7/20.
//  Copyright © 2020 lbx. All rights reserved.
//

#import "LBXScanBaseViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "AliRibutSDK.h"

@interface LBXScanBaseViewController ()

@end

@implementation LBXScanBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.view.backgroundColor = [UIColor blackColor];

#if TARGET_IPHONE_SIMULATOR
  
    self.view.backgroundColor = [UIColor whiteColor];
#else
   
#endif
    
    
    self.firstLoad = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    self.firstLoad  = NO;
}

- (void)statusBarOrientationChanged:(NSNotification*)notification
{
    
}


#pragma mark- 识别结果
- (void)scanResultWithArray:(NSArray<LBXScanResult*>*)array
{
    
    if (!array ||  array.count < 1)
    {
        NSLog(@"扫码失败了。。。。");
        return;
    }
    // 0、获取扫码结果
    LBXScanResult *scanResult = array[0];
    // 1、获取扫码数据:ribut://ribut?url=ws%3A%2F%2F30.77.74.203%3A5622，ribut做了ip端口号encode
    NSString *data = scanResult.strScanned;;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];;
    NSURL *dataUrl = [NSURL URLWithString:data];
    // 2、解析url参数，生成字典
    /** 字典数据结构：url 不需要decode，内部会自动decode，直接作为通知参数即可
        params = {"url":"ws%3A%2F%2F30.77.74.203%3A5622"}
     */
    if (dataUrl) {
        NSString *query = dataUrl.query;
        NSDictionary *queryParam = [self transQueryToDictionary:query];
        params =[NSMutableDictionary dictionaryWithDictionary:queryParam];
    }
    // 3、判断是否是ribut扫码内容, 通过协议头ribut://ribut判断是否是ribut扫码
    if ([data hasPrefix:@"ribut://ribut"]) {
        // 4、发送ribut扫码通知,传递url解析的参数
        [[NSNotificationCenter defaultCenter] postNotificationName:AliRibutConnectNotification object:nil userInfo:params];
        return;
    }

}

// url参数转字典
- (NSDictionary *)transQueryToDictionary:(NSString *)query
{
    NSArray * array = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:array.count / 2];
    for (NSString * obj in array)
    {
        NSArray * subArray = [obj componentsSeparatedByString:@"="];
        NSString * key = [subArray objectAtIndex:0];
        NSString * value = nil;
        if ([subArray count]>2) {
            NSMutableString *temp = nil;
            for (int i=1;i<[subArray count];i++) {
                NSString *current = [subArray objectAtIndex:i];
                if (!current) {
                    current = @"";
                }
                if (i == 1) {
                    temp = [NSMutableString stringWithString:current];
                }
                else {
                    [temp appendString:[NSString stringWithFormat:@"=%@",current]];
                }
            }
            value = temp;
        }
        else if ([subArray count] == 2) {
            value = [subArray objectAtIndex:1];
        }
        else {
            // no value
            value = @"";  // empty string is friendly then [NSNull null]
        }
        [dict setValue:value forKey:key];
    }
    return [NSDictionary dictionaryWithDictionary:dict];
}


-(UIImage *)getImageFromLayer:(CALayer *)layer size:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, YES, [[UIScreen mainScreen]scale]);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


- (CGPoint)pointForCorner:(NSDictionary *)corner {
    CGPoint point;
    CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)corner, &point);
    return point;
}



- (void)handCorners:(NSArray<NSDictionary *> *)corners bounds:(CGRect)bounds
{
    CGFloat totalX = 0;
    CGFloat totalY = 0;
    
    for (NSDictionary *dic in corners) {
        CGPoint pt = [self pointForCorner:dic];
        NSLog(@"pt:%@",NSStringFromCGPoint(pt));
        totalX += pt.x;
        totalY += pt.y;
    }
    
    CGFloat averX = totalX / corners.count;
    CGFloat averY = totalY / corners.count;
    
   
    
    CGFloat minSize = MIN(bounds.size.width , bounds.size.height);
    
     NSLog(@"averx:%f,avery:%f minsize:%f",averX,averY,minSize);

    dispatch_async(dispatch_get_main_queue(), ^{
             
        [self signCodeWithCenterX:averX centerY:averY];
        
    });
}

- (void)signCodeWithCenterX:(CGFloat)centerX centerY:(CGFloat)centerY
{
    UIView *signView = [[UIView alloc]initWithFrame:CGRectMake(centerX-10, centerY-10, 20, 20)];
    
    [self.cameraPreView addSubview:signView];
    signView.backgroundColor = [UIColor redColor];
    
    self.codeFlagView = signView;
}
  


//继承者实现
- (void)reStartDevice
{
    
}

- (void)resetCodeFlagView
{
    if (_codeFlagView) {
        [_codeFlagView removeFromSuperview];
        self.codeFlagView = nil;
    }
    if (self.layers) {
        
        for (CALayer *layer in self.layers) {
            [layer removeFromSuperlayer];
        }
        
        self.layers = nil;
    }
}

- (UIImage *)imageByCroppingWithSrcImage:(UIImage*)srcImg cropRect:(CGRect)cropRect
{
   
    CGImageRef imageRef = srcImg.CGImage;
    CGImageRef imagePartRef = CGImageCreateWithImageInRect(imageRef, cropRect);
    UIImage *cropImage = [UIImage imageWithCGImage:imagePartRef];
    CGImageRelease(imagePartRef);
    return cropImage;
}


- (void)showNextVCWithScanResult:(LBXScanResult*)strResult
{
    
   
}


#pragma mark- 绘制二维码区域标志
- (void)didDetectCodes:(CGRect)bounds corner:(NSArray<NSDictionary*>*)corners
{
    AVCaptureVideoPreviewLayer * preview = nil;
    
    for (CALayer *layer in [self.cameraPreView.layer sublayers]) {
        
        if ( [layer isKindOfClass:[AVCaptureVideoPreviewLayer class]]) {
            
            preview = (AVCaptureVideoPreviewLayer*)layer;
        }
    }
    
    NSArray *layers = nil;
    if (!layers) {
        layers = @[[self makeBoundsLayer],[self makeCornersLayer]];
        [preview addSublayer:layers[0]];
        [preview addSublayer:layers[1]];
    }
    
    CAShapeLayer *boundsLayer = layers[0];
    boundsLayer.path = [self bezierPathForBounds:bounds].CGPath;
    //得到一个CGPathRef赋给图层的path属性
    
    if (corners) {
        CAShapeLayer *cornersLayer = layers[1];
        cornersLayer.path = [self bezierPathForCorners:corners].CGPath;
        //对于cornersLayer，基于元数据对象创建一个CGPath
    }
    
    self.layers = layers;

}


- (UIBezierPath *)bezierPathForBounds:(CGRect)bounds {
    // 图层边界，创建一个和对象的bounds关联的UIBezierPath
    return [UIBezierPath bezierPathWithRect:bounds];
}

- (CAShapeLayer *)makeBoundsLayer {
    //CAShapeLayer 是具体化的CALayer子类，用于绘制Bezier路径
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = [UIColor colorWithRed:0.96f green:0.75f blue:0.06f alpha:1.0f].CGColor;
    shapeLayer.fillColor = nil;
    shapeLayer.lineWidth = 4.0f;
    
    return shapeLayer;
}

- (CAShapeLayer *)makeCornersLayer {
    
    CAShapeLayer *cornersLayer = [CAShapeLayer layer];
    cornersLayer.lineWidth = 2.0f;
    cornersLayer.strokeColor = [UIColor colorWithRed:0.172 green:0.671 blue:0.428 alpha:1.0].CGColor;
    cornersLayer.fillColor = [UIColor colorWithRed:0.190 green:0.753 blue:0.489 alpha:0.5].CGColor;
    
    return cornersLayer;;
}

- (UIBezierPath *)bezierPathForCorners:(NSArray *)corners {
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    for (int i = 0; i < corners.count; i ++) {
        CGPoint point = [self pointForCorner:corners[i]];
        //遍历每个条目，为每个条目创建一个CGPoint
        if (i == 0) {
            [path moveToPoint:point];
        } else {
            [path addLineToPoint:point];
        }
    }
    [path closePath];
    return path;
}


#pragma mark- 相册

//继承者实现
- (void)recognizeImageWithImage:(UIImage*)image
{
   

}

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    __block UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (!image){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self recognizeImageWithImage:image];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"cancel");
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark- 权限
- (void)requestCameraPemissionWithResult:(void(^)( BOOL granted))completion
{
    if ([AVCaptureDevice respondsToSelector:@selector(authorizationStatusForMediaType:)])
    {
        AVAuthorizationStatus permission =
        [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        switch (permission) {
            case AVAuthorizationStatusAuthorized:
                completion(YES);
                break;
            case AVAuthorizationStatusDenied:
            case AVAuthorizationStatusRestricted:
                completion(NO);
                break;
            case AVAuthorizationStatusNotDetermined:
            {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                         completionHandler:^(BOOL granted) {
                                             
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 if (granted) {
                                                     completion(true);
                                                 } else {
                                                     completion(false);
                                                 }
                                             });
                                             
                                         }];
            }
                break;
                
        }
    }
    
    
}

+ (void)authorizePhotoPermissionWithCompletion:(void(^)(BOOL granted,BOOL firstTime))completion
{
    if (@available(iOS 8.0, *)) {
        
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        
        switch (status) {
            case PHAuthorizationStatusAuthorized:
            {
                if (completion) {
                    completion(YES,NO);
                }
            }
                break;
            case PHAuthorizationStatusRestricted:
            case PHAuthorizationStatusDenied:
            {
                if (completion) {
                    completion(NO,NO);
                }
            }
                break;
            case PHAuthorizationStatusNotDetermined:
            {
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    if (completion) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(status == PHAuthorizationStatusAuthorized,YES);
                        });
                    }
                }];
            }
                break;
            default:
            {
                if (completion) {
                    completion(NO,NO);
                }
            }
                break;
        }
        
    }else{
        
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        switch (status) {
            case ALAuthorizationStatusAuthorized:
            {
                if (completion) {
                    completion(YES, NO);
                }
            }
                break;
            case ALAuthorizationStatusNotDetermined:
            {
                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                
                [library enumerateGroupsWithTypes:ALAssetsGroupAll
                                       usingBlock:^(ALAssetsGroup *assetGroup, BOOL *stop) {
                                           if (*stop) {
                                               if (completion) {
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       completion(YES, NO);
                                                   });
                                                   
                                               }
                                           } else {
                                               *stop = YES;
                                           }
                                       }
                                     failureBlock:^(NSError *error) {
                                         if (completion) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 completion(NO, YES);
                                             });
                                         }
                                     }];
            } break;
            case ALAuthorizationStatusRestricted:
            case ALAuthorizationStatusDenied:
            {
                if (completion) {
                    completion(NO, NO);
                }
            }
                break;
        }
    }
  
}


- (BOOL)isLandScape
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;

    BOOL landScape = NO;
    
    
    switch (orientation) {
        case UIDeviceOrientationPortrait: {
            landScape = NO;
        }
            break;
        case UIDeviceOrientationLandscapeLeft: {
            landScape = YES;
        }
            break;
        case UIDeviceOrientationLandscapeRight: {
            
            landScape = YES;
        }
            break;
        case UIDeviceOrientationPortraitUpsideDown: {
            
            landScape = NO;
        }
            break;
        default:
            break;
    }
    
    return landScape;
    
}

- (AVCaptureVideoOrientation)videoOrientation
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    
    switch (orientation) {
        case UIDeviceOrientationPortrait: {
            return AVCaptureVideoOrientationPortrait;
        }
            break;
        case UIDeviceOrientationLandscapeRight : {
            return AVCaptureVideoOrientationLandscapeLeft;
        }
            break;
        case UIDeviceOrientationLandscapeLeft: {
            return AVCaptureVideoOrientationLandscapeRight;
            
        }
            break;
        case UIDeviceOrientationPortraitUpsideDown: {
            return AVCaptureVideoOrientationPortraitUpsideDown;
            
        }
            break;
        default:
            return AVCaptureVideoOrientationPortrait;
            break;
    }
    
    return AVCaptureVideoOrientationPortrait;
}

@end
