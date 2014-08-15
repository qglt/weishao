//
//  ChatPopViewController.m
//  WhistleIm
//
//  Created by wangchao on 13-10-15.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "ChatPopViewController.h"
#import "TalkingRecordViewController.h"
#import "PersonCardViewController.h"
#import "ImUtils.h"
#import "FriendInfo.h"
#import "NBNavigationController.h"
#import "PersonalSettingData.h"
#import "LightAppInfo.h"
#import "LightAppMessageInfo.h"
#import "CrowdInfo.h"
#import "ChatGroupInfo.h"
#import "PersonalInfoView.h"
#import "PersonalTableViewCell.h"
#import "AddMembersToCrowdAndGroupViewController.h"
#import "RosterManager.h"
#import "AppDetailController.h"
#import "AppCommentController.h"
#import "CrowdInfoViewController.h"
#import "GroupInfoViewController.h"
#import "DiscussionManager.h"

#define ADD_GROUP_MEMBERS_DEFAULT @"addGroupMembersDefault"
#define ADD_GROUP_MEMBERS_DEFAULT_STRANGER @"addGroupMembersDefaultStranger"

#define ADD_GROUP_MEMBERS_FROM_INFO @"addGroupMembersFromInfo"


#define HEADER_HEIGHT 8.0f

@interface ChatPopViewController ()<PersonalInfoViewDelegate,UITableViewDataSource,UITableViewDelegate,NBNavigationControllerDelegate>

@property (nonatomic, strong) NSMutableArray    * m_arrTableData;
@property (nonatomic, strong) PersonalInfoView  * m_personalInfoView;
@property (nonatomic,strong)  UITableView       * m_tableView;

@end

@implementation ChatPopViewController
{
    // 可以再次添加讨论组成员
    BOOL m_canAddGroupMembers;
}
@synthesize m_personalInfoView;
@synthesize m_arrTableData;
@synthesize uintInfo;

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
    m_canAddGroupMembers = YES;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 6.1f) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.view.backgroundColor = [ImUtils colorWithHexString:@"#f0f0f0"];
    
    [self createNavigationBar:YES];
    
    [self setTableDataArr];
    
    [self createTableView];
    
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    m_canAddGroupMembers = YES;
    [self createNavigationBar:NO];
}

- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:nil andLeftTitle:@"聊天设置" andRightTitle:nil andNeedCreateSubViews:needCreate];
}


- (void)setTableDataArr
{
    self.m_arrTableData = [[NSMutableArray alloc] initWithCapacity:0];
    [self.m_arrTableData addObject:[self getFirstSectionArr]];
    NSMutableArray *temp = [self getSecodnSectionArr];
    if (temp.count>0) {
        [self.m_arrTableData addObject:[self getSecodnSectionArr]];
    }
}

- (NSMutableArray *)getFirstSectionArr
{
    NSMutableArray * sectionArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    if([self.uintInfo isKindOfClass:[LightAppInfo class]] || [self.uintInfo isKindOfClass:[LightAppMessageInfo class]])
    {
        PersonalSettingData * data0 = [[PersonalSettingData alloc] init];
        data0.m_title =NSLocalizedString(@"appInfo", @"");
        data0.m_cellHeight = 45;
        data0.m_hasHeaderLine = YES;
        data0.m_hasIndicator = YES;
        
        [sectionArr addObject:data0];
        
        PersonalSettingData * data1 = [[PersonalSettingData alloc] init];
        data1.m_title = NSLocalizedString(@"conversationHistory", @"");
        data1.m_cellHeight = 45.0f;
        data1.m_hasHeaderLine = NO;
        data1.m_hasIndicator = YES;
        
        [sectionArr addObject:data1];
        
//        PersonalSettingData * data2 = [[PersonalSettingData alloc] init];
//        data2.m_title = NSLocalizedString(@"setupConversationBackground", @"");
//        data2.m_cellHeight = 45.0f;
//        data2.m_hasHeaderLine = NO;
//        data2.m_hasIndicator = YES;
//        
//        [sectionArr addObject:data2];
    }else if([self.uintInfo isKindOfClass:[FriendInfo class]])
    {
        PersonalSettingData * data0 = [[PersonalSettingData alloc] init];
        data0.m_title =NSLocalizedString(@"friendInfo", @"");
        data0.m_cellHeight = 45;
        data0.m_hasHeaderLine = YES;
        data0.m_hasIndicator = YES;
        
        [sectionArr addObject:data0];
        
        PersonalSettingData * data1 = [[PersonalSettingData alloc] init];
        data1.m_title = NSLocalizedString(@"conversationHistory", @"");
        data1.m_cellHeight = 45.0f;
        data1.m_hasHeaderLine = NO;
        data1.m_hasIndicator = YES;
        
        [sectionArr addObject:data1];
        
//        PersonalSettingData * data2 = [[PersonalSettingData alloc] init];
//        data2.m_title = NSLocalizedString(@"setupConversationBackground", @"");
//        data2.m_cellHeight = 45.0f;
//        data2.m_hasHeaderLine = NO;
//        data2.m_hasIndicator = YES;
//        
//        [sectionArr addObject:data2];
        
        PersonalSettingData * data3 = [[PersonalSettingData alloc] init];
        data3.m_title = NSLocalizedString(@"createChatGroup", @"");
        data3.m_cellHeight = 45.0f;
        data3.m_hasHeaderLine = NO;
        data3.m_hasIndicator = YES;
        
        [sectionArr addObject:data3];
    }else if([self.uintInfo isKindOfClass:[CrowdInfo class]])
    {
        PersonalSettingData * data0 = [[PersonalSettingData alloc] init];
        data0.m_title =NSLocalizedString(@"crowdInfo", @"");
        data0.m_cellHeight = 45;
        data0.m_hasHeaderLine = YES;
        data0.m_hasIndicator = YES;
        
        [sectionArr addObject:data0];
        
        PersonalSettingData * data1 = [[PersonalSettingData alloc] init];
        data1.m_title = NSLocalizedString(@"conversationHistory", @"");
        data1.m_cellHeight = 45.0f;
        data1.m_hasHeaderLine = NO;
        data1.m_hasIndicator = YES;
        
        [sectionArr addObject:data1];
        
//        PersonalSettingData * data2 = [[PersonalSettingData alloc] init];
//        data2.m_title = NSLocalizedString(@"setupConversationBackground", @"");
//        data2.m_cellHeight = 45.0f;
//        data2.m_hasHeaderLine = NO;
//        data2.m_hasIndicator = YES;
//        
//        [sectionArr addObject:data2];
    }else if([self.uintInfo isKindOfClass:[ChatGroupInfo class]])
    {
        PersonalSettingData * data0 = [[PersonalSettingData alloc] init];
        data0.m_title =NSLocalizedString(@"chatGroupInfo", @"");
        data0.m_cellHeight = 45;
        data0.m_hasHeaderLine = YES;
        data0.m_hasIndicator = YES;
        
        [sectionArr addObject:data0];
        
        PersonalSettingData * data1 = [[PersonalSettingData alloc] init];
        data1.m_title = NSLocalizedString(@"conversationHistory", @"");
        data1.m_cellHeight = 45.0f;
        data1.m_hasHeaderLine = NO;
        data1.m_hasIndicator = YES;
        
        [sectionArr addObject:data1];
        
//        PersonalSettingData * data2 = [[PersonalSettingData alloc] init];
//        data2.m_title = NSLocalizedString(@"setupConversationBackground", @"");
//        data2.m_cellHeight = 45.0f;
//        data2.m_hasHeaderLine = NO;
//        data2.m_hasIndicator = YES;
//        
//        [sectionArr addObject:data2];
        
        PersonalSettingData * data3 = [[PersonalSettingData alloc] init];
        data3.m_title = NSLocalizedString(@"addChatGroupMember", @"");
        data3.m_cellHeight = 45.0f;
        data3.m_hasHeaderLine = NO;
        data3.m_hasIndicator = YES;
        
        [sectionArr addObject:data3];
    }
    
    return  sectionArr;
}

- (NSMutableArray *)getSecodnSectionArr
{
    NSMutableArray * sectionArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    if([self.uintInfo isKindOfClass:[LightAppInfo class]])
    {
        PersonalSettingData * data = [[PersonalSettingData alloc] init];
        data.m_title = NSLocalizedString(@"comment", @"");
        data.m_cellHeight = 45.0f;
        data.m_hasHeaderLine = YES;
        data.m_hasIndicator = YES;
        
        [sectionArr addObject:data];
    }
    return  sectionArr;
}

- (void)createTableView
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 6.9f) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.m_tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.m_tableView.delegate = self;
    self.m_tableView.dataSource = self;
    self.m_tableView.scrollEnabled = NO;
    self.m_tableView.showsVerticalScrollIndicator = NO;
    self.m_tableView.separatorColor = [UIColor clearColor];
    self.m_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.m_tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.m_tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.m_arrTableData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.m_arrTableData objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEADER_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.view.bounds.size.width, HEADER_HEIGHT)];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray * eachSectionArr = [self.m_arrTableData objectAtIndex:indexPath.section];
    PersonalSettingData * data = [eachSectionArr objectAtIndex:indexPath.row];
    return data.m_cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellID = @"personal";
    PersonalTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[PersonalTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellBackground.png"]];
    }
    
    NSMutableArray * eachSectionArr = [self.m_arrTableData objectAtIndex:indexPath.section];
    PersonalSettingData * settingData = [eachSectionArr objectAtIndex:indexPath.row];
    [cell setCellWithSettingData:settingData];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if([self.uintInfo isKindOfClass:[LightAppInfo class]]|| [self.uintInfo isKindOfClass:[LightAppNewsMessageInfo class]])
    {
        if (indexPath.section==1) {
            //评论页面
            AppCommentController *commentVC = [AppCommentController new];
            commentVC.info = self.uintInfo;
            [self.navigationController pushViewController:commentVC animated:YES];
        }else
        {
            switch (indexPath.row) {
                case 0:
                {
                    //应用详情
                    AppDetailController *detailVC = [AppDetailController new];
                    detailVC.info = self.uintInfo;
                    [self.navigationController pushViewController:detailVC animated:YES];
                }
                    break;
                case 1:
                {
                    [self chatHistory];
                }
                    break;
                case 2:
                {
                    
                }
                    break;
            }
        }

    }else if([self.uintInfo isKindOfClass:[FriendInfo class]])
    {
        switch (indexPath.row) {
            case 0:
            {
                [self friend:nil];
            }
                break;
            case 1:
            {
                [self chatHistory];
            }
                break;
//            case 2:
//            {
//                
//            }
//                break;
            case 2:
            {
                FriendInfo * friendInfo = (FriendInfo *)self.uintInfo;
                [self createGroupWithFriendJid:friendInfo.jid];
            }
                break;
        }
    }else if([self.uintInfo isKindOfClass:[CrowdInfo class]])
    {
        switch (indexPath.row) {
            case 0:
            {
                [self pushToCrowdInfoViewController:(CrowdInfo *)self.uintInfo];
            }
                break;
            case 1:
            {
                [self chatHistory];
            }
                break;
            case 2:
            {
                
            }
                break;
        }
    }else if([self.uintInfo isKindOfClass:[ChatGroupInfo class]])
    {
        switch (indexPath.row) {
            case 0:
            {
                [self pushToGroupInfoViewController:(ChatGroupInfo *)self.uintInfo];
            }
                break;
            case 1:
            {
                [self chatHistory];
            }
                break;
            case 2:
            {
                ChatGroupInfo * groupInfo = (ChatGroupInfo *)self.uintInfo;
                [self addGroupMemberWithGroupJid:groupInfo.sessionId];
            }
                break;
        }
    }
}

- (void)pushToCrowdInfoViewController:(CrowdInfo *)crowdInfo
{
    CrowdInfoViewController * controller = [[CrowdInfoViewController alloc] init];
    controller.m_crowdInfo = crowdInfo;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)addGroupMemberWithGroupJid:(NSString *)sessionId
{
    if (m_canAddGroupMembers) {
        m_canAddGroupMembers = NO;
        [[DiscussionManager shareInstance] getDiscussionMember:sessionId callback:^(ChatGroupInfo * chatGroupInfo) {
            
            if (chatGroupInfo.members == nil) {
                m_canAddGroupMembers = YES;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([chatGroupInfo.members count] < 20) {
                    AddMembersToCrowdAndGroupViewController * controller = [[AddMembersToCrowdAndGroupViewController alloc] init];
                    controller.m_type = ADD_GROUP_MEMBERS_FROM_INFO;
                    controller.m_crowdSessionID = sessionId;
                    controller.m_arrHadMembersJid = [self getMembersJidArr:chatGroupInfo.members];
                    [self.navigationController pushViewController:controller animated:YES];
                    m_canAddGroupMembers = NO;
                } else {
                    m_canAddGroupMembers = YES;
                    [self createAlertViewWithMessage:@"成员达到上限"];
                }
            });
        }];
    }
}

- (void)createAlertViewWithMessage:(NSString *)message
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    m_canAddGroupMembers = NO;
}

// 获取讨论组成员的jid
- (NSMutableArray *)getMembersJidArr:(NSMutableArray *)memberArr
{
    NSMutableArray * membersJidArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSUInteger i = 0; i < [memberArr count]; i++) {
        DiscussionMemberInfo * groupMemberInfo = [memberArr objectAtIndex:i];
        [membersJidArr addObject:groupMemberInfo.jid];
    }
    
    return membersJidArr;
}

- (void)createGroupWithFriendJid:(NSString *)jid
{
    [[RosterManager shareInstance] getRelationShip:jid WithCallback:^(enum FriendRelation relationShip) {
        BOOL isFriend = NO;
        if (relationShip == RelationStranger || relationShip == RelationNone) {
            isFriend = NO;
        } else if (relationShip == RelationContact) {
            isFriend = YES;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            AddMembersToCrowdAndGroupViewController * controller = [[AddMembersToCrowdAndGroupViewController alloc] init];
            if (isFriend) {
                controller.m_type = ADD_GROUP_MEMBERS_DEFAULT;
            } else {
                controller.m_type = ADD_GROUP_MEMBERS_DEFAULT_STRANGER;
            }
            controller.m_friendJid = jid;
            [self.navigationController pushViewController:controller animated:YES];
        });
    }];
}

- (void)pushToGroupInfoViewController:(ChatGroupInfo *)chatGroupInfo
{
    GroupInfoViewController * controller = [[GroupInfoViewController alloc] init];
    controller.m_groupJid = chatGroupInfo.sessionId;
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)chatHistory
{
    TalkingRecordViewController * controller = [[TalkingRecordViewController alloc] init];
    controller.inputObject = self.uintInfo;
    [self.navigationController pushViewController:controller animated:YES];
}

-(IBAction)chatBackground:(id)sender
{
    // ADD_GROUP_MEMBERS_DEFAULT
}

-(void)leftNavigationBarButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)friend:(id)sender
{
    PersonCardViewController * cardViewController = [[PersonCardViewController alloc] init];
    cardViewController.m_jid = [ImUtils getIdByObject:self.uintInfo];
    cardViewController.hidesBottomBarWhenPushed = YES;
    
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
}


-(IBAction)creatGroup:(id)sender
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    self.uintInfo = nil;
    

}

@end
