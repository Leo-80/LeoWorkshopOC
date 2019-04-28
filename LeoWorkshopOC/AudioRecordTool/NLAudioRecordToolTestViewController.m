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
@property (nonatomic, strong) NSString * recordPath;
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
    
    UIButton * playRecordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    playRecordBtn.frame = CGRectMake(50.0f, 250.0f, 100.0f, 50.0f);
    [playRecordBtn setTitle:@"播放录音" forState:UIControlStateNormal];
    [playRecordBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [playRecordBtn addTarget:self action:@selector(playRecordAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playRecordBtn];
    
    UIButton * stopPlayRecordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    stopPlayRecordBtn.frame = CGRectMake(50.0f, 300.0f, 150.0f, 50.0f);
    [stopPlayRecordBtn setTitle:@"停止播放录音" forState:UIControlStateNormal];
    [stopPlayRecordBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [stopPlayRecordBtn addTarget:self action:@selector(stopPlayRecordAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stopPlayRecordBtn];
}

- (void)beginRecordAction{
    NSLog(@"开始录音");
     [_arTool prepareRecord];
     [_arTool beginRecord];
}

- (void)stopRecordAction{
    NSLog(@"结束录音");
    [_arTool stopRecord];
    _recordPath = [_arTool audioRecordTypeToMP3:[_arTool getAudioFilePath:@"test.caf"] isDelSourceFile:NO];
    
//    [[NLOSSManage initOSSManage] uploadFilesForAliOSS:_recordPath savePath:@"video/1234567890"];
}
- (void)playRecordAction{
    NSLog(@"播放录音");
    [_arTool playRecord:_recordPath];
}
- (void)stopPlayRecordAction{
    NSLog(@"停止播放录音");
     [_arTool stopPlayRecord];
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
