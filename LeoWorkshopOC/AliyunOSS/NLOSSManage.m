//
//  NLOSSManage.m
//  LeoWorkshopOC
//
//  Created by leo on 2019/3/24.
//  Copyright © 2019 leo. All rights reserved.
//

#import "NLOSSManage.h"
#import <AliyunOSSiOS/OSSService.h>

static NSString * const AccessKeyId = @"LTAIsbbnXwkLRPEy";
static NSString * const AccessKeySecret = @"GcMx7KRxFz5m2n9U";
static NSString * const SecurityToken = @"Y1YRTKPOX4/IRAe9Oi7lLcO3hic=";
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
//    id<OSSCredentialProvider> credential = [[OSSStsTokenCredentialProvider alloc] initWithAccessKeyId:AccessKeyId secretKeyId:AccessKeySecret securityToken:SecurityToken];
//    id<OSSCredentialProvider> credential = [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithPlainTextAccessKey:AccessKeyId secretKey:AccessKeySecret];
//    id<OSSCredentialProvider> credential = [[OSSCustomSignerCredentialProvider alloc] initWithImplementedSigner:^NSString *(NSString *contentToSign, NSError *__autoreleasing *error) {
//        return [NSString stringWithFormat:@"OSS %@:%@", AccessKeyId, @"7dbWfTveFch6VUylQoIunbfb2qA="];
//    }];
    id<OSSCredentialProvider> credential = [[OSSAuthCredentialProvider alloc] initWithAuthServerUrl:STSURL];
    [OSSLog enableLog];
    OSSClientConfiguration * conf = [[OSSClientConfiguration alloc] init];
    conf.maxRetryCount = 3; // 网络请求异常重试次数
    conf.timeoutIntervalForRequest = 30; // 网络请求的超时时间
    conf.timeoutIntervalForResource = 24 * 60 *60; // 允许资源传输的最长时间
    self.client = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:credential clientConfiguration:conf];
}

- (void)uploadFilesForAliOSS:(NSString *)filePath{
//    NSString *lrcPath = @"Users/leo/Documents/LeoWorkshopOC/LeoWorkshopOC/LrcParseTool/1553073016455.txt"; //[[NSBundle mainBundle] pathForResource:@"1553073016455" ofType:@"txt"];
//
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    put.bucketName = bucketName;
    put.objectKey = @"video/"; //oss 文件夹路径
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
@end
