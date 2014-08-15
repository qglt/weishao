//
//  TileView.h
//  IPhoneTest
//
//  Created by 曾长欢 on 14-1-13.
//  Copyright (c) 2014年 曾长欢. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseAppInfo.h"
typedef enum{
    TileViewNormalMode = 0,
    TileViewEditingMode = 1,
}Mode;
@protocol TileViewDelegate;
@interface TileView : UIView
{
    CGPoint _long_point;//long press point
    UIButton *button;

}
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, assign) BOOL isRemovable;
@property (nonatomic, assign) BOOL isLongPressEdit;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic,strong) UILabel *appName;
@property (nonatomic, strong) UIButton *deleteButton;
@property(weak,nonatomic)id<TileViewDelegate> delegate;
@property (nonatomic, strong) BaseAppInfo *info;

- (id)initWithTarget:(id)target action:(SEL)action info:(BaseAppInfo *)info editable:(BOOL)removable isLongPress:(BOOL) isLongPress;
- (void) enableEditing;
- (void) disableEditing;
@end


@protocol TileViewDelegate <NSObject>

@optional

- (void)sendExpressInfoWhenTouched:(BaseAppInfo *)expressInfo;
- (void)deleteCommonExpressWithExpressInfo:(BaseAppInfo *)expressInfo;

- (void) gridItemDidClicked:(TileView *) gridItem;
- (void) gridItemDidEnterEditingMode:(TileView *) gridItem;
- (void) gridItemDidDeleted:(TileView *) gridItem atIndex:(NSInteger)index;
- (void) gridItemDidMoved:(TileView *) gridItem withLocation:(CGPoint)point moveGestureRecognizer:(UILongPressGestureRecognizer*)recognizer;
- (void) gridItemDidEndMoved:(TileView *) gridItem withLocation:(CGPoint)point moveGestureRecognizer:(UILongPressGestureRecognizer*) recognizer;
@end;