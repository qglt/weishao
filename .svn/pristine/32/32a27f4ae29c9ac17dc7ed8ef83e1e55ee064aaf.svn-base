//
//  SelectTypeTableView.m
//  WhistleIm
//
//  Created by 管理员 on 13-10-25.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "SelectTypeTableView.h"
#import "GetFrame.h"
#import "AddCrowdTableViewCell.m"
#import "SelectTypeTableViewCell.h"


#define TYPE_COUNTER 3

#define IMAGEVIEW_TAG 1000
#define LABEL_TAG 2000

@interface SelectTypeTableView ()
<UITableViewDataSource, UITableViewDelegate,SelectTypeTableViewCellDelegate>
{
    CGRect m_frame;
    BOOL m_isIOS7;
    UITableView * m_tableView;
    NSMutableArray * m_arrTableData;
    NSMutableArray * m_arrTableImage;
    NSMutableArray * m_arrTableSelectImage;
}

@property (nonatomic, strong) UITableView * m_tableView;
@property (nonatomic, strong) NSMutableArray * m_arrTableData;
@property (nonatomic, strong) NSMutableArray * m_arrTableImage;
@property (nonatomic, strong)  NSMutableArray * m_arrTableSelectImage;

@end

@implementation SelectTypeTableView

@synthesize m_tableView;
@synthesize m_arrTableData;
@synthesize m_arrTableImage;
@synthesize m_arrTableSelectImage;
@synthesize m_isCrowd;
@synthesize m_delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        m_frame = frame;
        m_isIOS7 = [[GetFrame shareInstance] isIOS7Version];
        [self setMemory];
        [self createBGView];
        [self createTableView];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame andIsCrowd:(BOOL)isCrowd
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        m_frame = frame;
        m_isIOS7 = [[GetFrame shareInstance] isIOS7Version];
        m_isCrowd = isCrowd;
        [self setMemory];
        [self createBGView];
        [self createTableView];
    }
    return self;
}
- (void)setMemory
{
    // ols_ic_name.png
    if (m_isCrowd) {
        self.m_arrTableData = [[NSMutableArray alloc] initWithObjects:@"群名称", @"群号", nil];
        self.m_arrTableImage = [[NSMutableArray alloc] initWithObjects:@"searchType_name", @"searchType_id", nil];
        self.m_arrTableSelectImage = [[NSMutableArray alloc] initWithObjects:@"searchType_name_P", @"searchType_id_P", nil];

    }else{
        self.m_arrTableData = [[NSMutableArray alloc] initWithObjects:@"姓名", @"昵称", @"微哨号", nil];
        self.m_arrTableImage = [[NSMutableArray alloc] initWithObjects:@"searchType_name", @"searchType_nickname", @"searchType_id", nil];
        self.m_arrTableSelectImage = [[NSMutableArray alloc] initWithObjects:@"searchType_name_P", @"searchType_nickname_P", @"searchType_id_P", nil];
    }
}

- (void)createBGView
{
    // ols_select_bg.png
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:m_frame];
    imageView.image = [UIImage imageNamed:@"ols_select_bg.png"];
    [self addSubview:imageView];
}

- (void)createTableView
{
    CGFloat y = 45 + 6;
    CGFloat height = 135;
    if (m_isCrowd) {
        height = 90;
    }
    self.m_tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, y, 98, height) style:UITableViewStylePlain];
    self.m_tableView.delegate = self;
    self.m_tableView.dataSource = self;
    self.m_tableView.rowHeight = 45.0f;
//    self.m_tableView.layer.cornerRadius = 8.0f;
    self.m_tableView.showsVerticalScrollIndicator = NO;
    self.m_tableView.scrollEnabled = NO;
    self.m_tableView.separatorColor = [UIColor clearColor];
    self.m_tableView.backgroundColor = [UIColor clearColor];
    [self setTableViewBGImage];
    [self addSubview:self.m_tableView];
}
-(void)setTableViewBGImage
{
    UIImageView * imageView = [[UIImageView alloc]init];
    if (m_isCrowd) {
        imageView.frame = CGRectMake(8, 45, 102, 97);
        imageView.image = [UIImage imageNamed:@"typeTable_BG_Two"];
    }else{
        imageView.frame = CGRectMake(8, 45, 102, 142);
        imageView.image = [UIImage imageNamed:@"typeTable_BG_Tree"];
    }
    [self addSubview:imageView];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (m_isCrowd) {
        return 2;
    }
    return TYPE_COUNTER;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId = @"cellIdentity";
    SelectTypeTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[SelectTypeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.backgroundColor = [UIColor clearColor];
        cell.delegate = self;
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellBackground.png"]];
    }
    [cell setCellData:[self.m_arrTableData objectAtIndex:indexPath.row] normalImage:[self.m_arrTableImage objectAtIndex:indexPath.row] selectImage:[self.m_arrTableSelectImage objectAtIndex:indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString * typeName = [self getSearchOptionsString:indexPath.row];
    [m_delegate typeSelected:typeName andSelectedRow:indexPath.row];
}
-(void)SelectTypeTableViewCellPressed:(id)cell
{
    NSIndexPath * indexPath = [self.m_tableView indexPathForCell:cell];
    [self tableView:self.m_tableView didSelectRowAtIndexPath:indexPath];
}
- (NSString *)getSearchOptionsString:(NSUInteger)selectedRow
{
    NSString * typeName = nil;
    if (m_isCrowd) {
        if (selectedRow == 0) {
            typeName = @"name";
        } else if (selectedRow == 1) {
            typeName = @"id";
        }
    }else{
        if (selectedRow == 0) {
            typeName = @"name";
        } else if (selectedRow == 1) {
            typeName = @"nick_name";
        } else if (selectedRow == 2) {
            typeName = @"aid";
        }
    }
    return typeName;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [m_delegate touchToRemoveSelf];
}
@end
