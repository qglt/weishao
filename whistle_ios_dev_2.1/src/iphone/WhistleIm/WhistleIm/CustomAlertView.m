//
//  CustomAlertView.m
//  WhistleIm
//
//  Created by 管理员 on 14-3-3.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "CustomAlertView.h"
#import "ImUtils.h"

#define BUTTON_HEIGHT 45.0f

static BOOL m_canShowNext = YES;

@interface CustomAlertView ()
{
    CGRect m_frame;
    
    UIImageView * m_bgImageView;
    UILabel * m_contentLabel;
    NSString * m_title;
    NSString * m_cancelBtnTitle;
    NSString * m_confrimBtnTitle;
    
    UIView * m_whiteBGView;
    
    UIButton * m_cancelBtn;
    UIButton * m_confrimBtn;
    
    CGFloat m_contentHeight;
    
    UIWindow * m_window;
    
    UILabel * m_titleLabel;
    
    NSString * m_message;
    
    BOOL m_hasTitle;
}

@property (nonatomic, strong) UIImageView * m_bgImageView;
@property (nonatomic, strong) UILabel * m_contentLabel;
@property (nonatomic, strong) NSString * m_title;
@property (nonatomic, strong) NSString * m_cancelBtnTitle;
@property (nonatomic, strong) NSString * m_confrimBtnTitle;
@property (nonatomic, strong) UIView * m_whiteBGView;
@property (nonatomic, strong) UIButton * m_cancelBtn;
@property (nonatomic, strong) UIButton * m_confrimBtn;
@property (nonatomic, strong) UIWindow * m_window;
@property (nonatomic, strong) UILabel * m_titleLabel;
@property (nonatomic, strong) NSString * m_message;

@end

@implementation CustomAlertView

@synthesize m_bgImageView;
@synthesize m_contentLabel;
@synthesize m_delegate;
@synthesize m_title;
@synthesize m_cancelBtnTitle;
@synthesize m_confrimBtnTitle;
@synthesize m_whiteBGView;
@synthesize m_cancelBtn;
@synthesize m_confrimBtn;
@synthesize m_window;
@synthesize m_titleLabel;
@synthesize m_message;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle confrimButtonTitle:(NSString *)confrimButtonTitle
{
    if (m_canShowNext) {
        self = [super init];
        if (self) {
            // Initialization code
            self.m_title = title;
            self.m_message = message;
            self.m_delegate = delegate;
            self.m_cancelBtnTitle = cancelButtonTitle;
            self.m_confrimBtnTitle = confrimButtonTitle;
            
            [self setBasicCondition];

            NSString * actualTitle = [self.m_title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (self.m_title && actualTitle.length > 0) {
                m_hasTitle = YES;
            }
            
            m_contentHeight = [self getContentHeight];

            [self createBGImageView];
            [self createWhiteBGView];
            if (m_hasTitle) {
                [self createTitleLabel];
            }
            [self createTransverseLine];
            
            if (self.m_cancelBtnTitle && self.m_confrimBtnTitle && self.m_cancelBtnTitle.length > 0 && self.m_confrimBtnTitle.length > 0) {
                [self createPortraitLine];
            }

            [self createContentLabel];
            [self createButtons];
        }
        
        m_canShowNext = NO;
        return self;

    } else {
        return nil;
    }
}

- (void)setBasicCondition
{
    m_frame = [[UIScreen mainScreen] bounds];
    self.frame = m_frame;
    self.alpha = 0.0f;
}

- (CGFloat)getContentHeight
{
    CGFloat height = 0.0f;
    UIFont * font = [UIFont fontWithName:@"STHeitiSC-Thin" size:12.0f];
    NSLog(@"message == %@", self.m_message);
    CGSize textSize = [self.m_message sizeWithFont:font constrainedToSize:CGSizeMake(m_frame.size.width - 50 - 60, 10000)  lineBreakMode:NSLineBreakByWordWrapping];
    NSLog(@"textSize == %@", NSStringFromCGSize(textSize));
    height = textSize.height;
    return height;
}

- (void)createBGImageView
{
    self.m_bgImageView = [[UIImageView alloc] initWithFrame:m_frame];
    self.m_bgImageView.image = [UIImage imageNamed:@"customAlertBG.png"];
    self.m_bgImageView.userInteractionEnabled = YES;
    self.m_bgImageView.clipsToBounds = YES;
    [self addSubview:self.m_bgImageView];
}

- (void)createWhiteBGView
{
    CGFloat height = 0.0f;
    if (m_hasTitle) {
        height = 38 + m_contentHeight + 12 + 45 + 0.5;
    } else {
        height = 12 + m_contentHeight + 12 + 45 + 0.5;
    }
    self.m_whiteBGView = [[UIView alloc] initWithFrame:CGRectMake(25, (m_frame.size.height - height) / 2.0f, m_frame.size.width - 50, height)];
    self.m_whiteBGView.backgroundColor = [UIColor whiteColor];
    self.m_whiteBGView.layer.cornerRadius = 10.0f;
    self.m_whiteBGView.clipsToBounds = YES;
    [self addSubview:self.m_whiteBGView];
}

- (void)createTitleLabel
{
    self.m_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, m_frame.size.width - 50, 38.0f)];
    self.m_titleLabel.backgroundColor = [UIColor clearColor];
    self.m_titleLabel.text = self.m_title;
    self.m_titleLabel.textAlignment = NSTextAlignmentCenter;
    self.m_titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:15.0f];
    self.m_titleLabel.textColor = [ImUtils colorWithHexString:@"#262626"];
    [self.m_whiteBGView addSubview:self.m_titleLabel];
}

- (void)createTransverseLine
{
    CGFloat y = 0.0f;
    if (m_hasTitle) {
        y = 38.0f + m_contentHeight + 12;
    } else {
        y = 12 + m_contentHeight + 12;
    }
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(0, y, m_frame.size.width - 50.0f, 0.5f)];
    lineView.backgroundColor = [ImUtils colorWithHexString:@"#e1e1e1"];
    [self.m_whiteBGView addSubview:lineView];
}

- (void)createPortraitLine
{
    CGFloat y = 0.0f;
    if (m_hasTitle) {
        y = 38.0f + m_contentHeight + 12;
    } else {
        y = 12 + m_contentHeight + 12;
    }
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake((m_frame.size.width - 50 - 0.5) / 2.0f, y, 0.5, BUTTON_HEIGHT)];
    lineView.backgroundColor = [ImUtils colorWithHexString:@"#e1e1e1"];
    [self.m_whiteBGView addSubview:lineView];
}

- (void)createContentLabel
{
    CGFloat y = 0.0f;
    if (m_hasTitle) {
        y = 38.0f;
    } else {
        y = 12.0f;
    }
    self.m_contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, y, m_frame.size.width - 50 - 60, m_contentHeight)];
    self.m_contentLabel.backgroundColor = [UIColor clearColor];
    self.m_contentLabel.text = self.m_message;
    self.m_contentLabel.numberOfLines = 0;
    self.m_contentLabel.textAlignment = NSTextAlignmentCenter;
    self.m_contentLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:12.0f];
    self.m_contentLabel.textColor = [ImUtils colorWithHexString:@"#262626"];
    [self.m_whiteBGView addSubview:self.m_contentLabel];
}

// rightBottomSelected.png    rightBottomNormal.png
// leftBottomSelected.png     leftBottomNormal.png
// bottomNormal.png  bottomSelected.png
- (void)createButtons
{
    CGRect frame = CGRectZero;
    CGFloat y = 0.0f;
    if (m_hasTitle) {
        y = m_contentHeight + 38 + 12 + 0.5;
    } else {
        y = 12 + 12 + m_contentHeight + 0.5;
    }
    
    CGFloat width = 0.0f;
    if (self.m_cancelBtnTitle && self.m_confrimBtnTitle) {
        width = (m_frame.size.width - 50 - 0.5) / 2.0f;
        frame = CGRectMake(0, y, width, BUTTON_HEIGHT);
        self.m_cancelBtn = [self createButtonsWithFrame:frame andTitle:self.m_cancelBtnTitle andImage:@"leftBottomNormal.png" andSelectedImage:@"leftBottomSelected.png" andTag:1000];
        [self.m_whiteBGView addSubview:self.m_cancelBtn];

        frame = CGRectMake(width + 0.5, y, width, BUTTON_HEIGHT);
        self.m_confrimBtn = [self createButtonsWithFrame:frame andTitle:self.m_confrimBtnTitle andImage:@"rightBottomNormal.png" andSelectedImage:@"rightBottomSelected.png" andTag:1001];
        [self.m_whiteBGView addSubview:self.m_confrimBtn];
    } else if (self.m_cancelBtnTitle || self.m_confrimBtnTitle) {
        NSString * title = nil;
        if (self.m_cancelBtnTitle) {
            title = self.m_cancelBtnTitle;
        } else if (self.m_confrimBtnTitle) {
            title = self.m_confrimBtnTitle;
        }
        width = m_frame.size.width - 50;
        frame = CGRectMake(0, y, width, BUTTON_HEIGHT);
        UIButton * button = [self createButtonsWithFrame:frame andTitle:title andImage:@"bottomNormal.png" andSelectedImage:@"bottomSelected.png" andTag:1000];
        [self.m_whiteBGView addSubview:button];
    }
}

- (UIButton *)createButtonsWithFrame:(CGRect)frame andTitle:(NSString *)title andImage:(NSString *)imagePath andSelectedImage:(NSString *)selectedImagePath andTag:(NSUInteger)tag
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:imagePath] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:selectedImagePath] forState:UIControlStateSelected];
    [button setBackgroundImage:[UIImage imageNamed:selectedImagePath] forState:UIControlStateHighlighted];
    button.frame = frame;
    button.tag = tag;
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, button.frame.size.width, button.frame.size.height)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [ImUtils colorWithHexString:@"#262626"];
    label.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
    label.highlightedTextColor = [UIColor whiteColor];
    label.text = title;
    [button addSubview:label];
    
    return button;
}

- (void)buttonPressed:(UIButton *)button
{
    m_canShowNext = YES;
    [self hidden];
    [m_delegate customAlertView:self clickedButtonAtIndex:button.tag - 1000];
}

- (void)show
{
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.m_window = window;
    window.windowLevel = UIWindowLevelStatusBar + 1;
    window.opaque = NO;
    [self.m_window addSubview:self];
    [self.m_window makeKeyAndVisible];
    
    self.alpha = 0.0f;
    [UIView animateWithDuration:0.125 animations:^{
        self.m_whiteBGView.layer.transform = CATransform3DMakeScale(1.1, 1.1, 1.0);
        self.alpha = 0.5f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.125 animations:^{
            self.m_whiteBGView.layer.transform = CATransform3DIdentity;
            self.alpha = 1.0f;
        } completion:^(BOOL finished) {
          
        }];
    }];
}

- (void)hidden
{
    [UIView animateWithDuration:0.1 animations:^{
        self.m_whiteBGView.layer.transform = CATransform3DMakeScale(1.1, 1.1, 1.0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 animations:^{
            self.m_whiteBGView.layer.transform = CATransform3DIdentity;
            self.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [self cleanup];
        }];
    }];
}

- (void)cleanup {
	self.m_whiteBGView.layer.transform = CATransform3DIdentity;
	self.m_whiteBGView.transform = CGAffineTransformIdentity;
    [self removeFromSuperview];
    self.m_window = nil;
    
	// rekey main AppDelegate window
	[[[[UIApplication sharedApplication] delegate] window] makeKeyWindow];
}


@end
