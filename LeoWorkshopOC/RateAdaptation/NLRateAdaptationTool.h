//
//  NLRateAdaptationTool.h
//  LeoWorkshopOC
//
//  Created by leo on 2019/5/31.
//  Copyright © 2019 leo. All rights reserved.
//

#ifndef NLRateAdaptationTool_h
#define NLRateAdaptationTool_h


#import <UIKit/UIKit.h>

#pragma 屏幕尺寸

#define kwidth [UIScreen mainScreen].bounds.size.width
#define kheight [UIScreen mainScreen].bounds.size.height

#pragma UI设计图尺寸

#define kBaseWidth 750
#define kBaseHeight 1334

//宏定义内联函数
#define Inline static inline
#pragma mark --设置比例
//实际屏幕宽度和设计图宽度的比例
Inline CGFloat RateWidth() {
    return kwidth/kBaseWidth;
}

//传入设计图尺寸标注，转化为实际屏幕尺寸标注
Inline CGFloat NLAdaption(CGFloat x) {
    return x * RateWidth();
}

#endif /* NLRateAdaptationTool_h */
