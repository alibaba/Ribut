//
//  ViewController.m
//  RibutIOSDemo
//
//  Created by 微笑 on 2022/2/13.
//

#import "ViewController.h"
#import "LBXScanNativeViewController.h"
#import "StyleDIY.h"
#import "LBXPermission.h"
#import "LBXPermissionSetting.h"

#import "AliRibutSDK.h"
#import "AliDemoService.h"
#import "AliNewWorkViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (LBXScanBaseViewController*)createScanVC
{
    LBXScanBaseViewController *vc = nil;
    
    LBXScanNativeViewController* tmp = [LBXScanNativeViewController new];
    tmp.listScanTypes = @[[StyleDIY nativeCodeWithType:SCT_QRCode]];
    vc = tmp;

    vc.cameraInvokeMsg = @"相机启动中";
    
    //开启只识别框内,ZBar暂不支持
    vc.isOpenInterestRect = NO;
    
    vc.continuous = NO;

    return vc;
}

- (void)jumpScanVC
{
    LBXScanBaseViewController *vc = [self createScanVC];
    
    vc.style = [StyleDIY ZhiFuBaoStyle];
    vc.orientation = [StyleDIY videoOrientation];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)clickSaoyiSao:(id)sender {
    
    __weak __typeof(self) weakSelf = self;
    [LBXPermission authorizeWithType:LBXPermissionType_Camera completion:^(BOOL granted, BOOL firstTime) {
        if (granted) {
            [weakSelf jumpScanVC];
        }
        else if(!firstTime)
        {
            [LBXPermissionSetting showAlertToDislayPrivacySettingWithTitle:@"提示" msg:@"没有相机权限，是否前往设置" cancel:@"取消" setting:@"设置" ];
        }
    }];

}

- (IBAction)clickRequest:(id)sender {
    
    AliNewWorkViewController *networkVc = [[AliNewWorkViewController alloc] init];
    [self.navigationController pushViewController:networkVc animated:YES];
}

- (IBAction)addOneRow:(id)sender {
    [[AliDemoService shareInstance] addOneRow];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 注册自定义频道
    [self setupChannelService];
}

// 注册自定义频道
- (void)setupChannelService
{
    [[AliRibutManager shareInstance] registerChannel:@"Demo" delegate:[AliDemoService shareInstance]];
}

@end
