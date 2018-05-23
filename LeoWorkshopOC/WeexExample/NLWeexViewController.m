//
//  NLWeexViewController.m
//  WeexExample
//
//  Created by leo on 2018/5/21.
//  Copyright © 2018年 leo. All rights reserved.
//

#import "NLWeexViewController.h"
#import <WeexSDK.h>

#ifdef DEBUG
# define DLog(format, ...) NSLog((@"[行号:%d]" format), __LINE__, ##__VA_ARGS__);
#else
# define DLog(...);
#endif


@interface NLWeexViewController ()
@property (nonatomic, strong) WXSDKInstance *wxInstance;
@property (nonatomic, strong) UIView * weexView;
@property (nonatomic, strong) NSArray * weexUrls;
@end

@implementation NLWeexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"weex view controller";
    // Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"FireWeex" style:UIBarButtonItemStyleDone target:self action:@selector(fireWeexAction)];
    [self weexRender];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self updateInstanceState:WeexInstanceAppear];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self updateInstanceState:WeexInstanceDisappear];
}
- (void)dealloc{
    [self.wxInstance destroyInstance];
}

/**
 初始化 weex 加载容器
 */
- (void)weexRender{
    
    [_wxInstance destroyInstance]; // weex instance 销毁
    _wxInstance = [[WXSDKInstance alloc]init];
    _wxInstance.viewController = self;
    
    _wxInstance.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    
    __weak typeof (self) weakSelf = self;

    // 创建 weex View
    _wxInstance.onCreate = ^(UIView * view){
        [weakSelf.weexView removeFromSuperview];
        weakSelf.weexView = view;
        [weakSelf.view addSubview:weakSelf.weexView];
    };
    
    // weex View 加载出错，此方法中可做降级处理。（如weex view加载失败，可用H5页面 或者 native View 替换显示）
    _wxInstance.onFailed = ^(NSError * error){
#ifdef DEBUG
        DLog(@"-----------\n");
        DLog(@"error:%@",[error domain]);
        DLog(@"-----------\n");
#endif
        // 降级处理 (暂时关闭)
        //        if (weakSelf.weexUrls.count > 1 ) {
        //            weakSelf.placeholderH5View.h5UrlStr = weakSelf.weexUrls[0];
        //            [weakSelf.view addSubview:weakSelf.placeholderH5View.view];
        //        }
        
    };
    // weex View 加载完成
    _wxInstance.renderFinish = ^(UIView *view){
        DLog(@"renderFinish");
        [weakSelf updateInstanceState:WeexInstanceAppear];
    };
    // 此方法 暂未用到
    _wxInstance.updateFinish = ^(UIView *view ) {
        DLog(@"updateFinish");
    };
    
    if ([self.weexUrl containsString:@"_wx_tpl"]) {
        _weexUrls = [self.weexUrl componentsSeparatedByString:@"_wx_tpl="];
        
        if (_weexUrls.count >1) {
            NSURL *url = [NSURL URLWithString:_weexUrls[1]];
            [_wxInstance renderWithURL:url options:@{} data:nil];
        }
    }else{
        NSURL *url = [NSURL URLWithString:self.weexUrl];
        [_wxInstance renderWithURL:url options:@{} data:nil]; // 加载weex view 
    }
    
    
}

/**
 weex 在加载完成时 和 离开页面时，调用

 @param state WXState
 */
- (void)updateInstanceState:(WXState)state
{
    if (_wxInstance && _wxInstance.state != state) {
        _wxInstance.state = state;
        NSString * temp = @"_root";
        if (state == WeexInstanceAppear) {
            [[WXSDKManager bridgeMgr] fireEvent:_wxInstance.instanceId ref:temp type:@"viewappear" params:nil domChanges:nil];
        }
        else if (state == WeexInstanceDisappear) {
            [[WXSDKManager bridgeMgr] fireEvent:_wxInstance.instanceId ref:temp type:@"viewdisappear" params:nil domChanges:nil];
        }
    }
}

/**
 native 主动向weex 发送数据
 */
- (void)fireWeexAction{
    WXSDKInstance * wxInstance = [WXSDKEngine topInstance]; // 获取活跃的 instance
    [wxInstance fireGlobalEvent:@"nativeToweex" params:@{@"params":@"this is params"}];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
