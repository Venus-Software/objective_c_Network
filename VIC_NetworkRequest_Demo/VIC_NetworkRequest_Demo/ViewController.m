//
//  ViewController.m
//  VIC_NetworkRequest_Demo
//
//  Created by 吴伟军 on 2017/4/28.
//  Copyright © 2017年 wuwj. All rights reserved.
//

#import "ViewController.h"
#import "VICNetWorkHeader.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@",[NSString stringWithFormat:@"%@",[[VICURLFactory shardFactoryHandle] relativeBaseURL]]);
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
