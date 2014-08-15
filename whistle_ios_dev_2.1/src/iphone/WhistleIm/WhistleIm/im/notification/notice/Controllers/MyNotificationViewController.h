//
//  MyNotificationViewController.h
//  WhistleIm
//
//  Created by ruijie on 佛历2557-1-2.
//  Copyright (c) 佛历2557年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QTNoticeDelegate.h"
#import "NoticeAndNotificationInfo.h"

@interface MyNotificationViewController : UIViewController <NoticeAndNotificationInfoDelegate>
{
    NSMutableDictionary * m_notificationAllDataDict;
}
@property (nonatomic,strong) NSMutableDictionary * m_notificationAllDataDict;
@property (nonatomic,weak) id <QTNoticeDelegate> delegate;
@end
