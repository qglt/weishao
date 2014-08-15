//
//  SettingViewController.m
//  MyWhistle
//
//  Created by lizuoying on 13-10-15.
//  Copyright (c) 2013年 lizuoying. All rights reserved.
//

#import "SettingViewController.h"
#import "NBNavigationController.h"
#import "GetFrame.h"

@interface SettingViewController ()
<NBNavigationControllerDelegate, UIScrollViewDelegate>
{
    CGRect m_frame;
    BOOL m_isIOS7;
    UIScrollView * m_scrollView;
}

@property (nonatomic, strong) UIScrollView * m_scrollView;
@end

@implementation SettingViewController

@synthesize m_scrollView;

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
    m_frame = self.view.bounds;
    self.view.backgroundColor = [UIColor blueColor];
    m_isIOS7 = [[GetFrame shareInstance] isIOS7Version];
    if (m_isIOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }    [self createScrollView];
    [self createViewsOnScrollView];
    
    [self createNavigationBar:YES];
}

- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:nil andRightBtnType:@"personalSwitch" andLeftTitle:@"我的名片" andRightTitle:@"设置" andNeedCreateSubViews:needCreate];
}

- (void)leftNavigationBarButtonPressed:(UIButton *)button
{

}

- (void)rightNavigationBarButtonPressed:(UIButton *)button
{
    NSLog(@"button selected in SettingViewController == %d", button.selected);
    if (button.selected) {
        self.m_scrollView.contentOffset = CGPointMake(m_frame.size.width, 0);
    } else {
        self.m_scrollView.contentOffset = CGPointMake(0, 0);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createNavigationBar:NO];
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
//    } else if (scrollView.contentOffset.x >= m_frame.size.width) {
//        [nav resetTitleAndSwitchButtonWithSelectedState:YES];
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
