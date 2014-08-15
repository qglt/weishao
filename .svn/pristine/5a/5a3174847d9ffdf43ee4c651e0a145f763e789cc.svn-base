//
//  CreateCrowdViewController.m
//  WhistleIm
//
//  Created by 管理员 on 14-2-12.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "CreateCrowdViewController.h"
#import "NBNavigationController.h"
#import "ImUtils.h"
#import "SelectedCrowdTypeViewController.h"
#import "CrowdManager.h"

@interface CreateCrowdViewController ()
<UITextViewDelegate>
{
    CGRect m_frame;
    UIImageView * m_agreeImageView;
    UIButton * m_selectedBtn;
    BOOL m_isSelected;
    UITextView * m_textView;
    
    BOOL m_nextTimeEnable;
    NSUInteger m_maxLimit;
    
    // 是否可以点击同意button
    BOOL m_canPreAgreeBtn;
    
    // 是否达到上限
    BOOL m_upToMaxLimit;
}

@property (nonatomic, strong) UIImageView * m_agreeImageView;
@property (nonatomic, strong) UIButton * m_selectedBtn;
@property (nonatomic, strong) UITextView * m_textView;

@end

@implementation CreateCrowdViewController

@synthesize m_agreeImageView;
@synthesize m_selectedBtn;
@synthesize m_textView;

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
    
    [self createAgreeButton];
    [self getCreateCrowdLimitsOfAuthority];
    [self createWebView];
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
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:@"setUp" andLeftTitle:@"微哨群服务协议" andRightTitle:nil andNeedCreateSubViews:needCreate];
}

- (void)leftNavigationBarButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightNavigationBarButtonPressed:(UIButton *)button
{
    if (m_upToMaxLimit) {
        [self createAlertViewWithMessage:@"可创建的群已经达到上限"];
    } else {
        [self selectedCrowdType];
    }
}

- (void)selectedCrowdType
{
    SelectedCrowdTypeViewController * controller = [[SelectedCrowdTypeViewController alloc] init];
    controller.m_maxLimit = m_maxLimit;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)getCreateCrowdLimitsOfAuthority
{
    [[CrowdManager shareInstance] getCreateCrowdSetting:^(BOOL success, BOOL canCreate, NSUInteger totalNum, NSString * content) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.m_selectedBtn.enabled = YES;
            NSLog(@"create authority success == %d, canCreate == %d, totoalNum == %d, content == %@", success, canCreate, totalNum, content);
            if (success) {
                m_upToMaxLimit = !canCreate;
                m_maxLimit = totalNum;
            }
        });
    }];
}

- (void)createAlertViewWithMessage:(NSString *)message
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)createWebView
{
    CGFloat y = 0.0f;
    if (isIOS7) {
        y += 64.0f;
    }
    
    CGFloat height = m_frame.size.height - 64 - 50;
    UIWebView * webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, y, m_frame.size.width, height)];
    webView.backgroundColor = [UIColor clearColor];
    
    [[CrowdManager shareInstance] getCrowdPolicy:^(NSString * content) {
        NSLog(@"contentcontent == %@", content);
        dispatch_async(dispatch_get_main_queue(), ^{
            [webView loadHTMLString:content baseURL:nil];
        });
    }];

    [self.view addSubview:webView];
}

// moreUnselected.png  moreSelected.png
- (void)createAgreeButton
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGFloat y = m_frame.size.height - 50.0f;
    if (isIOS7 == NO) {
        y -= 64.0f;
    }
    button.frame = CGRectMake(0, y, m_frame.size.width, 50);
    button.backgroundColor = [ImUtils colorWithHexString:@"#D9D9D9"];
    [button addTarget:self action:@selector(agreeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(110, 0, button.frame.size.width - 110, button.frame.size.height)];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"阅读并同意本协议";
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
    label.textColor = [ImUtils colorWithHexString:@"#262626"];
    
    [button addSubview:label];
    
    self.m_selectedBtn = [[UIButton alloc] initWithFrame:CGRectMake(85.0f, 18, 15, 15)];
    [self.m_selectedBtn setBackgroundImage:[UIImage imageNamed:@"moreUnselected.png"] forState:UIControlStateNormal];
    [self.m_selectedBtn addTarget:self action:@selector(agreeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.m_selectedBtn.enabled = NO;
    [button addSubview:self.m_selectedBtn];
    
    [self.view addSubview:button];
}

- (void)agreeButtonPressed:(UIButton *)button
{
    m_isSelected = !m_isSelected;
    if (m_isSelected) {
        [self.m_selectedBtn setBackgroundImage:[UIImage imageNamed:@"moreSelected.png"] forState:UIControlStateNormal];
    } else {
        [self.m_selectedBtn setBackgroundImage:[UIImage imageNamed:@"moreUnselected.png"] forState:UIControlStateNormal];
    }
    
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav resetSetUpButtonStateWithEnable:m_isSelected];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createNavigationBar:NO];
    
    if (m_nextTimeEnable) {
        NBNavigationController * nav = (NBNavigationController *)self.navigationController;
        [nav resetSetUpButtonStateWithEnable:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    m_nextTimeEnable = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
