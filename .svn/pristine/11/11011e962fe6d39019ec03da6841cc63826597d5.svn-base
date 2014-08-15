////
////  WhistleApplicationProxy.m
////  WhistleIm
////
////  Created by wangchao on 13-6-21.
////  Copyright (c) 2013年 Ruijie. All rights reserved.
////
////
////#import "WhistleAppDelegate.h"
////#import "WhistleApplicationProxy.h"
////#import "AccountManager.h"
////#import "AccountInfo.h"
////#import "BizlayerProxy.h"
////#import "DisscussionManager.h"
////#import "RosterManager.h"
////#import "NoticeManager.h"
////#import "FriendInfo.h"
////#import "Constants.h"
////#import "LocalRecentListManager.h"
////#import "AppMessageManager.h"
////#import "PushMessageManager.h"
////#import "CrowdManager.h"
////#import "ImUtil.h"
////#import "JSONObjectHelper.h"
//#import <QuartzCore/QuartzCore.h>
//
//static BOOL _isChangeUserSegue;
//
//@interface UINavigationBar (myNave)
//- (CGSize)changeHeight:(CGSize)size;
//@end
//
//@implementation UINavigationBar (customNav)
////- (CGSize)sizeThatFits:(CGSize)size {
////    CGSize newSize = CGSizeMake(kScreenWidth,kImTitleBarHeight);
////    return newSize;
////}
//@end
//
//
//@interface WhistleApplicationProxy ()
//
//@property (assign) BOOL rosterReady;
//@property (assign) BOOL noticeReady;
//@property (assign) BOOL appMsgReady;
//
//
//@end
//
//@implementation WhistleApplicationProxy
//
//-(id)initWithWhistleDelegate:(WhistleAppDelegate *)delegate
//{
//    self = [super init];
//    
//    if(self){
//        self.whistleDelegate = delegate;
//        self.whistleBizProxy = [[BizlayerProxy alloc] init];
//        self.whistleAccountManager = [[AccountManager alloc] init];
//        self.whistleRosterManager = [[RosterManager alloc] init];
//        self.whistleLocalRecentListManager = [[LocalRecentListManager alloc] init];
//        self.whistleDisscussionManager = [[DisscussionManager alloc] init];
//        self.whistlePushMessageManager = [[PushMessageManager alloc] init];
//        self.whistleNoticeManager = [[NoticeManager alloc] init];
//        self.whistleAppMessageManager = [[AppMessageManager alloc] init];
//        self.whistleCrowdManager = [[CrowdManager alloc] init];
//        self.rosterReady = NO;
//        self.noticeReady = NO;
//        self.appMsgReady = NO;
//    }
//    
//    return self;
//}
//
//
//
//- (CGRect)statusBarFrameViewRect:(UIView*)view
//{
//    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
//    
//    if(view.window){
//        CGRect statusBarWindowRect = [view.window convertRect:statusBarFrame fromWindow: nil];
//    
//    
//        CGRect statusBarViewRect = [view convertRect:statusBarWindowRect fromView: nil];
//    
//        return statusBarViewRect;
//    }else{
//        CGRect statusBarViewRect = [view convertRect:statusBarFrame fromView: nil];
//        return statusBarViewRect;
//    }
//}
//
//-(void)startWhistle
//{
////    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRosterDone:) name:kRosterDoneNotificationName object:nil];
////    [self.whistleRosterManager initRosterData:^(Roster* data){
////        if (data) {
////            self.rosterReady = YES;
////            [self checkToShowMain];
////        }
////    }];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNoticeDone:) name:kNoticeListReadyNotificationName object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppMsgDone:) name:kAppMessageListReadyNotificationName object:nil];
//    currentApplicationStatus = WhistleStarting;
//    self.mainStoryboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
//    
//    self.whistleDelegate.window.rootViewController = [self.mainStoryboard instantiateInitialViewController];
//    
//        
//}
//
//-(void)onStartSuccessfully
//{
//    currentApplicationStatus = WhistleStarted;
//    
//    [self configAccountManager];
//    
//}
//
//-(void)onStartWithFailure:(NSString *)reason
//{
//    
//}
//
//-(void)configAccountManager
//{
//    void(^listener)(NSArray*) = ^(NSArray *result){
//        [self onAccountManagerConfigDone:result];
//    };
//    
//    [self.whistleAccountManager fetchAccountHistory:listener];
//    
//}
//
//-(void)onAccountManagerConfigDone:(NSArray *)accountHistoryList
//{
//    [self.whistleAccountManager reset];
//    @autoreleasepool {
//        self.whistleAccountManager.historyAccounts = [NSMutableArray arrayWithArray:accountHistoryList];
//    
//    
//    BOOL showLogin = NO;
//    
//    if(self.whistleAccountManager.allowAutoLogin){
//        
//        
//        if([self.whistleAccountManager.historyAccounts count] == 0){
//            
//            showLogin = YES;
//            
//        }else{
//            
//            self.whistleAccountManager.currentAccount = [self.whistleAccountManager.historyAccounts objectAtIndex:0];
//            /*
//             if(!self.whistleAccountManager.currentAccount.autoLogin){
//             showLogin = YES;
//             }
//             */
//            showLogin = YES;
//        }
//    }else{
//        showLogin = YES;
//        if([self.whistleAccountManager.historyAccounts count] > 0){
//            self.whistleAccountManager.currentAccount = [self.whistleAccountManager.historyAccounts objectAtIndex:0];
//        }
//    }
//    if(showLogin){
//        
//        [self performSelectorOnMainThread:@selector(doManuallyLogin) withObject:nil waitUntilDone:NO];
//        //[self doSwitchToLogin];
//    }else{
//        //[self doAutoLogin];
//    }
//    }
//}
//
//-(void)doManuallyLogin
//{
//    if (currentApplicationStatus == WhistleStarted) {
//        _isChangeUserSegue = NO;
//        //自动登录
////        AccountInfo *acc =  [self.whistleAccountManager currentAccount];
////        if(acc.savePasswd){
////            [self.whistleAccountManager login:^(BOOL result, NSDictionary* data){
////                if (result) {
////                    [self onStartSuccessfully];
////                }
////                else{
////                    [self.whistleDelegate.window.rootViewController performSegueWithIdentifier:@"WellcomeToLoginSegue" sender:self];
////                }
////
////            }];
////         }else{
//            [self.whistleDelegate.window.rootViewController performSegueWithIdentifier:@"WellcomeToLoginSegue" sender:self];
////        }
//        
//    }else if(currentApplicationStatus == WhistleChangeUser){
//        currentApplicationStatus = WhistleStarted;
//        _isChangeUserSegue = YES;
//        [self.whistleDelegate.window.rootViewController performSegueWithIdentifier:@"ChangeUserSegue" sender:self];
//    }
//
//}
//
//-(void)doAutoLogin
//{
//    
//}
//
//-(void)onLoginSuccessfully
//{
//    NSLog(@"self.whistleLocalRecentListManager reset");
//    [self.whistleAccountManager registerListener];
//    [self.whistlePushMessageManager registPushMsgListener];
//    [self.whistleNoticeManager prepareData];
//    [self.whistleAppMessageManager prepareData];
////    [self.whistleRosterManager reset];
//    [self.whistleLocalRecentListManager reset];
//    [self.whistleCrowdManager registerListener];
//    [self.whistleDisscussionManager reset];
//    
//    [self.whistleRosterManager initRosterData:^(Roster* data){
//        if (data) {
//            self.rosterReady = YES;
//            [self checkToShowMain];
//        }
//    }];
//}
//
//
//-(void)onLoginWithFailure:(NSString *)reason
//{
//    
//}
//
//-(void)onRosterDone:(NSNotification *)notification
//{
////    self.rosterReady = YES;
////    [self checkToShowMain];
//    
//}
//
//-(void)onNoticeDone:(NSNotification *)notification
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNoticeListReadyNotificationName object:nil];
//
////    self.noticeReady = YES;
////    [self checkToShowMain];
//    
//}
//
//-(void)onAppMsgDone:(NSNotification *)notification
//{
////    self.appMsgReady = YES;
////    [self checkToShowMain];
//    
//}
//
//-(void)checkToShowMain
//{
////    if(self.rosterReady && self.noticeReady && self.appMsgReady){
//    [self performSelectorOnMainThread:@selector(showImMain) withObject:nil waitUntilDone:NO];
////    }
//}
//
//
//-(void)onChangeUser
//{
//    self.rosterReady = NO;
//    self.appMsgReady = NO;
//    self.noticeReady = NO;
//    currentApplicationStatus = WhistleChangeUser;
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNoticeDone:) name:kNoticeListReadyNotificationName object:nil];
//    
//    //[JSONObjectHelper reset];
//    [self.whistleBizProxy reset];
//    [self.whistleRosterManager clear];
//    [self.whistleNoticeManager clear];
//    [self.whistleLocalRecentListManager clear];
//    [self.whistleDisscussionManager clear];
//    [self.whistleNoticeManager clear];
//    [self.whistleAppMessageManager clear];
//    [self.whistleCrowdManager clear];
//    
//    [self configAccountManager];
//    //[self.whistleDelegate.window.rootViewController performSegueWithIdentifier:@"ChangeUserSegue" sender:self];
//}
//
//- (void)showImMain
//{
//    
//    
//    [self.whistleDelegate.window.rootViewController performSegueWithIdentifier:@"LoginToImCoreSegue" sender:self];
//   
//}
//
//
//-(NSString *)getImageName:(NSString *)baseName subfix:(NSString *)subfix
//{
//    NSString *fullName = nil;
//    if (IS_IPHONE5){
//        fullName = [NSString stringWithFormat:@"%@-568h.%@",baseName,subfix];
//        
//    }else{
//        fullName = [NSString stringWithFormat:@"%@.%@",baseName,subfix];
//    }
//    return fullName;
//
//}
//
//- (void)drawRosterHeadPic:(FriendInfo *)rosterItem withView:(UIImageView *)view withOnline:(BOOL)flag
//{
////    UIImage *headImage = nil;
////
////    if(!rosterItem){
////        
////        headImage = [UIImage imageNamed:@"head_male_student.jpg"];
////        
////        headImage = [ImUtil convertImageToGrayScale:headImage];
////        
////        
////    }else{
////    
////        
////    if([rosterItem.identity isEqualToString:IDENT_TEACHER]){
////        if([rosterItem.head length] == 0){
////            if([rosterItem.sexShow isEqualToString:SEX_BOY]){
////                headImage = [UIImage imageNamed:@"head_male_teacher.jpg"];
////            }else {
////                headImage = [UIImage imageNamed:@"head_female_teacher.jpg"];
////            }
////        }else{
////            headImage = [UIImage imageWithContentsOfFile:rosterItem.head];
////        }
////    }else{
////        if([rosterItem.head length] == 0){
////            if([rosterItem.sexShow isEqualToString:SEX_BOY]){
////                headImage = [UIImage imageNamed:@"head_male_student.jpg"];
////            }else {
////                headImage = [UIImage imageNamed:@"head_female_student.jpg"];
////            }
////        }else{
////            headImage = [UIImage imageWithContentsOfFile:rosterItem.head];
////        }
////        
////    }
////    
////    if (flag && ![rosterItem isOnline]) {
////        headImage = [ImUtil convertImageToGrayScale:headImage];
////    }
////        
////    }
//    
//    if (rosterItem) {
//        UIImage * image = nil;
//        image = [UIImage imageWithContentsOfFile:rosterItem.head];
//        if (image == nil) {
//            if (rosterItem.identity) {
//                if ([rosterItem.identity isEqualToString:IDENT_TEACHER]) {
//                    if ([rosterItem.sexShow isEqualToString:SEX_BOY]) {
//                        image = [UIImage imageNamed:@"male_teacher_image.png"];
//                    } else {
//                        image = [UIImage imageNamed:@"female_teacher_image.png"];
//                    }
//                } else if ([rosterItem.identity isEqualToString:IDENT_STUDENT]){
//                    if ([rosterItem.sexShow isEqualToString:SEX_BOY]) {
//                        image = [UIImage imageNamed:@"male_student_image.png"];
//                    } else {
//                        image = [UIImage imageNamed:@"female_student_image.png"];
//                    }
//                } else if ([rosterItem.identity isEqualToString:IDENT_OTHER]) {
//                    if ([rosterItem.sexShow isEqualToString:SEX_BOY]) {
//                        image = [UIImage imageNamed:@"male_other_image.png"];
//                    } else {
//                        image = [UIImage imageNamed:@"female_other_image.png"];
//                    }
//                }else{
//                    image = [UIImage imageNamed:@"male_other_image.png"];
//                }
//            }else{
//                image = [UIImage imageNamed:@"male_other_image.png"];
//            }
//            
//        }
//        
//        if (flag && ![rosterItem isOnline]) {
//            image = [ImUtil convertImageToGrayScale:image];
//        }
//        
//        view.image = image;
//        view.layer.cornerRadius = 8.0f;
//        view.layer.masksToBounds = YES;
//    }
//}
//
//-(void)drawRosterPresencePic:(FriendInfo *)rosterItem withView:(UIImageView *)view
//{
//    AccountStatus status = [rosterItem getFriendPresence];
//    UIImage *presenceImage = [UIImage imageNamed:@"presence_busy.png"];
//    [view setHidden:YES];
//
//    
//    switch (status) {
//        case Online:
//        case Offline:
//            [view setHidden:YES];
//            break;
//        case Away :
//            [view setHidden:NO];
//            presenceImage = [UIImage imageNamed:@"presence_away.png"];
//            break;
//        case Busy :
//            [view setHidden:NO];
//            break;
//        case Android:
//            [view setHidden:NO];
//            presenceImage = [UIImage imageNamed:@"presence_android.png"];
//            break;
//        case Ios:
//            [view setHidden:NO];
//            presenceImage = [UIImage imageNamed:@"presence_apple.png"];
//            break;
//            
//        default:
//            break;
//    }
//    
//    view.image = presenceImage;
//    
//}
//
//-(BOOL)isTeacher:(FriendInfo *)rosterInfo
//{
//    if([rosterInfo.identity isEqualToString:IDENT_TEACHER]){
//        return YES;
//    }
//    return NO;
//}
//
//-(BOOL)isBoy:(FriendInfo *)rosterInfo
//{
//    if([rosterInfo.sexShow isEqualToString:SEX_BOY]){
//        return YES;
//    }
//    return NO;
//}
//
//-(void)configGenderImage:(FriendInfo *)rosterInfo image:(UIImageView *)image
//{
//    if([self isBoy:rosterInfo]){
//        [image setImage:[UIImage imageNamed:@"info_gender_male.png"]];
//        
//    }else{
//        [image setImage:[UIImage imageNamed:@"info_gender_female.png"]];
//    }
//}
//
//-(void)configIdentityImage:(FriendInfo *)rosterInfo image:(UIImageView *)image
//{
//    if(![self isTeacher:rosterInfo]){
//        [image setHidden:YES];
//    }else{
//        [image setHidden:NO];
//    }
//}
//
//-(void)configButtonEffect:(UIButton *)button inview:(UIView *)view
//{
//    UIGraphicsBeginImageContext(view.frame.size);
//    
//    [[[UIImage imageNamed:@"info_button_bg.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:20] drawInRect:view.bounds];
//    
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    //self.detailedInfo.backgroundColor = [UIColor colorWithPatternImage:image];
//    [button setBackgroundImage:image forState:UIControlStateNormal];
//    [button setTitle:NSLocalizedString(@"open_detail_info", nil) forState:UIControlStateNormal];
//    UIGraphicsBeginImageContext(view.frame.size);
//    
//    [[[UIImage imageNamed:@"info_button_bg_pressed.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:20] drawInRect:view.bounds];
//    
//    image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    [button setBackgroundImage:image forState:UIControlStateHighlighted];
//    [button setTitle:NSLocalizedString(@"open_detail_info", nil) forState:UIControlStateHighlighted];
// 
//}
//
//-(void)configEditorEffect:(UITextView *)editor inview:(UIView *)view
//{
//    UIGraphicsBeginImageContext(editor.frame.size);
//    
//    [[[UIImage imageNamed:@"content_input_bg.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:20] drawInRect:editor.bounds];
//    
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    image = [image stretchableImageWithLeftCapWidth:12 topCapHeight:12];
//    editor.backgroundColor = [UIColor colorWithPatternImage:image];
//
//}
//
//-(void)configTimeLabelBackground:(UILabel *)label
//{
//    UIGraphicsBeginImageContext(label.frame.size);
//    
//    [[[UIImage imageNamed:@"time_bg.png"] stretchableImageWithLeftCapWidth:9 topCapHeight:9] drawInRect:label.bounds];
//    
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    image = [image stretchableImageWithLeftCapWidth:9 topCapHeight:9];
//    label.backgroundColor = [UIColor colorWithPatternImage:image];
//
//}
//
//-(void)setViewFullBackground:(NSString *)imageName inview:(UIView *)view
//{
//    UIGraphicsBeginImageContext(view.frame.size);
//    
//    [[UIImage imageNamed:[self getImageName:imageName subfix:@"png"]] drawInRect:view.bounds];
//    
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    view.backgroundColor = [UIColor colorWithPatternImage:image];
//    
//}
//
//-(void)setTableViewFullBackground:(NSString *)imageName inview:(UITableView *)table
//{
//    table.backgroundView = [[UIView alloc] initWithFrame:table.bounds];
//    table.backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[self getImageName:imageName subfix:@"png"]]];
//    
//}
//
//-(NSString *)getShownameByIdentity:(FriendInfo *)rosterInfo
//{
//    if(!rosterInfo){
//        return NSLocalizedString(@"defaultName", nil);
//    }
//    if([rosterInfo.remarkName length] > 0){
//        return rosterInfo.remarkName;
//    }
//    if([self isTeacher:self.whistleRosterManager.currentRoster.myInitInfo]){
//        return rosterInfo.name;
//    }else{
//        if ([@"" isEqualToString:rosterInfo.nickName]) {
//            return rosterInfo.showName;
//        }else{
//            return rosterInfo.nickName;
//        }
//    }
//}
//
//- (BOOL)isSameDay :(NSDate *)day1 :(NSDate *)day2
//{
//    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
//    NSDateComponents *comps1 = [calendar components:unitFlags fromDate:day1];
//    NSDateComponents *comps2 = [calendar components:unitFlags fromDate:day2];
//    
//    if (([comps1 year] == [comps2 year]) && ([comps1 month] == [comps2 month]) && ([comps1 day] == [comps2 day])){
//        return YES;
//    }
//    return NO;
//}
//
//-(UIImage *)getImageFromFilePath:(NSString *)path
//{
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    BOOL success = [fileManager fileExistsAtPath:path];
//    
//    UIImage* image = nil;
//    
//    if(!success)
//    {
//        NSLog(@"no image for %@",path);
//        return nil;
//    }
//    else
//    {
//        image = [[UIImage alloc] initWithContentsOfFile:path];
//    }
//    
//    NSLog(@"got image from %@",path);
//    return image;
//}
//
//-(void)prepareNoticeManager
//{
//    [self.whistleNoticeManager prepareData];
//}
//
//-(void)prepareAppMessageManager
//{
//    [self.whistleAppMessageManager prepareData];
//}
//
//+ (BOOL) isChangeUserSegue
//{
//    return _isChangeUserSegue;
//}
//
//
//@end
