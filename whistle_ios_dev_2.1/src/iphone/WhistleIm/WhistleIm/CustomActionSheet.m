//
//  CustomActionSheet.m
//  WhistleIm
//
//  Created by 管理员 on 14-3-3.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "CustomActionSheet.h"
#import "ImUtils.h"

#define HEADER_HEIGHT 8.0f
static BOOL m_canShowNext = YES;
@interface CustomActionSheet ()

<UITableViewDataSource, UITableViewDelegate>
{
    CGRect m_frame;
    
    UITableView * m_tableView;
    NSArray * m_arrTitleArr;
    NSString * m_closedTitle;
    UIImageView * m_bgImageView;
    
    UIWindow * m_window;
    NSString * m_description;
    
    BOOL m_hadDescription;
    
    BOOL m_descriptionHeight;
}

@property (nonatomic, strong) UITableView * m_tableView;
@property (nonatomic, strong) NSArray * m_arrTitleArr;
@property (nonatomic, strong) NSString * m_closedTitle;
@property (nonatomic, strong) UIImageView * m_bgImageView;
@property (nonatomic, strong) UIWindow * m_window;
@property (nonatomic, strong) NSString * m_description;

@end

@implementation CustomActionSheet

@synthesize m_tableView;
@synthesize m_arrTitleArr;
@synthesize m_closedTitle;
@synthesize m_bgImageView;
@synthesize m_delegate;
@synthesize m_window;
@synthesize m_description;

- (id)initWithTitleArr:(NSArray *)titleArr andDelegate:(id)delegate andDescription:(NSString *)description
{
    if (m_canShowNext) {
        self = [super init];
        if (self) {
            // Initialization code
            
            [self setBasicCondition];
            self.m_delegate = delegate;
            self.m_arrTitleArr = titleArr;
            self.m_description = description;
            
            UIFont * font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
            CGSize textSize = [self.m_description sizeWithFont:font constrainedToSize:CGSizeMake(280, 10000) lineBreakMode:NSLineBreakByWordWrapping];
            NSLog(@"textSize == %@", NSStringFromCGSize(textSize));
            m_descriptionHeight = textSize.height;
            
            [self createBGImageView];
            if (self.m_description && [self.m_description length] > 0) {
                m_hadDescription = YES;
    
            } else {
                m_hadDescription = NO;
            }
            
            [self createTableView];
        }
        m_canShowNext = NO;
        return self;
    } else {
        return nil;
    }
    
    NSLog(@"canshowNext in init == %d", m_canShowNext);
}

- (void)setBasicCondition
{
    m_frame = [[UIScreen mainScreen] bounds];
    self.frame = m_frame;
    self.alpha = 0.0f;
}

- (void)createBGImageView
{
    self.m_bgImageView = [[UIImageView alloc] initWithFrame:m_frame];
    self.m_bgImageView.image = [UIImage imageNamed:@"customAlertBG.png"];
    self.m_bgImageView.userInteractionEnabled = YES;
    self.m_bgImageView.alpha = 0.0f;
    [self addSubview:self.m_bgImageView];
}

- (void)createTableView
{
    CGFloat height = 0.0f;
    if (!m_hadDescription) {
        height = 45 * [self.m_arrTitleArr count] + HEADER_HEIGHT * 3;
    } else {
        height = 45 * [self.m_arrTitleArr count] + HEADER_HEIGHT * 2 + m_descriptionHeight + 40;
    }
    
    self.m_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, m_frame.size.height, m_frame.size.width, height) style:UITableViewStylePlain];
    
    self.m_tableView.delegate = self;
    self.m_tableView.dataSource = self;
    self.m_tableView.showsVerticalScrollIndicator = NO;
    self.m_tableView.separatorColor = [UIColor clearColor];
    self.m_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.m_tableView.backgroundColor = [UIColor whiteColor];
    self.m_tableView.scrollEnabled = NO;
    [self.m_bgImageView addSubview:self.m_tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!m_hadDescription) {
        return 3;
    } else {
        return 3;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!m_hadDescription) {
        if (section == 0) {
            return [self.m_arrTitleArr count] - 1;
        } else if (section == 1) {
            return 1;
        } else if (section == 2) {
            return 0;
        }
    } else {
        if (section == 0) {
            return 2;
        } else if (section == 1) {
            return 1;
        } else if (section == 2) {
            return 0;
        }
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (!m_hadDescription) {
        return HEADER_HEIGHT;
    } else {
        if (section == 0) {
            return 0;
        } else {
            return HEADER_HEIGHT;
        }
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!m_hadDescription) {
        return 45.0f;
    } else {
        if (indexPath.section == 0 && indexPath.row == 0) {
            return m_descriptionHeight + 40.0f;
        } else {
            return 45.0f;
        }
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!m_hadDescription) {
        UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, m_frame.size.width, HEADER_HEIGHT)];
        headerView.backgroundColor = [ImUtils colorWithHexString:@"#F0F0F0"];
        return headerView;
    } else {
        if (section == 0) {
            return nil;
        } else {
            UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, m_frame.size.width, HEADER_HEIGHT)];
            headerView.backgroundColor = [ImUtils colorWithHexString:@"#F0F0F0"];
            return headerView;
        }
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!m_hadDescription) {
        static NSString * cellId = @"show";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellBackground.png"]];
            
            UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, m_frame.size.width, 45)];
            label.textAlignment = NSTextAlignmentCenter;
            label.tag = 1000;
            label.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
            label.textColor = [ImUtils colorWithHexString:@"#262626"];
            label.highlightedTextColor = [UIColor whiteColor];
            label.backgroundColor = [UIColor clearColor];
            [cell addSubview:label];
            
            UIView * headerLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, m_frame.size.width, 0.5)];
            headerLine.backgroundColor = [UIColor colorWithRed:224.0f / 255.0f green:224.0f / 255.0f blue:224.0f / 255.0f alpha:1.0f];
            [cell addSubview:headerLine];
            
            if (indexPath.section == 1 || (indexPath.section == 0 && indexPath.row == [self.m_arrTitleArr count] - 2)) {
                UIView * footerLine = [[UIView alloc] initWithFrame:CGRectMake(0, 45 - 0.5, m_frame.size.width, 0.5)];
                footerLine.backgroundColor = [UIColor colorWithRed:224.0f / 255.0f green:224.0f / 255.0f blue:224.0f / 255.0f alpha:1.0f];
                [cell addSubview:footerLine];
            }
        }
        
        UILabel * label = (UILabel *)[cell viewWithTag:1000];
        
        if (indexPath.section == 0) {
            label.text = [self.m_arrTitleArr objectAtIndex:indexPath.row];
        } else if (indexPath.section == 1) {
            label.text = [self.m_arrTitleArr objectAtIndex:[self.m_arrTitleArr count] - 1];
        }
        
        return cell;
    } else {
        static NSString * cellId = @"show";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellBackground.png"]];
            
            CGFloat x = 20.0f;
            CGFloat y = 0.0f;
            CGFloat width = m_frame.size.width - 40.0f;
            CGFloat height = 45.0f;
            if (indexPath.section == 0 && indexPath.row == 0) {
                height = m_descriptionHeight;
                y = 20.0f;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
            label.textAlignment = NSTextAlignmentCenter;
            label.tag = 1000;
            label.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
            label.textColor = [ImUtils colorWithHexString:@"#262626"];
            label.highlightedTextColor = [UIColor whiteColor];
            label.backgroundColor = [UIColor clearColor];
            [cell addSubview:label];

            UIView * headerLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, m_frame.size.width, 0.5)];
            headerLine.backgroundColor = [UIColor colorWithRed:224.0f / 255.0f green:224.0f / 255.0f blue:224.0f / 255.0f alpha:1.0f];
            [cell addSubview:headerLine];

            if (indexPath.section == 1 || (indexPath.section == 0 && indexPath.row == [self.m_arrTitleArr count] - 1)) {
                UIView * footerLine = [[UIView alloc] initWithFrame:CGRectMake(0, 45 - 0.5, m_frame.size.width, 0.5)];
                footerLine.backgroundColor = [UIColor colorWithRed:224.0f / 255.0f green:224.0f / 255.0f blue:224.0f / 255.0f alpha:1.0f];
                [cell addSubview:footerLine];
            }
        
            NSLog(@"had none description section == %d", indexPath.section);
            NSLog(@"had none description == %d", indexPath.row);
        }
        
        UILabel * label = (UILabel *)[cell viewWithTag:1000];
        
        if (indexPath.section == 0 && indexPath.row == 0) {
            label.text = self.m_description;
        } else if (indexPath.section == 0 && indexPath.row == 1) {
            label.text = [self.m_arrTitleArr objectAtIndex:0];
        } else if (indexPath.section == 1 && indexPath.row == 0) {
            label.text = [self.m_arrTitleArr objectAtIndex:1];
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
    if (m_hadDescription) {
        if (indexPath.section == 0 && indexPath.row == 0) {
            cell.backgroundColor = [ImUtils colorWithHexString:@"#F0F0F0"];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!m_hadDescription) {
        m_canShowNext = YES;
        NSUInteger index = 0;
        if (indexPath.section == 0) {
            index = indexPath.row;
        } else if (indexPath.section == 1) {
            index = [self.m_arrTitleArr count] - 1;
        }
        
        NSLog(@"CustomActionSheet clickedButtonAtIndex for none description == %d", index);
        [m_delegate customActionSheet:self clickedButtonAtIndex:index];
        [self removeSelf];

    } else {
        if ((indexPath.section == 0 && indexPath.row == 1) || indexPath.section == 1) {
            m_canShowNext = YES;
            NSUInteger index = 0;
            if (indexPath.section == 0 && indexPath.row == 1) {
                index = 0;
            } else if (indexPath.section == 1) {
                index = 1;
            }
            NSLog(@"CustomActionSheet clickedButtonAtIndex for description == %d", index);
            [m_delegate customActionSheet:self clickedButtonAtIndex:index];
            [self removeSelf];
        }
    }
}

- (void)show
{
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.m_window = window;
    window.windowLevel = UIWindowLevelStatusBar + 1;
    window.opaque = NO;
    [self.m_window addSubview:self];
    [self.m_window makeKeyAndVisible];
    
    [self.m_window addSubview:self];
    [self moveUp:YES];
}

- (void)moveUp:(BOOL)isUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25f];
    if (!m_descriptionHeight) {
        if (isUp) {
            CGRect frame = self.m_tableView.frame;
            CGFloat height = 45 * [self.m_arrTitleArr count] + HEADER_HEIGHT * 3;
            frame.origin.y = m_frame.size.height - height;
            self.m_tableView.frame = frame;
            self.m_bgImageView.alpha = 1.0f;
            self.alpha = 1.0f;
        } else {
            CGRect frame = self.m_tableView.frame;
            CGFloat y = m_frame.size.height;
            frame.origin.y = y;
            self.m_tableView.frame = frame;
            self.m_bgImageView.alpha = 0.0f;
            self.alpha = 0.0f;
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(moveSelfFromWindow)];
        }
    } else {
        if (isUp) {
            CGRect frame = self.m_tableView.frame;
            CGFloat height = 45 * [self.m_arrTitleArr count] + HEADER_HEIGHT * 2 + m_descriptionHeight + 40;
            frame.origin.y = m_frame.size.height - height;
            self.m_tableView.frame = frame;
            self.m_bgImageView.alpha = 1.0f;
            self.alpha = 1.0f;
        } else {
            CGRect frame = self.m_tableView.frame;
            CGFloat y = m_frame.size.height;
            frame.origin.y = y;
            self.m_tableView.frame = frame;
            self.m_bgImageView.alpha = 0.0f;
            self.alpha = 0.0f;
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(moveSelfFromWindow)];
        }
    }
    
    [UIView commitAnimations];
}

- (void)removeSelf
{
    [self moveUp:NO];
}

- (void)moveSelfFromWindow
{
    [self removeFromSuperview];
    self.m_window = nil;
    [[[[UIApplication sharedApplication] delegate] window] makeKeyWindow];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    m_canShowNext = YES;
    [self removeSelf];
}

@end
