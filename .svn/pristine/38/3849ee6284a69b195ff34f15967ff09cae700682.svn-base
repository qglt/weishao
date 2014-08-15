//
//  ActivityAnnotationView.m
//  WhistleIm
//
//  Created by liming on 14-2-12.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "ActivityAnnotationView.h"
#define kTypeIconWidth      45.0f
#define kTypeIconHeight     49.0f

@interface ActivityAnnotationView()

@property (nonatomic,strong) UIImageView   *activityTypeIconView;

@end


@implementation ActivityAnnotationView

-(id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.bounds = CGRectMake(0, 0, kTypeIconWidth, kTypeIconHeight);
        self.activityTypeIconView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.activityTypeIconView.image = [UIImage imageNamed:@"catfriendshipannotation.png"];
        [self addSubview:self.activityTypeIconView];
    }
    
    return self;

}

#pragma mark - Overwrite

-(UIImage *)activityTypeIcon
{
    return self.activityTypeIconView.image;
}

-(void)setActivityTypeIcon:(UIImage *)activityTypeIcon
{
    self.activityTypeIconView.image = activityTypeIcon;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
