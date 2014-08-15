//
//  PersonCardView.m
//  WhistleIm
//
//  Created by 管理员 on 13-12-9.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "PersonCardView.h"
#import "GBPathImageView.h"
#import "GetFrame.h"
#import "FriendInfo.h"
#import "RosterManager.h"
#import "CircularHeaderImageView.h"
#import "PersonalTableViewCell.h"
#import "PersonalSettingData.h"
#import "SeriesButton.h"

#define HEADER_HEIGHT 8.0f


#define BUTTON_TAG_START 1000
#define RECORD_BUTTON_TAG 1000
#define CHANGE_REMARK_BUTTON_TAG 1001
#define DELETE_FRIEND_BUTTON_TAG 1002


#define PHONE_BUTTON_START_TAG 2000
#define PHONE_BUTTON_TAG 2000
#define NOTE_BUTTON_TAG 2001

@interface PersonCardView ()
<UITableViewDataSource, UITableViewDelegate, SeriesButtonDelegate>
{
    CGRect m_frame;
    GBPathImageView * m_personImageView;
    UILabel * m_nameLabel;
    UITableView * m_tableView;
    NSMutableArray * m_arrTableData;
    UIButton * m_addOrTalkBtn;
    CGFloat m_btnY;
    
    SeriesButton * m_seriesButton;
    UIButton * m_indicatorButton;
    
    UILabel * m_sexAndAgeLabel;
    UIImageView * m_starBGImageView;
    
    UIImageView * m_teacherImageView;
}

@property (nonatomic, strong) GBPathImageView * m_personImageView;
@property (nonatomic, strong) UILabel * m_nameLabel;
@property (nonatomic, strong) UITableView * m_tableView;
@property (nonatomic, strong) NSMutableArray * m_arrTableData;
@property (nonatomic, strong) UIButton * m_addOrTalkBtn;
@property (nonatomic, strong) SeriesButton * m_seriesButton;
@property (nonatomic, strong) UIButton * m_indicatorButton;
@property (nonatomic, strong) UILabel * m_sexAndAgeLabel;
@property (nonatomic, strong) UIImageView * m_starBGImageView;
@property (nonatomic, strong) UIImageView * m_teacherImageView;

@end

@implementation PersonCardView

@synthesize m_personImageView;
@synthesize m_nameLabel;
@synthesize m_friendInfo;
@synthesize m_isStranger;
@synthesize m_delegate;
@synthesize m_tableView;
@synthesize m_arrTableData;
@synthesize m_addOrTalkBtn;
@synthesize m_seriesButton;
@synthesize m_indicatorButton;
@synthesize m_sexAndAgeLabel;
@synthesize m_starBGImageView;
@synthesize m_teacherImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        m_frame = frame;
    }
    return self;
}

- (void)createSubViewsWithFriendInfo:(FriendInfo *)friendInfo andTableDataArr:(NSMutableArray *)tableData
{
    self.m_friendInfo = friendInfo;
    self.m_arrTableData = tableData;
    [self createSubViews];
    [self createButton];
}

- (void)createSubViews
{
    [self createBGViews];
    [self createPersonImageView];
    [self createLabels];
    [self createTeacherImageView];
    [self changeFrameWithFriendInfo:self.m_friendInfo];
    
    [self createTableView];
    [self createIndicatorButton];
    [self createSeriesButton];
}

- (void)createIndicatorButton
{
    self.m_indicatorButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.m_indicatorButton.frame = CGRectMake((m_frame.size.width - 64) / 2.0f, 150 - 33, 64, 33);
    // indicatorToUpNormal.png     indicatorToUpHighLight.png  indicator_up.png   indicator_up_pressed.png
    [self.m_indicatorButton setBackgroundImage:[UIImage imageNamed:@"indicator_up.png"] forState:UIControlStateNormal];
    [self.m_indicatorButton setBackgroundImage:[UIImage imageNamed:@"indicator_up_pressed.png"] forState:UIControlStateSelected];
    [self.m_indicatorButton setBackgroundImage:[UIImage imageNamed:@"indicator_up_pressed.png"] forState:UIControlStateHighlighted];

    [self.m_indicatorButton addTarget:self action:@selector(indicatorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.m_indicatorButton];
}

- (void)indicatorButtonPressed:(UIButton *)button
{
    self.m_indicatorButton.hidden = YES;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25f];
    CGRect frame = self.m_seriesButton.frame;
    frame.origin.y = 117;
    self.m_seriesButton.frame = frame;
    [UIView commitAnimations];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationStop)];
    CGRect frame = self.m_seriesButton.frame;
    frame.origin.y = 150;
    self.m_seriesButton.frame = frame;
    [UIView commitAnimations];
}

- (void)animationStop
{
    self.m_indicatorButton.hidden = NO;
}

- (void)createSeriesButton
{
    BOOL hasPhone = NO;
    if ([self isPhoneWithNumber:self.m_friendInfo.cellphone] && self.m_friendInfo.cellphone && self.m_friendInfo.cellphone.length > 0 && ![self.m_friendInfo.cellphone isEqualToString:@"保密"]) {
        hasPhone = YES;
    }
    
    self.m_seriesButton = [[SeriesButton alloc] initWithFrame:CGRectMake(0, 150, m_frame.size.width, 33) wihtHasPhone:hasPhone];
    self.m_seriesButton.m_delegate = self;
    [self.m_starBGImageView addSubview:self.m_seriesButton];
}

- (BOOL)isPhoneWithNumber:(NSString *)number
{
    for (NSUInteger i = 0; i < 10; i++) {
        if ([number hasPrefix:[NSString stringWithFormat:@"%d", i]]) {
            return YES;
        }
    }
    return NO;
}

//---
- (void)callUpInSeriesButton
{
    [m_delegate callUp];
}

- (void)sendMessageInSeriesButton
{
    [m_delegate sendMessage];
}

- (void)deleteFriendInSeriesButton
{
    [m_delegate deleteFriend];
}

- (void)gotoPhonePageInSeriesButton
{
    [m_delegate showPhoneList];
}
//----

- (void)createBGViews
{
    self.m_starBGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, m_frame.size.width, 150)];
    self.m_starBGImageView.backgroundColor = [UIColor clearColor];
    self.m_starBGImageView.image = [UIImage imageNamed:@"mySelfBGImage.png"];
    self.m_starBGImageView.userInteractionEnabled = YES;
    self.m_starBGImageView.clipsToBounds = YES;
    [self addSubview:self.m_starBGImageView];
}

- (void)createPersonImageView
{
    [self.m_personImageView removeFromSuperview];
    self.m_personImageView = nil;
    UIImage * image = [[GetFrame shareInstance] getFriendHeadImageWithFriendInfo:self.m_friendInfo convertToGray:NO];
    CGFloat y = 12;
    self.m_personImageView = [[GBPathImageView alloc] initWithFrame:CGRectMake((m_frame.size.width - 64) / 2.0f, y, 64, 64) image:image pathType:GBPathImageViewTypeCircle pathColor:[UIColor whiteColor] borderColor:[UIColor whiteColor] pathWidth:2.0f];
    self.m_personImageView.clipsToBounds = YES;
    self.m_personImageView.userInteractionEnabled = YES;
    [self addSubview:self.m_personImageView];
}

- (void)createTeacherImageView
{
    self.m_teacherImageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 78 + 7.5 / 2, 10.5, 10.5)];
    self.m_teacherImageView.backgroundColor = [UIColor clearColor];
    self.m_teacherImageView.image = [UIImage imageNamed:@"card_teacher_img.png"];
    self.m_teacherImageView.userInteractionEnabled = YES;
    self.m_teacherImageView.hidden = YES;
    [self addSubview:self.m_teacherImageView];
}

- (void)createLabels
{
    CGFloat y = 78;
    self.m_nameLabel = [self createLabelWithFrame:CGRectMake(0, y, m_frame.size.width, 18) andText:self.m_friendInfo.nickName andFont:[UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f] andTextColor:[UIColor whiteColor]];
    
    CGFloat yy = 97;
    NSString * needAge = nil;
    if ([self isNeedAge:self.m_friendInfo.age]) {
        needAge = [NSString stringWithFormat:@"%@岁", self.m_friendInfo.age];
    } else {
        needAge = @"";
    }
    
    NSString * sex = nil;
    if ([self.m_friendInfo.sexShow isEqualToString:@"girl"]) {
        sex = @"女";
    } else {
        sex = @"男";
    }
    
    NSString * sexAndAge = [sex stringByAppendingFormat:@" %@", needAge];
    self.m_sexAndAgeLabel = [self createLabelWithFrame:CGRectMake(0, yy, m_frame.size.width, 15) andText:sexAndAge andFont:[UIFont fontWithName:@"STHeitiSC-Thin" size:11.0f] andTextColor:[UIColor whiteColor]];
}

- (BOOL)isNeedAge:(NSString *)age
{
    for (NSUInteger i = 0; i < 10; i++) {
        if ([age hasPrefix:[NSString stringWithFormat:@"%d", i]]) {
            return YES;
        }
    }
    return NO;
}

- (UILabel *)createLabelWithFrame:(CGRect)frame andText:(NSString *)text andFont:(UIFont *)font andTextColor:(UIColor *)color
{
    UILabel * label = [[UILabel alloc] initWithFrame:frame];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = text;
    label.font = font;
    label.textColor = color;
    label.backgroundColor = [UIColor clearColor];
    label.hidden = YES;
    [self addSubview:label];
    return label;
}

- (void)createTableView
{
    CGFloat height = [self getTableViewTotalHeight];
    
    [self.m_tableView removeFromSuperview];
    self.m_tableView = nil;
    
    self.m_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 150, m_frame.size.width, height) style:UITableViewStylePlain];
    self.m_tableView.delegate = self;
    self.m_tableView.dataSource = self;
    self.m_tableView.scrollEnabled = NO;
    self.m_tableView.showsVerticalScrollIndicator = NO;
    self.m_tableView.separatorColor = [UIColor clearColor];
    self.m_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.m_tableView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.m_tableView];
}

- (CGFloat)getTableViewTotalHeight
{
    CGFloat height = 0;
    for (NSUInteger i = 0; i < [self.m_arrTableData count]; i++) {
        NSMutableArray * eachSectionArr = [self.m_arrTableData objectAtIndex:i];
        for (NSUInteger j = 0; j < [eachSectionArr count]; j++) {
            PersonalSettingData * data = [eachSectionArr objectAtIndex:j];
            height += data.m_cellHeight;
        }
    }
    
    height += [self.m_arrTableData count] * HEADER_HEIGHT;
    
    if (height > m_frame.size.height - 150 - 45 - HEADER_HEIGHT * 2) {
        height = m_frame.size.height - 150 - 45 - HEADER_HEIGHT * 2;
    }
    
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.m_arrTableData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.m_arrTableData objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEADER_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, m_frame.size.width, HEADER_HEIGHT)];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray * eachSectionArr = [self.m_arrTableData objectAtIndex:indexPath.section];
    PersonalSettingData * data = [eachSectionArr objectAtIndex:indexPath.row];
    return data.m_cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellID = @"personal";
    PersonalTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[PersonalTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellBackground.png"]];
    }
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSMutableArray * eachSectionArr = [self.m_arrTableData objectAtIndex:indexPath.section];
    PersonalSettingData * settingData = [eachSectionArr objectAtIndex:indexPath.row];
    [cell setCellWithSettingData:settingData];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
   
    if (indexPath.section == 0 && indexPath.row == 1) {
        [m_delegate showDetailInfo];
    } else if (indexPath.section == 1) {
        [m_delegate changeRemark];
    } else if (indexPath.section == 2) {
        [m_delegate showTalkRecord];
    }
}

- (void)refreshViews:(FriendInfo *)friendInfo andTableDataArr:(NSMutableArray *)tableData
{
    self.m_arrTableData = tableData;
    self.m_friendInfo = friendInfo;
    [self createPersonImageView];
    [self createTableView];
    
    self.m_nameLabel.text = friendInfo.nickName;

    NSString * sex = nil;
    if ([self.m_friendInfo.sexShow isEqualToString:@"girl"]) {
        sex = @"女";
    } else {
        sex = @"男";
    }
    
    NSString * needAge = nil;
    if (self.m_friendInfo.age) {
        needAge = [NSString stringWithFormat:@"%@岁", self.m_friendInfo.age];
    } else {
        needAge = @"";
    }
    
    NSString * sexAndAge = [sex stringByAppendingFormat:@" %@", needAge];
    self.m_sexAndAgeLabel.text = sexAndAge;
    
    [self changeFrameWithFriendInfo:friendInfo];
    
    [self.m_tableView reloadData];
}

- (void)changeFrameWithFriendInfo:(FriendInfo *)friendInfo
{
    CGSize nameSize = [friendInfo.nickName sizeWithFont:[UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f]];

    CGFloat startX = 0;
    if ([friendInfo isTeacher]) {
        startX = (m_frame.size.width - 10.5 - 5 - nameSize.width) / 2;
        
        self.m_teacherImageView.hidden = NO;
        
        CGRect frame = self.m_teacherImageView.frame;
        frame.origin.x = startX;
        self.m_teacherImageView.frame = frame;
        
        frame = self.m_nameLabel.frame;
        frame.origin.x = startX + 10.5 + 5;
        frame.size.width = nameSize.width;
        self.m_nameLabel.frame = frame;
        
    } else {
        startX = (m_frame.size.width - nameSize.width) / 2;
        
        self.m_teacherImageView.hidden = YES;
        
        CGRect frame = self.m_nameLabel.frame;
        frame.origin.x = startX;
        frame.size.width = nameSize.width;
        self.m_nameLabel.frame = frame;
    }
    
    self.m_nameLabel.hidden = NO;
    self.m_sexAndAgeLabel.hidden = NO;
}

- (void)createButton
{
    CGFloat y = self.m_tableView.frame.size.height + self.m_tableView.frame.origin.y + 8;

    NSString * btnTitle = nil;
    if (self.m_isStranger) {
        btnTitle = @"加好友";
    } else {
        btnTitle = @"发消息";
    }
    [self.m_addOrTalkBtn removeFromSuperview];
    self.m_addOrTalkBtn = nil;
    // redBtnImageNormal.png   redBtnImageHighLight.png  blueButtonNormal.png  blueButtonPressed.png

    self.m_addOrTalkBtn = [self createButtonsWithFrame:CGRectMake(0, y, m_frame.size.width, 45) andTitle:btnTitle andImage:@"blueButtonNormal.png" andSelectedImage:@"blueButtonPressed.png" andTag:1000];
    [self addSubview:self.m_addOrTalkBtn];
}

- (UIButton *)createButtonsWithFrame:(CGRect)frame andTitle:(NSString *)title andImage:(NSString *)imagePath andSelectedImage:(NSString *)selectedImagePath andTag:(NSUInteger)tag
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:imagePath] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:selectedImagePath] forState:UIControlStateSelected];
    [button setBackgroundImage:[UIImage imageNamed:selectedImagePath] forState:UIControlStateHighlighted];
    button.frame = frame;
    button.tag = tag;
    button.backgroundColor = [UIColor redColor];
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, button.frame.size.width, button.frame.size.height)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.text = title;
    [button addSubview:label];
    
    return button;
}

- (void)buttonPressed:(UIButton *)button
{
    if (self.m_isStranger) {
        [m_delegate addFriend];
    } else {
        [m_delegate talkingWithFriend];
    }
}

@end
