//
//  TalkingRecordViewController.h
//  WhistleIm
//
//  Created by 管理员 on 13-9-30.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConversationInfo.h"
#import "MessageManager.h"


@protocol TalkingRecordViewControllerDelegate <NSObject>

- (void)clearLastConversation;

@end

//typedef enum TalkMode {
//	TalkModeVoice,
//    TalkModeText
//} TalkMode;

@protocol EmoViewDelegate;
@protocol HPGrowingTextViewDelegate;
@class HPGrowingTextView;
@class ActivateUnitInfo;
@class NotificationSummaryInfo;

@interface TalkingRecordViewController : UIViewController <MessageManagerDelegate>
{
    ConversationType convType;
    
    __weak id <TalkingRecordViewControllerDelegate> m_delegate;
}

@property (nonatomic, weak) __weak id <TalkingRecordViewControllerDelegate> m_delegate;

@property (nonatomic,strong) UITableView *mainContent;

@property (nonatomic,strong) NSString *inputJid;

@property (nonatomic,assign) int messageCount;

@property (nonatomic,assign) int countAll;

@property (nonatomic,strong) id inputObject;

-(void) handlePushMessage:(NSDictionary *)msgJson with:(NotificationSummaryInfo *)summaryInfo;
@end
