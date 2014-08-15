//
//  ChatRecordForNotice.h
//  Whistle
//
//  Created by wangchao on 13-3-7.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatRecord.h"

@class NoticeInfo;

@interface ChatRecordForNotice : ChatRecord


@property (nonatomic, strong) NoticeInfo* noticeInfo;

-(void)markRead:(void(^)(BOOL)) callback;

@end
