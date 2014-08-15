//
//  AddMembersTableView.m
//  WhistleIm
//
//  Created by 管理员 on 14-2-13.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "AddMembersTableView.h"
#import "CustomSearchBar.h"
#import "ImUtils.h"

#import "FriendsAndGroupViewCell.h"
#import "FriendGroupSectionInfo.h"
#import "GetFrame.h"
#import "EGORefreshTableHeaderView.h"
#import "GroupCellData.h"
#import "CrowdInfo.h"
#import "GetFrame.h"
#import "ImageUtil.h"
#import "AddMembersTableViewCell.h"
#import "FriendInfo.h"

#define SECTION_TITLE @"sectionTitle"
#define ALL_SECTION_DATA @"allSectionData"

#define BUTTON_TAG_START 1000


@interface AddMembersTableView ()
<CustomSearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
{
    CGRect m_frame;
    CustomSearchBar * m_searchBar;
    
    UITableView * m_tableView;
    
    NSInteger m_selectedIndex;
    BOOL m_isFristOpend;
    BOOL m_isSecondOpend;
    
    BOOL m_isGroup;
    BOOL m_reloading;
    BOOL m_isIOS7;
    BOOL m_buttonState;
    
    NSMutableDictionary * m_dictAllData;
    NSMutableArray * m_arrSeactionTitle;
    NSMutableArray * m_arrAllSectionData;
    
    // 每一个分组打开或关闭数组
    NSMutableDictionary * m_dictSectionState;
    
    // 每一个分组里面的某一项是否被选中数组
    NSMutableArray * m_arrIsSelected;
    
    NSMutableArray * m_arrSelectedJid;
}

@property (nonatomic, strong) CustomSearchBar * m_searchBar;
@property (nonatomic, strong) UITableView * m_tableView;




@property (nonatomic,strong)  NSMutableDictionary * m_dictAllData;
@property (nonatomic,strong) NSMutableArray * m_arrSeactionTitle;
@property (nonatomic,strong) NSMutableArray * m_arrAllSectionData;
@property (nonatomic,strong) NSMutableDictionary * m_dictSectionState;
@property (nonatomic,strong) NSMutableArray * m_arrIsSelected;
@property (nonatomic,strong) NSMutableArray * m_arrSelectedJid;


@end

@implementation AddMembersTableView

@synthesize m_searchBar;
@synthesize m_tableView;

@synthesize m_dictAllData;
@synthesize m_arrSeactionTitle;
@synthesize m_arrAllSectionData;
@synthesize m_dictSectionState;
@synthesize m_arrIsSelected;

@synthesize m_delegate;
@synthesize m_arrSelectedJid;
@synthesize m_maxLimitNum;


- (id)initWithFrame:(CGRect)frame withDataDict:(NSMutableDictionary *)dict
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        m_frame = frame;
        [self setMemory];
        [self createTableView];
    }
    return self;
}

- (UIView *)createSearchBar
{
    UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, m_frame.size.width, 45)];
    bgView.backgroundColor = [ImUtils colorWithHexString:@"#d9d9d9"];
    [self addSubview:bgView];
    
    self.m_searchBar = [[CustomSearchBar alloc] initWithFrame:CGRectMake(5, 8, m_frame.size.width - 5 * 2, 29)];
    self.m_searchBar.m_delegate = self;
    [bgView addSubview:self.m_searchBar];
    return bgView;
}

// CustomSearchBar delegate
- (void)deleteButtonPressed:(UIButton *)button
{
    NSLog(@"delete button pressed in AddMembersTableView");
    [m_delegate cancelButtonPressed];
}

// CustomSearchBar delegate
- (void)searchBarTextDidChange:(NSString *)searchText
{
    NSString * usefulText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [m_delegate searchBarTextDidChanged:usefulText];
    });
        
    // 实时更新好友页面的选中状态到控制器
    [m_delegate friendCellDidSelectedWithIndexPath:nil andSelectedJidArr:self.m_arrSelectedJid];
}

// CustomSearchBar delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString * usefulText = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (usefulText && [usefulText length] > 0) {
        [searchBar resignFirstResponder];
    } else {
        [m_delegate showNoneTextAlert];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self resignFirstResponderForSearchBar];
}

- (void)resignFirstResponderForSearchBar
{
    [self.m_searchBar.m_searchBar resignFirstResponder];
}

- (void)setMemory
{
    self.m_dictSectionState = [[NSMutableDictionary alloc] initWithCapacity:0];
}

- (void)setData:(NSMutableDictionary *)dictData
{
    self.m_arrSeactionTitle = [dictData objectForKey:SECTION_TITLE];
    self.m_arrAllSectionData = [dictData objectForKey:ALL_SECTION_DATA];
    [self resetMemory:self.m_arrSeactionTitle];
    self.m_arrIsSelected = [self getSelectedArr:self.m_arrAllSectionData];
}

- (void)resetMemory:(NSMutableArray *)sectionArr
{
    for (NSUInteger i = 0; i < [sectionArr count]; i++) {
        FriendGroupSectionInfo * sectionTitle = (FriendGroupSectionInfo *)[sectionArr objectAtIndex:i];
        id open = [self.m_dictSectionState objectForKey:sectionTitle.name];
        if (open == nil) {
            [self.m_dictSectionState setObject:[NSNumber numberWithBool:NO] forKey:[NSString stringWithFormat:@"%@", sectionTitle.name]];
        }
    }
    
    NSLog(@"m_dictSectionState frinds=== %@", self.m_dictSectionState);
}

// 根据选中的jid，确定cell的选中状态
- (NSMutableArray *)getSelectedArr:(NSMutableArray *)allDataArr
{
    NSMutableArray * totalSelectedArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSUInteger i = 0; i < [allDataArr count]; i++) {
        NSMutableArray * selectedStateArr = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableArray * eachSectionArr = [allDataArr objectAtIndex:i];
        for (NSUInteger j = 0; j < [eachSectionArr count]; j++) {
            FriendInfo * friendInfo = [eachSectionArr objectAtIndex:j];
           
            [selectedStateArr addObject:[NSNumber numberWithBool:[self isSelected:friendInfo.jid]]];
        }
        
        [totalSelectedArr addObject:selectedStateArr];
    }
    
    NSLog(@"friend selected state arr in AddMembersTableView and count == %@", totalSelectedArr);
    return totalSelectedArr;
}

- (BOOL)isSelected:(NSString *)friendJid
{
    BOOL result = NO;
    for (NSUInteger i = 0; i < [self.m_arrSelectedJid count]; i++) {
        if ([friendJid isEqualToString:[self.m_arrSelectedJid objectAtIndex:i]]) {
            result = YES;
            break;
        }
    }
    
    return result;
}


- (void)createTableView
{
    self.m_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, m_frame.size.width, m_frame.size.height) style:UITableViewStylePlain];
    self.m_tableView.delegate = self;
    self.m_tableView.dataSource = self;
    self.m_tableView.rowHeight = 45.0f;
    self.m_tableView.sectionHeaderHeight = 45.0f;
    self.m_tableView.showsVerticalScrollIndicator = NO;
    self.m_tableView.separatorColor = [UIColor clearColor];
    self.m_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.m_tableView.backgroundColor = [UIColor clearColor];
    self.m_tableView.tableHeaderView = [self createSearchBar];
    self.m_tableView.tableHeaderView.hidden = YES;
    [self addSubview:self.m_tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.m_arrSeactionTitle count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self getHeaderViewWithSection:section];
}

- (UIView *)getHeaderViewWithSection:(NSUInteger)section
{
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
    headerView.backgroundColor =[UIColor whiteColor];
    
    NSString * name = nil;
    NSNumber * sectionState = nil;
    if (m_isGroup == NO) {
        FriendGroupSectionInfo * sectionInfo = [self.m_arrSeactionTitle objectAtIndex:section];
        name = sectionInfo.name;
    } else {
        name = [self.m_arrSeactionTitle objectAtIndex:section];
    }
    sectionState = [self.m_dictSectionState objectForKey:name];
    
    [headerView addSubview:[self getButtonWithFrame:CGRectMake(0, 0, 320, 45) andSection:section andSelected:[sectionState boolValue]]];
    
    if (m_isGroup == NO) {
        FriendGroupSectionInfo * sectionInfo = [self.m_arrSeactionTitle objectAtIndex:section];
        [headerView addSubview:[self getLabelWithFrame:CGRectMake(49, 15, 197, 15) andLabelText:sectionInfo.name andTextAlignment:NSTextAlignmentLeft isName:YES]];
        [headerView addSubview:[self getLabelWithFrame:CGRectMake(197 + 49 + 15, (45 - 12) / 2.0f, 44, 12) andLabelText:[NSString stringWithFormat:@"%d/%d", sectionInfo.onlineCount, sectionInfo.totalCount ] andTextAlignment:NSTextAlignmentRight isName:NO]];
    } else {
        [headerView addSubview:[self getLabelWithFrame:CGRectMake(49, 15, 197, 15) andLabelText:[self.m_arrSeactionTitle objectAtIndex:section] andTextAlignment:NSTextAlignmentLeft isName:YES]];
        NSString * number = [NSString stringWithFormat:@"%d", [[self.m_arrAllSectionData objectAtIndex:section] count]];
        [headerView addSubview:[self getLabelWithFrame:CGRectMake(197 + 49 + 15, (45 - 12) / 2.0f, 44, 12) andLabelText:number andTextAlignment:NSTextAlignmentRight isName:NO]];
    }
    
    [headerView addSubview:[self getSectionIndicatorImageViewWithFrame:CGRectMake(24, 18, 9, 9) andIsOpend:[sectionState boolValue]]];
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44.5, 320, 0.5)];
    imageView.image = [UIImage imageNamed:@"separateLine.png"];
    [headerView addSubview:imageView];
    
    return headerView;
}


- (UILabel *)getLabelWithFrame:(CGRect)frame andLabelText:(NSString *)text andTextAlignment:(NSTextAlignment)alignment isName:(BOOL) isName
{
    UILabel * label = [[UILabel alloc] initWithFrame:frame];
    label.text = text;
    if (isName) {
        label.textColor = [ImUtils colorWithHexString:@"#262626"];
        UIFont* font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
        [label setFont:font];
        label.backgroundColor = [UIColor clearColor];
    }else{
        label.textColor = [ImUtils colorWithHexString:@"#808080"];
        UIFont* font = [UIFont fontWithName:@"STHeitiSC-Thin" size:12.0f];
        [label setFont:font];
        label.backgroundColor = [UIColor clearColor];
    }
    label.textAlignment = alignment;
//    label.backgroundColor = [UIColor clearColor];
    return label;
}

- (UIImageView *)getSectionIndicatorImageViewWithFrame:(CGRect)frame andIsOpend:(BOOL)isOpen
{
    // friend_expanded.png  friend_collapsed.png
    UIImageView * indicatorImageView = [[UIImageView alloc] initWithFrame:frame];
    if (isOpen) {
        indicatorImageView.image = [UIImage imageNamed:@"downGray.png"];
        indicatorImageView.highlightedImage = [UIImage imageNamed:@"downWhite.png"];
    } else {
        indicatorImageView.image = [UIImage imageNamed:@"leftGray.png"];
        indicatorImageView.highlightedImage = [UIImage imageNamed:@"leftWhite.png"];
    }
    indicatorImageView.backgroundColor = [UIColor clearColor];
    return indicatorImageView;
}

- (UIButton *)getButtonWithFrame:(CGRect)frame andSection:(NSUInteger)section andSelected:(BOOL)isSelected
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.selected = isSelected;
    button.tag = BUTTON_TAG_START + section;
    button.backgroundColor = [UIColor whiteColor];
    
    [button setBackgroundImage:[UIImage imageNamed:@"whiteButtonNormal.png"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"whiteButtonSelected.png"] forState:UIControlStateHighlighted];
    
    [button addTarget:self action:@selector(headerViewButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(buttonPressedDown:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(buttonPressedDown:) forControlEvents:UIControlEventTouchCancel];
    [button addTarget:self action:@selector(buttonPressedDown:) forControlEvents:UIControlEventTouchUpOutside];
    return button;
}

- (void)buttonPressedDown:(UIButton *)button
{
    [self resetIndicatorImageWithButton:button andIsHighlighted:YES];
    [self resetTitleTextColorWithButton:button andIsHighlighted:YES];
}

- (void)headerViewButtonPressed:(id)sender
{
    NSLog(@"headerViewButtonPressed");
    UIButton * button = (UIButton *)sender;
    button.selected = !button.selected;
    
    m_selectedIndex = button.tag - BUTTON_TAG_START;
    NSLog(@"m_selectedIndex ==== %d", m_selectedIndex);
    NSLog(@"button.selected ==== %d", button.selected);
    
    FriendGroupSectionInfo * sectionInfo = [self.m_arrSeactionTitle objectAtIndex:m_selectedIndex];
    NSString * name = sectionInfo.name;
    if (button.selected) {
        [self.m_dictSectionState setObject:[NSNumber numberWithBool:YES] forKey:name];
    } else {
        [self.m_dictSectionState setObject:[NSNumber numberWithBool:NO] forKey:name];
    }
    
    NSLog(@"self.m_dictSectionState ==== %@", self.m_dictSectionState);
    NSLog(@"allkey == %@", [self.m_dictSectionState allKeys]);
    for (NSInteger i = 0; i < [[self.m_dictSectionState allKeys] count]; i++) {
        NSLog(@"section name in dict == %@", [[self.m_dictSectionState allKeys] objectAtIndex:i]);
    }
    NSLog(@"allvalue == %@", [self.m_dictSectionState allValues]);
    
    [self resetIndicatorImageWithButton:button andIsHighlighted:NO];
    [self resetTitleTextColorWithButton:button andIsHighlighted:NO];
    
    [self.m_tableView reloadData];
}

- (void)resetIndicatorImageWithButton:(UIButton *)button andIsHighlighted:(BOOL)highlighted
{
    UIView * headerView = button.superview;
    for (UIView * subView in headerView.subviews) {
        if ([subView isKindOfClass:[UIImageView class]]) {
            UIImageView * indicatorImageView = (UIImageView *)subView;
            indicatorImageView.highlighted = highlighted;
        }
    }
}

- (void)resetTitleTextColorWithButton:(UIButton *)button andIsHighlighted:(BOOL)highlighted
{
    UIView * headerView = button.superview;
    for (UIView * subView in headerView.subviews) {
        if ([subView isKindOfClass:[UILabel class]]) {
            UILabel * label = (UILabel *)subView;
            label.highlighted = highlighted;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    FriendGroupSectionInfo * sectionInfo = [self.m_arrSeactionTitle objectAtIndex:section];
    NSString * name = sectionInfo.name;
    NSNumber * sectionState = [self.m_dictSectionState objectForKey:name];
    if ([sectionState boolValue]) {
        return [[self.m_arrAllSectionData objectAtIndex:section] count];
    } else {
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId = @"cellIdentity";
    AddMembersTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[AddMembersTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellBackground.png"]];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    FriendInfo * aFriendInfo = (FriendInfo *)[[self.m_arrAllSectionData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    BOOL selected = [[[self.m_arrIsSelected objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] boolValue];
    [cell setCellData:aFriendInfo andIsSelected:selected andType:@"friend"];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    // 更新选中状态数组
    NSMutableArray * selectedStateArr = [self.m_arrIsSelected objectAtIndex:indexPath.section];
    BOOL selected = [[selectedStateArr objectAtIndex:indexPath.row] boolValue];
    selected = !selected;
    [selectedStateArr replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:selected]];
    NSLog(@"selected state arr in AddMembersTableView == %@", self.m_arrIsSelected);

    // 更新jid数组
    NSMutableArray * eachSectionDataArr = [self.m_arrAllSectionData objectAtIndex:indexPath.section];
    FriendInfo * selectedFriendInfo = [eachSectionDataArr objectAtIndex:indexPath.row];
    if (selected) {
        [self.m_arrSelectedJid addObject:selectedFriendInfo.jid];
    } else {
        [self.m_arrSelectedJid removeObject:selectedFriendInfo.jid];
    }
    NSLog(@"selected jid arr in AddMembersTableView == %@, and count == %d", self.m_arrSelectedJid, [self.m_arrSelectedJid count]);
    
    NSLog(@"had selected == %d", [self.m_arrSelectedJid count]);
    NSLog(@"max limit num == %d", self.m_maxLimitNum);
    if ([self.m_arrSelectedJid count] > self.m_maxLimitNum) {
        [self.m_arrSelectedJid removeLastObject];
        selected = !selected;
        [selectedStateArr replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:selected]];
        return;
    }
    // 刷新
    [self.m_tableView reloadData];

    
    // 实时更新好友页面的选中状态到控制器
    [m_delegate friendCellDidSelectedWithIndexPath:indexPath andSelectedJidArr:self.m_arrSelectedJid];
}

- (NSUInteger)getSubtractIndexWithJid:(NSString *)jid
{
    NSLog(@"subtract jid in friend page == %@", jid);
    NSLog(@"self.m_arrSelectedJid in friend page == %@", self.m_arrSelectedJid);

    NSUInteger index = 0;
    for (NSUInteger i = 0; i < [self.m_arrSelectedJid count]; i++) {
        if ([jid isEqualToString:[self.m_arrSelectedJid objectAtIndex:i]]) {
            index = i;
            break;
        }
    }
    
    NSLog(@"index == %d", index);
    
    return index;
}

- (void)refreshTableView:(NSMutableDictionary *)dictData andSelectedJidArr:(NSMutableArray *)selectedJidArr
{
    self.m_arrSelectedJid = selectedJidArr;
    self.m_dictAllData = dictData;
    [self setData:self.m_dictAllData];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.m_tableView.tableHeaderView.hidden = NO;

        [self.m_tableView reloadData];
    });
}

@end
