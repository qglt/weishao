//
//  CommentaryTableViewCell.m
//  WhistleIm
//
//  Created by 曾长欢 on 14-2-17.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "CommentaryTableViewCell.h"
#import "ImUtils.h"
#import "FriendInfo.h"
#import <SDWebImage/UIImageView+WebCache.h>
@implementation CommentaryTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self creatContentView];
    }
    return self;
}

- (void)creatContentView
{
    _img = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 40, 40)];
    _img.image = [UIImage imageNamed:@"identity_man_new.png"];

    _img.layer.cornerRadius = 20.0f;
    _img.layer.masksToBounds = YES;
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 12, 45, 14)];
    _nameLabel.textColor = [ImUtils colorWithHexString:@"#262626"];
    _nameLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:15];
    _nameLabel.textAlignment = NSTextAlignmentLeft;
    _nameLabel.text = @"小马";
    
    _organizationLable = [[UILabel alloc] initWithFrame:CGRectMake(120, 12, 120, 14)];
    _organizationLable.textColor = [ImUtils colorWithHexString:@"#808080"];
    _organizationLable.font =[UIFont fontWithName:@"STHeitiSC-Thin" size:11];
    _organizationLable.textAlignment = NSTextAlignmentLeft;
    _organizationLable.text = @"zengchanghuan";
    
    _commentLable = [[UILabel alloc] initWithFrame:CGRectMake(65, 41, 45, 14)];
    _commentLable.textColor = [ImUtils colorWithHexString:@"#808080"];
    _commentLable.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11];
    _commentLable.textAlignment = NSTextAlignmentLeft;
    _commentLable.text = @"特别喜欢";
    
    _creatTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(240, 12, 180, 14)];
    _creatTimeLabel.textColor = [ImUtils colorWithHexString:@"#808080"];
    _creatTimeLabel.font = [UIFont fontWithName:@"STHeitiSC-Thin" size:11];
    _creatTimeLabel.textAlignment = NSTextAlignmentLeft;
    _creatTimeLabel.text = @"2014/2/17";
    
    [self.contentView addSubview:_nameLabel];
    [self.contentView addSubview:_organizationLable];
    [self.contentView addSubview:_commentLable];
    [self.contentView addSubview:_creatTimeLabel];
    [self.contentView addSubview:_img];

}
- (void) setCellData:(AppCommentItem *)item
{
    _nameLabel.text = item.comment_name;
    _organizationLable.text = item.comment_organization;
    _commentLable.text = item.comment_text;
    _creatTimeLabel.text = item.comment_addTimeFormat;
    
    if (item.extraInfo) {
        FriendInfo *frinendInfo = (FriendInfo *)item.extraInfo;
        [_img setImageWithURL:[NSURL fileURLWithPath:frinendInfo.head] placeholderImage:[ImUtils getDefault:frinendInfo]];
    }

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
