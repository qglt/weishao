//
//  FriendsDetailInfoViewController.m
//  WhistleIm
//
//  Created by 管理员 on 13-9-29.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "FriendsDetailInfoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "FriendInfo.h"
#import "GetFrame.h"
#import "NBNavigationController.h"
#import "PersonalSettingData.h"
#import "PersonalTableViewCell.h"
#import "ImUtils.h"

#define FRIEND @"friend"
#define MYSELF @"myself"

@interface FriendsDetailInfoViewController ()
<UITableViewDataSource, UITableViewDelegate>
{
    CGRect m_frame;
    UITableView * m_tableView;
    NSMutableArray * m_arrItems;
    NSMutableArray * m_arrTableData;
    BOOL m_isIOS7;
    BOOL m_is4Inch;
}

@property (nonatomic, strong) UITableView * m_tableView;
@property (nonatomic, strong) NSMutableArray * m_arrItems;
@property (nonatomic, strong) NSMutableArray * m_arrTableData;

@end

@implementation FriendsDetailInfoViewController

@synthesize m_tableView;
@synthesize m_arrTableData;
@synthesize m_arrItems;
@synthesize m_friendInfo;
@synthesize m_type;

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
    [self setbasicCondition];
    [self createNavigationBar:YES];

    [self addItemsToDataArr];
    [self createDetailInfo];

    [self createTableView];
}

- (void)setbasicCondition
{
    self.view.backgroundColor = [ImUtils colorWithHexString:@"#F0F0F0"];
    m_frame = [[UIScreen mainScreen] bounds];
    m_isIOS7 = [[GetFrame shareInstance] isIOS7Version];
    m_is4Inch = [[GetFrame shareInstance] is4InchScreen];
    
    if (isIOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:nil andLeftTitle:@"详细资料" andRightTitle:nil andNeedCreateSubViews:needCreate];
}

- (void)leftNavigationBarButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createTableView
{
    CGFloat y = 0.0f;
    if (isIOS7) {
        y += 64.0f;
    }
    self.m_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, y, m_frame.size.width, m_frame.size.height - 64) style:UITableViewStylePlain];
    self.m_tableView.delegate = self;
    self.m_tableView.dataSource = self;
    self.m_tableView.showsVerticalScrollIndicator = NO;
    self.m_tableView.rowHeight = 45.0f;
    self.m_tableView.separatorColor = [UIColor clearColor];
    self.m_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.m_tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.m_tableView];
}

- (void)addItemsToDataArr
{
    self.m_arrTableData = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSMutableArray * titleArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    [titleArr addObject:@"等级"];
    if ([self.m_type isEqualToString:MYSELF]) {
        [titleArr addObject:@"经验值"];
    }
    
    [titleArr addObject:@"姓名"];
    [titleArr addObject:@"微哨号"];
    [titleArr addObject:@"学号"];
    [titleArr addObject:@"手机"];
    [titleArr addObject:@"电话"];

    [titleArr addObject:@"组织"];
    [titleArr addObject:@"职务"];
    [titleArr addObject:@"生日"];
    [titleArr addObject:@"星座"];
    [titleArr addObject:@"生肖"];

    [titleArr addObject:@"血型"];
    [titleArr addObject:@"爱好"];
    [titleArr addObject:@"邮箱"];
    [titleArr addObject:@"微博"];
    [titleArr addObject:@"主页"];

    [titleArr addObject:@"住址"];
    [titleArr addObject:@"邮编"];
    [titleArr addObject:@"个人说明"];
    
    for (NSUInteger i = 0; i < [titleArr count]; i++) {
        PersonalSettingData * settingData = [[PersonalSettingData alloc] init];
        settingData.m_title = [titleArr objectAtIndex:i];
        settingData.m_cellHeight = 45;
        settingData.m_hasLabel = YES;
        [self.m_arrTableData addObject:settingData];
    }
}

- (void)createDetailInfo
{
    NSLog(@"\n\n\n");

    NSUInteger startIndex = 0;
    
    // 等级
    NSLog(@"FriendsDetailInfoViewController level == %d", self.m_friendInfo.level);
    [self replaceObjectWithIndex:startIndex++ andContent:[NSString stringWithFormat:@"%d", self.m_friendInfo.level]];
    
    // 经验值
    NSLog(@"FriendsDetailInfoViewController exp == %d", self.m_friendInfo.exp);
    NSLog(@"FriendsDetailInfoViewController next_exp == %d", self.m_friendInfo.next_exp);

    if ([self.m_type isEqualToString:MYSELF]) {
        NSString * empiricalValue = [NSString stringWithFormat:@"%d/%d  下次升级需要经验值%d", self.m_friendInfo.exp, self.m_friendInfo.next_exp, self.m_friendInfo.next_exp - self.m_friendInfo.exp];
        [self replaceObjectWithIndex:startIndex++ andContent:empiricalValue];
    } 
    
    // 姓名
    NSLog(@"FriendsDetailInfoViewController showName == %@", self.m_friendInfo.name);
    if (self.m_friendInfo.showName != nil && [self.m_friendInfo.showName length] > 0) {
        [self replaceObjectWithIndex:startIndex++ andContent:self.m_friendInfo.name];
    } else {
        [self replaceObjectWithIndex:startIndex++ andContent:@""];
    }
    
    // 微哨号
    NSLog(@"FriendsDetailInfoViewController username == %@", self.m_friendInfo.username);
    if (self.m_friendInfo.username != nil && [self.m_friendInfo.username length] > 0) {
        [self replaceObjectWithIndex:startIndex++ andContent:self.m_friendInfo.aid];
    } else {
        [self replaceObjectWithIndex:startIndex++ andContent:@""];
    }
    
    // 学号
    NSLog(@"FriendsDetailInfoViewController student_number == %@", self.m_friendInfo.student_number);
    if (self.m_friendInfo.student_number != nil && [self.m_friendInfo.student_number length] > 0) {
        [self replaceObjectWithIndex:startIndex++ andContent:self.m_friendInfo.student_number];
    } else {
        [self replaceObjectWithIndex:startIndex++ andContent:@""];
    }
    
    // 移动电话
    NSLog(@"FriendsDetailInfoViewController cellphone == %@", self.m_friendInfo.cellphone);
    if (self.m_friendInfo.cellphone != nil && [self.m_friendInfo.cellphone length] > 0) {
        [self replaceObjectWithIndex:startIndex++ andContent:self.m_friendInfo.cellphone];
    } else {
        [self replaceObjectWithIndex:startIndex++ andContent:@""];
    }
    
    // 固定电话
    NSLog(@"FriendsDetailInfoViewController landline == %@", self.m_friendInfo.landline);
    if (self.m_friendInfo.landline != nil && [self.m_friendInfo.landline length] > 0) {
        [self replaceObjectWithIndex:startIndex++ andContent:self.m_friendInfo.landline];
    } else {
        [self replaceObjectWithIndex:startIndex++ andContent:@""];
    }
    
    // 组织
    NSLog(@"FriendsDetailInfoViewController organization_id == %@", self.m_friendInfo.organization_id);
    if (self.m_friendInfo.organization_id != nil && [self.m_friendInfo.organization_id length] > 0) {
        [self replaceObjectWithIndex:startIndex++ andContent:self.m_friendInfo.organization_id];
    } else {
        [self replaceObjectWithIndex:startIndex++ andContent:@""];
    }
    
    // 职务
    NSLog(@"FriendsDetailInfoViewController title == %@", self.m_friendInfo.title);
    if (self.m_friendInfo.title != nil && [self.m_friendInfo.title length] > 0) {
        [self replaceObjectWithIndex:startIndex++ andContent:self.m_friendInfo.title];
    } else {
        [self replaceObjectWithIndex:startIndex++ andContent:@""];
    }
    
    // 生日
    NSLog(@"FriendsDetailInfoViewController birthday == %@", self.m_friendInfo.birthday);
    if (self.m_friendInfo.birthday != nil && [self.m_friendInfo.birthday length] > 0) {
        [self replaceObjectWithIndex:startIndex++ andContent:self.m_friendInfo.birthday];
    } else {
        [self replaceObjectWithIndex:startIndex++ andContent:@""];
    }
    
    // 星座
    NSLog(@"FriendsDetailInfoViewController zodiac == %@", self.m_friendInfo.zodiac);
    if (self.m_friendInfo.zodiac != nil && [self.m_friendInfo.zodiac length] > 0) {
        [self replaceObjectWithIndex:startIndex++ andContent:self.m_friendInfo.zodiac];
    } else {
        [self replaceObjectWithIndex:startIndex++ andContent:@""];
    }
    
    // 生肖
    NSLog(@"FriendsDetailInfoViewController zhZodiac == %@", self.m_friendInfo.zhZodiac);
    if (self.m_friendInfo.zhZodiac != nil && [self.m_friendInfo.zhZodiac length] > 0) {
        [self replaceObjectWithIndex:startIndex++ andContent:self.m_friendInfo.zhZodiac];
    } else {
        [self replaceObjectWithIndex:startIndex++ andContent:@""];
    }
    
    // 血型
    NSLog(@"FriendsDetailInfoViewController bloodType == %@", self.m_friendInfo.bloodType);
    if (self.m_friendInfo.bloodType != nil && [self.m_friendInfo.bloodType length] > 0) {
        [self replaceObjectWithIndex:startIndex++ andContent:self.m_friendInfo.bloodType];
    } else {
        [self replaceObjectWithIndex:startIndex++ andContent:@""];
    }
    
    // 爱好
    NSLog(@"FriendsDetailInfoViewController hobby == %@", self.m_friendInfo.hobby);
    if (self.m_friendInfo.hobby != nil && [self.m_friendInfo.hobby length] > 0) {
        [self replaceObjectWithIndex:startIndex++ andContent:self.m_friendInfo.hobby];
    } else {
        [self replaceObjectWithIndex:startIndex++ andContent:@""];
    }
    
    // 邮箱
    NSLog(@"FriendsDetailInfoViewController email == %@", self.m_friendInfo.email);
    if (self.m_friendInfo.email != nil && [self.m_friendInfo.email length] > 0) {
        [self replaceObjectWithIndex:startIndex++ andContent:self.m_friendInfo.email];
    } else {
        [self replaceObjectWithIndex:startIndex++ andContent:@""];
    }
    
    // 微博
    NSLog(@"FriendsDetailInfoViewController webLog == %@", self.m_friendInfo.webLog);
    if (self.m_friendInfo.webLog != nil && [self.m_friendInfo.webLog length] > 0) {
        [self replaceObjectWithIndex:startIndex++ andContent:self.m_friendInfo.webLog];
    } else {
        [self replaceObjectWithIndex:startIndex++ andContent:@""];
    }
    
    // 主页
    NSLog(@"FriendsDetailInfoViewController home_page == %@", self.m_friendInfo.home_page);
    if (self.m_friendInfo.home_page != nil && [self.m_friendInfo.home_page length] > 0) {
        [self replaceObjectWithIndex:startIndex++ andContent:self.m_friendInfo.home_page];
    } else {
        [self replaceObjectWithIndex:startIndex++ andContent:@""];
    }
    
    // 住址
    NSLog(@"FriendsDetailInfoViewController addressExtend == %@", self.m_friendInfo.addressExtend);
    if (self.m_friendInfo.addressExtend != nil && [self.m_friendInfo.addressExtend length] > 0) {
        [self replaceObjectWithIndex:startIndex++ andContent:self.m_friendInfo.addressExtend];
    } else {
        [self replaceObjectWithIndex:startIndex++ andContent:@""];
    }
    
    // 邮编
    NSLog(@"FriendsDetailInfoViewController address_postcode == %@", self.m_friendInfo.address_postcode);
    if (self.m_friendInfo.address_postcode != nil && [self.m_friendInfo.address_postcode length] > 0) {
        [self replaceObjectWithIndex:startIndex++ andContent:self.m_friendInfo.address_postcode];
    } else {
        [self replaceObjectWithIndex:startIndex++ andContent:@""];
    }
    
    // 个人说明
    NSLog(@"FriendsDetailInfoViewController information == %@", self.m_friendInfo.information);
    if (self.m_friendInfo.information != nil && [self.m_friendInfo.information length] > 0) {
        [self replaceObjectWithIndex:startIndex++ andContent:self.m_friendInfo.information];
    } else {
        [self replaceObjectWithIndex:startIndex++ andContent:@""];
    }
    NSLog(@"\n\n\n");
}

- (void)replaceObjectWithIndex:(NSUInteger)index andContent:(NSString *)content
{
    PersonalSettingData * settingData = [self.m_arrTableData objectAtIndex:index];
    settingData.m_content = content;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.m_arrTableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellID = @"edit";
    PersonalTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[PersonalTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellBackground.png"]];
    }
    
    PersonalSettingData * settingData = [self.m_arrTableData objectAtIndex:indexPath.row];
    [cell setCellWithSettingData:settingData];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
