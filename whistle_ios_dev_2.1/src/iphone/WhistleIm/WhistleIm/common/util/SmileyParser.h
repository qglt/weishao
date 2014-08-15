//
//  SmileyParser.h
//  WhistleIm
//
//  Created by wangchao on 13-9-3.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SmileyInfo : NSObject

@property (nonatomic,strong) NSString *resName;
@property (nonatomic,strong) NSString *resName_press;
@property (nonatomic,strong) NSString *smiley;
@property (nonatomic,strong) NSString *pushText;

@end

@interface SmileyParser : NSObject

@property(nonatomic,strong) NSMutableArray *defArray;
@property(nonatomic,strong) NSMutableArray *miaoXJArray;
@property(nonatomic,strong) NSMutableArray *xiaoXiaoArray;
@property(nonatomic,strong) NSMutableArray *bangbingArray;
@property(nonatomic,strong) NSMutableArray *infosList;
@property(nonatomic,strong) NSMutableString *pushPattern;
@property(nonatomic,strong) NSMutableString *OHpushPattern;
@property(nonatomic,strong) NSMutableString *sendPattern;
@property(nonatomic,strong) NSMutableDictionary *smileyTextToId;
@property(nonatomic,strong) NSMutableDictionary *pushTextToId;
@property(nonatomic,strong) NSMutableDictionary *sendTextToId;


+(SmileyParser *) parser;

-(NSString *)pasrePushMessageToSmily:(NSString *)text;

-(NSString *)pasreSmilyToPushMessage:(NSString *)text;

-(void) segmentSmilyText:(NSString *)message array:(NSMutableArray *)array;

-(int) getSegmentIndex:(NSString *)text segmentat:(int) segment withRange:(NSRange) range;
@end
