//
//  CrowdVoteTableView.m
//  WhistleIm
//
//  Created by 管理员 on 14-1-8.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "CrowdVoteTableView.h"
#import "GrowdVoteTableViewCell.h"
#import "GBPathImageView.h"
#import "VoteCellInfo.h"
#import "ImUtils.h"


#define  CELL_HEIGHT 45.0f
@interface CrowdVoteTableView ()
<UITableViewDataSource, UITableViewDelegate>
{
    CGRect m_frame;
    BOOL m_isSingleType;
    NSMutableArray * m_arrTableData;
    NSMutableDictionary * m_dictInfo;
    UITableView * m_tableView;
    
    UIImageView * m_personalHeader;
    UILabel * m_votePersonLabel;
    UILabel * m_signTypeLabel;
    UILabel * m_voteTimeLabel;
    UILabel * m_voteNameLabel;
    
    UIView * m_headerBGView;
    
    NSMutableArray * m_arrSelectedState;
    NSMutableArray * m_arrTableAllData;
    UIButton * m_voteButton;
}

@property (nonatomic, strong) NSMutableArray * m_arrTableData;
@property (nonatomic, strong) NSMutableDictionary * m_dictInfo;
@property (nonatomic, strong) UITableView * m_tableView;
@property (nonatomic, strong) UIImageView * m_personalHeader;
@property (nonatomic, strong) UILabel * m_votePersonLabel;
@property (nonatomic, strong) UILabel * m_signTypeLabel;
@property (nonatomic, strong) UILabel * m_voteTimeLabel;
@property (nonatomic, strong) UILabel * m_voteNameLabel;
@property (nonatomic, strong) UIView * m_headerBGView;
@property (nonatomic, strong) NSMutableArray * m_arrSelectedState;
@property (nonatomic, strong) NSMutableArray * m_arrTableAllData;
@property (nonatomic, strong) UIButton * m_voteButton;



@end

@implementation CrowdVoteTableView

@synthesize m_arrTableData;
@synthesize m_dictInfo;
@synthesize m_tableView;
@synthesize m_personalHeader;
@synthesize m_votePersonLabel;
@synthesize m_signTypeLabel;
@synthesize m_voteTimeLabel;
@synthesize m_voteNameLabel;
@synthesize m_headerBGView;
@synthesize m_arrSelectedState;
@synthesize m_arrTableAllData;
@synthesize m_voteButton;
@synthesize m_delegate;
@synthesize m_isShowVoteRatio;
@synthesize m_hadVoted;
@synthesize m_anonymous;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        m_frame = frame;
        [self setMemory];
        [self createTableView];
        [self createVoteButton];
    }
    return self;
}

- (void)setMemory
{
    self.m_arrSelectedState = [[NSMutableArray alloc] initWithCapacity:0];
    self.m_arrTableAllData = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)setSeletedStateMemoryWithCount:(NSUInteger)itemCount
{
    [self.m_arrSelectedState removeAllObjects];
    for (NSUInteger i = 0; i < itemCount; i++) {
        NSNumber * isSelected = [NSNumber numberWithBool:NO];
        [self.m_arrSelectedState addObject:isSelected];
    }
}

- (void)setAllTableDataMemoryWithArr:(NSMutableArray *)tableDataArr
{
    [self.m_arrTableAllData removeAllObjects];
    
    NSNumber * voteType = [self.m_dictInfo objectForKey:@"voteType"];

    for (NSUInteger i = 0; i < [tableDataArr count]; i++) {
        VoteCellInfo * cellInfo = [[VoteCellInfo alloc] init];
        cellInfo.m_content = [tableDataArr objectAtIndex:i];
        cellInfo.m_isSelectedState = [[self.m_arrSelectedState objectAtIndex:i] boolValue];
        cellInfo.m_isSingle = [voteType boolValue];
        if (i == 0) {
            cellInfo.m_hasHeaderLine = YES;
        } else {
            cellInfo.m_hasHeaderLine = NO;
        }
        [self.m_arrTableAllData addObject:cellInfo];
    }
}

- (UIView *)getTableViewHeaderViewWithFrame:(CGRect)frame
{
    self.m_headerBGView = [[UIView alloc] initWithFrame:frame];
    self.m_headerBGView.backgroundColor = [UIColor whiteColor];
    [self createHeaderImageView];
    [self createLabels];
    return self.m_headerBGView;
}

- (void)createHeaderImageView
{
    self.m_personalHeader = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 36, 36)];
    self.m_personalHeader.layer.cornerRadius = 36.0 / 2.0f;
    self.m_personalHeader.backgroundColor = [UIColor clearColor];
    self.m_personalHeader.clipsToBounds = YES;
    self.m_personalHeader.userInteractionEnabled = YES;
    [self.m_headerBGView addSubview:self.m_personalHeader];
}

- (void)createLabels
{
    UIColor * textColor = [ImUtils colorWithHexString:@"#262626"];
    UIFont * bigFont = [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
    UIFont * smallFont = [UIFont fontWithName:@"STHeitiSC-Thin" size:11.0f];
    
    self.m_votePersonLabel = [self createLabelWithFrame:CGRectMake(15 + 36 + 10, 15, 000, 00) andText:nil andFont:bigFont andTextColor:textColor];
    [self.m_headerBGView addSubview:self.m_votePersonLabel];

    self.m_signTypeLabel = [self createLabelWithFrame:CGRectMake(0, 18, 0, 0) andText:nil andFont:smallFont andTextColor:textColor];
    [self.m_headerBGView addSubview:self.m_signTypeLabel];

    self.m_voteTimeLabel = [self createLabelWithFrame:CGRectMake(15 + 36 + 10, 34, m_frame.size.width - 61 - 15, 0) andText:nil andFont:smallFont andTextColor:textColor];
    [self.m_headerBGView addSubview:self.m_voteTimeLabel];

    self.m_voteNameLabel = [self createLabelWithFrame:CGRectMake(15, 69, m_frame.size.width - 15 - 15, 0) andText:nil andFont:bigFont andTextColor:textColor];
    [self.m_headerBGView addSubview:self.m_voteNameLabel];
}

- (UILabel *)createLabelWithFrame:(CGRect)frame andText:(NSString *)text andFont:(UIFont *)font andTextColor:(UIColor *)color
{
    UILabel * label = [[UILabel alloc] initWithFrame:frame];
    label.textAlignment = NSTextAlignmentLeft;
    label.text = text;
    label.font = font;
    label.textColor = color;
    label.backgroundColor = [UIColor clearColor];
    [self addSubview:label];
    return label;
}

- (void)createTableView
{
    self.m_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, m_frame.size.width, m_frame.size.height - 45 - 20) style:UITableViewStylePlain];
    self.m_tableView.delegate = self;
    self.m_tableView.dataSource = self;
    self.m_tableView.hidden = YES;
    self.m_tableView.showsVerticalScrollIndicator = NO;
    self.m_tableView.rowHeight = CELL_HEIGHT;
    self.m_tableView.separatorColor = [UIColor clearColor];
    self.m_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.m_tableView.backgroundColor = [UIColor clearColor];
    self.m_tableView.tableHeaderView = [self getTableViewHeaderViewWithFrame:CGRectMake(0, 0, m_frame.size.width, 100)];
    [self addSubview:self.m_tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.m_hadVoted) {
        return [self.m_arrTableAllData count];
    } else {
        return [self.m_arrTableData count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellID = @"vote";
    GrowdVoteTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[GrowdVoteTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellBackground.png"]];
    }
    
    if (self.m_isShowVoteRatio) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.m_isShowVoteRatio = self.m_isShowVoteRatio;
   
    [cell setCellDataWithInfo:[self.m_arrTableAllData objectAtIndex:indexPath.row]];
    
    if (indexPath.row == 0) {
        [cell showHeaderLine:YES];
    } else {
        [cell showHeaderLine:NO];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

- (void)refreshTableViewWithData:(NSMutableArray *)tableData andInfoDict:(NSMutableDictionary *)dict
{
    self.m_tableView.hidden = NO;
    self.m_voteButton.hidden = NO;
    self.m_arrTableData = tableData;
    self.m_dictInfo = dict;
    
    [self resetHeaderView];
    [self setSeletedStateMemoryWithCount:[self.m_arrTableData count]];
    [self setAllTableDataMemoryWithArr:self.m_arrTableData];
    
    
    [self.m_tableView reloadData];
}

- (void)resetHeaderView
{
    NSString * personName = [self.m_dictInfo objectForKey:@"votePerson"];
    self.m_votePersonLabel.text = personName;
    CGSize personNameSize = [personName sizeWithFont:self.m_votePersonLabel.font constrainedToSize:CGSizeMake(m_frame.size.width - 15 - 36 - 10 - 15, 10000)  lineBreakMode:NSLineBreakByWordWrapping];
    CGRect nameFrame = self.m_votePersonLabel.frame;
    nameFrame.size.width = personNameSize.width;
    if (m_frame.size.width - 15 - 36 - 10 - personNameSize.width - 15 < 52.0f) {
        nameFrame.size.width = m_frame.size.width - 15 - 36 - 10 - 15 - 52;
    }
    nameFrame.size.height = personNameSize.height;
    self.m_votePersonLabel.frame = nameFrame;

    NSString * signType = [self.m_dictInfo objectForKey:@"signType"];
    self.m_signTypeLabel.text = signType;
    CGSize typeSize = [signType sizeWithFont:self.m_signTypeLabel.font constrainedToSize:CGSizeMake(m_frame.size.width - 15 - 36 - 10 - 15, 10000)  lineBreakMode:NSLineBreakByWordWrapping];
    CGRect typeFrame = self.m_signTypeLabel.frame;
    typeFrame.origin.x = personNameSize.width + nameFrame.origin.x;
    typeFrame.size.width = typeSize.width;
    typeFrame.size.height = typeSize.height;
    self.m_signTypeLabel.frame = typeFrame;
    NSLog(@"typeSize -=  == %@", NSStringFromCGSize(typeSize));
    
    NSString * voteTime = [self.m_dictInfo objectForKey:@"voteTime"];
    self.m_voteTimeLabel.text = voteTime;
    CGRect timeFrame = self.m_voteTimeLabel.frame;
    timeFrame.size.height = typeSize.height;
    self.m_voteTimeLabel.frame = timeFrame;
    
    NSString * voteName = [self.m_dictInfo objectForKey:@"voteName"];
    self.m_voteNameLabel.text = voteName;
    CGRect voteNameFrame = self.m_voteNameLabel.frame;
    voteNameFrame.size.height = personNameSize.height;
    self.m_voteNameLabel.frame = voteNameFrame;
    
    self.m_personalHeader.image = [self.m_dictInfo objectForKey:@"image"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.m_isShowVoteRatio) {
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSNumber * voteType = [self.m_dictInfo objectForKey:@"voteType"];
    [self resetSeletedStateArrWithType:[voteType boolValue] andIndex:indexPath.row];
    [self resetAllTableDataWithArr:self.m_arrSelectedState];
    [self.m_tableView reloadData];
    
//    [self enableVoteButton];
}

- (void)enableVoteButton
{
    BOOL enable = NO;
    for (NSUInteger i = 0; i < [self.m_arrSelectedState count]; i++) {
        BOOL selected = [[self.m_arrSelectedState objectAtIndex:i] boolValue];
        if (selected) {
            enable = YES;
            break;
        }
    }
    
    self.m_voteButton.userInteractionEnabled = enable;
}

- (void)resetSeletedStateArrWithType:(BOOL)isSingleType andIndex:(NSUInteger)index
{
    if (isSingleType) {
        [self setSeletedStateMemoryWithCount:[self.m_arrTableData count]];
        NSNumber * newType = [NSNumber numberWithBool:isSingleType];
        [self.m_arrSelectedState replaceObjectAtIndex:index withObject:newType];
    } else {
        NSNumber * moreType = [self.m_arrSelectedState objectAtIndex:index];
        BOOL isMoreSelected = [moreType boolValue];
        isMoreSelected = !isMoreSelected;
        NSNumber * newType = [NSNumber numberWithBool:isMoreSelected];
        [self.m_arrSelectedState replaceObjectAtIndex:index withObject:newType];
    }
    
    NSLog(@"m_arrSelectedState in CrowdVoteTableView == %@", self.m_arrSelectedState);
}

- (void)resetAllTableDataWithArr:(NSMutableArray *)selectedStateArr
{
    for (NSUInteger i = 0; i < [selectedStateArr count]; i++) {
        VoteCellInfo * cellInfo = [self.m_arrTableAllData objectAtIndex:i];
        cellInfo.m_isSelectedState = [[selectedStateArr objectAtIndex:i] boolValue];
    }
}

- (void)refreshTableViewWithVotePercentageData:(NSMutableArray *)votePercentageData andInfoDict:(NSMutableDictionary *)dict
{
    self.m_tableView.hidden = NO;
    self.m_voteButton.hidden = NO;
    self.m_arrTableAllData = votePercentageData;
    self.m_dictInfo = dict;
    [self resetHeaderView];

    [self.m_tableView reloadData];
    
    [self resetButtonTitle];
}

- (void)resetButtonTitle
{
    if (self.m_isShowVoteRatio) {
        NSArray * subViews = self.m_voteButton.subviews;
        for (UIView * view in subViews) {
            if ([view isKindOfClass:[UILabel class]]) {
                UILabel * btnLabel = (UILabel *)view;
                btnLabel.text = @"查看投票名单";
            }
        }
    }
    
//    self.m_voteButton.userInteractionEnabled = YES;
    
    if (self.m_anonymous) {
        self.m_voteButton.hidden = YES;
    } else {
        self.m_voteButton.hidden = NO;
    }
}

- (void)createVoteButton
{
    CGFloat y = m_frame.size.height - 45 - 10;
    // redBtnImageNormal.png   redBtnImageHighLight.png  blueButtonNormal.png  blueButtonPressed.png
    self.m_voteButton = [self createButtonsWithFrame:CGRectMake(0, y, m_frame.size.width, 45) andTitle:@"投票" andImage:@"blueButtonNormal.png" andSelectedImage:@"blueButtonPressed.png" andTag:1000];
    self.m_voteButton.hidden = YES;
//    self.m_voteButton.userInteractionEnabled = NO;
    [self addSubview:self.m_voteButton];
}

- (UIButton *)createButtonsWithFrame:(CGRect)frame andTitle:(NSString *)title andImage:(NSString *)imagePath andSelectedImage:(NSString *)selectedImagePath andTag:(NSUInteger)tag
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:imagePath] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:selectedImagePath] forState:UIControlStateSelected];
    [button setBackgroundImage:[UIImage imageNamed:selectedImagePath] forState:UIControlStateHighlighted];
    button.frame = frame;
    button.tag = tag;
    button.backgroundColor = [UIColor redColor];
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, button.frame.size.width, button.frame.size.height)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.text = title;
    [button addSubview:label];
    
    return button;
}

- (void)buttonPressed:(UIButton *)button
{
    if (self.m_isShowVoteRatio == NO) {
        [m_delegate voteButtonPressed:self.m_arrSelectedState];
    } else {
        [m_delegate showVoteList];
    }
}

@end
