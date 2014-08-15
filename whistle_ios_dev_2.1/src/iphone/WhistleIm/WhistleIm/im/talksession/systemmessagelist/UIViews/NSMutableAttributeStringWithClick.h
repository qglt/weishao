//
//  NSMutableAttributeStringWithClick.h
//  SpanableLabel
//
//  Created by liuke on 13-11-7.
//  Copyright (c) 2013年 liuke. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ClickCallback)(void);

@interface AttributedStringObject : NSObject

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) id value;
@property (nonatomic) NSRange range;
@property (nonatomic, strong) ClickCallback callback;

@end

@interface NSMutableAttributeStringWithClick : NSObject


- (void)addClickAttribute:(NSString*) name value:(id)value range:(NSRange)range ClickEvent: (ClickCallback) callback;

- (NSMutableArray*) getAttributeInfo;

- (BOOL) callbackByIndex:(CFIndex) index;


@end
