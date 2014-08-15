//
//  ChangeThemeViewController.m
//  WhistleIm
//
//  Created by 管理员 on 14-1-15.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "ChangeThemeViewController.h"
#import "NBNavigationController.h"
#import "ImUtils.h"

#define BUTTON_TAG_START 1000
#define INDICATOR_TAG_START 2000

#define THEME_NUMBERS 3
#define BUTTON_WIDTH 80.0f

@interface ChangeThemeViewController ()
{
    CGRect m_frame;
    UIView * m_bgView;
}

@property (nonatomic, strong) UIView * m_bgView;

@end

@implementation ChangeThemeViewController

@synthesize m_bgView;

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
    [self setBasicCondition];
    [self createNavigationBar:YES];
    [self createBGView];
    [self createColorButtons];
}

- (void)setBasicCondition
{
    self.view.backgroundColor = [ImUtils colorWithHexString:@"#F0F0F0"];
    m_frame = [[UIScreen mainScreen] bounds];
    
    if (isIOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:nil andLeftTitle:@"主题" andRightTitle:nil andNeedCreateSubViews:needCreate];
}

- (void)leftNavigationBarButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createBGView
{
    CGFloat y = 0.0f;
    
    if (isIOS7) {
        y += 64.0f;
    }
    CGFloat height = m_frame.size.height - 20 - 44 - 49;
    
    self.m_bgView = [[UIView alloc] initWithFrame:CGRectMake(0, y, m_frame.size.width, height)];
    self.m_bgView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.m_bgView];
}

- (void)createColorButtons
{
    NSUserDefaults * themeDefault = [NSUserDefaults standardUserDefaults];
    NSString * themeType = [themeDefault objectForKey:@"theme"];
    
    NSLog(@"themeType == %@", themeType);
    
    CGFloat x = 0.0f;
    CGFloat y = 15.0f;
    NSArray * btnImagesArr = [NSArray arrayWithObjects:@"blue_theme.png", @"red_theme.png", @"black_theme.png", nil];
    for (NSUInteger i = 0; i < THEME_NUMBERS; i++) {

        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor clearColor];
        button.tag = BUTTON_TAG_START + i;
       
        if (i % 3 == 0) {
            x = 15.0f;
        } else {
            x = 15.0f + (BUTTON_WIDTH + 25.0f) * i;
        }
        
        if (i / 3 > 0) {
            y = 15.0f + (BUTTON_WIDTH + 25.0f) * (i / 3);
        } else {
            y = 15.0f;
        }
        
        [button setBackgroundImage:[UIImage imageNamed:[btnImagesArr objectAtIndex:i]] forState:UIControlStateNormal];
        
        BOOL hidden = YES;

        if ([themeType isEqualToString:@"blue"]) {
            if (i == 0) {
                hidden = NO;
            }
        } else if ([themeType isEqualToString:@"red"]) {
            if (i == 1) {
                hidden = NO;
            }
        } else if ([themeType isEqualToString:@"black"]) {
            if (i == 2) {
                hidden = NO;
            }
        }
        
        NSLog(@"hidden == %d", hidden);
        [button addSubview:[self getSelectedImageView:hidden andTag:INDICATOR_TAG_START + i]];
        button.frame = CGRectMake(x, y, BUTTON_WIDTH, BUTTON_WIDTH);
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.m_bgView addSubview:button];
    }
}

- (UIImageView *)getSelectedImageView:(BOOL)hidden andTag:(NSUInteger)tag
{
    UIImageView * selectedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_WIDTH)];
    selectedImageView.image = [UIImage imageNamed:@"themeSelected.png"];
    selectedImageView.hidden = hidden;
    selectedImageView.tag = tag;
    selectedImageView.userInteractionEnabled = YES;
    return selectedImageView;
}

- (void)buttonPressed:(UIButton *)button
{
    [self changeSelectedIndicatorWithButton:button];
    [self setThemeDefaultWithButton:button];
    
    [self createNavigationBar:NO];
    [self postChangeThemeNotification];
}

- (void)changeSelectedIndicatorWithButton:(UIButton *)button
{
    for (NSUInteger i = INDICATOR_TAG_START; i < INDICATOR_TAG_START + THEME_NUMBERS; i++) {
        UIImageView * indicatorImageView = (UIImageView *)[self.m_bgView viewWithTag:i];
        
        if (button.tag - BUTTON_TAG_START == i - INDICATOR_TAG_START) {
            indicatorImageView.hidden = NO;
        } else {
            indicatorImageView.hidden = YES;
        }
    }
}

- (void)setThemeDefaultWithButton:(UIButton *)button
{
    NSString * themeType = nil;

    if (button.tag - BUTTON_TAG_START == 0) {
        themeType = @"blue";
    } else if (button.tag - BUTTON_TAG_START == 1) {
        themeType = @"red";
    } else if (button.tag - BUTTON_TAG_START == 2) {
        themeType = @"black";
    }
    NSUserDefaults * themeDefault = [NSUserDefaults standardUserDefaults];
    [themeDefault setObject:themeType forKey:@"theme"];
    [themeDefault synchronize];
    
    themeType = [themeDefault objectForKey:@"theme"];
    NSLog(@"themeType after selected == %@", themeType);
}

- (void)postChangeThemeNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTheme" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createNavigationBar:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
