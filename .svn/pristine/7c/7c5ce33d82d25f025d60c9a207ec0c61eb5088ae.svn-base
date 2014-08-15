//
//  SelectSchoolTableViewController.m
//  WhistleIm
//
//  Created by 移动组 on 13-12-11.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "SelectSchoolTableViewController.h"
#import "SelectSchoolTableView.h"
#import "NBNavigationController.h"
#import "GetFrame.h"
#import "AccountManager.h"
#import "Group.h"
#import "LoginViewController.h"

#define LEFT_ITEM_TAG 2000

@interface SelectSchoolTableViewController ()
{
    SelectSchoolTableView *selectView;
    NSMutableArray *_array;
    NSMutableArray *_keyArray;
}
@end

@implementation SelectSchoolTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init
{
    if (self = [super init]) {
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTheme:) name:@"changeTheme" object:nil];
    [self.navigationController setNavigationBarHidden:NO];

    NSLog(@"cloudConfigVC.remoteConfigObj.isRecommand = %d",self.remoteConfigObj.isRecommand);

    if (self.remoteConfigObj) {
        //有推荐学校，显示返回的button
        [self createNavBar:YES];


    }else
    {
        //没有推荐学校没有返回

        [self createNavigationBar:YES];


    }



    _array = [[NSMutableArray alloc] initWithCapacity:2];
    _keyArray = [NSMutableArray array];


    [self arrangeData];
    
//    CGFloat y = 0;
//    if (isIOS7) {
//        y += 64.0f;
//    }
    
    selectView = [[SelectSchoolTableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    selectView.selectViewDelegate = self;
    selectView.array = _array;
    selectView.keyArray = _keyArray;
    
    
    [self.view addSubview:selectView];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self createNavigationBar:NO];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
}
- (void)arrangeData
{
    Group *group = [[Group alloc] init];
    _array = [group dataSource:self.tableDataArray];
    for (Group *object in _array) {
        [_keyArray addObject:[object.groupName uppercaseString]];
    }
}
- (void)createNavBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:nil andLeftTitle:@"学校" andRightTitle:nil andNeedCreateSubViews:needCreate];
}
- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:nil andRightBtnType:nil andLeftTitle:@"学校" andRightTitle:nil andNeedCreateSubViews:needCreate];
}
- (void)leftNavigationBarButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - selectViewDelegate
- (void)confirmSchool:(NSString *)str
{
    //实现代理，把选择的学校发到后台
    //切换到主线程
    NSLog(@"搜索的字符串是 = %@",str);
    [[AccountManager shareInstance] searchCouldConfig:str withCallback:^(NSArray* data){

       dispatch_async(dispatch_get_main_queue(), ^{
           //切换到主线程，更新数据源更新UI
           
           //整理数据
           Group *group = [[Group alloc] init];
           self.tableDataArray =  [group dataSource:data];
           selectView.array = self.tableDataArray;
           
           //先要清空之前的titleKey
           [_keyArray removeAllObjects];
           for (Group *g in self.tableDataArray) {
               [_keyArray addObject:[g.groupName uppercaseString]];

           }
           selectView.keyArray = _keyArray;
           [selectView.tableView reloadData];
       });
    }];
    
}

- (void)sendConfirmSchool:(RemoteConfigInfo *)info
{
//    //选中学校确认后返回对象给AccountManager
    self.navigationController.navigationBarHidden = YES;
    [LoginViewController shareInstance].selectedConfig = info;
    [self.navigationController popToViewController:[LoginViewController shareInstance] animated:YES];
}
@end
