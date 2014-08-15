
//
//  PagedFlowView.h
//  WhistleIm
//
//  Created by 曾长欢 on 14-1-24.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PagedFlowViewDataSource;
@protocol PagedFlowViewDelegate;


typedef enum{
    PagedFlowViewOrientationHorizontal = 0,
    PagedFlowViewOrientationVertical
}PagedFlowViewOrientation;

@interface PagedFlowView : UIView<UIScrollViewDelegate>{
    
    PagedFlowViewOrientation orientation;//默认为横向
    
    UIScrollView        *_scrollView;
    BOOL                _needsReload;
    CGSize              _pageSize; //一页的尺寸
    NSInteger           _pageCount;  //总页数
    NSInteger           _currentPageIndex;

    NSMutableArray      *_cells;
    NSRange              _visibleRange;
    NSMutableArray      *_reusableCells;//如果以后需要支持reuseIdentifier，这边就得使用字典类型了

    UIPageControl       *pageControl; //可以是自己自定义的PageControl
    
    //如果希望非当前页的大小或者透明度发生变化可以设置这两个值
    CGFloat _minimumPageAlpha;
    CGFloat _minimumPageScale;

    
    id <PagedFlowViewDataSource> __weak _dataSource;
    id <PagedFlowViewDelegate>   __weak _delegate;
}

@property(nonatomic,weak)   id <PagedFlowViewDataSource> dataSource;
@property(nonatomic,weak)   id <PagedFlowViewDelegate>   delegate;
@property(nonatomic,strong)    UIPageControl       *pageControl;
@property (nonatomic, assign) CGFloat minimumPageAlpha;
@property (nonatomic, assign) CGFloat minimumPageScale;
@property (nonatomic, assign) PagedFlowViewOrientation orientation;
@property (nonatomic, assign, readonly) NSInteger currentPageIndex;

- (void)reloadData;

//获取可重复使用的Cell
- (UIView *)dequeueReusableCell;

- (void)scrollToPage:(NSUInteger)pageNumber;

@end


@protocol  PagedFlowViewDelegate<NSObject>

- (CGSize)sizeForPageInFlowView:(PagedFlowView *)flowView;

@optional

- (void)flowView:(PagedFlowView *)flowView didScrollToPageAtIndex:(NSInteger)index;

- (void)flowView:(PagedFlowView *)flowView didTapPageAtIndex:(NSInteger)index;

@end


@protocol PagedFlowViewDataSource <NSObject>

//返回显示View的个数
- (NSInteger)numberOfPagesInFlowView:(PagedFlowView *)flowView;

//返回给某列使用的View
- (UIView *)flowView:(PagedFlowView *)flowView cellForPageAtIndex:(NSInteger)index;

@end