//
//  LoginTextView.m
//  WhistleIm
//
//  Created by 管理员 on 13-12-2.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "LoginTextView.h"
#import "ImageUtil.h"

#define TEXT_VIEW_NUMBERS 2
#define ACCOUNT_TEXTFIELD_TAG 1000
#define PASSWORD_TEXTFIELD_TAG 2000

@interface LoginTextView ()
<UITextFieldDelegate>
{
    CGRect m_frame;
}
@end

@implementation LoginTextView

@synthesize m_userTextField;
@synthesize m_passWordTextField;

@synthesize m_delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
        m_frame = frame;
        [self createBGImageView];
        [self createLineImageView];
        [self createTextField];
    }
    return self;
}

- (void)createBGImageView
{
    for (NSUInteger i = 0; i < TEXT_VIEW_NUMBERS; i++) {
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (m_frame.size.height / 2.0f) * i, m_frame.size.width, m_frame.size.height / 2.0f)];
        if (i == 0) {
            imageView.image = [ImageUtil getImageByImageNamed:@"username_background.png" Consider:NO];
        } else if (i == 1) {
            imageView.image = [ImageUtil getImageByImageNamed:@"password_background.png" Consider:NO];
        }
        
        [self addSubview:imageView];
    }
}

- (void)createLineImageView
{
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (m_frame.size.height - 1.0f) / 2.0f, m_frame.size.width, 1.0f)];
    imageView.image = [ImageUtil getImageByImageNamed:@"seperator.png" Consider:NO];
    [self addSubview:imageView];
}

- (void)createTextField
{
    self.m_userTextField = [self getTextFieldWithFrame:CGRectMake(40, 0, m_frame.size.width - 40, m_frame.size.height / 2.0f) andPlaceholder:@"账号"];
    self.m_userTextField.tag = ACCOUNT_TEXTFIELD_TAG;
    [self addSubview:self.m_userTextField];
    self.m_passWordTextField = [self getTextFieldWithFrame:CGRectMake(40, m_frame.size.height / 2.0f, m_frame.size.width - 40, m_frame.size.height / 2.0f) andPlaceholder:@"密码"];
    self.m_passWordTextField.secureTextEntry = YES;
    [self addSubview:self.m_passWordTextField];
}

- (UITextField *)getTextFieldWithFrame:(CGRect)frame andPlaceholder:(NSString *)placeholder
{
    UITextField * textField = [[UITextField alloc] initWithFrame:frame];
    textField.delegate = self;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.placeholder = placeholder;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    return textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [m_delegate textFieldEndEdit];
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [m_delegate textFieldStartEdit];
}

- (void)textFieldDidChanged:(NSNotification *)notification
{
    UITextField * textField = notification.object;
    if (textField.tag == ACCOUNT_TEXTFIELD_TAG) {
        [m_delegate userTextFieldEdit:self.m_userTextField.text];
    }
}

- (void)textFieldResignFirstResponder
{
    [m_delegate textFieldEndEdit];
    [self.m_userTextField resignFirstResponder];
    [self.m_passWordTextField resignFirstResponder];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

@end
