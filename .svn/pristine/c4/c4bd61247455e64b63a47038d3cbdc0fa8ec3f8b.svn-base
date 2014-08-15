//
//  ImUtils.h
//  WhistleIm
//
//  Created by wangchao on 13-12-10.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kScreenWidth                    [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight                   [[UIScreen mainScreen] bounds].size.height
#define kMaxContentHeight              140
#define kMaxContentWidth               186

#define kMinContentHeight              74
#define kMinContentWidth               99

@class ConversationInfo;
@class MessageImage;
@class FriendInfo;
@class MessageLayoutInfo;
@interface ImUtils : NSObject

+(NSString *) md5HexDigest:(NSString *)string;

+(UIImage *)scaleAndRotateImage:(UIImage *)image scaleMaxResolution:(int) kMaxResolution;

+(NSString *)fetchLastMember:(NSDictionary *)jsonobj;

+(NSString *)formatMessageTime:(NSString *)time;

+(ConversationType) getChatType:(NSString *)fromId;

+(NSString *)flattenHTML:(NSString *)html trimWhiteSpace:(BOOL)trim;

+ (UIColor *) colorWithHexString: (NSString *)color;

+ (void)drawRosterHeadPic:(FriendInfo *)rosterItem withView:(UIImageView *)view withOnline:(BOOL)flag;

+ (void)setTableViewFullBackground:(NSString *)imageName inview:(UITableView *)table;

+(NSString *) getIdByObject:(id) inputObject;

+(BOOL) IsOnlineWithFriendInfo:(FriendInfo *)info byJid:(NSString *) inputJid;

+(UIImage *) getDefault:(id)Obj;

/**
 * 将UIColor变换为UIImage
 *
 **/
+ (UIImage *)createImageWithColor:(UIColor *)color;

+(NSString *)getVacrdImagePath:(NSString *)name;

+(void) setHeadViewImage:(FriendInfo *)info withImageView:(UIImageView *)imageView forJid:(NSString *)inputJid;

+(void)downloadPic:(ConversationInfo *)convInfo withCallback:(void (^)(BOOL))callback;

+(UIImage *)getFullBackgroundImageView:(NSString *)imageName WithCapInsets:(UIEdgeInsets)capInsets hLeftCapWidth:(NSInteger)leftCapWidth topCapHeight:(NSInteger)topCapHeight;

+(void) resizeContentImageView:(UIImageView *) imageView byImage:(UIImage *)image withMessageImage:(BaseMessageInfo *)convInfo;

@end
