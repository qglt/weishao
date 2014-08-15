//
//  GroupInfoTableView.m
//  WhistleIm
//
//  Created by 管理员 on 14-2-21.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "GroupInfoTableView.h"
#import "ImUtils.h"
#import "PersonalTableViewCell.h"
#import "PersonalSettingData.h"
#import "ShakeTableViewCell.h"
#import "ShakeTableViewCell.h"

#define HEADER_HEIGHT 8.0f

@interface GroupInfoTableView ()
<UITableViewDataSource, UITableViewDelegate, ShakeTableViewCellDelegate>
{
    CGRect m_frame;
    UITableView * m_tableView;
    NSMutableArray * m_arrTableData;
    
    UIButton * m_dissolveBtn;
    NSMutableArray * m_arrTitle;
    NSMutableArray * m_arrImages;
}

@property (nonatomic, strong) UITableView * m_tableView;
@property (nonatomic, strong) NSMutableArray * m_arrTableData;
@property (nonatomic, strong) UIButton * m_dissolveBtn;
@property (nonatomic, strong) NSString * m_mySelfAuthority;
@property (nonatomic, strong) NSMutableArray * m_arrTitle;
@property (nonatomic, strong) NSMutableArray * m_arrImages;

@end

@implementation GroupInfoTableView

@synthesize m_tableView;
@synthesize m_arrTableData;
@synthesize m_dissolveBtn;
@synthesize m_arrImages;
@synthesize m_arrTitle;
@synthesize m_delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        m_frame = frame;
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
    self.m_tableView.hidden = YES;
    self.m_tableView.separatorColor = [UIColor clearColor];
    self.m_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.m_tableView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.m_tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return [self.m_arrImages count];
    } else if (section == 2) {
        return 1;
    } else if (section == 3) {
        return 1;
    } else {
        return 0;
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
    if (indexPath.section == 0) {
        PersonalSettingData * data = [self.m_arrTitle objectAtIndex:0];
        return data.m_cellHeight;
    } else if (indexPath.section == 2) {
        PersonalSettingData * data = [self.m_arrTitle objectAtIndex:1];
        return data.m_cellHeight;
    } else if (indexPath.section == 1) {
        return 84.0f;
    } else if (indexPath.section == 3){
        return 45.0f + 8.0f;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cellforrow");
    if (indexPath.section == 0 || indexPath.section == 2) {
        
        static NSString * cellID = @"groupInfo";
        PersonalTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[PersonalTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellBackground.png"]];
        }
        
        PersonalSettingData * settingData = nil;
        if (indexPath.section == 0) {
            settingData = [self.m_arrTitle objectAtIndex:0];
        } else if (indexPath.section == 2) {
            settingData = [self.m_arrTitle objectAtIndex:1];
        }
        
        [cell setCellWithSettingData:settingData];
        return cell;
        
    } else if (indexPath.section == 1) {
        
        static NSString * cellId = @"shake";
        ShakeTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[ShakeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            cell.m_delegate = self;
        }
        
        cell.m_arrImagePath = [self.m_arrImages objectAtIndex:indexPath.row];
        cell.m_isEdit = NO;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setCellData];
        return cell;
        
    } else if (indexPath.section == 3) {
        static NSString * cellID = @"dissolve";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            [cell addSubview:[self createDissolveCrowdButton]];
            if (self.m_dissolveBtn.hidden) {
                cell.backgroundColor = [UIColor clearColor];
            } else {
                cell.backgroundColor = [UIColor whiteColor];
            }
        }
        
        return cell;
        
    } else {

        return nil;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

- (void)addButtonPressedInShakeTableViewCell
{
    [m_delegate addGroupMember];
}

- (UIButton *)createDissolveCrowdButton
{
    // redBtnImageNormal.png   redBtnImageHighLight.png
    UIButton * button = [self createButtonsWithFrame:CGRectMake(0, 0, m_frame.size.width, 45) andTitle:@"退出讨论组" andImage:@"redBtnImageNormal.png" andSelectedImage:@"redBtnImageHighLight.png" andTag:1000];
    button.hidden = YES;
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
    [m_delegate leaveGroup];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 0) {
        [m_delegate changeGroupName];
    } else if (indexPath.section == 2) {
        [m_delegate showGroupRecord];
    } else if (indexPath.section == 3) {
        
    }
}

- (void)refreshTableViewWithTitleArr:(NSMutableArray *)titleArr andImageArr:(NSMutableArray *)imageArr
{
    self.m_tableView.hidden = NO;
    self.m_dissolveBtn.hidden = NO;
    self.m_arrTitle = titleArr;
    self.m_arrImages = imageArr;
    [self.m_tableView reloadData];
}

@end
