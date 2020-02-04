//
//  WMContentView.h
//  WMScrollPageView
//
//  Created by Sper on 2018/1/20.
//  Copyright © 2018年 WM. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WMContentView;

@protocol WMContentViewDelegate <NSObject>

@required
/// 显示总页面数
- (NSInteger)numberOfCountInContentView:(WMContentView *)contentView;

/// 每一页显示的控制器视图
- (UIViewController *)contentView:(WMContentView *)contentView viewControllerAtIndex:(NSInteger)index;

@optional
/// 默认选中
- (NSInteger)defaultSelectedIndexAtContentView:(WMContentView *)contentView;

/// 控制器的滚动视图
- (void)contentView:(WMContentView *)contentView controllerScrollView:(UIScrollView *)scrollView;

/// 分页控制器的滚动视图滚动
- (void)contentView:(WMContentView *)contentView pageControlScroll:(UIScrollView *)scrollView;

/// 分页控制器滚动进度监听
- (void)contentView:(WMContentView *)contentView adjustUIWithProgress:(CGFloat)progress currentIndex:(NSInteger)currentIndex;

/// 视图停止滚动
- (void)stopScrollAnimatingAtContentView:(WMContentView *)contentView;
@end

@interface WMContentView : UITableViewCell
/// 代理对象
@property (nonatomic , weak  ) id<WMContentViewDelegate> delegate;
/// 当前视图显示在外层视图cell上
+ (instancetype)cellForTableView:(UITableView *)tableView delegate:(id<WMContentViewDelegate>)delegate;
/// 切换页面
- (void)wm_changePageWithIndex:(NSInteger)index;
@end
