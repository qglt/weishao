//
//  SelectedCrowdTypeViewController.m
//  WhistleIm
//
//  Created by 管理员 on 14-2-12.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "SelectedCrowdTypeViewController.h"
#import "NBNavigationController.h"
#import "ImUtils.h"
#import "AddMembersAndPerfectInfoViewController.h"
#import "CrowdManager.h"
#import "Toast.h"

#define BUTTON_START_TAG 1000

#define MAX_LENGTH 12

@interface SelectedCrowdTypeViewController ()
<UITextFieldDelegate>
{
    CGRect m_frame;
    UITextField * m_textField;
    UIView * m_bgView;
    
    NSUInteger m_selectedIndex;
    
    BOOL m_canRequestNext;
}

@property (nonatomic, strong) UITextField * m_textField;
@property (nonatomic, strong) UIView * m_bgView;

@end

@implementation SelectedCrowdTypeViewController

@synthesize m_textField;
@synthesize m_bgView;
@synthesize m_maxLimit;

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
    m_canRequestNext = YES;
    [self setBasicCondition];
    [self createNavigationBar:YES];
    
    [self createBgView];
    [self createBgImageView];
    [self createNameLabel];
    [self createTextField];
    
    [self createTypeButtons];
    [self createFinishButton];
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
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:nil andLeftTitle:@"创建群" andRightTitle:nil andNeedCreateSubViews:needCreate];
}

- (void)leftNavigationBarButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createBgView
{
    CGFloat y = 0.0f;
    if (isIOS7) {
        y += 64.0f;
    }
    
    CGFloat height = m_frame.size.height - 64;
    self.m_bgView = [[UIView alloc] initWithFrame:CGRectMake(0, y, m_frame.size.width, height)];
    [self.view addSubview:self.m_bgView];
}

- (void)createBgImageView
{
    UIImageView * bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 8, m_frame.size.width, 45)];
    bgView.image = [UIImage imageNamed:@"whiteBg.png"];
    bgView.backgroundColor = [UIColor clearColor];
    [self.m_bgView addSubview:bgView];
}

- (void)createNameLabel
{
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, 74, 45)];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.text = @"群名称";
    label.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
    label.textColor = [ImUtils colorWithHexString:@"#262626"];
    [self.m_bgView addSubview:label];
}

- (void)createTextField
{
    self.m_textField = [[UITextField alloc] initWithFrame:CGRectMake(74, 8, m_frame.size.width, 45)];
    self.m_textField.delegate = self;
    self.m_textField.backgroundColor = [UIColor clearColor];
    self.m_textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.m_textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.m_textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.m_textField.textColor = [ImUtils colorWithHexString:@"#808080"];
    self.m_textField.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
    [self.m_textField addTarget:self action:@selector(eventEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.m_bgView addSubview:self.m_textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)eventEditingChanged:(UITextField *)sender
{
    UITextRange *markRange = sender.markedTextRange;
    int pos = [sender offsetFromPosition:markRange.start
                              toPosition:markRange.end];
    int nLength = sender.text.length - pos;
    if (nLength > MAX_LENGTH && pos==0) {
        sender.text = [sender.text substringToIndex:MAX_LENGTH];
    }
}

- (void)createTypeButtons
{
    NSArray * titleArr = [NSArray arrayWithObjects:@"社团", @"课程", @"学习", @"生活", @"兴趣", @"老乡", @"朋友", @"其他", nil];
    
    CGFloat y = 68;
    NSUInteger index = 0;
    for (NSUInteger i = 0; i < 8; i++) {
        if (i >= 4) {
            y = 133;
            index = i - 4;
        } else {
            index = i;
        }
        UIButton * button = [self createButtonsWithFrame:CGRectMake(24 + (50 + 24) * index, y, 50, 50) andTitle:[titleArr objectAtIndex:i] andImage:@"roundnessDeleteNormal.png" andSelectedImage:@"roundnessDeleteSelected.png" andTag:BUTTON_START_TAG + i];
        [self.m_bgView addSubview:button];
    }
}

- (void)createFinishButton
{
    CGFloat y = 198;
    UIButton * finishButton= [self createButtonsWithFrame:CGRectMake(0, y, m_frame.size.width, 45) andTitle:@"完成" andImage:@"blueButtonNormal.png" andSelectedImage:@"blueButtonPressed.png" andTag:2000];
    [self.m_bgView addSubview:finishButton];
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
    if (button.tag == BUTTON_START_TAG || button.tag == 2000) {
        button.selected = YES;
    }
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, button.frame.size.width, button.frame.size.height)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
    if (button.selected) {
        label.textColor = [UIColor whiteColor];
    } else {
        label.textColor = [ImUtils colorWithHexString:@"#262626"];
    }
    label.text = title;
    label.tag = tag + 500;
    [button addSubview:label];
    
    return button;
}

- (void)buttonPressed:(UIButton *)button
{
    if (button.tag < BUTTON_START_TAG + 8) {
        for (NSUInteger i = BUTTON_START_TAG; i < BUTTON_START_TAG + 8; i++) {
            UIButton * btn = (UIButton *)[self.view viewWithTag:i];
            btn.selected = NO;
            UILabel * label = (UILabel *)[self.view viewWithTag:i + 500];
            label.textColor = [ImUtils colorWithHexString:@"#262626"];
        }
        
        button.selected = YES;
        UILabel * label = (UILabel *)[self.view viewWithTag:button.tag + 500];
        label.textColor = [UIColor whiteColor];
        m_selectedIndex = button.tag - BUTTON_START_TAG;
    } else {
        [self finishButtonPressed];
    }
}

- (void)finishButtonPressed
{
    NSString * crowdName = [self.m_textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([crowdName isEqualToString:@""]) {
        [self createAlertView];
    } else {
        // 发请求
        [self createCrowd];
    }
}

- (void)createCrowd
{
    if (m_canRequestNext) {
        m_canRequestNext = NO;
        NSUInteger category = [self getCrowdCategory];
        
        [[CrowdManager shareInstance] createCrowd:self.m_textField.text icon:@"" category:category authType:0 callback:^(BOOL isSuccess, NSString *sessionID, NSString * reason) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"create crowd success == %d, sesseionID == %@, reasib == %@", isSuccess, sessionID, reason);
                
                if (isSuccess) {
                    m_canRequestNext = NO;
                    [self addMembersAndPerfectInfoWithSessionID:sessionID];
                } else {
                    m_canRequestNext = YES;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [Toast show:@"创建群失败"];
                    });
                }
            });
        }];
    }
}

- (NSUInteger)getCrowdCategory
{
    if (m_selectedIndex == 0) {
        return 11;
    } else if (m_selectedIndex == 1) {
        return 10;
    } else if (m_selectedIndex == 2) {
        return 12;
    } else if (m_selectedIndex == 3) {
        return 13;
    } else if (m_selectedIndex == 4) {
        return 14;
    } else if (m_selectedIndex == 5) {
        return 15;
    } else if (m_selectedIndex == 6) {
        return 16;
    } else if (m_selectedIndex == 7) {
        return 17;
    } else {
        return 0;
    }
}

- (NSString *)getCrowdIconStrWithCategory:(NSUInteger)category
{
    NSString * icon = nil;
    if (category == 10) {
        icon = @"crowd_default_course.png";
    } else if (category == 11) {
        icon = @"crowd_default_mass.png";
    } else if (category == 12) {
        icon = @"crowd_default_study.png";
    } else if (category == 13) {
        icon = @"crowd_default_life.png";
    } else if (category == 14) {
        icon = @"crowd_default_interest.png";
    } else if (category == 15) {
        icon = @"crowd_default_townsman.png";
    } else if (category == 16) {
        icon = @"crowd_default_friend.png";
    } else if (category == 17) {
        icon = @"crowd_default_other.png";
    } else{
        icon = @"crowd_default_class.png";
    }
    return icon;
}

- (void)addMembersAndPerfectInfoWithSessionID:(NSString *)sessionID
{
    AddMembersAndPerfectInfoViewController * controller = [[AddMembersAndPerfectInfoViewController alloc] init];
    controller.m_crowdSessionID = sessionID;
    controller.m_maxLimit = self.m_maxLimit;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)createAlertView
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil message:@"群名不能为空" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.m_textField resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createNavigationBar:NO];
    m_canRequestNext = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    m_canRequestNext = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
