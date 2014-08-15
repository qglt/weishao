//
//  CampusActivityDetailController.m
//  WhistleIm
//
//  Created by LI on 14-2-19.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "CampusActivityDetailController.h"
#import "CampusActivity.h"
#import "Constants.h"
#import "ImUtils.h"
#import "NBNavigationController.h"

@interface CampusActivityDetailController ()

@end

@implementation CampusActivityDetailController
@synthesize activityObject;

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
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [self setBasicCondition];
	
    [self initTitle:@"活动详情"];
    
    [self createNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    CampusActivity *act = self.activityObject;
    
    ((UILabel *)[self.view viewWithTag:2]).text = act.game_name;
    //((UILabel *)[self.view viewWithTag:3]).text = act;
    ((UILabel *)[self.view viewWithTag:4]).text = act.creator_jid;
    ((UILabel *)[self.view viewWithTag:5]).text = act.type;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; 
    [dateFormatter setDateFormat:@"MM-dd HH:mm"];
    
    ((UILabel *)[self.view viewWithTag:6]).text = [dateFormatter stringFromDate:act.begin_time];
    ((UILabel *)[self.view viewWithTag:7]).text = [dateFormatter stringFromDate:act.end_time];
    
    ((UILabel *)[self.view viewWithTag:8]).text = act.game_desc;
    ((UILabel *)[self.view viewWithTag:9]).text = [NSString stringWithFormat:@"%d人参加/限%d人",act.member_number,act.limit_number];
    

}

- (void)setBasicCondition
{
    self.view.backgroundColor = [ImUtils colorWithHexString:@"#F0F0F0"];
    if (isIOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}


- (void)initTitle:(NSString *)title
{
    UILabel *titleLabel = [[UILabel alloc] init];
    
    titleLabel.backgroundColor  = [UIColor clearColor];
    titleLabel.textColor        = [UIColor whiteColor];
    titleLabel.text             = title;
    [titleLabel sizeToFit];
    
    self.navigationItem.titleView = titleLabel;
}


- (void)createNavigationBar
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIView *topbarContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, MAPTOPBARHEIGHT)];
    [self.view addSubview:topbarContainer];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(122, 30, 76, 21)];
    [label setText:@"活动详情"];
    [label setFont:[UIFont systemFontOfSize:18]];
    [label setTextColor:[UIColor colorWithRed:157.0/255 green:157.0/255 blue:157.0/255 alpha:1.0]];
    [label setBackgroundColor:[UIColor clearColor]];
    [topbarContainer addSubview:label];
    
    
    UIButton *btn = [self createButtonWithTitle:@"返回" withFrame:CGRectMake(12, 27, 50, 29) withTag:0];
    [btn setBackgroundColor:[UIColor clearColor]];
    
    [topbarContainer addSubview:btn];
}

-(UIButton *)createButtonWithTitle:(NSString *)string withFrame:(CGRect) rect withTag:(NSInteger) tag
{
    UIButton *button = nil;
    if(tag == 0){
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = rect;
    }
    
    [button setTitle:string forState:UIControlStateNormal];
    //button.backgroundColor = [UIColor blueColor];
    //[button setTintColor:[UIColor colorWithRed:157.0/255 green:157.0/255 blue:157.0/255 alpha:1.0]];
    [button setTitleColor:[UIColor colorWithRed:157.0/255 green:157.0/255 blue:157.0/255 alpha:1.0] forState:UIControlStateNormal];
    [button setFont:[UIFont systemFontOfSize:18]];
    button.tag = tag;
    [button addTarget:self action:@selector(pressBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    return  button;
}
#pragma mark - Handle Button Event
- (void)pressBtn:(UIButton *)btn
{
    switch (btn.tag) {
        case 0:
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
            
        default:
            break;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
