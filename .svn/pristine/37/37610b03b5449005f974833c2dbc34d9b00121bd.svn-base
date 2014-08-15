//
//  SeriesButton.h
//  WhistleIm
//
//  Created by 管理员 on 14-1-10.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SeriesButtonDelegate <NSObject>

- (void)callUpInSeriesButton;
- (void)sendMessageInSeriesButton;
- (void)deleteFriendInSeriesButton;

- (void)gotoPhonePageInSeriesButton;

@end

@interface SeriesButton : UIButton
{
    __weak id <SeriesButtonDelegate> m_delegate;
}

@property (nonatomic, weak) __weak id <SeriesButtonDelegate> m_delegate;

- (id)initWithFrame:(CGRect)frame wihtHasPhone:(BOOL)hasPhone;

@end
