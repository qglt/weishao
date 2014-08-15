//
//  AddCrowdsInfo.m
//  WhistleIm
//
//  Created by ruijie on 14-2-13.
//  Copyright (c) 2014年 Ruijie. All rights reserved.
//

#import "AddCrowdsInfo.h"
#import "RosterManager.h"
#import "CrowdInfo.h"
#import "CrowdManager.h"

@interface AddCrowdsInfo ()
{
    BOOL m_isMine;
}

@property (nonatomic,assign) BOOL m_isMine;
@end

@implementation AddCrowdsInfo
@synthesize m_isMine;
@synthesize m_delegate;
@synthesize m_isCommond;


- (void)sendData:(NSMutableArray *)dataArr
{
    [m_delegate sendCrowdsInfoToControllerWithArr:dataArr];
}

- (void)sendNoneResultMessage:(NSString *)noneResult
{
    [m_delegate sendNoneResultMessageToController:noneResult];
}

- (void)sendErrorMessage:(NSString *)errorMessage
{
    [m_delegate sendErrorMessageToController:errorMessage];
}

- (void)getCrowdsData:(NSString *)selectedType andSearchKey:(NSString *)searchText andStartIndex:(NSUInteger)startIndex andMaxCounter:(NSUInteger)counter
{
    NSLog(@"in AddCrowdsInfo selectedType === %@, searchText === %@, startIndex === %d, counter === %d", selectedType, searchText, startIndex, counter);
    [[CrowdManager shareInstance] findCrowd:selectedType text:searchText index:startIndex count:counter callback:^(NSArray *array ) {
        NSMutableArray * crowdsArray = nil;
        if (array && array.count >0) {
            crowdsArray = [NSMutableArray arrayWithArray:array];
            [self sendData:crowdsArray];
        }else if(array.count == 0){
            NSString * noneResult = nil;
            if (self.m_isCommond) {
                noneResult = @"暂无推荐群";
            } else {
                noneResult = @"没有搜索到该群";
            }
            [self sendNoneResultMessage:noneResult];
        }
    }];
}



@end
