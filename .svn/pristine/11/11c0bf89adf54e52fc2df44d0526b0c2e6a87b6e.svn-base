//
//  AddCrowdViewController.m
//  WhistleIm
//
//  Created by ruijie on 14-2-11.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "AddCrowdViewController.h"
#import "GetFrame.h"
#import "SelectTypeTableView.h"
#import "ImUtils.h"
#import "NBNavigationController.h"
#import "NetworkBrokenAlert.h"
#import "AddCrowdTableView.h"
#import "AddCrowdsInfo.h"
#import "CrowdInfoViewController.h"
#import "RequestCrowdViewController.h"
#import "CrowdInfo.h"
#import "CommonRespondView.h"
#import "CustomAlertView.h"

@interface AddCrowdViewController ()<addCrowdInfoDelegate,AddCrowdTableViewDelegate>
{
    CGRect m_frame;
    BOOL m_isIOS7;
    BOOL m_is4Inch;

    NSUInteger m_pageIndex;

    NSMutableArray * m_arrCrowdsData;
    AddCrowdsInfo * m_crowdInfo;
    NSString * m_strSelectedType;
    NSString * m_searchKey;
    BOOL m_isMine;  //已经再此群里
    NSUInteger m_selectedIndex;

    BOOL m_isCommond;
}

@property (nonatomic,strong)AddCrowdsInfo * m_crowdInfo;
@property (nonatomic,strong)NSMutableArray * m_arrCrowdsData;
@property (nonatomic,strong)NSString * m_strSelectedType;
@property (nonatomic,strong)NSString * m_searchKey;
@property (nonatomic, strong) AddCrowdTableView * m_crowdsTableView;

@end

@implementation AddCrowdViewController
@synthesize m_arrCrowdsData;
@synthesize m_searchKey;
@synthesize m_strSelectedType;
@synthesize m_crowdInfo;

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
    [self setBaseCondition];
    [self setCrowdsInfo];
    [self createNavigationBar:YES];
    [self createCrowdsTableView];
    [self getCrowdsInfoData];
}

- (void)setBaseCondition
{
    m_frame = self.view.bounds;
    m_isIOS7 = [[GetFrame shareInstance] isIOS7Version];
    m_is4Inch = [[GetFrame shareInstance] is4InchScreen];
    self.view.backgroundColor = [ImUtils colorWithHexString:@"#F0F0F0"];
    self.m_strSelectedType = @"name";
    m_pageIndex = 0;
    m_isCommond = YES;
    m_arrCrowdsData = [[NSMutableArray alloc]init];
}

- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:nil andLeftTitle:@"添加群" andRightTitle:nil andNeedCreateSubViews:needCreate];
}

- (void)leftNavigationBarButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)createCrowdsTableView
{
    CGFloat y = 0;
    CGFloat height = m_frame.size.height;
    if (m_isIOS7) {
        y += 64;
        if (m_is4Inch) {
            height = m_frame.size.height - 64;
        } else {
            height = m_frame.size.height - 64;
        }
    } else {
        height = m_frame.size.height - 44;
    }

    self.m_crowdsTableView = [[AddCrowdTableView alloc] initWithFrame:CGRectMake(0, y, m_frame.size.width, height) withTableDataArr:nil];
    self.m_crowdsTableView.m_delegate = self;
    self.m_crowdsTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.m_crowdsTableView];
}

- (void)createErrorAlertView:(NSString *)errorMsg
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"" message:errorMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

-(void)setCrowdsInfo
{
    self.m_crowdInfo = [[AddCrowdsInfo alloc] init];
    self.m_crowdInfo.m_delegate = self;
}

-(void)getCrowdsInfoData
{
    self.m_crowdInfo.m_isCommond = YES;
    m_isCommond = YES;
    [self.m_crowdInfo getCrowdsData:self.m_strSelectedType andSearchKey:nil andStartIndex:m_pageIndex andMaxCounter:6];
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

#pragma mark - AddCrowdInfo delegate Methods -
- (void)sendCrowdsInfoToControllerWithArr:(NSMutableArray *)dataArr
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.m_crowdsTableView hiddenEmptySearchResultView:YES andText:nil];
    });
    if (m_isCommond) {
        self.m_arrCrowdsData = dataArr;
    } else {
        if (!(self.m_arrCrowdsData)) {
            self.m_arrCrowdsData = [[NSMutableArray alloc] init];
        }
        for (NSUInteger i = 0; i < [dataArr count]; i++) {
            [self.m_arrCrowdsData addObject:[dataArr objectAtIndex:i]];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.m_crowdsTableView refreshTableData:self.m_arrCrowdsData andSelectedType:self.m_strSelectedType];
    });
}

- (void)sendNoneResultMessageToController:(NSString *)noneResult
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.m_crowdsTableView hiddenEmptySearchResultView:NO andText:noneResult];
    });
}
- (void)sendErrorMessageToController:(NSString *)errorMsg
{
//    [self createErrorAlertView:errorMsg];
}
#pragma mark - AddCrowdTableViewDelegate Methods -
- (void)didSelectedRowWithCrowdInfo:(NSUInteger)index
{
    /*
     获取index位置数据， 压入群详情页
     */
    CrowdInfo * crowdInfo = [m_arrCrowdsData objectAtIndex:index];
    CrowdInfoViewController * controller = [[CrowdInfoViewController alloc]init];
    controller.m_crowdInfo = crowdInfo;
    [self.navigationController pushViewController:controller animated:YES];

}

- (void)showCrowdAlockingAlert
{
    [[[CustomAlertView alloc] initWithTitle:@"系统提示" message:@"操作失败，该群已被冻结" delegate:nil cancelButtonTitle:nil confrimButtonTitle:@"确定"] show];
}

- (void)showNoneTextAlert
{
    [CommonRespondView respond:@"请输入查找条件"];
}

-(void)didSelectedButtonWithAddCrowd:(NSUInteger)index
{
    m_selectedIndex = index;
    CrowdInfo * crowdInfo = [self.m_arrCrowdsData objectAtIndex:m_selectedIndex];
    if ([crowdInfo isAllowJoin]) {
        RequestCrowdViewController * controller = [[RequestCrowdViewController alloc]init];
        controller.m_CrowdInfo = crowdInfo;
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }else{
        [CommonRespondView respond:@"对不起, 该群不允许任何人加入"];
    }
}

- (void)sendSelectedTypeToController:(NSString *)selectedType andSearchKey:(NSString *)key andMaxCounter:(NSUInteger)counter andIndex:(NSUInteger)pageIndex isCommond:(BOOL)isCommond
{
    m_pageIndex = pageIndex;
    self.m_strSelectedType = selectedType;
    self.m_searchKey = key;
    m_isCommond = isCommond;
    self.m_crowdInfo.m_isCommond = isCommond;
    [self.m_crowdInfo getCrowdsData:self.m_strSelectedType andSearchKey:self.m_searchKey andStartIndex:pageIndex * counter andMaxCounter:counter];
}

@end
