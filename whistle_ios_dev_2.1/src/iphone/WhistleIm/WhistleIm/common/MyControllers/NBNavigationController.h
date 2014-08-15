//
//  NBNavigationController.h
//  MyWhistle
//
//  Created by lizuoying on 13-11-29.
//  Copyright (c) 2013年 lizuoying. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NBNavigationControllerDelegate <NSObject>

@optional
- (void)leftNavigationBarButtonPressed:(UIButton *)button;
- (void)rightNavigationBarButtonPressed:(UIButton *)button;
- (void)editButtonPressedWithState:(BOOL)isEditState;

@end

@interface NBNavigationController : UINavigationController
{
    __weak id <NBNavigationControllerDelegate> m_delegate;
}

@property (nonatomic, weak) __weak id <NBNavigationControllerDelegate> m_delegate;

- (void)setNavigationController:(UIViewController *)controller leftBtnType:(NSString *)leftBtnType andRightBtnType:(NSString *)rightBtnType andLeftTitle:(NSString *)leftTitle andRightTitle:(NSString *)rightTitle andNeedCreateSubViews:(BOOL)needCreate;

- (void)resetEditButtonLabel:(BOOL)hidden andIsEditState:(BOOL)state;
- (void)resetDeleteButtonHidden:(BOOL)hidden;
- (UIColor *)getThemeBGColor;

- (void)resetSetUpButtonStateWithEnable:(BOOL)isEnable;

// edit 按钮是否显示
- (void)showEditButton;

//- (void)resetTitleAndSwitchButtonWithSelectedState:(BOOL)selected;

//------start ----
//- (void)setNavigationController:(UIViewController *)controller leftBtnType:(NSString *)leftBtnType andRightBtnType:(NSString *)rightBtnType andLeftTitle:(NSString *)leftTitle andRightTitle:(NSString *)rightTitle andNeedCreateSubViews:(BOOL)needCreate hiddenRightButton:(BOOL)needHidden;
//- (void)resetRightBarButtonBGImageWithType:(NSString *)type;
//------end-------


@end
