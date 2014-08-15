//
//  SearchMembersTableView.m
//  WhistleIm
//
//  Created by 管理员 on 14-2-13.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "SearchMembersTableView.h"
#import "AddMembersTableViewCell.h"
#import "LocalSearchData.h"
@interface SearchMembersTableView ()
<UITableViewDataSource, UITableViewDelegate>
{
    CGRect m_frame;
    UITableView * m_tableView;
    NSMutableArray * m_arrTableData;
    
    // 每一个分组里面的某一项是否被选中数组
    NSMutableArray * m_arrIsSelected;
    
    NSMutableArray * m_arrSelectedJid;
}

@property (nonatomic, strong) UITableView * m_tableView;
@property (nonatomic, strong) NSMutableArray * m_arrTableData;
@property (nonatomic, strong) NSMutableArray * m_arrIsSelected;
@property (nonatomic, strong) NSMutableArray * m_arrSelectedJid;


@end

@implementation SearchMembersTableView
@synthesize m_tableView;
@synthesize m_arrTableData;

@synthesize m_arrIsSelected;
@synthesize m_delegate;

@synthesize m_arrSelectedJid;

@synthesize m_maxLimitNum;

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
    self.m_tableView.rowHeight = 50.0f;
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
    AddMembersTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[AddMembersTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellBackground.png"]];
    }
    
    LocalSearchData * data = [self.m_arrTableData objectAtIndex:indexPath.row];
    BOOL selected = [[self.m_arrIsSelected objectAtIndex:indexPath.row] boolValue];
    [cell setCellData:data andIsSelected:selected andType:@"search"];
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
    BOOL selected = [[self.m_arrIsSelected objectAtIndex:indexPath.row] boolValue];
    selected = !selected;
    [self.m_arrIsSelected replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:selected]];
   
    // 更新jid数组
    LocalSearchData * data = [self.m_arrTableData objectAtIndex:indexPath.row];
    if (selected) {
        [self.m_arrSelectedJid addObject:data.m_jid];
    } else {
        [self.m_arrSelectedJid removeObject:data.m_jid];
    }
    NSLog(@"selected jid arr for cell did selected in SearchMembersTableView == %@, and count == %d", self.m_arrSelectedJid, [self.m_arrSelectedJid count]);
    
    NSLog(@"had selected == %d", [self.m_arrSelectedJid count]);
    NSLog(@"max limit num == %d", self.m_maxLimitNum);
    if ([self.m_arrSelectedJid count] > self.m_maxLimitNum) {
        [self.m_arrSelectedJid removeLastObject];
        selected = !selected;
        [self.m_arrIsSelected replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:selected]];
        return;
    }
    
    // 刷新
    [self.m_tableView reloadData];
    
    // 实时更新好友页面的选中状态到控制器
    [m_delegate searchCellDidSelectedWithIndexPath:indexPath andSelectedJidArr:self.m_arrSelectedJid];
}

- (NSUInteger)getSubtractIndexWithJid:(NSString *)jid
{
    NSUInteger index = 0;
    for (NSUInteger i = 0; i < [self.m_arrSelectedJid count]; i++) {
        if ([jid isEqualToString:[self.m_arrSelectedJid objectAtIndex:i]]) {
            index = i;
            break;
        }
    }
    
    return index;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [m_delegate searchFriendsTableViewScrolled];
}

- (void)sendSelectedStateArr
{
    [m_delegate searchCellDidSelectedWithIndexPath:nil andSelectedJidArr:self.m_arrSelectedJid];
}

- (void)refreshTableViewWithDataArr:(NSMutableArray *)dataArr andSearchText:(NSString *)text andSelectedJidArr:(NSMutableArray *)selectedJidArr
{
    self.m_arrTableData = dataArr;
    NSLog(@"m_arrTableData== %@, counter == %d", self.m_arrTableData, [self.m_arrTableData count]);
    
    self.m_arrSelectedJid = selectedJidArr;
    NSLog(@"selected jid arr for refresh in SearchMembersTableView == %@", self.m_arrSelectedJid);
    
    self.m_arrIsSelected = [self setSelectedStateArrWithDataArr:self.m_arrTableData];
    NSLog(@"selected state arr for refresh in SearchMembersTableView == %@", self.m_arrIsSelected);

    [self.m_tableView reloadData];
}

- (NSMutableArray *)setSelectedStateArrWithDataArr:(NSMutableArray *)dataArr
{
    NSMutableArray * selectedStateArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSUInteger i = 0; i < [dataArr count]; i++) {
        [selectedStateArr addObject:[NSNumber numberWithBool:NO]];
    }
    
    for (NSUInteger i = 0; i < [dataArr count]; i++) {
        LocalSearchData * data = [self.m_arrTableData objectAtIndex:i];
        [selectedStateArr replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:[self isSelected:data.m_jid]]];
    }
    
    return selectedStateArr;
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

//- (NSMutableArray *)getSelectedArr:(NSMutableArray *)allDataArr
//{
//    NSMutableArray * totalSelectedArr = [[NSMutableArray alloc] initWithCapacity:0];
//    for (NSUInteger i = 0; i < [allDataArr count]; i++) {
//        [totalSelectedArr addObject:[NSNumber numberWithBool:NO]];
//    }
//    
//    NSLog(@"selected state arr == %@", totalSelectedArr);
//    return totalSelectedArr;
//}

@end
