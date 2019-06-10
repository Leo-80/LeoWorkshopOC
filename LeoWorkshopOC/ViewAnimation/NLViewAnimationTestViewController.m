//
//  NLViewAnimationTestViewController.m
//  LeoWorkshopOC
//
//  Created by leo on 2019/5/31.
//  Copyright © 2019 leo. All rights reserved.
//

#import "NLViewAnimationTestViewController.h"
#import "NLRateAdaptationTool.h"


@interface NLViewAnimationTestViewController ()
@property (nonatomic, strong) UIButton * startAnimationBtn;
@property (nonatomic, strong) UIView * demonstrateView;
@end

@implementation NLViewAnimationTestViewController
- (UIButton *)startAnimationBtn{
    if (!_startAnimationBtn) {
        _startAnimationBtn  = [UIButton buttonWithType:UIButtonTypeCustom];
        _startAnimationBtn.titleLabel.font = [UIFont systemFontOfSize:NLAdaption(15)];
        [_startAnimationBtn setTitle:@"开始动画" forState:UIControlStateNormal];
        [_startAnimationBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_startAnimationBtn addTarget:self action:@selector(startAnimationBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startAnimationBtn;
}
- (UIView *)demonstrateView{
    if (!_demonstrateView) {
        _demonstrateView = [[UIView alloc] init];
        _demonstrateView.backgroundColor = [UIColor redColor];
    }
    return _demonstrateView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self layoutView];
    
}
- (void)layoutView{
    
    [self.view addSubview:self.demonstrateView];
    [self.demonstrateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(100);
        make.left.equalTo(self.view).with.offset(-325);
        make.size.mas_equalTo(CGSizeMake(314, 40));
    }];
    
    [self.view addSubview:self.startAnimationBtn];
    
    [self.startAnimationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.demonstrateView.mas_bottom).with.offset(70);
        make.left.equalTo(self.view).with.offset(100);
        make.size.mas_equalTo(CGSizeMake(300, 40));
    }];
    
    UIView * raView = [[UIView alloc] init];
    raView.backgroundColor = [UIColor redColor];
    [self.view addSubview:raView];
    [raView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(NLAdaption(100));
        make.top.equalTo(self.startAnimationBtn.mas_bottom).with.offset(NLAdaption(20));
        make.size.mas_equalTo(CGSizeMake(NLAdaption(100), NLAdaption(100)));
    }];
}

- (void)startAnimationBtnAction{
    [UIView animateWithDuration:1.5 animations:^{
        NSLog(@"动画启动");
        [self.demonstrateView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).with.offset(11);
        }];
        //MARK: - 关键技术点，此布局修改对应当前view 所以使用self.view，如调整位置大小可使用self.demonstrateView
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        NSLog(@"动画结束");
        [self.demonstrateView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).with.offset(-325);
        }];
    }];
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
