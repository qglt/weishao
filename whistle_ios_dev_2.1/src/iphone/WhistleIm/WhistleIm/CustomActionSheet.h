//
//  CustomActionSheet.h
//  WhistleIm
//
//  Created by 管理员 on 14-3-3.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomActionSheet;
@protocol CustomActionSheetDelegate <NSObject>

- (void)customActionSheet:(CustomActionSheet *)customActionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface CustomActionSheet : UIView
{
    __weak id <CustomActionSheetDelegate> m_delegate;
}

@property (nonatomic, weak) __weak id <CustomActionSheetDelegate> m_delegate;
- (id)initWithTitleArr:(NSArray *)titleArr andDelegate:(id)delegate andDescription:(NSString *)description;
- (void)show;

@end
