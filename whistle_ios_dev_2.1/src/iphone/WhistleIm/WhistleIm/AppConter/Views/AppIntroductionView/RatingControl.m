//
//  RatingControl.m
//  WhistleIm
//
//  Created by 曾长欢 on 14-1-22.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "RatingControl.h"

static const CGFloat kFontSize = 12;
static const NSString *kDefaultEmptyChar = @"☆";
static const NSString *kDefaultSolidChar = @"★";
static const NSInteger kStarWidthAndHeight = 15;

@implementation RatingControl
@synthesize rating = _rating;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)drawRect:(CGRect)rect
{
	CGPoint currPoint = CGPointZero;
	
	for (int i = 0; i < _rating; i++)
	{
		if (_solidImage)
        {
            [_solidImage drawAtPoint:currPoint];
        }
		else
        {
            CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), _solidColor.CGColor);
            [kDefaultSolidChar drawAtPoint:currPoint withFont:[UIFont boldSystemFontOfSize:kFontSize]];
        }
        
		currPoint.x += kStarWidthAndHeight;
	}
	
	NSInteger remaining = _maxRating - _rating;
	
	for (int i = 0; i < remaining; i++)
	{
		if (_emptyImage)
        {
			[_emptyImage drawAtPoint:currPoint];
        }
		else
        {
            CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), _emptyColor.CGColor);
			[kDefaultEmptyChar drawAtPoint:currPoint withFont:[UIFont boldSystemFontOfSize:kFontSize]];
        }
		currPoint.x += kStarWidthAndHeight;
	}
}
- (id)initWithLocation:(CGPoint)location
            emptyImage:(UIImage *)emptyImageOrNil
            solidImage:(UIImage *)solidImageOrNil
            emptyColor:(UIColor *)emptyColor
            solidColor:(UIColor *)solidColor
          andMaxRating:(NSInteger)maxRating
{
    if (self = [self initWithFrame:CGRectMake(location.x,
                                              location.y,
                                              (maxRating * kStarWidthAndHeight),
                                              kStarWidthAndHeight)])
	{
		_rating = 0;
		self.backgroundColor = [UIColor clearColor];
		self.opaque = NO;
		
		_emptyImage = emptyImageOrNil;
		_solidImage = solidImageOrNil;
        _emptyColor = emptyColor;
        _solidColor = solidColor;
        _maxRating = maxRating;
	}
	
	return self;
}
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
//	[self handleTouch:touch];
	return NO;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
//	[self handleTouch:touch];
	return NO;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
//    [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
    return;
}

@end
