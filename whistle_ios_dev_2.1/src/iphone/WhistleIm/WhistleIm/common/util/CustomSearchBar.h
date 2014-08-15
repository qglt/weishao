//
//  CustomSearchBar.h
//  RJMySearchBar
//
//  Created by 管理员 on 13-12-26.
//  Copyright (c) 2013年 lizuoying. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomScrollTableViewCell.h"

@protocol CustomSearchBarDelegate <NSObject>

@optional
- (void)deleteButtonPressed:(UIButton *)button;
- (void)searchBarTextDidChange:(NSString *)searchText;
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;

@end

@interface CustomSearchBar : UIView
{
    UISearchBar * m_searchBar;
    UIButton * m_deleteButton;
    __weak id <CustomSearchBarDelegate> m_delegate;
}

@property (nonatomic, strong) UISearchBar * m_searchBar;
@property (nonatomic, strong) UIButton * m_deleteButton;
@property (nonatomic, weak) __weak id <CustomSearchBarDelegate> m_delegate;

- (void)changeSearchBarPlaceHolder:(NSString *)holder;

@end
