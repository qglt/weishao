//
//  AnswerRequestViewController.m
//  WhistleIm
//
//  Created by 管理员 on 13-11-1.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "AnswerRequestViewController.h"
#import "GetFrame.h"
#import "SystemMessageInfo.h"
#import "FriendInfo.h"
#import "RosterManager.h"
#import "Whistle.h"
#import "BizlayerProxy.h"
#import "NBNavigationController.h"
#import "SystemMsgManager.h"
#import "ImUtils.h"

#define LEFT_ITEM_TAG 2000

#define AGREE_BUTTON_TAG 4000
#define AGREE_AND_ADD_BUTTON_TAG 4001
#define REJECT_BUTTON_TAG 4002


@interface AnswerRequestViewController ()
<UITextViewDelegate>
{
    CGRect m_frame;
    BOOL m_isIOS7;
    BOOL m_is4Inch;
    
    UIView * m_BGView;
}

@property (nonatomic, strong) UIView * m_BGView;
@property (nonatomic, strong) UILabel * m_textView;


@end

@implementation AnswerRequestViewController

@synthesize m_systemMessageInfo;
@synthesize m_friendInfo;
@synthesize m_BGView;
@synthesize m_textView;

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
    
    if (self.m_friendInfo) {
        [self createViews];
    } else {
        // 20131212 - li
        //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //            [[WHISTLE_APPPROXY whistleRosterManager] getFriendInfoByJid: self.m_systemMessageInfo.jid checkStrange:YES WithCallback:^(FriendInfo* data){
        //                dispatch_async(dispatch_get_main_queue(), ^{
        //                    self.m_friendInfo = data;
        //                    [self createViews];
        //                });
        //            }];
        //
        //        });
    }
}

- (void)createViews
{
    [self setBaseCondition];
    [self createBGView];
    [self createNavigationBar:YES];
    [self createPersonImageView];
    [self createNameLabel];
    [self createOrganizationLabel];
    [self createSendInfoTextView];
    [self createButtons];
}

- (void)setBaseCondition
{
    m_frame = self.view.bounds;
    m_isIOS7 = [[GetFrame shareInstance] isIOS7Version];
    m_is4Inch = [[GetFrame shareInstance] is4InchScreen];
    self.view.backgroundColor = [ImUtils colorWithHexString:@"#F0F0F0"];
}

#pragma mark -
#pragma mark - BarButtonItem
- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:nil andLeftTitle:NSLocalizedString(@"system_list", nil) andRightTitle:nil andNeedCreateSubViews:needCreate];
}

- (void)leftNavigationBarButtonPressed:(UIButton *)button;
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createBGView
{
    CGFloat y = 0;
    CGFloat height = m_frame.size.height;
    if (m_isIOS7) {
        y += 64;
        if (m_is4Inch) {
            height = m_frame.size.height - 64;
        } else {
            height = m_frame.size.height - 64;
        }
    } else {
        height = m_frame.size.height - 44;
    }
    
    self.m_BGView = [[UIView alloc] initWithFrame:CGRectMake(0, y, m_frame.size.width, height)];
    self.m_BGView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.m_BGView];
}

- (void)createPersonImageView
{
    CGFloat y = 15;
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(132.5, y, 55, 55)];
    imageView.clipsToBounds = YES;
    UIImage * image = [self getHeaderImage];
    imageView.image = image;
    imageView.layer.cornerRadius = 27.5f;
    imageView.layer.masksToBounds = YES;
    [self.m_BGView addSubview:imageView];
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
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, y, self.view.bounds.size.width, 15)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = self.m_friendInfo.showName;
    label.font = [UIFont fontWithName:@"STHeitiTC-Light" size:15.0f];
    label.textColor = [ImUtils colorWithHexString:@"#262626"];
    label.backgroundColor = [UIColor clearColor];
    [self.m_BGView addSubview:label];
    
    if ([self.m_friendInfo.identity isEqualToString:@"biz.vcard.teacher"]) {
        CGSize textSize = [self.m_friendInfo.name sizeWithFont:[UIFont fontWithName:@"STHeitiTC-Light" size:15.0f] constrainedToSize:CGSizeMake(self.view.bounds.size.width, 10000) lineBreakMode:NSLineBreakByWordWrapping];
        NSLog(@"textSize == %@", NSStringFromCGSize(textSize));
        UIImageView * starImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - textSize.width)/2-15-10, y, 15, 15)];
        starImageView.image = [UIImage imageNamed:@"identity_teacher_new.png"];
        starImageView.backgroundColor = [UIColor clearColor];
        [self.m_BGView addSubview:starImageView];
    }
}

-(void)createOrganizationLabel
{
    CGFloat y = 97;
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, y,  self.view.bounds.size.width, 12)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = self.m_friendInfo.organization_id;
    label.font = [UIFont fontWithName:@"STHeitiTC-Light" size:12.0f];
    label.textColor = [ImUtils colorWithHexString:@"#808080"];
    label.backgroundColor = [UIColor clearColor];
    [self.m_BGView addSubview:label];
}

- (void)createSendInfoTextView
{
    CGFloat y = 115;
    m_textView = [[UILabel alloc] initWithFrame:CGRectMake(0, y,  self.view.bounds.size.width, 12)];
    m_textView.textAlignment = NSTextAlignmentCenter;
    m_textView.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"reason", nil),self.m_systemMessageInfo.extraInfo.length>0?self.m_systemMessageInfo.extraInfo:@"无"];
    m_textView.font = [UIFont fontWithName:@"STHeitiTC-Light" size:12.0f];
    [m_textView sizeToFit];
    
    m_textView.frame = CGRectMake(0, y,  self.view.bounds.size.width, m_textView.frame.size.height);
    m_textView.textColor = [ImUtils colorWithHexString:@"#808080"];
    m_textView.backgroundColor = [UIColor clearColor];
    [self.m_BGView addSubview:m_textView];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.m_textView resignFirstResponder];
}

- (void)createButtons
{
    UIButton * agreeAndAddBtn = [self createButtonsWithFrame:CGRectMake(0, 172,self.view.bounds.size.width, 41) andTitle:NSLocalizedString(@"agree_add_friend", nil)andTag:AGREE_AND_ADD_BUTTON_TAG];
    [self.m_BGView addSubview:agreeAndAddBtn];
    UIButton * agreeBtn = [self createButtonsWithFrame:CGRectMake(0, 221,self.view.bounds.size.width, 41) andTitle:NSLocalizedString(@"agree", nil)andTag:AGREE_BUTTON_TAG];
    [self.m_BGView addSubview:agreeBtn];
    
    UIButton * rejectBtn = [self createButtonsWithFrame:CGRectMake(0, 270,self.view.bounds.size.width, 41) andTitle:NSLocalizedString(@"reject", nil) andTag:REJECT_BUTTON_TAG];
    [self.m_BGView addSubview:rejectBtn];
}

- (UIButton *)createButtonsWithFrame:(CGRect)frame andTitle:(NSString *)title andTag:(NSUInteger)tag
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[ImUtils createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [button setBackgroundImage:[ImUtils createImageWithColor:[ImUtils colorWithHexString:@"#cccccc"]] forState:UIControlStateHighlighted];
    
//    [button setFont:[UIFont fontWithName:@"STHeitiTC-Light" size:15.0f]];
    button.titleLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:15.0f];
    [button setTitleColor:[ImUtils colorWithHexString:@"#262626"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [button setTitle:title forState:UIControlStateNormal];
    button.frame = frame;
    button.tag = tag;
    
    [button addTarget:self action:@selector(functionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *separatorViewTop = [[UIView alloc] initWithFrame:CGRectMake(0,0, button.frame.size.width, 1)];
    separatorViewTop.backgroundColor = [ImUtils colorWithHexString:@"#e1e1e1"];
    [button addSubview:separatorViewTop];
    
    UIView *separatorViewBottom = [[UIView alloc] initWithFrame:CGRectMake(0,40, button.frame.size.width, 1)];
    separatorViewBottom.backgroundColor = [ImUtils colorWithHexString:@"#e1e1e1"];
    [button addSubview:separatorViewBottom];
    
    return button;
}

- (void)functionButtonPressed:(id)sender
{
    UIButton * button = (UIButton *)sender;
    if (button.tag == AGREE_AND_ADD_BUTTON_TAG) {
        [self agreeRequestAndAddTheFriend];
    } else if (button.tag == AGREE_BUTTON_TAG) {
        [self agreeRequest];
    } else if (button.tag == REJECT_BUTTON_TAG) {
        [self rejectRequest];
    }
}

- (void)responseToRequest:(BOOL)act
{
    [[SystemMsgManager shareInstance] ackAddFriendInvite:self.m_systemMessageInfo.jid isAgree:act withCallback:^(BOOL success) {
        
    }];
}

- (void)addFriend
{
    [[SystemMsgManager shareInstance] addFriend:self.m_systemMessageInfo.jid withMsg:self.m_textView.text withCallback:^(BOOL success) {
        
    }];
}

- (void)agreeRequestAndAddTheFriend
{
    [self responseToRequest:YES];
    [self addFriend];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)agreeRequest
{
    [self responseToRequest:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rejectRequest
{
    [self responseToRequest:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
