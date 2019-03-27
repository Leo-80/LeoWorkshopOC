//
//  NLPlayerTool.m
//  LeoWorkshopOC
//
//  Created by leo on 2019/3/27.
//  Copyright © 2019 leo. All rights reserved.
//

#import "NLPlayerTool.h"
#import <AVFoundation/AVFoundation.h>


@implementation NLPlayerTool
static NLPlayerTool * playerTool = nil;

+ (instancetype)initLrcParseTool{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        playerTool = [[self alloc] init];
    });
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
    return self;
}
- (id)copy{
    return self;
}
- (id)mutableCopy{
    return self;
}

@end
