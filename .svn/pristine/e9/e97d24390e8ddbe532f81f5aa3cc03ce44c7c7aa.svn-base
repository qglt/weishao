//
//  AgreeToAddFriendViewController.m
//  WhistleIm
//
//  Created by 管理员 on 13-11-20.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "AgreeToAddFriendViewController.h"
#import "GetFrame.h"
#import "FriendInfo.h"
#import "Whistle.h"
#import "RosterManager.h"
#import "SystemMessageInfo.h"
#import "NBNavigationController.h"
#import "ImUtils.h"
#import "PrivateTalkViewController.h"

#define LEFT_ITEM_TAG 2000

@interface AgreeToAddFriendViewController ()
{
    BOOL m_isIOS7;
    
}
@end

@implementation AgreeToAddFriendViewController
@synthesize m_messageInfo;
@synthesize m_friendInfo;

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
    m_isIOS7 = [[GetFrame shareInstance] isIOS7Version];
    self.view.backgroundColor = [ImUtils colorWithHexString:@"#F0F0F0"];

    [self createNavigationBar:YES];
    
    [self createPersonImageView];
    [self createNameLabel];
    [self createOrganizationLabel];
    [self createSystemMessageLabel];
    if ([m_messageInfo.msgType isEqualToString:@"agree"]) {
        [self createSendButton];
    }else
    {
        [self createReasonTextView];
    }
}

#pragma mark -
#pragma mark - BarButtonItem
- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:nil andLeftTitle:NSLocalizedString(@"system_list", nil) andRightTitle:nil andNeedCreateSubViews:needCreate];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self createNavigationBar:NO];
}

- (void)leftNavigationBarButtonPressed:(UIButton *)button;
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createPersonImageView
{
    CGFloat y = 15;
    if (m_isIOS7) {
        y += 64;
    }
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(132.5,y, 55, 55)];
    imageView.clipsToBounds = YES;
    UIImage * image = [self getHeaderImage];
    imageView.image = image;
    imageView.layer.cornerRadius = 27.5f;
    imageView.layer.masksToBounds = YES;
    [self.view addSubview:imageView];
    
    //biz.vcard.student
//    NSLog(@"self.m_friendInfo.identity == %@", self.m_friendInfo.identity);
//    if ([self.m_friendInfo.identity isEqualToString:IDENT_TEACHER]) {
//        y = 3;
//        if (m_isIOS7) {
//            y += 64;
//        }
//        UIImageView * starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(42, y, 62, 62)];
//        starImageView.image = [UIImage imageNamed:@"info_teacher.png"];
//        starImageView.backgroundColor = [UIColor clearColor];
//        [self.view addSubview:starImageView];
//    }
}

- (UIImage *)getHeaderImage
{
    UIImage * image = nil;
    image = [UIImage imageWithContentsOfFile:self.m_friendInfo.head];
    if (image == nil) {
        if ([self.m_friendInfo.sexShow isEqualToString:SEX_GIRL]) {
            image = [UIImage imageNamed:@"identity_woman.png"];
        } else {
            image = [UIImage imageNamed:@"identity_man_new.png"];
        }
    }
    
    return image;
}

- (void)createNameLabel
{
    CGFloat y = 76;
    if (m_isIOS7) {
        y += 64;
    }
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, y,self.view.bounds.size.width, 15)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = self.m_friendInfo.showName;
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
    CGFloat y = 103;
    if (m_isIOS7) {
        y += 64;
    }
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, y,  self.view.bounds.size.width, 12)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = self.m_friendInfo.organization_id;
    [[RosterManager shareInstance] getFriendInfoByJid:self.m_friendInfo.jid checkStrange:YES WithCallback:^(FriendInfo *info) {
        [label performSelectorOnMainThread:@selector(setText:) withObject:info.organization_id waitUntilDone:YES];
    }];
    label.font = [UIFont fontWithName:@"STHeitiTC-Light" size:12.0f];
    label.textColor = [ImUtils colorWithHexString:@"#808080"];
    label.backgroundColor = [UIColor clearColor];
    [self.view addSubview:label];
}

-(void)createSystemMessageLabel
{
    CGFloat y = 145;
    if (m_isIOS7) {
        y += 64;
    }
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, y, self.view.bounds.size.width, 15)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = self.m_messageInfo.info;
    label.font = [UIFont fontWithName:@"STHeitiTC-Light" size:15.0f];
    label.textColor = [ImUtils colorWithHexString:@"#262626"];
    label.backgroundColor = [UIColor clearColor];
    [self.view addSubview:label];
}

- (void)createReasonTextView
{
    CGFloat y = 170;
    if (m_isIOS7) {
        y += 64;
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, y,  self.view.bounds.size.width, 12)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"reason", nil),self.m_messageInfo.extraInfo.length>0?self.m_messageInfo.extraInfo:@"无"];
    label.font = [UIFont fontWithName:@"STHeitiTC-Light" size:12.0f];
    [label sizeToFit];
    
    label.frame = CGRectMake(0, y,  self.view.bounds.size.width, label.frame.size.height);
    label.textColor = [ImUtils colorWithHexString:@"#808080"];
    label.backgroundColor = [UIColor clearColor];
    [self.view addSubview:label];
}

-(void)createSendButton
{
    CGFloat y = 170;
    if (m_isIOS7) {
        y += 64;
    }
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, y, self.view.bounds.size.width, 41);
    [button setBackgroundImage:[ImUtils createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [button setBackgroundImage:[ImUtils createImageWithColor:[ImUtils colorWithHexString:@"#cccccc"]] forState:UIControlStateHighlighted];
    
//    [button setFont:[UIFont fontWithName:@"STHeitiTC-Light" size:15.0f]];
    button.titleLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:15.0f];
    [button setTitleColor:[ImUtils colorWithHexString:@"#262626"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [button setTitle:NSLocalizedString(@"send_message", nil)  forState:UIControlStateNormal];
    [button addTarget:self action:@selector(push2TalkView) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *separatorViewTop = [[UIView alloc] initWithFrame:CGRectMake(0,0, button.frame.size.width, 1)];
    separatorViewTop.backgroundColor = [ImUtils colorWithHexString:@"#e1e1e1"];
    [button addSubview:separatorViewTop];
    
    UIView *separatorViewBottom = [[UIView alloc] initWithFrame:CGRectMake(0,40, button.frame.size.width, 1)];
    separatorViewBottom.backgroundColor = [ImUtils colorWithHexString:@"#e1e1e1"];
    [button addSubview:separatorViewBottom];
    
    [self.view addSubview:button];
}

-(void) push2TalkView
{
    PrivateTalkViewController *controller = [[PrivateTalkViewController alloc] init];
    controller.inputObject = m_friendInfo;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
