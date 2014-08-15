//
//  CampusActivityListViewController.m
//  WhistleIm
//
//  Created by liming on 14-2-11.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "CampusActivityListViewController.h"
#import "CampusActivityListController.h"
#import "CampusActivityDetailController.h"

@interface CampusActivityListViewController ()<CampusActivityListDelegate>
@property (nonatomic,strong) CampusActivityListController *activitiesList;
@property (nonatomic,strong) UIScrollView *scrollerView;

@end

@implementation CampusActivityListViewController

@synthesize scrollerView;

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

    [self createTabBar];
    [self createScroller];
    
    self.activitiesList = [[CampusActivityListController alloc] init];
    self.activitiesList.pushDalegate = self;
    UIView *listView = [self.activitiesList getView];
    [listView setFrame:CGRectMake(0,0,self.view.frame.size.width,self.scrollerView.frame.size.height)];
    [self.scrollerView addSubview:listView];
    [self.activitiesList bindView];
	// Do any additional setup after loading the view.
}

-(void)createTabBar
{
    UIButton *allBtn = [self crateTabButtonWithTitle:@"全部" withFrame:CGRectMake(0,0,self.view.frame.size.width/2,50) withTag:0];
     UIButton *myBtn = [self crateTabButtonWithTitle:@"我的" withFrame:CGRectMake(self.view.frame.size.width/2,0,self.view.frame.size.width/2,50) withTag:0];
    [self.view addSubview:allBtn];
    [self.view addSubview:myBtn];
}

-(void)push2DetailController:(CampusActivity *)activity
{
    CampusActivityDetailController *controller = [[CampusActivityDetailController alloc] init];
    controller.activityObject = activity;
    self.navigationController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

-(UIButton *)crateTabButtonWithTitle:(NSString *)string withFrame:(CGRect) rect withTag:(NSInteger) tag
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = rect;
    [button setTitle:string forState:UIControlStateNormal];
    button.backgroundColor = [UIColor blueColor];
    button.tag = tag;
    [button addTarget:self action:@selector(pressTabBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    return  button;
}

-(void)pressBtn:(UIButton *)btn
{
    switch (btn.tag) {
        case 0:
            
            break;
        case 1:
            
            break;
            
        default:
            break;
    }
}


-(void) createScroller
{
    scrollerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,50,self.view.frame.size.width,self.view.frame.size.height-50)];
    scrollerView.contentSize = CGSizeMake(self.view.frame.size.width*2,scrollerView.frame.size.height);
    [self.view addSubview:scrollerView];
}

-(void)dealloc
{
    [[self.activitiesList getView] removeFromSuperview];
    [self.activitiesList unbindView];
    [self.activitiesList destroy];
    self.activitiesList = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
