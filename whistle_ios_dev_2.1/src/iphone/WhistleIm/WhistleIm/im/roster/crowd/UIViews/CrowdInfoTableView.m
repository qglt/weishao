//
//  CrowdInfoTableView.m
//  WhistleIm
//
//  Created by 管理员 on 14-1-16.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "CrowdInfoTableView.h"
#import "PersonalTableViewCell.h"
#import "GBPathImageView.h"
#include "PersonalSettingData.h"
#import "ImUtils.h"

#define SUPER @"super"
#define ADMIN @"admin"
#define MEMBER @"member"
#define HEADER_HEIGHT 8.0f

@interface CrowdInfoTableView ()
<UITableViewDataSource, UITableViewDelegate>
{
    CGRect m_frame;
    UITableView * m_tableView;
    NSMutableArray * m_arrTableData;
    
    UIButton * m_dissolveBtn;
    
    GBPathImageView * m_crowdHeadImageView;
    NSString * m_mySelfAuthority;

}

@property (nonatomic, strong) UITableView * m_tableView;
@property (nonatomic, strong) NSMutableArray * m_arrTableData;
@property (nonatomic, strong) GBPathImageView * m_crowdHeadImageView;
@property (nonatomic, strong) UIButton * m_dissolveBtn;
@property (nonatomic, strong) NSString * m_mySelfAuthority;

@end

@implementation CrowdInfoTableView

@synthesize m_tableView;
@synthesize m_arrTableData;
@synthesize m_crowdHeadImageView;
@synthesize m_delegate;
@synthesize m_dissolveBtn;
@synthesize m_mySelfAuthority;

- (id)initWithFrame:(CGRect)frame withTableDataArr:(NSMutableArray *)tableData andMySelfAuthority:(NSString *)authority
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        m_frame = frame;
        self.m_mySelfAuthority = authority;
        self.m_arrTableData = tableData;
        [self createTableView];
    }
    return self;
}

- (void)createTableView
{
    self.m_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, m_frame.size.width, m_frame.size.height) style:UITableViewStylePlain];
    self.m_tableView.delegate = self;
    self.m_tableView.dataSource = self;
    self.m_tableView.showsVerticalScrollIndicator = NO;
    self.m_tableView.separatorColor = [UIColor clearColor];
    self.m_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.m_tableView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.m_tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    if ([self.m_mySelfAuthority isEqualToString:SUPER]) {
//        return [self.m_arrTableData count] + 1;
//    } else {
//        return [self.m_arrTableData count];
//    }
    
    return [self.m_arrTableData count] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section < [self.m_arrTableData count]) {
        return [[self.m_arrTableData objectAtIndex:section] count];
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEADER_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, m_frame.size.width, HEADER_HEIGHT)];
    headerView.backgroundColor = [ImUtils colorWithHexString:@"#F0F0F0"];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < [self.m_arrTableData count]) {
        NSMutableArray * eachSectionArr = [self.m_arrTableData objectAtIndex:indexPath.section];
        PersonalSettingData * data = [eachSectionArr objectAtIndex:indexPath.row];
        return data.m_cellHeight;
    } else {
        return 45.0f + 8.0f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < [self.m_arrTableData count]) {
        static NSString * cellID = @"crowdInfo";
        PersonalTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[PersonalTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellBackground.png"]];
        }
        
        
        NSMutableArray * eachSectionArr = [self.m_arrTableData objectAtIndex:indexPath.section];
        PersonalSettingData * settingData = [eachSectionArr objectAtIndex:indexPath.row];
        if (!settingData.m_hasIndicator) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.m_isCrowdDetailInfo = YES;
        [cell setCellWithSettingData:settingData];
        
        return cell;
        
    } else {
        static NSString * cellID = @"dissolve";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            [cell addSubview:[self createDissolveCrowdButton]];
            cell.backgroundColor = [UIColor whiteColor];
        }
    
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

- (UIButton *)createDissolveCrowdButton
{
    // redBtnImageNormal.png   redBtnImageHighLight.png
    
    NSString * btnTitle = nil;
    NSUInteger btnTag = 0;
    if ([self.m_mySelfAuthority isEqualToString:SUPER]) {
        btnTitle = @"解散群";
        btnTag = 1000;
    } else {
        btnTitle = @"退出群";
        btnTag = 2000;
    }
    
    UIButton * button = [self createButtonsWithFrame:CGRectMake(0, 0, m_frame.size.width, 45) andTitle:btnTitle andImage:@"redBtnImageNormal.png" andSelectedImage:@"redBtnImageHighLight.png" andTag:btnTag];
    self.m_dissolveBtn = button;
    return button;
}

- (UIButton *)createButtonsWithFrame:(CGRect)frame andTitle:(NSString *)title andImage:(NSString *)imagePath andSelectedImage:(NSString *)selectedImagePath andTag:(NSUInteger)tag
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:imagePath] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:selectedImagePath] forState:UIControlStateSelected];
    [button setBackgroundImage:[UIImage imageNamed:selectedImagePath] forState:UIControlStateHighlighted];
    button.frame = frame;
    button.tag = tag;
    button.backgroundColor = [UIColor redColor];
    [button addTarget:self action:@selector(functionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, button.frame.size.width, button.frame.size.height)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.text = title;
    [button addSubview:label];
    
    return button;
}

- (void)functionButtonPressed:(UIButton *)button
{
    if (button.tag == 1000) {
        [m_delegate dissolveCrowd];
    } else if (button.tag == 2000) {
        [m_delegate quitCrowd];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == [self.m_arrTableData count]) {
        if (![self.m_mySelfAuthority isEqualToString:SUPER]) {
            return;
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableArray * eachSectionArr = [self.m_arrTableData objectAtIndex:indexPath.section];
    PersonalSettingData * settingData = [eachSectionArr objectAtIndex:indexPath.row];
    
    if (settingData.m_hasIndicator || settingData.m_hasSelected) {
        if (indexPath.section == 3) {
            [self changeOnlineState:indexPath.row];
            [m_delegate changeCrowdAcceptStateWithIndex:indexPath.row];
        } else if (indexPath.section == [self.m_arrTableData count] - 1) {
            [m_delegate showCrowdTalkRecord];
        } else if (indexPath.section == 2) {
            [m_delegate showCrowdMembers];
        } else if (indexPath.section == 0 && indexPath.row == 0) {
            [m_delegate changeCrowdImage];
        } else if (indexPath.section == 1 && indexPath.row == 2) {
            [m_delegate changeCrowdCategory];
        } else {
            [m_delegate changeCrowdOthersInfoWithIndex:indexPath];
        }
    }
}

- (void)changeOnlineState:(NSUInteger)index
{
    if ([self.m_arrTableData count] > 3) {
        NSMutableArray * eachSectionArr = [self.m_arrTableData objectAtIndex:3];
        for (NSUInteger i = 0; i < [eachSectionArr count]; i++) {
            PersonalSettingData * onLineData = [eachSectionArr objectAtIndex:i];
            
            if (i == index) {
                onLineData.m_isOnLine = YES;
            } else {
                onLineData.m_isOnLine = NO;
            }
            
            NSLog(@"m_isOnLine == %d", onLineData.m_isOnLine);
        }
    }
    [self.m_tableView reloadData];
}

- (void)refreshCrowdInfoTableViewWithDataArr:(NSMutableArray *)tableData andMySelfAuthority:(NSString *)authority
{
    self.m_mySelfAuthority = authority;
    self.m_arrTableData = tableData;
    [self.m_tableView reloadData];
}

@end
