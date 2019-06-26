//
//  NLBubbleHintView.m
//  gege
//
//  Created by leo on 2019/6/17.
//  Copyright © 2019 laoshi. All rights reserved.
//

#import "NLBubbleHintView.h"
#define Screen_Width        [UIScreen mainScreen].bounds.size.width
@implementation NLBubbleHintView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (UIImageView *)bubbleBgImg{
    if (!_bubbleBgImg) {
        
        _bubbleBgImg = [[UIImageView alloc] init];
    }
    return _bubbleBgImg;
}
- (UILabel *)hintTextLable{
    if (!_hintTextLable) {
        _hintTextLable = [[UILabel alloc] init];
        _hintTextLable.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10.0f];
        _hintTextLable.textColor = [UIColor redColor];
    }
    return _hintTextLable;
}
- (instancetype) init{
    self = [super init];
    if (self) {
        [self setUpViews];
    }
    return self;
}
- (void)setUpViews{
    [self addSubview:self.bubbleBgImg];
    [self.bubbleBgImg addSubview:self.hintTextLable];
}

- (void)showBubbleHintView:(NSString *)hintStr{
    self.hintTextLable.text = hintStr;
    CGSize hintTextSize = [self.hintTextLable sizeThatFits:CGSizeMake(Screen_Width, MAXFLOAT)];
    
    UIImage * bubbleImg = [UIImage imageNamed:@"room_lable_white"];
    bubbleImg = [self dc_stretchLeftAndRightWithContainerSize:CGSizeMake(self.frame.size.width+20, self.frame.size.height) image:bubbleImg];
    
    self.bubbleBgImg.image = bubbleImg;
    
    CGFloat bubbleMinWidth = bubbleImg.size.width;
    
    CGFloat width;
    
    if (hintTextSize.width > bubbleMinWidth) {
        width = hintTextSize.width;
    }else{
        width = bubbleMinWidth;
    }
    
    CGFloat bubbleMinHeight = 22;
    CGFloat height;
    
    if (hintTextSize.height > bubbleMinHeight) {
        height = hintTextSize.height;
    }else{
        height = bubbleMinHeight;
    }
    
    self.hintTextLable.frame = CGRectMake(8,5, hintTextSize.width,hintTextSize.height);
//    self.hintTextLable.backgroundColor = [UIColor brownColor];
     self.bubbleBgImg.frame = CGRectMake(0, 0, self.hintTextLable.frame.origin.x+self.hintTextLable.frame.size.height+8,self.hintTextLable.frame.origin.y+self.hintTextLable.frame.size.height+8);
}

- (UIImage *)dc_stretchLeftAndRightWithContainerSize:(CGSize)imageViewSize image:(UIImage *)originImage {
    
    CGSize imageSize = originImage.size;
    CGSize bgSize = CGSizeMake(imageViewSize.width, imageViewSize.height); //imageView的宽高取整，否则会出现横竖两条缝
    
    UIImage *image = [originImage stretchableImageWithLeftCapWidth:floorf(imageSize.width * 0.8) topCapHeight:imageSize.height * 0.5];
    CGFloat tempWidth = (bgSize.width)/2 + (imageSize.width)/2;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake((NSInteger)tempWidth, (NSInteger)bgSize.height), NO, [UIScreen mainScreen].scale);
    
    [image drawInRect:CGRectMake(0, 0, (NSInteger)tempWidth, (NSInteger)bgSize.height)];
    
    UIImage *firstStrechImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *secondStrechImage = [firstStrechImage stretchableImageWithLeftCapWidth:floorf(imageSize.width * 0.2) topCapHeight:imageSize.height * 0.5];
    
    return secondStrechImage;
}
@end
