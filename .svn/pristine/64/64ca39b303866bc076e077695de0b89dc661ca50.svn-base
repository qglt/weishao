//
//  LoginTextView.h
//  WhistleIm
//
//  Created by 管理员 on 13-12-2.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol LoginTextViewDelegate <NSObject>

- (void)textFieldStartEdit;
- (void)textFieldEndEdit;
- (void)userTextFieldEdit:(NSString *)userName;
@end
@interface LoginTextView : UIView
{
    UITextField * m_userTextField;
    UITextField * m_passWordTextField;
    
    __weak id <LoginTextViewDelegate> m_delegate;
}

@property (nonatomic, strong) UITextField * m_userTextField;
@property (nonatomic, strong) UITextField * m_passWordTextField;
@property (nonatomic, weak) __weak id <LoginTextViewDelegate> m_delegate;


- (void)textFieldResignFirstResponder;
@end
