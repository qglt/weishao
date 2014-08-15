//
//  NBNavigationController.m
//  MyWhistle
//
//  Created by lizuoying on 13-11-29.
//  Copyright (c) 2013年 lizuoying. All rights reserved.
//

#import "NBNavigationController.h"
#import "NavigationBarSetting.h"
#import "ImageUtil.h"
#import "ImUtils.h"

#define LEFT_DISTANCE 15.0f
#define NAVIGATION_BAR_HEIGHT 44.0f
#define LEFT_BUTTON_TAG 1000
#define RIGHT_BUTTON_TAG 2000

@interface NBNavigationController ()
{
    CGRect m_frame;
    
    UILabel * m_titleLabel;
    UIButton * m_leftButton;
    UIButton * m_rightButton;
    
    NSString * m_leftBtnType;
    NSString * m_rightBtnType;
    NSString * m_leftTitle;
    NSString * m_rightTitle;
    
    NavigationBarSetting * m_leftBtnSetting;
    NavigationBarSetting * m_rightBtnSetting;
    
    __weak UIViewController * m_controller;
    
    BOOL m_isEditState;
}

@property (nonatomic, strong) UILabel * m_titleLabel;
@property (nonatomic, strong) UIButton * m_leftButton;
@property (nonatomic, strong) UIButton * m_rightButton;

@property (nonatomic, strong) NSString * m_leftBtnType;
@property (nonatomic, strong) NSString * m_rightBtnType;
@property (nonatomic, strong) NSString * m_leftTitle;
@property (nonatomic, strong) NSString * m_rightTitle;

@property (nonatomic, strong) NavigationBarSetting * m_leftBtnSetting;
@property (nonatomic, strong) NavigationBarSetting * m_rightBtnSetting;

@property (nonatomic, weak) UIViewController * m_controller;

@end

@implementation NBNavigationController

@synthesize m_titleLabel;
@synthesize m_leftButton;
@synthesize m_rightButton;

@synthesize m_leftBtnType;
@synthesize m_rightBtnType;
@synthesize m_leftTitle;
@synthesize m_rightTitle;

@synthesize m_leftBtnSetting;
@synthesize m_rightBtnSetting;

@synthesize m_controller;

@synthesize m_delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setBasicConditions];
    [self setNavigationBGImageView];
}

- (void)setBasicConditions
{
    m_frame = self.view.bounds;
}

- (void)setNavigationBGImageView
{
//    UIImage * image = [ImageUtil getImageByImageNamed:@"navigationbar_default.png" Consider:NO];
    UIImage * image = [self getNavigationBarBGImage];
    [self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.barStyle = UIBarStyleDefault;
    [self.navigationBar setTintColor:[UIColor colorWithRed:31 /255.0f green:137 /255.0f blue:91 /255.0f alpha:1.0f]];
//    [self.navigationBar setTintColor:[UIColor clearColor]];

}

- (UIImage *)getNavigationBarBGImage
{
    UIImage * image = nil;

    NSUserDefaults * themeDefault = [NSUserDefaults standardUserDefaults];
    NSString * themeType = [themeDefault objectForKey:@"theme"];
    // navigationBarBG.png  navigationBarForIOS6.png
    
    // blue_iOS7_navBar.png
    if ([themeType isEqualToString:@"blue"]) {
        if (isIOS7) {
            image = [UIImage imageNamed:@"blue_iOS7_navBar.png"];
        } else {
            image = [UIImage imageNamed:@"blue_iOS6_navBar.png"];
        }
    } else if ([themeType isEqualToString:@"red"]) {
        if (isIOS7) {
            image = [UIImage imageNamed:@"red_iOS7_navBar.png"];
        } else {
            image = [UIImage imageNamed:@"red_iOS6_navBar.png"];
        }
    } else if ([themeType isEqualToString:@"black"]) {
        if (isIOS7) {
            image = [UIImage imageNamed:@"black_iOS7_navBar.png"];
        } else {
            image = [UIImage imageNamed:@"black_iOS6_navBar.png"];
        }
    }
    
    return image;
}

- (UIColor *)getThemeBGColor
{
    UIColor * color = nil;
    
    NSUserDefaults * themeDefault = [NSUserDefaults standardUserDefaults];
    NSString * themeType = [themeDefault objectForKey:@"theme"];
    // navigationBarBG.png  navigationBarForIOS6.png
    
    // blue_iOS7_navBar.png
    if ([themeType isEqualToString:@"blue"]) {
        color = [ImUtils colorWithHexString:@"#2F87B9"];
    } else if ([themeType isEqualToString:@"red"]) {
        color = [ImUtils colorWithHexString:@"#A90424"];
    } else if ([themeType isEqualToString:@"black"]) {
        
        color = [ImUtils colorWithHexString:@"#323232"];
    }else
    {
        color = [ImUtils colorWithHexString:@"#2F87B9"];
    }
    
    return color;
}

- (void)setNavigationController:(UIViewController *)controller leftBtnType:(NSString *)leftBtnType andRightBtnType:(NSString *)rightBtnType andLeftTitle:(NSString *)leftTitle andRightTitle:(NSString *)rightTitle andNeedCreateSubViews:(BOOL)needCreate
{
    [self setNavigationBGImageView];

    [controller.navigationItem setHidesBackButton:YES animated:YES];
    if (isIOS7) {
        controller.extendedLayoutIncludesOpaqueBars = YES;
    }
    self.m_controller = controller;
    self.m_delegate = (id)controller;
    self.m_leftBtnType = leftBtnType;
    self.m_rightBtnType = rightBtnType;
    self.m_leftTitle = leftTitle;
    self.m_rightTitle = rightTitle;
    self.m_leftBtnSetting = [self getLeftBtnSettingDictWithType:self.m_leftBtnType];
    self.m_rightBtnSetting = [self getRightBtnSettingDictWithType:self.m_rightBtnType];
    
    if (needCreate) {
    
        UIView * titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, m_frame.size.width, NAVIGATION_BAR_HEIGHT)];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        titleView.autoresizesSubviews = YES;
        
        if (self.m_leftTitle || self.m_rightTitle) {
            self.m_titleLabel = [self createTitleLabel:self.m_leftTitle];
            [titleView addSubview:self.m_titleLabel];
        }
        
        if (self.m_leftBtnType) {
            [self createLeftButton];
            [titleView addSubview:self.m_leftButton];
        }
        
        if (self.m_rightBtnType) {
            [self createRightButton];
            [titleView addSubview:self.m_rightButton];
        }

        controller.navigationItem.titleView = titleView;
    }
}

- (UILabel *)createTitleLabel:(NSString *)leftTitle
{
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 0, m_frame.size.width - 16 - 88, NAVIGATION_BAR_HEIGHT)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = leftTitle;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:20.0f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    return titleLabel;
}

- (void)createLeftButton
{
    if (self.m_leftBtnType && [self.m_leftBtnType length] > 0 && self.m_leftBtnSetting) {
        self.m_leftButton = [self createButtonWithNavigationBarSetting:self.m_leftBtnSetting];
    }
}

- (void)createRightButton
{
    if (self.m_rightBtnType && [self.m_rightBtnType length] > 0 && self.m_rightBtnSetting) {
        self.m_rightButton = [self createButtonWithNavigationBarSetting:self.m_rightBtnSetting];
    }
}

- (NavigationBarSetting *)getLeftBtnSettingDictWithType:(NSString *)buttonType
{
    NavigationBarSetting * setting = [[NavigationBarSetting alloc] init];
    setting.m_buttonSide = @"leftSide";
    setting.m_btnType = buttonType;
    if (buttonType && [buttonType length] > 0) {
        if ([buttonType isEqualToString:@"add"]) {
            setting.m_frame = NSStringFromCGRect(CGRectMake(0, 0, 44, 44));
            setting.m_normalImage = @"addNavItemNormal.png";
            setting.m_selectedImage = @"addNavItemSelected.png";
        } else if ([buttonType isEqualToString:@"more"]) {
            setting.m_frame = NSStringFromCGRect(CGRectMake(0, 0, 44, 44));
            setting.m_normalImage = @"moreNavItemNormal.png";
            setting.m_selectedImage = @"moreNavItemSelected.png";
        } else if ([buttonType isEqualToString:@"create"]) {
            setting.m_frame = NSStringFromCGRect(CGRectMake(0, 0, 44, 44));
            setting.m_normalImage = @"GroupNavItemNormal.png";
            setting.m_selectedImage = @"GroupNavItemSelected.png";
        } else if ([buttonType isEqualToString:@"delete"]) {
            setting.m_frame = NSStringFromCGRect(CGRectMake(0, 0, 44, 44));
            setting.m_normalImage = @"clearNavItemNormal.png";
            setting.m_selectedImage = @"clearNavItemSelected.png";
        } else if ([buttonType isEqualToString:@"edit"] || [buttonType isEqualToString:@"send"] || [buttonType isEqualToString:@"finish"] || [buttonType isEqualToString:@"back"] || [buttonType isEqualToString:@"search"]) {
            setting.m_frame = NSStringFromCGRect(CGRectMake(0, 0, 44, 44));
        }
    }
    return setting;
}

- (NavigationBarSetting *)getRightBtnSettingDictWithType:(NSString *)buttonType
{
    NavigationBarSetting * setting = [[NavigationBarSetting alloc] init];
    setting.m_buttonSide = @"rightSide";
    setting.m_btnType = buttonType;
    
    if (buttonType && [buttonType length] > 0) {
        if ([buttonType isEqualToString:@"add"]) {
            setting.m_frame = NSStringFromCGRect(CGRectMake(m_frame.size.width - 44 - 16, 0, 44, 44));
            setting.m_normalImage = @"addNavItemNormal.png";
            setting.m_selectedImage = @"addNavItemSelected.png";

        } else if ([buttonType isEqualToString:@"more"]) {
            setting.m_frame = NSStringFromCGRect(CGRectMake(m_frame.size.width - 44 - 16, 0, 44, 44));
            setting.m_normalImage = @"moreNavItemNormal.png";
            setting.m_selectedImage = @"moreNavItemSelected.png";
        } else if ([buttonType isEqualToString:@"create"]) {
            setting.m_frame = NSStringFromCGRect(CGRectMake(m_frame.size.width - 44 - 16, 0, 44, 44));
            setting.m_normalImage = @"GroupNavItemNormal.png";
            setting.m_selectedImage = @"GroupNavItemSelected.png";
        } else if ([buttonType isEqualToString:@"delete"]) {
            setting.m_frame = NSStringFromCGRect(CGRectMake(m_frame.size.width - 44 - 16, 0, 44, 44));
            setting.m_normalImage = @"clearNavItemNormal.png";
            setting.m_selectedImage = @"clearNavItemSelected.png";
        } else if ([buttonType isEqualToString:@"edit"] || [buttonType isEqualToString:@"send"] || [buttonType isEqualToString:@"finish"] || [buttonType isEqualToString:@"back"] || [buttonType isEqualToString:@"setUp"] || [buttonType isEqualToString:@"search"]) {
            setting.m_frame = NSStringFromCGRect(CGRectMake(m_frame.size.width - 44 - 16, 0, 44, 44));
        }
    }
    
    return setting;
}

- (UIButton *)createButtonWithNavigationBarSetting:(NavigationBarSetting *)setting
{
    NSString * btnType = setting.m_btnType;
    NSString * frameStr = setting.m_frame;
    CGRect frame = CGRectFromString(frameStr);
    NSString * normalImage = setting.m_normalImage;
    NSString * selectedImage = setting.m_selectedImage;
    NSString * buttonSide = setting.m_buttonSide;
    NSLog(@"normalImage == %@", normalImage);
    NSLog(@"selectedImage == %@", selectedImage);

    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.backgroundColor = [UIColor clearColor];
    if ([buttonSide isEqualToString:@"leftSide"]) {
        button.tag = LEFT_BUTTON_TAG;
    } else if ([buttonSide isEqualToString:@"rightSide"]){
        button.tag = RIGHT_BUTTON_TAG;
    }
    
    if ([btnType isEqualToString:@"add"] || [btnType isEqualToString:@"more"] || [btnType isEqualToString:@"create"] || [btnType isEqualToString:@"delete"]) {
        [button setBackgroundImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:selectedImage] forState:UIControlStateSelected];
        [button setBackgroundImage:[UIImage imageNamed:selectedImage] forState:UIControlStateHighlighted];
    } else if ([btnType isEqualToString:@"edit"] || [btnType isEqualToString:@"send"] || [btnType isEqualToString:@"back"] || [btnType isEqualToString:@"finish"] || [btnType isEqualToString:@"setUp"] || [btnType isEqualToString:@"search"]) {
        if ([btnType isEqualToString:@"edit"]) {
            button.hidden = YES;
        }
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        
        if ([buttonSide isEqualToString:@"leftSide"]) {
            label.textAlignment = NSTextAlignmentLeft;
            label.frame = CGRectMake(7, 0, 44 - 7, 44);
        } else if ([buttonSide isEqualToString:@"rightSide"]){
            label.textAlignment = NSTextAlignmentRight;
            label.frame = CGRectMake(0, 0, 44 - 7, 44);
        }
        
        label.textColor = [UIColor whiteColor];
        NSString * text = nil;
        if ([btnType isEqualToString:@"edit"]) {
            text = @"编辑";
        } else if ([btnType isEqualToString:@"send"]) {
            text = @"发送";
        } else if ([btnType isEqualToString:@"back"]) {
            text = NSLocalizedString(@"back", @"");
        } else if ([btnType isEqualToString:@"finish"]) {
            text = @"完成";
        } else if ([btnType isEqualToString:@"setUp"]) {
            text = @"创建";
        } else if ([btnType isEqualToString:@"search"]) {
            text = @"搜索";
        }
        label.text = text;
        label.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:15.0f];
        [button addSubview:label];
        
        // 创建--文字
        if ([btnType isEqualToString:@"setUp"]) {
            [self setLabelAlpha:button];
            button.enabled = NO;
        }
    }
    
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(setLabelAlpha:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(resetLabelAlpha:) forControlEvents:UIControlEventTouchCancel];
    [button addTarget:self action:@selector(resetLabelAlpha:) forControlEvents:UIControlEventTouchUpOutside];
    return button;
}

// 右侧创建按钮置灰和可否点击
- (void)resetSetUpButtonStateWithEnable:(BOOL)isEnable
{
    if (isEnable) {
        [self resetLabelAlpha:self.m_rightButton];
    } else {
        [self setLabelAlpha:self.m_rightButton];
    }
    
    self.m_rightButton.enabled = isEnable;
}

- (void)resetLabelAlpha:(UIButton *)button
{
    NavigationBarSetting * setting = nil;
    if (button.tag == LEFT_BUTTON_TAG) {
        setting = self.m_leftBtnSetting;
    } else if (button.tag == RIGHT_BUTTON_TAG) {
        setting = self.m_rightBtnSetting;
    }
    if ([setting.m_btnType isEqualToString:@"edit"] || [setting.m_btnType isEqualToString:@"send"] || [setting.m_btnType isEqualToString:@"back"] || [setting.m_btnType isEqualToString:@"finish"] || [setting.m_btnType isEqualToString:@"setUp"]) {
        for (UIView * view in button.subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                UILabel * label = (UILabel *)view;
                label.alpha = 1.0f;
            }
        }
    }
}

- (void)setLabelAlpha:(UIButton *)button
{
    NavigationBarSetting * setting = nil;
    if (button.tag == LEFT_BUTTON_TAG) {
        setting = self.m_leftBtnSetting;
    } else if (button.tag == RIGHT_BUTTON_TAG) {
        setting = self.m_rightBtnSetting;
    }
    if ([setting.m_btnType isEqualToString:@"edit"] || [setting.m_btnType isEqualToString:@"send"] || [setting.m_btnType isEqualToString:@"back"] || [setting.m_btnType isEqualToString:@"finish"] || [setting.m_btnType isEqualToString:@"setUp"]) {
        for (UIView * view in button.subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                UILabel * label = (UILabel *)view;
                label.alpha = 0.3f;
            }
        }
    }
}

- (void)buttonPressed:(UIButton *)button
{
    NavigationBarSetting * setting = nil;
    if (button.tag == LEFT_BUTTON_TAG) {
        setting = self.m_leftBtnSetting;
    } else if (button.tag == RIGHT_BUTTON_TAG) {
        setting = self.m_rightBtnSetting;
    }
    
    if ([setting.m_btnType isEqualToString:@"edit"]) {
        
        m_isEditState = !m_isEditState;
        [self.m_delegate editButtonPressedWithState:m_isEditState];
        [self resetButtonLabelWithBtn:button];
        
    } else {
        if (button.tag == LEFT_BUTTON_TAG) {
            [self.m_delegate leftNavigationBarButtonPressed:button];
        } else if (button.tag == RIGHT_BUTTON_TAG) {
            [self.m_delegate rightNavigationBarButtonPressed:button];
        }
    }

//    [self resetButtonLabelWithBtn:button];
    
    [self resetLabelAlpha:button];
}

// UIViewController ----> Switch button And Title
//- (void)resetTitleAndSwitchButtonWithSelectedState:(BOOL)selected
//{
//    [self resetSwitchButtonWithSelectedState:selected];
//    [self resetTitleWithButtonSelectedState:selected];
//}

// UIViewController ----> Switch button
//- (void)resetSwitchButtonWithSelectedState:(BOOL)selected
//{
//    UIButton * switchButton = [self getTitleViewSwitchBtn];
//    switchButton.selected = selected;
//    if (selected) {
//        [switchButton setBackgroundImage:[ImageUtil getImageByImageNamed:self.m_rightBtnSetting.m_selectedImage Consider:NO] forState:UIControlStateNormal];
//    } else {
//        [switchButton setBackgroundImage:[ImageUtil getImageByImageNamed:self.m_rightBtnSetting.m_normalImage Consider:NO] forState:UIControlStateNormal];
//    }
//}

// UIViewController ----> UINavigationController ----> Title
//- (void)resetTitleWithButtonSelectedState:(BOOL)selected
//{
//    UIView * view = self.m_controller.navigationItem.titleView;
//    for (UIView * subView in [view subviews]) {
//        if ([subView isKindOfClass:[UILabel class]]) {
//            UILabel * label = (UILabel *)subView;
//            if (selected) {
//                label.text = self.m_rightTitle;
//            } else {
//                label.text = self.m_leftTitle;
//            }
//        }
//    }
//}

// UINavigationController ----> Edit button
- (void)resetButtonLabelWithBtn:(UIButton *)button
{
    for (UIView * subView in [button subviews]) {
        if ([subView isKindOfClass:[UILabel class]]) {
            UILabel * label = (UILabel *)subView;
            if (m_isEditState) {
                label.text = @"完成";
            } else {
                label.text = @"编辑";
            }
        }
    }
}

// UIViewController ----> Edit button
- (void)resetEditButtonLabel:(BOOL)hidden andIsEditState:(BOOL)state
{
    m_isEditState = state;
    UIButton * editButton = editButton = [self getTitleViewEditBtn];
    [self resetButtonLabelWithBtn:editButton];
    editButton.hidden = hidden;
}

- (UIButton *)getTitleViewEditBtn
{
    UIButton * editButton = nil;
    NSUInteger tag = 0;
    UIView * view = self.m_controller.navigationItem.titleView;
    if ([self.m_leftBtnType isEqualToString:@"edit"]) {
        tag = LEFT_BUTTON_TAG;
    } else if ([self.m_rightBtnType isEqualToString:@"edit"]) {
        tag = RIGHT_BUTTON_TAG;
    }
    
    for (UIView * subView in [view subviews]) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton * button = (UIButton *)subView;
            if (button.tag == tag) {
                editButton = button;
            }
        }
    }
    
    return editButton;
}

- (void)resetDeleteButtonHidden:(BOOL)hidden
{
    UIButton * deleteButton = [self getTitleViewDeleteBtn];
    deleteButton.hidden = hidden;
}

-(UIButton *)getTitleViewDeleteBtn
{
    UIButton * deleteButton = nil;
    NSUInteger tag = 0;
    UIView * view = self.m_controller.navigationItem.titleView;
    if ([self.m_rightBtnType isEqualToString:@"delete"]) {
        tag = RIGHT_BUTTON_TAG;
    }
    
    for (UIView * subView in [view subviews]) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton * button = (UIButton *)subView;
            if (button.tag == tag) {
                deleteButton = button;
            }
        }
    }
    return deleteButton;
}

- (void)showEditButton
{
    UIButton * editButton = nil;
    NSUInteger tag = 0;
    UIView * view = self.m_controller.navigationItem.titleView;
    if ([self.m_rightBtnType isEqualToString:@"edit"]) {
        tag = RIGHT_BUTTON_TAG;
    }
    
    for (UIView * subView in [view subviews]) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton * button = (UIButton *)subView;
            if (button.tag == tag) {
                editButton = button;
                editButton.hidden = NO;
            }
        }
    }
}

//- (UIButton *)getTitleViewSwitchBtn
//{
//    UIButton * switchButton = nil;
//    NSUInteger tag = 0;
//    UIView * view = self.m_controller.navigationItem.titleView;
//   
//    if ([self.m_leftBtnType isEqualToString:@"personalSwitch"] || [self.m_leftBtnType isEqualToString:@"noticeSwitch"] || [self.m_leftBtnType isEqualToString:@"friendSwitch"]) {
//        tag = LEFT_BUTTON_TAG;
//    } else if ([self.m_rightBtnType isEqualToString:@"personalSwitch"] || [self.m_rightBtnType isEqualToString:@"noticeSwitch"] || [self.m_rightBtnType isEqualToString:@"friendSwitch"]) {
//        tag = RIGHT_BUTTON_TAG;
//    }
//    
//    for (UIView * subView in [view subviews]) {
//        if ([subView isKindOfClass:[UIButton class]]) {
//            UIButton * button = (UIButton *)subView;
//            if (button.tag == tag) {
//                switchButton = button;
//            }
//        }
//    }
//    
//    return switchButton;
//}

// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//- (void)setNavigationController:(UIViewController *)controller leftBtnType:(NSString *)leftBtnType andRightBtnType:(NSString *)rightBtnType andLeftTitle:(NSString *)leftTitle andRightTitle:(NSString *)rightTitle andNeedCreateSubViews:(BOOL)needCreate hiddenRightButton:(BOOL)needHidden
//{
//    [controller.navigationItem setHidesBackButton:YES animated:YES];
//    if (isIOS7) {
//        controller.extendedLayoutIncludesOpaqueBars = YES;
//    }
//    self.m_controller = controller;
//    self.m_delegate = (id)controller;
//    self.m_leftBtnType = leftBtnType;
//    self.m_rightBtnType = rightBtnType;
//    self.m_leftTitle = leftTitle;
//    self.m_rightTitle = rightTitle;
//    self.m_leftBtnSetting = [self getLeftBtnSettingDictWithType:self.m_leftBtnType];
//    self.m_rightBtnSetting = [self getRightBtnSettingDictWithType:self.m_rightBtnType];
//    if (needCreate) {
//        UIView * titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, m_frame.size.width, NAVIGATION_BAR_HEIGHT)];
//        titleView.backgroundColor = [UIColor clearColor];
//        
//        if (self.m_leftTitle || self.m_rightTitle) {
//            self.m_titleLabel = [self createTitleLabel:self.m_leftTitle];
//            [titleView addSubview:self.m_titleLabel];
//        }
//        
//        if (self.m_leftBtnType) {
//            [self createLeftButton];
//            [titleView addSubview:self.m_leftButton];
//        }
//        
//        if (self.m_rightBtnType) {
//            [self createRightButton];
//            [titleView addSubview:self.m_rightButton];
//        }
//        
//        if (needHidden) {
//            self.m_rightButton.hidden = YES;
//            [self.m_rightButton setBackgroundImage:[ImageUtil getImageByImageNamed:nil Consider:NO] forState:UIControlStateNormal];
//            [self.m_rightButton setBackgroundImage:[ImageUtil getImageByImageNamed:nil Consider:NO] forState:UIControlStateSelected];
//            [self.m_rightButton setBackgroundImage:[ImageUtil getImageByImageNamed:nil Consider:NO] forState:UIControlStateHighlighted];
//        }
//        
//        controller.navigationItem.titleView = titleView;
//    }
//    
//    if (needHidden == NO) {
//        self.m_rightButton.hidden = NO;
//    }
//}

//- (void)resetRightBarButtonBGImageWithType:(NSString *)type
//{
//    NSString * normalBtnImage = nil;
//    NSString * selectedBtnImage = nil;
//    if ([type isEqualToString:@"add"]) {
//        normalBtnImage = @"icon_add.png";
//        selectedBtnImage = @"icon_add_pre.png";
//    } else if ([type isEqualToString:@"chat"]) {
//        normalBtnImage = @"icon_chat.png";
//        selectedBtnImage = @"icon_chat_pre.png";
//    }
//    
//    [self.m_rightButton setBackgroundImage:[ImageUtil getImageByImageNamed:normalBtnImage Consider:NO] forState:UIControlStateNormal];
//    [self.m_rightButton setBackgroundImage:[ImageUtil getImageByImageNamed:selectedBtnImage Consider:NO] forState:UIControlStateSelected];
//    [self.m_rightButton setBackgroundImage:[ImageUtil getImageByImageNamed:selectedBtnImage Consider:NO] forState:UIControlStateHighlighted];
//}
// --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
