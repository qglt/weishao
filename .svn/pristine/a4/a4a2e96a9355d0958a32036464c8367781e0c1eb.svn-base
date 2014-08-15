//
//  CrowdMembersViewController.m
//  WhistleIm
//
//  Created by 管理员 on 14-2-11.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "CrowdMembersViewController.h"
#import "ShakeTableView.h"
#import "NBNavigationController.h"
#import "ImUtils.h"
#import "CrowdMemberInfo.h"
#import "RosterManager.h"
#import "CrowdMember.h"
#import "CrowdManager.h"
#import "AddMembersToCrowdAndGroupViewController.h"
#import "NetworkBrokenAlert.h"
#import "Toast.h"

#define SUPER @"super"
#define ADMIN @"admin"
#define MEMBER @"member"
#define ADD_CROWD_MEMBERS_FROM_INFO @"addCrowdMembersFromInfo"

#define EACH_ROW_NUM 4


@interface CrowdMembersViewController ()
<ShakeTableViewDelegate, CrowdDelegate>
{
    CGRect m_frame;
    NSMutableDictionary * m_dictData;
    ShakeTableView * m_shakeTableView;
    
    NSMutableArray * m_arrSuperOrAdmin;
    NSMutableArray * m_arrNormalMembers;
    
    NSMutableArray * m_arrActualSuperOrAdmin;
    NSMutableArray * m_arrActualNormalMembers;
    
    NSUInteger m_superOrAdminIndex;
    
    NSUInteger m_deleteTag;
    NSIndexPath * m_deleteIndexPath;
    
    NSMutableArray * m_arrDataArr;
    NSString * m_authorityType;
    
    BOOL m_isEditState;
    
    NSMutableArray * m_arrMembersJid;
    
    BOOL m_canRequestNextTime;
    
    NSMutableArray * m_arrExistingMembers;
}

@property (nonatomic, strong) NSMutableDictionary * m_dictData;
@property (nonatomic, strong) ShakeTableView * m_shakeTableView;
@property (nonatomic, strong) NSMutableArray * m_arrSuperOrAdmin;
@property (nonatomic, strong) NSMutableArray * m_arrNormalMembers;

@property (nonatomic, strong) NSMutableArray * m_arrActualSuperOrAdmin;
@property (nonatomic, strong) NSMutableArray * m_arrActualNormalMembers;

@property (nonatomic, strong) NSMutableArray * m_arrDataArr;
@property (nonatomic, strong) NSString * m_authorityType;

@property (nonatomic, strong) NSIndexPath * m_deleteIndexPath;
@property (nonatomic, strong) NSMutableArray * m_arrMembersJid;
@property (nonatomic, strong) NSMutableArray * m_arrExistingMembers;



@end

@implementation CrowdMembersViewController

@synthesize m_arrDataArr;
@synthesize m_authorityType;

@synthesize m_dictData;
@synthesize m_shakeTableView;

@synthesize m_arrSuperOrAdmin;
@synthesize m_arrNormalMembers;

@synthesize m_arrActualSuperOrAdmin;
@synthesize m_arrActualNormalMembers;

@synthesize m_deleteIndexPath;
@synthesize m_crowdSessionID;
@synthesize m_arrMembersJid;
@synthesize m_maxLimit;
@synthesize m_arrExistingMembers;



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
    [[CrowdManager shareInstance] addListener:self];
    [self createNavigationBar:YES];
    [self setBasicCondition];
    [self getCrowdMembersData];
    [self createShakeTableView];
}

- (void)getCrowdMembersData
{
    [[CrowdManager shareInstance] getCrowdMembers:self.m_crowdSessionID callback:^(NSArray * membersArr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.m_arrExistingMembers = (NSMutableArray *)membersArr;
            NSMutableArray * memberDataArr = (NSMutableArray *)membersArr;
            [self getMySelfAuthorityWithMembersDataArr:memberDataArr];
            self.m_arrMembersJid = [self getMembersJidArr:memberDataArr];
            self.m_arrDataArr = [self sortMemberTypeWithMembersDataArr:memberDataArr];
            self.m_dictData = [self constructData];
            [self.m_shakeTableView refreshTableView:self.m_dictData andIsEditState:m_isEditState];
        });
    }];
}

/**
 *  群成员信息变更
 *
 *  @param info 群
 */
- (void) crowdMemberChanged:(CrowdInfo*) info
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.m_arrExistingMembers = (NSMutableArray *)info.members;
        NSMutableArray * memberDataArr = (NSMutableArray *)info.members;
        [self getMySelfAuthorityWithMembersDataArr:memberDataArr];
        self.m_arrMembersJid = [self getMembersJidArr:memberDataArr];
        self.m_arrDataArr = [self sortMemberTypeWithMembersDataArr:memberDataArr];
        self.m_dictData = [self constructData];
        [self.m_shakeTableView refreshTableView:self.m_dictData andIsEditState:m_isEditState];
    });
}

// 确定自己的什么，决定是否可以删除群成员和可以删除哪些群成员
- (void)getMySelfAuthorityWithMembersDataArr:(NSMutableArray *)memberDataArr
{
    FriendInfo * mySelf = [[RosterManager shareInstance] mySelf];
    CrowdMember * mySelfMember = nil;
    for (NSUInteger i = 0; i < [memberDataArr count]; i++) {
        CrowdMember * member = [memberDataArr objectAtIndex:i];
        if ([mySelf.jid isEqualToString:member.jid]) {
            mySelfMember = member;
            break;
        }
    }
    
    if ([mySelfMember isSuper]) {
        self.m_authorityType = SUPER;
    } else if ([mySelfMember isAdmin]) {
        self.m_authorityType = ADMIN;
    } else if ([mySelfMember isNone]) {
        self.m_authorityType = MEMBER;
    }
    
    if ([self.m_authorityType isEqualToString:SUPER] || [self.m_authorityType isEqualToString:ADMIN] ) {
        NBNavigationController * nav = (NBNavigationController *)self.navigationController;
        [nav showEditButton];
    }
}

// 按照超级管理员，管理员，群成员排序
- (NSMutableArray *)sortMemberTypeWithMembersDataArr:(NSMutableArray *)memberDataArr
{
    // 获取超级管理员
    NSMutableArray * memberSortArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSUInteger i = 0; i < [memberDataArr count]; i++) {
        CrowdMember * member = [memberDataArr objectAtIndex:i];
        if ([member isSuper]) {
            [memberSortArr addObject:member];
            break;
        }
    }
    
    // 获取管理员
    NSMutableArray * adminMemberArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSUInteger i = 0; i < [memberDataArr count]; i++) {
        CrowdMember * member = [memberDataArr objectAtIndex:i];
        if ([member isAdmin]) {
            [memberSortArr addObject:member];
            [adminMemberArr addObject:member];
            continue;
        }
    }
    
    // 获取超级管理员和管理员的个数
    m_superOrAdminIndex = [adminMemberArr count] + 1;

    // 获取普通群成员
    for (NSUInteger i = 0; i < [memberDataArr count]; i++) {
        CrowdMember * member = [memberDataArr objectAtIndex:i];
        if ([member isNone]) {
            [memberSortArr addObject:member];
            continue;
        }
    }
    
    return memberSortArr;
}

// 获取已经在群里的成员
- (NSMutableArray *)getMembersJidArr:(NSMutableArray *)memberArr
{
    NSMutableArray * membersJidArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSUInteger i = 0; i < [memberArr count]; i++) {
        CrowdMember * member = [memberArr objectAtIndex:i];
        [membersJidArr addObject:member.jid];
    }
    
    return membersJidArr;
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
    NSString * rightBtn = @"edit";
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:rightBtn andLeftTitle:@"群成员" andRightTitle:nil andNeedCreateSubViews:needCreate];
}

- (void)leftNavigationBarButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)editButtonPressedWithState:(BOOL)isEditState
{
    NSLog(@"isEditState == %d", isEditState);
    
    m_isEditState = isEditState;
    [self editTableViewWithEditState:isEditState];
}

- (void)createShakeTableView
{
    CGFloat y = 0.0f;
    if (isIOS7) {
        y += 64.0f;
    }
    
    CGFloat height = m_frame.size.height - 64;
    self.m_shakeTableView = [[ShakeTableView alloc] initWithFrame:CGRectMake(0, y, m_frame.size.width, height) withDataArr:self.m_dictData];
    self.m_shakeTableView.m_delegate = self;
    [self.view addSubview:self.m_shakeTableView];
}

- (void)deleteButtonPressedInShakeTableView:(NSIndexPath *)indexPath andImageTag:(NSUInteger)deleteTag
{
    NSLog(@"indexPath.section == %d", indexPath.section);
    NSLog(@"indexPath.row == %d", indexPath.row);
    NSLog(@"deleteTag == %d", deleteTag);
    
    self.m_deleteIndexPath = indexPath;
    m_deleteTag = deleteTag;
    
    [self deleteAllMembers];
}

- (void)addButtonPressedInShakeTableView
{
    AddMembersToCrowdAndGroupViewController * controller = [[AddMembersToCrowdAndGroupViewController alloc] init];
    controller.m_type = ADD_CROWD_MEMBERS_FROM_INFO;
    controller.m_crowdSessionID = self.m_crowdSessionID;
    controller.m_arrHadMembersJid = self.m_arrMembersJid;
    controller.m_maxLimit = self.m_maxLimit;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)deleteAllMembers
{
    if ([NetworkBrokenAlert isNetworkBrokenAndShowTip]) {
        return;
    }
    
    if (self.m_deleteIndexPath.section == 1) {
        [self deleteNormalMembers];
    } else if (self.m_deleteIndexPath.section == 0) {
        [self deleteAdmin];
    }
}

- (void)deleteAdmin
{
    NSMutableArray * eachRowArr = [self.m_arrActualSuperOrAdmin objectAtIndex:0];
    [eachRowArr removeObjectAtIndex:m_deleteTag];
    [self.m_dictData setObject:self.m_arrActualSuperOrAdmin forKey:@"admin"];
    [self.m_shakeTableView refreshTableView:self.m_dictData andIsEditState:m_isEditState];
    [self deleteDataFromServerWithIndex:m_deleteTag];
}

- (void)deleteNormalMembers
{    
    NSInteger deleteIndex = 0;
    for (NSUInteger i = 0; i < self.m_deleteIndexPath.row; i++) {
        NSMutableArray * eachRowArr = [self.m_arrActualNormalMembers objectAtIndex:i];
        deleteIndex += [eachRowArr count];
    }
    
    deleteIndex += m_deleteTag;
    
    if (deleteIndex >= 0) {
        [self.m_arrNormalMembers removeObjectAtIndex:deleteIndex];
    }
    
    NSLog(@"deleteIndex == %d", deleteIndex);
    
    NSMutableArray * normalSmallArr = [self separateSmallSectionWithArr:self.m_arrNormalMembers andWithDistance:EACH_ROW_NUM];
    self.m_arrActualNormalMembers = [self getActualMembersDataWithArr:normalSmallArr isManager:NO];
    
    [self createAddButton];
    
    [self.m_dictData setObject:self.m_arrActualNormalMembers forKey:@"member"];
    
    [self.m_shakeTableView refreshTableView:self.m_dictData andIsEditState:m_isEditState];
    
    [self deleteDataFromServerWithIndex:deleteIndex + m_superOrAdminIndex];
}

- (void)deleteDataFromServerWithIndex:(NSUInteger)index
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // 发送删除请求
        CrowdMember * member = [self.m_arrDataArr objectAtIndex:index];
        [[CrowdManager shareInstance] crowdMemberKickout:self.m_crowdSessionID friend:member.jid reson:nil callback:^(BOOL isSuceess) {
            NSLog(@"delete crowd member success == %d", isSuceess);
            if (isSuceess) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Toast show:@"删除成功"];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Toast show:@"删除失败"];
                });
            }
        }];
    });
}

- (NSMutableDictionary *)constructData
{
    NSMutableDictionary * dataDict = [[NSMutableDictionary alloc] initWithCapacity:0];

    // 分离出的一维数组
    self.m_arrSuperOrAdmin = [self getSuperOrAdminMemberWithIndex:m_superOrAdminIndex];
    self.m_arrNormalMembers = [self getNormalMembersWithIndex:m_superOrAdminIndex];
    
    // 构造二维数组
    NSMutableArray * normalSmallArr = [self separateSmallSectionWithArr:self.m_arrNormalMembers andWithDistance:EACH_ROW_NUM];
    NSMutableArray * superSmallArr = [self separateSmallSectionWithArr:self.m_arrSuperOrAdmin andWithDistance:EACH_ROW_NUM];
    
    // 根据二维数组，获取实际的数据
    self.m_arrActualSuperOrAdmin = [self getActualMembersDataWithArr:superSmallArr isManager:YES];
    self.m_arrActualNormalMembers = [self getActualMembersDataWithArr:normalSmallArr isManager:NO];
    
    [self createAddButton];
    
    [dataDict setObject:self.m_arrActualSuperOrAdmin forKey:@"admin"];
    [dataDict setObject:self.m_arrActualNormalMembers forKey:@"member"];
    
    return dataDict;
}

- (void)createAddButton
{
    if (([self.m_authorityType isEqualToString:ADMIN] || [self.m_authorityType isEqualToString:SUPER]) && [self.m_arrExistingMembers count] < self.m_maxLimit) {
        [self addButtonItemWithNormalMemberArr:self.m_arrActualNormalMembers];
    }
}

- (void)addButtonItemWithNormalMemberArr:(NSMutableArray *)normalMemberArr
{
    CrowdMemberInfo * memberInfo = [[CrowdMemberInfo alloc] init];
    memberInfo.m_hiddenDelBtn = YES;
    memberInfo.m_showAddBtn = YES;
    memberInfo.m_memberName = @"添加";
    
    if ([normalMemberArr count] > 0) {
        NSMutableArray * eachSectionDataArr = [normalMemberArr objectAtIndex:[normalMemberArr count] - 1];
        if ([eachSectionDataArr count] >= EACH_ROW_NUM) {
            NSMutableArray * newSectionArr = [[NSMutableArray alloc] initWithCapacity:0];
            [newSectionArr addObject:memberInfo];
            [normalMemberArr addObject:newSectionArr];
        } else {
            [eachSectionDataArr addObject:memberInfo];
        }
    } else {
        NSMutableArray * newSectionArr = [[NSMutableArray alloc] initWithCapacity:0];
        [newSectionArr addObject:memberInfo];
        [normalMemberArr addObject:newSectionArr];
    }
}

// 从返回的所有成员数组中分离出群主和管理员
- (NSMutableArray *)getSuperOrAdminMemberWithIndex:(NSUInteger)index
{
    NSMutableArray * superOrAdminArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSUInteger i = 0; i < index; i++) {
        if ([self.m_arrDataArr count] > i) {
            CrowdMember * crowdMember = [self.m_arrDataArr objectAtIndex:i];
            [superOrAdminArr addObject:crowdMember];
        }
    }
    
    NSLog(@"superOrAdminArr count == %d", [superOrAdminArr count]);
    
    return superOrAdminArr;
}

// 从返回的所有成员数组中分离出普通群成员
- (NSMutableArray *)getNormalMembersWithIndex:(NSUInteger)index
{
    NSMutableArray * normalMembersArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSUInteger i = index; i < [self.m_arrDataArr count]; i++) {
        if ([self.m_arrDataArr count] > i) {
            CrowdMember * crowdMember = [self.m_arrDataArr objectAtIndex:i];
            [normalMembersArr addObject:crowdMember];
        }
    }
    
    NSLog(@"normalMembersArr count == %d", [normalMembersArr count]);
    
    return normalMembersArr;
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
    
    return totalArr;
}

// 构造实际的成员数据
- (NSMutableArray *)getActualMembersDataWithArr:(NSMutableArray *)membersArr isManager:(BOOL)isManager
{
    NSMutableArray * actualTotalArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (NSUInteger i = 0; i < [membersArr count]; i++) {
        
        NSMutableArray * actualEachArr = [[NSMutableArray alloc] initWithCapacity:0];

        NSMutableArray * eachArr = [membersArr objectAtIndex:i];
        
        for (NSUInteger j = 0; j < [eachArr count]; j++) {
            
            CrowdMemberInfo * memberInfo = [[CrowdMemberInfo alloc] init];
            
            CrowdMember * crowdMember = [eachArr objectAtIndex:j];
            memberInfo.m_memberName = crowdMember.showName;
            memberInfo.m_memberImage = [self getCrowdMemberImageWithPath:crowdMember.head andCrowdMember:crowdMember];

            if (isManager == NO) {
                if (m_isEditState) {
                    memberInfo.m_hiddenDelBtn = NO;
                } else {
                    memberInfo.m_hiddenDelBtn = YES;
                }
            } else {
                if ([self.m_authorityType isEqualToString:ADMIN]) {
                    memberInfo.m_hiddenDelBtn = YES;
                } else if ([self.m_authorityType isEqualToString:SUPER]) {
                    if (j == 0) {
                        memberInfo.m_hiddenDelBtn = YES;
                    } else {
                        memberInfo.m_hiddenDelBtn = NO;
                    }
                }
            }
           
            [actualEachArr addObject:memberInfo];
        }
        
        [actualTotalArr addObject:actualEachArr];
    }
    
    NSLog(@"\n\n\ntotalArr count == %d", [actualTotalArr count]);
    for (NSUInteger i = 0; i < [actualTotalArr count]; i++) {
        NSLog(@"eachArr count == %d", [[actualTotalArr objectAtIndex:i] count]);
    }
    
    return actualTotalArr;
}

- (UIImage *)getCrowdMemberImageWithPath:(NSString *)path andCrowdMember:(CrowdMember *)member
{
    UIImage * image = nil;
    
    if ([path length] > 0) {
        image = [UIImage imageWithContentsOfFile:path];
    }
    
    if (image == nil) {
        if ([member isBoy]) {
            image = [UIImage imageNamed:@"identity_man_new.png"];
        } else {
            image = [UIImage imageNamed:@"identity_woman.png"];
        }
    }
    
    return image;
}

// 设置编辑状态，抖动效果，以及是否可以删除
- (void)editTableViewWithEditState:(BOOL)canEdit
{
    NSMutableArray * adminArr = [self.m_dictData objectForKey:@"admin"];
    NSMutableArray * memberArr = [self.m_dictData objectForKey:@"member"];
  
    for (NSUInteger i = 0; i < [adminArr count]; i++) {
        NSMutableArray * adminRowArr = [adminArr objectAtIndex:i];
        for (NSUInteger j = 0; j < [adminRowArr count]; j++) {
            CrowdMemberInfo * memberInfo = [adminRowArr objectAtIndex:j];
            
            if ([self.m_authorityType isEqualToString:ADMIN]) {
                memberInfo.m_hiddenDelBtn = YES;
            } else if ([self.m_authorityType isEqualToString:SUPER]) {
                if (j == 0) {
                    memberInfo.m_hiddenDelBtn = YES;
                } else {
                    memberInfo.m_hiddenDelBtn = NO;
                }
            }
        }
    }
    
    for (NSUInteger i = 0; i < [memberArr count]; i++) {
        NSMutableArray * memberRowArr = [memberArr objectAtIndex:i];
        for (NSUInteger j = 0; j < [memberRowArr count]; j++) {
            CrowdMemberInfo * memberInfo = [memberRowArr objectAtIndex:j];
            memberInfo.m_hiddenDelBtn = !canEdit;
        }
    }
    
    [self.m_shakeTableView refreshTableView:self.m_dictData andIsEditState:canEdit];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createNavigationBar:NO];
    if (m_canRequestNextTime) {
        [self getCrowdMembersData];
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
