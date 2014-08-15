//
//  SelectTypeTableView.h
//  WhistleIm
//
//  Created by 管理员 on 13-10-25.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectTypeTableViewDelegate <NSObject>

- (void)typeSelected:(NSString *)typeName andSelectedRow:(NSUInteger)row;
- (void)touchToRemoveSelf;
@end

@interface SelectTypeTableView : UIView
{
    __weak id <SelectTypeTableViewDelegate> m_delegate;
    BOOL m_isCrowd;
}
@property (nonatomic, assign) BOOL m_isCrowd;
@property (nonatomic, weak) __weak id <SelectTypeTableViewDelegate> m_delegate;
- (id)initWithFrame:(CGRect)frame andIsCrowd:(BOOL)isCrowd;
@end
