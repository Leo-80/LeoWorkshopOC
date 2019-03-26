//
//  NLOSSManage.m
//  LeoWorkshopOC
//
//  Created by leo on 2019/3/24.
//  Copyright © 2019 leo. All rights reserved.
//

#import "NLOSSManage.h"
#import <AliyunOSSiOS/OSSService.h>

static NSString * const bucketName = @"hzweimo";
static NSString * const endpoint = @"oss-cn-beijing.aliyuncs.com";
static NSString * const STSURL = @"http://39.106.195.151:7080/";

@interface NLOSSManage ()
@property (nonatomic, strong) OSSClient * client;

@end
@implementation NLOSSManage

static NLOSSManage * ossManage = nil;

+ (instancetype)initOSSManage{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ossManage = [[self alloc] init];
    });
    [ossManage initOSSClient];
    return ossManage;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (ossManage == nil) {
            ossManage = [super allocWithZone:zone];
        }
    });
    return ossManage;
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


- (void)initOSSClient{
    
    id<OSSCredentialProvider> credential = [[OSSAuthCredentialProvider alloc] initWithAuthServerUrl:STSURL];
    [OSSLog enableLog];
    OSSClientConfiguration * conf = [[OSSClientConfiguration alloc] init];
    conf.maxRetryCount = 3; // 网络请求异常重试次数
    conf.timeoutIntervalForRequest = 30; // 网络请求的超时时间
    conf.timeoutIntervalForResource = 24 * 60 *60; // 允许资源传输的最长时间
    self.client = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:credential clientConfiguration:conf];
}

- (void)uploadFilesForAliOSS:(NSString *)filePath savePath:(NSString *)sPath{
    
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    put.bucketName = bucketName;
    put.objectKey = [NSString stringWithFormat:@"%@/%@_i.mp3",sPath,[self getNowTimeTimestamp]];//@"video/test.mp3"; //oss 文件夹路径
    put.uploadingFileURL = [NSURL fileURLWithPath:filePath];
//    put.uploadingData = <NSData *>; // 直接上传NSData
    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
    };
    OSSTask * putTask = [self.client putObject:put];
    [putTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            NSLog(@"upload object success!");
        } else {
            NSLog(@"upload object failed, error: %@" , task.error);
        }
        return nil;
    }];
    
    
}
- (void)downloadFileFromAliOSS{
    
    OSSGetObjectRequest * request = [OSSGetObjectRequest new];
    request.bucketName = bucketName;
    request.objectKey = @"20190301/1551436550024.txt"; // oss文件夹路径
    request.downloadProgress = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        NSLog(@"%lld, %lld, %lld", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    };
    OSSTask * getTask = [self.client getObject:request];
    [getTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            NSLog(@"download object success!");
            OSSGetObjectResult * getResult = task.result;
            NSLog(@"download result: %@", getResult.downloadedData);
        } else {
            NSLog(@"download object failed, error: %@" ,task.error);
        }
        return nil;
    }];
}

-(NSString *)getNowTimeTimestamp{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss SSS"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    //设置时区,这个对于时间的处理有时很重要
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    
    [formatter setTimeZone:timeZone];
    
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld",(long)[datenow timeIntervalSince1970]*1000];
    
    return timeSp;
}
@end
