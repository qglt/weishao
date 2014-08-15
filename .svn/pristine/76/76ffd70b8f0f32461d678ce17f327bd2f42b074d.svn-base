//
//  CloudConfigurationController.m
//  WhistleIm
//
//  Created by 移动组 on 13-12-10.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "CloudConfigurationController.h"
#import "SelectSchoolTableViewController.h"
#import "NBNavigationController.h"
#import "ImUtils.h"
@interface CloudConfigurationController ()

@end

@implementation CloudConfigurationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)changeTheme:(NSNotification *)notification
{
    [self createNavigationBar:NO];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [ImUtils colorWithHexString:@"#f0f0f0"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTheme:) name:@"changeTheme" object:nil];
    [self.navigationController setNavigationBarHidden:NO];

    [self createNavigationBar:YES];

	// Do any additional setup after loading the view.
    
    [self createCloudConfigurationView];
    if (self.remoteConfigObj) {

        [self.cloudConfigurationView.recommendButton setTitle:self.remoteConfigObj.name forState:UIControlStateNormal];

    }
    else
    {
        self.cloudConfigurationView.recommendButton.hidden = YES;

    }

}

- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:nil andRightBtnType:nil andLeftTitle:@"选择所属学校" andRightTitle:nil andNeedCreateSubViews:needCreate];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[AccountManager shareInstance] addListener:self];
    
    [self createNavigationBar:NO];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[AccountManager shareInstance] removeListener:self];
}
#pragma mark -

#pragma mark customView
-(void)createCloudConfigurationView
{
    self.cloudConfigurationView = [[CloudConfigurationView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    //设置代理
    self.cloudConfigurationView.cloudDelegate =  self;
    [self.view addSubview:self.cloudConfigurationView];
    
}
#pragma mark -

#pragma mark CloudConfigurationDelegate

- (void)downLoadButton:(UIButton *)sender
{
    //返回对象给AccountManager
    self.navigationController.navigationBarHidden = YES;
    [LoginViewController shareInstance].selectedConfig = self.remoteConfigObj;
    [self.navigationController popToViewController:[LoginViewController shareInstance] animated:YES];
    LOG_UI_DEBUG(@"选择学校：%@",self.remoteConfigObj.name);
}
- (void)selectButton:(UIButton *)button
{
    [self createTableView];
}

- (void)createTableView
{
    SelectSchoolTableViewController *selectVC = [[SelectSchoolTableViewController alloc] init];
    //传学校数组到选择学校控制器
    selectVC.tableDataArray = self.remoteConfigArray;

    selectVC.remoteConfigObj = self.remoteConfigObj;
    [self.navigationController pushViewController:selectVC animated:YES];
}


#pragma mark -

#pragma mark Memory management
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
