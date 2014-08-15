//
//  NoticesGlanceView.m
//  WhistleIm
//
//  Created by 管理员 on 13-10-29.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "NoticesGlanceView.h"
#import "ChatRecordForNotice.h"
#import "RecentAppMessageInfo.h"
#import "NoticeInfo.h"
#import "ImUtils.h"

#define IMPORTANT @"important"
#define NORMAL @"normal"

#define TITLE_TAG 1
#define TIME_TAG  2
#define TEXT_TAG  3


@interface NoticesGlanceView ()
<UITextViewDelegate>
{
    CGRect m_frame;
}
@end

@implementation NoticesGlanceView
@synthesize m_notification;
@synthesize m_notice;

- (id)initWithFrame:(CGRect)frame andData:(ChatRecordForNotice *)notice
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        m_frame = frame;
        self.m_notice = notice;
        [self createNoticeTitleLabel:notice];
        [self createImportantStateImageView:notice];
        [self createTimeLabel:notice];
        [self createTextView:notice];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame andNotificationData:(RecentAppMessageInfo *)notification
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        m_frame = frame;
        self.m_notification = notification;
        [self createNotificationTitleLabel:notification];
        [self createNotificationTextView:notification];
    }
    return self;
}

- (void)createNoticeTitleLabel:(ChatRecordForNotice *)notice
{
    CGSize size = [notice.noticeInfo.title sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:CGSizeMake(m_frame.size.width - 90, m_frame.size.height/4.0) lineBreakMode:NSLineBreakByWordWrapping];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    label.center = CGPointMake(self.frame.size.width / 2.0f, 15 + label.center.y);
    label.backgroundColor = [UIColor clearColor];
    label.text = notice.noticeInfo.title;
    label.font = [UIFont systemFontOfSize:15.0];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.tag = TITLE_TAG;
    label.textColor = [UIColor colorWithRed:38/255.0 green:38/255.0 blue:38/255.0 alpha:1];
    [self addSubview:label];
}

- (void)createImportantStateImageView:(ChatRecordForNotice *)notice
{
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 34, 0, 34, 18)];
    imageView.backgroundColor = [UIColor clearColor];
    
    // importanticon.png   normalicon.png
    if ([notice.priority isEqualToString:IMPORTANT]) {
        imageView.image = [UIImage imageNamed:@"importanticon"];
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(12, 4, 22, 11)];
        label.font = [UIFont systemFontOfSize:11.0f];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.text = @"重要";
        [imageView addSubview:label];
        [self addSubview:imageView];
    }
}

- (void)createTimeLabel:(ChatRecordForNotice *)notice
{
    UILabel * titleLabel = (UILabel *)[self viewWithTag:TITLE_TAG];
    CGFloat height = titleLabel.frame.origin.y + titleLabel.frame.size.height + 5;
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, height, m_frame.size.width, 11)];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:11.0f];
    label.textColor = [UIColor colorWithRed:38/255.0 green:38/255.0 blue:38/255.0 alpha:1];
    label.backgroundColor = [UIColor clearColor];
    
    NSString * timeStr = [notice.noticeInfo.publishTime substringWithRange:NSMakeRange(11, 5)];
    NSString * dateStr = [notice.noticeInfo.publishTime substringWithRange:NSMakeRange(5, 5)];
    NSString * signatureStr = notice.noticeInfo.signature;
    NSString * text = [dateStr stringByAppendingString:@" "];
    if (timeStr != nil) {
        text = [text stringByAppendingString:timeStr];
    }
    text = [text stringByAppendingString:@" "];
    
    if (signatureStr != nil) {
        text = [text stringByAppendingString:signatureStr];
    }
    label.text = text;
    label.tag = TIME_TAG;
    [self addSubview:label];
}

- (void)createTextView:(ChatRecordForNotice *)notice
{
    UILabel * titleLabel = (UILabel *)[self viewWithTag:TIME_TAG];
    CGFloat height = titleLabel.frame.origin.y + titleLabel.frame.size.height + 5;
    
    NSString * String = [ImUtils flattenHTML:notice.noticeInfo.body trimWhiteSpace:YES];
    
    UITextView * textView = [[UITextView alloc] initWithFrame:CGRectMake(15, height, m_frame.size.width - 30, m_frame.size.height - height - 20)];
    textView.backgroundColor = [UIColor clearColor];
    textView.editable = NO;
    textView.delegate = self;
    textView.font = [UIFont systemFontOfSize:15.0f];
    NSString * blankStr = @"    ";
    textView.textColor = [UIColor colorWithRed:38/255.0 green:38/255.0 blue:38/255.0 alpha:1];
    textView.text = [blankStr stringByAppendingString:[String stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "]];

    [self addSubview:textView];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return NO;
}

#pragma mark - notification methods

- (void)createNotificationTitleLabel:(RecentAppMessageInfo *)notification
{
    CGSize size = [notification.serviceInfo.name sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:CGSizeMake(m_frame.size.width - 90, m_frame.size.height/4.0) lineBreakMode:NSLineBreakByWordWrapping];

    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    label.center = CGPointMake(self.frame.size.width / 2.0f, 15 + label.center.y);
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:15.0f];
    
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.text = notification.serviceInfo.name;
    label.textAlignment = NSTextAlignmentCenter;
    label.tag = TITLE_TAG;
    label.textColor = [UIColor colorWithRed:38/255.0 green:38/255.0 blue:38/255.0 alpha:1];
    [self addSubview:label];
}

- (void)createNotificationTextView:(RecentAppMessageInfo *)notification
{
    NSString * titleString = [ImUtils flattenHTML:notification.message.body trimWhiteSpace:YES];
    UILabel * label = (UILabel *)[self viewWithTag:TITLE_TAG];
    CGFloat height = label.frame.origin.y + label.frame.size.height + 5;
    
    UITextView * textView = [[UITextView alloc] initWithFrame:CGRectMake(15, height, m_frame.size.width - 30, m_frame.size.height - height - 20)];
    textView.backgroundColor = [UIColor clearColor];
    textView.editable = NO;
    textView.delegate = self;
    textView.font = [UIFont systemFontOfSize:15.0f];
    NSString * blankStr = @"    ";
    if (titleString) {
        textView.text =[blankStr stringByAppendingString:[titleString stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "]];
    }
    textView.textColor = [UIColor colorWithRed:38/255.0 green:38/255.0 blue:38/255.0 alpha:1];
    
    [self addSubview:textView];
}
@end
