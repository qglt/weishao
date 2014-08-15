//
//  CampusActivityCell.h
//  WhistleIm
//
//  Created by liming on 14-2-10.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CampusActivityCellDelegate <NSObject>

 @optional

- (void)onSelectedButtonInWhichCell:(UITableViewCell *)cell joinGame:(BOOL)whether_join;

@end

@interface CampusActivityCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *titleLabel;

@property (nonatomic,weak) IBOutlet UILabel *startTimeLabel;

@property (nonatomic,weak) IBOutlet UILabel *endTimeLabel;

@property (nonatomic,weak) IBOutlet UILabel *runningStatus;

@property (nonatomic,weak) IBOutlet UILabel *distanceLabel;

@property (nonatomic,weak) IBOutlet UILabel *monitorLabel;

@property (nonatomic,weak) IBOutlet UILabel *typeLabel;

@property (nonatomic,weak) IBOutlet UIImageView *activityIcon;

@property (nonatomic,weak) IBOutlet UIButton *joinNumberButton;

@property (nonatomic,weak) IBOutlet UIButton *joinButton;

@property (nonatomic,weak) IBOutlet UILabel *memberNumber;

@property (nonatomic,weak) id<CampusActivityCellDelegate> delegate;

- (IBAction)campactJoin:(id)sender;


@end
