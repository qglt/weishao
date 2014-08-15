//
//  ConversationViewController.m
//  MyWhistle
//
//  Created by lizuoying on 13-10-15.
//  Copyright (c) 2013年 lizuoying. All rights reserved.
//

#import "ConversationViewController.h"
#import "NBNavigationController.h"
#import "LocalRecentListManager.h"
#import "EventDateFormat.h"
#import "RecentRecord.h"
#import "CrowdInfo.h"
#import "CrowdManager.h"
#import "ChatGroupInfo.h"
#import "DiscussionManager.h"
#import "FriendInfo.h"
#import "ImUtils.h"
#import "RecentItemCell.h"
#import "GetFrame.h"
#import "SystemMessageInfo.h"
#import "RosterManager.h"
#import "JSONObjectHelper.h"
#import "PrivateTalkViewController.h"
#import "PersonCardViewController.h"
#import "Constants.h"
#import "SystemInfomationViewController.h"
#import "RootView.h"
#import "JGScrollableTableViewCellAccessoryButton.h"
#import "JGScrollableTableViewCell.h"
#import "LeveyTabBarController.h"
#import "LightAppMessageInfo.h"
#import "LightAppInfo.h"
#import "CrowdInfoViewController.h"
#import "GroupInfoViewController.h"
#import "AppDetailController.h"

#define LEFT_ITEM_TAG 2000
#define RIGHT_ITEM_TAG 3000
#define BACK_ITEM_TAG 4000

@interface ConversationViewController ()
<NBNavigationControllerDelegate>
{
    NSIndexPath *_openedIndexPath;
    BOOL _left;
}

@property (nonatomic,strong) UITableView *mTalkView;

@property(nonatomic,strong) NSMutableArray *recordData;

@property(nonatomic,strong) UILabel *emptyLabel;
@property (nonatomic, strong) NSString * m_talkType;

@property (nonatomic, strong) FriendInfo * m_friendInfo;

@property (nonatomic, strong) NSMutableArray * m_arrUnreadInfo;

@property (nonatomic, strong) NSMutableArray * m_arrCanEdit;

@property (nonatomic, assign) NSInteger m_selectedIndex;

@property (nonatomic, assign) BOOL isShowNetworkView;


@end

@implementation ConversationViewController

@synthesize mTalkView;

@synthesize emptyLabel;

@synthesize recordData;

@synthesize m_talkType;

@synthesize m_friendInfo;

@synthesize m_arrCanEdit;

@synthesize m_arrUnreadInfo;

@synthesize m_selectedIndex;

@synthesize isShowNetworkView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
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

    self.view.backgroundColor = [UIColor clearColor];

    m_selectedIndex = -1;
    self.recordData = [NSMutableArray array];
    self.m_arrUnreadInfo = [[NSMutableArray alloc] initWithCapacity:0];
    self.m_arrCanEdit = [[NSMutableArray alloc] initWithCapacity:0];
    
    [[LocalRecentListManager shareInstance] addListener:self];
    [[LocalRecentListManager shareInstance] getRecentList];
    
//    mTalkView = [[UITableView alloc] initWithFrame:self.view.bounds];
    mTalkView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64 - 50)];
    [self.view addSubview: [[RootView alloc] initWithView: mTalkView]];
    
    if(!emptyLabel)
    {
        emptyLabel = [self createEmptyLabel];
        [mTalkView addSubview:emptyLabel];
    }
    
    mTalkView.dataSource = self;
    mTalkView.delegate = self;
    
    isShowNetworkView = NO;//默认网络状态通知页面不显示
    
    mTalkView.backgroundColor = [ImUtils colorWithHexString:@"f0f0f0"];
    [mTalkView setSeparatorColor:[UIColor clearColor]];
    self.view.backgroundColor = [ImUtils colorWithHexString:@"f0f0f0"];
    [[GetFrame shareInstance] setNavigationBarForController:self];
    
    [self createNavigationBar:YES];
}

- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:nil andRightBtnType:nil andLeftTitle:NSLocalizedString(@"message", @"") andRightTitle:nil andNeedCreateSubViews:needCreate];
}


-(UILabel *)createEmptyLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    label.font = [UIFont systemFontOfSize:15];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f];

    label.text = @"暂无会话内容";
    [label sizeToFit];
    label.frame = CGRectMake((mTalkView.frame.size.width-label.frame.size.width)/2, (mTalkView.frame.size.height-label.frame.size.height)/2-44, label.frame.size.width, label.frame.size.height);
//    label.center = mTalkView.center;
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];
    [label setHidden:NO];
    return label;
}

-(void)refreshTalbeView:(NSMutableArray *)data
{
    [self.recordData removeAllObjects];
    if(data.count>0)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [mTalkView setScrollEnabled:YES];
            [emptyLabel setHidden:YES];
        });
        for (RecentRecord *record in data) {
//            RecentRecord *record = [data objectAtIndex:i];
            [recordData addObject:record];
//            [self addRecentRecord:record];
        }
        [self performSelectorOnMainThread:@selector(reloadDataOnMainThread) withObject:nil waitUntilDone:YES];
    }else
    {
        if(!emptyLabel)
        {
            emptyLabel = [self createEmptyLabel];
        }
        [mTalkView setScrollEnabled:NO];
        [emptyLabel setHidden:NO];
        [self performSelectorOnMainThread:@selector(reloadDataOnMainThread) withObject:nil waitUntilDone:YES];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [self.m_arrUnreadInfo removeAllObjects];
    for (NSUInteger i = 0; i < [self.recordData count]; i++) {
        [self.m_arrUnreadInfo addObject:[NSNumber numberWithBool:NO]];
    }
    
    
    [self.m_arrCanEdit removeAllObjects];
    for (NSUInteger i = 0; i < [self.recordData count]; i++) {
        [self.m_arrCanEdit addObject:[NSNumber numberWithBool:YES]];
    }
    return self.recordData.count;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        return  75;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RecentRecord *record = [recordData objectAtIndex:indexPath.row];
    static NSString *itemCellIdentifier = @"RectentItemCell";
    RecentItemCell *itemCell = [tableView dequeueReusableCellWithIdentifier:itemCellIdentifier];
    if(itemCell==nil)
    {
        itemCell = [[RecentItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:itemCellIdentifier];
        
        [itemCell.headBtn addTarget:self action:@selector(headImagebuttonPressed:event:) forControlEvents:UIControlEventTouchUpInside];
        
        [itemCell.actionView addTarget:self action:@selector(deleteCellPressed:event:)forControlEvents:UIControlEventTouchUpInside];
        
        itemCell.scrollDelegate = self;
        itemCell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellBackground.png"]];
    }

    
    [itemCell setupCell:record];
    
    
    [itemCell setOptionViewVisible:[_openedIndexPath isEqual:indexPath]];
    
    
    
    return itemCell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

-(void) deleteCellPressed:(UIButton *)button event:(UIEvent *)event
{
    NSSet * set = [event allTouches];
    UITouch * touch = [set anyObject];
    CGPoint point = [touch locationInView:self.mTalkView];
    NSIndexPath * indexPath = [mTalkView indexPathForRowAtPoint:point];
    
    RecentRecord *record = [recordData objectAtIndex:indexPath.row];

    if(record.getType ==RecentRecord_System)
    {
        [[LocalRecentListManager shareInstance] removeRecentSystemContact:^(BOOL result) {
            if(result)
            {
                 _openedIndexPath = nil;
            }
        }];
    }else
    {
        NSString *resultId = @"";
        if(record.getType ==RecentRecord_Discussion)
        {
            ChatGroupInfo *info = record.extraInfo;
            resultId= info.sessionId;
        }else if(record.getType ==RecentRecord_Crowd)
        {
            CrowdInfo *info = record.extraInfo;
            resultId = info.session_id;
        }else if(record.getType ==RecentRecord_LightApp)
        {
//            LightAppMessageInfo  *info = record.extraInfo;
//            LightAppInfo *la = info.lightappDetail;
//            resultId =la.appid;
            resultId = record.jid;
        }else
        {
            FriendInfo *info = record.extraInfo;
            resultId = info.jid;
        }
        [[LocalRecentListManager shareInstance] removeRecentContact:resultId withCallback:^(BOOL result) {
            if(result)
            {
                _openedIndexPath = nil;
            }
        }];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.editing = NO;
    mTalkView.editing = NO;
    [super viewDidDisappear:animated];
}

// 好友头像点击事件
- (void)headImagebuttonPressed:(UIButton *)button event:(UIEvent *)event
{
    // - (NSSet *)allTouches;
    
    NSSet * set = [event allTouches];
    UITouch * touch = [set anyObject];
    CGPoint point = [touch locationInView:self.mTalkView];
    NSIndexPath * indexPath = [mTalkView indexPathForRowAtPoint:point];
    
    m_selectedIndex = indexPath.row;
    
    RecentRecord *record = [recordData objectAtIndex:indexPath.row];
    
    if(record.getType == RecentRecord_Conversation)
    {
        PersonCardViewController * cardViewController = [[PersonCardViewController alloc] init];
        cardViewController.hidesBottomBarWhenPushed = YES;
        cardViewController.m_delegate = self;
    
        FriendInfo *info = record.extraInfo;
        self.m_friendInfo = info;
        cardViewController.m_jid = self.m_friendInfo.jid;
        
        [[RosterManager shareInstance] getRelationShip:cardViewController.m_jid WithCallback:^(enum FriendRelation relationShip) {
            BOOL isStranger = NO;
            if (relationShip == RelationStranger || relationShip == RelationNone) {
                isStranger = YES;
            } else if (relationShip == RelationContact) {
                isStranger = NO;
            }
            cardViewController.m_isStranger = isStranger;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController pushViewController:cardViewController animated:YES];
            });
        }];
    } else if (record.getType == RecentRecord_Crowd) {
        [self pushToCrowdInfoViewControllerWithObject:(CrowdInfo *)record.extraInfo];
    } else if (record.getType == RecentRecord_Discussion) {
        [self pushToGroupInfoViewControllerWithObject:(ChatGroupInfo *)record.extraInfo];
    }else if (record.getType == RecentRecord_LightApp)
    {
        //push到轻应用详情
        AppDetailController *VC = [[AppDetailController alloc] init];
        LightAppMessageInfo *info = record.extraInfo;
        LightAppInfo *li = info.lightappDetail;
        if (li) {
            VC.info =li;
            [self.navigationController pushViewController:VC animated:YES];
        }
        
    }
}

- (void)pushToCrowdInfoViewControllerWithObject:(CrowdInfo *)crowdInfo
{
    CrowdInfoViewController * controller = [[CrowdInfoViewController alloc] init];
    controller.m_crowdInfo = crowdInfo;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)pushToGroupInfoViewControllerWithObject:(ChatGroupInfo *)chatGroupInfo
{
    GroupInfoViewController * controller = [[GroupInfoViewController alloc] init];
    controller.m_groupJid = chatGroupInfo.sessionId;
    [self.navigationController pushViewController:controller animated:YES];
}

//PersonCardViewController delegate
- (void)changeShowName:(NSString *)remarkName
{
//    NSMutableDictionary * dic = [recordData objectAtIndex:m_selectedIndex];
//    NSString * key = [dataKeys objectAtIndex:1];
//    [dic setObject:remarkName forKey:key];
}

//PersonCardViewController delegate
- (void)clearLastConversation
{
//    NSMutableDictionary * dic = [recordData objectAtIndex:m_selectedIndex];
//    NSString * key = [dataKeys objectAtIndex:3];
//    [dic setObject:@"" forKey:key];
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RecentRecord *record = [recordData objectAtIndex:indexPath.row];
    
    [self.m_arrUnreadInfo replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:NO]];
    
    if (record.getType ==RecentRecord_System) {
        SystemInfomationViewController * controller = [[SystemInfomationViewController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        PrivateTalkViewController * controller = [[PrivateTalkViewController alloc] init];
        if (record.getType == RecentRecord_LightApp) {
            controller.inputObject = ((LightAppMessageInfo *)record.extraInfo).lightappDetail;
        }else
        {
            controller.inputObject = record.extraInfo;
            if (record.isMyDevice) {
                controller.myDevice = record.jid;
            }
        }
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(recordData.count ==0)
    {
        return NO;
    }

    return YES;
}

-(void)reloadDataOnMainThread
{
    if(recordData.count>0 && !self.navigationItem.leftBarButtonItem)
    {
        mTalkView.editing = NO;
        [mTalkView setScrollEnabled:YES];
        [emptyLabel setHidden:YES];
    }else if(recordData.count==0)
    {
        self.mTalkView.editing = YES;//!self.mTalkView.editing;
        self.navigationItem.leftBarButtonItem = nil;
        [mTalkView setScrollEnabled:NO];
        [emptyLabel setHidden:NO];
    }else
    {
    }
    
    [mTalkView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)leftNavigationBarButtonPressed:(UIButton *)button
{
    
}

- (void)rightNavigationBarButtonPressed:(UIButton *)button
{
    
}

- (void)editButtonPressedWithState:(BOOL)isEditState
{
    self.mTalkView.editing = !self.mTalkView.editing;
    self.editing = !self.editing;
    [mTalkView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    BOOL noUnreadInfo = NO;
    
    for (NSUInteger i = 0; i < [self.m_arrUnreadInfo count]; i++) {
        NSNumber * number = [self.m_arrUnreadInfo objectAtIndex:i];
        if ([number boolValue]) {
            noUnreadInfo = YES;
            break;
        }
    }
    
    [mTalkView reloadData];
    
    if (noUnreadInfo == NO) {
        NSLog(@"unread clear");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changbadgevalue" object:nil];
    }
}


- (void) localRecentListChanged:(NSMutableArray*) list
{
//   [self performSelectorOnMainThread:@selector(reloadDataOnMainThread) withObject:nil waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(refreshTalbeView:) withObject:list waitUntilDone:YES];
}

- (void) getLocalRecentListFinish:(NSMutableArray*) list
{
    [self performSelectorOnMainThread:@selector(refreshTalbeView:) withObject:list waitUntilDone:YES];
}

- (void) getLocalRecentListFailure
{
    
}

- (void) updateRecentListUnReadCount:(NSUInteger) count
{
    
}

- (void) updateRecentRecord:(RecentRecord*) rec
{
    
}

#pragma mark - JGScrollableTableViewCellDelegate

- (void)cellDidBeginScrolling:(JGScrollableTableViewCell *)cell {
    [JGScrollableTableViewCellManager closeAllCellsWithExceptionOf:cell stopAfterFirst:YES];
}

- (void)cellDidScroll:(JGScrollableTableViewCell *)cell {
    [JGScrollableTableViewCellManager closeAllCellsWithExceptionOf:cell stopAfterFirst:YES];
}

- (void)cellDidEndScrolling:(JGScrollableTableViewCell *)cell {
    if (cell.optionViewVisible) {
        _openedIndexPath = [mTalkView indexPathForCell:cell];
    }
    else {
        _openedIndexPath = nil;
    }
    
    [JGScrollableTableViewCellManager closeAllCellsWithExceptionOf:cell stopAfterFirst:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _openedIndexPath = nil;
    [self.leveyTabBarController hidesTabBar:YES animated:YES];
}

@end
