//
//  WriteContentView.h
//  WhistleIm
//
//  Created by liuke on 13-9-30.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WriteContentViewDelegate <NSObject>

- (void)sendText:(NSString *)text;

@end

@interface WriteContentView : UIView
{
    __weak id <WriteContentViewDelegate> m_delegate;
}

@property (nonatomic, weak) __weak id <WriteContentViewDelegate> m_delegate;
- (id)initWithFrame:(CGRect)frame withParentView: (UIView*) pv;
- (void) textViewDidEndEditing;
- (NSString*) getContent;
@end
