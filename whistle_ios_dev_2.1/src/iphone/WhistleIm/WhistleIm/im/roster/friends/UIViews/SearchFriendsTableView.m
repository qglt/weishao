//
//  SearchFriendsTableView.m
//  WhistleIm
//
//  Created by 管理员 on 13-10-22.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "SearchFriendsTableView.h"
#import "LocalSearchData.h"
#import "SearchFriendsTableViewCell.h"
#import "CrowdInfo.h"

@interface SearchFriendsTableView ()
<UITableViewDataSource, UITableViewDelegate>
{
    CGRect m_frame;
    UITableView * m_tableView;
    NSMutableArray * m_arrTableData;
    UILabel * m_noneResultLabel;
}

@property (nonatomic, strong) UITableView * m_tableView;
@property (nonatomic, strong) NSMutableArray * m_arrTableData;
@property (nonatomic, strong) UILabel * m_noneResultLabel;



@end

@implementation SearchFriendsTableView

@synthesize m_tableView;
@synthesize m_arrTableData;
@synthesize m_noneResultLabel;

@synthesize m_delegate;

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        m_frame = frame;
        [self createTableView];
        [self createEmptySearchResultView];
    }
    return self;
}

- (void)createEmptySearchResultView
{
    self.m_noneResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (m_frame.size.height - 60) / 2.0f, m_frame.size.width, 60)];
    self.m_noneResultLabel.backgroundColor = [UIColor clearColor];
    self.m_noneResultLabel.numberOfLines = 0;
    self.m_noneResultLabel.hidden = YES;
    self.m_noneResultLabel.textAlignment = NSTextAlignmentCenter;
    self.m_noneResultLabel.textColor = [UIColor colorWithRed:131.0f / 255.0f green:130.0f / 255.0f blue:127.0f / 255.0f alpha:1.0f];
    
    [self addSubview:self.m_noneResultLabel];
}

- (void)createTableView
{
    self.m_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, m_frame.size.width, m_frame.size.height) style:UITableViewStylePlain];
    self.m_tableView.delegate = self;
    self.m_tableView.dataSource = self;
    self.m_tableView.rowHeight = 45.0f;
    self.m_tableView.showsVerticalScrollIndicator = NO;
    self.m_tableView.separatorColor = [UIColor clearColor];
    self.m_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.m_tableView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.m_tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.m_arrTableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId = @"cellIdentity";
    SearchFriendsTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[SearchFriendsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellBackground.png"]];
    }
    
    LocalSearchData * data = [self.m_arrTableData objectAtIndex:indexPath.row];
    [cell setCellData:data];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LocalSearchData * searchData = [self.m_arrTableData objectAtIndex:indexPath.row];
    
    
    if ([searchData.m_type isEqualToString:@"crowd_chat"]) {
        if (searchData.m_crowdInfo.status == 1) {
            [m_delegate showCrowdAlockingAlert];
        } else if (searchData.m_crowdInfo.status == 0) {
            [m_delegate didSelectFriendIndexWithID:searchData andType:searchData.m_type];
        }
    } else {
        [m_delegate didSelectFriendIndexWithID:searchData andType:searchData.m_type];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [m_delegate searchFriendsTableViewScrolled];
}

- (void)refreshTableViewWithDataArr:(NSMutableArray *)dataArr andSearchText:(NSString *)text
{
    self.m_arrTableData = dataArr;
    NSLog(@"m_arrTableData== %@, counter == %d", self.m_arrTableData, [self.m_arrTableData count]);
    if (text != nil && [text length] > 0) {
        if ([self.m_arrTableData count] > 0) {
            [self showNoneResultLabel:YES];
            NSLog(@"hidden local search none result label");
        } else {
            [self showNoneResultLabel:NO];
            NSLog(@"show local search none result label");
        }
    } else {
        [self showNoneResultLabel:YES];
    }
    
    [self.m_tableView reloadData];
}

- (void)showNoneResultLabel:(BOOL)hidden
{
    self.m_noneResultLabel.hidden = hidden;
    self.m_noneResultLabel.text = @"无查找结果";
}

@end
