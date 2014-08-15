//
//  RequestCrowdViewController.m
//  WhistleIm
//
//  Created by ruijie on 14-2-14.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "RequestCrowdViewController.h"
#import "GetFrame.h"
#import "CrowdInfo.h"
#import "Whistle.h"
#import "JSONObjectHelper.h"
#import "RosterManager.h"
#import "NBNavigationController.h"
#import "RosterManager.h"
#import "CommonRespondView.h"
#import "NetworkBrokenAlert.h"
#import "ImUtils.h"
#import "CrowdManager.h"
#import "CommonRespondView.h"


#define LEFT_ITEM_TAG 2000
#define RIGHT_ITEM_TAG 3000

#define LIMIT_CHARACTOR_NUM 75

@interface RequestCrowdViewController ()<UITextViewDelegate>
{
    CGRect m_frame;
    BOOL m_isIOS7;
    BOOL m_is4Inch;

    UITextView * m_textView;
    UILabel * m_remarkLabel;
}

@property (nonatomic, strong) UITextView * m_textView;
@property (nonatomic, strong) UILabel * m_remarkLabel;

@end

@implementation RequestCrowdViewController
@synthesize m_CrowdInfo;

@synthesize m_textView;
@synthesize m_remarkLabel;

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
    [self setBaseCondition];
    [self createPersonImageView];
    [self createNameLabel];
    [self createOrganizationLabel];
    [self createSendInfoTextView];
    [self createLimitLabel];
}

- (void)setBaseCondition
{
    self.title = @"添加群";
    m_frame = self.view.bounds;
    m_isIOS7 = [[GetFrame shareInstance] isIOS7Version];
    m_is4Inch = [[GetFrame shareInstance] is4InchScreen];
    self.view.backgroundColor = [ImUtils colorWithHexString:@"#F0F0F0"];
}

- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:@"send" andLeftTitle:@"添加群" andRightTitle:nil andNeedCreateSubViews:needCreate];
}

- (void)leftNavigationBarButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightNavigationBarButtonPressed:(UIButton *)button
{
    [self sendAddingCrowdRequest];
}

- (void)sendAddingCrowdRequest
{
    if ([NetworkBrokenAlert isNetworkBrokenAndShowTip]) {
        return;
    }
    [[CrowdManager shareInstance] applyJoinCrowd:m_CrowdInfo.session_id reason:self.m_textView.text callback:^(BOOL isSuccess) {
        if (isSuccess) {
            [CommonRespondView respond:@"发送成功，等待确认"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        } else {
            [CommonRespondView respond:@"发送失败，请检查网络状态"];
        }
    }];
}

- (void)createPersonImageView
{
    CGFloat y = 10;
    if (m_isIOS7) {
        y += 64;
    }
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, 55, 55)];
    imageView.center = CGPointMake(self.view.center.x, imageView.center.y);
    imageView.clipsToBounds = YES;
    imageView.image = [m_CrowdInfo getCrowdIcon];
    imageView.layer.cornerRadius = 55.0/2.0f;
    [self.view addSubview:imageView];
}

- (void)createNameLabel
{
    CGFloat y = 71;
    if (m_isIOS7) {
        y += 64;
    }
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, y, 210, 15)];
    label.center = CGPointMake(self.view.center.x, label.center.y);
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor whiteColor];
    label.textColor = [ImUtils colorWithHexString:@"#262626"];
    label.text = self.m_CrowdInfo.name;
    label.font = [UIFont systemFontOfSize:15.0f];
    label.backgroundColor = [UIColor clearColor];
    [self.view addSubview:label];
}

-(void)createOrganizationLabel
{
    CGFloat y = 92;
    if (m_isIOS7) {
        y += 64;
    }
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, y, 210, 12)];
    label.center = CGPointMake(self.view.center.x, label.center.y);
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [ImUtils colorWithHexString:@"#808080"];
    label.font = [UIFont systemFontOfSize:12.0f];
    label.text = [@"群号：" stringByAppendingString:[m_CrowdInfo getCrowdID]];
    label.backgroundColor = [UIColor clearColor];
    [self.view addSubview:label];
}
- (void)createSendInfoTextView
{
    CGFloat y = 92 + 12 + 10;
    if (m_isIOS7) {
        y += 64;
    }

    UIView * txtBGView = [[UIView alloc]initWithFrame:CGRectMake(0, y, m_frame.size.width, 82)];
    txtBGView.backgroundColor = [UIColor whiteColor];

    self.m_textView = [[UITextView alloc] initWithFrame:CGRectMake(10, y+5, m_frame.size.width-30, 64)];
    self.m_textView.backgroundColor = [UIColor clearColor];
    self.m_textView.delegate = self;
    self.m_textView.textColor = [ImUtils colorWithHexString:@"#262626"];
    self.m_textView.font = [UIFont systemFontOfSize:15.0f];
    [self.view addSubview:txtBGView];
    [self.view addSubview:self.m_textView];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.m_textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (range.location >= LIMIT_CHARACTOR_NUM) {
        return NO;
    } else {
        return YES;
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSInteger limitNumber = LIMIT_CHARACTOR_NUM - textView.text.length;
    if (limitNumber <= 0) {
        limitNumber = 0;
    }
    self.m_remarkLabel.text = [NSString stringWithFormat:@"%d", limitNumber];
}

- (void)createLimitLabel
{
    self.m_remarkLabel = [[UILabel alloc] initWithFrame:CGRectMake(m_frame.size.width - 10 - 15 , self.m_textView.frame.origin.y + self.m_textView.frame.size.height - 9, 13, 11)];
    self.m_remarkLabel.textAlignment = NSTextAlignmentCenter;
    self.m_remarkLabel.textColor = [ImUtils colorWithHexString:@"#808080"];
    self.m_remarkLabel.font = [UIFont systemFontOfSize:11.0f];
    self.m_remarkLabel.text = [NSString stringWithFormat:@"%d", LIMIT_CHARACTOR_NUM];
    self.m_remarkLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.m_remarkLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
