//
//  EmoView.m
//  WhistleIm
//
//  Created by wangchao on 13-9-3.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "EmoView.h"
#import "SmileyParser.h"
#import "ImageUtil.h"

@implementation EmoView

@synthesize  data;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)loadEmoViewfromData:(NSMutableArray *)tempdata numColumns:(int)numColumns size:(CGSize)size
{
    
    self.data = tempdata;
    int numRows = ceil(self.data.count/(CGFloat)numColumns);
    int hight = size.height;
    int width = size.width;
    

    for (int i =0; i<numRows; i++) {
        for (int j =0; j<numColumns; j++) {
            if(i*numColumns+j >data.count-1)
            {
                break;
            }
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            SmileyInfo *info = [self.data objectAtIndex:(i*numColumns+j)];
            [button setImage:[ImageUtil getImageByImageNamed:info.resName Consider:NO] forState:UIControlStateNormal];
            info.resName_press.length>0?[button setImage:[ImageUtil getImageByImageNamed:info.resName_press Consider:NO] forState:UIControlStateHighlighted]:[button setImage:[ImageUtil getImageByImageNamed:info.resName Consider:NO] forState:UIControlStateHighlighted];
            [button setBackgroundColor:[UIColor clearColor]];
            
            button.frame = CGRectMake(j*width+13, i*(hight+3), width, hight);
            button.tag = (i*numColumns+j);
            [button addTarget:self action:@selector(toucheUp:) forControlEvents:UIControlEventTouchUpInside];
            [button addTarget:self action:@selector(toucheout:) forControlEvents:UIControlEventTouchUpOutside];
            [button addTarget:self action:@selector(toucheDown:) forControlEvents:UIControlEventTouchDown];
            
            [self addSubview:button];
        }
    }
    
    UIView *del =  [self viewWithTag:data.count-2];
    del.frame = CGRectMake(self.bounds.size.width-97, del.frame.origin.y,width,hight);
    
    UIView *send =  [self viewWithTag:data.count-1];
    send.frame = CGRectMake(self.bounds.size.width-55, send.frame.origin.y,55, send.frame.size.height);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(IBAction)toucheUp:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if(delegate)
    {
        [delegate EmoViewTouchUpInSide:[data objectAtIndex:button.tag] with:button];
    }
}

-(IBAction)toucheout:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if(delegate)
    {
        [delegate EmoViewTouchUpOutSide:[data objectAtIndex:button.tag] with:button];
    }
}


-(IBAction)toucheDown:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if(delegate)
    {
        [delegate EmoViewTouchDown:[data objectAtIndex:button.tag]with:button];
    }
}

@end
