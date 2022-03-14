//
//  AliNewWorkViewController.m
//  RibutIOSDemo
//
//  Created by 微笑 on 2022/2/15.
//

#import "AliNewWorkViewController.h"
#import "AFNetworking.h"

@interface AliNewWorkViewController ()
@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) NSArray *dataSource;
@end

@implementation AliNewWorkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _manager = [AFHTTPSessionManager manager];
    _manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    self.refreshControl.tintColor = [UIColor greenColor];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"下拉刷新了~~"];
    [self.refreshControl addTarget:self action:@selector(change:) forControlEvents:UIControlEventValueChanged];
    
    [self sendRequest];
    
}

- (void)sendRequest
{
    __weak typeof(self) weakSelf = self;
    [_manager GET:@"http://t.weather.sojson.com/api/weather/city/101010300" parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *result = responseObject;
        if (result[@"data"]) {
            NSDictionary *data = result[@"data"];
            if (data) {
                weakSelf.dataSource = data[@"forecast"];
                if (weakSelf.dataSource.count) {
                    [weakSelf.tableView reloadData];
                }
            }
        }
        [weakSelf.refreshControl endRefreshing];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"%@",error);
        [weakSelf.refreshControl endRefreshing];
        
    }];
}

-(void)change:(UIRefreshControl*)con{
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"开始刷新了~~"];
    [self sendRequest];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    if (cell == nil) {
           // 创建新的 cell，默认为主标题模式
           cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }

    // 设置每一行显示的文字内容
    NSDictionary *dict = _dataSource[indexPath.row];
    NSString *ymd = dict[@"ymd"];
    NSString *week = dict[@"week"];
    NSString *type = dict[@"type"];
    NSString *high = dict[@"high"];
    NSString *low = dict[@"low"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ ",ymd,week,type,high,low];
    
    return cell;
}



@end
