//
//  ChangeTextInfoViewController.m
//  WhistleIm
//
//  Created by 管理员 on 14-2-11.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "ChangeTextInfoViewController.h"
#import "NBNavigationController.h"
#import "ImUtils.h"
#import "CrowdManager.h"
#import "DiscussionManager.h"
#import "RosterManager.h"
#import "NetworkBrokenAlert.h"
#import "CommonRespondView.h"

@interface ChangeTextInfoViewController ()
<UITextViewDelegate>
{
    CGRect m_frame;
    UITextView * m_textView;
    UILabel * m_limitWordsLabel;
    
    NSInteger m_remainderNum;
}

@property (nonatomic, strong) UITextView * m_textView;
@property (nonatomic, strong) UILabel * m_limitWordsLabel;

@end

@implementation ChangeTextInfoViewController

@synthesize m_title;
@synthesize m_placeHolder;
@synthesize m_numberOfWords;
@synthesize m_type;

@synthesize m_textView;
@synthesize m_limitWordsLabel;
@synthesize m_crowdSessionID;
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
    [self setBasicCondition];
    [self createNavigationBar:YES];
    [self regNotification];
    [self createTextView];
    [self createLimitLabel];
}

- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:@"finish" andLeftTitle:self.m_title andRightTitle:nil andNeedCreateSubViews:needCreate];
}

- (void)leftNavigationBarButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightNavigationBarButtonPressed:(UIButton *)button
{
    if ([NetworkBrokenAlert isNetworkBrokenAndShowTip]) {
        return;
    }
    
    if (m_remainderNum >= 0) {
        [self.m_textView resignFirstResponder];
        [self sendChangeRequest];
    } else {
        [self createAlertViewWithMessage:@"字数超出上限"];
    }
}

- (void)createAlertViewWithMessage:(NSString *)message
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
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

- (void)sendChangeRequest
{
    if ([self.m_type isEqualToString:@"crowdName"]) {
        [self changeCrowdName];
    } else if ([self.m_type isEqualToString:@"crowdRemark"]) {
        [self changeCrowdRemark];
    } else if ([self.m_type isEqualToString:@"crowdNotice"]) {
        [self changeCrowdNotice];
    } else if ([self.m_type isEqualToString:@"crowdIntroduce"]) {
        [self changeCrowdDescription];
    } else if ([self.m_type isEqualToString:@"groupName"]) {
        [self changeGroupName];
    } else if ([self.m_type isEqualToString:@"friendRemark"]) {
        [self changeFriendRemark];
    } else if ([self.m_type isEqualToString:@"myMoodWords"]) {
        [self changeMoodWords];
    } else if ([self.m_type isEqualToString:@"myNickName"]) {
        [self changeNickName];
    }
}

// 群名称
- (void)changeCrowdName
{
    NSString * changedStr = [self.m_textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [[CrowdManager shareInstance] setCrowdName:self.m_crowdSessionID name:changedStr callback:^(BOOL success) {
        NSLog(@"change crowd name success == %d", success);
        [self showResultWithState:success];
    }];
}

// 群公告
- (void)changeCrowdNotice
{
    NSString * changedStr = [self.m_textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [[CrowdManager shareInstance] setCrowdAnnounce:self.m_crowdSessionID announce:changedStr callback:^(BOOL success) {
        NSLog(@"change crowd notice success == %d", success);
        [self showResultWithState:success];
    }];
}

// 群描述
- (void)changeCrowdDescription
{
    NSString * changedStr = [self.m_textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    [[CrowdManager shareInstance] setCrowdDescription:self.m_crowdSessionID description:changedStr callback:^(BOOL success) {
        NSLog(@"change crowd description success == %d", success);
        [self showResultWithState:success];
    }];
}

// 群备注
- (void)changeCrowdRemark
{
    NSString * changedStr = [self.m_textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    [[CrowdManager shareInstance] setCrowdRemark:self.m_crowdSessionID remark:changedStr callback:^(BOOL success) {
        NSLog(@"change crowd remark success == %d", success);
        [self showResultWithState:success];
    }];
}

// 讨论组名
- (void)changeGroupName
{
    NSString * changedStr = [self.m_textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    [[DiscussionManager shareInstance] setDiscussionName:self.m_crowdSessionID name:changedStr callback:^(BOOL success) {
        NSLog(@"change group name success == %d", success);
        [self showResultWithState:success];
    }];
}

// 好友备注
- (void)changeFriendRemark
{
    NSString * changedStr = [self.m_textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [[RosterManager shareInstance] setBuddyRemark:self.m_friendInfo withRemark:changedStr withListener:^(BOOL success) {
        NSLog(@"change friend remark success == %d", success);
        [self showResultWithState:success];
    }];
}

// 个性签名
- (void)changeMoodWords
{
    NSString * changedStr = [self.m_textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [[RosterManager shareInstance] storeMyMoodWord:changedStr  withCallback:^(BOOL success) {
        NSLog(@"change my moodWords success == %d", success);
        [self showResultWithState:success];
    }];
}

// 昵称
- (void)changeNickName
{
    NSString * changedStr = [self.m_textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [[RosterManager shareInstance] storeMyNickName:changedStr withCallback:^(BOOL success) {
        NSLog(@"change my nickName success == %d", success);
        [self showResultWithState:success];
    }];
}

- (void)popViewController
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)showResultWithState:(BOOL)success
{
    if (success) {
        [self popViewController];
        [CommonRespondView respond:@"修改成功"];
    } else {
        [CommonRespondView respond:@"修改失败"];
    }
}

- (void)createTextView
{
    CGFloat y = 0.0f;
    if (isIOS7) {
        y += 64.0f;
    }
    
    CGFloat height = m_frame.size.height - 64 - 50;
    self.m_textView = [[UITextView alloc] initWithFrame:CGRectMake(10, y, m_frame.size.width - 20, height)];
    self.m_textView.backgroundColor = [UIColor clearColor];
    self.m_textView.delegate = self;
    self.m_textView.text = self.m_placeHolder;
    [self.m_textView becomeFirstResponder];
    self.m_textView.font = [UIFont systemFontOfSize:15.0f];
    self.m_textView.textColor = [UIColor colorWithRed:110.0f / 255.0f green:110.0f / 255.0f  blue:110.0f / 255.0f  alpha:1.0f];
    [self.view addSubview:self.m_textView];
}

- (void)createLimitLabel
{
    CGFloat y = m_frame.size.height - 40;
    if (isIOS7 == NO) {
        y -= 64.0f;
    }
    self.m_limitWordsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, y, m_frame.size.width - 20, 30)];
    NSString * text = [NSString stringWithFormat:@"%d", self.m_numberOfWords - [self.m_textView.text length]];
    self.m_limitWordsLabel.text = text;
    self.m_limitWordsLabel.textAlignment = NSTextAlignmentRight;
    self.m_limitWordsLabel.backgroundColor = [UIColor clearColor];
    NSInteger limitNumber = self.m_numberOfWords - self.m_textView.text.length;
    if (limitNumber < 0) {
        self.m_limitWordsLabel.textColor = [UIColor redColor];
    } else {
        self.m_limitWordsLabel.textColor = [UIColor colorWithRed:110.0f / 255.0f green:110.0f / 255.0f  blue:110.0f / 255.0f  alpha:1.0f];
    }
    [self.view addSubview:self.m_limitWordsLabel];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (!isIOS7) {
        if (range.location >= self.m_numberOfWords) {
            return NO;
        } else {
            return YES;
        }
    } else {
        return YES;
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSInteger limitNumber = self.m_numberOfWords - textView.text.length;
    NSString * text = [NSString stringWithFormat:@"%d", limitNumber];
    self.m_limitWordsLabel.text = text;
    
    if (limitNumber < 0) {
        self.m_limitWordsLabel.textColor = [UIColor redColor];
    } else {
        self.m_limitWordsLabel.textColor = [UIColor colorWithRed:110.0f / 255.0f green:110.0f / 255.0f  blue:110.0f / 255.0f  alpha:1.0f];
    }
    
    m_remainderNum = limitNumber;
}

- (void)regNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

#pragma mark - notification handler
- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect endKeyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSLog(@"endKeyboardRect == %@", NSStringFromCGRect(endKeyboardRect));
    
    [UIView animateWithDuration:duration animations:^{
        CGRect frame = self.m_limitWordsLabel.frame;
        if (isIOS7) {
            frame.origin.y = endKeyboardRect.origin.y - 40;

        } else {
            frame.origin.y = endKeyboardRect.origin.y - 40 - 64;
        }
        self.m_limitWordsLabel.frame = frame;
        
        CGFloat y = frame.origin.y;
        CGRect textFrame = self.m_textView.frame;
        if (isIOS7) {
            textFrame.size.height = y - 64.0f - 10;
        } else {
            textFrame.size.height = y - 10;
        }
        self.m_textView.frame = textFrame;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

@end
