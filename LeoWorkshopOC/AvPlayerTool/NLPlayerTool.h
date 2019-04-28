//
//  NLPlayerTool.h
//  LeoWorkshopOC
//
//  Created by leo on 2019/3/27.
//  Copyright © 2019 leo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol playerToolDelegate <NSObject>
@optional
- (void)playMusicEnd;
@end

@interface NLPlayerTool : NSObject
@property (nonatomic, assign) id<playerToolDelegate> delegate;

/**
 初始化播放工具
 */
+ (instancetype)initPlayerTool;

/**
 指定时间播放

 @param startTime 设施时间（秒）
 */
- (void)seekToPlayTime:(NSTimeInterval)startTime;

/**
 播放
 */
- (void)playMusic:(NSString *)mStr;

/**
 暂停
 */
- (void)pauseMusic;
@end

NS_ASSUME_NONNULL_END
