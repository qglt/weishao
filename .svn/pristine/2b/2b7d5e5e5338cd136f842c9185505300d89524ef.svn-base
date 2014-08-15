//
//  CustomeView.m
//  vishao
//
//  Created by 曾长欢 on 14-1-13.
//  Copyright (c) 2014年 曾长欢. All rights reserved.
//

#import "CustomeView.h"
#import "TileView.h"
#import "MyRect.h"
#import "Globle.h"
#import <QuartzCore/QuartzCore.h>
#define kTileWidth  60.f
#define kTileHeight kTileWidth
#define kTileMarginLeft1 16.f
#define kTileMarginLeft2 (320.f - kTileMarginLeft1 - kTileWidth)
#define kTileMargin 10.f
#define kTileInterval 101.f


#define columns 2
#define rows 4
#define itemsPerPage 16
#define space 20
#define gridHight 100
#define gridWith 100
#define unValidIndex  -1
#define threshold 30


@interface CustomeView()
{
    // 拖动的tile的原始center坐标
    CGPoint _dragFromPoint;
    
    // 要把tile拖往的center坐标
    CGPoint _dragToPoint;
    
    // tile拖往的rect
    CGRect _dragToFrame;
    
    // 拖拽的tile是否被其他tile包含
    BOOL _isDragTileContainedInOtherTile;
    
    // 拖拽往的目标处的tile
    TileView *_pushedTile;
//    TileView *_titleView;
    


}

@end

@implementation CustomeView
@synthesize tileArray = _tileArray, scrollView = _scrollView;



- (id) initWithFrame:(CGRect)frame isHide:(BOOL)isHide
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self addSubview:self.scrollView];
        
        _isDragTileContainedInOtherTile = NO;
        //是否编辑状态
        singletap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        singletap.numberOfTapsRequired = 1;
        singletap.delegate = self;
        [self.scrollView addGestureRecognizer:singletap];
        
        
        isHideButton = isHide;
        
        if (isHideButton) {
            //创建不可编辑的应用中心VIEW
            appCenterButton = [UIButton buttonWithType:UIButtonTypeCustom];
            appCenterButton.frame = CGRectMake(16, 15, 60, 60);
            [appCenterButton setImage:[UIImage imageNamed:@"home.png"] forState:UIControlStateNormal];
            [appCenterButton addTarget:self action:@selector(pushAppController:) forControlEvents:UIControlEventTouchUpInside];
            [self.scrollView addSubview:appCenterButton];
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, 60, 20)];
            nameLabel.text = @"应用中心";
            nameLabel.textAlignment = NSTextAlignmentCenter;
            nameLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:12.0f];

            nameLabel.textColor = [UIColor colorWithRed:38/255.0 green:38/255.0 blue:38/255.0 alpha:1.0];
            [appCenterButton addSubview:nameLabel];

        }

    }
    return self;
}



- (UIImage *)createRoundPlusImageWithSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 填充黑色圆形
    [[UIColor grayColor] setFill];
    CGContextFillEllipseInRect(context, CGRectMake(0, 0, size.width, size.height));
    
    // 画白色加号
    CGContextSetLineWidth(context, 2.f);
    [[UIColor whiteColor] set];
    CGContextMoveToPoint(context, 2, size.height / 2);
    CGContextAddLineToPoint(context, size.width - 2, size.height / 2);
    CGContextMoveToPoint(context, size.width / 2, 2);
    CGContextAddLineToPoint(context, size.width / 2, size.height - 2);
    CGContextStrokePath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
#pragma mark - 控件点击
- (void)addRecommend:(NSArray *)list
{
    //先要清空里面的数据,保证frame值能随着改变
    [self.tileArray removeAllObjects];
    for (BaseAppInfo *info in list) {
        [self addViewButtonTouch:info];
    }
}
- (BOOL)addViewButtonTouch:(BaseAppInfo *)info
{
    self.userInteractionEnabled = YES;
    _titleView = [[TileView alloc] initWithTarget:self action:Nil info:info editable:NO isLongPress:NO];
    _titleView.userInteractionEnabled = YES;
    _titleView.frame = [self createFrameLayoutTile];
    
    _titleView.delegate = self;
    _titleView.appName.text = info.appName;
     // 动态增长contectSize
    if (_titleView.frame.origin.y + kTileHeight + kTileMargin > self.scrollView.frame.size.height) {
        self.scrollView.contentSize = CGSizeMake(320, _titleView.frame.origin.y + kTileHeight + kTileMargin * 4+(64+40)+kTileHeight);
        NSLog(@"%f",_titleView.frame.origin.y + kTileHeight + kTileMargin * 2);
    }
    [self.scrollView addSubview:_titleView];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    [self.tileArray addObject:_titleView];
    [self scrollToBottomWithScrollView:self.scrollView];
    return YES;
}

- (void) addCollect:(NSArray *)list
{
    [self.tileArray removeAllObjects];
    for (BaseAppInfo *info in list) {
        [self addCollectButton:info];
    }
}

- (BOOL) addCollectButton:(BaseAppInfo *)info
{

    
    self.userInteractionEnabled = YES;
    _titleView = [[TileView alloc] initWithTarget:self action:Nil info:info editable:YES isLongPress:YES];
    _titleView.userInteractionEnabled = YES;
    [self.tileArray addObject:_titleView];
    NSLog(@"self.tileArrayXXXX = %d",[self.tileArray count]);

    _titleView.frame = [self createCollectFrameLayoutTile];
    
    _titleView.delegate = self;
    _titleView.appName.text = info.appName;
    
    // 动态增长contectSize
    if (_titleView.frame.origin.y + kTileHeight + kTileMargin > self.scrollView.frame.size.height) {
        self.scrollView.contentSize = CGSizeMake(320, _titleView.frame.origin.y + kTileHeight + kTileMargin * 4+(64+40)+kTileHeight);
        NSLog(@"%f",_titleView.frame.origin.y + kTileHeight + kTileMargin * 2);
    }
    [self.scrollView addSubview:_titleView];
    self.scrollView.backgroundColor = [UIColor whiteColor];
   
    [self scrollToBottomWithScrollView:self.scrollView];
    return YES;

}
- (CGRect)createCollectFrameLayoutTile
{
    int number = [self.tileArray count];
    //起始位置应该60＋16＋16
    //列数取模，行数相除
    CGRect rect;
    //如果收藏个数大于3，另起一行
    NSLog(@"%d",[self.tileArray count]);
    if (number > 3) {
        rect = CGRectMake(kTileMarginLeft1 + 76 * (number % 4), kTileMarginLeft1 + (kTileInterval) * (number / 4), kTileWidth, kTileWidth+kTileMarginLeft1);

    }else if (number <= 3)
    {
        rect = CGRectMake(kTileMarginLeft1 + 76 * (number % 4), kTileMarginLeft1 + (kTileInterval) * (number / 4), kTileWidth, kTileWidth+kTileMarginLeft1);
    }
    
    return rect;

    
    
}
- (void)removeFromSuperviewToRootView
{
    
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void) removeCollectSubviews
{
    NSMutableArray *array = [NSMutableArray array];
    //遍历子view，移除掉除第1个之外的所有view
    for (int i = 0; i < [self.scrollView.subviews count]; i++) {
        if ([self.scrollView.subviews[i] isKindOfClass:[TileView class]]) {
            [array addObject:self.scrollView.subviews[i]];
        }
    }
    for (UIView* v in array) {
        [v removeFromSuperview];
    }
    NSLog(@"self.scrollView.subviews count = %d",[self.scrollView.subviews count]);
}
#pragma mark - TileViewDelegate

- (void)sendExpressInfoWhenTouched:(BaseAppInfo *)info
{
    [self.customeDelegate pushVC:info];
}

- (void)deleteCommonExpressWithExpressInfo:(BaseAppInfo *)expressInfo
{
    //将此方法传到控制器里执行
    [self.customeDelegate deleteCollect:expressInfo];
    
}

- (void)gridItemDidClicked:(TileView *)gridItem{
    NSLog(@"grid at index %d did clicked",gridItem.index);
    if (gridItem.index == [_tileArray count]-1) {
//        [self Addbutton];
    }
}
- (void)gridItemDidDeleted:(TileView *)gridItem atIndex:(NSInteger)index{
    NSLog(@"grid at index %d did deleted",gridItem.index);
    TileView * item = [_tileArray objectAtIndex:index];
    
    [_tileArray removeObjectAtIndex:index];
    [UIView animateWithDuration:0.2 animations:^{
        CGRect lastFrame = item.frame;
        CGRect curFrame;
        for (int i=index; i < [_tileArray count]; i++) {
            TileView *temp = [_tileArray objectAtIndex:i];
            curFrame = temp.frame;
            [temp setFrame:lastFrame];
            lastFrame = curFrame;
            [temp setIndex:i];
        }
//        [addbutton setFrame:lastFrame];
    }];
    [item removeFromSuperview];
    item = nil;
}
- (void) gridItemDidEnterEditingMode:(TileView *)gridItem
{
    for (TileView *item in _tileArray) {
        [item enableEditing];
    }
    isEditing = YES;
}

- (void) gridItemDidMoved:(TileView *)gridItem withLocation:(CGPoint)point moveGestureRecognizer:(UILongPressGestureRecognizer *)recognizer
{
//    CGRect frame = gridItem.frame;
//    CGPoint _point = [recognizer locationInView:self.scrollView];
//    CGPoint pointInView = [recognizer locationInView:self];
//    frame.origin.x = _point.x - point.x;
//    frame.origin.y = _point.y - point.y;
//    gridItem.frame = frame;
//    NSLog(@"gridItemframe:%f,%f",frame.origin.x,frame.origin.y);
//    NSLog(@"move to point(%f,%f)",point.x,point.y);
//    
//    NSInteger toIndex = [self indexOfLocation:_point];
//    NSInteger fromIndex = gridItem.index;
//    NSLog(@"fromIndex:%d toIndex:%d",fromIndex,toIndex);
//    
//    if (toIndex != unValidIndex && toIndex != fromIndex) {
//        TileView *moveItem = [_tileArray objectAtIndex:toIndex];
//        [self.scrollView sendSubviewToBack:moveItem];
//        [UIView animateWithDuration:0.2 animations:^{
//            CGPoint origin = [self orginPointOfIndex:fromIndex];
//            //NSLog(@"origin:%f,%f",origin.x,origin.y);
//            moveItem.frame = CGRectMake(origin.x, origin.y, moveItem.frame.size.width, moveItem.frame.size.height);
//        }];
//        [self exchangeItem:fromIndex withposition:toIndex];
//        //移动
//        
//    }
//    //翻页
//    if (pointInView.x >= _scrollView.frame.size.width - threshold) {
//        [_scrollView scrollRectToVisible:CGRectMake(_scrollView.contentOffset.x + _scrollView.frame.size.width, 0, _scrollView.frame.size.width, _scrollView.frame.size.height) animated:YES];
//    }else if (pointInView.x < threshold) {
//        [_scrollView scrollRectToVisible:CGRectMake(_scrollView.contentOffset.x - _scrollView.frame.size.width, 0, _scrollView.frame.size.width, _scrollView.frame.size.height) animated:YES];
//    }

}

- (void) gridItemDidEndMoved:(TileView *)gridItem withLocation:(CGPoint)point moveGestureRecognizer:(UILongPressGestureRecognizer *)recognizer
{
//    CGPoint _point = [recognizer locationInView:self.scrollView];
//    NSInteger toIndex = [self indexOfLocation:_point];
//    if (toIndex == unValidIndex) {
//        toIndex = gridItem.index;
//    }
//    CGPoint origin = [self orginPointOfIndex:toIndex];
//    [UIView animateWithDuration:0.2 animations:^{
//        gridItem.frame = CGRectMake(origin.x, origin.y, gridItem.frame.size.width, gridItem.frame.size.height);
//    }];
//    NSLog(@"gridItem index:%d",gridItem.index);
}
#pragma mark-- private
- (NSInteger)indexOfLocation:(CGPoint)location{
    NSInteger index;
    NSInteger _page = location.x / 320;
    NSInteger row =  location.y / (gridHight + 20);
    NSInteger col = (location.x - _page * 320) / (gridWith + 20);
    if (row >= rows || col >= columns) {
        return  unValidIndex;
    }
    index = itemsPerPage * _page + row * 2 + col;
    if (index >= [_tileArray count]) {
        return  unValidIndex;
    }
    
    return index;
}

- (CGPoint)orginPointOfIndex:(NSInteger)index{
    CGPoint point = CGPointZero;
    if (index > [_tileArray count] || index < 0) {
        return point;
    }else{
        NSInteger _page = index / itemsPerPage;
        NSInteger row = (index - _page * itemsPerPage) / columns;
        NSInteger col = (index - _page * itemsPerPage) % columns;
        
        point.x = _page * 320 + col * gridWith + (col +1) * space;
        point.y = row * gridHight + (row + 1) * space;
        return  point;
    }
}

- (void)exchangeItem:(NSInteger)oldIndex withposition:(NSInteger)newIndex
{
    ((TileView *)[_tileArray objectAtIndex:oldIndex]).index = newIndex;
    ((TileView *)[_tileArray objectAtIndex:newIndex]).index = oldIndex;
    [_tileArray exchangeObjectAtIndex:oldIndex withObjectAtIndex:newIndex];
}

- (void) handleSingleTap:(UITapGestureRecognizer *) gestureRecognizer{
    if (isEditing) {
        for (TileView *item in _tileArray) {
            [item disableEditing];
        }
//        [addbutton disableEditing];
    }
    isEditing = NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if(touch.view != _scrollView){
        return NO;
    }else
        return YES;
}
- (CGRect)createFrameLayoutTile
{
    int number = [self.tileArray count];

    //列数取模，行数相除
    CGRect rect = CGRectMake(kTileMarginLeft1 + 76 * (number % 4), kTileMarginLeft1 + (kTileInterval) * (number / 4), kTileWidth, kTileWidth+kTileMarginLeft1);

    NSLog(@"rect.origin.y = %f",rect.origin.y);

    return rect;
}
// 若使用此方法，则self.scrollView.subviews会出现UIImageView
// 所以只能自己建立一个数组记录scrollView上的所有tileView
- (void)scrollToBottomWithScrollView:(UIScrollView *)scrollView
{
    if (scrollView.contentSize.height - 480 > 0)
    {
        [scrollView setContentOffset:CGPointMake(0, self.scrollView.contentSize.height - 480) animated:YES];
    }
}


#pragma mark - getter

- (NSMutableArray *)tileArray
{
    if (!_tileArray)
    {
        _tileArray = [[NSMutableArray alloc] init];
    }
    return _tileArray;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView)
    {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-64-40)];
    }
    return _scrollView;
}


#pragma mark pushAppCentent
- (void)pushAppController:(UIButton *)sender
{
    [self.customeDelegate pushAppCententController];
    
}
@end
