//
//  GroupInfoViewController.m
//  WhistleIm
//
//  Created by 管理员 on 14-2-21.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "GroupInfoViewController.h"
#import "ImUtils.h"
#import "NBNavigationController.h"
#import "GroupInfoTableView.h"
#import "PersonalSettingData.h"
#import "DiscussionManager.h"
#import "ChatGroupInfo.h"
#import "DiscussionMemberInfo.h"
#import "CrowdMemberInfo.h"
#import "TalkingRecordViewController.h"
#import "ChangeTextInfoViewController.h"
#import "AddMembersToCrowdAndGroupViewController.h"
#import "NetworkBrokenAlert.h"

#define ADD_CROWD_MEMBERS_FROM_INFO @"addCrowdMembersFromInfo"
#define ADD_GROUP_MEMBERS_FROM_INFO @"addGroupMembersFromInfo"

#define  CELL_HEIGHT 45.0f
#define EACH_ROW_NUM 4

@interface GroupInfoViewController ()
<GroupInfoTableViewDelegate>
{
    CGRect m_frame;
    GroupInfoTableView * m_tableView;
    NSMutableArray * m_arrTitle;
    NSMutableArray * m_arrImages;
    ChatGroupInfo * m_chatGroupInfo;
    BOOL m_canRequestNextTime;
    
    NSMutableArray * m_arrMembersJid;
}

@property (nonatomic, strong) GroupInfoTableView * m_tableView;
@property (nonatomic, strong) NSMutableArray * m_arrTitle;
@property (nonatomic, strong) NSMutableArray * m_arrImages;
@property (nonatomic, strong) ChatGroupInfo * m_chatGroupInfo;
@property (nonatomic, strong) NSMutableArray * m_arrMembersJid;

@end

@implementation GroupInfoViewController

@synthesize m_tableView;
@synthesize m_groupJid;
@synthesize m_arrImages;
@synthesize m_arrTitle;
@synthesize m_chatGroupInfo;
@synthesize m_arrMembersJid;

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
    
    NSLog(@"group jid == %@", self.m_groupJid);
    [self setBasicCondition];
    [self createNavigationBar:YES];
    [self createGroupInfoTableView];
    
    self.m_arrTitle = [self getTitleArr];
    [self getGroupData];
}

- (void)setBasicCondition
{
    m_frame = [[UIScreen mainScreen] bounds];
    self.view.backgroundColor = [ImUtils colorWithHexString:@"#F0F0F0"];
    if (isIOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:nil andLeftTitle:@"讨论组资料" andRightTitle:nil andNeedCreateSubViews:needCreate];
}

- (void)leftNavigationBarButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSMutableArray *)getTitleArr
{
    NSMutableArray * titleArr = [[NSMutableArray alloc] initWithCapacity:0];
    PersonalSettingData * groupName = [[PersonalSettingData alloc] init];
    groupName.m_title = @"普通讨论组";
    groupName.m_hasIndicator = YES;
    groupName.m_needChangeTitleFrame = YES;
    groupName.m_cellHeight = CELL_HEIGHT;
    
    PersonalSettingData * groupRecord = [[PersonalSettingData alloc] init];
    groupRecord.m_title = @"聊天记录";
    groupRecord.m_hasIndicator = YES;
    groupRecord.m_cellHeight = CELL_HEIGHT;
    
    [titleArr addObject:groupName];
    [titleArr addObject:groupRecord];
    
    return titleArr;
}

- (void)getGroupData
{
    [[DiscussionManager shareInstance] getDiscussionMember:self.m_groupJid callback:^(ChatGroupInfo * groupInfo) {
        self.m_chatGroupInfo = groupInfo;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"self.m_chatGroupInfo.members == %@", self.m_chatGroupInfo.members);

            self.m_arrMembersJid = [self getMembersJidArr:self.m_chatGroupInfo.members];
            [self resetTitleArrData];
            NSMutableArray * seperateArr = [self separateSmallSectionWithArr:self.m_chatGroupInfo.members andWithDistance:EACH_ROW_NUM];
            self.m_arrImages = [self getActualMembersDataWithArr:seperateArr];
            
            NSUInteger totalMembers = 0;
            for (NSUInteger i = 0; i < [self.m_arrImages count]; i++) {
                NSMutableArray * eachSectionArr = [self.m_arrImages objectAtIndex:i];
                totalMembers += [eachSectionArr count];
            }
            if (totalMembers < 20) {
                [self addButtonItem];
            }
            [self.m_tableView refreshTableViewWithTitleArr:self.m_arrTitle andImageArr:self.m_arrImages];
        });
    }];
}

- (void)addButtonItem
{
    NSMutableArray * eachSectionDataArr = [self.m_arrImages objectAtIndex:[self.m_arrImages count] - 1];
    
    CrowdMemberInfo * memberInfo = [[CrowdMemberInfo alloc] init];
    memberInfo.m_hiddenDelBtn = YES;
    memberInfo.m_showAddBtn = YES;
    memberInfo.m_memberName = @"添加";

    if ([eachSectionDataArr count] >= EACH_ROW_NUM) {
        NSMutableArray * newSectionArr = [[NSMutableArray alloc] initWithCapacity:0];
        [newSectionArr addObject:memberInfo];
        [self.m_arrImages addObject:newSectionArr];
    } else {
        [eachSectionDataArr addObject:memberInfo];
    }
}

- (NSMutableArray *)getMembersJidArr:(NSMutableArray *)memberArr
{
    NSMutableArray * membersJidArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSUInteger i = 0; i < [memberArr count]; i++) {
        DiscussionMemberInfo * groupMemberInfo = [memberArr objectAtIndex:i];
        [membersJidArr addObject:groupMemberInfo.jid];
    }
    
    return membersJidArr;
}

- (void)resetTitleArrData
{
    PersonalSettingData * groupName = [self.m_arrTitle objectAtIndex:0];
    groupName.m_title = self.m_chatGroupInfo.groupName;
    NSLog(@"title arr == %@", self.m_arrTitle);
}

// 成员数组按照指定个数分成小的数组
- (NSMutableArray *)separateSmallSectionWithArr:(NSMutableArray *)allArr andWithDistance:(NSUInteger)distance
{
    NSMutableArray * totalArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSUInteger i = 0; i < [allArr count]; i++) {
        if (i % distance == 0) {
            NSMutableArray * eachArr = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSUInteger j = i; j < distance + i; j++) {
                if (j < [allArr count]) {
                    [eachArr addObject:[allArr objectAtIndex:j]];
                }
            }
            
            [totalArr addObject:eachArr];
        }
    }
    
    NSLog(@"totalArr == %@", totalArr);
    
    return totalArr;
}

// 构造实际的成员数据
- (NSMutableArray *)getActualMembersDataWithArr:(NSMutableArray *)membersArr
{
    NSMutableArray * actualTotalArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (NSUInteger i = 0; i < [membersArr count]; i++) {
        
        NSMutableArray * actualEachArr = [[NSMutableArray alloc] initWithCapacity:0];
        
        NSMutableArray * eachArr = [membersArr objectAtIndex:i];
        
        for (NSUInteger j = 0; j < [eachArr count]; j++) {
            
            CrowdMemberInfo * memberInfo = [[CrowdMemberInfo alloc] init];
            
            DiscussionMemberInfo * groupMemberInfo = [eachArr objectAtIndex:j];
            memberInfo.m_memberName = groupMemberInfo.showName;
            memberInfo.m_memberImage = [self getGroupMemberImageWithPath:groupMemberInfo.head andDiscussionMemberInfo:groupMemberInfo];
            memberInfo.m_hiddenDelBtn = YES;
            
            [actualEachArr addObject:memberInfo];
        }
        
        [actualTotalArr addObject:actualEachArr];
    }
    
    NSLog(@"actualTotalArr == %@", actualTotalArr);
    NSLog(@"\n\n\ntotalArr count == %d", [actualTotalArr count]);
    for (NSUInteger i = 0; i < [actualTotalArr count]; i++) {
        NSLog(@"eachArr count == %d", [[actualTotalArr objectAtIndex:i] count]);
    }
    
    return actualTotalArr;
}

- (UIImage *)getGroupMemberImageWithPath:(NSString *)path andDiscussionMemberInfo:(DiscussionMemberInfo *)info
{
    UIImage * image = nil;
    
    if ([path length] > 0) {
        image = [UIImage imageWithContentsOfFile:path];
    }
    
    if (image == nil) {
        if ([info.sex isEqualToString:@""]) {
            image = [UIImage imageNamed:@"identity_man_new.png"];
        } else {
            image = [UIImage imageNamed:@"identity_woman.png"];
        }
    }
    
    return image;
}

- (void)createGroupInfoTableView
{
    CGFloat y = 0.0f;
    
    if (isIOS7) {
        y += 64.0f;
    }
    CGFloat height = m_frame.size.height - 20 - 44;
    self.m_tableView = [[GroupInfoTableView alloc] initWithFrame:CGRectMake(0, y, m_frame.size.width, height)];
    self.m_tableView.m_delegate = self;
    [self.view addSubview:self.m_tableView];
}

- (void)leaveGroup
{
    if ([NetworkBrokenAlert isNetworkBrokenAndShowTip]) {
        return;
    }
    
    [[DiscussionManager shareInstance] leaveDiscussion:self.m_groupJid callback:^(BOOL success) {
        NSLog(@"leave group success == %d", success);
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
    }];
}

- (void)changeGroupName
{
    ChangeTextInfoViewController * controller = [[ChangeTextInfoViewController alloc] init];
    controller.m_title = @"讨论组名称";
    controller.m_placeHolder = self.m_chatGroupInfo.groupName;
    controller.m_numberOfWords = 12;
    controller.m_crowdSessionID = self.m_groupJid;
    controller.m_type = @"groupName";
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)addGroupMember
{
    AddMembersToCrowdAndGroupViewController * controller = [[AddMembersToCrowdAndGroupViewController alloc] init];
    controller.m_type = ADD_GROUP_MEMBERS_FROM_INFO;
    controller.m_crowdSessionID = self.m_groupJid;
    controller.m_arrHadMembersJid = self.m_arrMembersJid;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)showGroupRecord
{
    TalkingRecordViewController * controller = [[TalkingRecordViewController alloc] init];
    controller.inputObject = self.m_chatGroupInfo;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createNavigationBar:NO];
    if (m_canRequestNextTime) {
        [self getGroupData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    m_canRequestNextTime = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
