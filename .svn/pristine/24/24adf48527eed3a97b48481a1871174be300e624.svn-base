//
//  SelectTypeTableViewCell.h
//  WhistleIm
//
//  Created by ruijie on 14-2-17.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectTypeTableViewCellDelegate <NSObject>

-(void)SelectTypeTableViewCellPressed:(id)cell;

@end

@interface SelectTypeTableViewCell : UITableViewCell
@property (nonatomic,weak) id <SelectTypeTableViewCellDelegate>delegate;
-(void)setCellData:(NSString *)textString normalImage:(NSString *)imageName selectImage:(NSString *)selectImageName;
@end
