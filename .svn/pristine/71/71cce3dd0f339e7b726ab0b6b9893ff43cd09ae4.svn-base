//
//  CrowdDetailInfoSetting.m
//  WhistleIm
//
//  Created by 管理员 on 14-1-16.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "CrowdDetailInfoSetting.h"
#import "PersonalSettingData.h"
#import "CrowdInfo.h"
#import "CrowdManager.h"

#define SUPER @"super"
#define ADMIN @"admin"
#define MEMBER @"member"

#define CELL_HEIGHT 45.0f

@interface CrowdDetailInfoSetting ()
{
    NSMutableArray * m_arrTitleItems;
    CrowdInfo * m_detailCrowdInfo;
    
    NSString * m_mySelfAuthority;
}

@property (nonatomic, strong) NSMutableArray * m_arrTitleItems;
@property (nonatomic, strong) CrowdInfo * m_detailCrowdInfo;
@property (nonatomic, strong) NSString * m_mySelfAuthority;

@end

@implementation CrowdDetailInfoSetting

@synthesize m_arrTitleItems;
@synthesize m_delegate;
@synthesize m_detailCrowdInfo;
@synthesize m_mySelfAuthority;

- (id)init
{
    self = [super init];
    if (self) {
        [self setMemory];
    }
    return self;
}

- (void)setMemory
{
    self.m_arrTitleItems = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)structureData
{
    [self.m_arrTitleItems removeAllObjects];
    [self.m_arrTitleItems addObject:[self getFirstSectionArr]];
    [self.m_arrTitleItems addObject:[self getSecondSectionArr]];
    [self.m_arrTitleItems addObject:[self getThirdSectionArr]];
    [self.m_arrTitleItems addObject:[self getFouthSectionArr]];
    [self.m_arrTitleItems addObject:[self getFifthSectionArr]];
}

- (void)getCrowdDetailInfoWithSessionId:(NSString *)sessionId
{
    // 获取群的详细信息
    [[CrowdManager shareInstance] getCrowdDetailInfoBySessionID:sessionId WithCallback:^(CrowdInfo * detailCrowdInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self getDetailInfo:detailCrowdInfo];
        });
    }];
}

- (void)getDetailInfo:(CrowdInfo *)crowdInfo
{
    self.m_detailCrowdInfo = crowdInfo;
    self.m_mySelfAuthority = [self getMySelfAuthority];
    [self structureData];
    [m_delegate sendCrowdDetailInfo:self.m_arrTitleItems andDetailCrowdInfo:self.m_detailCrowdInfo andMySelfAuthority:self.m_mySelfAuthority];
}

- (NSString *)getMySelfAuthority
{
    if ([self.m_detailCrowdInfo isSuper]) {
        return SUPER;
    } else if ([self.m_detailCrowdInfo isAdmin]) {
        return ADMIN;
    } else {
        return nil;
    }
}

- (NSMutableArray *)getFirstSectionArr
{
    NSMutableArray * sectionArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    BOOL canEdit = NO;
    if ([self.m_mySelfAuthority isEqualToString:SUPER] || [self.m_mySelfAuthority isEqualToString:ADMIN]) {
        canEdit = YES;
    }
    PersonalSettingData * crowdHeader = [[PersonalSettingData alloc] init];
    crowdHeader.m_title = @"群头像";
    crowdHeader.m_hasIndicator = canEdit;
    crowdHeader.m_hasImageView = YES;
    UIImage * image = [self.m_detailCrowdInfo getCrowdIcon];
    crowdHeader.m_image = image;
    crowdHeader.m_cellHeight = CELL_HEIGHT;
    
    PersonalSettingData * crowdName = [[PersonalSettingData alloc] init];
    crowdName.m_title = @"群名称";
    crowdName.m_hasIndicator = canEdit;
    crowdName.m_cellHeight = CELL_HEIGHT;
    crowdName.m_content = self.m_detailCrowdInfo.name;
    crowdName.m_hasLabel = YES;
    
    PersonalSettingData * crowdNum = [[PersonalSettingData alloc] init];
    crowdNum.m_title = @"群号";
    crowdNum.m_hasLabel = YES;
    crowdNum.m_content = [self.m_detailCrowdInfo getCrowdID];
    NSLog(@"群号：self.m_detailCrowdInfo.crowd_no == %@", [self.m_detailCrowdInfo getCrowdID]);
    crowdNum.m_cellHeight = CELL_HEIGHT;
    
    [sectionArr addObject:crowdHeader];
    [sectionArr addObject:crowdName];
    [sectionArr addObject:crowdNum];
    
    return sectionArr;
}

- (NSMutableArray *)getSecondSectionArr
{
    NSMutableArray * sectionArr = [[NSMutableArray alloc] initWithCapacity:0];

    BOOL canEdit = NO;
    if ([self.m_mySelfAuthority isEqualToString:SUPER] || [self.m_mySelfAuthority isEqualToString:ADMIN]) {
        canEdit = YES;
    }
    
    PersonalSettingData * crowdRemark = [[PersonalSettingData alloc] init];
    crowdRemark.m_title = @"群备注";
    crowdRemark.m_hasIndicator = YES;
    crowdRemark.m_hasLabel = YES;
    crowdRemark.m_content = self.m_detailCrowdInfo.remark;
    NSLog(@"群备注：self.m_detailCrowdInfo.remark == %@", self.m_detailCrowdInfo.remark);

    crowdRemark.m_cellHeight = CELL_HEIGHT;
    
    PersonalSettingData * crowdNotice = [[PersonalSettingData alloc] init];
    crowdNotice.m_title = @"群公告";
    crowdNotice.m_hasIndicator = canEdit;
    crowdNotice.m_hasLabel = YES;
    crowdNotice.m_content = self.m_detailCrowdInfo.announce;
    NSLog(@"群公告：self.m_detailCrowdInfo.announce == %@", self.m_detailCrowdInfo.announce);

    crowdNotice.m_cellHeight = CELL_HEIGHT;

    PersonalSettingData * crowdCategory = [[PersonalSettingData alloc] init];
    crowdCategory.m_title = @"群分类";
    crowdCategory.m_hasIndicator = canEdit;
    crowdCategory.m_hasLabel = YES;
    crowdCategory.m_content = [self getCrowdCategoryWithType:self.m_detailCrowdInfo.category];
    crowdCategory.m_cellHeight = CELL_HEIGHT;
    
    NSLog(@"群分类 == %@", crowdCategory.m_content);
    
    PersonalSettingData * crowdIntroduction = [[PersonalSettingData alloc] init];
    crowdIntroduction.m_title = @"群简介";
    crowdIntroduction.m_hasIndicator = canEdit;
    crowdIntroduction.m_hasLabel = YES;
    crowdIntroduction.m_content = self.m_detailCrowdInfo.description;
    NSLog(@"群简介 == %@", self.m_detailCrowdInfo.description);

    crowdIntroduction.m_cellHeight = CELL_HEIGHT;
    
    [sectionArr addObject:crowdRemark];
    [sectionArr addObject:crowdNotice];
    [sectionArr addObject:crowdCategory];
    [sectionArr addObject:crowdIntroduction];
    
    return sectionArr;
}

- (NSString *)getCrowdCategoryWithType:(NSUInteger)category
{
    // 10, 11, 12, 13, 14, 15, 16, 17
    // 课程，社团，学习，生活，兴趣，老乡，朋友，其他
    NSString * typeStr = nil;
    if (category == 10) {
        typeStr = @"课程";
    } else if (category == 11) {
        typeStr = @"社团";
    } else if (category == 12) {
        typeStr = @"学习";
    } else if (category == 13) {
        typeStr = @"生活";
    } else if (category == 14) {
        typeStr = @"兴趣";
    } else if (category == 15) {
        typeStr = @"老乡";
    } else if (category == 16) {
        typeStr = @"朋友";
    } else if (category == 17) {
        typeStr = @"其他";
    } else{
        typeStr = @"";
    }
    
    return typeStr;
}

- (NSMutableArray *)getThirdSectionArr
{
    NSMutableArray * sectionArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    PersonalSettingData * crowdMember = [[PersonalSettingData alloc] init];
    crowdMember.m_title = @"群成员";
    crowdMember.m_hasIndicator = YES;
    crowdMember.m_hasLabel = YES;
    NSString * numContent = [NSString stringWithFormat:@"%d人", self.m_detailCrowdInfo.cur_member_size];
    NSLog(@"群成员 == %d", self.m_detailCrowdInfo.cur_member_size);

    crowdMember.m_content = numContent;

    crowdMember.m_cellHeight = CELL_HEIGHT;
    
    [sectionArr addObject:crowdMember];
    return sectionArr;
}

- (NSMutableArray *)getFouthSectionArr
{
    NSMutableArray * sectionArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    PersonalSettingData * acceptAndRemind = [[PersonalSettingData alloc] init];
    acceptAndRemind.m_title = @"接收并提醒聊天消息";
    acceptAndRemind.m_hasSelected = YES;
    acceptAndRemind.m_cellHeight = CELL_HEIGHT;
    
    PersonalSettingData * acceptAndNoRemind = [[PersonalSettingData alloc] init];
    acceptAndNoRemind.m_title = @"接收不提醒聊天消息";
    acceptAndNoRemind.m_hasSelected = YES;
    acceptAndNoRemind.m_cellHeight = CELL_HEIGHT;
    
    PersonalSettingData * shieldInfo = [[PersonalSettingData alloc] init];
    shieldInfo.m_title = @"屏蔽聊天消息";
    shieldInfo.m_hasSelected = YES;
    shieldInfo.m_cellHeight = CELL_HEIGHT;
    
    
    //NSInteger alert;//0-接收并提醒；1-接收不提醒；2-不接收
    acceptAndRemind.m_isOnLine = NO;
    acceptAndNoRemind.m_isOnLine = NO;
    shieldInfo.m_isOnLine = NO;
    if (self.m_detailCrowdInfo.alert == 0) {
        acceptAndRemind.m_isOnLine = YES;
    } else if (self.m_detailCrowdInfo.alert == 1) {
        acceptAndNoRemind.m_isOnLine = YES;
    } else if (self.m_detailCrowdInfo.alert == 2) {
        shieldInfo.m_isOnLine = YES;
    }
    
    NSLog(@"群消息设置 == %d", self.m_detailCrowdInfo.alert);
    
    [sectionArr addObject:acceptAndRemind];
    [sectionArr addObject:acceptAndNoRemind];
    [sectionArr addObject:shieldInfo];
    return sectionArr;
}

- (NSMutableArray *)getFifthSectionArr
{
    NSMutableArray * sectionArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    PersonalSettingData * record = [[PersonalSettingData alloc] init];
    record.m_title = @"聊天记录";
    record.m_hasIndicator = YES;
    record.m_cellHeight = CELL_HEIGHT;
    
    [sectionArr addObject:record];
    return sectionArr;
}

@end
