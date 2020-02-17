//
//  WMSegmentViewController.m
//  WMDemo
//
//  Created by Sper on 2019/1/27.
//  Copyright © 2019年 WM. All rights reserved.
//

#import "WMSegmentViewController.h"
#import "WMScrollPageView.h"
#import "TestTableViewController.h"

@interface WMSegmentViewController ()<WMScrollPageViewDataSource,WMScrollPageViewDelegate>
@property (nonatomic, strong) WMScrollPageView *pageView;
@property (nonatomic, strong) WMSegmentView *segmentView;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) WMSegmentStyle *style;
@end

@implementation WMSegmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.pageView];
    
    self.segmentView = self.pageView.segmentView;
    self.segmentView.layer.borderWidth = 1.0;
    self.segmentView.layer.cornerRadius = 10;
    self.segmentView.layer.masksToBounds = YES;
    self.segmentView.layer.borderColor = [UIColor blackColor].CGColor;
    self.segmentView.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = self.segmentView;
}

/// 滑动块有多少项  默认是 0
- (NSInteger)numberOfCountInScrollPageView:(WMScrollPageView *)scrollPageView {
    return self.titles.count;
}

/// 每一项显示的标题
- (NSString *)scrollPageView:(WMScrollPageView *)scrollPageView titleForSegmentAtIndex:(NSInteger)index {
    return self.titles[index];
}

/// 每一项下面显示的视图控制器
- (UIViewController *)scrollPageView:(WMScrollPageView *)scrollPageView viewControllerAtIndex:(NSInteger)index {
    TestTableViewController *vc = [TestTableViewController new];
    vc.index = index;
    return  vc;
}

- (NSArray *)titles{
    return @[@"App订单",@"团购订单",@"卡订单"];
}

- (WMSegmentStyle *)style{
    if (_style == nil) {
        _style = [[WMSegmentStyle alloc] init];
        _style.normalTitleColor = [UIColor whiteColor];
        _style.selectedTitleColor = [UIColor darkTextColor];
        _style.normalBgColor = [UIColor darkTextColor];
        _style.selectedBgColor = [UIColor whiteColor];
//        _style.borderRadius = 8.0;
//        _style.borderColor = [UIColor darkTextColor];
        _style.showMoveLine = NO;
        _style.allowShowBottomLine = NO;
        _style.customSegmentSuperView = YES;
        _style.segmentHeight = 35;
    }
    return _style;
}
- (WMScrollPageView *)pageView {
    if (_pageView == nil) {
        _pageView = [[WMScrollPageView alloc] initWithSegmentStyle:self.style parentVC:self];
        _pageView.dataSource = self;
        _pageView.delegate = self;
    }
    return _pageView;
}
- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.pageView.frame = CGRectMake(0, 88, self.view.bounds.size.width, self.view.bounds.size.height - 88);
    self.segmentView.frame = CGRectMake(0, 0, 250, self.style.segmentHeight);
}

@end
