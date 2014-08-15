//
//  CrowdSystemView.h
//  WhistleIm
//
//  Created by liuke on 13-11-5.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CrowdSystemDelegata <NSObject>

- (void) pushAgreeBtn;
- (void) pushRejectBtn;
- (void) clickLabel: (NSString*) jid;
@end

@interface CrowdSystemView : UIView

@property (strong, nonatomic) UIImage* photo;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* crowd_no;
@property (strong, nonatomic) NSString* content;//原始文字
@property (strong, nonatomic) NSString* reason;
@property (nonatomic) NSInteger category;
@property (nonatomic) BOOL isAgree;

//@property (strong, nonatomic) NSDictionary* contentDic;

- (void) setContentDictionary:(NSDictionary *)contentDic;

- (void) createViewIsReason:(BOOL) isreason isButton:(BOOL) isHasBtn IsNeedAnswer:(BOOL) isAnswer;

@property (weak, nonatomic) __weak id<CrowdSystemDelegata> crowdSystemDelegate;

@end
