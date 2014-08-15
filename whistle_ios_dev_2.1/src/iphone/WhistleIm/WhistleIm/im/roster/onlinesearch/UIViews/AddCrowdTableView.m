//
//  AddCrowdTableView.m
//  WhistleIm
//
//  Created by ruijie on 14-2-11.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "AddCrowdTableView.h"
#import "GetFrame.h"
#import "AddCrowdTableViewCell.h"
#import "SelectTypeTableView.h"
#import "CustomSearchBar.h"
#import "ImUtils.h"
#import "CrowdInfo.h"

#define BUTTON_HEIGHT 39.0f

#define SEARCH_TYPE_TAG 1000
#define SEARCH_TAG 2000
#define NEXT_FRIENDS_TAG 3000

// 搜索的每页条数
#define EACH_PAGE_NUMBERS 20

// 推荐的每页条数
#define COMMOND_EAHC_PAGE_NUMBER 6

@interface AddCrowdTableView ()<UITableViewDataSource,UITableViewDelegate,CustomSearchBarDelegate,SelectTypeTableViewDelegate,AddCrowdTableViewCellDelegate>
{
    CGRect m_frame;

    CustomSearchBar * m_searchBar;
    UITableView * m_tableView;

    UIButton * m_typeButton;


    NSMutableArray * m_arrTableData;
    SelectTypeTableView * m_typeTableView;

    NSString * m_strSelectedType;

    // 推荐的 pageIndex
    NSUInteger m_pageIndex;

    UILabel * m_noneResultLabel;
    BOOL m_isRecommend;
    BOOL m_isIOS7;

    UIButton * m_nextButton;
    UIImageView * m_nextBtnBGImageView;

    BOOL m_typeChanged;

    // 搜索的 pageIndex
    NSUInteger m_searchIndex;

    BOOL m_nextPageReturned;
}

@property (nonatomic, strong) CustomSearchBar * m_searchBar;
@property (nonatomic, strong) UITableView * m_tableView;
@property (nonatomic, strong) UIButton * m_typeButton;
@property (nonatomic, strong) NSMutableArray * m_arrTableData;
@property (nonatomic, strong) SelectTypeTableView * m_typeTableView;
@property (nonatomic, strong) NSString * m_strSelectedType;
@property (nonatomic, strong) UILabel * m_noneResultLabel;
@property (nonatomic, strong) UIButton * m_nextButton;
@property (nonatomic, strong) UIImageView * m_nextBtnBGImageView;

@end

@implementation AddCrowdTableView
@synthesize m_searchBar;
@synthesize m_tableView;
@synthesize m_typeButton;

@synthesize m_arrTableData;

@synthesize m_typeTableView;

@synthesize m_strSelectedType;
@synthesize m_noneResultLabel;

@synthesize m_delegate;

@synthesize m_nextButton;

@synthesize m_nextBtnBGImageView;

- (id)initWithFrame:(CGRect)frame withTableDataArr:(NSMutableArray *)tableData
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        m_isRecommend = YES;
        m_isIOS7 = [[GetFrame shareInstance] isIOS7Version];
        m_frame = frame;
        self.m_strSelectedType = @"name";
        self.m_arrTableData = tableData;
        [self createSearchBarBGView];
        [self createSearchBar];
        [self createButtons];
        [self createTableView];
        [self createEmptySearchResultView];
    }
    return self;
}

#pragma mark - init subViews methods -
-(void)createSearchBarBGView
{
    CGFloat y = 0;
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, y, m_frame.size.width, 44)];
    view.backgroundColor = [ImUtils colorWithHexString:@"#d9d9d9"];
    [self addSubview:view];
}

- (void)createSearchBar
{
    self.m_searchBar = [[CustomSearchBar alloc] initWithFrame:CGRectMake(40, 8, m_frame.size.width - 80, 29)];
    self.m_searchBar.m_delegate = self;
    [self.m_searchBar changeSearchBarPlaceHolder:@"群名称"];
    [self addSubview:self.m_searchBar];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self searchMoreCrowds];
}

- (void)setCommondViews:(BOOL)isCommond
{
    self.m_nextButton.hidden = isCommond;
    self.m_nextBtnBGImageView.hidden = isCommond;

    CGFloat y = self.m_searchBar.frame.origin.y + self.m_searchBar.frame.size.height + 7.5;

    if (isCommond) {
        self.m_tableView.frame = CGRectMake(0, y, m_frame.size.width, m_frame.size.height - y);
    } else {
        self.m_tableView.frame = CGRectMake(0, y, m_frame.size.width, m_frame.size.height - 60 - y);
    }
}

- (void)createButtons
{
    self.m_typeButton = [self createButtonWithFrame:CGRectMake(10.5, 10.5f, 24.0f, 24.0f) andTitle:nil andImage:@"searchType_name" andSelectedImage:@"searchType_name_P" andTag:SEARCH_TYPE_TAG];
    [self addSubview:self.m_typeButton];

    UIButton * searchButton = [self createButtonWithFrame:CGRectMake(m_frame.size.width - 8 - 31, 0, 31, 44) andTitle:nil andImage:@"searchBtn_Magn" andSelectedImage:@"searchBtn_Magn_P" andTag:SEARCH_TAG];
    [self addSubview:searchButton];

    self.m_nextButton = [self createButtonWithFrame:CGRectMake(0, m_frame.size.height - 39.0f, m_frame.size.width, BUTTON_HEIGHT) andTitle:@"换一批" andImage:@"blue_iOS6_navBar" andSelectedImage:nil andTag:NEXT_FRIENDS_TAG];
    [self addSubview:self.m_nextButton];
}

- (UIButton *)createButtonWithFrame:(CGRect)frame andTitle:(NSString *)title andImage:(NSString *)imagePath andSelectedImage:(NSString *)selectedImagePath andTag:(NSUInteger)tag
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    if (tag == SEARCH_TYPE_TAG) {
        UIView * view = [[UIView alloc]initWithFrame:frame];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.cornerRadius = frame.size.width / 2.0f;
        view.layer.masksToBounds = YES;
        button.frame = CGRectMake(frame.origin.x+0.5, frame.origin.y + 0.5, frame.size.width - 1, frame.size.height - 1);
        view.layer.cornerRadius = button.frame.size.width / 2.0f;
        view.layer.masksToBounds = YES;
        [self addSubview:view];
    }else{
        button.frame = frame;
    }
    [button setBackgroundImage:[UIImage imageNamed:imagePath] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:selectedImagePath] forState:UIControlStateSelected];
    [button setBackgroundImage:[UIImage imageNamed:selectedImagePath] forState:UIControlStateHighlighted];

    button.tag = tag;
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];

    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, button.frame.size.width, button.frame.size.height)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.text = title;
    label.font = [UIFont systemFontOfSize:15.0f];
    [button addSubview:label];

    return button;
}

- (void)createEmptySearchResultView
{
    self.m_noneResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (m_frame.size.height - 60) / 2.0f, m_frame.size.width, 60)];
    self.m_noneResultLabel.backgroundColor = [UIColor clearColor];
    self.m_noneResultLabel.numberOfLines = 0;
    self.m_noneResultLabel.hidden = YES;
    self.m_noneResultLabel.textAlignment = NSTextAlignmentCenter;
    self.m_noneResultLabel.textColor = [UIColor colorWithRed:131.0f / 255.0f green:130.0f / 255.0f blue:127.0f / 255.0f alpha:1.0f];

    [self addSubview:self.m_noneResultLabel];
}

- (void)createTypeTableView
{
    CGRect frame = [[UIScreen mainScreen] bounds];
    self.m_typeTableView = [[SelectTypeTableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, m_frame.size.height) andIsCrowd:YES];
    self.m_typeTableView.m_delegate = self;
    [self addSubview:self.m_typeTableView];
}

- (void)createTableView
{
    CGFloat y = self.m_searchBar.frame.origin.y + self.m_searchBar.frame.size.height + 7.5;
    self.m_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, y, m_frame.size.width, m_frame.size.height - 60 - 45) style:UITableViewStylePlain];
    self.m_tableView.delegate = self;
    self.m_tableView.dataSource = self;
    self.m_tableView.rowHeight = 45.0f;
    self.m_tableView.showsVerticalScrollIndicator = NO;
    self.m_tableView.separatorColor = [UIColor clearColor];
    self.m_tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.m_tableView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.m_tableView];
}

#pragma mark - Operates the sub-views methods -
- (void)deleteButtonPressed:(UIButton *)button
{
    m_pageIndex++;
    [self setCommondViews:NO];
    [self searchCrowd];
}

- (void)buttonPressed:(UIButton *)button
{
    if (button.tag == SEARCH_TYPE_TAG) {
        [self createTypeTableView];
    } else if (button.tag == SEARCH_TAG) {
        [self searchMoreCrowds];
    } else if (button.tag == NEXT_FRIENDS_TAG) {
        if (m_typeChanged) {
            m_pageIndex = 0;
        } else {
            m_pageIndex++;
        }

        [self searchCrowd];
    }
}

- (void)hiddenEmptySearchResultView:(BOOL)isShow andText:(NSString *)text
{
    self.m_noneResultLabel.hidden = isShow;
    self.m_noneResultLabel.text = text;
    NSLog(@"isShow isShow == %d", isShow);


    if ([self.m_arrTableData count] > 0) {
        self.m_noneResultLabel.hidden = YES;
    } else {
        self.m_noneResultLabel.hidden = NO;
    }
}

- (void)refreshTableData:(NSMutableArray *)tableDataArr andSelectedType:(NSString *)type
{
    self.m_arrTableData = tableDataArr;
    [self.m_tableView reloadData];

    NSLog(@"online search crowd arr count == %d", [self.m_arrTableData count]);
    if (m_isRecommend == NO && [self.m_arrTableData count] >= EACH_PAGE_NUMBERS * (m_searchIndex + 1)) {
        m_nextPageReturned = YES;
    } else {
        m_nextPageReturned = NO;
    }
    
    NSLog(@"online crowd m_nextPageReturned == %d", m_nextPageReturned);
}
- (void)changeTypeButtonBGImageView:(NSUInteger)selectedRow
{
    if (selectedRow == 0) {
        [self setNormalBGImagView:@"searchType_name" andHighlightImageName:@"searchType_name_P"];
    } else if (selectedRow == 1){
        [self setNormalBGImagView:@"searchType_id" andHighlightImageName:@"searchType_id_P"];
    }
}

- (void)setNormalBGImagView:(NSString *)normalImageName andHighlightImageName:(NSString *)highlightName
{
    [self.m_typeButton setBackgroundImage:[UIImage imageNamed:normalImageName] forState:UIControlStateNormal];
    [self.m_typeButton setBackgroundImage:[UIImage imageNamed:highlightName] forState:UIControlStateSelected];
    [self.m_typeButton setBackgroundImage:[UIImage imageNamed:highlightName] forState:UIControlStateHighlighted];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.m_searchBar.m_searchBar resignFirstResponder];
}
#pragma mark -  SelectTypeTableView delegate Methods - 
- (void)typeSelected:(NSString *)typeName andSelectedRow:(NSUInteger)row
{
    m_pageIndex = 0;
    m_typeChanged = YES;
    NSLog(@"typeName == %@", typeName);
    self.m_strSelectedType = typeName;
    [self.m_typeTableView removeFromSuperview];
    self.m_typeTableView = nil;
    [self changeTypeButtonBGImageView:row];
    [self chageSearchBarPlaceHolder:row];
}
-(void)chageSearchBarPlaceHolder:(NSInteger)row
{
    if (!row) {
        [self.m_searchBar changeSearchBarPlaceHolder:@"群名称"];
    }else{
        [self.m_searchBar changeSearchBarPlaceHolder:@"群号"];
    }
}
- (void)touchToRemoveSelf
{
    [self.m_typeTableView removeFromSuperview];
    self.m_typeTableView = nil;
}

#pragma mark - Search Crowd Methods -
// 推荐
- (void)searchCrowd
{
    m_nextPageReturned = NO;
    m_isRecommend = YES;
    m_typeChanged = NO;
    
    NSString * searchText = [self.m_searchBar.m_searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.m_searchBar.m_searchBar resignFirstResponder];
        [self.m_arrTableData removeAllObjects];
        [self.m_tableView reloadData];
        [self setCommondViews:NO];
    });

    NSLog(@"m_strSelectedType == %@", self.m_strSelectedType);
    NSLog(@"m_pageIndex== %d", m_pageIndex);

    [m_delegate sendSelectedTypeToController:self.m_strSelectedType andSearchKey:searchText andMaxCounter:COMMOND_EAHC_PAGE_NUMBER andIndex:m_pageIndex isCommond:YES];
}
// 非推荐搜索更多
- (void)searchMoreCrowds
{
    m_searchIndex = 0;
    m_isRecommend = NO;

    NSString * searchText = [self.m_searchBar.m_searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([searchText length] > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.m_searchBar.m_searchBar resignFirstResponder];
            [self.m_arrTableData removeAllObjects];
            [self.m_tableView reloadData];
            [self setCommondViews:YES];
        });
        [m_delegate sendSelectedTypeToController:self.m_strSelectedType andSearchKey:searchText andMaxCounter:EACH_PAGE_NUMBERS andIndex:m_searchIndex isCommond:NO];
    } else {
        [m_delegate showNoneTextAlert];
    }
}

#pragma mark - UItableView delegate methods -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.m_arrTableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId = @"cellIdentity";
    AddCrowdTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[AddCrowdTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.m_delegate = self;
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellBackground.png"]];
    }
    cell.m_strSelectedType = self.m_strSelectedType;
    [cell setCellData:[self.m_arrTableData objectAtIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"online crowd index == %d", indexPath.row);
    cell.backgroundColor = [UIColor whiteColor];
    if (m_nextPageReturned) {
        if (m_isRecommend == NO) {
            NSInteger cellCount = [self.m_arrTableData count];
            if (cellCount - 1 == indexPath.row) {
                m_searchIndex++;
                NSString * searchText = [self.m_searchBar.m_searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                [m_delegate sendSelectedTypeToController:self.m_strSelectedType andSearchKey:searchText andMaxCounter:EACH_PAGE_NUMBERS andIndex:m_searchIndex isCommond:NO];
                NSLog(@"online crowd start index == %d", m_searchIndex);
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CrowdInfo * crowdInfo = [self.m_arrTableData objectAtIndex:indexPath.row];
    if (crowdInfo.status == 0) {
        [m_delegate didSelectedRowWithCrowdInfo:indexPath.row];
    } else if (crowdInfo.status == 1){  // 冻结了
        [m_delegate showCrowdAlockingAlert];
    }
}

#pragma mark - cell delegate methods -
- (void)addButtonPressedInAddCrowdsTableViewCell:(UIButton *)button
{
    AddCrowdTableViewCell * cell = nil;
    if ([[[UIDevice currentDevice] systemVersion]floatValue] > 6.9f) {
        cell = (AddCrowdTableViewCell *)button.superview.superview.superview;
    }else{
        cell = (AddCrowdTableViewCell *)button.superview.superview;
    }
    NSIndexPath * indexPath = [self.m_tableView indexPathForCell:cell];
    
    CrowdInfo * crowdInfo = [self.m_arrTableData objectAtIndex:indexPath.row];
    if (crowdInfo.status == 0) {
        [m_delegate didSelectedButtonWithAddCrowd:indexPath.row];
    } else if (crowdInfo.status == 1){  // 冻结了
        [m_delegate showCrowdAlockingAlert];
    }
    
}

- (void)cellImageButtonPressed:(UIButton *)button
{
    AddCrowdTableViewCell * cell = nil;
    if ([[[UIDevice currentDevice] systemVersion]floatValue] > 6.9f) {
        cell = (AddCrowdTableViewCell *)button.superview.superview.superview;
    }else{
        cell = (AddCrowdTableViewCell *)button.superview.superview;
    }
    NSIndexPath * indexPath = [self.m_tableView indexPathForCell:cell];
    
    CrowdInfo * crowdInfo = [self.m_arrTableData objectAtIndex:indexPath.row];
    if (crowdInfo.status == 0) {
        [m_delegate didSelectedRowWithCrowdInfo:indexPath.row];
    } else if (crowdInfo.status == 1){  // 冻结了
        [m_delegate showCrowdAlockingAlert];
    }
}

@end
