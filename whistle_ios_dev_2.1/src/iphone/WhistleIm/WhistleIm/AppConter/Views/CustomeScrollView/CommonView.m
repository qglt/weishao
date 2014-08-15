//
//  CommonView.m
//  WhistleIm
//
//  Created by 曾长欢 on 14-1-21.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "CommonView.h"
@implementation CommonView

- (id)initWithFrame:(CGRect)frame appInfo:(BaseAppInfo *)appInfo
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.expressInfo = appInfo;
        self.isEditing = NO;
#warning fix me 优化代码
        
        UILabel * nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 75, 60, 15)];
        nameLabel.text = @"ada";
        nameLabel.font = [UIFont systemFontOfSize:10.0];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:nameLabel];
        

        
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchedCommonView:)];
        [self addGestureRecognizer:self.tapGesture];
        self.isEditing = YES;
    }
    return self;
}

- (void)addCloseView
{
    self.isEditing = YES;
    CABasicAnimation * shakeAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    shakeAnimation.duration = 0.2;
    shakeAnimation.autoreverses = YES;
    shakeAnimation.repeatCount = MAXFLOAT;
    shakeAnimation.removedOnCompletion = NO;
    CGFloat rotation = 0.03;
    
    shakeAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DRotate(self.layer.transform, -rotation, 0.0 ,0.0 ,1.0)];
    shakeAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DRotate(self.layer.transform, rotation, 0.0 ,0.0 ,1.0)];
    [self.layer addAnimation:shakeAnimation forKey:@"shakeAnimation"];
    
//    self.closeImageView = [UIImageView expressImageViewWithFrame:CGRectMake(-10, 5, 26, 26) imageName:@"close.png"];
    
    self.closeTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchedCloseView:)];
    [self addGestureRecognizer:self.closeTapGesture];
    
    [self addSubview:self.closeImageView];
}

- (void)stopEditingCommonView
{
    [self removeGestureRecognizer:self.closeTapGesture];
    [self.layer removeAllAnimations];
    [self.closeImageView removeFromSuperview];
}

//单击手势响应方法  传快递名称
- (void) touchedCommonView:(UIGestureRecognizer *)tap
{
    if (self.isEditing)
    {
        if ([_delegate respondsToSelector:@selector(sendExpressInfoWhenTouched:)])
        {
            [_delegate sendExpressInfoWhenTouched:self.expressInfo];
        }
        
    }
    else
    {
        
        if ([_delegate respondsToSelector:@selector(sendExpressInfoWhenTouched:)])
        {
            [_delegate sendExpressInfoWhenTouched:self.expressInfo];
        }
    }
}


//单击手势 响应关闭按钮方法
- (void)touchedCloseView:(UIGestureRecognizer *)tap
{
    [self removeFromSuperview];
//    DataManager * manager = [[DataManager alloc] init];
//    [manager updateExpressDBWithId:self.expressInfo.expressId isCommon:NO];
//    [_delegate deleteCommonExpressWithExpressInfo:self.expressInfo];
}



@end
