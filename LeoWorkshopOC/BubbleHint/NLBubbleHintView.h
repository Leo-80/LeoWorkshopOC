//
//  NLBubbleHintView.h
//  gege
//
//  Created by leo on 2019/6/17.
//  Copyright © 2019 laoshi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLBubbleHintView : UIView
@property (nonatomic, strong) UIImageView * bubbleBgImg;
@property (nonatomic, strong) UILabel * hintTextLable;
- (void)showBubbleHintView:(NSString *)hintStr;
@end

NS_ASSUME_NONNULL_END
