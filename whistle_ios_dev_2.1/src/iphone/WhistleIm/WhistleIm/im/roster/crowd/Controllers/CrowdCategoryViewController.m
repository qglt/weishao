//
//  CrowdCategoryViewController.m
//  WhistleIm
//
//  Created by 管理员 on 14-2-10.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "CrowdCategoryViewController.h"
#import "NBNavigationController.h"
#import "ImUtils.h"
#import "CrowdManager.h"
#import "NetworkBrokenAlert.h"
#import "CommonRespondView.h"

#define  CELL_HEIGHT 45.0f

@interface CrowdCategoryViewController ()
<UITableViewDataSource, UITableViewDelegate>
{
    CGRect m_frame;
    UITableView * m_tableView;
    NSMutableArray * m_arrTableAllData;
    NSUInteger m_selectedIndex;
}

@property (nonatomic, strong) UITableView * m_tableView;
@property (nonatomic, strong) NSMutableArray * m_arrTableAllData;

@end

@implementation CrowdCategoryViewController

@synthesize m_tableView;
@synthesize m_arrTableAllData;
@synthesize m_category;
@synthesize m_crowdSessionID;

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
    [self createNavigationBar:YES];
    [self setBasicCondition];
    [self setMemory];
    [self setSelectedIndex];
    [self createTableView];
}

- (void)setSelectedIndex
{
    NSUInteger category = self.m_category;
    if (category == 10) {
        m_selectedIndex = 1;
    } else if (category == 11) {
        m_selectedIndex = 0;
    } else if (category == 12) {
        m_selectedIndex = 2;
    } else if (category == 13) {
        m_selectedIndex = 3;
    } else if (category == 14) {
        m_selectedIndex = 4;
    } else if (category == 15) {
        m_selectedIndex = 5;
    } else if (category == 16) {
        m_selectedIndex = 6;
    } else if (category == 17) {
        m_selectedIndex = 7;
    }
}

- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:nil andLeftTitle:@"群分类" andRightTitle:nil andNeedCreateSubViews:needCreate];
}

- (void)leftNavigationBarButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createNavigationBar:NO];
}

- (void)setBasicCondition
{
    self.view.backgroundColor = [ImUtils colorWithHexString:@"#F0F0F0"];
    m_frame = [[UIScreen mainScreen] bounds];
    
    if (isIOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

// 课程，社团，学习，生活，兴趣，老乡，朋友，其他
- (void)setMemory
{
    self.m_arrTableAllData = [[NSMutableArray alloc] initWithCapacity:0];
    [self.m_arrTableAllData addObject:@"社团"];
    [self.m_arrTableAllData addObject:@"课程"];
    [self.m_arrTableAllData addObject:@"学习"];
    [self.m_arrTableAllData addObject:@"生活"];

    [self.m_arrTableAllData addObject:@"兴趣"];
    [self.m_arrTableAllData addObject:@"老乡"];
    [self.m_arrTableAllData addObject:@"朋友"];
    [self.m_arrTableAllData addObject:@"其他"];
}

- (void)createTableView
{
    CGFloat y = 0.0f;
    if (isIOS7) {
        y += 64.0f;
    }
    
    self.m_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, y, m_frame.size.width, CELL_HEIGHT * [self.m_arrTableAllData count]) style:UITableViewStylePlain];
    self.m_tableView.delegate = self;
    self.m_tableView.dataSource = self;
    self.m_tableView.showsVerticalScrollIndicator = NO;
    self.m_tableView.rowHeight = CELL_HEIGHT;
    self.m_tableView.separatorColor = [UIColor clearColor];
    self.m_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.m_tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.m_tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.m_arrTableAllData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellID = @"category";
    UITableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellBackground.png"]];

       
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 270, 45)];
        label.textColor = [UIColor colorWithRed:109.0f / 255.0f green:109.0f / 255.0f blue:109.0f / 255.0f alpha:1.0f];
        label.backgroundColor = [UIColor clearColor];
        label.tag = 1000;
        [cell addSubview:label];
        
        UIImageView * indicatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(290, 15, 15, 15)];
        indicatorImageView.userInteractionEnabled = YES;
        indicatorImageView.tag = 2000;
        [cell addSubview:indicatorImageView];
        
        UIView * footerLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, 320, 1)];
        footerLineView.backgroundColor = [UIColor colorWithRed:224.0f / 255.0f green:224.0f / 255.0f blue:224.0f / 255.0f alpha:1.0f];
        [cell addSubview:footerLineView];
    }
    
    UILabel * label = (UILabel *)[cell viewWithTag:1000];
    label.text = [self.m_arrTableAllData objectAtIndex:indexPath.row];
    
    UIImageView * indicatorImageView = (UIImageView *)[cell viewWithTag:2000];
    indicatorImageView.image = [UIImage imageNamed:@"singleUnselected.png"];
    if (m_selectedIndex == indexPath.row) {
        indicatorImageView.image = [UIImage imageNamed:@"singleSelected.png"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    m_selectedIndex = indexPath.row;
    [self.m_tableView reloadData];
    
    // 发更改群分类的请求
    [self changeCrowdTypeWithIndex:indexPath.row];
}

// 群类型
- (void)changeCrowdTypeWithIndex:(NSUInteger)index
{
    if ([NetworkBrokenAlert isNetworkBrokenAndShowTip]) {
        return;
    }
    
    NSUInteger type = [self getCrowdTypeWithIndex:index];
    [[CrowdManager shareInstance] setCrowdCatagory:self.m_crowdSessionID category:type callback:^(BOOL success) {
        NSLog(@"change crowd type success == %d", success);
        [self showResultWithState:success];
    }];
}

- (void)showResultWithState:(BOOL)success
{
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
        	[self.navigationController popViewControllerAnimated:YES];
    	});
        [CommonRespondView respond:@"修改成功"];
    } else {
        [CommonRespondView respond:@"修改失败"];
    }
}

- (NSUInteger)getCrowdTypeWithIndex:(NSUInteger)index
{
    NSUInteger type = 0;
    if (index == 1) {
        type = 10;
    } else if (index == 0) {
        type = 11;
    } else if (index == 2) {
        type = 12;
    } else if (index == 3) {
        type = 13;
    } else if (index == 4) {
        type = 14;
    } else if (index == 5) {
        type = 15;
    } else if (index == 6) {
        type = 16;
    } else if (index == 7) {
        type = 17;
    }
    
    return type;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
