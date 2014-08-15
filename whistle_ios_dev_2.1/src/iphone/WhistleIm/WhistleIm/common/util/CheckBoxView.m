//
//  CheckBoxView.m
//  WhistleIm
//
//  Created by 管理员 on 13-12-2.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "CheckBoxView.h"
#import "ImageUtil.h"
@interface CheckBoxView ()
{
    CGRect m_frame;
    UIButton * m_button;
    NSString * m_title;
    UIImageView * m_checkBoxImageView;
}

@property (nonatomic, strong) UIButton * m_button;
@property (nonatomic, strong) NSString * m_title;
@property (nonatomic, strong) UIImageView * m_checkBoxImageView;


@end

@implementation CheckBoxView

@synthesize m_button;
@synthesize m_title;
@synthesize m_checkBoxImageView;

@synthesize m_delegate;

- (id)initWithFrame:(CGRect)frame withTitle:(NSString *)title
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        m_frame = frame;
        self.m_title = title;
        [self createBoxImageView];
        [self createTitleLabelWithTitle:title];
    }
    return self;
}

- (void)createBoxImageView
{
    UIImage * image = nil; // savepass_check.png  savepass_uncheck.png
    
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    NSNumber * remember = [userDefault objectForKey:self.m_title];
    if (remember == nil) {
        remember = [NSNumber numberWithBool:NO];
    }
    
    if ([remember boolValue]) {
        image = [ImageUtil getImageByImageNamed:@"savepass_check.png" Consider:NO];
    } else {
        image = [ImageUtil getImageByImageNamed:@"savepass_uncheck.png" Consider:NO];
    }
    
    self.m_button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.m_button.frame = CGRectMake(0, 0, m_frame.size.width, m_frame.size.height);
    self.m_button.backgroundColor = [UIColor clearColor];
    self.m_button.selected = [remember boolValue];
    self.m_button.clipsToBounds = YES;
    [self.m_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.m_checkBoxImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 23, 24)];
    self.m_checkBoxImageView.image = image;
    self.m_checkBoxImageView.userInteractionEnabled = YES;
    [self addSubview:self.m_checkBoxImageView];
    [self.m_button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.m_button];
}

- (void)buttonPressed:(id)sender
{
    UIButton * button = (UIButton *)sender;
    button.selected = !button.selected;
    
    UIImage * image = nil;
    if (button.selected) {
        image = [ImageUtil getImageByImageNamed:@"savepass_check.png" Consider:NO];
    } else {
        image = [ImageUtil getImageByImageNamed:@"savepass_uncheck.png" Consider:NO];
    }
    self.m_checkBoxImageView.image = image;
    
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:[NSNumber numberWithBool:button.selected] forKey:self.m_title];
    [userDefault synchronize];
    
    [m_delegate checkBoxButtonPressed:button];
}

- (void)createTitleLabelWithTitle:(NSString *)title
{
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(23, 0, m_frame.size.width - 23, 24)];
    label.textAlignment = NSTextAlignmentLeft;
    label.text = title;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:143.0f / 255.0f green:143.0f / 255.0f blue:143.0f / 255.0f alpha:1.0f];
    [self addSubview:label];
}

- (void)resetButtonSelectedState:(BOOL)isSelected
{
    self.m_button.selected = isSelected;
    UIImage * image = nil;
    if (self.m_button.selected) {
        image = [ImageUtil getImageByImageNamed:@"savepass_check.png" Consider:NO];
    } else {
        image = [ImageUtil getImageByImageNamed:@"savepass_uncheck.png" Consider:NO];
    }
    self.m_checkBoxImageView.image = image;
}

@end
