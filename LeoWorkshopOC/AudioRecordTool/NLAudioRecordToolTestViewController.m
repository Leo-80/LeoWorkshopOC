//
//  NLAudioRecordToolTestViewController.m
//  LeoWorkshopOC
//
//  Created by leo on 2019/3/25.
//  Copyright © 2019 leo. All rights reserved.
//

#import "NLAudioRecordToolTestViewController.h"
#import "NLAudioRecordTool.h"
#import "NLOSSManage.h"

@interface NLAudioRecordToolTestViewController ()
@property (nonatomic, strong) NLAudioRecordTool * arTool;
@end

@implementation NLAudioRecordToolTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self layoutView];
    
    _arTool = [NLAudioRecordTool initAudioRecorderTool];
    [_arTool initAudioRecord:@"test.caf"];
    
}

- (void)layoutView{
    
    UIButton * beginRecordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    beginRecordBtn.frame = CGRectMake(50.0f, 150.0f, 100.0f, 50.0f);
    [beginRecordBtn setTitle:@"开始录音" forState:UIControlStateNormal];
    [beginRecordBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [beginRecordBtn addTarget:self action:@selector(beginRecordAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:beginRecordBtn];
    
    UIButton * stopRecordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    stopRecordBtn.frame = CGRectMake(50.0f, 200.0f, 100.0f, 50.0f);
    [stopRecordBtn setTitle:@"结束录音" forState:UIControlStateNormal];
    [stopRecordBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [stopRecordBtn addTarget:self action:@selector(stopRecordAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stopRecordBtn];
}

- (void)beginRecordAction{
     [_arTool beginRecord];
     [_arTool prepareRecord];
}

- (void)stopRecordAction{
    [_arTool stopRecord];
    NSString * path = [_arTool audioRecordTypeToMP3:[_arTool getAudioFilePath:@"test.caf"] isDelSourceFile:NO];
    
    [[NLOSSManage initOSSManage] uploadFilesForAliOSS:path savePath:@"video/1234567890"];
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
