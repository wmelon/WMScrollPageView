//
//  ViewController.m
//  WMDemo
//
//  Created by Sper on 2017/8/31.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "ViewController.h"
#import "WMScrollPageView.h"
#import "TestTableViewController.h"

/// 判断是否刘海屏幕设备
#define kIsIPhoneX \
({\
UIWindow *window = [UIApplication sharedApplication].windows[0];\
BOOL result = NO;\
if (@available(iOS 11.0, *)) {\
UIEdgeInsets edgeInsets = window.safeAreaInsets;\
result = (edgeInsets.top > 20);\
}\
(result);\
})\

#define kNavBarHeight (kIsIPhoneX ? 88 : 64)

@interface ViewController ()<WMScrollPageViewDataSource,WMScrollPageViewDelegate>
@property (nonatomic, strong) WMScrollPageView *scrollPageView;
@property (nonatomic, strong) NSMutableArray *titles;
@property (nonatomic, strong) UIView *headerView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _titles = [NSMutableArray array];
    [_titles addObjectsFromArray:@[@"要闻",@"政务",@"时报",@"视频",@"直播",@"生活",@"社区",@"商圈",@"园区",@"图片",@"美丽长宁",@"专题",@"投稿"]];
    

    [self.view addSubview:self.scrollPageView];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    [button addTarget:self action:@selector(playInputClick:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor redColor];
    self.navigationItem.titleView = button;
}
- (void)playInputClick:(UIButton *)button {
    [_titles setArray:@[@"要闻",@"政务"]];
    [self.scrollPageView reloadScrollPageView];
}
#pragma mark - 监听屏幕旋转(new)
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    NSTimeInterval duration = [coordinator transitionDuration];
    [UIView animateWithDuration:duration animations:^{
        self.scrollPageView.frame = CGRectMake(0, 0, size.width, size.height);
    }];
}
#pragma mark -- WMScrollBarControlDataSource
- (NSInteger)numberOfCountInScrollPageView:(WMScrollPageView *)scrollPageView{
    return self.titles.count;
}
/// 每一项显示的标题
- (NSString *)scrollPageView:(WMScrollPageView *)scrollPageView titleForSegmentAtIndex:(NSInteger)index{
    return self.titles[index];
}

/// 每一项下面显示的视图控制器
- (UIViewController *)scrollPageView:(WMScrollPageView *)scrollPageView viewControllerAtIndex:(NSInteger)index{
    TestTableViewController * vc = [TestTableViewController new];
    [vc setTitle:self.titles[index]];
    return vc;
}
- (UIView *)headerViewInScrollPageView:(WMScrollPageView *)scrollPageView {
    return self.headerView;
}
- (void)plusButtonClickAtScrollPageView:(WMScrollPageView *)scrollPageView{
    //// 这里处理点击
    //    [CNJumper pushVcName:kClassName(CNNewsDetailViewController)];
}
- (WMScrollPageView *)scrollPageView{
    if (_scrollPageView == nil){
        WMSegmentStyle * style = [WMSegmentStyle new];
        style.itemSizeStyle = wm_itemSizeStyle_equal_textSize;
        style.scaleTitle = YES;
        style.changeTitleColor = YES;
        _scrollPageView = [[WMScrollPageView alloc] initWithSegmentStyle:style parentVC:self];
        _scrollPageView.dataSource = self;
        _scrollPageView.delegate = self;
    }
    return _scrollPageView;
}
- (UIView *)headerView {
    if (_headerView == nil) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
        _headerView.backgroundColor = [UIColor redColor];
    }
    return _headerView;
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.scrollPageView.frame = CGRectMake(0, kNavBarHeight, self.view.frame.size.width, self.view.frame.size.height - kNavBarHeight);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
