//
//  CustomAlertView.h
//  WhistleIm
//
//  Created by 管理员 on 14-3-3.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomAlertView;
@protocol CustomAlertViewDelegate <NSObject>

- (void)customAlertView:(CustomAlertView *)customAlertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface CustomAlertView : UIView
{
    __weak id <CustomAlertViewDelegate> m_delegate;
}

@property (nonatomic, weak) __weak id <CustomAlertViewDelegate> m_delegate;
- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle confrimButtonTitle:(NSString *)confrimButtonTitle;
- (void)show;
@end
