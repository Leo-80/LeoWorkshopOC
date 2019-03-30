//
//  NLAudioRecordTool.m
//  LeoWorkshopOC
//
//  Created by leo on 2019/3/25.
//  Copyright © 2019 leo. All rights reserved.
//

#import "NLAudioRecordTool.h"

#import <AVFoundation/AVFoundation.h>
//#import <AVFoundation/AVAudioSettings.h>
#import "lameTool/lame.h"

@interface NLAudioRecordTool ()
@property (nonatomic, strong) AVAudioRecorder * audioRecorder;
@property (nonatomic, strong) AVAudioPlayer * audioPlayer;
@end

@implementation NLAudioRecordTool

static NLAudioRecordTool * audioRecordTool = nil;

+ (instancetype)initAudioRecorderTool{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        audioRecordTool = [[self alloc] init];
    });
    return audioRecordTool;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (audioRecordTool == nil) {
            audioRecordTool = [super allocWithZone:zone];
        }
    });
    return audioRecordTool;
}
- (instancetype)init{
    self = [super init];
    return self;
}
- (id)copy{
    return self;
}
- (id)mutableCopy{
    return self;
}

- (NSURL *)setSavePath:(NSString *)fileName{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileName];
    NSURL *url = [NSURL URLWithString:path];
    NSLog(@"record path %@",url);
    return url;
}
- (NSString *)getAudioFilePath:(NSString *)fileName{
    
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileName];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:path]) {
        return nil;
    }
    
    return path;
}
- (void)initAudioRecord:(NSString *)fileName{
    
    NSDictionary * recordSettings = @{AVFormatIDKey:@(kAudioFormatLinearPCM),AVSampleRateKey:@(11025.0),AVNumberOfChannelsKey:@(2),AVEncoderAudioQualityKey:@(AVAudioQualityMin)};
    if (!_audioRecorder) {
        self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:[self setSavePath:fileName] settings:recordSettings error:nil];
    }
}

- (void)prepareRecord{
    [self.audioRecorder prepareToRecord];
}
- (void)beginRecord{
    [self.audioRecorder record];
}
- (void)stopRecord{
    [self.audioRecorder stop];
}
- (NSString *)audioRecordTypeToMP3:(NSString *)filePath isDelSourceFile:(BOOL)isDel{
    // 输入路径
    NSString *inPath = filePath;
    // 判断输入路径是否存在
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:filePath]) {
        NSLog(@"文件不存在");
    }
    // 输出路径
    NSString *outPath = [[filePath stringByDeletingPathExtension] stringByAppendingString:@".mp3"];
    
    @try {
        int read, write;
        FILE *pcm = fopen([inPath cStringUsingEncoding:1], "rb");//被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);
        FILE *mp3 = fopen([outPath cStringUsingEncoding:1], "wb");//生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        // 初始化lame编码器
        lame_t lame = lame_init();
        // 设置lame mp3编码的采样率 / 声道数 / 比特率
        lame_set_in_samplerate(lame, 11025.0);
        lame_set_num_channels(lame,2);
        lame_set_out_samplerate(lame, 11025.0);
        lame_set_brate(lame, 8);
        // MP3音频质量.0~9.其中0是最好,非常慢,9是最差.
        lame_set_quality(lame, 7);
        
        // 设置mp3的编码方式
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            size_t size = (size_t)(2 * sizeof(short int));
            read = fread(pcm_buffer, size, PCM_SIZE, pcm);
            if (read == 0) {
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            } else {
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            }
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        // 转码完成
        if (isDel) {
            NSError * error;
            [fm removeItemAtPath:filePath error:&error];
            if (error == nil) {
                NSLog(@"原文件删除成功！");
            }
        }
        return outPath;
    }
}

- (void)playRecord:(NSString *)rPath{
    
    if (rPath && !_audioPlayer) {
        NSURL * recordUrl = [NSURL fileURLWithPath:rPath];
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:recordUrl error:nil];
    }
    [_audioPlayer prepareToPlay];
    [_audioPlayer play];
}

- (void)pausePlayRecord{
    [_audioPlayer pause];
}
- (void)stopPlayRecord{
    [_audioPlayer stop];
}
@end

