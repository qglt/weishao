//
//  CrowdVoteViewController.m
//  WhistleIm
//
//  Created by 管理员 on 14-1-8.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "CrowdVoteViewController.h"
#import "NBNavigationController.h"
#import "CrowdVoteTableView.h"
#import "VotePercentageInfo.h"
#import "VoteListViewController.h"
#import "CrowdVoteInfo.h"
#import "CrowdVoteItmes.h"
#import "CrowdVoteHelper.h"
#import "GetFrame.h"
#import "ImUtils.h"
#import "RosterManager.h"

@interface CrowdVoteViewController ()
<CrowdVoteTableViewDelegate, CrowdVoteHelperDelegate>
{
    CGRect m_frame;
    CrowdVoteTableView * m_voteTableView;
    NSMutableArray * m_arrTableData;
    NSMutableDictionary * m_dictInfo;
    BOOL m_isSingleType;
    
    NSMutableArray * m_arrVotePercentage;
    
    CrowdVoteHelper * m_voteHelper;
    
    BOOL m_anonymous;
    
    NSMutableArray * m_arrSelectedState;
    
    NSMutableArray * m_arrVotePersonNames;

}

@property (nonatomic, strong) CrowdVoteTableView * m_voteTableView;
@property (nonatomic, strong) NSMutableArray * m_arrTableData;
@property (nonatomic, strong) NSMutableDictionary * m_dictInfo;
@property (nonatomic, strong) NSMutableArray * m_arrVotePercentage;
@property (nonatomic, strong) CrowdVoteHelper * m_voteHelper;
@property (nonatomic, strong) NSMutableArray * m_arrSelectedState;
@property (nonatomic, strong) NSMutableArray * m_arrVotePersonNames;



@end

@implementation CrowdVoteViewController

@synthesize m_voteTableView;
@synthesize m_arrTableData;
@synthesize m_dictInfo;
@synthesize m_arrVotePercentage;
@synthesize m_hadVoted;
@synthesize m_crowdVoteInfo;
@synthesize m_voteHelper;
@synthesize m_arrSelectedState;
@synthesize m_arrVotePersonNames;

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
    
    // 单选多选
    if (self.m_crowdVoteInfo.single) {
        m_isSingleType = YES;
    } else {
        m_isSingleType = NO;
    }
    
    // 是否匿名
    if (self.m_crowdVoteInfo.anonymous) {
        m_anonymous = YES;
    } else {
        m_anonymous = NO;
    }
    
    if (self.m_crowdVoteInfo.m_arrSelfVoted != nil && [self.m_crowdVoteInfo.m_arrSelfVoted count] > 0) {
        m_hadVoted = YES;
    } else {
        m_hadVoted = NO;
    }
    
    NSLog(@"m_hadVoted == %d", m_hadVoted);

    [self setMemory];
    [self setbasicCondition];
    [self createNavigationBar:YES];

    [self createVoteTableView];
    
    // 创建投票标题
    [self getHeaderInfoDict];
    
    // 创建投票选项
    [self getItemsTableData];

    
    if (self.m_hadVoted) {
        [self getHadVotedDataWithCrowdVoteInfo:self.m_crowdVoteInfo];
        [self refreshPercentageTableData];
    } else {
        [self refreshVoteItemsTableData];
    }
    
    
    [self logData];
    [self createVoteHelper];
}

//number:需要处理的数字， position：保留小数点第几位，
-(NSString *)roundUp:(float)number afterPoint:(int)position
{
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:YES raiseOnDivideByZero:NO];
    NSDecimalNumber *ouncesDecimal;
    NSDecimalNumber *roundedOunces;
    ouncesDecimal = [[NSDecimalNumber alloc] initWithFloat:number];
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    NSLog(@"roundedOunces == %@", [NSString stringWithFormat:@"%@",roundedOunces]);
    return [NSString stringWithFormat:@"%@",roundedOunces];
}

- (void)createVoteHelper
{
    self.m_voteHelper = [[CrowdVoteHelper alloc] init];
    self.m_voteHelper.m_delegate = self;
}

- (void)logData
{
    /*
     @property (nonatomic, strong) NSString *gid;//群ID
     @property (nonatomic, strong) NSString *title;//投票标题
     @property (nonatomic, assign) NSInteger single;//是否为单选模式
     @property (nonatomic, assign) NSInteger anonymous;//是否为匿名投票
     @property (nonatomic, strong) NSString *timesTamp;//投票创建时间
     @property (nonatomic, strong) NSString *vid;//投票的id
     @property (nonatomic, strong) NSString *jid;//创建人的jid
     @property (nonatomic, strong) NSString *name;//创建人的姓名
     @property (nonatomic, assign) NSInteger totalCount;//总票数
     @property (nonatomic, assign) NSInteger pollMember;//参与投票的总人数
     
     
     @property (nonatomic, strong) NSArray *voteItems;//投票项为json数组，且至少为2个，装CrowdVoteItmes对象
     */
    NSLog(@"%@", self.m_crowdVoteInfo);
    
    NSLog(@"vote crowd gid == %@", self.m_crowdVoteInfo.gid);
    NSLog(@"voteTitle == %@", self.m_crowdVoteInfo.title);
    NSLog(@"single == %d", self.m_crowdVoteInfo.single);
    NSLog(@"anonymous == %d", self.m_crowdVoteInfo.anonymous);
    NSLog(@"timesTamp == %@", self.m_crowdVoteInfo.timesTamp);

    NSLog(@"vid == %@", self.m_crowdVoteInfo.vid);
    NSLog(@"vote person jid == %@", self.m_crowdVoteInfo.jid);
    NSLog(@"name == %@", self.m_crowdVoteInfo.name);
    NSLog(@"totalCount == %d", self.m_crowdVoteInfo.totalCount);
    NSLog(@"voteItems == %@", self.m_crowdVoteInfo.voteItems);
    NSLog(@"extraInfo == %@", self.m_crowdVoteInfo.extraInfo);
    NSLog(@"m_arrSelfVoted == %@", self.m_crowdVoteInfo.m_arrSelfVoted);
    /*
     @property (nonatomic, strong) NSString *itemName;//投票选项
     @property (nonatomic, assign) NSInteger iid;//选项的ID
     @property (nonatomic, strong) NSArray *members;
     */
    
    for (NSUInteger i = 0; i < [self.m_crowdVoteInfo.voteItems count]; i++) {
        CrowdVoteItmes * voteItems = [self.m_crowdVoteInfo.voteItems objectAtIndex:i];
        NSLog(@"itemName == %@", voteItems.itemName);
        NSLog(@"iid == %d", voteItems.iid);
        NSLog(@"members == %@", voteItems.members);
    }
}

- (void)setMemory
{
    self.m_arrTableData = [[NSMutableArray alloc] initWithCapacity:0];
    self.m_arrVotePercentage = [[NSMutableArray alloc] initWithCapacity:0];
    self.m_dictInfo = [[NSMutableDictionary alloc] initWithCapacity:0];
    self.m_arrVotePersonNames = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)setbasicCondition
{
    self.view.backgroundColor = [ImUtils colorWithHexString:@"#F0F0F0"];
    m_frame = [[UIScreen mainScreen] bounds];
    
    if (isIOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:nil andLeftTitle:@"投票" andRightTitle:nil andNeedCreateSubViews:needCreate];
}

- (void)leftNavigationBarButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createVoteTableView
{
    CGFloat y = 0.0f;
    if (isIOS7) {
        y += 64.0f;
    }
    CGFloat height = m_frame.size.height - 20 - 44;
    self.m_voteTableView = [[CrowdVoteTableView alloc] initWithFrame:CGRectMake(0, y, m_frame.size.width, height)];
    self.m_voteTableView.m_delegate = self;
    [self.view addSubview:self.m_voteTableView];
}

// CrowdVoteTableView delegate 发起投票请求
- (void)voteButtonPressed:(NSMutableArray *)stateArr
{
    NSLog(@"voteArr in CrowdVoteViewController == %@", stateArr);
    if ([self hadVotedAtLeastOneItemWithStateArr:stateArr]) {
        self.m_arrSelectedState = stateArr;
        [self voteMyCardWithSelectedArr:stateArr];
    } else {
        [self createAlertViewWithMessage:@"请选择投票项"];
    }
}

- (BOOL)hadVotedAtLeastOneItemWithStateArr:(NSMutableArray *)stateArr
{
    BOOL result = NO;
    for (NSUInteger i = 0; i < [stateArr count]; i++) {
        NSNumber * selectedState = [stateArr objectAtIndex:i];
        if ([selectedState boolValue]) {
            result = YES;
            break;
        }
    }
    
    return result;
}

- (void)createAlertViewWithMessage:(NSString *)message
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

// 发起投票请求
- (void)voteMyCardWithSelectedArr:(NSMutableArray *)stateArr
{
    NSUInteger votedId = [self.m_crowdVoteInfo.vid integerValue];
    
    NSString * iid = nil;
    if (m_isSingleType) {
        iid = @"";
    } else {
        iid = @"";
    }
    for (NSUInteger i = 0; i < [stateArr count]; i++) {
        BOOL selected = [[stateArr objectAtIndex:i] boolValue];
        if (selected) {
            CrowdVoteItmes * voteItems = [self.m_crowdVoteInfo.voteItems objectAtIndex:i];
            NSLog(@"iid == %d", voteItems.iid);
            
            if (m_isSingleType) {
                iid = [iid stringByAppendingFormat:@"iid[]=%d", voteItems.iid];
            } else {
                iid = [iid stringByAppendingFormat:@"iid[]=%d&", voteItems.iid];
            }
        }
    }
    
    if (!m_isSingleType) {
        iid = [iid substringToIndex:[iid length] - 1];
    }
    
    NSLog(@"my vote iids == %@", iid);
    
    [self.m_voteHelper voteMySelectedWithJid:self.m_crowdVoteInfo.jid voteId:votedId iids:iid name:self.m_crowdVoteInfo.name];
}

// 点击投票之后的结果回调
- (void)sendVoteData:(CrowdVoteInfo *)voteInfo
{
    [self getHadVotedDataWithCrowdVoteInfo:voteInfo];
    [self refreshPercentageTableData];
}

- (void)getHadVotedDataWithCrowdVoteInfo:(CrowdVoteInfo *)voteInfo
{
    [self.m_arrVotePercentage removeAllObjects];
    [self.m_arrVotePersonNames removeAllObjects];
    
    self.m_crowdVoteInfo = voteInfo;
    NSLog(@"self.m_crowdVoteInfo.m_arrSelfVoted == %@", self.m_crowdVoteInfo.m_arrSelfVoted);
    
    NSMutableArray * mySelectedArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSUInteger i = 0; i < [self.m_crowdVoteInfo.m_arrSelfVoted count]; i++) {
        NSDictionary * mySelectedDict =  [self.m_crowdVoteInfo.m_arrSelfVoted objectAtIndex:i];
        NSString * iid = [mySelectedDict objectForKey:@"iid"];
        [mySelectedArr addObject:iid];
    }
    NSLog(@"mySelectedArr ==  %@", mySelectedArr);
    
    for (NSUInteger i = 0; i < [voteInfo.voteItems count]; i++) {
        CrowdVoteItmes * voteItems = [voteInfo.voteItems objectAtIndex:i];
        NSLog(@"itemName == %@", voteItems.itemName);
        NSLog(@"iid == %d", voteItems.iid);
        NSLog(@"members == %@", voteItems.members);
        
        VotePercentageInfo * percentageInfo = [[VotePercentageInfo alloc] init];
        
        percentageInfo.m_itemName = [self.m_arrTableData objectAtIndex:i];
        
        
        for (NSUInteger i = 0; i < [mySelectedArr count]; i++) {
            NSUInteger iid = [[mySelectedArr objectAtIndex:i] integerValue];
            if (iid == voteItems.iid) {
                percentageInfo.m_isMySelected = YES;
                break;
            } else {
                percentageInfo.m_isMySelected = NO;
            }
        }
       
        
        NSLog(@"is myself selected == %d", percentageInfo.m_isMySelected);
        
        percentageInfo.m_progress = (CGFloat)voteItems.count / voteInfo.totalCount;
        
        NSString * ratio = [NSString stringWithFormat:@"%d(", voteItems.count];
        NSString * percentage = [self roundUp:(CGFloat)voteItems.count / voteInfo.totalCount * 100 afterPoint:0];
        ratio = [ratio stringByAppendingFormat:@"%@", percentage];
        ratio = [ratio stringByAppendingFormat:@"%@", @"%)"];
        NSLog(@"voteItems.count == %d", voteItems.count);
        NSLog(@"voteInfo.totalCount == %d", voteInfo.totalCount);
        NSLog(@"m_progress == %f", percentageInfo.m_progress);
        NSLog(@"ratio str == %@", ratio);
        percentageInfo.m_percentageStr = ratio;
        
        [self.m_arrVotePercentage addObject:percentageInfo];
        
        if (voteItems.members && voteItems.members.length > 0) {
            [self.m_arrVotePersonNames addObject:voteItems.members];
        } else {
            [self.m_arrVotePersonNames addObject:@""];
        }
    }
    
    NSLog(@"self.m_arrVotePersonNames == %@", self.m_arrVotePersonNames);
    NSLog(@"self.m_arrVotePercentage == %@", self.m_arrVotePercentage);
}

- (BOOL)isMySelfVotedWithName:(NSString *)votedName
{
    BOOL mySelfVoted = NO;
    NSString * myName = [[RosterManager shareInstance] mySelf].name;
    NSLog(@"my name == %@", myName);
    NSLog(@"votedName == %@", votedName);

    if (m_isSingleType) {
        if ([votedName isEqualToString:myName]) {
            mySelfVoted = YES;
        } else {
            mySelfVoted = NO;
        }
    } else {
        if([votedName rangeOfString:myName].location !=NSNotFound) {
            mySelfVoted = YES;
        } else {
            mySelfVoted = NO;
        }
    }
    
    return mySelfVoted;
}

// 刷新投票之后的页面
- (void)refreshPercentageTableData
{
    self.m_voteTableView.m_isShowVoteRatio = YES;
    self.m_voteTableView.m_hadVoted = self.m_hadVoted;
    self.m_voteTableView.m_anonymous = m_anonymous;
    [self.m_voteTableView refreshTableViewWithVotePercentageData:self.m_arrVotePercentage andInfoDict:self.m_dictInfo];
}

// CrowdVoteTableView delegate
- (void)showVoteList
{
    VoteListViewController * controller = [[VoteListViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    controller.m_arrTableData = self.m_arrVotePersonNames;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)getItemsTableData
{
    [self.m_arrTableData removeAllObjects];
    for (NSUInteger i = 'A'; i < 'A' + [self.m_crowdVoteInfo.voteItems count]; i++) {
        CrowdVoteItmes * voteItems = [self.m_crowdVoteInfo.voteItems objectAtIndex:i - 'A'];
        NSString * sortingName = [NSString stringWithFormat:@"%c、", i];
        sortingName = [sortingName stringByAppendingFormat:@"%@", voteItems.itemName];
        [self.m_arrTableData addObject:sortingName];
    }
}

- (void)getHeaderInfoDict
{
    [self.m_dictInfo setObject:[NSNumber numberWithBool:m_isSingleType] forKey:@"voteType"];
    if (m_anonymous) {
        [self.m_dictInfo setObject:@"(匿名投票)" forKey:@"signType"];

    } else {
        [self.m_dictInfo setObject:@"(记名投票)" forKey:@"signType"];
    }
    [self.m_dictInfo setObject:self.m_crowdVoteInfo.name forKey:@"votePerson"];
    
    NSString * timeStr = @"投票后查看结果 ";
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_US"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[self.m_crowdVoteInfo.timesTamp doubleValue]];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];

    NSString * voteTime = [timeStr stringByAppendingFormat:@"%@", confromTimespStr];
    [self.m_dictInfo setObject:voteTime forKey:@"voteTime"];
    
    NSString * type = nil;
    if (m_isSingleType) {
        type = @"(单选)";
    } else {
        type = @"(多选)";
    }
    NSString * title = [type stringByAppendingFormat:@"%@", self.m_crowdVoteInfo.title];
    
    [self.m_dictInfo setObject:title forKey:@"voteName"];
    
    UIImage * headerImage = [[GetFrame shareInstance] getFriendHeadImageWithFriendInfo:self.m_crowdVoteInfo.extraInfo convertToGray:NO];
    [self.m_dictInfo setObject:headerImage forKey:@"image"];
}

- (void)refreshVoteItemsTableData
{
    self.m_voteTableView.m_isShowVoteRatio = NO;
    self.m_voteTableView.m_hadVoted = self.m_hadVoted;
    [self.m_voteTableView refreshTableViewWithData:self.m_arrTableData andInfoDict:self.m_dictInfo];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createNavigationBar:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
