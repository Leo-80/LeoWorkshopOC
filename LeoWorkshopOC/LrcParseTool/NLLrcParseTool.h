//
//  NLLrcParseTool.h
//  LeoWorkshopOC
//
//  Created by leo on 2019/3/24.
//  Copyright © 2019 leo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLLrcParseTool : NSObject
+ (instancetype)initLrcParseTool;
- (NSArray *)lrcToolWithLrcFile:(NSString *)lrcFile FileType:(NSString *)type;
- (NSMutableArray *)lrcToolWithLrcString:(NSString *)lrcStr;
@end

@interface LrcObject : NSObject
@property (nonatomic, strong) NSNumber * lrcTime;
@property (nonatomic, copy) NSString * lrcStr;
@end
NS_ASSUME_NONNULL_END
