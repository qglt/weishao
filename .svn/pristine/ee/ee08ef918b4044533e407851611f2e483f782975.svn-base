//
//  MessageText.h
//  Whistle
//
//  Created by wangchao on 13-3-7.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//

#import "Message.h"
#import "NSAttributedString+Attributes.h"

@interface MessageText : Message

@property (nonatomic, copy) NSString *txt;
@property (nonatomic ,strong) NSMutableAttributedString *attrString;
@property (nonatomic ,assign) CGFloat heightNum;
@property (nonatomic ,assign) CGSize attrStringSize;

-(void)setAttrTxt:(NSString *)text;

-(id)initAppWithContant:(NSString *)content time:(NSString *)time;

+(NSDate *)formatAppTime:(NSString *)times;

@end
