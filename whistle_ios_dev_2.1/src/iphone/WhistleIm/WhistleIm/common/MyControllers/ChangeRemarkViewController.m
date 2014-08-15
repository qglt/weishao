//
//  ChangeRemarkViewController.m
//  WhistleIm
//
//  Created by 管理员 on 13-9-30.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "ChangeRemarkViewController.h"
#import "Whistle.h"
#import "FriendInfo.h"
#import "NetworkBrokenAlert.h"
#import "GetFrame.h"
#import "JSONObjectHelper.h"
#import "NBNavigationController.h"
#import "RosterManager.h"
#import "ImUtils.h"
#import "CommonRespondView.h"
#define LIMIT_CHARACTOR_NUM 12
#define NAME_CHARACTOR_NUM 50

#define LEFT_ITEM_TAG 2000
#define RIGHT_ITEM_TAG 3000

@interface ChangeRemarkViewController ()
<UITextViewDelegate>
{
    CGRect m_frame;
    UITextView * m_textView;
    UILabel * m_remarkLabel;
    WhistleCommandCallbackType m_changeRemarkCallBack;
    BOOL m_isIOS7;
    BOOL m_is4Inch;
}

@property (nonatomic, strong) UITextView * m_textView;
@property (nonatomic, strong) UILabel * m_remarkLabel;
@property (nonatomic, strong) WhistleCommandCallbackType m_changeRemarkCallBack;





@end

@implementation ChangeRemarkViewController

@synthesize m_textView;
@synthesize m_remarkLabel;

@synthesize m_friendInfo;

@synthesize m_changeRemarkCallBack;

@synthesize m_isChangeMoodWords;

@synthesize  m_isChangeNickName;

@synthesize m_isChangeFriendMark;

@synthesize m_title;

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
//    if (m_isChangeNickName) {
//        self.title = @"昵称";
//    } else if (m_isChangeMoodWords){
//        self.title = @"签名档";
//    } else if (m_isChangeFriendMark) {
//        self.title = @"备注";
//    }
//    
//    self.m_title = self.title;

    m_frame = [[UIScreen mainScreen] bounds];
    m_isIOS7 = [[GetFrame shareInstance] isIOS7Version];
    m_is4Inch = [[GetFrame shareInstance] is4InchScreen];
    self.view.backgroundColor = [ImUtils colorWithHexString:@"#F0F0F0"];


    [self createRemarkTextView];
    [self createLimitLabel];
    [self createNavigationBar:YES];
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
    [self rightBarButtonPressed:nil];
}

- (void)rightBarButtonPressed:(id)sender
{
    if ([NetworkBrokenAlert isNetworkBrokenAndShowTip]) {
        return;
    }
    [self.m_textView resignFirstResponder];
    
    if (m_isChangeNickName || m_isChangeMoodWords) {
        [self changeMoodWordsToServer];
    } else {
        [self sendRemarkToServer];
    }
}

- (void)changeMoodWordsToServer
{
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
 
    if (m_isChangeNickName) {
        [data setValue:self.m_textView.text forKey:KEY_NICK_NAME];
        [[RosterManager shareInstance] storeMyNickName:self.m_textView.text withCallback:^(BOOL success) {
            if (success) {
                [CommonRespondView respond:@"操作成功"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            } else {
                [CommonRespondView respond:@"操作失败"];
            }
        }];
    } else if (m_isChangeMoodWords){
        [data setValue:self.m_textView.text forKey:KEY_MOOD_WORDS];
        [[RosterManager shareInstance] storeMyMoodWord:self.m_textView.text  withCallback:^(BOOL success) {
            if (success) {
                [CommonRespondView respond:@"操作成功"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            } else {
                [CommonRespondView respond:@"操作失败"];
            }
        }];
    }
}

- (void)sendRemarkToServer
{
    [[RosterManager shareInstance] setBuddyRemark:self.m_friendInfo withRemark:self.m_textView.text withListener:^(BOOL success) {
        if (success) {
            [CommonRespondView respond:@"操作成功"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        } else {
            [CommonRespondView respond:@"操作失败"];
        }
    }];
}

- (void)createRemarkTextView
{
    CGFloat y = 20;
    if (m_isIOS7) {
        y += 64;
    }
    self.m_textView = [[UITextView alloc] initWithFrame:CGRectMake(8.0f, y, m_frame.size.width - 16, 100)];
    self.m_textView.backgroundColor = [UIColor clearColor];
    [self.m_textView becomeFirstResponder];
    
    if (m_isChangeNickName) {
        self.m_textView.text = self.m_friendInfo.nickName;
    } else if (m_isChangeMoodWords) {
        self.m_textView.text = self.m_friendInfo.moodWords;
    } else if (m_isChangeFriendMark) {
        self.m_textView.text = [[RosterManager shareInstance] getShownameByIdentity:self.m_friendInfo];
    }
    
    self.m_textView.layer.cornerRadius = 5.0f;
    self.m_textView.delegate = self;
    self.m_textView.textColor = [UIColor whiteColor];
    NSUInteger length = [self.m_textView.text length];
    [self.m_textView setSelectedRange:NSMakeRange(0, length)];
    
    UIImageView * BGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8.0f, y, m_frame.size.width - 16, 100)];
    BGImageView.image = [UIImage imageNamed:@"moodwordsImage.png"];
    
    [self.view addSubview:BGImageView];
    [self.view addSubview:self.m_textView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (m_isChangeNickName || m_isChangeFriendMark) {
        if (range.location >= LIMIT_CHARACTOR_NUM) {
            return NO;
        } else {
            return YES;
        }
    } else {
        if (range.location >= NAME_CHARACTOR_NUM) {
            return NO;
        } else {
            return YES;
        }
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (m_isChangeNickName || m_isChangeFriendMark) {
        NSInteger limitNumber = LIMIT_CHARACTOR_NUM - textView.text.length;
        if (limitNumber <= 0) {
            limitNumber = 0;
        }
        self.m_remarkLabel.text = [NSString stringWithFormat:@"可输入%d字", limitNumber];
    } else {
        
        NSInteger limitNumber = NAME_CHARACTOR_NUM - textView.text.length;
        if (limitNumber <= 0) {
            limitNumber = 0;
        }
        self.m_remarkLabel.text = [NSString stringWithFormat:@"可输入%d字", limitNumber];
    }
}

- (void)createLimitLabel
{
    CGFloat y = 190;
    if (!isIOS7) {
        y -= 60.0f;
    }
    self.m_remarkLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, y, 100, 30)];
    self.m_remarkLabel.textAlignment = NSTextAlignmentCenter;
    
    NSString * text = self.m_textView.text;
    
    if (m_isChangeNickName || m_isChangeFriendMark) {
        self.m_remarkLabel.text = [NSString stringWithFormat:@"可输入%d字", LIMIT_CHARACTOR_NUM - [text length]];
    } else {
        self.m_remarkLabel.text = [NSString stringWithFormat:@"可输入%d字", NAME_CHARACTOR_NUM - [text length]];
    }
    self.m_remarkLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.m_remarkLabel];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.m_textView resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
