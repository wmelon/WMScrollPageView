//
//  NextPageViewController.m
//  WMDemo
//
//  Created by Sper on 2018/1/25.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "NextPageViewController.h"
#import "ViewController.h"

@interface NextPageViewController ()

@end

@implementation NextPageViewController
- (IBAction)nextPage:(id)sender {
    [self.navigationController pushViewController:[ViewController new] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

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
