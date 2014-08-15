//
//  GetFrame.h
//  WhistleIm
//
//  Created by 管理员 on 13-10-15.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CrowdInfo;
@class FriendInfo;

@interface GetFrame : NSObject
+ (id)shareInstance;
- (BOOL)isIOS7Version;
- (BOOL)is4InchScreen;
- (void)setNavigationBarForController:(UIViewController *)controller;
- (BOOL) isRetinaScreen;
- (UIImage *)convertImageToGrayScale:(UIImage *)image;
- (UIImage *)getFriendHeadImageWithFriendInfo:(FriendInfo *)friendInfo convertToGray:(BOOL)isGray;

@end
