//
//  NLThreadExampleViewController.m
//  LeoWorkshopOC
//
//  Created by leo on 2018/6/1.
//  Copyright © 2018年 leo. All rights reserved.
//  原文地址: http://www.cnblogs.com/kenshincui/p/3983982.html#!comments
//

#import "NLThreadExampleViewController.h"
#import <UIColor+YYAdd.h>

#define ROW_COUNT 5  // 每行view个数
#define COLUMN_COUNT 3 // 一共几列
#define ROW_HEIGHT 60
#define ROW_WIDTH ROW_HEIGHT
#define ROW_SPACING 70
#define COLUMN_SPACING 20
#define IMAGE_COUNT 9

typedef NS_ENUM(NSInteger,ThreadExampleType){
    ThreadExampleTypeNSThread,
    ThreadExampleTypeNSOperation,
    ThreadExampleTypeGCD,
    ThreadExampleTypeNSLock,
    ThreadExampleTypeSynchronized, //代码块
    ThreadExampleTypeSemaphore,    // 型号量
    ThreadExampleTypeCondition,    // 控制线程通信
};

#define CURRENT_EXAMPLE_TYPE ThreadExampleTypeNSThread



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
@property (atomic, strong) NSMutableArray * imageURLs; // 图片 url 数组
@property (nonatomic, strong) NSLock * thread_lock; // 同步锁
@property (nonatomic, strong) dispatch_semaphore_t  semaphore; // 信号量
@property (atomic,assign) NSInteger currentIndex; // 当前加载的图片索引
@property (nonatomic, strong) NSCondition * condition; // 控制线程
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
    [stopLoadBtn setTitle:@"stoploadBtn/createImage" forState:UIControlStateNormal];
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
    
    //TODO: 但测试NSCondition(控制线程通信)时，需注释初始化方法
    _imageURLs = [NSMutableArray array];
    if (CURRENT_EXAMPLE_TYPE != ThreadExampleTypeCondition) {
        
        for (int i = 0 ; i < IMAGE_COUNT; i++) {
            NSString * urlStr = [NSString stringWithFormat:@"https://images.cnblogs.com/cnblogs_com/kenshincui/613474/o_%i.jpg",i];
            [_imageURLs addObject:urlStr];
        }
        
    }
    
    // MARK: 初始化锁对象
    _thread_lock = [[NSLock alloc] init];
    // MARK: 初始化型号量
    // FIXME: 为什么初始化的时候 信号量为 1
    _semaphore = dispatch_semaphore_create(1);
    // MARK: 初始化NSCondition
    _condition=[[NSCondition alloc]init];
    
}

- (void)threadExerciseBtnAction{
    DLog(@"threadExerciseBtnAction");
//    [self thread_loadImageWithMultiThread];
    [self thread_loadLastImageViewWithMultiThread];
}
- (void)nsOperationExerciseBtnAction{
    DLog(@"nsOperationExerciseBtnAction");
//    [self operation_loadImageWithMultiThread];
    [self operation_loadLastImageViewWithMultiThread];
}
- (void)GCDExerciseBtnAction{
    DLog(@"GCDExerciseBtnAction");
//    [self GCD_loadImageWithMultiThread];
//    [self lock_loadImageWithMultiThread];
    [self condition_loadImageWithMultiThread];
    
}
#pragma mark -----------NSThread Example--------------
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

/**
 扩展--NSObject分类扩展方法
 为了简化多线程开发过程，苹果官方对NSObject进行分类扩展(本质还是创建NSThread)，对于简单的多线程操作可以直接使用这些扩展方法。
 
 - (void)performSelectorInBackground:(SEL)aSelector withObject:(id)arg：在后台执行一个操作，本质就是重新创建一个线程执行当前方法。
 
 - (void)performSelector:(SEL)aSelector onThread:(NSThread *)thr withObject:(id)arg waitUntilDone:(BOOL)wait：在指定的线程上执行一个方法，需要用户创建一个线程对象。
 
 - (void)performSelectorOnMainThread:(SEL)aSelector withObject:(id)arg waitUntilDone:(BOOL)wait：在主线程上执行一个方法（前面已经使用过）。
 
 例如前面加载图多个图片的方法，可以改为后台线程执行：
 **/
-(void)thread_loadImageWithMultiThread{
    //创建多个线程用于填充图片
//    for (int i=0; i<ROW_COUNT*COLUMN_COUNT; ++i) {
//        NSThread *thread=[[NSThread alloc]initWithTarget:self selector:@selector(thread_loadImage:) object:[NSNumber numberWithInteger:i]];
//        thread.name=[NSString stringWithFormat:@"myThread%i",i];//设置线程名称
//        [thread start];
//    }
    
    //创建多个线程用于填充图片
    int count = ROW_COUNT*COLUMN_COUNT;
    
    for (int i=0; i<count; ++i) {
        [self performSelectorInBackground:@selector(thread_loadImage:) withObject:[NSNumber numberWithInteger:i]];
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
    
    if (CURRENT_EXAMPLE_TYPE != ThreadExampleTypeCondition) {
        for (int i=0; i<ROW_COUNT*COLUMN_COUNT; i++) {
            NSThread *thread= _threadList[i];
            //判断线程是否完成，如果没有完成则设置为取消状态
            //注意设置为取消状态仅仅是改变了线程状态而言，并不能终止线程
            if (!thread.isFinished) {
                [thread cancel];
            }
        }
    }else{
        //TODO:借用stop方法，执行创建图片方法
        [self condition_createImageWithMultiThread];
    }
}
#pragma mark -----------NSOperation Example--------------
#pragma mark 将图片显示到界面
/*
    由于方法可以传递两个参数，所不需要自己在建立对象传递
 */
-(void)operation_updateImageWithData:(NSData *)imageData andIndex:(NSInteger)index{
    UIImage *image=[UIImage imageWithData:imageData];
    UIImageView *imageView= _imageViews[index];
    imageView.image=image;
}

#pragma mark 请求图片数据
-(NSData *)operation_requestData:(NSInteger)index{
    
    NSString * urlStr = [NSString stringWithFormat:@"https://images.cnblogs.com/cnblogs_com/kenshincui/613474/o_%li.jpg",index];
    NSURL *url=[NSURL URLWithString:urlStr];
    NSData *data=[NSData dataWithContentsOfURL:url];
    return data;
}

#pragma mark 加载图片
-(void)operation_loadImage:(NSNumber *)index{
   
    NSInteger i=[index integerValue];
    
    DLog(@"%li",(long)i);//未必按顺序输出
    
    NSData *data= [self operation_requestData:i];
    DLog(@"%@",[NSThread currentThread]);
    //更新UI界面,此处调用了主线程队列的方法（mainQueue是UI主线程）
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self operation_updateImageWithData:data andIndex:i];
    }];

}

#pragma mark 多线程下载图片
/**
 对比之前NSThread加载张图片很发现核心代码简化了不少，这里着重强调两点：
 1、使用NSBlockOperation方法，所有的操作不必单独定义方法，同时解决了只能传递一个参数的问题。
 2、调用主线程队列的addOperationWithBlock:方法进行UI更新，不用再定义一个参数实体（之前必须定义一个KCImageData解决只能传递一个参数的问题）。
 3、使用NSOperation进行多线程开发可以设置最大并发线程，有效的对线程进行了控制（上面的代码运行起来你会发现打印当前进程时只有有限的线程被创建，如上面的代码设置最大线程数为5，则图片基本上是五个一次加载的）。
 **/
-(void)operation_loadImageWithMultiThread{
    NSInteger count = ROW_COUNT*COLUMN_COUNT;
    
    NSOperationQueue * operationQueue = [[NSOperationQueue alloc] init];
    //如下面的代码设置最大线程数为5，则图片基本上是五个一次加载的
    operationQueue.maxConcurrentOperationCount = 5 ; // 设置最大并发线程数
    // 创建多个线程用于填充图片
    for (int i = 0; i < count; ++i) {
        //方法1：创建操作块添加到队列
//        //创建多线程操作
//        NSBlockOperation *blockOperation=[NSBlockOperation blockOperationWithBlock:^{
//            [self operation_loadImage:[NSNumber numberWithInt:i]];
//        }];
//        //创建操作队列
//        [operationQueue addOperation:blockOperation];
        
        //方法2：直接使用操队列添加操作
        [operationQueue addOperationWithBlock:^{
            [self operation_loadImage:[NSNumber numberWithInt:i]];
        }];
    }
}

#pragma mark 多线程下载图片通过修改线程优先级方式从最后一张开始加载
/**
 前面使用NSThread很难控制线程的执行顺序，但是使用NSOperation就容易多了，
 每个NSOperation可以设置依赖线程。假设操作A依赖于操作B，
 线程操作队列在启动线程时就会首先执行B操作，然后执行A。
 对于前面优先加载最后一张图的需求，只要设置前面的线程操作的依赖线程为最后一个操作即可
 可以看到虽然加载最后一张图片的操作最后被加入到操作队列，但是它却是被第一个执行的。
 操作依赖关系可以设置多个，例如A依赖于B、B依赖于C…但是千万不要设置为循环依赖关系
 （例如A依赖于B，B依赖于C，C又依赖于A），否则是不会被执行的
 **/
- (void)operation_loadLastImageViewWithMultiThread{
    
    int count=ROW_COUNT*COLUMN_COUNT;
    //创建操作队列
    NSOperationQueue *operationQueue=[[NSOperationQueue alloc]init];
    operationQueue.maxConcurrentOperationCount=5;//设置最大并发线程数
    
    NSBlockOperation *lastBlockOperation=[NSBlockOperation blockOperationWithBlock:^{
        [self operation_loadImage:[NSNumber numberWithInt:(count-1)]];
    }];
    //创建多个线程用于填充图片
    for (int i=0; i<count-1; ++i) {
        //方法1：创建操作块添加到队列
        //创建多线程操作
        NSBlockOperation *blockOperation=[NSBlockOperation blockOperationWithBlock:^{
            [self operation_loadImage:[NSNumber numberWithInt:i]];
        }];
        //设置依赖操作为最后一张图片加载操作
        [blockOperation addDependency:lastBlockOperation];
        
        [operationQueue addOperation:blockOperation];
    }
    //将最后一个图片的加载操作加入线程队列
    [operationQueue addOperation:lastBlockOperation];
}
#pragma mark -----------GCD Example--------------
/**
 GCD(Grand Central Dispatch)是基于C语言开发的一套多线程开发机制，
 也是目前苹果官方推荐的多线程开发方法。前面也说过三种开发中GCD抽象层次最高，
 当然是用起来也最简单，只是它基于C语言开发，并不像NSOperation是面向对象的开发，
 而是完全面向过程的。对于熟悉C#异步调用的朋友对于GCD学习起来应该很快，
 因为它与C#中的异步调用基本是一样的。这种机制相比较于前面两种多线程开发方式最显著的优点就是它对于多核运算更加有效。
 
 GCD中也有一个类似于NSOperationQueue的队列，GCD统一管理整个队列中的任务。
 但是GCD中的队列分为并行队列和串行队列两类：
 串行队列：只有一个线程，加入到队列中的操作按添加顺序依次执行。
 并发队列：有多个线程，操作进来之后它会将这些队列安排在可用的处理器上，同时保证先进来的任务优先处理。
 其实在GCD中还有一个特殊队列就是主队列，用来执行主线程上的操作任务（从前面的演示中可以看到其实在NSOperation中也有一个主队列）
 
 
 1、dispatch_apply():重复执行某个任务，但是注意这个方法没有办法异步执行（为了不阻塞线程可以使用dispatch_async()包装一下再执行）。
 2、dispatch_once():单次执行一个任务，此方法中的任务只会执行一次，重复调用也没办法重复执行（单例模式中常用此方法）。
 3、dispatch_time()：延迟一定的时间后执行。
 4、dispatch_barrier_async()：使用此方法创建的任务首先会查看队列中有没有别的任务要执行，如果有，则会等待已有任务执行完毕再执行；
                            同时在此方法后添加的任务必须等待此方法中任务执行后才能执行。（利用这个方法可以控制执行顺序，
                            例如前面先加载最后一张图片的需求就可以先使用这个方法将最后一张图片加载的操作添加到队列，
                            然后调用dispatch_async()添加其他图片加载任务）
 5、dispatch_group_async()：实现对任务分组管理，如果一组任务全部完成可以通过dispatch_group_notify()方法获得完成通知（需要定义dispatch_group_t作为分组标识）。
 **/
#pragma mark 将图片显示到界面
/*
 由于方法可以传递两个参数，所不需要自己在建立对象传递
 */
-(void)GCD_updateImageWithData:(NSData *)imageData andIndex:(NSInteger)index{
    UIImage *image=[UIImage imageWithData:imageData];
    UIImageView *imageView= _imageViews[index];
    imageView.image=image;
}

#pragma mark 请求图片数据
-(NSData *)GCD_requestData:(NSInteger)index{
    
    NSString * urlStr = [NSString stringWithFormat:@"https://images.cnblogs.com/cnblogs_com/kenshincui/613474/o_%li.jpg",index];
    NSURL *url=[NSURL URLWithString:urlStr];
    NSData *data=[NSData dataWithContentsOfURL:url];
    return data;
}

#pragma mark 加载图片
-(void)GCD_loadImage:(NSNumber *)index{
    
    //如果在串行队列中会发现当前线程打印变化完全一样，因为他们在一个线程中
    NSLog(@"thread is :%@",[NSThread currentThread]);
    
    NSInteger i=[index integerValue];
    //请求数据
    NSData *data= [self GCD_requestData:i];
    //更新UI界面,此处调用了GCD主线程队列的方法
    dispatch_queue_t mainQueue= dispatch_get_main_queue();
    dispatch_sync(mainQueue, ^{
        [self GCD_updateImageWithData:data andIndex:i];
    });
}

#pragma mark 多线程下载图片

/**
 串行队列:
 使用串行队列时首先要创建一个串行队列，然后调用异步调用方法，在此方法中传入串行队列和线程操作即可自动执行。
 下面使用线程队列演示图片的加载过程，你会发现多张图片会按顺序加载，因为当前队列中只有一个线程
 
 并行队列:
 并发队列同样是使用dispatch_queue_create()方法创建，
 只是最后一个参数指定为DISPATCH_QUEUE_CONCURRENT进行创建，
 但是在实际开发中我们通常不会重新创建一个并发队列而是使用dispatch_get_global_queue()方法取得一个全局的并发队列
 （当然如果有多个并发队列可以使用前者创建）。下面通过并行队列演示一下多个图片的加载。

 dispatch_sync方法使用，可以看点击按钮后按钮无法再次点击，
 因为所有图片的加载全部在主线程中（可以打印线程查看），主线程被阻塞，造成图片最终是一次性显示。可以得出结论：
 1、在GDC中一个操作是多线程执行还是单线程执行取决于当前队列类型和执行方法，只有队列类型为并行队列并且使用异步方法执行时才能在多个线程中执行。
 2、串行队列可以按顺序执行，并行队列的异步方法无法确定执行顺序。
 3、UI界面的更新最好采用同步方法，其他操作采用异步方法。
 
 **/
-(void)GCD_loadImageWithMultiThread{
    NSInteger count=ROW_COUNT*COLUMN_COUNT;
    
    // MARK: 创建串行队列
    /*创建一个串行队列
     第一个参数：队列名称
     第二个参数：队列类型 DISPATCH_QUEUE_SERIAL(串行) DISPATCH_QUEUE_CONCURRENT(并行)
     */
    
//    dispatch_queue_t serialQueue=dispatch_queue_create("myThreadQueue1", DISPATCH_QUEUE_SERIAL);//注意queue对象不是指针类型
//    //创建多个线程用于填充图片
//    for (int i=0; i<count; ++i) {
//        //异步执行队列任务
//        dispatch_async(serialQueue, ^{
//            [self GCD_loadImage:[NSNumber numberWithInt:i]];
//        });
//    }
    
    //非ARC环境请释放
    //    dispatch_release(seriQueue);
    
    // MARK: 创建全局并行队列
    /*取得全局队列
     第一个参数：线程优先级
     第二个参数：标记参数，目前没有用，一般传入0
     */
    dispatch_queue_t globalQueue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //创建多个线程用于填充图片
    for (int i=0; i<count; ++i) {
        //异步执行队列任务
        dispatch_async(globalQueue, ^{
            [self GCD_loadImage:[NSNumber numberWithInt:i]];
        });
        // FIXME: dispatch_sync 同步执行过程中程序crash
        //同步执行队列任务
//        dispatch_sync(globalQueue, ^{
//            [self GCD_loadImage:[NSNumber numberWithInt:i]];
//        });
    }
    
}
#pragma mark -----------NSLock(同步锁) @synchronized（代码块）dispatch_semaphore_t（信号量）----------
/**
 要解决资源抢夺问题在iOS中有常用的有两种方法：
 一种是使用NSLock同步锁，
 另一种是使用@synchronized代码块。
 两种方法实现原理是类似的，只是在处理上代码块使用起来更加简单（C#中也有类似的处理机制synchronized和lock）。
 
 这里不妨还拿图片加载来举例，假设现在有9张图片，但是有15个线程都准备加载这9张图片，
 约定不能重复加载同一张图片，这样就形成了一个资源抢夺的情况。在下面的程序中将创建9张图片，
 每次读取照片链接时首先判断当前链接数是否大于1，用完一个则立即移除，最多只有9个
 
 NSLock:
 iOS中对于资源抢占的问题可以使用同步锁NSLock来解决，使用时把需要加锁的代码（以后暂时称这段代码为”加锁代码“）
 放到NSLock的lock和unlock之间，一个线程A进入加锁代码之后由于已经加锁，另一个线程B就无法访问，
 只有等待前一个线程A执行完加锁代码后解锁，B线程才能访问加锁代码。
 需要注意的是lock和unlock之间的”加锁代码“应该是抢占资源的读取和修改代码，
 不要将过多的其他操作代码放到里面，否则一个线程执行的时候另一个线程就一直在等待，就无法发挥多线程的作用了。
 
 另外，在上面的代码中”抢占资源“_imageNames定义成了成员变量，这么做是不明智的，应该定义为“原子属性”。
 对于被抢占资源来说将其定义为原子属性是一个很好的习惯，因为有时候很难保证同一个资源不在别处读取和修改。
 nonatomic属性读取的是内存数据（寄存器计算好的结果），而atomic就保证直接读取寄存器的数据，
 这样一来就不会出现一个线程正在修改数据，而另一个线程读取了修改之前（存储在内存中）的数据，
 永远保证同时只有一个线程在访问一个属性。
 
 @synchronized代码块:
 使用@synchronized解决线程同步问题相比较NSLock要简单一些，日常开发中也更推荐使用此方法。
 首先选择一个对象作为同步对象（一般使用self），然后将”加锁代码”（争夺资源的读取、修改代码）放到代码块中。
 @synchronized中的代码执行时先检查同步对象是否被另一个线程占用，如果占用该线程就会处于等待状态，直到同步对象被释放
 
 
 在iOS开发中，除了同步锁有时候还会用到一些其他锁类型，在此简单介绍一下：
 
 NSRecursiveLock ：递归锁，有时候“加锁代码”中存在递归调用，递归开始前加锁，
                递归调用开始后会重复执行此方法以至于反复执行加锁代码最终造成死锁，
                这个时候可以使用递归锁来解决。使用递归锁可以在一个线程中反复获取锁而不造成死锁，
                这个过程中会记录获取锁和释放锁的次数，只有最后两者平衡锁才被最终释放。
 
 NSDistributedLock：分布锁，它本身是一个互斥锁，基于文件方式实现锁机制，可以跨进程访问。
 
 pthread_mutex_t：同步锁，基于C语言的同步锁机制，使用方法与其他同步锁机制类似。
 
 *注意*在开发过程中除非必须用锁，否则应该尽可能不使用锁，因为多线程开发本身就是为了提高程序执行顺序，而同步锁本身就只能一个进程执行，这样不免降低执行效率。
 **/

#pragma mark 将图片显示到界面
/*
 由于方法可以传递两个参数，所不需要自己在建立对象传递
 */
-(void)lock_updateImageWithData:(NSData *)imageData andIndex:(NSInteger)index{
    UIImage *image=[UIImage imageWithData:imageData];
    UIImageView *imageView= _imageViews[index];
    imageView.image=image;
}

#pragma mark 请求图片数据
-(NSData *)lock_requestData:(NSInteger)index{

    NSData *data;
    NSString *img_url;
    // MARK: 方法一 NSLock
//    //MARK: 加锁
//    [_thread_lock lock];
//    if (_imageURLs.count>0) {
//        img_url=[_imageURLs lastObject];
//        [_imageURLs removeObject:img_url];
//    }
//    //MARK: 使用完解锁
//    [_thread_lock unlock];
    
    // MARK: 方法二 @synchronized 代码块
    
//    @synchronized(self){
//
//        if (_imageURLs.count>0) {
//            img_url=[_imageURLs lastObject];
//            [_imageURLs removeObject:img_url];
//        }
//    }
    // MARK: 方法三 dispatch_semaphore_t
    /*信号等待
     第二个参数：等待时间
     */
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    if (_imageURLs.count>0) {
        img_url=[_imageURLs lastObject];
        [_imageURLs removeObject:img_url];
    }
    // MARK: 信号通知
    dispatch_semaphore_signal(_semaphore);
    
    if(img_url){
        NSURL *url=[NSURL URLWithString:img_url];
        data=[NSData dataWithContentsOfURL:url];
    }
    return data;
}

#pragma mark 加载图片
-(void)lock_loadImage:(NSNumber *)index{
    
    //如果在串行队列中会发现当前线程打印变化完全一样，因为他们在一个线程中
    NSLog(@"thread is :%@",[NSThread currentThread]);
    
    NSInteger i=[index integerValue];
    //请求数据
    NSData *data= [self lock_requestData:i];
    //更新UI界面,此处调用了GCD主线程队列的方法
    dispatch_queue_t mainQueue= dispatch_get_main_queue();
    dispatch_sync(mainQueue, ^{
        [self lock_updateImageWithData:data andIndex:i];
    });
}

#pragma mark 多线程下载图片

-(void)lock_loadImageWithMultiThread{
    NSInteger count=ROW_COUNT*COLUMN_COUNT;
    
    /*取得全局队列
     第一个参数：线程优先级
     第二个参数：标记参数，目前没有用，一般传入0
     */
    dispatch_queue_t globalQueue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //创建多个线程用于填充图片
    for (int i=0; i<count; ++i) {
        //异步执行队列任务
        dispatch_async(globalQueue, ^{
            [self lock_loadImage:[NSNumber numberWithInt:i]];
        });
    }
}
#pragma mark -----------NSCondition(控制线程通信)----------
/**
 
 由于线程的调度是透明的，程序有时候很难对它进行有效的控制，
 为了解决这个问题iOS提供了NSCondition来控制线程通信(同前面GCD的信号机制类似)。
 NSCondition实现了NSLocking协议，所以它本身也有lock和unlock方法，
 因此也可以将它作为NSLock解决线程同步问题，此时使用方法跟NSLock没有区别，
 只要在线程开始时加锁，取得资源后释放锁即可，这部分内容比较简单在此不再演示。
 当然，单纯解决线程同步问题不是NSCondition设计的主要目的，
 NSCondition更重要的是解决线程之间的调度关系（当然，这个过程中也必须先加锁、解锁）。
 NSCondition可以调用wati方法控制某个线程处于等待状态，
 直到其他线程调用signal（此方法唤醒一个线程，如果有多个线程在等待则任意唤醒一个
 ）或者broadcast（此方法会唤醒所有等待线程）方法唤醒该线程才能继续。
 
 假设当前imageNames没有任何图片，而整个界面能够加载15张图片（每张都不能重复），
 现在创建15个线程分别从imageNames中取图片加载到界面中。由于imageNames中没有任何图片，
 那么15个线程都处于等待状态，只有当调用图片创建方法往imageNames中添加图片后（每次创建一个）
 并且唤醒其他线程（这里只唤醒一个线程）才能继续执行加载图片。
 如此，每次创建一个图片就会唤醒一个线程去加载，这个过程其实就是一个典型的生产者-消费者模式

 **/

#pragma mark 创建图片
-(void)condition_createImageName{
    [_condition lock];
    //如果当前已经有图片了则不再创建，线程处于等待状态
    if (_imageURLs.count>0) {
        NSLog(@"createImageName wait, current:%li",(long)_currentIndex);
        [_condition wait];
    }else{
        NSLog(@"createImageName work, current:%li",(long)_currentIndex);
        //生产者，每次生产1张图片
        [_imageURLs addObject:[NSString stringWithFormat:@"https://images.cnblogs.com/cnblogs_com/kenshincui/613474/o_%li.jpg",(long)_currentIndex++]];
        //创建完图片则发出信号唤醒其他等待线程
        [_condition signal];
    }
    [_condition unlock];
}

#pragma mark 加载图片并将图片显示到界面
-(void)condition_loadAnUpdateImageWithIndex:(int )index{
    //请求数据
    NSData *data= [self condition_requestData:index];
//    //更新UI界面,此处调用了GCD主线程队列的方法
    dispatch_queue_t mainQueue= dispatch_get_main_queue();
    dispatch_sync(mainQueue, ^{
        UIImage *image=[UIImage imageWithData:data];
        UIImageView *imageView= self.imageViews[index];
        imageView.image=image;  // 一定要在主线程中使用
    });
}

#pragma mark 请求图片数据
/**
  在上面的代码中loadImage:方法是消费者，当在界面中点击“加载图片”后就创建了15个消费者线程。
 在这个过程中每个线程进入图片加载方法之后都会先加锁，加锁之后其他进程是无法进入“加锁代码”的。
 但是第一个线程进入“加锁代码”后去加载图片却发现当前并没有任何图片，
 因此它只能等待。一旦调用了NSCondition的wait方法后其他线程就可以继续进入“加锁代码”（
 注意，这一点和前面说的NSLock、@synchronized等是不同的，使用NSLock、@synchronized等进行加锁后无论什么情况下，只要没有解锁其他线程就无法进入“加锁代码”），
 同时第一个线程处于等待队列中（此时并未解锁）。第二个线程进来之后同第一线程一样，
 发现没有图片就进入等待状态，然后第三个线程进入。。。如此反复，
 直到第十五个线程也处于等待。此时点击“创建图片”后会执行createImageName方法，
 这是一个生产者，它会创建一个图片链接放到imageNames中，
 然后通过调用NSCondition的signal方法就会在条件等待队列中选择一个线程（该线程会任意选取，假设为线程A）开启，那么此时这个线程就会继续执行。
 在上面代码中，wati方法之后会继续执行图片加载方法，那么此时线程A启动之后继续执行图片加载方法，当然此时可以成功加载图片。
 加载完图片之后线程A就会释放锁，整个线程任务完成。此时再次点击”创建图片“按钮重复前面的步骤加载其他图片。
 **/
-(NSData *)condition_requestData:(NSInteger)index{
    NSData *data;
    NSString *img_url;
    img_url=[_imageURLs lastObject];
    [_imageURLs removeObject:img_url];
    if(img_url){
        NSURL *url=[NSURL URLWithString:img_url];
        data=[NSData dataWithContentsOfURL:url];
    }
    return data;
}

#pragma mark 加载图片
-(void)condition_loadImage:(NSNumber *)index{
    
    int i=(int)[index integerValue];
    //加锁
    [_condition lock];
    //如果当前有图片资源则加载，否则等待
    if (_imageURLs.count>0) {
        NSLog(@"loadImage work,index is %i",i);
        [self condition_loadAnUpdateImageWithIndex:i];
        [_condition broadcast];
    }else{
        NSLog(@"loadImage wait,index is %i",i);
        NSLog(@"%@",[NSThread currentThread]);
        //线程等待
        [_condition wait];
        NSLog(@"loadImage resore,index is %i",i);
        //一旦创建完图片立即加载
        [self condition_loadAnUpdateImageWithIndex:i];
    }
    //解锁
    [_condition unlock];
}

#pragma mark - UI调用方法
#pragma mark 异步创建一张图片链接
-(void)condition_createImageWithMultiThread{
    dispatch_queue_t globalQueue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //创建图片链接
    dispatch_async(globalQueue, ^{
        [self condition_createImageName];
    });
}

#pragma mark 多线程下载图片

-(void)condition_loadImageWithMultiThread{
    NSInteger count=ROW_COUNT*COLUMN_COUNT;
    
    /*取得全局队列
     第一个参数：线程优先级
     第二个参数：标记参数，目前没有用，一般传入0
     */
    dispatch_queue_t globalQueue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //创建多个线程用于填充图片
    for (int i=0; i<count; ++i) {
        //异步执行队列任务
        dispatch_async(globalQueue, ^{
            [self condition_loadImage:[NSNumber numberWithInt:i]];
        });
    }
}
#pragma mark ----------总结----------

/**
 1>无论使用哪种方法进行多线程开发，每个线程启动后并不一定立即执行相应的操作，具体什么时候由系统调度（CPU空闲时就会执行）。
 
 2>更新UI应该在主线程（UI线程）中进行，并且推荐使用同步调用，常用的方法如下：
 
    * - (void)performSelectorOnMainThread:(SEL)aSelector withObject:(id)arg waitUntilDone:(BOOL)wait
    * -(void)performSelector:(SEL)aSelector onThread:(NSThread *)thr withObject:(id)arg waitUntilDone:(BOOL) wait;
        方法传递主线程[NSThread mainThread])
    * [NSOperationQueue mainQueue] addOperationWithBlock:
    * dispatch_sync(dispatch_get_main_queue(), ^{})
 
 3>NSThread适合轻量级多线程开发，控制线程顺序比较难，同时线程总数无法控制（每次创建并不能重用之前的线程，只能创建一个新的线程）。
 
 4>对于简单的多线程开发建议使用NSObject的扩展方法完成，而不必使用NSThread。
 
 5>可以使用NSThread的currentThread方法取得当前线程，使用 sleepForTimeInterval:方法让当前线程休眠。
 
 6>NSOperation进行多线程开发可以控制线程总数及线程依赖关系。
 
 7>创建一个NSOperation不应该直接调用start方法（如果直接start则会在主线程中调用）而是应该放到NSOperationQueue中启动。
 
 8>相比NSInvocationOperation推荐使用NSBlockOperation，代码简单，同时由于闭包性使它没有传参问题。
 
 9>NSOperation是对GCD面向对象的ObjC封装，但是相比GCD基于C语言开发，效率却更高，建议如果任务之间有依赖关系或者想要监听任务完成状态的情况下优先选择NSOperation否则使用GCD。
 
 10>在GCD中串行队列中的任务被安排到一个单一线程执行（不是主线程），可以方便地控制执行顺序；并发队列在多个线程中执行（前提是使用异步方法），顺序控制相对复杂，但是更高效。
 
 11>在GCD中一个操作是多线程执行还是单线程执行取决于当前队列类型和执行方法，只有队列类型为并行队列并且使用异步方法执行时才能在多个线程中执行（如果是并行队列使用同步方法调用则会在主线程中执行）。
 
 12>相比使用NSLock，@synchronized更加简单，推荐使用后者。
 **/

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
