//
//  NLMusicLyricScrollViewController.m
//  LeoWorkshopOC
//
//  Created by leo on 2019/3/27.
//  Copyright © 2019 leo. All rights reserved.
//

#import "NLMusicLyricScrollViewController.h"
#import "NLLrcParseTool.h"
#import <AVFoundation/AVFoundation.h>

@interface NLMusicLyricScrollViewController () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView * musicTableView;
@property (nonatomic, strong) NSArray * lrcObjects;
@property (nonatomic, assign) NSInteger currentLrcIndex;
@property (nonatomic, strong) AVPlayer * player;
@property (nonatomic, assign) NSInteger currentRow;
@end

@implementation NLMusicLyricScrollViewController

- (UITableView *)musicTableView{
    if (!_musicTableView) {
        CGRect  mTableFrame =  CGRectMake(0.0f, 100.0f, CGRectGetWidth(self.view.frame), 400.0f);
        _musicTableView = [[UITableView alloc] initWithFrame:mTableFrame style:UITableViewStylePlain];
        _musicTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _musicTableView.delegate = self;
        _musicTableView.dataSource = self;
        _musicTableView.backgroundColor = [UIColor whiteColor];
        _musicTableView.rowHeight = 48;
    }
    return _musicTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _lrcObjects= [[NLLrcParseTool initLrcParseTool] lrcToolWithLrcFile:@"1553152856148" FileType:@"txt"];
    [self layoutView];
    
    [self initMusic];
    
}

- (void)layoutView{
    [self.view addSubview:self.musicTableView];
    
    UIButton * playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    playBtn.frame = CGRectMake(50.0f, 550.0f, 100.0f, 50.0f);
    [playBtn setTitle:@"播放音乐" forState:UIControlStateNormal];
    [playBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [playBtn addTarget:self action:@selector(playMusic) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playBtn];
    
    UIButton * igniteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    igniteBtn.frame = CGRectMake(50.0f, 650.0f, 100.0f, 50.0f);
    [igniteBtn setTitle:@"燃点播放" forState:UIControlStateNormal];
    [igniteBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [igniteBtn addTarget:self action:@selector(ignitePlayAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:igniteBtn];
}


- (void)initMusic{
    
    NSURL * mUrl = [NSURL URLWithString:@"https://music.hzweimo.com/20190321/Sw0DAFULdtuAEg4jAEA9tW64BJY812.mp3"];
    AVPlayerItem * mItem = [AVPlayerItem playerItemWithURL:mUrl];
    _player = [[AVPlayer alloc] initWithPlayerItem:mItem];
    [mItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    __weak typeof(self)wSelf = self;
    [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, NSEC_PER_SEC) queue:NULL usingBlock:^(CMTime time) {
        
        CGFloat currentTime = CMTimeGetSeconds(wSelf.player.currentItem.currentTime);
        NSLog(@"currentTime : %f",currentTime);
        [wSelf disPlayLyric:currentTime];
    }];
    
}
- (void)ignitePlayAction{
    [self seekToPlayTime:180.0f];
}
- (void)disPlayLyric:(NSTimeInterval)currentTime{
   
    
        for (NSInteger i = _currentRow ; i < _lrcObjects.count; i++) {
            LrcObject * lrcOb = _lrcObjects[i];
            if (currentTime > [lrcOb.lrcTime floatValue]) {
                _currentRow = i;
               
            }else{
                break;
            }
        }
    
         NSLog(@"_currentRow : %ld",(long)_currentRow);
        [_musicTableView reloadData];
     if (_lrcObjects.count - _currentRow > 8) {
        [_musicTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_currentRow inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    
}

- (void)seekToPlayTime:(NSTimeInterval)startTime{
    CMTime cTime = CMTimeMake(startTime, 1);
    __weak typeof(self)wSelf = self;
    [_player seekToTime:cTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        if (finished) {
            [wSelf.player play];
        }
    }];
}

- (void)playMusic{
    
    [_player play];
    
}
#pragma mark AVPlayer KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] intValue];
        switch (status) {
            case AVPlayerItemStatusFailed:
                NSLog(@"player item error");
                break;
            case AVPlayerItemStatusReadyToPlay:
                NSLog(@"player is ready ");
                break;
            case AVPlayerItemStatusUnknown:
                NSLog(@"player unknown  error");
                break;
            default:
                break;
        }
    }
}
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _lrcObjects.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellIdentifier = @"cellIdentifier";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    LrcObject * lrcOb  =  [_lrcObjects objectAtIndex:indexPath.row];
    cell.textLabel.text = lrcOb.lrcStr;
    
    if (indexPath.row == _currentRow) {
        cell.textLabel.textColor = [UIColor redColor];
        cell.textLabel.font = [UIFont systemFontOfSize:18.0f];
    }else{
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
    }
    
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
