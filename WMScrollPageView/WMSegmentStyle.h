//
//  WMSegmentStyle.h
//  WMScrollPageView
//
//  Created by Sper on 2018/1/20.
//  Copyright © 2018年 WM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger , wm_itemSizeStyle){
    wm_itemSizeStyle_equal_width,   /// 默认是切换项等宽
    wm_itemSizeStyle_equal_textSize   /// 根据文本计算宽度
};
typedef NS_ENUM(NSInteger ,wm_scrollLineWidthStyle) {
    wm_scrollLineWidthStyle_equal_text, /// 滚动条和按钮文字一样宽
    wm_scrollLineWidthStyle_equal_item  /// 滚动条和按钮一样宽
};

@interface WMSegmentStyle : NSObject
/// 是否自定义导航控件显示父控件 ， 默认是 NO
@property (nonatomic, assign) BOOL customSegmentSuperView;
#pragma mark -- 显示标题的样式
/** 是否显示滚动条 默认为YES*/
@property (assign, nonatomic, getter=isShowMoveLine) BOOL showMoveLine;
/** 是否缩放标题 默认为NO*/
@property (assign, nonatomic, getter=isScaleTitle) BOOL scaleTitle;
/** 是否颜色渐变 默认为NO*/
@property (assign, nonatomic, getter=isChangeTitleColor) BOOL changeTitleColor;
/** 是否显示附加的按钮 默认为NO*/
@property (assign, nonatomic, getter=isShowExtraButton) BOOL showExtraButton;
/// 默认是 yes
@property (assign, nonatomic, getter=isAllowShowBottomLine) BOOL allowShowBottomLine;
/** 滚动条的高度 默认为2 */
@property (assign, nonatomic) CGFloat scrollLineHeight;
/// 滚动条的宽度 默认是0 会根据文字计算宽度
@property (assign, nonatomic) CGFloat scrollLineWidth;
/// 滚动条的宽度 只要设置了滚动条scrollLineWidth  这个属性就没有用
@property (assign, nonatomic) wm_scrollLineWidthStyle scrollLineWidthStyle;
/** 滚动条的颜色 */
@property (strong, nonatomic) UIColor *scrollLineColor;
/** 标题之间的间隙 默认为10.0 */
@property (assign, nonatomic) CGFloat titleMargin;
/** 标题的字体 默认为17 */
@property (strong, nonatomic) UIFont *titleFont;
/** 标题缩放倍数, 默认1.2 */
@property (assign, nonatomic) CGFloat titleBigScale;
/** 标题一般状态的颜色 */
@property (strong, nonatomic) UIColor *normalTitleColor;
/** 标题选中状态的颜色 */
@property (strong, nonatomic) UIColor *selectedTitleColor;
/** segmentVIew的高度, 默认是44 */
@property (assign, nonatomic) CGFloat segmentHeight;
/// 底部分割线高度 默认是0.5
@property (assign, nonatomic) CGFloat bottomLineHeight;
/// 底部分割线颜色 默认是灰色
@property (strong, nonatomic) UIColor *bottomLineColor;
/// 选择项宽度样式 默认是屏幕宽度平分
@property (assign, nonatomic) wm_itemSizeStyle itemSizeStyle;
/// 正常情况下背景颜色 默认是nil
@property (nonatomic, strong) UIColor *normalBgColor;
/// 选中状态下背景颜色  默认是nil
@property (nonatomic, strong) UIColor *selectedBgColor;
/// 边框颜色
@property (nonatomic, strong) UIColor *borderColor;
/// 边框圆角
@property (nonatomic, assign) CGFloat borderRadius;
#pragma mark -- 显示内容的样式
/// 外面是否显示导航栏 默认是 YES
@property (assign, nonatomic , getter=isShowNavigationBar) BOOL showNavigationBar;
/// 头部是否可以下拉放大 默认是 YES
@property (assign, nonatomic) BOOL allowStretchableHeader;
@end
