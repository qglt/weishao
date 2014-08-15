//
//  ShakeTableView.m
//  RJShakeImageView
//
//  Created by 管理员 on 13-12-24.
//  Copyright (c) 2013年 lizuoying. All rights reserved.
//

#import "ShakeTableView.h"
#import "ShakeTableViewCell.h"
#import "ImUtils.h"

@interface ShakeTableView ()
<UITableViewDataSource, UITableViewDelegate, ShakeTableViewCellDelegate>
{
    UITableView * m_tableView;
    NSMutableDictionary * m_dictData;
    
    CGRect m_frame;
    BOOL m_isEdit;
}

@property (nonatomic, strong) UITableView * m_tableView;
@property (nonatomic, strong) NSMutableDictionary * m_dictData;

@end

@implementation ShakeTableView

@synthesize m_tableView;

@synthesize m_arrTableData;

@synthesize m_dictData;

@synthesize m_delegate;

- (id)initWithFrame:(CGRect)frame withDataArr:(NSMutableDictionary *)dataDict
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        m_frame = frame;
        self.m_dictData = dataDict;
        [self createTableView];
    }
    return self;
}

- (void)createTableView
{
    self.m_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, m_frame.size.width, m_frame.size.height) style:UITableViewStylePlain];
    self.m_tableView.delegate = self;
    self.m_tableView.dataSource = self;
    self.m_tableView.rowHeight = 84.0f;
    self.m_tableView.sectionHeaderHeight = 25.0f;
    self.m_tableView.showsVerticalScrollIndicator = NO;
    self.m_tableView.separatorColor = [UIColor clearColor];
    self.m_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.m_tableView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.m_tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSMutableArray * adminArr = [self.m_dictData objectForKey:@"admin"];
    NSMutableArray * memberArr = [self.m_dictData objectForKey:@"member"];
    
    NSInteger section = -1;
    
    if ([adminArr count] > 0 && [memberArr count] > 0) {
        section = [self.m_dictData count];
    } else if (([adminArr count] > 0 && [memberArr count] <= 0) || ([adminArr count] <= 0 && [memberArr count] > 0)) {
        section = [self.m_dictData count] - 1;
    } else {
        section = 0;
    }
    
    return section;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray * sectionArr = nil;
    if (section == 0) {
        sectionArr = [self.m_dictData objectForKey:@"admin"];
    } else if (section == 1) {
        sectionArr = [self.m_dictData objectForKey:@"member"];
    }
    
    return [sectionArr count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 25)];
    bgView.backgroundColor = [ImUtils colorWithHexString:@"#F0F0F0"];

    UILabel * sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 25)];
    sectionLabel.backgroundColor = [UIColor clearColor];
    sectionLabel.textColor = [ImUtils colorWithHexString:@"#808080"];
    sectionLabel.textAlignment = NSTextAlignmentCenter;
    sectionLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:12.0f];
    if (section == 0) {
        sectionLabel.text = @"管理员";
    } else if (section == 1) {
        sectionLabel.text = @"群成员";
    }
    
    [bgView addSubview:sectionLabel];
    return bgView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId = @"shake";
    ShakeTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[ShakeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.m_delegate = self;
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellBackground.png"]];
    }
    
    NSMutableArray * sectionArr = nil;
    if (indexPath.section == 0) {
        sectionArr = [self.m_dictData objectForKey:@"admin"];
    } else if (indexPath.section == 1) {
        sectionArr = [self.m_dictData objectForKey:@"member"];
    }
    cell.m_arrImagePath = [sectionArr objectAtIndex:indexPath.row];
    cell.m_isEdit = m_isEdit;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setCellData];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

- (void)refreshTableView:(NSMutableDictionary *)dataDict andIsEditState:(BOOL)isEdit
{
    self.m_dictData = dataDict;
    m_isEdit = isEdit;
    [self.m_tableView reloadData];
}

- (void)deleteButtonPressedInShakeTableViewCell:(id)mySelf andImageTag:(NSUInteger)deleteTag
{
    ShakeTableViewCell * cell = (ShakeTableViewCell *)mySelf;
    NSIndexPath * indexPath = [self.m_tableView indexPathForCell:cell];
    [m_delegate deleteButtonPressedInShakeTableView:indexPath andImageTag:deleteTag];
}

- (void)addButtonPressedInShakeTableViewCell
{
    [m_delegate addButtonPressedInShakeTableView];
}

@end
