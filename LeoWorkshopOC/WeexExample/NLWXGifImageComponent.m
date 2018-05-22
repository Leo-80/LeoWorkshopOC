//
//  NLWXGifImageComponent.m
//  WeexExample
//
//  Created by leo on 2018/5/21.
//  Copyright © 2018年 leo. All rights reserved.
//

#import "NLWXGifImageComponent.h"
#import <SDWebImage/FLAnimatedImageView+WebCache.h>
#import <WeexSDK.h>

@interface NLWXGifImageComponent()
@property (nonatomic, strong) NSString * gifUrl;
@property (nonatomic, strong) FLAnimatedImageView *gifImageView;
@end
@implementation NLWXGifImageComponent
WX_EXPORT_METHOD(@selector(getGifURL:))

- (FLAnimatedImageView *)gifImageView{
    if (!_gifImageView) {
        _gifImageView = [[FLAnimatedImageView alloc] init];
        _gifImageView.frame = self.view.bounds;
    }
    return _gifImageView;
}

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance {
    if(self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance]) {
        
        if (attributes[@"gifurl"]) {
            _gifUrl = attributes[@"gifurl"];
        }
    }
    return self;
}
- (void)getGifURL:(NSString *)url{
    _gifUrl = url;
    [self uploadGifImageView];
}
- (void)uploadGifImageView{
    
    [self.view addSubview:self.gifImageView];
    
    __weak typeof (self) weakSelf = self;
    NSString *imagePath                = _gifUrl;
    NSData   *gifImageData             = [self imageDataFromDiskCacheWithKey:imagePath];
    if (gifImageData) {
        [self animatedImageView:self.gifImageView data:gifImageData];
    }else{
        NSURL *url = [NSURL URLWithString:imagePath];
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:url
                                                              options:0
                                                             progress:nil
                                                            completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                                
                                                                [[[SDWebImageManager sharedManager] imageCache] storeImage:image imageData:data forKey:url.absoluteString toDisk:YES completion:^{
                                                                    [weakSelf animatedImageView:self.gifImageView data:data];
                                                                }];
                                                            }];
    }
}
- (void)animatedImageView:(FLAnimatedImageView *)imageView data:(NSData *)data {
    
    FLAnimatedImage *gifImage = [FLAnimatedImage animatedImageWithGIFData:data];
    imageView.frame           = CGRectMake(0, 0, gifImage.size.width, gifImage.size.height);
    imageView.animatedImage   = gifImage;
    imageView.alpha           = 0.f;
    
    [UIView animateWithDuration:1.f animations:^{
        
        imageView.alpha = 1.f;
    }];
}

- (NSData *)imageDataFromDiskCacheWithKey:(NSString *)key {
    
    NSString *path = [[[SDWebImageManager sharedManager] imageCache] defaultCachePathForKey:key];
    return [NSData dataWithContentsOfFile:path];
}
@end
