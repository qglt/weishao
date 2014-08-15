//
//  VoteListTableView.m
//  WhistleIm
//
//  Created by 管理员 on 14-1-8.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "VoteListTableView.h"
#import "VoteListTableViewCell.h"
#import "ImUtils.h"

@interface VoteListTableView ()
<UITableViewDataSource, UITableViewDelegate>
{
    CGRect m_frame;
    UITableView * m_tableView;
    NSMutableArray * m_arrTableData;
    NSMutableArray * m_arrSectionTitle;
    
    NSMutableArray * m_arrCellHeight;
}

@property (nonatomic, strong) UITableView * m_tableView;
@property (nonatomic, strong) NSMutableArray * m_arrTableData;
@property (nonatomic, strong) NSMutableArray * m_arrSectionTitle;

@property (nonatomic, strong) NSMutableArray * m_arrCellHeight;

@end

@implementation VoteListTableView

@synthesize m_tableView;
@synthesize m_arrTableData;
@synthesize m_arrSectionTitle;
@synthesize m_arrCellHeight;

- (id)initWithFrame:(CGRect)frame
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

- (void)setMemory
{
    self.m_arrCellHeight = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)createTableView
{
    self.m_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, m_frame.size.width, m_frame.size.height) style:UITableViewStylePlain];
    self.m_tableView.delegate = self;
    self.m_tableView.dataSource = self;
    self.m_tableView.sectionHeaderHeight = 25.0f;
    self.m_tableView.showsVerticalScrollIndicator = NO;
    self.m_tableView.separatorColor = [UIColor clearColor];
    self.m_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.m_tableView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.m_tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.m_arrTableData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 25)];
    bgView.backgroundColor = [ImUtils colorWithHexString:@"#F0F0F0"];
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 290, 25)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [ImUtils colorWithHexString:@"#808080"];
    label.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:12.0f];
    label.text = [self.m_arrSectionTitle objectAtIndex:section];
    
    [bgView addSubview:label];
    return bgView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.m_arrCellHeight count] > indexPath.section) {
        return [[self.m_arrCellHeight objectAtIndex:indexPath.section] floatValue];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellID = @"voteList";
    VoteListTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[VoteListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellBackground.png"]];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString * votePersonName = [self.m_arrTableData objectAtIndex:indexPath.section];
    CGFloat cellHeight = [[self.m_arrCellHeight objectAtIndex:indexPath.section] floatValue];
    [cell setCellData:votePersonName andHeight:cellHeight];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

- (void)refreshVoteListTableViewWithTableData:(NSMutableArray *)tableData andTitleData:(NSMutableArray *)titleArr
{
    self.m_arrTableData = tableData;
    self.m_arrSectionTitle = titleArr;
    [self resetCellHeightWithArr:self.m_arrTableData];
    [self.m_tableView reloadData];
}

- (void)resetCellHeightWithArr:(NSMutableArray *)tableData
{
    [self.m_arrCellHeight removeAllObjects];
    for (NSUInteger i = 0; i < [tableData count]; i++) {
        NSString * votePersonName = [tableData objectAtIndex:i];
        CGSize textSize = [votePersonName sizeWithFont:[UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f] constrainedToSize:CGSizeMake(290, 10000) lineBreakMode:NSLineBreakByWordWrapping];
        
        NSLog(@"voteListTableView textSize == %@", NSStringFromCGSize(textSize));
        CGFloat height = 15 * 2 + textSize.height;
        [self.m_arrCellHeight addObject:[NSNumber numberWithFloat:height]];
    }
}

@end
