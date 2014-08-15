//
//  PersonalInfoView.m
//  WhistleIm
//
//  Created by 管理员 on 13-12-6.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "PersonalInfoView.h"
#import "GBPathImageView.h"
#import "GetFrame.h"
#import "FriendInfo.h"
#import "ChangeRemarkViewController.h"
#import "CircularHeaderImageView.h"
#import "PersonalTableViewCell.h"
#import "PersonalSettingData.h"
#import "GetFrame.h"
#import "ImUtils.h"
#define HEADER_HEIGHT 8.0f

@interface PersonalInfoView ()
<UITextViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    CGRect m_frame;
    GBPathImageView * m_personImageView;
    UILabel * m_nameLabel;
    UILabel * m_ageLabel;
    FriendInfo * m_myInfo;
    UILabel * m_sexLabel;
    UITableView * m_tableView;
    NSMutableArray * m_arrTableData;
    
    UILabel * m_sexAndAgeLabel;
    
    UIImageView * m_teacherImageView;
    UILabel * m_stateLabel;
}

@property (nonatomic, strong) GBPathImageView * m_personImageView;
@property (nonatomic, strong) UILabel * m_nameLabel;
@property (nonatomic, strong) UILabel * m_ageLabel;
@property (nonatomic, strong) FriendInfo * m_myInfo;
@property (nonatomic, strong) UILabel * m_sexLabel;
@property (nonatomic, strong) UITableView * m_tableView;
@property (nonatomic, strong) NSMutableArray * m_arrTableData;
@property (nonatomic, strong) UILabel * m_sexAndAgeLabel;
@property (nonatomic, strong) UIImageView * m_teacherImageView;
@property (nonatomic, strong) UILabel * m_stateLabel;

@end

@implementation PersonalInfoView

@synthesize m_personImageView;
@synthesize m_nameLabel;
@synthesize m_ageLabel;
@synthesize m_myInfo;
@synthesize m_delegate;
@synthesize m_sexLabel;
@synthesize m_tableView;
@synthesize m_arrTableData;
@synthesize m_sexAndAgeLabel;
@synthesize m_teacherImageView;
@synthesize m_stateLabel;

- (id)initWithFrame:(CGRect)frame withTableDataArr:(NSMutableArray *)tableDataArr
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        m_frame = frame;
        self.m_arrTableData = tableDataArr;
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews
{
    [self createBGViews];
    [self createPersonImageView];
    [self createLabels];
    [self createTeacherImageView];
    [self createTableView];
}

- (void)createBGViews
{
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, m_frame.size.width, 150)];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.image = [UIImage imageNamed:@"mySelfBGImage.png"];
    imageView.userInteractionEnabled = YES;
    [self addSubview:imageView];
}

- (void)createPersonImageView
{
    [self.m_personImageView removeFromSuperview];
    self.m_personImageView = nil;
    UIImage * image = [[GetFrame shareInstance] getFriendHeadImageWithFriendInfo:self.m_myInfo convertToGray:NO];
    CGFloat y = 12;
    self.m_personImageView = [[GBPathImageView alloc] initWithFrame:CGRectMake((m_frame.size.width - 65) / 2.0f, y, 64, 64) image:image pathType:GBPathImageViewTypeCircle pathColor:[UIColor whiteColor] borderColor:[UIColor whiteColor] pathWidth:2.0f];
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
    self.m_nameLabel = [self createLabelWithFrame:CGRectMake(0, y, m_frame.size.width, 18) andText:self.m_myInfo.nickName andFont:[UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f] andTextColor:[UIColor whiteColor]];
    self.m_nameLabel.backgroundColor = [UIColor clearColor];
    
    CGFloat yy = 97;
    NSString * needAge = nil;
    if ([self isNeedAge:self.m_myInfo.age]) {
        needAge = [NSString stringWithFormat:@"%@岁", self.m_myInfo.age];
    } else {
        needAge = @"";
    }
    
    NSString * sex = nil;
    if ([self.m_myInfo.sexShow isEqualToString:@"girl"]) {
        sex = @"女";
    } else {
        sex = @"男";
    }
    
    NSString * sexAndAge = [sex stringByAppendingFormat:@" %@", needAge];
    self.m_sexAndAgeLabel = [self createLabelWithFrame:CGRectMake(0, yy, m_frame.size.width, 15) andText:sexAndAge andFont:[UIFont fontWithName:@"STHeitiSC-Thin" size:11.0f] andTextColor:[UIColor whiteColor]];
    self.m_sexAndAgeLabel.backgroundColor = [UIColor clearColor];
    
    self.m_stateLabel = [self createLabelWithFrame:CGRectMake(200, 80, 50, 16) andText:@"[在线]" andFont:[UIFont fontWithName:@"STHeitiSC-Thin" size:11.0f] andTextColor:[ImUtils colorWithHexString:@"#898289"]];
    self.m_stateLabel.backgroundColor = [UIColor clearColor];
    
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
    self.m_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 150, m_frame.size.width, m_frame.size.height - 150) style:UITableViewStylePlain];
    self.m_tableView.delegate = self;
    self.m_tableView.dataSource = self;
    self.m_tableView.scrollEnabled = NO;
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
    [m_delegate cellDidSelected:indexPath];
}

- (void)refreshViews:(FriendInfo *)friendInfo andTableDataArr:(NSMutableArray *)tableData
{
    self.m_myInfo = friendInfo;
    [self createPersonImageView];
    
    self.m_nameLabel.text = friendInfo.nickName;
    
    NSString * sex = nil;
    if ([self.m_myInfo.sexShow isEqualToString:@"girl"]) {
        sex = @"女";
    } else {
        sex = @"男";
    }
    
    NSString * needAge = nil;
    if (self.m_myInfo.age) {
        needAge = [NSString stringWithFormat:@"%@岁", self.m_myInfo.age];
    } else {
        needAge = @"";
    }
    
    NSString * sexAndAge = [sex stringByAppendingFormat:@" %@", needAge];
    self.m_sexAndAgeLabel.text = sexAndAge;

    [self changeFrameWithFriendInfo:friendInfo];
    
    self.m_arrTableData = tableData;
    [self.m_tableView reloadData];
}

- (void)changeFrameWithFriendInfo:(FriendInfo *)friendInfo
{
    CGSize nameSize = [friendInfo.nickName sizeWithFont:[UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f]];
    
    NSString * onLine = nil;
    if ([friendInfo isOnline]) {
        onLine = @"[在线]";
    } else {
        onLine = @"[隐身]";
    }
    CGSize onLineStateSize = [onLine sizeWithFont:[UIFont fontWithName:@"STHeitiSC-Thin" size:11.0f]];
    
    CGFloat startX = 0;
    if ([friendInfo isTeacher]) {
        startX = (m_frame.size.width - 10.5 - 5 * 2 - nameSize.width - onLineStateSize.width) / 2;
        self.m_teacherImageView.hidden = NO;
        
        CGRect frame = self.m_teacherImageView.frame;
        frame.origin.x = startX;
        self.m_teacherImageView.frame = frame;
        
        frame = self.m_nameLabel.frame;
        frame.origin.x = startX + 10.5 + 5;
        frame.size.width = nameSize.width;
        self.m_nameLabel.frame = frame;
        
        frame = self.m_stateLabel.frame;
        frame.origin.x = startX + 10.5 + 5 + nameSize.width + 5;
        frame.size.width = onLineStateSize.width;
        self.m_stateLabel.frame = frame;
        self.m_stateLabel.text = onLine;
        
    } else {
        startX = (m_frame.size.width - 5 - nameSize.width - onLineStateSize.width) / 2;
        self.m_teacherImageView.hidden = YES;
        
        CGRect frame = self.m_nameLabel.frame;
        frame.origin.x = startX;
        frame.size.width = nameSize.width;
        self.m_nameLabel.frame = frame;
        
        frame = self.m_stateLabel.frame;
        frame.origin.x = startX + nameSize.width + 5;
        frame.size.width = onLineStateSize.width;
        self.m_stateLabel.frame = frame;
        self.m_stateLabel.text = onLine;
    }
    
    self.m_nameLabel.hidden = NO;
    self.m_stateLabel.hidden = NO;
    self.m_sexAndAgeLabel.hidden = NO;
}

@end
