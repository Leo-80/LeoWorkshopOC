//
//  NLThreadExampleViewController.m
//  LeoWorkshopOC
//
//  Created by leo on 2018/6/1.
//  Copyright © 2018年 leo. All rights reserved.
//

#import "NLThreadExampleViewController.h"
#import <UIColor+YYAdd.h>

#define ROW_COUNT 5  // 每行view个数
#define COLUMN_COUNT 3 // 一共几列
#define ROW_HEIGHT 60
#define ROW_WIDTH ROW_HEIGHT
#define ROW_SPACING 70
#define COLUMN_SPACING 20

/**
大家应该注意到在使用NSThread不管是使用
 + (void)detachNewThreadSelector:(SEL)selector toTarget:(id)target withObject:(id)argument
 - (instancetype)initWithTarget:(id)target selector:(SEL)selector object:(id)argument
 方法还是使用
 - (void)performSelectorOnMainThread:(SEL)aSelector withObject:(id)arg waitUntilDone:(BOOL)wait
 方法都只能传一个参数，由于更新图片需要传递UIImageView的索引和图片数据，因此这里不妨定义一个类保存图片索引和图片数据以供后面使用。
 */
#pragma mark NSThread 所需
@interface NLImageData ()
@property (nonatomic, assign) NSInteger image_index; // 图片索引
@property (nonatomic, strong) NSData * image_data;  // 图片数据
@end

@implementation NLImageData
@end

@interface NLThreadExampleViewController ()
@property (nonatomic, strong) NSMutableArray * imageViews; // 图片View 数组
@property (nonatomic, strong) NSMutableArray * threadList;
@end


@implementation NLThreadExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self layoutView];
}
- (void)layoutView{
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    
    
    __weak __typeof(self) wself = self;
    
    UIButton * _threadExerciseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _threadExerciseBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    _threadExerciseBtn.backgroundColor = [UIColor colorWithHexString:@"#F0F8FF"];
    [_threadExerciseBtn setTitle:@"NSThreadExercise" forState:UIControlStateNormal];
    [_threadExerciseBtn setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    [_threadExerciseBtn addTarget:self action:@selector(threadExerciseBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_threadExerciseBtn];

    [_threadExerciseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wself.view.mas_top).offset(80);
        make.centerX.equalTo(wself.view);
        make.size.mas_equalTo(CGSizeMake(200, 40));
    }];
    
    UIButton * _nsOperationExerciseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _nsOperationExerciseBtn.titleLabel.font = [UIFont systemFontOfSize:14];
     _nsOperationExerciseBtn.backgroundColor = [UIColor colorWithHexString:@"#F0FFF0"];
    [_nsOperationExerciseBtn setTitle:@"nsOperationExerciseBtn" forState:UIControlStateNormal];
    [_nsOperationExerciseBtn setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    [_nsOperationExerciseBtn addTarget:self action:@selector(nsOperationExerciseBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_nsOperationExerciseBtn];

    [_nsOperationExerciseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_threadExerciseBtn.mas_bottom).offset(20);
        make.centerX.equalTo(wself.view);
        make.size.mas_equalTo(CGSizeMake(200, 40));
    }];
    
    UIButton * _GCDExerciseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _GCDExerciseBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    _GCDExerciseBtn.backgroundColor = [UIColor colorWithHexString:@"#F0FFFF"];
    [_GCDExerciseBtn setTitle:@"GCDExerciseBtn" forState:UIControlStateNormal];
    [_GCDExerciseBtn setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    [_GCDExerciseBtn addTarget:self action:@selector(GCDExerciseBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_GCDExerciseBtn];

    [_GCDExerciseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_nsOperationExerciseBtn.mas_bottom).offset(20);
        make.centerX.equalTo(wself.view);
        make.size.mas_equalTo(CGSizeMake(200, 40));
    }];
    
    UIButton * stopLoadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    stopLoadBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    stopLoadBtn.backgroundColor = [UIColor colorWithHexString:@"#FF4500"];
    [stopLoadBtn setTitle:@"stoploadBtn" forState:UIControlStateNormal];
    [stopLoadBtn setTitleColor:[UIColor colorWithHexString:@"#FFFAF0"] forState:UIControlStateNormal];
    [stopLoadBtn addTarget:self action:@selector(stopLoadBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stopLoadBtn];
    
    [stopLoadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_GCDExerciseBtn.mas_bottom).offset(20);
        make.centerX.equalTo(wself.view);
        make.size.mas_equalTo(CGSizeMake(200, 40));
    }];
    
    UIView * allImageDisplayView = [[UIView alloc] init];
    allImageDisplayView.backgroundColor = [UIColor colorWithHexString:@"FFC0CB"];
    [self.view addSubview:allImageDisplayView];
    [allImageDisplayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(stopLoadBtn.mas_bottom).offset(20);
        make.bottom.equalTo(wself.view.mas_bottom);
        make.left.equalTo(wself.view.mas_left);
        make.right.equalTo(wself.view.mas_right);
    }];
    
    _imageViews = [NSMutableArray array];
    
    for (int r = 0; r < ROW_COUNT; r++) {
        for (int c = 0; c < COLUMN_COUNT; c++) {
            UIImageView * imageView = [[UIImageView alloc] init];
            CGRect rect = CGRectMake(c*ROW_WIDTH + (c*ROW_SPACING), r * ROW_HEIGHT+(r*COLUMN_SPACING), ROW_WIDTH, ROW_HEIGHT);
            imageView.frame = rect;
            imageView.contentMode =  UIViewContentModeScaleAspectFit;
            [allImageDisplayView addSubview:imageView];
            [_imageViews addObject:imageView];
        }
    }
    
}

- (void)threadExerciseBtnAction{
    DLog(@"threadExerciseBtnAction");
//    [self thread_loadImageWithMultiThread];
    [self thread_loadLastImageViewWithMultiThread];
}
- (void)nsOperationExerciseBtnAction{
    DLog(@"nsOperationExerciseBtnAction");
}
- (void)GCDExerciseBtnAction{
    DLog(@"GCDExerciseBtnAction");
}

/*****NSThread Example******/

/**
 使用NSThread在进行多线程开发过程中操作比较简单，
 但是要控制线程执行顺序并不容易（前面万不得已采用了休眠的方法），
 另外在这个过程中如果打印线程会发现循环几次就创建了几个线程，
 这在实际开发过程中是不得不考虑的问题，因为每个线程的创建也是相当占用系统开销的。
 */
#pragma mark 将图片显示到界面
-(void)thread_updateImage:(NLImageData *)imageData{
    UIImage *image=[UIImage imageWithData:imageData.image_data];
    UIImageView *imageView= _imageViews[imageData.image_index];
    imageView.image=image;
}

#pragma mark 请求图片数据
-(NSData *)thread_requestData:(NSInteger)index{
    /**通过休眠的方式 使最后一张图片优先加载 （除非网速特别差）**/
    if (index!=(ROW_COUNT*COLUMN_COUNT-1)) {
        [NSThread sleepForTimeInterval:2.0];
    }
    /**通过休眠的方式 使最后一张图片优先加载（除非网速特别差）**/
    
    /**通过休眠的方式 使停止加载方法能够看出效果**/
    if (index % 2 == 0) {
        [NSThread sleepForTimeInterval:1.0];
    }
    /**通过休眠的方式 使停止加载方法能够看出效果**/
    
    NSString * urlStr = [NSString stringWithFormat:@"https://images.cnblogs.com/cnblogs_com/kenshincui/613474/o_%li.jpg",index];
    NSURL *url=[NSURL URLWithString:urlStr];
    NSData *data=[NSData dataWithContentsOfURL:url];
    return data;
}

#pragma mark 加载图片
-(void)thread_loadImage:(NSNumber *)index{
    //    NSLog(@"%i",i);
    //currentThread方法可以取得当前操作线程
    NSLog(@"current thread:%@",[NSThread currentThread]);
    
    NSInteger i=[index integerValue];
    
    DLog(@"%li",(long)i);//未必按顺序输出
    
    NSData *data= [self thread_requestData:i];
    
    /**如果当前线程处于取消状态，则退出当前线程**/
    NSThread *currentThread=[NSThread currentThread];
    //    如果当前线程处于取消状态，则退出当前线程
    if (currentThread.isCancelled) {
        DLog(@"thread(%@) will be cancelled!",currentThread);
        [NSThread exit];//取消当前线程
    }
    /**如果当前线程处于取消状态，则退出当前线程**/
    
    NLImageData *imageData=[[NLImageData alloc]init];
    imageData.image_index=i;
    imageData.image_data=data;
    [self performSelectorOnMainThread:@selector(thread_updateImage:) withObject:imageData waitUntilDone:YES];
}

#pragma mark 多线程下载图片
-(void)thread_loadImageWithMultiThread{
    //创建多个线程用于填充图片
    for (int i=0; i<ROW_COUNT*COLUMN_COUNT; ++i) {
        NSThread *thread=[[NSThread alloc]initWithTarget:self selector:@selector(thread_loadImage:) object:[NSNumber numberWithInteger:i]];
        thread.name=[NSString stringWithFormat:@"myThread%i",i];//设置线程名称
        [thread start];
    }
}

#pragma mark 多线程下载图片通过修改线程优先级方式从最后一张开始加载
/**
从上面的运行效果大家不难发现，图片并未按顺序加载，
 原因有两个：第一，每个线程的实际执行顺序并不一定按顺序执行（虽然是按顺序启动）；
 第二，每个线程执行时实际网络状况很可能不一致。当然网络问题无法改变，只能尽可能让网速更快，
 但是可以改变线程的优先级，让15个线程优先执行某个线程。线程优先级范围为0~1，
 值越大优先级越高，每个线程的优先级默认为0.5。修改图片下载方法如下，
 改变最后一张图片加载的优先级，这样可以提高它被优先加载的几率，但是它也未必就第一个加载。
 因为首先其他线程是先启动的，其次网络状况我们没办法修改
 */
- (void)thread_loadLastImageViewWithMultiThread{
    
   _threadList = [NSMutableArray array];
    int count=ROW_COUNT*COLUMN_COUNT;
    //创建多个线程用于填充图片
    for (int i=0; i<count; ++i) {
        //        [NSThread detachNewThreadSelector:@selector(loadImage:) toTarget:self withObject:[NSNumber numberWithInt:i]];
        NSThread *thread=[[NSThread alloc]initWithTarget:self selector:@selector(thread_loadImage:) object:[NSNumber numberWithInt:i]];
        thread.name=[NSString stringWithFormat:@"myThread%i",i];//设置线程名称
        if(i==(count-1)){
            thread.threadPriority=1.0; //提升最后一张图片加载的优先权
        }else{
            thread.threadPriority=0.0;
        }
        [_threadList addObject:thread];
    }
    
    for (int i=0; i<count; i++) {
        NSThread *thread=_threadList[i];
        [thread start];
    }
}

#pragma mark 停止加载图片

/**
 线程状态分为isExecuting（正在执行）、isFinished（已经完成）、isCancellled（已经取消）三种。
 其中取消状态程序可以干预设置，只要调用线程的cancel方法即可。
 但是需要注意在主线程中仅仅能设置线程状态，并不能真正停止当前线程，如果要终止线程必须在线程中调用exist方法，这是一个静态方法，调用该方法可以退出当前线程。
 假设在图片加载过程中点击停止按钮让没有完成的线程停止加载，可以改造程序如下：
 */
- (void)stopLoadBtnAction{
    
    for (int i=0; i<ROW_COUNT*COLUMN_COUNT; i++) {
        NSThread *thread= _threadList[i];
        //判断线程是否完成，如果没有完成则设置为取消状态
        //注意设置为取消状态仅仅是改变了线程状态而言，并不能终止线程
        if (!thread.isFinished) {
            [thread cancel];
        }
    }
}
/******NSOperation Example*****/

/*****GCD Example******/



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
