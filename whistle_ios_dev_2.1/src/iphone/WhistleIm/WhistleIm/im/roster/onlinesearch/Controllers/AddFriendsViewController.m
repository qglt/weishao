//
//  AddFriendsViewController.m
//  WhistleIm
//
//  Created by 管理员 on 13-10-24.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "AddFriendsViewController.h"
#import "GetFrame.h"
#import "AddFriendsInfo.h"
#import "AddFriendsTableView.h"
#import "RequestFriendsViewController.h"
#import "SelectTypeTableView.h"
#import "FriendInfo.h"
#import "PersonCardViewController.h"
#import "NBNavigationController.h"
#import "NetworkBrokenAlert.h"
#import "ImUtils.h"
#import "RosterManager.h"
#import "CommonRespondView.h"

#define LEFT_ITEM_TAG 2000

#define MAX_COUNTER 6


@interface AddFriendsViewController ()
<AddFriendsInfoDelegate, AddFriendsTableViewDelegate>
{
    CGRect m_frame;
    BOOL m_isIOS7;
    BOOL m_is4Inch;
    NSUInteger m_pageIndex;
    
    AddFriendsTableView * m_friendsTableView;
    
    AddFriendsInfo * m_friendsInfo;
    NSMutableArray * m_arrFriendsData;
    NSString * m_strSelectedType;
    NSString * m_searchKey;
    BOOL m_isFriend;
    BOOL m_toPersonCard;
    BOOL m_cellDidSelected;
    NSUInteger m_selectedIndex;
    
    BOOL m_isCommond;
}
@property (nonatomic, strong) AddFriendsTableView * m_friendsTableView;


@property (nonatomic, strong) AddFriendsInfo * m_friendsInfo;
@property (nonatomic, strong) NSMutableArray * m_arrFriendsData;
@property (nonatomic, strong) NSString * m_strSelectedType;
@property (nonatomic, strong) NSString * m_searchKey;

@end

@implementation AddFriendsViewController

@synthesize m_friendsTableView;

@synthesize m_friendsInfo;
@synthesize m_arrFriendsData;
@synthesize m_strSelectedType;
@synthesize m_searchKey;

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
    [self setFriendsInfo];
    [self createNavigationBar:YES];
    [self createFriendsTableView];
    [self getFriendsInfoData];
}

- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:nil andLeftTitle:@"添加好友" andRightTitle:nil andNeedCreateSubViews:needCreate];
}

- (void)leftNavigationBarButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
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
}

- (void)setMemory
{
    self.m_arrFriendsData = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)setFriendsInfo
{
    self.m_friendsInfo = [[AddFriendsInfo alloc] init];
    self.m_friendsInfo.m_delegate = self;
}

- (void)createFriendsTableView
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
    
    self.m_friendsTableView = [[AddFriendsTableView alloc] initWithFrame:CGRectMake(0, y, m_frame.size.width, height) withTableDataArr:nil];
    self.m_friendsTableView.m_delegate = self;
    self.m_friendsTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.m_friendsTableView];
}

// AddFriendsTableView delegate
- (void)didSelectedRowWithFriendInfo:(NSUInteger)index;
{
    m_cellDidSelected = YES;
    m_selectedIndex = index;
    FriendInfo * friendInfo = [self.m_arrFriendsData objectAtIndex:index];
    [self.m_friendsInfo getRelationshipWithJid:friendInfo.jid];
}

- (void)createAlertViewWithMessage:(NSString *)message
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)getFriendsInfoData
{
    self.m_friendsInfo.m_isCommond = YES;
    m_isCommond = YES;
    [self.m_friendsInfo getFriendsData:self.m_strSelectedType andSearchKey:self.m_searchKey andStartIndex:m_pageIndex * MAX_COUNTER andMaxCounter:MAX_COUNTER];
}

// 点击查找和search按钮，获取数据
- (void)sendSelectedTypeToController:(NSString *)selectedType andSearchKey:(NSString *)key andMaxCounter:(NSUInteger)counter andIndex:(NSUInteger)pageIndex isCommond:(BOOL)isCommond
{
    if ([NetworkBrokenAlert isNetworkBrokenAndShowTip]) {
        return;
    }
    self.m_strSelectedType = selectedType;
    self.m_searchKey = key;
    m_isCommond = isCommond;
    self.m_friendsInfo.m_isCommond = isCommond;
    [self.m_friendsInfo getFriendsData:self.m_strSelectedType andSearchKey:self.m_searchKey andStartIndex:pageIndex * counter andMaxCounter:counter];
}

- (void)showNoneTextAlert
{
    [CommonRespondView respond:@"请输入查找条件"];
}

- (void)pushToPersonCardViewController:(NSUInteger)index
{
    m_toPersonCard = YES;
    m_selectedIndex = index;
    FriendInfo * friendInfo = [self.m_arrFriendsData objectAtIndex:index];
    [self.m_friendsInfo getRelationshipWithJid:friendInfo.jid];
}

// AddFriendsInfo delegate
- (void)sendFrindsInfoToControllerWithArr:(NSMutableArray *)dataArr
{
    [self.m_friendsTableView hiddenEmptySearchResultView:YES andText:nil];
    if (m_isCommond) {
        self.m_arrFriendsData = dataArr;
    } else {
        if (!(self.m_arrFriendsData)) {
            self.m_arrFriendsData = [[NSMutableArray alloc] init];
        }
        for (NSUInteger i = 0; i < [dataArr count]; i++) {
            [self.m_arrFriendsData addObject:[dataArr objectAtIndex:i]];
        }
    }
    [self.m_friendsTableView refreshTableData:self.m_arrFriendsData andSelectedType:self.m_strSelectedType];
}

// none result message
- (void)sendNoneResultMessageToController:(NSString *)noneResult
{
    [self.m_friendsTableView hiddenEmptySearchResultView:NO andText:noneResult];
}

- (void)sendErrorMessageToController:(NSString *)errorMsg
{
//    [self createErrorAlertView:errorMsg];
}

//- (void)createErrorAlertView:(NSString *)errorMsg
//{
//    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"" message:errorMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    [alertView show];
//}

- (void)sendStrangerOrNot:(BOOL)isFriend
{
    FriendInfo * friendInfo = [self.m_arrFriendsData objectAtIndex:m_selectedIndex];
    NSLog(@"isFriend relationship === %d", isFriend);

    if (m_cellDidSelected) {
        m_cellDidSelected = NO;
        if (!isFriend) {
            NSLog(@"did selected friend info in controller == %@", friendInfo);
            RequestFriendsViewController * requestViewController = [[RequestFriendsViewController alloc] init];
            requestViewController.m_friendInfo = friendInfo;
            [self.navigationController pushViewController:requestViewController animated:YES];
        } else {
            [self createAlertViewWithMessage:@"对方已经是您的好友"];
        }
    } else if (m_toPersonCard) {
        m_toPersonCard = NO;
        PersonCardViewController * controller = [[PersonCardViewController alloc] init];
        controller.m_jid = friendInfo.jid;
        self.hidesBottomBarWhenPushed = YES;
        
        [[RosterManager shareInstance] getRelationShip:controller.m_jid WithCallback:^(enum FriendRelation relationShip) {
            BOOL isStranger = NO;
            if (relationShip == RelationStranger || relationShip == RelationNone) {
                isStranger = YES;
            } else if (relationShip == RelationContact) {
                isStranger = NO;
            }
            controller.m_isStranger = isStranger;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController pushViewController:controller animated:YES];
            });
        }];
    }
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
