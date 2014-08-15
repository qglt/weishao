//
//  NoticeTableView.m
//  WhistleIm
//
//  Created by 管理员 on 13-10-28.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "NoticeTableView.h"
#import "NoticeTableViewCell.h"
#import "ChatRecordForNotice.h"
#import "RecentAppMessageInfo.h"
#import "ImageUtil.h"
#define SEND_DATE @"date"
#define ALL_DATA  @"data"

#define NOTIFICATION_DATA @"notification_data"
#define NOTIFICATION_DATE @"notification_date"


@interface NoticeTableView ()
<UISearchBarDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate,NoticeTableViewCellDelegate>
{
    CGRect m_frame;
    UITableView * m_tableView;
    
    NSInteger m_selectedIndex;
    
    BOOL m_reloading;
    
    NSMutableDictionary * m_dictAllData;
    NSMutableArray * m_arrSeactionTitle;
    NSMutableArray * m_arrAllSectionData;
    NSMutableDictionary * m_dataDict;
    BOOL m_isNotice;
    BOOL m_isUpdate;
    UILabel * m_noneResultLabel;
    
    BOOL m_isEditState;
}

@property (nonatomic, strong) UITableView * m_tableView;


@property (nonatomic,strong)  NSMutableDictionary * m_dictAllData;
@property (nonatomic,strong) NSMutableArray * m_arrSeactionTitle;
@property (nonatomic,strong) NSMutableArray * m_arrAllSectionData;
@property (nonatomic,strong) NSMutableDictionary * m_dataDict;
@property (nonatomic,strong) UILabel * m_noneResultLabel;

@end

@implementation NoticeTableView

@synthesize m_tableView;

@synthesize m_delegate;


@synthesize m_dictAllData;
@synthesize m_arrSeactionTitle;
@synthesize m_arrAllSectionData;
@synthesize m_dataDict;
@synthesize m_noneResultLabel;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        m_frame = frame;
        [self createEmptySearchResultView];
        [self createTableView];
        
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
    self.m_tableView.rowHeight = 46.0f;
    
    self.m_tableView.showsVerticalScrollIndicator = NO;
    self.m_tableView.separatorColor = [UIColor clearColor];
    self.m_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.m_tableView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.m_tableView];
}
#pragma mark - UITableView delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.m_arrSeactionTitle count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.m_arrAllSectionData objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"cellIdentity";
    NoticeTableViewCell *cell = (NoticeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        NSMutableArray *rightUtilityButtons = [NSMutableArray new];
        
        [rightUtilityButtons addUtilityButtonWithColor:
         [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                 title:@"删除"];
        
        cell = [[NoticeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:cellIdentifier
                                      containingTableView:self.m_tableView // Used for row height and selection
                                       leftUtilityButtons:nil
                                      rightUtilityButtons:rightUtilityButtons];
        cell.delegate = self;
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellBackground.png"]];
    }
    
    NSMutableArray * eachSectionArr = [self.m_arrAllSectionData objectAtIndex:indexPath.section];
    cell.m_isNotice =m_isNotice;
    if (m_isNotice) {
        [cell setCellNoticeData:[eachSectionArr objectAtIndex:indexPath.row]];
    } else {
        [cell setCellNotificationData:[eachSectionArr objectAtIndex:indexPath.row]];
    }
    [cell changeFrame:self.m_tableView.editing];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger selectedIndex = 0;
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
   
    NSUInteger counter = 0;
    for (NSUInteger i = 0; i < section; i++) {
        NSMutableArray * eachSectionArr = [self.m_arrAllSectionData objectAtIndex:section - 1];
        counter += [eachSectionArr count];
    }
    selectedIndex = counter + row;

    if (m_isNotice) {
        [m_delegate cellDidSelectedRow:selectedIndex andIsNotice:m_isNotice];
        
        ChatRecordForNotice * notice = [[self.m_arrAllSectionData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        if (notice.isRead == NO) {
            [m_delegate noticeMarkRead:notice];
        }
    } else {
        [m_delegate NotificationCellDidSelected:indexPath];
        
        RecentAppMessageInfo * notification = [[self.m_arrAllSectionData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        if (notification.message.isRead == NO) {
            [m_delegate notificationMarkRead:notification];
        }
    }
    
}

#pragma mark - tableView批量删除
-(void)removeAll
{
    
    for (NSMutableArray *eachArr in self.m_arrAllSectionData) {
       
        __block ChatRecordForNotice * notice = nil;
        __block RecentAppMessageInfo * notification = nil;
        if (m_isNotice) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                for (notice in eachArr){
                    [m_delegate deleteNoticeInTheMemory:notice];
                }
                [eachArr removeAllObjects];
            });
        
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                for (notification in eachArr) {
                    [m_delegate deleteNotificationInTheMemory:notification];
                }
                [eachArr removeAllObjects];
            });
        }
    }
    
    [self.m_arrSeactionTitle removeAllObjects];
    [self.m_arrAllSectionData removeAllObjects];
    
    [self.m_tableView reloadData];
}
- (void)editTableView:(BOOL)canEdit
{
    self.m_tableView.editing = canEdit;
    [self.m_tableView reloadData];
    m_isEditState = canEdit;
}

- (void)clearEditState
{
    self.m_tableView.editing = NO;
    [self.m_tableView reloadData];
    m_isEditState = NO;
}

- (void)refreshNoticeTableView:(NSMutableDictionary *)dataDict isNotice:(BOOL)isNotice isUpdate:(BOOL)isUpdate
{
    m_isNotice = isNotice;
    m_isUpdate = isUpdate;
    self.m_dataDict = dataDict;
    NSUInteger unreadCounter = 0;
    if (m_isNotice == YES) {
        self.m_arrSeactionTitle = [self.m_dataDict objectForKey:SEND_DATE];
        self.m_arrAllSectionData = [self.m_dataDict objectForKey:ALL_DATA];
    } else {
        self.m_arrSeactionTitle = [self.m_dataDict objectForKey:NOTIFICATION_DATE];
        self.m_arrAllSectionData = [self.m_dataDict objectForKey:NOTIFICATION_DATA];
    }
    
    unreadCounter = [self getUnreadCounterWithDataArr:self.m_arrAllSectionData];
    if (m_isNotice == YES) {
        [m_delegate sendNoticeUnreadCounter:unreadCounter andIsUpdate:m_isUpdate];
    } else {
        [m_delegate sendNotificationUnreadCounter:unreadCounter andIsUpdate:m_isUpdate];
    }
    
    [self hiddenNoneResultLabel:self.m_arrSeactionTitle andIsEditState:m_isEditState];

    [self.m_tableView reloadData];
}

- (NSUInteger)getUnreadCounterWithDataArr:(NSMutableArray *)dataArr
{
    NSUInteger unreadCounter = 0;
    for (NSUInteger i = 0; i < [dataArr count]; i++) {
        NSMutableArray * eachSectionArr = [dataArr objectAtIndex:i];
        for (NSUInteger j = 0; j < [eachSectionArr count]; j++) {
            if (m_isNotice) {
                ChatRecordForNotice * notice = [eachSectionArr objectAtIndex:j];
                if (!notice.isRead) {
                    unreadCounter++;
                }
            } else {
                RecentAppMessageInfo * notification = [eachSectionArr objectAtIndex:j];
                if (!notification.isRead) {
                    unreadCounter++;
                }
            }
        }
    }
    
    if (m_isNotice) {
        NSLog(@"notice unread == %d", unreadCounter);
    } else {
        NSLog(@"notification unread == %d", unreadCounter);
    }
    return unreadCounter;
}

- (void)hiddenNoneResultLabel:(NSMutableArray *)dataArr andIsEditState:(BOOL)isEdit
{
    self.m_noneResultLabel.text = nil;
    NSInteger count = [dataArr count];
    if (count <= 0) {
        self.m_noneResultLabel.hidden = NO;
        if (m_isNotice) {
            self.m_noneResultLabel.text = @"暂无通知";
        } else {
            self.m_noneResultLabel.text = @"暂无应用提醒";
        }
    } else {
        self.m_noneResultLabel.hidden = YES;
    }
    
    if (m_isNotice == YES) {
        [m_delegate hiddenNoticeEditBarButton:count andIsEditState:isEdit];
    } else {
        [m_delegate hiddenNotificationEditBarButton:count andIsEditState:isEdit];
    }
}
#pragma mark - NoticeTableViewDelegate method
- (void)swippableTableViewCell:(NoticeTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    // Delete button was pressed
    NSIndexPath *cellIndexPath = [self.m_tableView indexPathForCell:cell];
    
    NSMutableArray * eachSectionArr = [self.m_arrAllSectionData objectAtIndex:cellIndexPath.section];
    
    // ChatRecordForNotice    RecentAppMessageInfo
    ChatRecordForNotice * notice = nil;
    RecentAppMessageInfo * notification = nil;
    if (m_isNotice) {
        notice = [eachSectionArr objectAtIndex:cellIndexPath.row];
        
    } else {
        notification = [eachSectionArr objectAtIndex:cellIndexPath.row];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (m_isNotice) {
            [m_delegate deleteNoticeInTheMemory:notice];
        } else {
            [m_delegate deleteNotificationInTheMemory:notification];
        }
    });
    
    [eachSectionArr removeObjectAtIndex:cellIndexPath.row];/////--------------------------------------
    [self.m_arrAllSectionData replaceObjectAtIndex:cellIndexPath.section withObject:eachSectionArr];
    if ([eachSectionArr count] <= 0) {
        [self.m_arrSeactionTitle removeObjectAtIndex:cellIndexPath.section];
        [self.m_arrAllSectionData removeObjectAtIndex:cellIndexPath.section];
    }
    
    [self.m_tableView beginUpdates];
    if ([eachSectionArr count] <= 0) {
        [self.m_tableView deleteSections:[NSIndexSet indexSetWithIndex:cellIndexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.m_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:cellIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [self.m_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:cellIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    [self.m_tableView endUpdates];
    
    
    BOOL isEdit = NO;
    if ([self.m_arrSeactionTitle count] > 0) {
        isEdit = YES;
    }
    [self hiddenNoneResultLabel:self.m_arrSeactionTitle andIsEditState:isEdit];
    
}
@end
