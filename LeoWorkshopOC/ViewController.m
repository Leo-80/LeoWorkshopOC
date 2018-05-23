//
//  ViewController.m
//  LeoWorkshopOC
//
//  Created by leo on 2018/5/22.
//  Copyright © 2018年 leo. All rights reserved.
//

#import "ViewController.h"
#import <Masonry.h>
#import "NLWeexViewController.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView * vcTableView;
@end

@implementation ViewController

#pragma mark lazy
- (UITableView *)vcTableView{
    
    if(!_vcTableView){
        _vcTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
        _vcTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _vcTableView.delegate = self;
        _vcTableView.dataSource = self;
        _vcTableView.backgroundColor = [UIColor whiteColor];
        _vcTableView.rowHeight = 48;
        //        _vcTableView.tableFooterView = [UIView new];
    }
    return _vcTableView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self layoutView];
}

- (void)layoutView{
    __weak __typeof(self) wself = self;
    [self.view addSubview:self.vcTableView];
    [self.vcTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(wself.view);
    }];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellIdentifier = @"cellIdentifier";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = @"weex example";
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NLWeexViewController * weexVC =  [[NLWeexViewController alloc] init];
    weexVC.weexUrl = [NSString stringWithFormat:@"file://%@/index.native.js",[NSBundle mainBundle].bundlePath];
    [self.navigationController pushViewController:weexVC animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
