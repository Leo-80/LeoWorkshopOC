//
//  NLLrcParseTool.m
//  LeoWorkshopOC
//
//  Created by leo on 2019/3/24.
//  Copyright © 2019 leo. All rights reserved.
//

#import "NLLrcParseTool.h"

@implementation NLLrcParseTool

static NLLrcParseTool * lrcParseTool = nil;

+ (instancetype)initLrcParseTool{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lrcParseTool = [[self alloc] init];
    });
    return lrcParseTool;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (lrcParseTool == nil) {
            lrcParseTool = [super allocWithZone:zone];
        }
    });
    return lrcParseTool;
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

/**
 通过文件名及文件类型解析歌词
 
 @param lrcFile 文件名
 @param type 文件类型
 @return 解析后歌词对象
 */
- (NSArray *)lrcToolWithLrcFile:(NSString *)lrcFile FileType:(NSString *)type{
    
    NSString *lrcPath = [[NSBundle mainBundle] pathForResource:lrcFile ofType:type];
    // 2.加载文件内容
    NSString *lrcString = [NSString stringWithContentsOfFile:lrcPath encoding:NSUTF8StringEncoding error:nil];
    NSMutableArray * perfectLrcArray = [self rmUselessLrc:lrcString];
    NSMutableArray * lrcObjectArray = [self baseParseLrc:perfectLrcArray];
    return lrcObjectArray;
}

/**
 通过歌词字符串解析歌词
 
 @param lrcStr 歌词字符串
 @return 解析后歌词对象
 */
- (NSMutableArray *)lrcToolWithLrcString:(NSString *)lrcStr{
    NSMutableArray * perfectLrcArray = [self rmUselessLrc:lrcStr];
    NSMutableArray * lrcObjectArray = [self baseParseLrc:perfectLrcArray];
    return lrcObjectArray;
}
/**
 获取头部歌词
 
 @param lrcArray 歌词数组
 @return headArray 头部歌词数组 [00:00.00]xxx headIndex结束的下标
 */
- (NSDictionary *)lrcHeadDict:(NSArray *)lrcArray {
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    NSDictionary * sDict = [self splitLrcArray:lrcArray];
    if (sDict.count > 0) {
        NSArray * headLrcArr = [sDict objectForKey:@"sLrcArray"];
        [dict setObject:headLrcArr forKey:@"headArray"];
        [dict setObject:[sDict objectForKey:@"index"] forKey:@"headIndex"];
    }
    return dict;
}

/**
 获取中部歌词
 
 @param lrcArray 歌词数组
 @param hIndex 头部结束下标
 @param eIndex 尾部结束下标
 @return 中部歌词数组
 */
- (NSMutableArray *)lrcMiddleArray:(NSArray *)lrcArray HeadIndex:(NSNumber *)hIndex  EndIndex:(NSNumber *)eIndex{
    NSMutableArray * lrcMiddleArr = [NSMutableArray array];
    if (lrcArray.count > 0) {
        NSIndexSet * indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange([hIndex intValue]+1, lrcArray.count -[hIndex intValue]-[eIndex intValue]-2)];
        lrcMiddleArr = (NSMutableArray *)[lrcArray objectsAtIndexes:indexSet];
    }
    return lrcMiddleArr;
}

/**
 获取尾部歌词
 
 @param lrcArray 歌词数组
 @return endArray 尾部歌词数组 [00:00.00]xxx endIndex结束的下标
 */
- (NSDictionary *)lrcEndDict:(NSArray *)lrcArray {
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    
    NSArray * lrcReverseArr = [[lrcArray reverseObjectEnumerator] allObjects];
    NSDictionary * sDict = [self splitLrcArray:lrcReverseArr];
    if (sDict.count > 0) {
        NSArray * endLrcArr = [sDict objectForKey:@"sLrcArray"];
        [dict setObject:endLrcArr forKey:@"endArray"];
        [dict setObject:[sDict objectForKey:@"index"] forKey:@"endIndex"];
    }
    return dict;
}

/**
 切割歌词算法
 
 @param lrcArray 歌词数组
 @return sLrcArray 歌词数组 [00:00.00]xxx index
 */
- (NSDictionary *)splitLrcArray:(NSArray *)lrcArray{
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    NSNumber * index = nil;
    NSMutableArray * sLrcArray = [NSMutableArray array];
    
    for (int i =0 ; i <lrcArray.count; i++) {
        NSString *lrcLineString = [lrcArray objectAtIndex:i];
        NSString *nxetLrcLineString = nil;
        if (i < lrcArray.count -1) {
            nxetLrcLineString = [lrcArray objectAtIndex:i+1];
        }
        if ([lrcLineString rangeOfString:@"["].location != NSNotFound) {
            NSString * lrcStr = [lrcLineString substringFromIndex:10];
            NSString * nextLrcStr = nil;
            if ([nxetLrcLineString length]>0) {
                nextLrcStr = [nxetLrcLineString substringFromIndex:10];
            }
            
            NSLog(@"lrcStr :%@",lrcStr);
            if ([lrcStr rangeOfString:@":"].location != NSNotFound || [lrcStr  rangeOfString:@"："].location != NSNotFound) {
                if ([nextLrcStr rangeOfString:@":"].location !=NSNotFound  || [nextLrcStr rangeOfString:@"："].location !=NSNotFound) {
                    index = [NSNumber numberWithInt:i];
                    [sLrcArray addObject:lrcLineString];
                }else{
                    break;
                }
            }
        }else{
            NSLog(@"music lrc music error");
            return nil;
        }
        
    }
    NSLog(@"sLrcArray : %@",sLrcArray);
    if (sLrcArray.count > 0) {
        [dict setObject:sLrcArray forKey:@"sLrcArray"];
        [dict setObject:index forKey:@"index"];
    }
    return dict;
}

/**
 去除无用歌词
 
 @param lrcString 原始歌词字符串
 @return 完美歌词数组
 */
- (NSMutableArray *)rmUselessLrc:(NSString *)lrcString{
    NSMutableArray * perfectLrcArray = [NSMutableArray array];
    
    NSArray *lrcLines = [lrcString componentsSeparatedByString:@"\n"];
    NSDictionary * headLrcDict = [self lrcHeadDict:lrcLines];
    NSDictionary * endLrcDict = [self lrcEndDict:lrcLines];
    
    NSMutableArray * lrcMiddleArrary = [self lrcMiddleArray:lrcLines HeadIndex:[headLrcDict objectForKey:@"headIndex"] EndIndex:[endLrcDict objectForKey:@"endIndex"]];
    
    NSArray * endLrcs = [endLrcDict objectForKey:@"endArray"];
    NSMutableArray * pEndLrcs = [NSMutableArray array];
    
    for (NSString *lrcLineStr in endLrcs) {
        
        NSRange startRange = [lrcLineStr rangeOfString:@"]"];
        NSString * lrcStr = [lrcLineStr substringFromIndex:10];
        NSRange stopRange;
        if ([lrcStr rangeOfString:@":"].location != NSNotFound) {
            stopRange = [lrcStr rangeOfString:@":"];
        }else if ([lrcStr rangeOfString:@"："].location != NSNotFound){
            stopRange = [lrcStr rangeOfString:@"："];
        }
        
        NSString * cLrcStr = [lrcLineStr substringWithRange:NSMakeRange(startRange.location+1, stopRange.location+1)];
        
        if ([self contrastLrc:lrcMiddleArrary ContranstLrcStr:cLrcStr]) {
            [pEndLrcs addObject:lrcLineStr];
        }
    }
    if (pEndLrcs.count > 0) {
        [lrcMiddleArrary addObjectsFromArray:pEndLrcs];
    }
    NSArray * headLrcs = [headLrcDict objectForKey:@"headArray"];
    NSMutableArray * pHeadLrcs = [NSMutableArray array];
    
    for (NSString *lrcLineStr in headLrcs) {
        
        NSRange startRange = [lrcLineStr rangeOfString:@"]"];
        NSString * lrcStr = [lrcLineStr substringFromIndex:10];
        NSRange stopRange;
        if ([lrcStr rangeOfString:@":"].location != NSNotFound) {
            stopRange = [lrcStr rangeOfString:@":"];
        }else if ([lrcStr rangeOfString:@"："].location != NSNotFound){
            stopRange = [lrcStr rangeOfString:@"："];
        }
        
        NSString * cLrcStr = [lrcLineStr substringWithRange:NSMakeRange(startRange.location+1, stopRange.location+1)];
        
        if ([self contrastLrc:lrcMiddleArrary ContranstLrcStr:cLrcStr]) {
            [pHeadLrcs addObject:lrcLineStr];
        }
    }
    
    perfectLrcArray  = pHeadLrcs;
    [perfectLrcArray addObjectsFromArray:lrcMiddleArrary];
    
    return perfectLrcArray;
}

/**
 尾部、头部歌词和中部歌词对比
 
 @param normlrcs 基准歌词数组
 @param cLrcStr 比对词
 @return 是否对比存在
 */
- (BOOL)contrastLrc:(NSArray *)normlrcs ContranstLrcStr:(NSString *)cLrcStr{
    
    int contrastCount = 0;
    
    for (NSString * normlrcStr in normlrcs) {
        if ([normlrcStr rangeOfString:cLrcStr].location !=NSNotFound) {
            contrastCount ++;
        }
    }
    
    if (contrastCount > 0) {
        return  YES;
    }
    
    return NO;
}

/**
 基础解析
 
 @param lrcLines 完美歌词数组
 @return lrctime  lrcStr
 */
- (NSMutableArray *)baseParseLrc:(NSArray *)lrcLines{
    
    NSMutableArray * lrcObjectArray = [NSMutableArray array];
    
    for (NSString *lrcLineString in lrcLines) {
        
        if ([lrcLineString rangeOfString:@"["].location != NSNotFound) {
            
            LrcObject * lrcOb = [[LrcObject alloc] init];
            
            NSRange startRange = [lrcLineString rangeOfString:@"["];
            //            NSLog(@"startRange : %lu %lu",(unsigned long)startRange.length,(unsigned long)startRange.location);
            NSRange stopRange = [lrcLineString rangeOfString:@"]"];
            //            NSLog(@"stopRange : %lu %lu",(unsigned long)stopRange.length,(unsigned long)stopRange.location);
            
            NSString * content = [lrcLineString substringWithRange:NSMakeRange(startRange.location+1, stopRange.location-startRange.location-1)];
            //            NSLog(@"content : %@",content);
            
            if ([content length] == 8) {
                
                NSString *minute = [content substringWithRange:NSMakeRange(0, 2)];
                NSString *second = [content substringWithRange:NSMakeRange(3, 2)];
                //                NSString *mm = [content substringWithRange:NSMakeRange(6, 2)];
                
                //                NSString *lrcTimeStr = [NSString stringWithFormat:@"%@:%@.%@",minute,second,mm];
                //                NSLog(@"lrcTime : %@",lrcTimeStr);
                NSNumber *lrcTime =[NSNumber numberWithInteger:[minute integerValue] * 60 + [second integerValue]];
                lrcOb.lrcTime = lrcTime;
                lrcOb.lrcStr = [lrcLineString substringFromIndex:10];
                //                NSLog(@"lrcTime : %@",lrcTime);
                //                    NSString * lrcStr = [lrcLineString substringFromIndex:10];
                //
                //                    if ([lrcStr rangeOfString:@":"].location != NSNotFound || [lrcStr rangeOfString:@"："].location != NSNotFound) {
                //                        continue;
                //                    }else{
                //                        lrcOb.lrcStr = lrcStr;
                //    //                    NSLog(@"lrcStr : %@",lrcStr);
                //                    }
            }
            [lrcObjectArray addObject:lrcOb];
        }else{
            NSLog(@"music lrc form error");
            return nil;
        }
    }
    return lrcObjectArray;
}
@end

@implementation LrcObject

@end
