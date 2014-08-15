//
//  ContactsHeaderView.h
//  WhistleIm
//
//  Created by 管理员 on 14-1-2.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ContactsHeaderViewDelegate <NSObject>

- (void)headerSearchBarDeleteBtnPressed:(UIButton *)button;
- (void)headerSearchBarTextDidChange:(NSString *)searchText;
- (void)headerSearchBarSearchButtonClicked:(UISearchBar *)searchBar;

- (void)crwodButtonPressed;
- (void)disccusssionButtonPressed;
@end

@interface ContactsHeaderView : UIView
{
    __weak id <ContactsHeaderViewDelegate> m_delegate;
}

@property (nonatomic, weak) __weak id <ContactsHeaderViewDelegate> m_delegate;
- (void)contactsHeaderViewresignFirstResponder;
- (void)contactsHeaderViewClearSearchBarText;
- (void)hiddenDeleteButton;
@end
