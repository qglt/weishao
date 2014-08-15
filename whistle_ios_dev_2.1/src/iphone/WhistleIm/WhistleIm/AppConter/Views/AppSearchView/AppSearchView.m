//
//  AppSearchView.m
//  WhistleIm
//
//  Created by 曾长欢 on 14-2-19.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "AppSearchView.h"
#import "CustomScrollTableViewCell.h"
#import "ImUtils.h"
#import "AppManager.h"
@interface AppSearchView()<UITableViewDataSource,UITableViewDelegate,CustomSearchBarDelegate,RootScrollViewDelegate,AppCenterDelegate>
{
    CGRect _mainScreenFrame;
    BOOL _isIOS7;
    CGRect m_frame;
    UIButton * searchButton;
    NSIndexPath *_openedIndexPath;

}

@end
@implementation AppSearchView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _isIOS7 = [[GetFrame shareInstance] isIOS7Version];
        [self createTableView];
        m_frame = frame;


        
    }
    return self;
}
- (void) createTableView
{
    _mainScreenFrame = [[UIScreen mainScreen] bounds];

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    view.backgroundColor = [ImUtils colorWithHexString:@"#d9d9d9"];
    [self addSubview:view];
    
    self.searchBar = [[CustomSearchBar alloc] initWithFrame:CGRectMake(0, 8, 280, 29)];
    [self.searchBar changeSearchBarPlaceHolder:@"应用名称"];
    self.searchBar.m_delegate = self;
    [self.searchBar sizeToFit];
    [view addSubview:self.searchBar];
    
    
    searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    searchButton.frame = CGRectMake(280, 0, 40, 44);
    [searchButton setImage:[UIImage imageNamed:@"searchBtn_Magn.png"] forState:UIControlStateNormal];
    [searchButton setImage:[UIImage imageNamed:@"searchBtn_Magn_P.png"] forState:0];
    [searchButton addTarget:self action:@selector(doSearchText) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:searchButton];

    
    //如果是ios7　是下面这个Frame
    if (_isIOS7) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, self.frame.size.width, self.frame.size.height-64-44)style:UITableViewStylePlain];
    }else{
        //如果不是ios7 是下面这个Frame
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, self.frame.size.width, self.frame.size.height-44-44)style:UITableViewStylePlain];
    }
    self.tableView.bounces = NO;
    self.tableView.delegate =  self;
    self.tableView.dataSource = self;
    [self addSubview:self.tableView];
    self.tableView.hidden = YES;
//    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
//    [self.tableView addGestureRecognizer:singleTap];

    
}
- (void)singleTap:(UITapGestureRecognizer *)singleTap
{
    [self exitkeyboard];
}
- (void)exitkeyboard
{
    [self.searchBar resignFirstResponder];
}
#pragma mark - UITableViewDataSource
//返回组
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    return [self.array count];
    return 1;
}



//返回每个section的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return [[[self.array objectAtIndex:section] array]count];
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    CustomScrollTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[CustomScrollTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellBackground.png"]];
        
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:94/255 green:94/255 blue:94/255 alpha:1.0];
    
    BaseAppInfo *info = [self.dataArray objectAtIndex:indexPath.row];
    [cell setupCell:info];
    cell.scrollDelegate = self;
    cell.scrollViewDelegate = self;
    [cell setOptionViewVisible:[_openedIndexPath isEqual:indexPath]];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

#pragma mark - UITableViewDelegate
//重新设置一下tableviewcell的行高为66
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150/2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    BaseAppInfo *info = [self.dataArray objectAtIndex:indexPath.row ];

    if (self.appSearchDelegate && [self.appSearchDelegate respondsToSelector:@selector(pushTalk:)]) {
        [self.appSearchDelegate pushTalk:info];
    }
    
}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    self.isSearching = NO;
//    self.searchBar.text  = @"";
    [self.tableView reloadData];
    return indexPath;
}

#pragma mark - CustomSearchBarDelegate
- (void)deleteButtonPressed:(UIButton *)button
{
    [self doSearchText];
}
- (void)searchBarTextDidChange:(NSString *)searchText
{
//    [self doSearchText];
    

    NSString * text = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([text isEqualToString:@""] && [searchText length] <= 0) {
        NSLog(@"searchbar.text == %@", text);
        [self doSearchText];
        
        self.searchBar.m_deleteButton.hidden = YES;
    }
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self doSearchText];
}

- (void)doSearchText
{
    NSString *searchText = [self.searchBar.m_searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([searchText length]>0) {
        self.tableView.hidden = NO;
    } else {
        self.tableView.hidden = YES;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.searchBar.m_searchBar resignFirstResponder];
        if (self.appSearchDelegate && [self.appSearchDelegate respondsToSelector:@selector(searchApp:)]) {
            [self.appSearchDelegate searchApp:searchText];
        }
    });
}

- (void)pickUpCellWithCell:(CustomScrollTableViewCell *)cell
{
    [JGScrollableTableViewCellManager closeAllCellsWithExceptionOf:cell stopAfterFirst:YES];

}


#pragma mark - JGScrollableTableViewCellDelegate

- (void)cellDidBeginScrolling:(CustomScrollTableViewCell *)cell {
    [JGScrollableTableViewCellManager closeAllCellsWithExceptionOf:cell stopAfterFirst:YES];
}

- (void)cellDidScroll:(CustomScrollTableViewCell *)cell {
    [JGScrollableTableViewCellManager closeAllCellsWithExceptionOf:cell stopAfterFirst:YES];
    //发送完之后发到控制
}

- (void)cellDidEndScrolling:(CustomScrollTableViewCell *)cell {
    if (cell.optionViewVisible) {
        _openedIndexPath = [self.tableView indexPathForCell:cell];
    }
    else {
        _openedIndexPath = nil;
    }
    
    [JGScrollableTableViewCellManager closeAllCellsWithExceptionOf:cell stopAfterFirst:YES];

}
#pragma mark RootScrollViewDelegate


- (void)pushAppDetailController:(id)object
{
    CustomScrollTableViewCell * cell = (CustomScrollTableViewCell *)object;
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    
    BaseAppInfo *info = [self.dataArray objectAtIndex:indexPath.row ];
    if (self.appSearchDelegate && [self.appSearchDelegate respondsToSelector:@selector(pushDetail:)]) {
        [self.appSearchDelegate pushDetail:info];
    }
}
- (void)markApp:(id)object
{
    CustomScrollTableViewCell *cell = (CustomScrollTableViewCell *)object;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    BaseAppInfo *baseAppInfo = [self.dataArray objectAtIndex:indexPath.row];
    
    if (baseAppInfo.isCollection) {
        [[AppManager shareInstance] removeFromMyCollectApp:baseAppInfo callback:^(BOOL isSuccess) {
            if (isSuccess) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell setupCell:baseAppInfo];
                });
            }
        }];
    } else {
        [[AppManager shareInstance] add2MyCollectApp:baseAppInfo callback:^(BOOL isSuccess) {
            if (isSuccess) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell setupCell:baseAppInfo];
                });
            }
            
        }];
    }
    
    
}
@end
