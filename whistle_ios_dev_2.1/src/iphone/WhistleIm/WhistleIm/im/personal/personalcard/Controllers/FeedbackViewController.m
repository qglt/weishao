//
//  FeedbackViewController.m
//  WhistleIm
//
//  Created by liuke on 13-9-29.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "FeedbackViewController.h"
#import "FeedbackView.h"
#import "EmotionView.h"
#import "BizBridge.h"
#import "Whistle.h"
#import "FeedbackManager.h"
#import "ImUtils.h"
#import "ImageUtil.h"
#import "OtherManager.h"
#import "NBNavigationController.h"
#import "NetworkBrokenAlert.h"
#import "CommonRespondView.h"

#define LEFT_ITEM_TAG 2000
#define RIGHT_ITEM_TAG 3000


@interface FeedbackViewController ()
<SendFeedbackDelegate>
{
    FeedbackView* _view;
    FeedbackManager* _feedbackMan;
    NSArray* _emotion_arr;// = {@"喜欢", @"不错", @"一般", @"不好", @"讨厌"};
//    MBProgressHUD *HUD;
    BOOL _isSendSuccess;
}

@end

@implementation FeedbackViewController

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
    _emotion_arr = [[NSArray alloc] initWithObjects:@"喜欢", @"不错", @"一般", @"不好", @"讨厌", nil];
    _feedbackMan = [[FeedbackManager alloc] init:nil];
    _feedbackMan.delegate = self;
    self.view.backgroundColor = [ImUtils colorWithHexString:@"#F0F0F0"];

    _view = [[FeedbackView alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    [[self view] addSubview:_view];
    [self createNavigationBar:YES];
}

- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:@"send" andLeftTitle:@"意见反馈" andRightTitle:nil andNeedCreateSubViews:needCreate];
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
    
    [self sendButtonPressed:button];
}

- (void) sendButtonPressed:(id) sender
{
    NSLog(@"send feedback");
    NSString* content = [_view getContent];
    content = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (content && [content length] > 0) {
        
        [_view endEditing];
        enum EMOTION e = [_view getEmotion];

        [[OtherManager shareInstance] getFeedback:content WithEmotion:[_emotion_arr objectAtIndex:e] withCallback:^(NSString *info) {
            [_feedbackMan sendContent:info];
        }];
        
    } else {
        [CommonRespondView respond:@"请输入内容"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    _view = nil;
}

- (void) sucessed
{
    [CommonRespondView respond:@"发送成功"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popToRootViewControllerAnimated:YES];
    });
}

- (void) failure:(NSData *)data WithError:(NSError *)error
{
    [CommonRespondView respond:@"发送失败"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createNavigationBar:NO];
}

@end
