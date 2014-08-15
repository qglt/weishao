//
//  CustomSearchBar.m
//  RJMySearchBar
//
//  Created by 管理员 on 13-12-26.
//  Copyright (c) 2013年 lizuoying. All rights reserved.
//

#import "CustomSearchBar.h"
@interface CustomSearchBar ()
<UISearchBarDelegate, UITextFieldDelegate>
{
    CGRect m_frame;
    
}
//@property (nonatomic,assign) BOOL onLineSearch;
@end

@implementation CustomSearchBar

@synthesize m_searchBar;
@synthesize m_deleteButton;
@synthesize m_delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        m_frame = frame;
        if (!isIOS7) {
            [self createBGImageView];
        }
        [self createSearchBar];
        [self createDeleteButton];
    }
    return self;
}

- (void)createBGImageView
{
    UIImageView * bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 0, m_frame.size.width - 16, 29)];
    bgImageView.image = [UIImage imageNamed:@"searchBarborder.png"];
    bgImageView.userInteractionEnabled = YES;
    bgImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:bgImageView];
}

- (void)createDeleteButton
{
    self.m_deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.m_deleteButton.frame = CGRectMake(m_frame.size.width - 47, 0, 34, 28);
    [self.m_deleteButton setBackgroundImage:[UIImage imageNamed:@"searchBarDelete.png"] forState:UIControlStateNormal];
    [self.m_deleteButton setBackgroundImage:[UIImage imageNamed:@"searchBarDeletePressed.png"] forState:UIControlStateSelected];
    [self.m_deleteButton setBackgroundImage:[UIImage imageNamed:@"searchBarDeletePressed.png"] forState:UIControlStateHighlighted];
    self.m_deleteButton.hidden = YES;
    self.m_deleteButton.backgroundColor = [UIColor clearColor];

    [self.m_deleteButton addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.m_deleteButton];
}

- (void)deleteButtonPressed:(UIButton *)button
{
    self.m_searchBar.text = nil;
    [self.m_searchBar resignFirstResponder];
    self.m_deleteButton.hidden = YES;
    [m_delegate deleteButtonPressed:button];
}

- (void)createSearchBar
{
    self.m_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, m_frame.size.width, m_frame.size.height)];
    self.m_searchBar.delegate = self;
    self.m_searchBar.backgroundImage = nil;
    self.m_searchBar.barStyle = UIBarStyleDefault;
    self.m_searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.m_searchBar.placeholder = @"搜索";
    self.m_searchBar.backgroundColor = [UIColor clearColor];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0f) {
        [[self.m_searchBar.subviews objectAtIndex:0] removeFromSuperview];
        UITextField *searchField = [[m_searchBar subviews] lastObject];
        searchField.delegate = self;
        searchField.background = [UIImage imageNamed:nil];
        searchField.clearButtonMode = UITextFieldViewModeNever;
        self.m_searchBar.frame = CGRectMake(0, 0, m_frame.size.width - 30, m_frame.size.height);
        self.m_searchBar.backgroundColor = [UIColor clearColor];
    } else {
        if ([self.m_searchBar respondsToSelector:@selector(barTintColor)]) {
            [self.m_searchBar setBarTintColor:[UIColor clearColor]];
        }
    }
    
    [self addSubview:self.m_searchBar];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.m_deleteButton.hidden = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSString * text = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([m_delegate respondsToSelector:@selector(searchBarTextDidChange:)]) {
        [m_delegate searchBarTextDidChange:text];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [m_delegate searchBarSearchButtonClicked:self.m_searchBar];
}

-(void)changeSearchBarPlaceHolder:(NSString *)holder
{
    self.m_searchBar.placeholder = holder;
}
@end
