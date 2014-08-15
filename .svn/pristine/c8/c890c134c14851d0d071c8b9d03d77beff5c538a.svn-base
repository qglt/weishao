//
//  FriendsAndGroupView.m
//  WhistleIm
//
//  Created by 管理员 on 13-10-22.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "FriendsAndGroupView.h"
#import "FriendsAndGroupViewCell.h"
#import "FriendGroupSectionInfo.h"
#import "GetFrame.h"
#import "EGORefreshTableHeaderView.h"
#import "GroupCellData.h"
#import "CrowdInfo.h"
#import "GetFrame.h"
#import "ImageUtil.h"
#import "ImUtils.h"
#import "ContactsHeaderView.h"
#define BUTTON_TAG_START 1000
//#define FRIENDS_BUTTON_TAG 1000
//#define STRANGER_BUTTON_TAG 1001


#define SECTION_TITLE @"sectionTitle"
#define ALL_SECTION_DATA @"allSectionData"

@interface FriendsAndGroupView ()
<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate, FriendsAndGroupViewCellDelegate, ContactsHeaderViewDelegate>
{
    CGRect m_frame;
    UITableView * m_tableView;
    EGORefreshTableHeaderView * m_refreshHeaderView;
    
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
    
    NSMutableDictionary * m_dictSectionState;
    
    ContactsHeaderView * m_headerView;
}
@property (nonatomic, strong) UITableView * m_tableView;
@property (nonatomic, strong) EGORefreshTableHeaderView * m_refreshHeaderView;


@property (nonatomic,strong)  NSMutableDictionary * m_dictAllData;
@property (nonatomic,strong) NSMutableArray * m_arrSeactionTitle;
@property (nonatomic,strong) NSMutableArray * m_arrAllSectionData;
@property (nonatomic,strong) NSMutableDictionary * m_dictSectionState;
@property (nonatomic,strong) ContactsHeaderView * m_headerView;



@end

@implementation FriendsAndGroupView

@synthesize m_tableView;
@synthesize m_refreshHeaderView;

@synthesize m_delegate;


@synthesize m_dictAllData;
@synthesize m_arrSeactionTitle;
@synthesize m_arrAllSectionData;
@synthesize m_dictSectionState;

@synthesize m_headerView;


- (id)initWithFrame:(CGRect)frame andIsGroup:(BOOL)isGroup withDataDict:(NSMutableDictionary *)dict
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        m_frame = frame;
        m_selectedIndex = -1;
        m_isGroup = isGroup;
        [self setMemory];

        self.m_dictAllData = dict;
        [self setData:self.m_dictAllData];
        [self createTableView];
        
        if (m_isGroup == NO) {
            [self createHeaderView];
        }
        m_isIOS7 = [[GetFrame shareInstance] isIOS7Version];
    }
    return self;
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
}

- (void)resetMemory:(NSMutableArray *)sectionArr
{
    if (m_isGroup == NO) {
        for (NSUInteger i = 0; i < [sectionArr count]; i++) {
            FriendGroupSectionInfo * sectionTitle = (FriendGroupSectionInfo *)[sectionArr objectAtIndex:i];
            id open = [self.m_dictSectionState objectForKey:sectionTitle.name];
            if (open == nil) {
                [self.m_dictSectionState setObject:[NSNumber numberWithBool:NO] forKey:[NSString stringWithFormat:@"%@", sectionTitle.name]];
            }
        }
        
        NSLog(@"m_dictSectionState frinds=== %@", self.m_dictSectionState);
    } else {
        for (NSUInteger i = 0; i < [sectionArr count]; i++) {
            NSString * groupOrCrowdName = [sectionArr objectAtIndex:i];
            id open = [self.m_dictSectionState objectForKey:groupOrCrowdName];
            if (open == nil) {
                [self.m_dictSectionState setObject:[NSNumber numberWithBool:NO] forKey:[NSString stringWithFormat:@"%@", groupOrCrowdName]];
            }
        }
        NSLog(@"m_dictSectionState group=== %@", self.m_dictSectionState);
    }
}

- (void)headerSearchBarDeleteBtnPressed:(UIButton *)button
{
    [m_delegate cancelButtonPressed];
}

- (void)headerSearchBarTextDidChange:(NSString *)searchText
{
    NSString * usefulText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [m_delegate searchBarTextDidChanged:usefulText];
    });
}

- (void)headerSearchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString * usefulText = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (usefulText && [usefulText length] > 0) {
        [searchBar resignFirstResponder];
    } else {
        [m_delegate showNoneTextAlert];
    }
}

- (void)crwodButtonPressed
{
    [m_delegate pushToCrowdListViewController];
}

- (void)disccusssionButtonPressed
{
    [m_delegate pushToGroupListViewController];
}

- (ContactsHeaderView *)getTableHeaderViewWithFrame:(CGRect)frame
{
    ContactsHeaderView * headerView = [[ContactsHeaderView alloc] initWithFrame:frame];
    headerView.m_delegate = self;
    headerView.hidden = YES;
    return headerView;
}

- (void)createTableView
{
    self.m_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, m_frame.size.height) style:UITableViewStylePlain];
    self.m_tableView.delegate = self;
    self.m_tableView.dataSource = self;
    self.m_tableView.rowHeight = 45.0f;
    self.m_tableView.sectionHeaderHeight = 45.0f;
    self.m_tableView.showsVerticalScrollIndicator = NO;
    self.m_tableView.separatorColor = [UIColor clearColor];
    self.m_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.m_tableView.backgroundColor = [UIColor clearColor];
    self.m_headerView = [self getTableHeaderViewWithFrame:CGRectMake(0, 0, m_frame.size.width, 160)];
    self.m_tableView.tableHeaderView = self.m_headerView;
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
    label.highlightedTextColor = [UIColor whiteColor];
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

    if (m_isGroup == NO) {
        FriendGroupSectionInfo * sectionInfo = [self.m_arrSeactionTitle objectAtIndex:m_selectedIndex];
        NSString * name = sectionInfo.name;
        if (button.selected) {
            [self.m_dictSectionState setObject:[NSNumber numberWithBool:YES] forKey:name];
        } else {
            [self.m_dictSectionState setObject:[NSNumber numberWithBool:NO] forKey:name];
        }
    } else {
        NSString * name = [self.m_arrSeactionTitle objectAtIndex:m_selectedIndex];
        if (button.selected) {
            [self.m_dictSectionState setObject:[NSNumber numberWithBool:YES] forKey:name];
        } else {
            [self.m_dictSectionState setObject:[NSNumber numberWithBool:NO] forKey:name];
        }
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
    if (m_isGroup == NO) {
        FriendGroupSectionInfo * sectionInfo = [self.m_arrSeactionTitle objectAtIndex:section];
        NSString * name = sectionInfo.name;
        NSNumber * sectionState = [self.m_dictSectionState objectForKey:name];
        if ([sectionState boolValue]) {
            return [[self.m_arrAllSectionData objectAtIndex:section] count];
        } else {
            return 0;
        }
    } else {
        NSString * name = [self.m_arrSeactionTitle objectAtIndex:section];
        NSNumber * sectionState = [self.m_dictSectionState objectForKey:name];
        if ([sectionState boolValue]) {
            return [[self.m_arrAllSectionData objectAtIndex:section] count];
        } else {
            return 0;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId = @"cellIdentity";
    FriendsAndGroupViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[FriendsAndGroupViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.m_delegate = self;
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellBackground.png"]];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    cell.m_isGroup = m_isGroup;
    
    if (cell.m_isGroup) {
        if (indexPath.section == 0) {
            cell.m_isCrowd = YES;
        } else if (indexPath.section == 1) {
            cell.m_isCrowd = NO;
        }
    }
   
    if (m_isGroup == NO) {
        FriendInfo * aFriendInfo = (FriendInfo *)[[self.m_arrAllSectionData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        [cell setCellData:aFriendInfo];
    } else {
        if (cell.m_isCrowd == NO) {
            GroupCellData * groupData = (GroupCellData *)[[self.m_arrAllSectionData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            [cell setCrowdAndGroupData:groupData];
        } else {
            CrowdInfo * crowdInfo = (CrowdInfo *)[[self.m_arrAllSectionData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            [cell setCrowdAndGroupData:crowdInfo];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

// cell delegate
- (void)cellImageButtonPressed:(UIButton *)button
{
    FriendsAndGroupViewCell * cell = nil;
    if (m_isIOS7) {
        cell = (FriendsAndGroupViewCell *)button.superview.superview;
    } else {
        cell = (FriendsAndGroupViewCell *)button.superview;
    }
    
    NSIndexPath * indexPath = [self.m_tableView indexPathForCell:cell];
    if (!m_isGroup) {
        [m_delegate cellButtonPressedInFriendsAndGroupView:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (m_isGroup == NO) {
        FriendInfo * friendInfo = [[self.m_arrAllSectionData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        [m_delegate didSelectRowAtIndexPath:friendInfo];
    } else {
        if (indexPath.section == 1) {
            GroupCellData * cellData = [[self.m_arrAllSectionData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            [m_delegate didSelectRowAtIndexPathWithGroupJid:cellData];
        } else if (indexPath.section == 0) {
            CrowdInfo * crowdInfo =  [[self.m_arrAllSectionData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            if (crowdInfo.status != 1) {
                [m_delegate didSelectRowAtIndexPathWithCrowdInfo:crowdInfo];
            }
        }
    }
}

- (void)closeKeyBoard
{
    [self.m_headerView contactsHeaderViewresignFirstResponder];
}

- (void)clearSearchBarText
{
    [self.m_headerView contactsHeaderViewClearSearchBarText];
}

- (void)hiddenDeleteBtn
{
    [self.m_headerView hiddenDeleteButton];
}

- (void)pullDownReloadDataFinished
{

}

- (void)refreshTableView:(NSMutableDictionary *)dictData
{
    self.m_dictAllData = dictData;
    [self setData:self.m_dictAllData];
    
     dispatch_async(dispatch_get_main_queue(), ^{
         self.m_tableView.tableHeaderView.hidden = NO;
         [self.m_tableView reloadData];
         [self doneLoadingTableViewData];
    });
}

-(void)createHeaderView
{
    if (self.m_refreshHeaderView && [self.m_refreshHeaderView superview]) {
        [self.m_refreshHeaderView removeFromSuperview];
    }
    self.m_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:
                                CGRectMake(0.0f, 0.0f - 480,
                                           320, 480)];
    self.m_refreshHeaderView.delegate = self;
    
    [self.m_tableView addSubview:self.m_refreshHeaderView];
    
    [self.m_refreshHeaderView refreshLastUpdatedDate];
}

- (void)reloadTableViewDataSource
{
    NSLog(@"==开始加载数据");
    m_reloading = YES;
    [m_delegate pullDownToReloadData];
}

- (void)doneLoadingTableViewData
{
    NSLog(@"===加载完数据");
    m_reloading = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.m_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.m_tableView];
    });
}

#pragma mark –
#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [m_delegate cancelButtonPressed];
    [self.m_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.m_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark –
#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    [self reloadTableViewDataSource];
    //[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return m_reloading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
    return [NSDate date];
}



@end
