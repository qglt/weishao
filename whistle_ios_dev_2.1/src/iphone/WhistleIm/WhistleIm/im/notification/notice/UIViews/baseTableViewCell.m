//
//  baseTableViewCell.m
//  WhistleIm
//
//  Created by ruijie on 佛历2557-1-3.
//  Copyright (c) 佛历2557年 Ruijie. All rights reserved.
//

#import "baseTableViewCell.h"
#import "ImUtils.h"
#import "UIResource.h"

@interface baseTableViewCell()
{
    UIView* m_headerLineView;
    UIImageView * accessoryViewimage;
    UIImageView* unread;
    UILabel* unreadNum;
}
@property (nonatomic,strong)UIView* m_headerLineView;
@property (nonatomic,strong)UIImageView * accessoryViewimage;
@end

@implementation baseTableViewCell
@synthesize m_headerLineView;
@synthesize accessoryViewimage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setBaseCondition];
        [self createAccessoryView];
        [self addLine];
    }
    return self;
}
-(void)setBaseCondition
{
    self.backgroundColor = [UIColor whiteColor];
    UIFont* font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15.0f];
    [self.textLabel setFont:font];
    self.textLabel.textColor = [ImUtils colorWithHexString:@"#262626"];
    self.textLabel.highlightedTextColor = [UIColor whiteColor];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor clearColor];

    CGRect frame = [[UIScreen mainScreen] bounds];
    unread = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - 37 - 19, (90 - 38) / 4, 19, 19)];
    [self addSubview:unread];
    [unread setImage:[UIImage imageNamed:@"chat_cell_unread"]];
    
    unreadNum = [[UILabel alloc] init];
    [unreadNum setTranslatesAutoresizingMaskIntoConstraints:NO];
    unreadNum.textColor = [UIColor whiteColor];
    unreadNum.font = [UIFont systemFontOfSize:11.0f];
    unreadNum.textAlignment = NSTextAlignmentCenter;
    unreadNum.backgroundColor = [UIColor clearColor];
    [unread addSubview:unreadNum];
    [unread addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[unreadNum]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(unreadNum)]];
    [unread addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[unreadNum]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(unreadNum)]];
}
-(void)createAccessoryView
{
    accessoryViewimage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"disclosure"] highlightedImage:[UIImage imageNamed:@"disclosurep"]];
    self.accessoryView = accessoryViewimage;
}
-(void)addLine
{
    self.m_headerLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 45, 320, 1)];
    self.m_headerLineView.backgroundColor = [UIColor colorWithRed:225.0f / 255.0f green:225.0f / 255.0f blue:225.0f / 255.0f alpha:1.0f];
    [self addSubview:self.m_headerLineView];
}

- (void) setUnreadNum:(NSUInteger)count
{
    if (count <= 0) {
        unread.hidden = YES;
    }else{
        unread.hidden = NO;
        unreadNum.text = [NSString stringWithFormat:@"%d", count];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"CellBackground.png"]];
    [(UIButton *)self.accessoryView setHighlighted:YES];
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    self.backgroundColor = [UIColor whiteColor];
    [(UIButton *)self.accessoryView setHighlighted:NO];
}
@end
