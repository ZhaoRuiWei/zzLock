//
//  ViewController.m
//  zzLock
//
//  Created by 赵瑞玮 on 16/12/5.
//  Copyright © 2016年 zhaoruiwei. All rights reserved.
//

#import "ViewController.h"
//首先我们都知道@synchronized(self)可以实现数据保护，避免资源抢夺。这里取巧的使用新的技术达到一定目的。
//我们往往过于依赖系统的方法，看似负责的判断逻辑其实可以很简单的实现，避免系统的一些看不懂的思维怪圈。以下代码看完会发现，可以简单的避免冗长的代码逻辑。

@interface ViewController ()

//数据源－车票案例
@property (nonatomic,assign) NSInteger tickets;
//全局锁对象－ 此案例没有用到
@property (nonatomic,strong) NSObject *lockObj;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化车票数据
    self.tickets = 100;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 售票口1
    NSThread *thread1 = [[NSThread alloc] initWithTarget:self selector:@selector(sellTickets) object:nil];
    thread1.name = @"t1";
    thread1.qualityOfService=0.51;
    [thread1 start];
    
    // 售票口2
    NSThread *thread2 = [[NSThread alloc] initWithTarget:self selector:@selector(sellTickets) object:nil];
    thread2.name = @"t2";
    [thread2 start];
}

/// 卖票主方法
- (void)sellTickets
{
    // 如果在这里加锁,结果就是先进来的线程会把票卖完,再开锁;后来的线程没活干
    //    @synchronized(self) {
    
    // 保证每个售票口都能独自把票卖完
    while (YES) {
        
        // 1. 互斥锁 / 同步锁 : 使用线程同步技术;
        // 2. 特点 : 保证被锁定的代码在同一时间有且只有一个线程可以执行;
        // 3. 牺牲了性能,保证了共享资源的安全;
        // 4. self : 锁对象;凡是继承自NSObject的对象都可以作为互斥锁的锁对象;内部都有一把锁,默认是开启的;
        // 5. 注意 : 锁对象必须是全局的,不能是局部的;
        // 6. 锁定的范围要竟可能的小,但是必须锁住数据的读写部分
        
        // 局部锁对象
        //        NSObject *lockObj = [[NSObject alloc] init];
        // 判断是有有余票
        self.tickets>0 ?   self.tickets--,   NSLog(@"余票 %zd %@",self.tickets,[NSThread currentThread]):    self.tickets;
        if(self.tickets==0)
        {
            NSLog(@"没票,%@",[NSThread currentThread]);
            break;
        }
        //        if(self.tickets==0)
        //        NSLog(@"没票");
        
        //            if (self.tickets > 0) {
        //
        //                // 如果有余票就卖一张
        //                self.tickets = self.tickets - 1;
        //                // 提示余票数
        //                NSLog(@"余票 %zd",self.tickets);
        //
        //            } else { // 如果没有余票就提示用户没票
        //                NSLog(@"没票");
        //                break;
        //            }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
