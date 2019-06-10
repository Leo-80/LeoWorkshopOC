//
//  NLInAppPurchaseTestViewController.m
//  LeoWorkshopOC
//
//  Created by leo on 2019/5/9.
//  Copyright © 2019 leo. All rights reserved.
//

#import "NLInAppPurchaseTestViewController.h"
#import "NLInAppPurchaseTool.h"

@interface NLInAppPurchaseTestViewController ()

@end

@implementation NLInAppPurchaseTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self layoutView];
}
- (void)layoutView{
    
    UIButton * payBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    payBtn.frame = CGRectMake(50.0f, 150.0f, 100.0f, 50.0f);
    [payBtn setTitle:@"购买" forState:UIControlStateNormal];
    [payBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [payBtn addTarget:self action:@selector(payAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:payBtn];
}

- (void)payAction{
    NSArray * array = [NSArray arrayWithObjects:@"yinfu6", nil];
    [[NLInAppPurchaseTool initInAppPurchaseTool] requestInAppProduct:array];
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
