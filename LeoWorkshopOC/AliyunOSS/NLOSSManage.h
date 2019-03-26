//
//  NLOSSManage.h
//  LeoWorkshopOC
//
//  Created by leo on 2019/3/24.
//  Copyright © 2019 leo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLOSSManage : NSObject
+ (instancetype)initOSSManage;
- (void)downloadFileFromAliOSS;
- (void)uploadFilesForAliOSS:(NSString *)filePath;
@end

NS_ASSUME_NONNULL_END
