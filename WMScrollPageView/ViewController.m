//
//  ViewController.m
//  WMScrollPageView
//
//  Created by Sper on 2017/8/30.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "ViewController.h"
#import "WMScrollPageView.h"
#import "TestViewController.h"

@interface ViewController ()<WMScrollPageViewDataSource,WMScrollPageViewDelegate>
@property (nonatomic, strong) WMScrollPageView *pageView;
@property (nonatomic, strong) NSMutableArray *titles;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _titles = [NSMutableArray array];
    [_titles addObjectsFromArray:@[@"要闻",@"政务",@"时报",@"视频",@"直播",@"生活",@"社区",@"商圈",@"园区",@"图片",@"美丽长宁",@"专题",@"投稿"]];
    [self.view addSubview:self.pageView];
}

/// 滑动块有多少项  默认是 0
- (NSInteger)numberOfCountInScrollPageView:(WMScrollPageView *)scrollPageView{
    return self.titles.count;
}

/// 每一项显示的标题
- (NSString *)scrollPageView:(WMScrollPageView *)scrollPageView titleForBarItemAtIndex:(NSInteger)index{
    return self.titles[index];
}


/// 滑块下的每一项对应显示的控制器
- (UIViewController *)scrollPageView:(WMScrollPageView *)scrollPageView controllerAtIndex:(NSInteger)index{
    TestViewController *vc = TestViewController.new;
    vc.titleString = self.titles[index];
    return vc;
}

- (WMScrollBarItemStyle *)scrollBarItemStyleInScrollPageView:(WMScrollPageView *)scrollPageView{
    WMScrollBarItemStyle *style = [WMScrollBarItemStyle new];
    style.itemSizeStyle = wm_itemSizeStyle_equal_textSize;
    style.scaleTitle = YES;
    style.showExtraButton = YES;
    style.showLine = YES;
    style.selectedTitleColor = [UIColor redColor];
    style.scrollLineColor = [UIColor redColor];
    style.scrollLineHeight = 2.0;
    return style;
}

- (WMScrollPageView *)pageView{
    if (_pageView == nil){
        _pageView = [[WMScrollPageView alloc] initWithFrame:self.view.bounds];
        _pageView.dataSource = self;
        _pageView.delegate = self;
    }
    return _pageView;
}


@end
