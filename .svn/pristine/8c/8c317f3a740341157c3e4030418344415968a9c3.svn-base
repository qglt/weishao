//
//  CrowdSystemViewController.m
//  WhistleIm
//
//  Created by liuke on 13-11-6.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "CrowdSystemViewController.h"
#import "CrowdSystemView.h"
#import "GetFrame.h"
#import "SystemMessageInfo.h"
#import "Whistle.h"
#import "CrowdManager.h"
#import "CrowdInfo.h"
#import "ImUtils.h"
#import "ResultInfo.h"
#import "MBProgressHUD.h"
#import "RosterManager.h"
#import "FriendInfo.h"
#import "PersonCardViewController.h"
#import "SystemMsgManager.h"
#import "NBNavigationController.h"
#import "CommonRespondView.h"

#define LEFT_ITEM_TAG 2000

@interface CrowdSystemViewController ()<CrowdSystemDelegata, NBNavigationControllerDelegate>
{
    CrowdSystemView* view;
    MBProgressHUD* HUD;
    BOOL isOpSuccess_;
}
@end

@implementation CrowdSystemViewController

@synthesize systemMsgInfo = _systemMsgInfo;

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
    [self createNavigationBar:YES];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [ImUtils colorWithHexString:@"#F0F0F0"];

    CGFloat y = 0;
    CGFloat h = 44;
    if ([[GetFrame shareInstance] isIOS7Version]) {
        y = 64.0f;
        h = 0;
    }
    view = [[CrowdSystemView alloc] initWithFrame:CGRectMake(0, y, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - y - h)];
    view.name = self.systemMsgInfo.crowd_name;
    NSDictionary* dd = [self.systemMsgInfo getCrowdContent];
    [view setContentDictionary:dd];
    view.reason = self.systemMsgInfo.reason;
    // 20131212 - li
    view.crowd_no = [((CrowdInfo*)self.systemMsgInfo.extraObject) getCrowdID];
    view.category = self.systemMsgInfo.category;
    view.photo = [((CrowdInfo*)self.systemMsgInfo.extraObject) getCrowdIcon];
    view.isAgree = self.systemMsgInfo.isAgree;
    [view createViewIsReason: nil != view.reason isButton: ([self.systemMsgInfo isInviteOrAuthen] && (!self.systemMsgInfo.isRead || self.systemMsgInfo.crowdHasDismiss)) IsNeedAnswer:[self.systemMsgInfo isAnswer]];
    [self.view addSubview:view];
    view.crowdSystemDelegate = self;
    if (![self.systemMsgInfo isInviteOrAuthen]) {//没有按钮的界面直接设置为已读
        [self markCrowdMsgRead];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 20131212 - li
- (void) pushAgreeBtn
{
    if ([ CROWD_SYS_MSG_INVITED_BY_CROWD isEqualToString: [self systemMsgInfo].msgType] ) {

        [self.systemMsgInfo answerInviteByCrowd:YES WithCallback:^(BOOL isSuccuess){
            if (isSuccuess) {
                [CommonRespondView respond:@"操作成功"];
                [self markCrowdMsgRead];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }else{
                [CommonRespondView respond:@"操作失败"];
            }
            
        }];
        //管理员邀请你加入群
    }else if ([CROWD_SYS_MSG_APPLY_AUTHEN isEqualToString:[self systemMsgInfo].msgType]){
        //你回答同意别人加入群
        [self.systemMsgInfo answerApplyJonCrowd:YES withCallback:^(BOOL isApply) {
            if (isApply) {
                [CommonRespondView respond:@"操作成功"];
                [self markCrowdMsgRead];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }else{
                [CommonRespondView respond:@"操作失败"];
            }
        }];
    }
    
}

// 20131212 - li
- (void) pushRejectBtn
{
    if ([ CROWD_SYS_MSG_INVITED_BY_CROWD isEqualToString: [self systemMsgInfo].msgType] ) {
        [self.systemMsgInfo answerInviteByCrowd:NO WithCallback:^(BOOL isInvite){
            if (isInvite) {
                [CommonRespondView respond:@"操作成功"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
                [self markCrowdMsgRead];
            }else{
                [CommonRespondView respond:@"操作失败"];
            }
        }];
    }else if ([CROWD_SYS_MSG_APPLY_AUTHEN isEqualToString:[self systemMsgInfo].msgType]){
//        //你回答不同意别人加入群
        [self.systemMsgInfo answerApplyJonCrowd:NO withCallback:^(BOOL isApply) {
            if (isApply) {
                [CommonRespondView respond:@"操作成功"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
                [self markCrowdMsgRead];
            }else{
                [CommonRespondView respond:@"操作失败"];
            }
        }];
    }
}
//
//
- (void) clickLabel:(NSString *)jid
{
    PersonCardViewController* controller = [[PersonCardViewController alloc] init];
    controller.m_jid = jid;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createNavigationBar:NO];
}

- (void) leftNavigationBarButtonPressed:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createNavigationBar:(BOOL)needCreate
{
    NBNavigationController * nav = (NBNavigationController *)self.navigationController;
    [nav setNavigationController:self leftBtnType:@"back" andRightBtnType:nil andLeftTitle:NSLocalizedString(@"system_crowd", nil) andRightTitle:nil andNeedCreateSubViews:needCreate];
}



- (void) markCrowdMsgRead
{
//    self.systemMsgInfo.isRead = YES;
    [[SystemMsgManager shareInstance] markSystemRead:self.systemMsgInfo withCallback:^(BOOL isSuccess) {
        
    }];
}

@end
