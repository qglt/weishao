////
////  WhistleApplicationProxy.h
////  WhistleIm
////
////  Created by wangchao on 13-6-21.
////  Copyright (c) 2013年 Ruijie. All rights reserved.
////
//
//#import <Foundation/Foundation.h>
//
//@class WhistleAppDelegate;
//@class AccountManager;
//@class BizlayerProxy;
//@class RosterManager;
//@class FriendInfo;
//@class NoticeManager;
//@class DisscussionManager;
//@class LocalRecentListManager;
//@class PushMessageManager;
//@class AppMessageManager;
//@class CrowdManager;
//
//enum WhistleApplicationStatus {
//    WhistleNotRunning                     = 0,
//    WhistleStarting                     = 1 << 0,
//    WhistleStarted                      = 1 << 1,
//    WhistleChangeUser                   = 1 << 2
//};
//
//typedef enum WhistleApplicationStatus WhistleApplicationStatus;
//
//
//@interface WhistleApplicationProxy : NSObject{
//    WhistleApplicationStatus currentApplicationStatus;
//}
//
//@property (strong, nonatomic) AccountManager *whistleAccountManager;
//
//@property (strong, nonatomic) RosterManager *whistleRosterManager;
//
//@property (strong, nonatomic) NoticeManager *whistleNoticeManager;
//
//@property (strong, nonatomic) AppMessageManager *whistleAppMessageManager;
//
//@property (strong, nonatomic) WhistleAppDelegate *whistleDelegate;
//
//@property (strong, nonatomic) BizlayerProxy *whistleBizProxy;
//
//@property (strong, nonatomic) LocalRecentListManager *whistleLocalRecentListManager;
//
//@property (strong, nonatomic) DisscussionManager *whistleDisscussionManager;
//
//@property (strong, nonatomic) PushMessageManager *whistlePushMessageManager;
//
//@property (strong, nonatomic) CrowdManager *whistleCrowdManager;
//
//@property (strong, nonatomic) UIStoryboard *mainStoryboard;
//
//@property (strong,nonatomic) NSString *whistleMainFolder;
//
//-(id)initWithWhistleDelegate:(WhistleAppDelegate *)delegate;
//
//-(void)startWhistle;
//
//-(void)onStartSuccessfully;
//
//-(void)onStartWithFailure:(NSString *)reason;
//
//-(void)onLoginSuccessfully;
//
//-(void)onLoginWithFailure:(NSString *)reason;
//
//-(void)onChangeUser;
//
//-(CGRect)statusBarFrameViewRect:(UIView *)view;
//
//-(NSString *)getImageName:(NSString *)baseName subfix:(NSString *)subfix;
//
//-(void)drawRosterHeadPic:(FriendInfo *)rosterItem withView:(UIImageView *)view withOnline:(BOOL)flag;
//
//-(void)drawRosterPresencePic:(FriendInfo *)rosterItem withView:(UIImageView *)view;
//
////-(void)drawRosterGreyHeadPic:(FriendInfo *)rosterItem withView:(UIImageView *)view;
//
//-(BOOL)isTeacher:(FriendInfo *)rosterInfo;
//
//-(BOOL)isBoy:(FriendInfo *)rosterInfo;
//
//-(void)configIdentityImage :(FriendInfo *)rosterInfo image:(UIImageView *)image;
//
//-(void)configGenderImage :(FriendInfo *)rosterInfo image:(UIImageView *)image;
//
//-(void)configButtonEffect:(UIButton *) button inview:(UIView *)view;
//
//-(void)configEditorEffect:(UITextView *)editor inview:(UIView *)view;
//
//-(void)configTimeLabelBackground:(UILabel *)label;
//
//-(void)setViewFullBackground:(NSString *)imageName inview:(UIView *)view;
//
//-(void)setTableViewFullBackground:(NSString *)imageName inview:(UITableView *)table;
//
//-(NSString *)getShownameByIdentity:(FriendInfo *)rosterInfo;
//
//- (BOOL)isSameDay :(NSDate *)day1 :(NSDate *)day2;
//
//-(void)prepareNoticeManager;
//
//-(void)prepareAppMessageManager;
//
//-(UIImage *)getImageFromFilePath :(NSString *)path;
//
//+ (BOOL) isChangeUserSegue;
//
//@end
//
