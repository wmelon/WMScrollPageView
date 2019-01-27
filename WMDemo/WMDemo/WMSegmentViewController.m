//
//  WMSegmentViewController.m
//  WMDemo
//
//  Created by Sper on 2019/1/27.
//  Copyright © 2019年 WM. All rights reserved.
//

#import "WMSegmentViewController.h"
#import "WMSegmentView.h"

@interface WMSegmentViewController ()<WMSegmentViewDelegate>
@property (nonatomic, strong) WMSegmentView *segmentView;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) WMSegmentStyle *style;
@end

@implementation WMSegmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.titleView = self.segmentView;
}
#pragma mark -- WMSegmentViewDelegate
/// 一共多少个切换标题
- (NSInteger)numberOfCountAtSegmentView:(WMSegmentView *)segmentView{
    return self.titles.count;
}

/// 标题按钮显示的文案
- (NSString *)segmentView:(WMSegmentView *)segmentView titleForItemAtIndex:(NSInteger)index{
    return self.titles[index];
}

/// 控件样式
- (WMSegmentStyle *)segmentStyleAtSegmentView:(WMSegmentView *)segmentView{
    return self.style;
}

/// 标题按钮点击事件
- (void)segmentView:(WMSegmentView *)segmentView didSelectIndex:(NSInteger)index{
    
}
/// 默认选中标题
- (NSInteger)defaultSelectedIndexAtSegmentView:(WMSegmentView *)segmentView{
    return 2;
}

//- (void)segmentView:(HKSegmentView *)segmentView didSelectIndex:(NSInteger)index{
//
//}
- (NSArray *)titles{
    return @[@"App订单",@"团购订单"];
}
- (WMSegmentStyle *)style{
    if (_style == nil) {
        _style = [[WMSegmentStyle alloc] init];
        _style.normalTitleColor = [UIColor whiteColor];
        _style.selectedTitleColor = [UIColor darkTextColor];
        _style.selectedBgColor = [UIColor whiteColor];
        _style.borderRadius = 8.0;
        _style.borderColor = [UIColor darkTextColor];
        _style.showMoveLine = NO;
        _style.allowShowBottomLine = NO;
    }
    return _style;
}
- (WMSegmentView *)segmentView{
    if (_segmentView == nil){
        _segmentView = [[WMSegmentView alloc] init];
        _segmentView.layer.cornerRadius = 8;
        _segmentView.layer.masksToBounds = YES;
        _segmentView.backgroundColor = [UIColor lightGrayColor];
        _segmentView.delegate = self;
    }
    return _segmentView;
}
- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.segmentView.frame = CGRectMake(0, 0, 150, 35);
}

@end
