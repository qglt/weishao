//
//  SystemInfoTableView.m
//  WhistleIm
//
//  Created by 管理员 on 13-10-31.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "SystemInfoTableView.h"
#import "SystemInfoTableViewCell.h"

#import "SystemMessageInfo.h"
#import "JGScrollableTableViewCellAccessoryButton.h"

#define SYSTEM_SEND_DATE @"sendDate"
#define SYSTEM_MESSAGE @"systemMessage"

#define AGREE_TYPE @"agree"
#define REQUEST_TYPE @"request"

#define EACH_PAGE_NUMBERS 20

@interface SystemInfoTableView ()
<UISearchBarDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, SystemInfoTableViewCellDelegate,JGScrollableTableViewCellDelegate>
{
    CGRect m_frame;
    UITableView * m_tableView;
    NSInteger m_selectedIndex;
    NSMutableDictionary * m_dictAllData;
    NSMutableArray * m_arrSeactionTitle;
    NSMutableArray * m_arrAllSectionData;
    NSMutableDictionary * m_dataDict;
    
    BOOL m_nextPageReturned;
    
    // 已经获取的所有条数
    NSUInteger m_getAllCellsCount;
    NSUInteger m_startIndex;
}

@property (nonatomic, strong) UITableView * m_tableView;


@property (nonatomic,strong)  NSMutableDictionary * m_dictAllData;
@property (nonatomic,strong) NSMutableArray * m_arrAllSectionData;
@property (nonatomic,strong) NSMutableDictionary * m_dataDict;
@end

@implementation SystemInfoTableView

@synthesize m_tableView;
@synthesize m_dictAllData;
@synthesize m_arrAllSectionData;
@synthesize m_dataDict;
@synthesize openedIndexPath;
@synthesize m_totalCount;
@synthesize m_delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        m_frame = frame;
        self.m_arrAllSectionData = [[NSMutableArray alloc] initWithCapacity:0];
        [self createTableView];
    }
    return self;
}

- (void)createTableView
{
    self.m_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, m_frame.size.width, m_frame.size.height) style:UITableViewStylePlain];
    self.m_tableView.delegate = self;
    self.m_tableView.dataSource = self;
    self.m_tableView.rowHeight = 76.0f;
    self.m_tableView.showsVerticalScrollIndicator = NO;
    self.m_tableView.separatorColor = [UIColor clearColor];
    self.m_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.m_tableView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.m_tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.m_arrAllSectionData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId = @"cellIdentity";
    SystemInfoTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[SystemInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.m_delegate = self;
        cell.backgroundColor = [UIColor whiteColor];
        [cell.actionView addTarget:self action:@selector(deleteCellPressed:event:)forControlEvents:UIControlEventTouchUpInside];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellBackground.png"]];
    }
    
    SystemMessageInfo * messageInfo =  [self.m_arrAllSectionData objectAtIndex:indexPath.row];
  
    [cell setCellData:messageInfo];
    [cell setOptionViewVisible:[openedIndexPath isEqual:indexPath]];
    
    return cell;
}

-(void) deleteCellPressed:(UIButton *)button event:(UIEvent *)event
{
    NSSet * set = [event allTouches];
    UITouch * touch = [set anyObject];
    CGPoint point = [touch locationInView:self.m_tableView];
    NSIndexPath * indexPath = [m_tableView indexPathForRowAtPoint:point];
    
    SystemMessageInfo *messageInfo = [m_arrAllSectionData objectAtIndex:indexPath.row];
    [m_delegate deleteSystemMessage:messageInfo];
    [m_arrAllSectionData removeObjectAtIndex:indexPath.row];
    [m_tableView reloadData];
    openedIndexPath = nil;
}

// cell delegate
- (void)pushToPersonInfo:(FriendInfo *)friendInfo andSystemMsg:(SystemMessageInfo *)messageInfo isStranger:(BOOL)stranger
{
    [m_delegate pushPersonInfoToController:friendInfo andSystemMessage:messageInfo isStranger:stranger];
}

// cell delegate
- (void)markReadInSystemInfoTableViewCell:(SystemMessageInfo *)messageInfo
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [m_delegate markReadSystemMessage:messageInfo];
    });
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SystemMessageInfo * messageInfo = [self.m_arrAllSectionData objectAtIndex:indexPath.row];
    if ([messageInfo.msgType isEqualToString:REQUEST_TYPE]) {
        [m_delegate answerRequest:messageInfo];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [m_delegate markReadSystemMessage:messageInfo];
        });
        
    }else if ([messageInfo isCrowdSystemMsg]){
        LOG_GENERAL_INFO(@"群系统消息处理%@", messageInfo);
        [m_delegate pushCrowdInfoToController:nil andSystemMessage:messageInfo];
    } else if ([messageInfo.msgType isEqualToString:AGREE_TYPE]) {
        [m_delegate pushToAgreeToAddFriendViewController:messageInfo];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [m_delegate markReadSystemMessage:messageInfo];
        });
    } else if ([messageInfo.msgType isEqualToString:@"reject"]) {
        [m_delegate pushToAgreeToAddFriendViewController:messageInfo];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [m_delegate markReadSystemMessage:messageInfo];
        });
    }
}

- (void)refreshNoticeTableView:(NSMutableDictionary *)dataDict
{
    LOG_UI_INFO(@"systemInfo TableView reload");
    
    self.m_dataDict = dataDict;
    self.m_arrAllSectionData = [self.m_dataDict objectForKey:SYSTEM_MESSAGE];
    
    m_getAllCellsCount = self.m_arrAllSectionData.count;
    
    if (m_totalCount - m_getAllCellsCount > 0) {
        m_nextPageReturned = YES;
    } else {
        m_nextPageReturned = NO;
    }
    
    NSLog(@"m_totalCount == %d", m_totalCount);
    NSLog(@"m_getAllCellsCount == %d", m_getAllCellsCount);
    
    [self.m_tableView reloadData];
}

- (void)editTableView:(BOOL)canEdit
{
    self.m_tableView.editing = canEdit;
    [self.m_tableView reloadData];
}

- (void)clearEditState
{
    self.m_tableView.editing = NO;
    [self.m_tableView reloadData];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
    if (m_nextPageReturned) {

        if (m_getAllCellsCount - indexPath.row < 5) {
            m_selectedIndex++;
            m_nextPageReturned = NO;
            [m_delegate getMoreSystemItemsWithStartIndex:m_totalCount - EACH_PAGE_NUMBERS * m_selectedIndex andCount:EACH_PAGE_NUMBERS];
        }
    }
}

#pragma mark - JGScrollableTableViewCellDelegate

- (void)cellDidBeginScrolling:(JGScrollableTableViewCell *)cell {
    [JGScrollableTableViewCellManager closeAllCellsWithExceptionOf:cell stopAfterFirst:YES];
}

- (void)cellDidScroll:(JGScrollableTableViewCell *)cell {
    [JGScrollableTableViewCellManager closeAllCellsWithExceptionOf:cell stopAfterFirst:YES];
}

- (void)cellDidEndScrolling:(JGScrollableTableViewCell *)cell {
    if (cell.optionViewVisible) {
        openedIndexPath = [m_tableView indexPathForCell:cell];
    }
    else {
        openedIndexPath = nil;
    }
    
    [JGScrollableTableViewCellManager closeAllCellsWithExceptionOf:cell stopAfterFirst:YES];
}

@end
