//
//  CommentaryView.m
//  WhistleIm
//
//  Created by 曾长欢 on 14-1-10.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "CommentaryView.h"
#import "RatingControl.h"
#import "ImUtils.h"
#import "CommentaryTableViewCell.h"
@implementation CommentaryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.dataSource = self;
        self.delegate = self;
        [self initViews];
    }
    return self;
}

- (void)initViews
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 169)];
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 80, 100)];
    img.image = [UIImage imageNamed:@"average_scores.png"];
    
    UIImage *imag1 = [self reSizeImage:[UIImage imageNamed:@"empty_star.png"] toSize:CGSizeMake(12, 12)];
    UIImage *imag2 = [self reSizeImage:[UIImage imageNamed:@"solid_star.png"] toSize:CGSizeMake(12, 12)];
    RatingControl *ratingControl = [[RatingControl alloc] initWithLocation:CGPointMake(70, 50) emptyImage:imag1 solidImage:imag2 andMaxRating:5];
    [ratingControl setRating:3];
    ratingControl.frame = CGRectMake(5, 63, 70, 50);
    [img addSubview:ratingControl];
    [headerView addSubview:img];
    
    UILabel *averageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, 80, 15)];
    averageLabel.text = @"平均评分";
    averageLabel.textAlignment = NSTextAlignmentCenter;
    averageLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11];
    averageLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0];
    [img addSubview:averageLabel];
    
    //平均评分
    self.scrorcLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 80, 44)];
    self.scrorcLabel.textAlignment = NSTextAlignmentCenter;
    self.scrorcLabel.text = @"4.5";
    self.scrorcLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:30];
    self.scrorcLabel.textColor = [UIColor colorWithRed:47/255.0 green:135/255.0 blue:185/255.0 alpha:1.0];
    
    [img addSubview:self.scrorcLabel];
    
    UILabel *lable = [[UILabel alloc] init];
    lable.frame = CGRectMake(110, 25, 34, 10);
    [lable setText:@"五星"];
    lable.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11];
    lable.textColor = [UIColor colorWithRed:38/255.0 green:38/255.0 blue:38/255.0 alpha:1.0];

    [headerView addSubview:lable];
    
    UILabel *lable2 = [[UILabel alloc] init];
    lable2.frame = CGRectMake(110, 43, 34, 10);
    lable2.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11];
    lable2.textColor = [UIColor colorWithRed:38/255.0 green:38/255.0 blue:38/255.0 alpha:1.0];
    [lable2 setText:@"四星"];
    [headerView addSubview:lable2];
    
    UILabel *lable3 = [[UILabel alloc] init];
    lable3.frame = CGRectMake(110,61, 34, 10);
    [lable3 setText:@"三星"];
    lable3.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11];
    lable3.textColor = [UIColor colorWithRed:38/255.0 green:38/255.0 blue:38/255.0 alpha:1.0];
    [headerView addSubview:lable3];
    
    UILabel *lable4 = [[UILabel alloc] init];
    lable4.frame = CGRectMake(110,79, 34, 10);
    [lable4 setText:@"二星"];
    lable4.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11];
    lable4.textColor = [UIColor colorWithRed:38/255.0 green:38/255.0 blue:38/255.0 alpha:1.0];
    [headerView addSubview:lable4];
    
    UILabel *lable5 = [[UILabel alloc] init];
    lable5.frame = CGRectMake(110,97, 34, 10);
    [lable5 setText:@"一星"];
    lable5.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11];
    lable5.textColor = [UIColor colorWithRed:38/255.0 green:38/255.0 blue:38/255.0 alpha:1.0];
    [headerView addSubview:lable5];
    
    
    //添加评分进度条
    self.fiveStarView = [[UIProgressView alloc] initWithFrame:CGRectMake(142, 29, 127.5, 2)];
    [self.fiveStarView setProgressViewStyle:UIProgressViewStyleDefault];
    self.fiveStarView.trackTintColor = [ImUtils colorWithHexString:@"#e1e1e1"];
    self.fiveStarView.progressTintColor = [ImUtils colorWithHexString:@"#2f87b9"];
    self.fiveStarView.layer.masksToBounds = YES;
    self.fiveStarView.layer.cornerRadius = 1.0f;
    [headerView addSubview:self.fiveStarView];
    
    self.fourStarView = [[UIProgressView alloc] initWithFrame:CGRectMake(142, 29+18, 127.5, 2)];
    [self.fourStarView setProgressViewStyle:UIProgressViewStyleDefault];
    self.fourStarView.trackTintColor = [ImUtils colorWithHexString:@"#e1e1e1"];
    self.fourStarView.progressTintColor = [ImUtils colorWithHexString:@"#2f87b9"];
    self.fourStarView.layer.masksToBounds = YES;
    self.fourStarView.layer.cornerRadius = 1.0f;
    [headerView addSubview:self.fourStarView];
    
    self.threeStarView = [[UIProgressView alloc] initWithFrame:CGRectMake(142, 29+36, 127.5, 2)];
    [self.threeStarView setProgressViewStyle:UIProgressViewStyleDefault];
    self.threeStarView.trackTintColor = [ImUtils colorWithHexString:@"#e1e1e1"];
    self.threeStarView.progressTintColor = [ImUtils colorWithHexString:@"#2f87b9"];
    self.threeStarView.layer.masksToBounds = YES;
    self.threeStarView.layer.cornerRadius = 1.0f;
    [headerView addSubview:self.threeStarView];
    
    self.twoStarView = [[UIProgressView alloc] initWithFrame:CGRectMake(142, 29+54, 127.5, 2)];
    [self.twoStarView setProgressViewStyle:UIProgressViewStyleDefault];
    self.twoStarView.trackTintColor = [ImUtils colorWithHexString:@"#e1e1e1"];
    self.twoStarView.progressTintColor = [ImUtils colorWithHexString:@"#2f87b9"];
    self.twoStarView.layer.masksToBounds = YES;
    self.twoStarView.layer.cornerRadius = 1.0f;
    [headerView addSubview:self.twoStarView];
    
    self.oneStarView = [[UIProgressView alloc] initWithFrame:CGRectMake(142, 29+72, 127.5, 2)];
    [self.oneStarView setProgressViewStyle:UIProgressViewStyleDefault];
    self.oneStarView.trackTintColor = [ImUtils colorWithHexString:@"#e1e1e1"];
    self.oneStarView.progressTintColor = [ImUtils colorWithHexString:@"#2f87b9"];
    self.oneStarView.layer.masksToBounds = YES;
    self.oneStarView.layer.cornerRadius = 1.0f;
    [headerView addSubview:self.oneStarView];
    
    self.fiveStarLabel = [[UILabel alloc] initWithFrame:CGRectMake(157+127.5, 25, 34, 10)];
    self.fiveStarLabel.textColor = [ImUtils colorWithHexString:@"#262626"];
    self.fiveStarLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11];
    [headerView addSubview:self.fiveStarLabel];
    
    self.fourStarLabel = [[UILabel alloc] initWithFrame:CGRectMake(157+127.5, 43, 34, 10)];
    self.fourStarLabel.textColor = [ImUtils colorWithHexString:@"#262626"];
    self.fourStarLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11];
    [headerView addSubview:self.fourStarLabel];
    
    self.threeStarLabel = [[UILabel alloc] initWithFrame:CGRectMake(157+127.5, 61, 34, 10)];
    self.threeStarLabel.textColor = [ImUtils colorWithHexString:@"#262626"];
    self.threeStarLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11];
    [headerView addSubview:self.threeStarLabel];
    
    self.twoStarLabel = [[UILabel alloc] initWithFrame:CGRectMake(157+127.5, 79, 34, 10)];
    self.twoStarLabel.textColor = [ImUtils colorWithHexString:@"#262626"];
    self.twoStarLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11];
    [headerView addSubview:self.twoStarLabel];
    
    self.oneStarLabel = [[UILabel alloc] initWithFrame:CGRectMake(157+127.5, 97, 34, 10)];
    self.oneStarLabel.textColor = [ImUtils colorWithHexString:@"#262626"];
    self.oneStarLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11];
    [headerView addSubview:self.oneStarLabel];
    
    
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"我来评论" forState:0];
    button.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15];
    [button setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forState:0];
    button.tag = 1000;
    button.frame = CGRectMake(0, 130, 320, 39);
    button.backgroundColor = [UIColor colorWithRed:37/255.0 green:115/255.0 blue:170/255.0 alpha:1.0];
    [button addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:button];
    self.tableHeaderView  = headerView;
    
    
    
}
- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize

{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return reSizeImage;
    
}
#pragma mark -　btnAction
- (void)btnAction:(UIButton *)sender
{

    if ([self.scrollViewDelegate respondsToSelector:@selector(pushCommentController)]) {
        [self.scrollViewDelegate pushCommentController];
    }
}

#pragma mark -
#pragma mark UITableViewDataSource and UITableViewDelegate Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectio
{
     return [self.infoArray count];
}
- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    CommentaryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CommentaryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellBackground.png"]];
    }
 
//    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 40, 40)];
//    img.image = [UIImage imageNamed:@"app_default.png"];
//    [cell.contentView addSubview:img];
    
    AppCommentItem *item = [self.infoArray objectAtIndex:indexPath.row];
    [cell setCellData:item];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

@end
