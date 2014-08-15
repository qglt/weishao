//
//  AppCommentController.h
//  WhistleIm
//
//  Created by 曾长欢 on 14-1-13.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseAppInfo.h"
#import "CommentView.h"
@interface AppCommentController : UIViewController
@property (nonatomic, strong) BaseAppInfo *info;
@property (nonatomic, strong) NSString * commentStr;
@property (nonatomic, assign) NSInteger starScore;
@property (nonatomic, strong)CommentView *commentView;

@end
