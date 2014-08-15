//
//  PrivateTalkViewController.h
//  WhistleIm
//
//  Created by wangchao on 13-7-19.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConversationInfo.h"
#import "EGORefreshTableHeaderView.h"
#import "OHAttributedLabel.h"
#import "CrowdManager.h"
#import "DiscussionManager.h"
#import "MessageManager.h"
#import "AppMessageManager.h"


typedef enum TalkMode {
	TalkModeVoice,
    TalkModeText
} TalkMode;

@protocol EmoViewDelegate;
@protocol HPGrowingTextViewDelegate;
@protocol TalkingRecordViewControllerDelegate;

@class HPGrowingTextView;
@class ActivateUnitInfo;
@class NotificationSummaryInfo;

@class QTVoicePanel;


@interface PrivateTalkViewController : UIViewController <UIScrollViewDelegate,EmoViewDelegate,HPGrowingTextViewDelegate,TalkingRecordViewControllerDelegate,UITableViewDelegate, UITableViewDataSource,UIImagePickerControllerDelegate,NSXMLParserDelegate, UINavigationControllerDelegate,EGORefreshTableHeaderDelegate,UIAlertViewDelegate,CrowdDelegate,OHAttributedLabelDelegate,MessageManagerDelegate,AppMsgDelegate,DiscussionDelegate,UIGestureRecognizerDelegate> {
    BOOL isflage;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    TalkMode currentTalkMode;
    
    // add by lzy
    NSString * groupType;
}
@property (nonatomic,strong) NSString * groupType;

@property (nonatomic,strong) UITableView *mainContent;

@property (nonatomic,strong) UIView *operatePanel;

@property (nonatomic,strong) UIView *morePanel;

@property (nonatomic,strong) UIView *emoPanel;

@property (nonatomic,strong) UIButton *voiceBtn;

@property (nonatomic,strong) UIButton *switchModeBtn;

@property (nonatomic,strong) UIButton *moreBtn;

@property (nonatomic,strong) HPGrowingTextView *inputField;

@property (nonatomic,strong) UIImageView *popEmoWindow;

@property (nonatomic,strong) NSString *inputJid;

@property (nonatomic,assign) int messageCount;

@property (nonatomic,assign) int messageStart;

@property (nonatomic,assign) int countAll;

@property (nonatomic,strong) id inputObject;

@property (nonatomic,strong) UIImagePickerController *picker;

@property (nonatomic,strong) UIButton *otherMsgBtn;

@property (nonatomic,strong) QTVoicePanel *voicePanel;

@property (nonatomic, strong) NSString* myDevice;

-(void) reloadTableViewDataSource;

-(void) doneLoadingTableViewData;

@end
