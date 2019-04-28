//
//  NLPlayerTool.m
//  LeoWorkshopOC
//
//  Created by leo on 2019/3/27.
//  Copyright © 2019 leo. All rights reserved.
//

#import "NLPlayerTool.h"
#import <AVFoundation/AVFoundation.h>

@interface NLPlayerTool()
@property (nonatomic, strong) AVPlayer * player;
@property (nonatomic, assign) BOOL isAfreshPlay;
@property (nonatomic, strong) AVPlayerItem * mItem;
@property (nonatomic, strong) NSString * curMusicPath;
@end

@implementation NLPlayerTool
static NLPlayerTool * playerTool = nil;

+ (instancetype)initPlayerTool{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        playerTool = [[self alloc] init];
    });
    [playerTool initMusic];
    return playerTool;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (playerTool == nil) {
            playerTool = [super allocWithZone:zone];
        }
    });
    return playerTool;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playMusicEnd: ) name:AVPlayerItemDidPlayToEndTimeNotification object:nil]; //播放结束监听
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playMusicBackground:) name:UIApplicationWillTerminateNotification object:nil]; // 程序退到后台
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playMusicIntermit:) name:AVAudioSessionInterruptionNotification object:nil];//监听播放音频中断
        self.isAfreshPlay = YES;
    }
    return self;
}
- (id)copy{
    return self;
}
- (id)mutableCopy{
    return self;
}
- (void)initMusic{
    
    _player = [[AVPlayer alloc] init];
    __weak typeof(self)wSelf = self;
    [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, NSEC_PER_SEC) queue:NULL usingBlock:^(CMTime time) {
        
        CGFloat currentTime = CMTimeGetSeconds(wSelf.player.currentItem.currentTime);
        NSLog(@"currentTime : %f",currentTime);
        
    }];
    
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

- (void)playMusic:(NSString *)mStr{
    if (![_curMusicPath isEqualToString:mStr]) {
        self.isAfreshPlay = YES;
    }
    _curMusicPath = mStr;
    if (self.isAfreshPlay) {
        _mItem = nil;
        NSURL * mUrl = [NSURL URLWithString:mStr];
        _mItem = [AVPlayerItem playerItemWithURL:mUrl];
        [_mItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [_player replaceCurrentItemWithPlayerItem:_mItem];
    }
    if (_player.rate == 0) {
        [_player play];
    }
}

- (void)pauseMusic{
    if (_player.rate == 1.0) {
        [_player pause];
        self.isAfreshPlay = NO;
    }
}

- (void)playMusicEnd:(NSNotification *)noti{
    NSLog(@"播放结束");
    self.isAfreshPlay = YES;
    if ([_delegate conformsToProtocol:@protocol(playerToolDelegate)] && [_delegate respondsToSelector:@selector(playMusicEnd)]) {
         [self.delegate playMusicEnd];
    }
}
- (void)playMusicBackground:(NSNotification *)noti{
    NSLog(@"后台播放");
}
- (void)playMusicIntermit:(NSNotification *)noti{
    NSLog(@"播放中断");
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
@end
