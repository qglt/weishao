//
//  CampusActivityCell.m
//  WhistleIm
//
//  Created by liming on 14-2-10.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "CampusActivityCell.h"

@interface CampusActivityCell()
{
    int whether_participate;
}
@end

@implementation CampusActivityCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)campactJoin:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    [btn setBackgroundImage:[UIImage imageNamed:@"campactjoin_pressed"] forState:UIControlStateHighlighted];
    
    if(!whether_participate)
    {
        [btn setTitle:@"取消" forState:UIControlStateNormal];
        [btn setTitle:@"取消" forState:UIControlStateHighlighted];
        whether_participate = 1;
    }
    else
    {
        [btn setTitle:@"马上参加" forState:UIControlStateNormal];
        [btn setTitle:@"马上参加" forState:UIControlStateHighlighted];
        whether_participate = 0;
    }
    
    UITableViewCell *cell = (UITableViewCell *)[[[[[[btn superview] superview] superview] superview] superview] superview];
    
    if ([self.delegate conformsToProtocol:@protocol(CampusActivityCellDelegate)]) {
        
        [self.delegate onSelectedButtonInWhichCell:cell joinGame:(whether_participate)];
    }

}

@end
