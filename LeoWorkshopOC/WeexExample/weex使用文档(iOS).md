# Weex集成到已有项目与使用

## 一、集成到iOS

### 第一步：添加依赖

使用[CocoaPods](https://cocoapods.org)
	
	target 'YourTarget' do
    platform :ios, '9.0'
    pod 'WeexSDK'   ## 建议使用WeexSDK新版本
	end
[Weex 官方地址](http://weex.apache.org/cn/guide/),其中包含SDK手动集成过程。

### 第二步：初始化

在文件<font color ="#dd00dd">AppDelegate.m</font> 文件中做初始化操作，一般会在<font color ="#dd00dd">didFinishLaunchingWithOptions</font>方法中添加，

	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary 	*)launchOptions {
		//初始化Weex
    	[NLWeexSDKManager initWeexSDK];
	}
DEMO中对初始化步骤进行了封装，在<font color ="#dd00dd">NLWeexSDKManager</font>文件中，<font color ="#dd00dd">initWeexSDK</font>方法中体现weex环境初始化

	+(void)initWeexSDK{
    //business configuration
	//    [WXAppConfiguration setAppGroup:@"AliApp"];
   	//    [WXAppConfiguration setAppName:@"WeexDemo"];
   	//    [WXAppConfiguration setAppVersion:[SKPublicParameter AppVersion]];
    
    //init sdk environment
    [WXSDKEngine initSDKEnvironment];
    
    [WXSDKEngine registerHandler:[NLWXImageLoaderDefaultImpl new] withProtocol:@protocol(WXImgLoaderProtocol)];
    
    [WXSDKEngine registerModule:@"weexToNative" withClass:NSClassFromString(@"NLWXEventModule")]; //注册weex交互事件
    [WXSDKEngine registerComponent:@"gifimage" withClass:NSClassFromString(@"NLWXGifImageComponent")]; // 注册weex交互组件
	#ifdef DEBUG
    //set the log level
    [WXLog setLogLevel: WXLogLevelLog];
	#endif
	}
* <font color ="#dd00dd">WXAppConfiguration</font> 文件中包含的配置项，如果无配置默认取系统或者SDK中设置的数据
* <font color ="#dd00dd">WXSDKEngine</font> 文件中主要是完成 *registerHandler*、
*registerModule*、*registerComponent* weex与native交互的协议、方法、组件的注册，其中 **topInstance** 方法会在全局中获取活跃的Instance，如果你需要在不能直接获取到 Instance 时，需要使用该方法获取
	
		WXSDKInstance * wxInstance = [WXSDKEngine topInstance];

获取到 Instance 后你可以使用 <font color ="#dd00dd">WXSDKInstance </font>文件中方法，如 *fireGlobalEvent* 主动发送数据给weex

* <font color ="#dd00dd"> WXLog</font> 文件中包含设置 weex输出日志的方法。**建议放在debug模式下使用**

### 第三步：渲染Weex Instance

Weex 支持整体页面渲染和部分渲染两种模式，你需要做的事情是用指定的 URL 渲染 Weex 的 view，然后添加到它的父容器上，父容器一般都是 viewController。DEMO中创建一个整体页面渲染的ViewController类<font color ="#dd00dd">NLWeexViewController</font>

```
	/**
 	初始化 weex 加载容器
 	*/
	- (void)weexRender{
    
    	[_wxInstance destroyInstance]; // weex instance 销毁
    	_wxInstance = [[WXSDKInstance alloc]init];
    	_wxInstance.viewController = self;
    
    	_wxInstance.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    
    	__weak typeof (self) weakSelf = self;

    	// 创建 weex View
   	 _wxInstance.onCreate = ^(UIView * view){
        	[weakSelf.weexView removeFromSuperview];
        	weakSelf.weexView = view;
        	[weakSelf.view addSubview:weakSelf.weexView];
    	};
    
    	// weex View 加载出错，此方法中可做降级处理。（如weex view加载失败，可用H5页面 或者 native View 替换显示）
   		_wxInstance.onFailed = ^(NSError * error){
		#ifdef DEBUG
        	DLog(@"-----------\n");
        	DLog(@"error:%@",[error domain]);
        	DLog(@"-----------\n");
		#endif
        	// 降级处理 (暂时关闭)
        	//        if (weakSelf.weexUrls.count > 1 ) {
        	//            weakSelf.placeholderH5View.h5UrlStr = weakSelf.weexUrls[0];
        	//            [weakSelf.view addSubview:weakSelf.placeholderH5View.view];
        	//        }
        
    	};
    	// weex View 加载完成
   		_wxInstance.renderFinish = ^(UIView *view){
        	DLog(@"renderFinish");
        	[weakSelf updateInstanceState:WeexInstanceAppear];
    	};
    
    	_wxInstance.updateFinish = ^(UIView *view ) {
        	DLog(@"updateFinish");
    	};
    
    	if ([self.weexUrl containsString:@"_wx_tpl"]) {
        	_weexUrls = [self.weexUrl componentsSeparatedByString:@"_wx_tpl="];
        
        	if (_weexUrls.count >1) {
           	 NSURL *url = [NSURL URLWithString:_weexUrls[1]];
            	[_wxInstance renderWithURL:url options:@{} data:nil];
        	}
    	}else{
        	NSURL *url = [NSURL URLWithString:self.weexUrl];
        	[_wxInstance renderWithURL:url options:@{} data:nil]; // 加载weex view 
    	}
   	}
```

* JavaScript刷新页面方法需要native配合造作，在文件<font color ="#dd00dd">NLWeexViewController</font>中

```
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self updateInstanceState:WeexInstanceAppear];
}
```
```
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self updateInstanceState:WeexInstanceDisappear];
}
```
```
/**
 weex 在加载完成时 和 离开页面时，调用

 @param state WXState
 */
- (void)updateInstanceState:(WXState)state
{
    if (_wxInstance && _wxInstance.state != state) {
        _wxInstance.state = state;
        NSString * temp = @"_root";
        if (state == WeexInstanceAppear) {
            [[WXSDKManager bridgeMgr] fireEvent:_wxInstance.instanceId ref:temp type:@"viewappear" params:nil domChanges:nil];
        }
        else if (state == WeexInstanceDisappear) {
            [[WXSDKManager bridgeMgr] fireEvent:_wxInstance.instanceId ref:temp type:@"viewdisappear" params:nil domChanges:nil];
        }
    }
}
```

### 第四步：销毁 Weex Instance

在 viewController 的 dealloc 阶段 销毁掉 Weex instance，释放内存，避免造成内存泄露。

```
- (void)dealloc{
	[self.wxInstance destroyInstance];
}
```

# 扩展iOS的功能

[Weex 扩展iOS的功能地址](http://weex.apache.org/cn/guide/extend-ios.html)
由于weex官方文档写的足够详细，易懂这里不赘述。下面结合DEMO的具体解析下用法
### 自定义module

自定义module换句话说就是native暴露方法给 JavaScript 使用，其中可完成传参和回调数据给JavaScript

DEMO中新建文件 <font color ="#dd00dd">NLWXEventModule</font>,其中<font color ="#dd00dd">NLWXEventModule.h</font>

```
#import <Foundation/Foundation.h>
#import <WeexSDK.h>
/**
 weex 主动调用
 */
@interface NLWXEventModule : NSObject<WXModuleProtocol>

@end
```
<font color ="#dd00dd">NLWXEventModule.m</font>

```
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
    
    callback(weexJsonStr, NO);
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
```

* *记得注册在NLWeexSDKManager文件中，initWeexSDK方法中注册Module*

```
[WXSDKEngine registerModule:@"weexToNative" withClass:NSClassFromString(@"NLWXEventModule")]; //注册weex交互事件
```

### Component 扩展

component扩展换句话说就是native实现一个功能带UI的组件，JavaScript 可以把它当做自己div等方法使用。

结合DEMO具体解析:

DEMO中新建文件<font color ="#dd00dd">NLWXGifImageComponent</font> 其中 <font color ="#dd00dd">NLWXGifImageComponent.h</font>文件中

```
#import "WXComponent.h"

/**
 gif图片显示组件拓展
 */
@interface NLWXGifImageComponent : WXComponent

@end
```
<font color ="#dd00dd">NLWXGifImageComponent.m</font>

```
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

/**
 Initializes a new component using the specified  properties
  @param attributes 参数中可取到 js中控件属性 value
 */
- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance {
    if(self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance]) {
        
        if (attributes[@"gifurl"]) {
            _gifUrl = attributes[@"gifurl"];
        }
    }
    return self;
}

/**
 weex主动传递显示的gif路径

 @param url gif路径
 */
- (void)getGifURL:(NSString *)url{
    _gifUrl = url;
    [self uploadGifImageView];
}

/**
 利用 SDWebImage 三方库 实现gif图片显示
 */
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
```

* *记得注册在NLWeexSDKManager文件中，initWeexSDK方法中注册Component*

```
[WXSDKEngine registerComponent:@"gifimage" withClass:NSClassFromString(@"NLWXGifImageComponent")]; // 注册weex交互组件
```

## 参考链接：

[于德志 (@halfrost)博客](https://halfrost.com/weex_event/)

[iOS 上的 FlexBox 布局](https://juejin.im/post/5a33a6926fb9a045104a8d3c)