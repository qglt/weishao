//
//  NoticesDetailViewController.m
//  WhistleIm
//
//  Created by 管理员 on 13-10-28.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "NoticesDetailViewController.h"
#import "GetFrame.h"
#import "ChatRecordForNotice.h"
#import "NoticeInfo.h"
#import "NoticesGlanceView.h"
#import "Whistle.h"
#import "NoticeManager.h"
#import "NBNavigationController.h"
#import "RecentAppMessageInfo.h"

#define IMPORTANT @"important"
#define NORMAL @"normal"


#define LEFT_ITEM_TAG 2000

#define GLANCE_VIEW_START_TAG 3000

@interface NoticesDetailViewController ()
<UIScrollViewDelegate>
{
    BOOL m_isIOS7;
    BOOL m_is4Inch;
    CGRect m_frame;
    UIScrollView * m_scrollView;
    
    NSUInteger m_totalNoticePages;
    NSMutableArray * m_arrAllNoticeItem;
    
    NSMutableArray * m_arrMarkRead;
    NSString * m_strTotalCounter;
    NSUInteger m_previousIndex;
}

@property (nonatomic, strong) UIScrollView * m_scrollView;
@property (nonatomic, strong) NSMutableArray * m_arrAllNoticeItem;
@property (nonatomic, strong) NSMutableArray * m_arrMarkRead;
@property (nonatomic, strong) NSString * m_strTotalCounter;

@end

@implementation NoticesDetailViewController
@synthesize isNotice;
@synthesize m_scrollView;
@synthesize m_arrNoticeData;
@synthesize m_arrAllNoticeItem;
@synthesize m_selectedIndex;
@synthesize m_arrMarkRead;
@synthesize m_strTotalCounter;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [self setBasicCondition];
    [self getTotalNoticePage];
    [self createNavigationBar:YES];
    
    [self createScrollView];
    [self createViews];
}

- (void)setBasicCondition
{
    m_frame = self.view.bounds;
    m_isIOS7 = [[GetFrame shareInstance] isIOS7Version];
    m_is4Inch = [[GetFrame shareInstance] is4InchScreen];
    [self.view setBackgroundColor:[UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1]];
}

- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    NSString * title;
    if (isNotice) {
        title = [NSString stringWithFormat:@"通知（%d/%d）",self.m_selectedIndex+1,m_totalNoticePages];
    }else{
        title = [NSString stringWithFormat:@"应用提醒（%d/%d）",self.m_selectedIndex+1,m_totalNoticePages];
    }
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:nil andLeftTitle:title andRightTitle:nil andNeedCreateSubViews:needCreate];
}

- (void)leftNavigationBarButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getTotalNoticePage
{
    m_totalNoticePages = 0;
    self.m_arrAllNoticeItem = [[NSMutableArray alloc] initWithCapacity:0];
    for ( NSMutableArray * eachDayArr in self.m_arrNoticeData) {
        m_totalNoticePages += [eachDayArr count];
        for (NSUInteger j = 0; j < [eachDayArr count]; j++) {
            [self.m_arrAllNoticeItem addObject:[eachDayArr objectAtIndex:j]];
        }
    }
    
    NSLog(@"m_totalNoticePages == ?????????????????????????????????????????????????????????????????????????%d", m_totalNoticePages);
}
- (void)createScrollView
{
    CGFloat y = 0;
    CGFloat height = m_frame.size.height;
    if (m_isIOS7) {
        y += 64;
        if (m_is4Inch) {
            height = m_frame.size.height - 64;
        } else {
            height = m_frame.size.height - 64;
        }
    } else {
        height = m_frame.size.height - 44;
    }
    
    if (m_isIOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.m_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, y, m_frame.size.width, height)];
    self.m_scrollView.backgroundColor = [UIColor clearColor];
    self.m_scrollView.delegate = self;
    [self.m_scrollView setContentSize:CGSizeMake(m_frame.size.width * m_totalNoticePages, height)];
    
    NSLog(@"m_selectedIndex in NoticesDetailViewController == %d", self.m_selectedIndex);
    self.m_scrollView.contentOffset = CGPointMake(0 + self.m_selectedIndex * m_frame.size.width, 0);
    self.m_scrollView.pagingEnabled = YES;
    [self.view addSubview:self.m_scrollView];
}

- (void)createViews
{
    NSInteger startIndex = -1;
    NSInteger endIndex = -1;
    
    m_previousIndex = m_selectedIndex;
    NSLog(@"m_selectedIndex ==== %d", m_selectedIndex);

    if (m_totalNoticePages >= 3) {
        if (m_selectedIndex == 0) {
            startIndex = m_selectedIndex;
            endIndex = m_selectedIndex + 3;
        } else if (m_selectedIndex == m_totalNoticePages - 1) {
            startIndex = m_selectedIndex - 2;
            endIndex = m_selectedIndex + 1;
        } else if (0 < m_selectedIndex && m_selectedIndex < m_totalNoticePages - 1) {
            startIndex = m_selectedIndex - 1;
            endIndex = m_selectedIndex + 2;
        }
    } else if (m_totalNoticePages == 2) {
        if (m_selectedIndex == 0) {
            startIndex = m_selectedIndex;
            endIndex = m_selectedIndex + 2;
        } else if (m_selectedIndex == m_totalNoticePages - 1) {
            startIndex = m_selectedIndex - 1;
            endIndex = m_selectedIndex + 1;
        }
    } else if (m_totalNoticePages == 1) {
        startIndex = m_selectedIndex;
        endIndex = m_selectedIndex + 1;
    }
  
    if (startIndex >= 0 && endIndex >= 0) {
        [self createSubViewWithStartIndex:startIndex andEndIndex:endIndex];
    }
}

- (void)createSubViewWithStartIndex:(NSUInteger)startIndex andEndIndex:(NSUInteger)endIndex
{
    NSLog(@"startIndex ==== %d", startIndex);
    NSLog(@"endIndex ==== %d", endIndex);

    [self.m_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat width = self.m_scrollView.frame.size.width;
    for (NSUInteger i = startIndex; i < endIndex; i++) {
        if (isNotice) {
            ChatRecordForNotice * notice = [self.m_arrAllNoticeItem objectAtIndex:i];
            NoticesGlanceView * noticeView = [[NoticesGlanceView alloc] initWithFrame:CGRectMake(0 + width * i, 0, width, self.m_scrollView.frame.size.height) andData:notice];
            noticeView.tag = GLANCE_VIEW_START_TAG + i;
            noticeView.backgroundColor = [UIColor clearColor];
            [self.m_scrollView addSubview:noticeView];
        }else{
            RecentAppMessageInfo * notification = [self.m_arrAllNoticeItem objectAtIndex:i];
            NoticesGlanceView *notificationView = [[NoticesGlanceView alloc] initWithFrame:CGRectMake(0 + width * i, 0, width, self.m_scrollView.frame.size.height) andNotificationData:notification];
            notificationView.tag = GLANCE_VIEW_START_TAG + i;
            notificationView.backgroundColor = [UIColor clearColor];
            [self.m_scrollView addSubview:notificationView];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = (NSInteger)scrollView.contentOffset.x / (NSInteger)m_frame.size.width;
    NSString * title;
    if (isNotice) {
        title = [NSString stringWithFormat:@"通知（%d/%d）",index + 1,m_totalNoticePages];
    }else{
        title = [NSString stringWithFormat:@"应用提醒（%d/%d）",index + 1,m_totalNoticePages];
    }
    
    for (id p in self.navigationItem.titleView.subviews)
        if ([p isKindOfClass:[UILabel class]]) {
            ((UILabel *)p).text = title;
        }///                                          ------------------------
    
    LOG_UI_INFO(@"scrollView mark read index == %d", index);
    
    if (isNotice) {
        BOOL hadRead = [[self.m_arrMarkRead objectAtIndex:index] boolValue];
        if (!hadRead) {
            [self.m_arrMarkRead replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:YES]];
            
            ChatRecordForNotice * notice = [self getMarkReadNoticeWithIndex:index];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self markReadNotice:notice];
            });
        }
        LOG_UI_INFO(@"m_arrMarkRead %@", self.m_arrMarkRead);
        
        //--------
        m_selectedIndex = index;
        LOG_UI_INFO(@"m_selectedIndex ==== %d", m_selectedIndex);
        
        if (m_selectedIndex != m_previousIndex) {
            [self createViews];
        }
    }
    
}

- (ChatRecordForNotice *)getMarkReadNoticeWithIndex:(NSUInteger)index
{
    NoticesGlanceView * glanceView = (NoticesGlanceView *)[self.m_scrollView viewWithTag:index + GLANCE_VIEW_START_TAG];
    return glanceView.m_notice;
}

- (void)markReadNotice:(ChatRecordForNotice *)notice
{
    LOG_UI_INFO(@"markReadNotice");
    [[NoticeManager shareInstance] markRead:notice withCallback:^(BOOL remarked) {
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
