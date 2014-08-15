//
//  SelectTypeTableViewCell.m
//  WhistleIm
//
//  Created by ruijie on 14-2-17.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "SelectTypeTableViewCell.h"

#import "ImUtils.h"

@interface SelectTypeTableViewCell()

@property (nonatomic,strong) UIImageView * typeImageView;

@property (nonatomic,strong) UILabel * cellTextLabel;

@property (nonatomic,strong) NSString * cellData;

@property (nonatomic,strong) NSString * normalImage;

@property (nonatomic,strong) NSString * selectImage;

@end


@implementation SelectTypeTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setBaseCondition];
        [self createTypeImage];
        [self createTxtLabel];
        [self addLine];
    }
    return self;
}
-(void)setBaseCondition
{
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 4.0f;
    self.layer.masksToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleGray;
}
//
-(void)createTypeImage
{
    self.typeImageView = [[UIImageView alloc]initWithFrame:CGRectMake(13, 11, 23, 23)];
    [self addSubview:_typeImageView];
}
-(void)createTxtLabel
{
    self.cellTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(46, 16,  self.frame.size.width - 46, 13)];
    self.cellTextLabel.textAlignment = NSTextAlignmentLeft;
    self.cellTextLabel.textColor = [ImUtils colorWithHexString:@"#262626"];
    self.cellTextLabel.backgroundColor = [UIColor clearColor];
    self.cellTextLabel.font = [UIFont systemFontOfSize:13.0f];
    self.cellTextLabel.highlightedTextColor = [UIColor whiteColor];
    [self addSubview:self.cellTextLabel];
}
-(void)addLine
{
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(12, 44, self.frame.size.width - 24, 1)];
    line.backgroundColor = [UIColor colorWithRed:225.0f / 255.0f green:225.0f / 255.0f blue:225.0f / 255.0f alpha:1.0f];
    [self addSubview:line];
}
-(void)setCellData:(NSString *)textString normalImage:(NSString *)imageName selectImage:(NSString *)selectImageName
{
    self.cellData = textString;
    self.normalImage = imageName;
    self.selectImage = selectImageName;
    [self resetContaines];
}
-(void)resetContaines
{
    self.typeImageView.image = [UIImage imageNamed:self.normalImage];
    self.cellTextLabel.text = self.cellData;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.backgroundColor = [ImUtils colorWithHexString:@"#d9d9d9"];
    self.cellTextLabel.textColor = [ImUtils colorWithHexString:@"#ffffff"];
    self.typeImageView.image = [UIImage imageNamed:self.selectImage];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.backgroundColor = [UIColor whiteColor];
    self.cellTextLabel.textColor = [ImUtils colorWithHexString:@"#262626"];
    self.typeImageView.image = [UIImage imageNamed:self.normalImage];
    [self.delegate SelectTypeTableViewCellPressed:self];
}

@end
