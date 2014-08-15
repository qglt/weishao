//
//  RequestFriendsViewController.m
//  WhistleIm
//
//  Created by 管理员 on 13-10-25.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "RequestFriendsViewController.h"
#import "GetFrame.h"
#import "FriendInfo.h"
#import "Whistle.h"
#import "JSONObjectHelper.h"
#import "RosterManager.h"
#import "NBNavigationController.h"
#import "RosterManager.h"
#import "CommonRespondView.h"
#import "NetworkBrokenAlert.h"
#import "ImUtils.h"

#define LEFT_ITEM_TAG 2000
#define RIGHT_ITEM_TAG 3000

#define LIMIT_CHARACTOR_NUM 75

@interface RequestFriendsViewController ()
<UITextViewDelegate>
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

@implementation RequestFriendsViewController

@synthesize m_friendInfo;

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
    self.title = @"添加好友请求";
    m_frame = self.view.bounds;
    m_isIOS7 = [[GetFrame shareInstance] isIOS7Version];
    m_is4Inch = [[GetFrame shareInstance] is4InchScreen];
    self.view.backgroundColor = [ImUtils colorWithHexString:@"#F0F0F0"];
}

- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:@"send" andLeftTitle:NSLocalizedString(@"add_friend_request", nil) andRightTitle:nil andNeedCreateSubViews:needCreate];
}

- (void)leftNavigationBarButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightNavigationBarButtonPressed:(UIButton *)button
{
    [self sendAddingFriendRequest];
//    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sendAddingFriendRequest
{
    if ([NetworkBrokenAlert isNetworkBrokenAndShowTip]) {
        return;
    }
    NSLog(@"send add friends request in RequestFriendsViewController!");
    [[RosterManager shareInstance] addBuddy:self.m_friendInfo withMsg:self.m_textView.text withCallback:^(BOOL success) {
        if (success) {
            [CommonRespondView respond:@"发送成功，等待好友确认"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }else{
            [CommonRespondView respond:@"发送失败，请检查网络状态"];
        }
    }];
}

- (void)createPersonImageView
{
    CGFloat y = 15;
    if (m_isIOS7) {
        y += 64;
    }
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(132.5, y, 55, 55)];
    imageView.center = CGPointMake(self.view.center.x, imageView.center.y);
    imageView.clipsToBounds = YES;
    UIImage * image = [[GetFrame shareInstance] getFriendHeadImageWithFriendInfo:self.m_friendInfo convertToGray:NO];
    imageView.image = image;
    imageView.layer.cornerRadius = 27.5f;
    imageView.layer.masksToBounds = YES;
    imageView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:imageView];
}

- (void)createNameLabel
{
    CGFloat y = 76;
    if (m_isIOS7) {
        y += 64;
    }
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, y, self.view.bounds.size.width, 15)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = self.m_friendInfo.name;
    label.font = [UIFont fontWithName:@"STHeitiTC-Light" size:15.0f];
    label.textColor = [ImUtils colorWithHexString:@"#262626"];
    label.backgroundColor = [UIColor clearColor];
    [self.view addSubview:label];
    
    
    if ([self.m_friendInfo.identity isEqualToString:@"biz.vcard.teacher"]) {
     
        CGSize size = [self.m_friendInfo.name sizeWithFont:[UIFont systemFontOfSize:15.0f]];
        
        UIImageView * starImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-size.width)/2-15-2, y, 15, 15)];
        starImageView.image = [UIImage imageNamed:@"identity_teacher_new.png"];
        starImageView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:starImageView];
    }
}

-(void)createOrganizationLabel
{
    CGFloat y = 97;
    if (m_isIOS7) {
        y += 64;
    }
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(15, y,  self.view.bounds.size.width - 30, 12)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = self.m_friendInfo.organization_id;
    label.font = [UIFont fontWithName:@"STHeitiTC-Light" size:12.0f];
    label.textColor = [ImUtils colorWithHexString:@"#808080"];
    label.backgroundColor = [UIColor clearColor];
    [self.view addSubview:label];
}

- (void)createSendInfoTextView
{
    CGFloat y = 115;
    if (m_isIOS7) {
        y += 64;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, y+1, m_frame.size.width, 82)];
    view.backgroundColor = [UIColor whiteColor];
    
    
    self.m_textView = [[UITextView alloc] initWithFrame:CGRectMake(15,15, m_frame.size.width-30, 52)];
    self.m_textView.backgroundColor = [UIColor clearColor];
    
    self.m_textView.delegate = self;
    self.m_textView.textColor = [ImUtils colorWithHexString:@"262626"];
    self.m_textView.font = [UIFont fontWithName:@"STHeitiTC-Light" size:15.0f];
    self.m_textView.backgroundColor = [UIColor clearColor];
    
    [view addSubview:m_textView];
    [self.view addSubview:view];
    
    UIView *separatorViewTop = [[UIView alloc] initWithFrame:CGRectMake(0,y,m_frame.size.width, 1)];
    separatorViewTop.backgroundColor = [ImUtils colorWithHexString:@"#e1e1e1"];
    [self.view addSubview:separatorViewTop];
    
    UIView *separatorViewBottom = [[UIView alloc] initWithFrame:CGRectMake(0,y+view.frame.size.height+1,m_frame.size.width, 1)];
    separatorViewBottom.backgroundColor = [ImUtils colorWithHexString:@"#e1e1e1"];
    [self.view addSubview:separatorViewBottom];
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
    CGFloat y = 172;
    if (m_isIOS7) {
        y += 64;
    }
    self.m_remarkLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-30,y, 30, 12)];
    self.m_remarkLabel.textAlignment = NSTextAlignmentCenter;
    self.m_remarkLabel.text = [NSString stringWithFormat:@"%d", LIMIT_CHARACTOR_NUM];
    self.m_remarkLabel.textColor = [ImUtils colorWithHexString:@"808080"];
    self.m_remarkLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:11.0f];
    self.m_remarkLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.m_remarkLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
