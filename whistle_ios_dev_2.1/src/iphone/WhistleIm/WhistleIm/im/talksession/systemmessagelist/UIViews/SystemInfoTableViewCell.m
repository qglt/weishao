//
//  SystemInfoTableViewCell.m
//  WhistleIm
//
//  Created by 管理员 on 13-10-31.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "SystemInfoTableViewCell.h"
#import "RosterManager.h"
#import "SystemMessageInfo.h"
#import "Whistle.h"
#import "JSONObjectHelper.h"
#import "CrowdManager.h"
#import "GetFrame.h"
#import "ImUtils.h"
#import "EventDateFormat.h"

#import "JGScrollableTableViewCellAccessoryButton.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define AGREE_TYPE @"agree"
#define REQUEST_TYPE @"request"
#define CROWD_INVITE @"crowd_invite"
#define CROWD_WEB_GROUPS_MEMBER_LIST @"crowd_web_groups_member_list"


@interface SystemInfoTableViewCell ()
{
    UIImageView * m_headerImageView;
    UIImageView * m_identityImageView;
    UIImageView * m_newNoticeImageView;
    
    UILabel * m_noticeNameLabel;
    UILabel * m_noticeContentLabel;
    UILabel * m_timeLabel;
    NSString * m_messageType;
    
    FriendInfo * m_friendInfo;
    SystemMessageInfo * m_systemMessage;
}

@property (nonatomic, strong) UIImageView * m_headerImageView;
@property (nonatomic, strong) UIImageView * m_identityImageView;
@property (nonatomic, strong) UIImageView * m_newNoticeImageView;

@property (nonatomic, strong) UILabel * m_noticeNameLabel;
@property (nonatomic, strong) UILabel * m_noticeContentLabel;
@property (nonatomic, strong) UILabel * m_timeLabel;
@property (nonatomic, strong) NSString * m_messageType;
@property (nonatomic, strong) FriendInfo * m_friendInfo;
@property (nonatomic, strong) SystemMessageInfo * m_systemMessage;

@end


@implementation SystemInfoTableViewCell

@synthesize m_headerImageView;
@synthesize m_identityImageView;
@synthesize m_newNoticeImageView;

@synthesize m_noticeNameLabel;
@synthesize m_noticeContentLabel;
@synthesize m_timeLabel;
@synthesize m_messageType;
@synthesize m_friendInfo;
@synthesize m_systemMessage;

@synthesize m_delegate;

@synthesize actionView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self createFriendHeaderImageView];
        [self createButton];
        [self createNoticeNameLabel];
        [self createNoticeContentLabel];
        [self createTimeLabel];
        [self createDeleteBtn];
        [self createSeparateLine];
        [self createNewNoticeImageView];
    }
    return self;
}
- (void)createFriendHeaderImageView
{
    self.m_headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 55, 55)];
    self.m_headerImageView.backgroundColor = [UIColor clearColor];
    self.m_headerImageView.layer.cornerRadius = 27.5f;
    self.m_headerImageView.layer.masksToBounds = YES;
//    self.m_headerImageView.userInteractionEnabled = YES;
    
    [self addContentView:self.m_headerImageView];
}

- (void)createButton
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.frame = CGRectMake(15,10, 55, 55);
    button.layer.cornerRadius = 27.5;
    button.layer.masksToBounds = YES;
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addContentView:button];
}

- (void)buttonPressed:(id)sender
{
    if ([self.m_messageType isEqualToString:AGREE_TYPE]) {
        [m_delegate pushToPersonInfo:self.m_friendInfo andSystemMsg:self.m_systemMessage isStranger:NO];
        [m_delegate markReadInSystemInfoTableViewCell:self.m_systemMessage];
    } else if ([self.m_messageType isEqualToString:REQUEST_TYPE] || [self.m_messageType isEqualToString:REJECT]){
        [m_delegate pushToPersonInfo:self.m_friendInfo andSystemMsg:self.m_systemMessage isStranger:YES];
        [m_delegate markReadInSystemInfoTableViewCell:self.m_systemMessage];
    }
}

- (void)createNoticeNameLabel
{
    self.m_noticeNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80,22, 185, 21)];
    self.m_noticeNameLabel.textAlignment = NSTextAlignmentLeft;
    self.m_noticeNameLabel.backgroundColor = [UIColor clearColor];
    self.m_noticeNameLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
    self.m_noticeNameLabel.textColor = [ImUtils colorWithHexString:@"#262626"];
    self.m_noticeNameLabel.highlightedTextColor = [UIColor whiteColor];
    [self addContentView:self.m_noticeNameLabel];
}

- (void)createNoticeContentLabel
{
    self.m_noticeContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 43, 185, 21)];
    self.m_noticeContentLabel.textAlignment = NSTextAlignmentLeft;
    self.m_noticeContentLabel.textColor = [ImUtils colorWithHexString:@"#808080"];
    self.m_noticeContentLabel.backgroundColor =[UIColor clearColor];
    self.m_noticeContentLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11.0f];
    self.m_noticeContentLabel.highlightedTextColor = [UIColor whiteColor];
    [self addContentView:self.m_noticeContentLabel];
}

- (void)createTimeLabel
{
    self.m_timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(258,22, 40, 21)];
    self.m_timeLabel.textAlignment = NSTextAlignmentLeft;
    self.m_timeLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11.0f];
    self.m_timeLabel.textColor = [ImUtils colorWithHexString:@"#808080"];
    self.m_timeLabel.backgroundColor = [UIColor clearColor];
    self.m_timeLabel.highlightedTextColor = [UIColor whiteColor];
    [self addContentView:self.m_timeLabel];
}

- (void)createNewNoticeImageView
{
    self.m_newNoticeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(297, 45,8, 8)];
    self.m_newNoticeImageView.image = [UIImage imageNamed:@"unreadRedIndicator.png"];
    [self addContentView:self.m_newNoticeImageView];
}

-(void)createDeleteBtn
{
    actionView = [JGScrollableTableViewCellAccessoryButton button];
    
    [actionView setTitle:NSLocalizedString(@"action_delete", @"") forState:UIControlStateNormal];
    [actionView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [actionView setButtonColor:[ImUtils colorWithHexString:@"#cccccc"] forState:UIControlStateNormal];
    [actionView setButtonColor:[ImUtils colorWithHexString:@"#b2b2b2"] forState:UIControlStateHighlighted];
    
    actionView.frame = CGRectMake(0, 0.0f,75,75); //width is the only frame parameter that needs to be set on the option view
    actionView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    UIView *optionView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,75.0f,75.0f)];
    
    [optionView addSubview:actionView];
    
    [self setOptionView:optionView side:JGScrollableTableViewCellSideRight];
}

- (void)createSeparateLine
{
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0,75, self.frame.size.width, 1)];
    separatorView.backgroundColor = [ImUtils colorWithHexString:@"#e1e1e1"];
    [self addSubview:separatorView];
    [self setScrollViewBackgroundColor:[UIColor whiteColor]];
}

- (void)setCellData:(SystemMessageInfo *)messageInfo
{
    /*
     msgType == agree 别人同意了你的好友添加请求
     msgType == request 同意别人的好友添加请求
     msgType == crowd_invite 邀请入群
     msgType == crowd_web_groups_member_list 加群成功
     */
    self.m_systemMessage = messageInfo;
    self.m_messageType = messageInfo.msgType;
    
    
    self.m_headerImageView.image = nil;
    self.m_noticeNameLabel.text = nil;
    self.m_noticeContentLabel.text = nil;

    if ([self.m_systemMessage isFriendSystemMsg]) {
        
        FriendInfo * friend = self.m_systemMessage.extraObject;
        
        self.m_friendInfo = friend;
        if (friend) {
            self.m_noticeNameLabel.text = friend.showName;
        } else {
            self.m_noticeNameLabel.text = @"微哨用户";
        }
        
        self.m_headerImageView.image = [[GetFrame shareInstance] getFriendHeadImageWithFriendInfo:self.m_friendInfo convertToGray:NO];
        self.m_noticeContentLabel.text = messageInfo.info;
    } else if ([self.m_systemMessage isCrowdSystemMsg]) {
        
        CrowdInfo * crowdInfo = self.m_systemMessage.extraObject;
        self.m_noticeContentLabel.text = [messageInfo getShowTxt];
        self.m_noticeNameLabel.text = messageInfo.crowd_name;
        
        // image  
        self.m_headerImageView.image = [crowdInfo getCrowdIcon];
    }

    self.m_timeLabel.text =[[EventDateFormat format] parseTime:messageInfo.lastTime];
    
    [self.m_timeLabel sizeToFit];
    
    m_timeLabel.frame = CGRectMake(self.frame.size.width-m_timeLabel.frame.size.width-15, 22, m_timeLabel.frame.size.width, m_timeLabel.frame.size.height);
    
    LOG_UI_INFO(@"system messageInfo.isRead == %d", messageInfo.isRead);
    NSLog(@"system messageInfo.isRead == %d", messageInfo.isRead);
    self.m_newNoticeImageView.hidden = YES;
    self.m_newNoticeImageView.hidden = messageInfo.isRead;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
