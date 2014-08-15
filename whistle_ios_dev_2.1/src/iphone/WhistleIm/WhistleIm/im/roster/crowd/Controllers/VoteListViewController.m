//
//  VoteListViewController.m
//  WhistleIm
//
//  Created by 管理员 on 14-1-8.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "VoteListViewController.h"
#import "NBNavigationController.h"
#import "VoteListTableView.h"
#import "ImUtils.h"

@interface VoteListViewController ()
{
    CGRect m_frame;
    VoteListTableView * m_listTableView;
    
    NSMutableArray * m_arrSectionTitle;
}

@property (nonatomic, strong) VoteListTableView * m_listTableView;
@property (nonatomic, strong) NSMutableArray * m_arrSectionTitle;
@end

@implementation VoteListViewController

@synthesize m_listTableView;
@synthesize m_arrTableData;
@synthesize m_arrSectionTitle;

//@synthesize m_arrVotePersonNames;

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
    [self createVoteListTableView];
    
    [self refreshTableView];
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
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:nil andLeftTitle:@"投票名单" andRightTitle:nil andNeedCreateSubViews:needCreate];
}

- (void)leftNavigationBarButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createVoteListTableView
{
    CGFloat y = 0.0f;
    if (isIOS7) {
        y += 64.0f;
    }
    CGFloat height = m_frame.size.height - 20 - 44;
    self.m_listTableView = [[VoteListTableView alloc] initWithFrame:CGRectMake(0, y, m_frame.size.width, height)];
    [self.view addSubview:self.m_listTableView];
}

- (void)refreshTableView
{
    self.m_arrSectionTitle = [self getTitleSectionArr];
    self.m_arrTableData = [self sortTableDataArr];
    [self.m_listTableView refreshVoteListTableViewWithTableData:self.m_arrTableData andTitleData:self.m_arrSectionTitle];
}

- (NSMutableArray *)sortTableDataArr
{
    NSMutableArray * nameArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSUInteger i = 0; i < [self.m_arrTableData count]; i++) {
        NSString * names = [self.m_arrTableData objectAtIndex:i];
        if (![names isEqualToString:@""]) {
            [nameArr addObject:names];
        }
    }
    
    NSLog(@"nameArr == %@", nameArr);
    
    return nameArr;
}

- (NSMutableArray *)getTitleSectionArr
{
    NSMutableArray * titleSectionArr = [NSMutableArray array];
    for (int section = 'A'; section < 'A' + [self.m_arrTableData count]; section++) {
        
        NSString * names = [self.m_arrTableData objectAtIndex:section - 'A'];
        if (![names isEqualToString:@""]) {
            [titleSectionArr addObject:[NSString stringWithFormat:@"选%c的有", section]];
        }
    }
    
    NSLog(@"titleSectionArr == %@", titleSectionArr);

    return titleSectionArr;
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
