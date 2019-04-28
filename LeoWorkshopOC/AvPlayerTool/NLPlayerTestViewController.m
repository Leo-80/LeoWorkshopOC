//
//  NLPlayerTestViewController.m
//  LeoWorkshopOC
//
//  Created by leo on 2019/4/23.
//  Copyright © 2019 leo. All rights reserved.
//

#import "NLPlayerTestViewController.h"
#import "NLPlayerTool.h"

@interface NLPlayerTestViewController ()
@property (nonatomic, strong) NLPlayerTool * playerTool;
@end

@implementation NLPlayerTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _playerTool = [NLPlayerTool initPlayerTool];
    [self layoutView];
}
- (void)layoutView{
    
    UIButton * playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    playBtn.frame = CGRectMake(50.0f, 150.0f, 100.0f, 50.0f);
    [playBtn setTitle:@"播放音乐" forState:UIControlStateNormal];
    [playBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [playBtn addTarget:self action:@selector(playMusic) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playBtn];
    
    UIButton * igniteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    igniteBtn.frame = CGRectMake(50.0f, 250.0f, 100.0f, 50.0f);
    [igniteBtn setTitle:@"seek播放" forState:UIControlStateNormal];
    [igniteBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [igniteBtn addTarget:self action:@selector(ignitePlayAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:igniteBtn];
    
    
    UIButton * pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    pauseBtn.frame = CGRectMake(50.0f, 350.0f, 100.0f, 50.0f);
    [pauseBtn setTitle:@"暂停播放" forState:UIControlStateNormal];
    [pauseBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [pauseBtn addTarget:self action:@selector(pauseMusic) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pauseBtn];
    
    UIButton * nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.frame = CGRectMake(50.0f, 450.0f, 100.0f, 50.0f);
    [nextBtn setTitle:@"下一首" forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(nextPlayMusic) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
    
}

- (void)playMusic{
    
    [_playerTool playMusic:@"https://cdn.hzweimo.com/video/4576643881239924736/1554209789000_i.mp3"];
}
- (void)pauseMusic{
    [_playerTool pauseMusic];
}
- (void)ignitePlayAction{
    [_playerTool seekToPlayTime:180.0f];
}
- (void)nextPlayMusic{
     [_playerTool playMusic:@"https://cdn.hzweimo.com/video/4578756337788284928/4578756337788284928_1553658480438_android.mp3"];
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
