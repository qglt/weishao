//
//  SettingTableView.m
//  WhistleIm
//
//  Created by 管理员 on 13-12-6.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "SettingTableView.h"
#define SOUND_TYPE_COUNT 4

@interface SettingTableView ()
<UITableViewDataSource, UITableViewDelegate>
{
    CGRect m_frame;
    UITableView * m_tableView;
    UISwitch * m_soundSwitch;
    UISwitch * m_shakeSwitch;
    
    NSMutableArray * m_arrSwitchState;
}

@property (nonatomic, strong) UITableView * m_tableView;
@property (nonatomic, strong) UISwitch * m_soundSwitch;
@property (nonatomic, strong) UISwitch * m_shakeSwitch;
@property (nonatomic, strong) NSMutableArray * m_arrSwitchState;


@end

@implementation SettingTableView

@synthesize m_tableView;
@synthesize m_soundSwitch;
@synthesize m_shakeSwitch;
@synthesize m_arrSwitchState;

@synthesize m_delegate;

- (id)initWithFrame:(CGRect)frame withDataArr:(NSMutableArray *)dataArr
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        m_frame = frame;
        self.m_arrSwitchState = dataArr;
        [self createBGViews];
        [self createSettingTableView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)createBGViews
{
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, m_frame.size.width, m_frame.size.height)];
    imageView.image = nil;
    imageView.userInteractionEnabled = YES;
    [self addSubview:imageView];
}

- (void)createSettingTableView
{
    self.m_tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 0, m_frame.size.width - 20, 380) style:UITableViewStylePlain];
    self.m_tableView.delegate = self;
    self.m_tableView.dataSource = self;
    self.m_tableView.rowHeight = 50.0f;
    self.m_tableView.sectionHeaderHeight = 10.0f;
    self.m_tableView.separatorColor = [UIColor clearColor];
    self.m_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.m_tableView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.m_tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return 3;
    } else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, m_frame.size.width, 10)];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellBackground.png"]];
        CGRect frame = CGRectMake(0, 0, m_frame.size.width - 20, 50);
        NSUInteger btnTag = 1000 + indexPath.section * 10 + indexPath.row;
        UIButton * btn = nil;
        if (indexPath.section == 0) {
            
            CGFloat x = 240.0f;
            if (!isIOS7) {
                x = 200.0f;
            }
            if (indexPath.row == 0) {
                UIImageView * imageView = [self getCellBGImageViewWithFrame:CGRectMake(0, 0, m_frame.size.width - 20, 50) andImagePath:@"com_but1.png"];
                [cell addSubview:imageView];
                
                self.m_soundSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(x, 10, 30, 20)];
                [self.m_soundSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
                self.m_soundSwitch.on = [[self.m_arrSwitchState objectAtIndex:indexPath.row] boolValue];
                [cell addSubview:self.m_soundSwitch];
            } else if (indexPath.row == 1) {
                UIImageView * imageView = [self getCellBGImageViewWithFrame:CGRectMake(0, 0, m_frame.size.width - 20, 50) andImagePath:@"com_but3.png"];
                [cell addSubview:imageView];
                self.m_shakeSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(x, 10, 30, 20)];
                [self.m_shakeSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
                self.m_shakeSwitch.on = [[self.m_arrSwitchState objectAtIndex:indexPath.row] boolValue];
                [cell addSubview:self.m_shakeSwitch];
            }
        }
     
        
        else if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                btn = [self createButtonsWithFrame:frame andTitle:nil andImage:@"com_but1.png" andSelectedImage:@"com_but1_pre.png" andTag:btnTag];
                [cell addSubview:btn];
            } else if (indexPath.row == 1) {
                btn = [self createButtonsWithFrame:frame andTitle:nil andImage:@"com_but2.png" andSelectedImage:@"com_but2_pre.png" andTag:btnTag];
                [cell addSubview:btn];
            } else if (indexPath.row == 2) {
                btn = [self createButtonsWithFrame:frame andTitle:nil andImage:@"com_but3.png" andSelectedImage:@"com_but3_pre.png" andTag:btnTag];
                [cell addSubview:btn];
            }
        }
        
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 200, 50)];
        label.textAlignment = NSTextAlignmentLeft;
        label.backgroundColor = [UIColor clearColor];
        label.tag = 1000;
        [cell addSubview:label];
    }
    
    UILabel * label = (UILabel *)[cell viewWithTag:1000];

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            label.text = @"声音";
        } else if (indexPath.row == 1) {
            label.text = @"震动";
        }
    } else if (indexPath.section  == 1) {
           if (indexPath.row == 0) {
               label.text = @"关于";
           } else if (indexPath.row == 1) {
               label.text = @"反馈";
           } else if (indexPath.row == 2) {
               label.text = @"切换账号";
           }
       }
    
    if (indexPath.section != 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.section == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

- (UIImageView *)getCellBGImageViewWithFrame:(CGRect)frame andImagePath:(NSString *)path
{
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.userInteractionEnabled = YES;
    imageView.image = [UIImage imageNamed:path];
    return imageView;
}

- (UIButton *)createButtonsWithFrame:(CGRect)frame andTitle:(NSString *)title andImage:(NSString *)imagePath andSelectedImage:(NSString *)selectedImagePath andTag:(NSUInteger)tag
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:imagePath] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:selectedImagePath] forState:UIControlStateSelected];
    [button setBackgroundImage:[UIImage imageNamed:selectedImagePath] forState:UIControlStateHighlighted];
    button.frame = frame;
    button.tag = tag;
    [button addTarget:self action:@selector(functionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, button.frame.size.width - 20, button.frame.size.height)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor blackColor];
    label.text = title;
    [button addSubview:label];
    
    return button;
}

- (void)functionButtonPressed:(id)sender
{
    UIButton * button = (UIButton *)sender;
    if (button.tag == 1010) {

        [m_delegate AboutButtonPressed:button];
    } else if (button.tag == 1011) {

        [m_delegate feedBackButtonPressed:button];
    } else if (button.tag == 1012) {
//        [self doChangeUser];
        
        [m_delegate changeAccountButtonPressed:button];
        [m_delegate removeAppList];
    }
}

- (void)switchChanged:(id)sender
{
    UISwitch * mySwitch = (UISwitch *)sender;
    UITableViewCell * cell = (UITableViewCell *)[mySwitch superview];
    NSIndexPath * indexPath = [self.m_tableView indexPathForCell:cell];
    [self.m_arrSwitchState replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:mySwitch.on]];
    
    [self setUserDefaltObject];
}

- (void)setUserDefaltObject
{
    NSMutableArray * soundArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSUInteger i = 0; i < SOUND_TYPE_COUNT; i++) {
        [soundArr addObject:[NSNumber numberWithBool:NO]];
    }
    if (self.m_soundSwitch.on && self.m_shakeSwitch.on) {
        [soundArr replaceObjectAtIndex:SOUND_TYPE_COUNT - 2 withObject:[NSNumber numberWithBool:YES]];
    } else if (self.m_soundSwitch.on) {
        [soundArr replaceObjectAtIndex:0 withObject:[NSNumber numberWithBool:YES]];
    } else if (self.m_shakeSwitch.on) {
        [soundArr replaceObjectAtIndex:SOUND_TYPE_COUNT - 3 withObject:[NSNumber numberWithBool:YES]];
    } else if (!self.m_soundSwitch.on && !self.m_shakeSwitch.on) {
        [soundArr replaceObjectAtIndex:SOUND_TYPE_COUNT - 1 withObject:[NSNumber numberWithBool:YES]];
    }
    
    NSLog(@"sound array == %@", soundArr);
    [m_delegate switchClicked:soundArr];
}

@end
