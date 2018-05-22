//
//  NLWXEventModule.m
//  WeexExample
//
//  Created by leo on 2018/5/21.
//  Copyright © 2018年 leo. All rights reserved.
//

#import "NLWXEventModule.h"

@implementation NLWXEventModule

WX_EXPORT_METHOD_SYNC(@selector(getgobaltoken:callback:))  // 同步方法
WX_EXPORT_METHOD_SYNC(@selector(gotomyter:))
WX_EXPORT_METHOD(@selector(gotoString:)) // 异步方法

/**
 weex 主动调用方法，完成数据传递和回调

 @param weexJsonStr 交互数据
 @param callback 回调返回给weex所需数据
 */
- (void)getgobaltoken:(NSString *)weexJsonStr callback:(WXModuleKeepAliveCallback)callback{
    
    callback(weexJsonStr,YES);
}

/**
 weex 主动调用方法，完成数据传递

 @param urlstr 交互数据
 */
- (void)gotomyter:(NSString *)urlstr{
    NSLog(@"urlstr :%@",urlstr);
}

/**
 weex 主动调用方法,完成数据传递 （异步）

 @param str 交互数据
 */
- (void)gotoString:(NSString *)str{
    NSLog(@"str : %@", str);
}

@end
