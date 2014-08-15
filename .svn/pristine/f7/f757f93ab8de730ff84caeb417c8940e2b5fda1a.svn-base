//
//  ContactsHeaderView.m
//  WhistleIm
//
//  Created by 管理员 on 14-1-2.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "ContactsHeaderView.h"
#import "CustomSearchBar.h"
#import "ImUtils.h"

#define BUTTON_TAG_START 1000

@interface ContactsHeaderView ()
<CustomSearchBarDelegate>
{
    CGRect m_frame;
    CustomSearchBar * m_searchBar;
//    UIImageView * m_indicatorImageView;
    
    UIImageView * m_fristIndicator;
    UIImageView * m_secondIndicator;

}

@property (nonatomic, strong) CustomSearchBar * m_searchBar;
//@property (nonatomic, strong) UIImageView * m_indicatorImageView;
@property (nonatomic, strong) UIImageView * m_fristIndicator;
@property (nonatomic, strong) UIImageView * m_secondIndicator;

@end

@implementation ContactsHeaderView

@synthesize m_delegate;

@synthesize m_searchBar;

//@synthesize m_indicatorImageView;
@synthesize m_fristIndicator;
@synthesize m_secondIndicator;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        m_frame = frame;
        
        [self createSearchBar];
        [self createLabel];
        [self createButtons];
    }
    return self;
}

- (void)createSearchBar
{
    UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, m_frame.size.width, 45)];
    bgView.backgroundColor = [ImUtils colorWithHexString:@"#d9d9d9"];
    [self addSubview:bgView];
    
    self.m_searchBar = [[CustomSearchBar alloc] initWithFrame:CGRectMake(5, 8, m_frame.size.width - 5 * 2, 29)];
    self.m_searchBar.m_delegate = self;
    
    [self addSubview:self.m_searchBar];
}

- (void)deleteButtonPressed:(UIButton *)button
{
    [m_delegate headerSearchBarDeleteBtnPressed:button];
}

- (void)searchBarTextDidChange:(NSString *)searchText
{
    [m_delegate headerSearchBarTextDidChange:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [m_delegate headerSearchBarSearchButtonClicked:searchBar];
}

- (void)createButtons
{
    for (NSUInteger i = 0; i < 2; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 45 * (i + 1), m_frame.size.width, 45);
        button.tag = BUTTON_TAG_START + i;
        
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(49, 15, m_frame.size.width - 49 - 50, 15)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
        label.textColor = [ImUtils colorWithHexString:@"#262626"];
        if (i == 0) {
            label.text = @"群";
        } else if (i == 1) {
            label.text = @"讨论组";
        }
        [button addSubview:label];
        
        // whiteButtonSelected.png  whiteButtonNormal.png
        [button setBackgroundImage:[UIImage imageNamed:@"whiteButtonNormal.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"whiteButtonSelected.png"] forState:UIControlStateSelected];
        [button setBackgroundImage:[UIImage imageNamed:@"whiteButtonSelected.png"] forState:UIControlStateHighlighted];

        [button addTarget:self action:@selector(buttonPressedDown:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(buttonPressedDown:) forControlEvents:UIControlEventTouchCancel];
        [button addTarget:self action:@selector(buttonPressedDown:) forControlEvents:UIControlEventTouchUpOutside];

        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:button];
        
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 21 / 2.0f, 24, 24)];
        imageView.userInteractionEnabled = YES;
        imageView.backgroundColor = [UIColor clearColor];
        if (i == 0) {
            imageView.image = [UIImage imageNamed:@"crowdIcon.png"];
        } else if (i == 1) {
            imageView.image = [UIImage imageNamed:@"groupIcon.png"];
        }
        [button addSubview:imageView];
        
        if (i == 0) {
            self.m_fristIndicator = [self createIndicatorImageView];
            [button addSubview:self.m_fristIndicator];
        } else {
            self.m_secondIndicator = [self createIndicatorImageView];
            [button addSubview:self.m_secondIndicator];
        }
    }
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 90, m_frame.size.width, 0.5f)];
    lineView.backgroundColor = [ImUtils colorWithHexString:@"#e1e1e1"];
    [self addSubview:lineView];
}

- (void)buttonPressed:(UIButton *)button
{
    if (button.tag - BUTTON_TAG_START == 0) {
        [m_delegate crwodButtonPressed];
    } else if (button.tag - BUTTON_TAG_START == 1) {
        [m_delegate disccusssionButtonPressed];
    }
    
    [self resetIndicatorImageViewWithButton:button andImagePath:@"disclosure.png"];
}

- (void)buttonPressedDown:(UIButton *)button
{
    [self resetIndicatorImageViewWithButton:button andImagePath:@"disclosurep.png"];
}

- (void)createLabel
{
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(15, 135, m_frame.size.width - 15 - 15, 25)];
    label.text = @"好友分组";
    UIFont* font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
    [label setFont:font];
    label.textColor = [ImUtils colorWithHexString:@"#808080"];
    label.backgroundColor = [ImUtils colorWithHexString:@"#F0F0F0"];
    [self addSubview:label];
}

- (UIImageView *)createIndicatorImageView
{
    UIImageView * indicatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(290, 15, 15, 15)];
    indicatorImageView.image = [UIImage imageNamed:@"disclosure.png"];
    indicatorImageView.highlightedImage = [UIImage imageNamed:@"disclosurep.png"];
    indicatorImageView.userInteractionEnabled = YES;
    return indicatorImageView;
}

- (void)resetIndicatorImageViewWithButton:(UIButton *)button andImagePath:(NSString *)path
{
    if (button.tag - BUTTON_TAG_START == 0) {
        self.m_fristIndicator.image = [UIImage imageNamed:path];
    } else if (button.tag - BUTTON_TAG_START == 1) {
        self.m_secondIndicator.image = [UIImage imageNamed:path];
    }
}

- (void)contactsHeaderViewresignFirstResponder
{
    [self.m_searchBar.m_searchBar resignFirstResponder];
}

- (void)contactsHeaderViewClearSearchBarText
{
    self.m_searchBar.m_searchBar.text = nil;
}

- (void)hiddenDeleteButton
{
    self.m_searchBar.m_deleteButton.hidden = YES;
}

@end
