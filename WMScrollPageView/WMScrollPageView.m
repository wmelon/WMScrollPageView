//
//  WMScrollPageView.m
//  WMScrollPageView
//
//  Created by Sper on 2018/1/20.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "WMScrollPageView.h"
#import "WMContentView.h"
#import "WMStretchableTableHeaderView.h"

/// 屏幕宽度
#define kScrollPageViewScreenWidth  [UIScreen mainScreen].bounds.size.width
/// 屏幕高度
#define kScrollPageViewScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScrollIPhoneXRAndXSMAX (kScrollPageViewScreenWidth == 414.f && kScrollPageViewScreenHeight == 896.f ? YES : NO)
#define kScrollIPhoneXAndXS (kScrollPageViewScreenWidth == 375.f && kScrollPageViewScreenHeight == 812.f ? YES : NO)
/// 导航栏高度
#define kScrollPageNavBarHeight  ((kScrollIPhoneXRAndXSMAX || kScrollIPhoneXAndXS) ?88 : 64)

@interface WMManyGesturesTableView : UITableView<UIGestureRecognizerDelegate>
@end

@implementation WMManyGesturesTableView
//允许同时识别多个手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
@end

@interface WMScrollPageView()<UITableViewDataSource ,UITableViewDelegate ,WMContentViewDelegate ,UIScrollViewDelegate , WMSegmentViewDelegate>
/// 导航视图样式
@property (nonatomic ,strong) WMSegmentStyle *segmentStyle;
/// 当前外层滚动视图
@property (nonatomic ,strong) WMManyGesturesTableView *tableView;
/// 内部分页视图容器
@property (nonatomic ,strong) WMContentView * contentView;
/// 当前视图所在的控制器
@property (nonatomic ,weak  ) UIViewController *parentVC;
/// 头部视图的高度
@property (nonatomic ,assign) CGFloat tableViewHeaderViewHeight;
/// 头部下拉放大视图
@property (nonatomic ,strong) WMStretchableTableHeaderView *stretchableTableHeaderView;
/// 容器滚动视图是否可以滚动 默认是可以滚动的
@property (nonatomic ,assign) BOOL mainCanScroll;
/// 控制器滚动视图是否可以滚动
@property (nonatomic, assign) BOOL controlCanScroll;
/// 显示的控制器滚动视图
@property (nonatomic , strong) NSMutableArray<UIScrollView *> *controlScrollViewArray;

/// 配置头部视图
- (void)wm_configTableViewHeaderView;
/// 配置主滚动视图和子滚动视图谁可以滚动
- (void)wm_setMainScrollerViewAllowScroll:(BOOL)allowScroll;
- (NSInteger)wm_numberOfPageCount;
- (NSInteger)wm_defaultSelectedPage;
@end
@implementation WMScrollPageView
/// 分页导航视图
@synthesize segmentView = _segmentView;

- (instancetype)initWithSegmentStyle:(WMSegmentStyle *)segmentStyle parentVC:(UIViewController *)parentVC{
    if (self = [super init]){
        _segmentStyle = segmentStyle;
        _parentVC = parentVC;
        if (@available(iOS 11.0, *)) {
            self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            _parentVC.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return self;
}
- (void)reloadScrollPageView{
    [self setDataSource:self.dataSource];
    [self.segmentView wm_reloadSegmentView];
}
- (void)setDataSource:(id<WMScrollPageViewDataSource>)dataSource{
    _dataSource = dataSource;
    [self.tableView reloadData];
}
#pragma private method
/// 配置头部视图
- (void)wm_configTableViewHeaderView{
    UIView * headerView;
    if ([self.dataSource respondsToSelector:@selector(headerViewInScrollPageView:)]){
        headerView = [self.dataSource headerViewInScrollPageView:self];
    }
    if (headerView){
        if (self.segmentStyle.allowStretchableHeader){
            /// 允许下拉放大
            [self.stretchableTableHeaderView stretchHeaderForTableView:self.tableView withView:headerView];
        }else {
            /// 不允许下拉放大
            self.tableView.tableHeaderView = headerView;
        }
        self.tableViewHeaderViewHeight = CGRectGetHeight(headerView.frame);
        [self wm_setMainScrollerViewAllowScroll:YES];
    }else {
        self.tableView.scrollEnabled = NO;
        [self wm_setMainScrollerViewAllowScroll:NO];
    }
}
- (NSInteger)wm_numberOfPageCount{
    NSInteger count = 0;
    if ([self.dataSource respondsToSelector:@selector(numberOfCountInScrollPageView:)]){
        count = [self.dataSource numberOfCountInScrollPageView:self];
    }
    return count;
}
- (NSInteger)wm_defaultSelectedPage{
    NSInteger index = 0;
    if ([self.dataSource respondsToSelector:@selector(defaultSelectedIndexAtScrollPageView:)]){
        index = [self.dataSource defaultSelectedIndexAtScrollPageView:self];
    }
    if (index >= [self wm_numberOfPageCount]){
        index = 0;
    }
    return index;
}
#pragma mark -- control scrollerView scroll
/// 配置主滚动视图和子滚动视图谁可以滚动
- (void)wm_setMainScrollerViewAllowScroll:(BOOL)allowScroll{
    self.mainCanScroll = allowScroll;
    self.controlCanScroll = !allowScroll;
    [self.controlScrollViewArray enumerateObjectsUsingBlock:^(UIScrollView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        /// 外面主视图滚动，里面控制器视图就不允许滚动
        if (allowScroll){
            obj.contentOffset = CGPointZero;
        }
    }];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    /// 父滚动视图允许滚动的情况下才执行滚动计算
    if (self.tableView.scrollEnabled == NO) return;
    
    //计算导航栏的透明度
    CGFloat minAlphaOffset = 0;
    CGFloat maxAlphaOffset = self.tableViewHeaderViewHeight - kScrollPageNavBarHeight;
    CGFloat offset = scrollView.contentOffset.y;
    CGFloat alpha = (offset - minAlphaOffset) / (maxAlphaOffset - minAlphaOffset);
    //子控制器和主控制器之间的滑动状态切换
    CGFloat tabOffsetY = [_tableView rectForSection:0].origin.y - kScrollPageNavBarHeight + self.frame.origin.y;
    //下拉放大 必须实现
    [self.stretchableTableHeaderView scrollViewDidScroll:scrollView];
    if (offset >= tabOffsetY) {
        if (self.mainCanScroll) {
            [self wm_setMainScrollerViewAllowScroll:NO];
        }
    }
    if (!self.mainCanScroll){
        scrollView.contentOffset = CGPointMake(0, tabOffsetY);
        alpha = 1.0;  /// 防止不可以滚动的时候会出现透明度问题
    }
    if ([self.delegate respondsToSelector:@selector(scrollPageView:navigationBarAlpha:)]){
        [self.delegate scrollPageView:self navigationBarAlpha:alpha];
    }
}
/// 控制器的滚动视图滚动
- (void)controlScrollViewDidScroll:(UIScrollView *)scrollView {
    BOOL canScroll = self.controlCanScroll;
    /// 父滚动视图允许滚动才执行两个滚动视图的滚动切换
    if (self.tableView.scrollEnabled == NO) return;
    /// 控制当前滚动视图是否使用弹簧效果
    self.tableView.bounces = self.segmentStyle.allowStretchableHeader;
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY < 0){
        if (canScroll == YES){
            //子控制器到顶部了 主控制器可以滑动
            [self wm_setMainScrollerViewAllowScroll:YES];
        }
    }
    if (self.tableView.bounces){  /// 允许下拉放大头部
        if (!canScroll && scrollView.contentOffset.y != 0) {
            [scrollView setContentOffset:CGPointZero];
        }
    } else {
        if (!canScroll && scrollView.contentOffset.y != 0) {
            if (self.tableView.contentOffset.y > 0) {
                [scrollView setContentOffset:CGPointZero];
            }
        }
    }
}
#pragma mark -- UITableViewDelegate and UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WMContentView * contentViewCell = [WMContentView cellForTableView:tableView delegate:self];
    self.contentView = contentViewCell;
    return contentViewCell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //要减去导航栏 状态栏 以及 sectionheader的高度
    CGFloat naviBarAndTabBArHeight = 0.0;
    if (self.segmentStyle.isShowNavigationBar){
        naviBarAndTabBArHeight = kScrollPageNavBarHeight - self.frame.origin.y;
    }
    CGFloat height = self.frame.size.height - naviBarAndTabBArHeight;
    if (self.segmentStyle.customSegmentSuperView == NO) {
        height -= CGRectGetHeight(self.segmentView.frame);
    }
    if (height <= 0){
        height = 0;
    }
    return height;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.segmentStyle.customSegmentSuperView == NO) {
        return self.segmentView;
    }
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.segmentStyle.customSegmentSuperView == NO) {
        //sectionheader的高度，这是要放分段控件的
        return self.segmentStyle.segmentHeight;
    }
    return 0.0001;
}

#pragma mark -- WMSegmentViewDelegate
- (NSInteger)numberOfCountAtSegmentView:(WMSegmentView *)segmentView{
    return [self wm_numberOfPageCount];
}
- (NSString *)segmentView:(WMSegmentView *)segmentView titleForItemAtIndex:(NSInteger)index{
    NSString *title;
    if ([self.dataSource respondsToSelector:@selector(scrollPageView:titleForSegmentAtIndex:)]){
        title = [self.dataSource scrollPageView:self titleForSegmentAtIndex:index];
    }
    return title;
}
- (WMSegmentStyle *)segmentStyleAtSegmentView:(WMSegmentView *)segmentView{
    return self.segmentStyle;
}
- (NSInteger)defaultSelectedIndexAtSegmentView:(WMSegmentView *)segmentView{
    return [self wm_defaultSelectedPage];
}
- (void)segmentView:(WMSegmentView *)segmentView didSelectIndex:(NSInteger)index{
    [self.contentView wm_changePageWithIndex:index];
    [self pageViewCurrentIndex:index];
}
/// 右边添加按钮点击事件
- (void)plusButtonClickAtBarItem:(WMSegmentView *)segmentView{
    if ([self.delegate respondsToSelector:@selector(plusButtonClickAtScrollPageView:)]){
        [self.delegate plusButtonClickAtScrollPageView:self];
    }
}

#pragma mark -- WMContentViewDelegate
- (NSInteger)numberOfCountInContentView:(WMContentView *)WMContentView{
    return [self wm_numberOfPageCount];
}
- (UIViewController *)contentView:(WMContentView *)contentView viewControllerAtIndex:(NSInteger)index{
    UIViewController *viewController;
    if ([self.dataSource respondsToSelector:@selector(scrollPageView:viewControllerAtIndex:)]){
        viewController = [self.dataSource scrollPageView:self viewControllerAtIndex:index];
    }
    return viewController;
}
- (NSInteger)defaultSelectedIndexAtContentView:(WMContentView *)contentView{
    return [self wm_defaultSelectedPage];
}
- (void)contentView:(WMContentView *)contentView controllerScrollView:(UIScrollView *)scrollView {
    /// 存储控制器滚动视图
    if (![self.controlScrollViewArray containsObject:scrollView]){
        [self.controlScrollViewArray addObject:scrollView];
        
        /// 先移除KVO监听
        [self removeScrollViewKVO:scrollView];
        /// 给滚动视图添加KVO监听
        [self addScrollViewKVO:scrollView];
    }
}
/// 分页控制器手势滑动控制当前滚动视图实付可以滚动
- (void)contentView:(WMContentView *)contentView pageControlScroll:(UIScrollView *)scrollView{
    if (scrollView.panGestureRecognizer.state == UIGestureRecognizerStateChanged) {  /// 当滑动下面的PageView时，当前要禁止滑动
        if (self.tableViewHeaderViewHeight > 0){
            self.tableView.scrollEnabled = NO;
        }
    } else if (scrollView.panGestureRecognizer.state == UIGestureRecognizerStateEnded) {  /// bottomView停止滑动了  当前页可以滑动
        if (self.tableViewHeaderViewHeight > 0){
            self.tableView.scrollEnabled = YES;
        }
    }
}
/// 分页控制器滚动进度监听
- (void)contentView:(WMContentView *)contentView adjustUIWithProgress:(CGFloat)progress currentIndex:(NSInteger)currentIndex{
    [self.segmentView adjustUIWithProgress:progress currentIndex:currentIndex];
    [self pageViewCurrentIndex:currentIndex];
}
/// 停止滚动
- (void)stopScrollAnimatingAtContentView:(WMContentView *)contentView{
    [self.segmentView wm_scrollViewDidEndDecelerating];
}
- (void)pageViewCurrentIndex:(NSInteger)currentIndex {
    if ([self.delegate respondsToSelector:@selector(scrollPageView:currentIndex:)]){
        [self.delegate scrollPageView:self currentIndex:currentIndex];
    }
}
#pragma mark -- scrollView KVO
- (void)addScrollViewKVO:(UIScrollView *)scrollerView{
    [scrollerView addObserver:self forKeyPath:@"contentOffset"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
}
- (void)removeScrollViewKVO:(UIScrollView *)scrollView {
    @try {
        [scrollView removeObserver:self forKeyPath:@"contentOffset"];
    }@catch (NSException *exception) {
        NSLog(@"tableView多次删除了");
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]){   //// 监听tableView滚动
        [self controlScrollViewDidScroll:object];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
#pragma mark -- getter and setter
- (UITableView *)tableView{
    if (_tableView == nil){
        _tableView = [[WMManyGesturesTableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableView.delegate= self;
        _tableView.dataSource= self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView setShowsVerticalScrollIndicator:NO];
        [_tableView setShowsHorizontalScrollIndicator:NO];
        [self addSubview:_tableView];
    }
    return _tableView;
}
- (WMSegmentView *)segmentView{
    if (_segmentView == nil){
        _segmentView = [[WMSegmentView alloc] init];
        _segmentView.delegate = self;
    }
    return _segmentView;
}
- (WMStretchableTableHeaderView *)stretchableTableHeaderView{
    if (_stretchableTableHeaderView == nil){
        _stretchableTableHeaderView = [WMStretchableTableHeaderView new];
    }
    return _stretchableTableHeaderView;
}
- (NSMutableArray<UIScrollView *> *)controlScrollViewArray{
    if (_controlScrollViewArray == nil){
        _controlScrollViewArray = [NSMutableArray array];
    }
    return _controlScrollViewArray;
}
// 头部视图下拉放大必须实现
- (void)viewDidLayoutSubviews {
    [self.stretchableTableHeaderView resizeView];
}
- (void)layoutSubviews{
    [super layoutSubviews];
    self.tableView.frame = self.bounds;
    [self wm_configTableViewHeaderView];
    if (self.segmentStyle.customSegmentSuperView == NO){
        self.segmentView.frame = CGRectMake(0, self.tableViewHeaderViewHeight, self.frame.size.width, self.segmentStyle.segmentHeight);
    }
}
- (void)dealloc {
    NSLog(@"dealloc ---- %@",self);
    [self.controlScrollViewArray enumerateObjectsUsingBlock:^(UIScrollView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeScrollViewKVO:obj];
    }];
}
@end
