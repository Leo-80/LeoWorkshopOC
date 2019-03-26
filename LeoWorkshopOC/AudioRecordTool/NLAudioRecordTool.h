//
//  NLAudioRecordTool.h
//  LeoWorkshopOC
//
//  Created by leo on 2019/3/25.
//  Copyright © 2019 leo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLAudioRecordTool : NSObject
+ (instancetype)initAudioRecorderTool;
- (NSString *)getAudioFilePath:(NSString *)fileName;
- (void)initAudioRecord:(NSString *)fileName;
- (void)prepareRecord;
- (void)beginRecord;
- (void)stopRecord;
- (NSString *)audioRecordTypeToMP3:(NSString *)filePath isDelSourceFile:(BOOL)isDel;
@end

NS_ASSUME_NONNULL_END
