//
//  MessageText.m
//  Whistle
//
//  Created by wangchao on 13-3-7.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//

#import "MessageText.h"

#import "SmileyParser.h"
#import "ImUtils.h"

#import "OHAttributedLabel.h"

#import "OHASBasicMarkupParser.h"
#import "OHASBasicHTMLParser.h"
#import "NSString+Base64.h"

@implementation MessageText
{
 
}
@synthesize txt;
@synthesize attrString;
@synthesize heightNum;
@synthesize yourcls;
@synthesize time;
@synthesize style;



-(void)dealloc
{
    txt = nil;
    attrString = nil;
    yourcls = nil;
    style = nil;
    time = nil;
}

-(void)setAttrTxt:(NSString *)text
{
    attrString= [OHASBasicHTMLParser attributedStringByProcessingMarkupInString:text];
    [attrString setFont:[UIFont systemFontOfSize:15]];
    //            [mas setTextColor:[randomColors objectAtIndex:(idx%5)]];
    [attrString setTextAlignment:kCTTextAlignmentNatural lineBreakMode:kCTLineBreakByCharWrapping];
}

-(id)initAppWithContant:(NSString *)content time:(NSString *)times
{
    self = [super init];
    if (self) {
        NSString *replace1 = [content stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
        NSString *replace2 = [replace1 stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
        NSString *replace3 = [replace2 stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
        txt = [ImUtils flattenHTML:replace3 trimWhiteSpace:YES];
        time = [MessageText formatAppTime:times];
        [self setAttrTxt:txt];
    }
    return self;
}

+(NSDate *)formatAppTime:(NSString *)time
{
    if(time == nil)
    {
        return [NSDate date];
    }
    
    NSMutableString *formatResult = [NSMutableString stringWithString:time];
    
    [formatResult replaceOccurrencesOfString:@"&nbsp;" withString:@" " options:NSCaseInsensitiveSearch range:NSMakeRange(0,formatResult.length)];
    
    if([formatResult rangeOfString:@"上午"].location!=NSNotFound)
    {
        [formatResult replaceOccurrencesOfString:@"上午" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0,formatResult.length)];
    }
    
    if([formatResult rangeOfString:@"下午"].location!=NSNotFound)
    {
        [formatResult replaceOccurrencesOfString:@"下午" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0,formatResult.length)];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    return [formatter dateFromString:formatResult];
    
}



@end
