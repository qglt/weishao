//
//  NotificationViewController.m
//  MyWhistle
//
//  Created by lizuoying on 13-10-15.
//  Copyright (c) 2013年 lizuoying. All rights reserved.
//

#import "NotificationViewController.h"
#import "NBNavigationController.h"
#import "GetFrame.h"
#import "LoginViewController.h"
#import "WhistleAppDelegate.h"
#import "MyTabBarViewController.h"
#define BOOKMARK_WORD_LIMIT 10
@interface NotificationViewController ()
<UITextViewDelegate>
{
    UILabel * m_label;
    UIScrollView * m_scrollView;
    CGRect m_frame;
    
    BOOL m_isIOS7;
    UIView * m_bgView;
}

@property (nonatomic, strong) UILabel * m_label;
@property (nonatomic, strong) UIScrollView * m_scrollView;
@property (nonatomic, strong) UIView * m_bgView;


@end

@implementation NotificationViewController

@synthesize m_label;
@synthesize m_scrollView;
@synthesize m_bgView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)leftButtonPressed
{
    NSLog(@"leftButtonPressed in NotificationViewController");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    m_frame = self.view.bounds;
    m_isIOS7 = [[GetFrame shareInstance] isIOS7Version];
    if (m_isIOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.view.backgroundColor = [UIColor purpleColor];
    
    [self createScrollView];
    [self createViewsOnScrollView];
    
    [self createNavigationBar:YES];
    self.m_bgView = [CommonBackGroudView getBackGroudView];
    [self.view addSubview:self.m_bgView];
    [self createLabel];
    [self createButton];
}

- (void)createButton
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    CGFloat y = 303;
    if (!isIOS7) {
        y -= 20.0f;
    }
    button.frame = CGRectMake(54, y, 212, 38);
    [button setTitle:@"切换账号" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor blueColor];
 
    
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)buttonPressed:(UIButton *)button
{
    WhistleAppDelegate * delegate = [[UIApplication sharedApplication] delegate];
    NBNavigationController * navigationController = (NBNavigationController *)delegate.window.rootViewController;
    [navigationController popToViewController:[LoginViewController shareInstance] animated:NO];
}

- (void)createLabel
{
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, m_frame.size.width - 40, 40)];
    label.backgroundColor = [UIColor yellowColor];
    [self.m_bgView addSubview:label];
}

- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:@"edit" andRightBtnType:@"noticeSwitch" andLeftTitle:@"通知" andRightTitle:@"应用提醒" andNeedCreateSubViews:needCreate];
}

- (void)leftNavigationBarButtonPressed:(UIButton *)button
{

}

- (void)rightNavigationBarButtonPressed:(UIButton *)button
{
    NSLog(@"button selected in NotificationViewController == %d", button.selected);
    if (button.selected) {
        self.m_scrollView.contentOffset = CGPointMake(m_frame.size.width, 0);
    } else {
        self.m_scrollView.contentOffset = CGPointMake(0, 0);
    }
    
    [self resetEditButton:NO];
}

- (void)editButtonPressedWithState:(BOOL)isEditState
{
    NSLog(@"NotificationViewController edit state is == %d", isEditState);
}

- (void)resetEditButton:(BOOL)hidden
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav resetEditButtonLabel:hidden andIsEditState:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createNavigationBar:NO];
    [self resetEditButton:NO];
}

- (void)createScrollView
{
    self.m_scrollView = [[UIScrollView alloc] initWithFrame:m_frame];
    self.m_scrollView.delegate = self;
    self.m_scrollView.pagingEnabled = YES;
    self.m_scrollView.contentSize = CGSizeMake(m_frame.size.width * 2, m_frame.size.height);
    [self.view addSubview:self.m_scrollView];
}

- (void)createViewsOnScrollView
{
    for (NSUInteger i = 0; i < 2; i++) {
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0 + m_frame.size.width * i, 0, m_frame.size.width, m_frame.size.height)];
        
        UIColor * color = nil;
        if (i == 0) {
            color = [UIColor redColor];
        } else if (i == 1) {
            color = [UIColor greenColor];
        }
        view.backgroundColor = color;
        [self.m_scrollView addSubview:view];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
//    if (scrollView.contentOffset.x <= 0.0f) {
//        [nav resetTitleAndSwitchButtonWithSelectedState:NO];
//        [self resetEditButton:NO];
//    } else if (scrollView.contentOffset.x >= m_frame.size.width) {
//        [nav resetTitleAndSwitchButtonWithSelectedState:YES];
//        [self resetEditButton:NO];
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
