//
//  NSMutableAttributeStringWithClick.m
//  SpanableLabel
//
//  Created by liuke on 13-11-7.
//  Copyright (c) 2013年 liuke. All rights reserved.
//

#import "NSMutableAttributeStringWithClick.h"



@implementation AttributedStringObject

@synthesize range = _range;
@synthesize name = _name;
@synthesize value = _value;
@synthesize callback = _callback;

@end

@interface NSMutableAttributeStringWithClick()
{
    NSMutableArray* arr_;
}

@end

@implementation NSMutableAttributeStringWithClick


- (void) addClickAttribute:(NSString *)name value:(id)value range:(NSRange)range ClickEvent:(ClickCallback)callback
{
    if (!arr_) {
        arr_ = [[NSMutableArray alloc] init];
    }
    
    AttributedStringObject* obj = [[AttributedStringObject alloc] init];
    obj.name = name;
    obj.value = value;
    obj.range = range;
    obj.callback = callback;

    [arr_ addObject:obj];
}

- (NSMutableArray*) getAttributeInfo
{
    return arr_;
}

- (BOOL) callbackByIndex:(CFIndex) index
{
    __block BOOL ret = NO;
    for (AttributedStringObject* obj in arr_) {
        if (index >= obj.range.location && index <= (obj.range.location + obj.range.length)) {
            obj.callback();
            ret = YES;
        }
    }

    return ret;
}

@end
