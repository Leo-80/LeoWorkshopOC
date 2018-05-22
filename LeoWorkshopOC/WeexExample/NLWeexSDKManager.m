//
//  NLWeexSDKManager.m
//  WeexExample
//
//  Created by leo on 2018/5/21.
//  Copyright © 2018年 leo. All rights reserved.
//

#import "NLWeexSDKManager.h"
#import <WeexSDK.h>
#import "NLWXImageLoaderDefaultImpl.h"

@implementation NLWeexSDKManager
+(void)initWeexSDK{
    //business configuration
//        [WXAppConfiguration setAppGroup:@"AliApp"];
    //    [WXAppConfiguration setAppName:@"WeexDemo"];
    //    [WXAppConfiguration setAppVersion:[SKPublicParameter AppVersion]];
    
    //init sdk environment
    [WXSDKEngine initSDKEnvironment];
    
    [WXSDKEngine registerHandler:[NLWXImageLoaderDefaultImpl new] withProtocol:@protocol(WXImgLoaderProtocol)];
    
    [WXSDKEngine registerModule:@"weexToNative" withClass:NSClassFromString(@"NLWXEventModule")]; //注册weex交互事件
    [WXSDKEngine registerComponent:@"gifimage" withClass:NSClassFromString(@"NLWXGifImageComponent")]; // 注册weex交互组件
#ifdef DEBUG
    //set the log level
    [WXLog setLogLevel: WXLogLevelLog];
#endif
}
@end
