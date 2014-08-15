//
//  Rectent m
//  WhistleIm


//
//  Created by wangchao on 13-8-15.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "RecentItemCell.h"
#import "Constants.h"
#import "CrowdInfo.h"
#import "FriendInfo.h"
#import "ChatGroupInfo.h"
#import "ImUtils.h"
#import "GetFrame.h"
#import "ImUtils.h"
#import "RecentRecord.h"
#import "SystemMessageInfo.h"
#import "LightAppInfo.h"
#import "LightAppMessageInfo.h"
#import "EventDateFormat.h"
#import "JGScrollableTableViewCellAccessoryButton.h"
#import <SDWebImage/UIImageView+WebCache.h>


@implementation RecentItemCell

@synthesize timeLabel;
@synthesize headView;
@synthesize unreadBg;
@synthesize nameLabel;
@synthesize contentLabel;
@synthesize unreadLabel;
@synthesize stateImg;
@synthesize identityImg;
@synthesize headBtn;
@synthesize unreadBtn;
@synthesize crowdHotImg;
@synthesize crowdOfficialImg;
@synthesize actionView;
@synthesize stateLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        [self createView];
    }
    return self;
}

- (void)createView
{
    
    //头像
    headView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 55, 55)];
    headView.layer.cornerRadius = 27.5f;
    headView.layer.masksToBounds = YES;
    
    headBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    headBtn.backgroundColor = [UIColor clearColor];
    headView.userInteractionEnabled = YES;
    headBtn.frame = CGRectMake(0, 0,headView.frame.size.width,headView.frame.size.height);
    
    [headView addSubview:headBtn];
    
    stateImg = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-15-15,39,15,15)];
    [stateImg setHidden:YES];
    
    stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(80,43,30,21)];
    stateLabel.textAlignment = NSTextAlignmentLeft;
    stateLabel.backgroundColor = [UIColor clearColor];
    stateLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:11.0f];
    [self clearShandow:stateLabel];
    [stateImg setHidden:YES];
    
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80,22, 100, 21)];
    nameLabel.textAlignment = NSTextAlignmentLeft;
  
    nameLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
    nameLabel.backgroundColor = [UIColor clearColor];
    [self clearShandow:nameLabel];
    
    identityImg = [[UIImageView alloc] initWithFrame:CGRectMake(80,25,15,15)];
    identityImg.image = [UIImage imageNamed:@"identity_teacher_new.png"];
    [identityImg setHidden:YES];
    
    crowdOfficialImg = [[UIImageView alloc] initWithFrame:CGRectMake(80,25,15,15)];
    crowdOfficialImg.image = [UIImage imageNamed:@"crowd_official.png"];
    [crowdOfficialImg setHidden:YES];
    
    crowdHotImg = [[UIImageView alloc] initWithFrame:CGRectMake(80,25,15,15)];
    crowdHotImg.image = [UIImage imageNamed:@"crowd_hot.png"];
    [crowdHotImg setHidden:YES];
    
    
    contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(80,43, 195, 21)];
    contentLabel.textAlignment = NSTextAlignmentLeft;
    contentLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11.0f];
    [self clearShandow:contentLabel];
    
    contentLabel.backgroundColor = [UIColor clearColor];
    
    unreadLabel = [[UILabel alloc] initWithFrame:CGRectMake(53,8, 19, 19)];
    unreadLabel.textAlignment = NSTextAlignmentCenter;
    unreadLabel.font = [UIFont systemFontOfSize:11.0f];
    unreadLabel.textColor = [UIColor whiteColor];
    unreadLabel.shadowColor = [UIColor clearColor];
    unreadLabel.shadowOffset = CGSizeMake(0,0);
    unreadLabel.backgroundColor = [UIColor clearColor];
    unreadLabel.text = @"99+";
    [unreadLabel sizeToFit];
    
    unreadBg =  [[UIImageView alloc] initWithFrame:CGRectMake(53, 8, unreadLabel.frame.size.width+11, unreadLabel.frame.size.height+4)];
    unreadBg.image = [ImUtils getFullBackgroundImageView:@"chat_cell_unread.png" WithCapInsets:UIEdgeInsetsMake(9,9,9,9) hLeftCapWidth:9 topCapHeight:9];
    unreadBg.center = unreadLabel.center;
    [unreadBg setHidden:YES];
    
    [unreadLabel setHidden:YES];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(258,22, 40, 21)];//278
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    self.timeLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11.0f];
    self.timeLabel.backgroundColor = [UIColor clearColor];

    
    nameLabel.textColor = [ImUtils colorWithHexString:@"#262626"];
    contentLabel.textColor = [ImUtils colorWithHexString:@"#808080"];//[UIColor colorWithRed:80.0f/ 255.0f green:80.0f/ 255.0f blue:80.0f/ 255.0f alpha:1.0f];
    stateLabel.textColor = [ImUtils colorWithHexString:@"#808080"];
    self.timeLabel.textColor = [ImUtils colorWithHexString:@"#808080"];;
    
    nameLabel.highlightedTextColor = [UIColor whiteColor];
    contentLabel.highlightedTextColor = [UIColor whiteColor];
    self.timeLabel.highlightedTextColor = [UIColor whiteColor];
    stateLabel.highlightedTextColor = [UIColor whiteColor];
    
    
    self.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleGray;

    [self addContentView:self.headView];
    [self addContentView:self.stateImg];
    [self addContentView:self.stateLabel];
    [self addContentView:self.identityImg];
    [self addContentView:self.nameLabel];
    [self addContentView:self.contentLabel];
    [self addContentView:self.unreadBg];
    [self addContentView:self.unreadLabel];
    [self addContentView:self.timeLabel];
    [self addContentView:self.crowdOfficialImg];
    [self addContentView:self.crowdHotImg];
    
    
    [self setScrollViewBackgroundColor:[UIColor whiteColor]];
//    [self setScrollViewBackgroundColor:[UIColor colorWithWhite:0.975f alpha:1.0f]];
//    self.contentView.backgroundColor = [UIColor grayColor];
//    
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

    
    
    //setSeparatorColor
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0,74, self.frame.size.width, 1)];
    separatorView.backgroundColor = [ImUtils colorWithHexString:@"#e1e1e1"];
    [self addSubview:separatorView];
}

-(void) clearShandow:(UILabel *)label
{
    [label setShadowColor:[UIColor clearColor]];
    [label setShadowOffset:CGSizeMake(0, 0)];
}

-(void)setupCell:(RecentRecord *)record
{
    [crowdOfficialImg setHidden:YES];
    
    [crowdHotImg setHidden:YES];
    
    [stateImg setHidden:YES];
    [stateLabel setHidden:YES];
    [identityImg setHidden:YES];
    contentLabel.frame = CGRectMake(80,43, 195, 21);
    
    if([record getType]==RecentRecord_System)
    {
        [self setupSystemCell:record];
    }else if([record getType]==RecentRecord_Discussion)
    {
        [self setupGroupCell:record];
    }else if([record getType]==RecentRecord_Crowd)
    {
        [self setupCrowCell:record];
    }else if([record getType]==RecentRecord_LightApp)
    {
        [self setupLightAppCell:record];
    }else{
        [self setupConvCell:record];
    }
    
    timeLabel.text = [[EventDateFormat format] parseTime:record.time];
    
    [timeLabel sizeToFit];
    
    timeLabel.frame = CGRectMake(self.frame.size.width-timeLabel.frame.size.width-15, 22, timeLabel.frame.size.width, timeLabel.frame.size.height);
    
    NSString *unread = record.unreadAccount>99?@"99+":[NSString stringWithFormat:@"%i",record.unreadAccount];
    
    unreadLabel.text = unread;
    [unreadLabel sizeToFit];
    
    unreadBg.frame = CGRectMake(0, 0,  unreadLabel.frame.size.width+11, unreadLabel.frame.size.height+4);
    unreadBg.center = unreadLabel.center;

    if ( record.unreadAccount>0) {
        unreadLabel.hidden = NO;
        unreadBg.hidden = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changbadgevalue" object:@""];
    }else
    {
        unreadLabel.hidden = YES;
        unreadBg.hidden = YES;
    }
}

-(void) setupLightAppCell:(RecentRecord *)record
{
    LightAppMessageInfo *info = record.extraInfo;
    LightAppInfo *li = info.lightappDetail;
    li?[headView setImageWithURL:[NSURL fileURLWithPath:li.appIcon_middle] placeholderImage:[UIImage imageNamed:@"app_default.png"]]:[headView setImage:[UIImage imageNamed:@"app_default.png"]];
    nameLabel.text = ((LightAppInfo *)info.lightappDetail).appName;
    nameLabel.frame = CGRectMake(80,  nameLabel.frame.origin.y,  nameLabel.frame.size.width,  nameLabel.frame.size.height);
    contentLabel.text = info.content;
}

-(void) setupSystemCell:(RecentRecord *)record
{
    SystemMessageInfo *info = record.extraInfo;
    headView.image = [UIImage imageNamed:@"head_sys_msg.png"];
    nameLabel.text = @"系统消息";
    nameLabel.frame = CGRectMake(80,  nameLabel.frame.origin.y,  nameLabel.frame.size.width,  nameLabel.frame.size.height);
    contentLabel.text = [info getShowTxt];
}

-(void) setupConvCell:(RecentRecord *)record
{
    FriendInfo *info = record.extraInfo;
    
    [ImUtils drawRosterHeadPic:info withView: headView withOnline:YES] ;
    
    nameLabel.text = record.speaker;// info.showName;
    
    [self setStateViewWithFriendInfo:info];
    
    if([info.identity isEqualToString:@"biz.vcard.teacher"] || [info.identity_show isEqualToString:@"teacher"])
    {
        [ identityImg setHidden:NO];
        nameLabel.frame = CGRectMake( identityImg.frame.origin.x+ identityImg.frame.size.width+2,  nameLabel.frame.origin.y,  nameLabel.frame.size.width,  nameLabel.frame.size.height);
    }else
    {
         nameLabel.frame = CGRectMake( 80,22,  nameLabel.frame.size.width,  nameLabel.frame.size.height);
    }
    NSString *lastContent = [ImUtils fetchLastMember:record.msgContent];
    
    contentLabel.text = lastContent;
}

-(void) setupGroupCell:(RecentRecord *)record
{
    ChatGroupInfo *info = record.extraInfo;
    headView.image = [UIImage imageNamed:@"discussion_group_default"];
    nameLabel.text = [info groupName];
    nameLabel.frame = CGRectMake(80,  nameLabel.frame.origin.y,  nameLabel.frame.size.width,  nameLabel.frame.size.height);
    
    NSString *lastContent = [ImUtils fetchLastMember:record.msgContent];
    if(lastContent !=nil && lastContent.length>0)
    {
        lastContent = [NSString stringWithFormat:@"%@:%@",record.speaker,lastContent];
    }else{
        lastContent = @"";
    }
    
    contentLabel.text = lastContent;
}

-(void) setupCrowCell:(RecentRecord *)record
{
    CrowdInfo *info = record.extraInfo;
    
    nameLabel.text = info.name;
    
    UIImage *tempimg =nil;
    
    
    
    if(info.icon !=nil && info.icon.length>0 && [[NSFileManager defaultManager] fileExistsAtPath:info.icon])
    {
        tempimg =  [UIImage imageWithContentsOfFile:info.icon];
        
    }else{
        tempimg = info.getCrowdIcon;
    }
    
    headView.image = info.isNormal?tempimg:[[GetFrame shareInstance] convertImageToGrayScale:tempimg];
    if (info.official) {
        [crowdOfficialImg setHidden:NO];
    }
    
    if ([info.active isEqualToString:@"true"]) {
        [crowdHotImg setHidden:NO];
    }
    
    crowdHotImg.center = CGPointMake(crowdOfficialImg.center.x+((crowdOfficialImg.isHidden)?0:16), crowdOfficialImg.center.y);
    
    CGFloat x = 80;
    
    if (!crowdHotImg.isHidden) {
        x= crowdHotImg.frame.origin.x+17;
    }else if (!crowdOfficialImg.isHidden)
    {
        x+=17;
    }
    
    nameLabel.frame = CGRectMake(x,  nameLabel.frame.origin.y,  nameLabel.frame.size.width,  nameLabel.frame.size.height);
    
    NSString *lastContent = [ImUtils fetchLastMember:record.msgContent];
    if(lastContent !=nil && lastContent.length>0)
    {
        lastContent = [NSString stringWithFormat:@"%@:%@",record.speaker,lastContent];
    }else{
        lastContent = @"";
    }
    
    if (info.alert ==2) {
        [stateImg setHidden:NO];
        stateImg.image = [UIImage imageNamed:@"crowdShieldImg.png"];
    }
    
    contentLabel.text = lastContent;
}


-(void) setStateViewWithFriendInfo:(FriendInfo *)info
{
    if([info.presence isEqualToString:@"Away"])
    {
        [stateLabel setHidden:NO];
        stateLabel.text = [NSString stringWithFormat:@"[%@]",NSLocalizedString(@"away", @"")];
//        [stateLabel sizeToFit];
        contentLabel.frame= CGRectMake(stateLabel.frame.size.width+stateLabel.frame.origin.x,contentLabel.frame.origin.y, contentLabel.frame.size.width, contentLabel.frame.size.height);
    }else if([info.presence isEqualToString:@"Busy"])
    {
        [stateLabel setHidden:NO];
        stateLabel.text = [NSString stringWithFormat:@"[%@]",NSLocalizedString(@"busy", @"")];
//        [stateLabel sizeToFit];
        contentLabel.frame= CGRectMake(stateLabel.frame.size.width+stateLabel.frame.origin.x,contentLabel.frame.origin.y, contentLabel.frame.size.width, contentLabel.frame.size.height);
    }else if([info.presence isEqualToString:@"Android"])
    {
        [stateImg setHidden:NO];
        stateImg.image = [UIImage imageNamed:@"identity_android.png"];
    }else if([info.presence isEqualToString:@"IOS"])
    {
        [stateImg setHidden:NO];
        stateImg.image = [UIImage imageNamed:@"identity_ios.png"];
    }
}

-(void)dealloc
{
   headView = nil;
    
   unreadBg = nil;
    
   nameLabel = nil;
    
   contentLabel = nil;
    
   timeLabel = nil;
    
   unreadLabel = nil;
    
   stateImg = nil;
    
   identityImg = nil;
    
   actionView = nil;
}
@end
