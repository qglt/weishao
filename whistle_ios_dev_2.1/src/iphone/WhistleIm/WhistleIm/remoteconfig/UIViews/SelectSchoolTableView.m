
//
//  SelectSchoolTableView.m
//  test
//
//  Created by 移动组 on 13-12-11.
//  Copyright (c) 2013年 曾長歡. All rights reserved.
//

#import "SelectSchoolTableView.h"
#import "RemoteConfigInfo.h"
#import "AccountManager.h"
#import "Group.h"
#import "RemoteConfigInfo.h"
#import "GetFrame.h"
#import "ImUtils.h"

@interface SelectSchoolTableView() <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate, UISearchDisplayDelegate>
{
    CGRect _mainScreenFrame;
    BOOL _isIOS7;

}


@end

@implementation SelectSchoolTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _isIOS7 = [[GetFrame shareInstance] isIOS7Version];
        [self createTableView];
    }
    return self;
}
- (void) createTableView
{
    _mainScreenFrame = [[UIScreen mainScreen] bounds];
    
    
    self.searchBar = [[UISearchBar alloc] init];
    if (_isIOS7) {
        self.searchBar.frame = CGRectMake(0, 64, 320, 44);
    } else {
        self.searchBar.frame = CGRectMake(0, 0, 320, 44);
    }
    self.searchBar.backgroundColor = [UIColor clearColor];
    self.searchBar.placeholder = @"搜索学校";
    self.searchBar.delegate = self;
    [self.searchBar sizeToFit];
    [self addSubview:self.searchBar];
    
    NSLog(@"self.searchBar.frame.size.height = %f",self.searchBar.frame.size.height);
    //如果是ios7　是下面这个Frame
    if (_isIOS7) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44+64, self.frame.size.width, self.frame.size.height-50-64)style:UITableViewStyleGrouped];
    }else{
        //如果不是ios7 是下面这个Frame
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, self.frame.size.width, self.frame.size.height-50-44)style:UITableViewStyleGrouped];
    }
        
    
    self.tableView.delegate =  self;
    self.tableView.dataSource = self;
    [self addSubview:self.tableView];

}

#pragma mark - UITableViewDataSource
//返回组
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.array count];
}

//返回索引数组
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (self.isSearching) {
        return nil;
    }
//    NSArray *keyArray = @[@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",
//                          @"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z"];
    NSLog(@"添加索引");
    return self.keyArray;
}

//返回每个section的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.array objectAtIndex:section] array]count];
}
//返回每个索引的内容
//- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    Group *group = [self.array objectAtIndex:section];
//    return group.groupName;
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    Group *group = [self.array objectAtIndex:section];
    NSString *key = [group.groupName uppercaseString];
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 25)];
    customView.backgroundColor = [ImUtils colorWithHexString:@"#f0f0f0"];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 50, 25)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.opaque = NO;
    headerLabel.textColor = [ImUtils colorWithHexString:@"#808080"];
    headerLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:12.0];
    headerLabel.frame = CGRectMake(10, 0, 300, 25);
    headerLabel.text = key;
    [customView addSubview:headerLabel];
    return customView;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellBackground.png"]];
    }
    cell.backgroundColor = [ImUtils colorWithHexString:@"#ffffff"];
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:94/255 green:94/255 blue:94/255 alpha:1.0];
    

    Group *group = [self.array objectAtIndex:indexPath.section];
    RemoteConfigInfo *info = group.array[indexPath.row];
    cell.textLabel.text = info.name;
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
    return 45;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25;
    
}
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 0;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
//    NSLog(@"indexPath.section = %d",indexPath.section);
//    NSLog(@"indexPath.row = %d",indexPath.row);

    Group *group =  [self.array objectAtIndex:indexPath.section];
    
    RemoteConfigInfo *info = [group.array objectAtIndex:indexPath.row];
    if (self.selectViewDelegate && [self.selectViewDelegate respondsToSelector:@selector(sendConfirmSchool:)]) {
        [self.selectViewDelegate sendConfirmSchool:info];
    }

    
}
- (NSIndexPath *)tableView:(UITableView *)tableView
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    self.isSearching = NO;
    self.searchBar.text  = @"";
    [self.tableView reloadData];
    return indexPath;
}

#pragma mark - UISearchBarDelegate

//Editing Text
//开始输入时就执行
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    for (id cc in [self.searchBar subviews])
    {
        if ([cc isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)cc;
            [btn setTitle:@"取消" forState:UIControlStateNormal];
        }
    }
    return YES;
}
//searchBarShouldBeginEditing执行后，马上执行这个方法
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.searchBar.text = @" ";
//    NSLog(@"did begin");
}
//- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
//{
//    return NO;
//}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
//    NSLog(@"did end");
    self.searchBar.showsCancelButton = NO;
}
//搜索框中的内容发生改变时 回调（即要搜索的内容改变）
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self doSearchText:searchText];
    
}
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}
//Clicking Buttons
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
}
- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    self.isSearching = NO;
//    NSLog(@"cancle clicked");
    self.searchBar.text = @" ";
    [self.tableView reloadData];
    [self.searchBar resignFirstResponder];
}
- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar
{
    
}
 //Scope Button
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{

}
- (void)doSearchText:(NSString *)searchText
{
    if (self.selectViewDelegate && [self.selectViewDelegate respondsToSelector:@selector(confirmSchool:)]) {
        [self.selectViewDelegate confirmSchool:searchText];
    }

}
@end
