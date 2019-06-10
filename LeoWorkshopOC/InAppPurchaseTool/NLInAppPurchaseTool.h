//
//  NLInAppPurchaseTool.h
//  gege
//
//  Created by leo on 2019/5/8.
//  Copyright © 2019 laoshi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLInAppPurchaseTool : NSObject
+ (instancetype)initInAppPurchaseTool;
- (void)requestInAppProduct:(NSArray *)productIds;
@end

NS_ASSUME_NONNULL_END
