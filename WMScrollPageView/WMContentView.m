//
//  WMContentView.m
//  WMScrollPageView
//
//  Created by Sper on 2018/1/20.
//  Copyright © 2018年 WM. All rights reserved.
//

#import "WMContentView.h"
@interface WMManyGesturesCollectionView : UICollectionView<UIGestureRecognizerDelegate>
@end

@implementation WMManyGesturesCollectionView
//允许同时识别多个手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (self.contentOffset.x <= 0) {
        return YES;
    }
    return NO;
}
@end
@interface WMContentView()<UIGestureRecognizerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
/// 显示的子控制器数组
@property (nonatomic , strong) NSArray *showViewControllers;
/// 控制子控制器水平方向滚动视图
@property (nonatomic , strong) WMManyGesturesCollectionView *collectionView;
/// 当前选中页码
@property (nonatomic , assign) NSInteger selectedIndex;
/// 是否正在翻页
@property (nonatomic , assign) BOOL isChangeingPage;
@end

@implementation WMContentView
+ (instancetype)cellForTableView:(UITableView *)tableView delegate:(id<WMContentViewDelegate>)delegate {
    WMContentView * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WMContentView class])];
    if (cell == nil){
        cell = [[WMContentView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([WMContentView class])];
        [cell setSelectionStyle:(UITableViewCellSelectionStyleNone)];
        [cell.contentView addSubview:cell.collectionView];
    }
    cell.delegate = delegate;
    return cell;
}
- (void)setDelegate:(id<WMContentViewDelegate>)delegate{
    _delegate = delegate;
    [self wm_removeOldViewAndData];
    [self wm_addNewViewAndData];
    [self.collectionView reloadData];
}
- (void)wm_removeOldViewAndData{
    /// 刷新数据的时候一定要清除之前的数据
    [self.showViewControllers enumerateObjectsUsingBlock:^(UIViewController * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        /// 从父控制器移除
        if (obj.parentViewController){
            [obj removeFromParentViewController];
        }
    }];
    self.showViewControllers = nil;
}
- (void)wm_addNewViewAndData{
    NSInteger count = 0;
    if ([self.delegate respondsToSelector:@selector(numberOfCountInContentView:)]){
        count = [self.delegate numberOfCountInContentView:self];
    }
    NSMutableArray *controllersArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0 ; i < count; i++) {
        UIViewController * vc;
        if ([self.delegate respondsToSelector:@selector(contentView:viewControllerAtIndex:)]){
            vc = [self.delegate contentView:self viewControllerAtIndex:i];
        }
        if (vc && [vc isKindOfClass:[UIViewController class]]){
            [controllersArray addObject:vc];
        }
    }
    self.showViewControllers = controllersArray;
}
- (void)wm_changePageWithIndex:(NSInteger)index{
    if (index < self.showViewControllers.count){
        self.isChangeingPage = YES;
        _selectedIndex = index;
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        self.isChangeingPage = NO;
    }
}
#pragma mark -- 滚动监听
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.isChangeingPage) return;
    CGFloat pageWidth = self.frame.size.width;
    CGFloat offPercent = scrollView.contentOffset.x;
    
    if (offPercent <= 0 || (offPercent + pageWidth) >= scrollView.contentSize.width) return;
    _selectedIndex = (offPercent + pageWidth / 2) / pageWidth;
    if ([self.delegate respondsToSelector:@selector(contentView:adjustUIWithProgress:currentIndex:)]){
        [self.delegate contentView:self adjustUIWithProgress:offPercent / pageWidth currentIndex:_selectedIndex];
    }
}
/// 滚动完成之后更新数据
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if ([self.delegate respondsToSelector:@selector(stopScrollAnimatingAtContentView:)]){
        [self.delegate stopScrollAnimatingAtContentView:self];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([self.delegate respondsToSelector:@selector(stopScrollAnimatingAtContentView:)]){
        [self.delegate stopScrollAnimatingAtContentView:self];
    }
}

#pragma mark -- UICollectionViewDelegate and UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.showViewControllers.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < self.showViewControllers.count){
        UIViewController *viewController = self.showViewControllers[indexPath.row];
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        viewController.view.frame = cell.contentView.bounds;
        [cell.contentView addSubview:viewController.view];
        [self wm_getScrollViewWithIndex:indexPath.row];
//        [self setCanScroll:self.canScroll];
    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return self.frame.size;
}

#pragma mark -- 滚动监听相关
- (void)addCollectionViewKVO{
    [self.collectionView addObserver:self
                          forKeyPath:@"panGestureRecognizer.state"
                             options:NSKeyValueObservingOptionNew
                             context:nil];
}
- (void)removeCollectionViewKVO{
    @try {
        [self.collectionView removeObserver:self forKeyPath:@"panGestureRecognizer.state"];
    }@catch (NSException *exception) {
        NSLog(@"collectionView多次删除了");
    }
}

#pragma mark -- 监听拖拽手势的回调
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"panGestureRecognizer.state"]){
        if ([self.delegate respondsToSelector:@selector(contentView:pageControlScroll:)]){
            [self.delegate contentView:self pageControlScroll:object];
        }
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
/// 根据当前显示的控制器得到滚动视图
- (void)wm_getScrollViewWithIndex:(NSInteger)index{
    if (index < self.showViewControllers.count){
        UIViewController *viewControl = self.showViewControllers[index];
        if (viewControl.isViewLoaded){
            if ([viewControl.view isKindOfClass:[UIScrollView class]]){
                [self controlScrollViewAddScrollKVO:viewControl.view index:index];
            }else {
                [viewControl.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [self controlScrollViewAddScrollKVO:obj index:index];
                }];
            }
        }
    }
}
/// 获取控制器的滚动视图添加监听
- (void)controlScrollViewAddScrollKVO:(UIView *)view index:(CGFloat)index{
    UIScrollView *scrollerView;
    if ([view isKindOfClass:[UIScrollView class]]){
        if (view.superview && ([view.superview isKindOfClass:[UITableView class]] || [view.superview isKindOfClass:[UICollectionView class]])){
            scrollerView = (UIScrollView *)view.superview;
        }else {
            scrollerView = (UIScrollView *)view;
        }
        if (scrollerView){
            /// 当前控制器的滚动视图
            if ([self.delegate respondsToSelector:@selector(contentView:controllerScrollView:)]) {
                [self.delegate contentView:self controllerScrollView:scrollerView];
            }
        }
    }
}
#pragma mark -- getter and setter
- (UICollectionView *)collectionView{
    if (_collectionView == nil){
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[WMManyGesturesCollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.bounces = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
        //监听拖动手势
        [self addCollectionViewKVO];
    }
    return _collectionView;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    self.collectionView.frame = self.bounds;
    /// 默认滚动到指定页码
    NSInteger index = 0;
    if ([self.delegate respondsToSelector:@selector(defaultSelectedIndexAtContentView:)]){
        index = [self.delegate defaultSelectedIndexAtContentView:self];
    }
    [self wm_changePageWithIndex:index];
}
- (void)dealloc {
    NSLog(@"dealloc ---- %@",self);
    //清除监听
    [self removeCollectionViewKVO];
}
@end
