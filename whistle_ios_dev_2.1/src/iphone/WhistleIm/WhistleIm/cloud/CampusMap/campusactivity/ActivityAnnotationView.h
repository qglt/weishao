//
//  ActivityAnnotationView.h
//  WhistleIm
//
//  Created by liming on 14-2-12.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>

@interface ActivityAnnotationView : MAAnnotationView

/*
@property (nonatomic,copy) NSString *name;

@property (nonatomic,assign) int currentMemberNumber;

@property (nonatomic,assign) int maxMemberNumber;
 
 */

@property (nonatomic,strong) UIImage *activityTypeIcon;
@property (nonatomic,strong) UIImage *iconShadow;
@property (nonatomic,strong) UIView *calloutView;

@end
