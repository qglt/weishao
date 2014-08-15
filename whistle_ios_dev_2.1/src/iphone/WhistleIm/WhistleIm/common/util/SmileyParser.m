//
//  SmileyParser.m
//  WhistleIm
//
//  Created by wangchao on 13-9-3.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "SmileyParser.h"

@implementation SmileyInfo
{

}

static NSRegularExpression *regularExpression = nil;
static NSRegularExpression *push_expression = nil;
@end

@implementation SmileyParser

@synthesize defArray;
@synthesize miaoXJArray;
@synthesize xiaoXiaoArray;
@synthesize bangbingArray;
@synthesize infosList;
@synthesize sendTextToId;
@synthesize smileyTextToId;
@synthesize pushTextToId;
@synthesize sendPattern;//(<img>/)
@synthesize pushPattern;//(/xiao)
@synthesize OHpushPattern;


-(SmileyInfo *) createSmileyInfo:(NSString *)resName with:(NSString *)smiletText for:(NSString *)pushText
{
    SmileyInfo *info = [SmileyInfo alloc];
    info.resName =resName;
    info.smiley = smiletText;
    info.pushText = pushText;
    return info;
}

-(id)init
{
    if (self = [super init]) {
        if(infosList ==nil)
        {
            infosList = [NSMutableArray array];
            [self addDefInfos];
            [self buildPushRes];
            [self buildSendRes];
            [self buildSmileyRes];
            [self buildSendPattern];
            [self buildPushPattern];
            [self buildOHPushPattern];
        }
    }
    
    return self;
}

+(SmileyParser *)parser
{
    static SmileyParser* _sp = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sp = [[SmileyParser alloc] init];
    });
    return _sp;
}

-(NSString *)pasrePushMessageToSmily:(NSString *)text
{
    if(!text)
    {
        return @"";
    }
    if (!regularExpression) {//@"<img\\s+name=.+?src=(.+?)>"
        regularExpression = [NSRegularExpression regularExpressionWithPattern:@"<img\\s+name=.+?src=(.+?)>" options:NSRegularExpressionCaseInsensitive error:nil];
    }

    NSArray *array = [regularExpression matchesInString:text options:NSMatchingReportProgress range:NSMakeRange(0, text.length)];
    NSMutableString *result = [NSMutableString stringWithString:text];
    if(array.count>0)
    {
        for (NSTextCheckingResult *check in array) {
            NSString *replace = [text substringWithRange:check.range];
            NSString *str = [pushTextToId valueForKey:replace];
            [result replaceOccurrencesOfString:replace withString:str options:NSCaseInsensitiveSearch range:NSMakeRange(0, result.length)];
        }
    }
    return [NSString stringWithString:result];
}

-(int) getSegmentIndex:(NSString *)text segmentat:(int) segment withRange:(NSRange) range
{
    int index = segment;
    if (!push_expression) {
        push_expression = [NSRegularExpression regularExpressionWithPattern:pushPattern options:NSRegularExpressionCaseInsensitive error:nil];
    }
    
    NSArray *array = [push_expression matchesInString:text options:NSMatchingReportProgress range:range];
//    NSMutableString *result = [NSMutableString stringWithString:text];
    if(array.count>0)
    {
        NSTextCheckingResult *check =  [array objectAtIndex:0];
        index = check.range.location + check.range.length;
    }
    
    
    return index;
}

-(NSString *)pasreSmilyToPushMessage:(NSString *)text
{
    if (!push_expression) {
        push_expression = [NSRegularExpression regularExpressionWithPattern:pushPattern options:NSRegularExpressionCaseInsensitive error:nil];
    }
    
    NSArray *array = [push_expression matchesInString:text options:NSMatchingReportProgress range:NSMakeRange(0, text.length)];
    NSMutableString *result = [NSMutableString stringWithString:text];
    if(array.count>0)
    {
        for (NSTextCheckingResult *check in array) {
            NSString *replace = [text substringWithRange:check.range];
            NSString *str = [sendTextToId valueForKey:replace];
            [result replaceOccurrencesOfString:replace withString:str options:NSCaseInsensitiveSearch range:NSMakeRange(0, result.length)];

        }
    }
    
    
    return [NSString stringWithString:result];
}

-(void) buildPushPattern
{
    sendPattern = [NSMutableString stringWithString:@"("];
    for (int i=0; i<infosList.count; ++i) {
        NSMutableArray *array = [infosList objectAtIndex:i];
        for (int j=0; j<array.count;j++) {
            SmileyInfo *info = [array objectAtIndex:j];
            [sendPattern appendString:info.pushText];
            [sendPattern appendString:@"|"];
        }
    }
    [sendPattern deleteCharactersInRange:NSMakeRange(sendPattern.length-1, 1)];
    [sendPattern appendString:@")"];
}

-(void) buildSendPattern
{
    pushPattern = [NSMutableString stringWithString:@"("];
    for (int i=0; i<infosList.count; ++i) {
        NSMutableArray *array = [infosList objectAtIndex:i];
        for (int j=0; j<array.count;j++) {
            SmileyInfo *info = [array objectAtIndex:j];
            [pushPattern appendString:info.smiley];
            [pushPattern appendString:@"|"];
        }
    }
    [pushPattern deleteCharactersInRange:NSMakeRange(pushPattern
                                                     .length-1, 1)];
    [pushPattern appendString:@")"];
}

-(void) buildOHPushPattern
{
    OHpushPattern = [NSMutableString stringWithString:@"("];
    for (int i=0; i<defArray.count; ++i) {
        SmileyInfo *info = [defArray objectAtIndex:i];
        [OHpushPattern appendString:info.smiley];
        [OHpushPattern appendString:@"|"];
    }
    [OHpushPattern deleteCharactersInRange:NSMakeRange(OHpushPattern
                                                     .length-1, 1)];
    [OHpushPattern appendString:@")"];
}

-(void) buildSmileyRes
{
    smileyTextToId = [NSMutableDictionary dictionary];
    for (int i=0; i<infosList.count; ++i) {
        NSMutableArray *array = [infosList objectAtIndex:i];
        for (int j=0; j<array.count;j++) {
            SmileyInfo *info = [array objectAtIndex:j];
            [smileyTextToId setValue:info.resName forKey:info.smiley];
        }
    }
}

#pragma mark  <img> --- /xiao
-(void) buildPushRes
{
    pushTextToId = [NSMutableDictionary dictionary];
    for (int i=0; i<infosList.count; ++i) {
        NSMutableArray *array = [infosList objectAtIndex:i];
        for (int j=0; j<array.count;j++) {
            SmileyInfo *info = [array objectAtIndex:j];
            [pushTextToId setValue:info.smiley forKey:info.pushText];
        }
    }
}

#pragma mark  /xiao --- <img>
-(void) buildSendRes
{
    sendTextToId = [NSMutableDictionary dictionary];
    for (int i=0; i<infosList.count; ++i) {
        NSMutableArray *array = [infosList objectAtIndex:i];
        for (int j=0; j<array.count;j++) {
            SmileyInfo *info = [array objectAtIndex:j];
            [sendTextToId setValue:info.pushText forKey:info.smiley];
        }
    }
//    NSLog(@"smileyTextToId is %@",smileyTextToId);
}

-(void)segmentSmilyText:(NSString *)message array:(NSMutableArray *)array
{
   
    if (!push_expression) {
        push_expression =  [NSRegularExpression regularExpressionWithPattern:pushPattern options:NSRegularExpressionCaseInsensitive error:nil];
    }
    NSArray *temp =  [push_expression matchesInString:message options:NSMatchingReportProgress range:NSMakeRange(0, message.length)];
    int location = 0;
    if(temp.count ==0)
    {
        [array addObject:message];
        return;
    }else{
        for (int i = 0; i<temp.count; i++) {
            NSTextCheckingResult *result  = [temp objectAtIndex:i];
            if(result.range.location-location>0)
            {
                
                [array addObject:[message substringWithRange:NSMakeRange(location, result.range.location-location)]];
            }
            [array addObject:[message substringWithRange:result.range]];
            location= result.range.location+result.range.length;
            if(i==temp.count-1)
            {
                if(result.range.location+result.range.length != message.length)
                {
                    [array addObject:[message substringFromIndex:result.range.location+result.range.length]];
                }
            }
        }
    } 
}

-(void) addDefInfos
{
    [self initdefInfos];
    [self initMiaoXiaoJianInfos];
    [self initXiaoXiaoInfos];
    [self initBangBingInfos];
    
    
    [infosList addObject:defArray];
    [infosList addObject:miaoXJArray];
    [infosList addObject:xiaoXiaoArray];
    [infosList addObject:bangbingArray];
}

-(void) initdefInfos
{
    if(defArray == nil)
    {
        defArray = [NSMutableArray arrayWithCapacity:60];
        [defArray addObject:[self createSmileyInfo:@"f000.png" with:@"/微笑" for:@"<img name=\"SystemFace\" src=\"../../image/face/weixiao.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f001.png" with:@"/难过" for:@"<img name=\"SystemFace\" src=\"../../image/face/nanguo.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f002.png" with:@"/憨笑" for:@"<img name=\"SystemFace\" src=\"../../image/face/hanxiao.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f003.png" with:@"/鄙视" for:@"<img name=\"SystemFace\" src=\"../../image/face/bishi.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f004.png" with:@"/龇牙" for:@"<img name=\"SystemFace\" src=\"../../image/face/ciya.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f005.png" with:@"/亲亲" for:@"<img name=\"SystemFace\" src=\"../../image/face/qinqin.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f006.png" with:@"/可爱" for:@"<img name=\"SystemFace\" src=\"../../image/face/keai.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f007.png" with:@"/阴险" for:@"<img name=\"SystemFace\" src=\"../../image/face/yinxian.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f008.png" with:@"/撇嘴" for:@"<img name=\"SystemFace\" src=\"../../image/face/piezui.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f009.png" with:@"/哈欠" for:@"<img name=\"SystemFace\" src=\"../../image/face/haqian.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f010.png" with:@"/扮鬼脸" for:@"<img name=\"SystemFace\" src=\"../../image/face/banguilian.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f011.png" with:@"/惊恐" for:@"<img name=\"SystemFace\" src=\"../../image/face/jingkong.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f012.png" with:@"/奋斗" for:@"<img name=\"SystemFace\" src=\"../../image/face/fendou.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f013.png" with:@"/流泪" for:@"<img name=\"SystemFace\" src=\"../../image/face/liulei.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f014.png" with:@"/晕" for:@"<img name=\"SystemFace\" src=\"../../image/face/yun.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f015.png" with:@"/叹气" for:@"<img name=\"SystemFace\" src=\"../../image/face/tanqi.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f016.png" with:@"/坏笑" for:@"<img name=\"SystemFace\" src=\"../../image/face/huaixiao.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f017.png" with:@"/流汗" for:@"<img name=\"SystemFace\" src=\"../../image/face/liuhan.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f018.png" with:@"/大哭" for:@"<img name=\"SystemFace\" src=\"../../image/face/daku.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f019.png" with:@"/咒骂" for:@"<img name=\"SystemFace\" src=\"../../image/face/zhouma.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f020.png" with:@"/吓" for:@"<img name=\"SystemFace\" src=\"../../image/face/xiahu.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f021.png" with:@"/吐舌头" for:@"<img name=\"SystemFace\" src=\"../../image/face/tushetou.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f022.png" with:@"/困" for:@"<img name=\"SystemFace\" src=\"../../image/face/kunle.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f023.png" with:@"/可怜" for:@"<img name=\"SystemFace\" src=\"../../image/face/kelian.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f024.png" with:@"/抓狂" for:@"<img name=\"SystemFace\" src=\"../../image/face/zhuakuang.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f025.png" with:@"/安慰" for:@"<img name=\"SystemFace\" src=\"../../image/face/anwei.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f026.png" with:@"/惊讶" for:@"<img name=\"SystemFace\" src=\"../../image/face/jingya.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f027.png" with:@"/再见" for:@"<img name=\"SystemFace\" src=\"../../image/face/zaijian.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f028.png" with:@"/傲慢" for:@"<img name=\"SystemFace\" src=\"../../image/face/aoman.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f029.png" with:@"/发呆" for:@"<img name=\"SystemFace\" src=\"../../image/face/fadai.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f030.png" with:@"/冷汗" for:@"<img name=\"SystemFace\" src=\"../../image/face/lenghan.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f031.png" with:@"/抠鼻" for:@"<img name=\"SystemFace\" src=\"../../image/face/koubizi.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f032.png" with:@"/衰" for:@"<img name=\"SystemFace\" src=\"../../image/face/shuai.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f033.png" with:@"/糗大了" for:@"<img name=\"SystemFace\" src=\"../../image/face/qiudale.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f034.png" with:@"/快哭了" for:@"<img name=\"SystemFace\" src=\"../../image/face/kuaikule.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f035.png" with:@"/白眼" for:@"<img name=\"SystemFace\" src=\"../../image/face/bailian.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f036.png" with:@"/瀑布汗" for:@"<img name=\"SystemFace\" src=\"../../image/face/pubuhan.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f037.png" with:@"/委屈" for:@"<img name=\"SystemFace\" src=\"../../image/face/weiqu.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f038.png" with:@"/鼓掌" for:@"<img name=\"SystemFace\" src=\"../../image/face/guzhang.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f039.png" with:@"/吐" for:@"<img name=\"SystemFace\" src=\"../../image/face/tu.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f040.png" with:@"/右哼哼" for:@"<img name=\"SystemFace\" src=\"../../image/face/youhengheng.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f041.png" with:@"/左哼哼" for:@"<img name=\"SystemFace\" src=\"../../image/face/zuohengheng.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f042.png" with:@"/擦汗" for:@"<img name=\"SystemFace\" src=\"../../image/face/cahan.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f043.png" with:@"/害羞" for:@"<img name=\"SystemFace\" src=\"../../image/face/haixiu.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f044.png" with:@"/输了" for:@"<img name=\"SystemFace\" src=\"../../image/face/shula.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f045.png" with:@"/色" for:@"<img name=\"SystemFace\" src=\"../../image/face/se.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f046.png" with:@"/捂嘴" for:@"<img name=\"SystemFace\" src=\"../../image/face/wuzui.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f047.png" with:@"/疑问" for:@"<img name=\"SystemFace\" src=\"../../image/face/yiwen.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f048.png" with:@"/发怒" for:@"<img name=\"SystemFace\" src=\"../../image/face/fanu.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f049.png" with:@"/嗨" for:@"<img name=\"SystemFace\" src=\"../../image/face/hai.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f050.png" with:@"/尴尬" for:@"<img name=\"SystemFace\" src=\"../../image/face/ganga.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f051.png" with:@"/爱心" for:@"<img name=\"SystemFace\" src=\"../../image/face/aixin.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f052.png" with:@"/骷髅" for:@"<img name=\"SystemFace\" src=\"../../image/face/kulou.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f053.png" with:@"/闪电" for:@"<img name=\"SystemFace\" src=\"../../image/face/shandian.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f054.png" with:@"/爆发" for:@"<img name=\"SystemFace\" src=\"../../image/face/baofa.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f055.png" with:@"/羞" for:@"<img name=\"SystemFace\" src=\"../../image/face/xiuse.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f056.png" with:@"/摇头" for:@"<img name=\"SystemFace\" src=\"../../image/face/yaotou.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f057.png" with:@"/舔" for:@"<img name=\"SystemFace\" src=\"../../image/face/tian.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f058.png" with:@"/无奈" for:@"<img name=\"SystemFace\" src=\"../../image/face/wunai.gif\">"]];
        [defArray addObject:[self createSmileyInfo:@"f059.png" with:@"/加油" for:@"<img name=\"SystemFace\" src=\"../../image/face/jiayou.gif\">"]];
        
    }
}

-(void) initMiaoXiaoJianInfos
{
    if(miaoXJArray == nil)
    {
        miaoXJArray = [NSMutableArray arrayWithCapacity:28];
        [miaoXJArray addObject:[self createSmileyInfo:@"m000.png" with:@"^抱抱" for:@"<img name=\"SystemFace\" src=\"../../image/face/hair_thief/baobao.gif\">"]];
        [miaoXJArray addObject:[self createSmileyInfo:@"m001.png" with:@"^鄙视" for:@"<img name=\"SystemFace\" src=\"../../image/face/hair_thief/bishi.gif\">"]];
        [miaoXJArray addObject:[self createSmileyInfo:@"m002.png" with:@"^吃饭" for:@"<img name=\"SystemFace\" src=\"../../image/face/hair_thief/chifan.gif\">"]];
        [miaoXJArray addObject:[self createSmileyInfo:@"m003.png" with:@"^犯困" for:@"<img name=\"SystemFace\" src=\"../../image/face/hair_thief/fankun.gif\">"]];
        [miaoXJArray addObject:[self createSmileyInfo:@"m004.png" with:@"^飞吻" for:@"<img name=\"SystemFace\" src=\"../../image/face/hair_thief/feiwen.gif\">"]];
        [miaoXJArray addObject:[self createSmileyInfo:@"m005.png" with:@"^鼓掌" for:@"<img name=\"SystemFace\" src=\"../../image/face/hair_thief/guzhang.gif\">"]];
        [miaoXJArray addObject:[self createSmileyInfo:@"m006.png" with:@"^鬼脸" for:@"<img name=\"SystemFace\" src=\"../../image/face/hair_thief/guilian.gif\">"]];
        [miaoXJArray addObject:[self createSmileyInfo:@"m007.png" with:@"^减肥" for:@"<img name=\"SystemFace\" src=\"../../image/face/hair_thief/jianfei.gif\">"]];
        [miaoXJArray addObject:[self createSmileyInfo:@"m008.png" with:@"^囧" for:@"<img name=\"SystemFace\" src=\"../../image/face/hair_thief/jiong.gif\">"]];
        [miaoXJArray addObject:[self createSmileyInfo:@"m009.png" with:@"^看书" for:@"<img name=\"SystemFace\" src=\"../../image/face/hair_thief/kanshu.gif\">"]];
        [miaoXJArray addObject:[self createSmileyInfo:@"m010.png" with:@"^恐惧" for:@"<img name=\"SystemFace\" src=\"../../image/face/hair_thief/kongju.gif\">"]];
        [miaoXJArray addObject:[self createSmileyInfo:@"m011.png" with:@"^酷" for:@"<img name=\"SystemFace\" src=\"../../image/face/hair_thief/ku.gif\">"]];
        [miaoXJArray addObject:[self createSmileyInfo:@"m012.png" with:@"^冷" for:@"<img name=\"SystemFace\" src=\"../../image/face/hair_thief/leng.gif\">"]];
        [miaoXJArray addObject:[self createSmileyInfo:@"m013.png" with:@"^流口水" for:@"<img name=\"SystemFace\" src=\"../../image/face/hair_thief/liukoushui.gif\">"]];
        [miaoXJArray addObject:[self createSmileyInfo:@"m014.png" with:@"^冒汗" for:@"<img name=\"SystemFace\" src=\"../../image/face/hair_thief/maohan.gif\">"]];
        [miaoXJArray addObject:[self createSmileyInfo:@"m015.png" with:@"^没钱了" for:@"<img name=\"SystemFace\" src=\"../../image/face/hair_thief/meiqianle.gif\">"]];
        [miaoXJArray addObject:[self createSmileyInfo:@"m016.png" with:@"^欠揍" for:@"<img name=\"SystemFace\" src=\"../../image/face/hair_thief/qianzou.gif\">"]];
        [miaoXJArray addObject:[self createSmileyInfo:@"m017.png" with:@"^伤心" for:@"<img name=\"SystemFace\" src=\"../../image/face/hair_thief/shangxin.gif\">"]];
        [miaoXJArray addObject:[self createSmileyInfo:@"m018.png" with:@"^生气" for:@"<img name=\"SystemFace\" src=\"../../image/face/hair_thief/shengqi.gif\">"]];
        [miaoXJArray addObject:[self createSmileyInfo:@"m019.png" with:@"^偷笑" for:@"<img name=\"SystemFace\" src=\"../../image/face/hair_thief/touxiao.gif\">"]];
        [miaoXJArray addObject:[self createSmileyInfo:@"m020.png" with:@"^晚安" for:@"<img name=\"SystemFace\" src=\"../../image/face/hair_thief/wanan.gif\">"]];
        [miaoXJArray addObject:[self createSmileyInfo:@"m021.png" with:@"^我来了" for:@"<img name=\"SystemFace\" src=\"../../image/face/hair_thief/wolaile.gif\">"]];
        [miaoXJArray addObject:[self createSmileyInfo:@"m022.png" with:@"^洗澡" for:@"<img name=\"SystemFace\" src=\"../../image/face/hair_thief/xizao.gif\">"]];
        [miaoXJArray addObject:[self createSmileyInfo:@"m023.png" with:@"^消失" for:@"<img name=\"SystemFace\" src=\"../../image/face/hair_thief/xiaoshi.gif\">"]];
        [miaoXJArray addObject:[self createSmileyInfo:@"m024.png" with:@"^一秒变猪头" for:@"<img name=\"SystemFace\" src=\"../../image/face/hair_thief/yimiaobianzhutou.gif\">"]];
        [miaoXJArray addObject:[self createSmileyInfo:@"m025.png" with:@"^晕" for:@"<img name=\"SystemFace\" src=\"../../image/face/hair_thief/yun.gif\">"]];
        [miaoXJArray addObject:[self createSmileyInfo:@"m026.png" with:@"^再见" for:@"<img name=\"SystemFace\" src=\"../../image/face/hair_thief/zaijian.gif\">"]];
        [miaoXJArray addObject:[self createSmileyInfo:@"m027.png" with:@"^住嘴" for:@"<img name=\"SystemFace\" src=\"../../image/face/hair_thief/zhuzui.gif\">"]];
    }
}

-(void) initXiaoXiaoInfos
{
    if(xiaoXiaoArray == nil)
    {
        xiaoXiaoArray = [NSMutableArray arrayWithCapacity:30];
        [xiaoXiaoArray addObject:[self createSmileyInfo:@"x000.png" with:@"$kill" for:@"<img name=\"SystemFace\" src=\"../../image/face/xiaoxiao/kill.gif\">"]];
        [xiaoXiaoArray addObject:[self createSmileyInfo:@"x001.png" with:@"$kiss" for:@"<img name=\"SystemFace\" src=\"../../image/face/xiaoxiao/kiss.gif\">"]];
        [xiaoXiaoArray addObject:[self createSmileyInfo:@"x002.png" with:@"$安慰" for:@"<img name=\"SystemFace\" src=\"../../image/face/xiaoxiao/anwei.gif\">"]];
        [xiaoXiaoArray addObject:[self createSmileyInfo:@"x003.png" with:@"$抱抱" for:@"<img name=\"SystemFace\" src=\"../../image/face/xiaoxiao/baobao.gif\">"]];
        [xiaoXiaoArray addObject:[self createSmileyInfo:@"x004.png" with:@"$吃东西" for:@"<img name=\"SystemFace\" src=\"../../image/face/xiaoxiao/chidongxi.gif\">"]];
        [xiaoXiaoArray addObject:[self createSmileyInfo:@"x005.png" with:@"$吹泡泡" for:@"<img name=\"SystemFace\" src=\"../../image/face/xiaoxiao/chuipaopao.gif\">"]];
        [xiaoXiaoArray addObject:[self createSmileyInfo:@"x006.png" with:@"$打招呼" for:@"<img name=\"SystemFace\" src=\"../../image/face/xiaoxiao/dazhaohu.gif\">"]];
        [xiaoXiaoArray addObject:[self createSmileyInfo:@"x007.png" with:@"$荡秋千" for:@"<img name=\"SystemFace\" src=\"../../image/face/xiaoxiao/dangqiuqian.gif\">"]];
        [xiaoXiaoArray addObject:[self createSmileyInfo:@"x008.png" with:@"$道歉" for:@"<img name=\"SystemFace\" src=\"../../image/face/xiaoxiao/daoqian.gif\">"]];
        [xiaoXiaoArray addObject:[self createSmileyInfo:@"x009.png" with:@"$害羞" for:@"<img name=\"SystemFace\" src=\"../../image/face/xiaoxiao/haixiu.gif\">"]];
        [xiaoXiaoArray addObject:[self createSmileyInfo:@"x010.png" with:@"$坏笑" for:@"<img name=\"SystemFace\" src=\"../../image/face/xiaoxiao/huaixiao.gif\">"]];
        [xiaoXiaoArray addObject:[self createSmileyInfo:@"x011.png" with:@"$加油" for:@"<img name=\"SystemFace\" src=\"../../image/face/xiaoxiao/jiayou.gif\">"]];
        [xiaoXiaoArray addObject:[self createSmileyInfo:@"x012.png" with:@"$惊讶" for:@"<img name=\"SystemFace\" src=\"../../image/face/xiaoxiao/jingya.gif\">"]];
        [xiaoXiaoArray addObject:[self createSmileyInfo:@"x013.png" with:@"$囧" for:@"<img name=\"SystemFace\" src=\"../../image/face/xiaoxiao/jiong.gif\">"]];
        [xiaoXiaoArray addObject:[self createSmileyInfo:@"x014.png" with:@"$酷" for:@"<img name=\"SystemFace\" src=\"../../image/face/xiaoxiao/ku.gif\">"]];
        [xiaoXiaoArray addObject:[self createSmileyInfo:@"x015.png" with:@"$啦啦队" for:@"<img name=\"SystemFace\" src=\"../../image/face/xiaoxiao/laladui.gif\">"]];
        [xiaoXiaoArray addObject:[self createSmileyInfo:@"x016.png" with:@"$泪奔" for:@"<img name=\"SystemFace\" src=\"../../image/face/xiaoxiao/leiben.gif\">"]];
        [xiaoXiaoArray addObject:[self createSmileyInfo:@"x017.png" with:@"$冷" for:@"<img name=\"SystemFace\" src=\"../../image/face/xiaoxiao/leng.gif\">"]];
        [xiaoXiaoArray addObject:[self createSmileyInfo:@"x018.png" with:@"$没睡好" for:@"<img name=\"SystemFace\" src=\"../../image/face/xiaoxiao/meishuihao.gif\">"]];
        [xiaoXiaoArray addObject:[self createSmileyInfo:@"x019.png" with:@"$飘过" for:@"<img name=\"SystemFace\" src=\"../../image/face/xiaoxiao/piaoguo.gif\">"]];
        [xiaoXiaoArray addObject:[self createSmileyInfo:@"x020.png" with:@"$敲脑袋" for:@"<img name=\"SystemFace\" src=\"../../image/face/xiaoxiao/qiaonaodai.gif\">"]];
        [xiaoXiaoArray addObject:[self createSmileyInfo:@"x021.png" with:@"$色" for:@"<img name=\"SystemFace\" src=\"../../image/face/xiaoxiao/se.gif\">"]];
        [xiaoXiaoArray addObject:[self createSmileyInfo:@"x022.png" with:@"$生气" for:@"<img name=\"SystemFace\" src=\"../../image/face/xiaoxiao/shengqi.gif\">"]];
        [xiaoXiaoArray addObject:[self createSmileyInfo:@"x023.png" with:@"$睡觉" for:@"<img name=\"SystemFace\" src=\"../../image/face/xiaoxiao/shuijiao.gif\">"]];
        [xiaoXiaoArray addObject:[self createSmileyInfo:@"x024.png" with:@"$叹气" for:@"<img name=\"SystemFace\" src=\"../../image/face/xiaoxiao/tanqi.gif\">"]];
        [xiaoXiaoArray addObject:[self createSmileyInfo:@"x025.png" with:@"$疑问" for:@"<img name=\"SystemFace\" src=\"../../image/face/xiaoxiao/yiwen.gif\">"]];
        [xiaoXiaoArray addObject:[self createSmileyInfo:@"x026.png" with:@"$晕" for:@"<img name=\"SystemFace\" src=\"../../image/face/xiaoxiao/yun.gif\">"]];
        [xiaoXiaoArray addObject:[self createSmileyInfo:@"x027.png" with:@"$撞墙" for:@"<img name=\"SystemFace\" src=\"../../image/face/xiaoxiao/zhuangqiang.gif\">"]];
        [xiaoXiaoArray addObject:[self createSmileyInfo:@"x028.png" with:@"$走你" for:@"<img name=\"SystemFace\" src=\"../../image/face/xiaoxiao/zouni.gif\">"]];
        [xiaoXiaoArray addObject:[self createSmileyInfo:@"x029.png" with:@"$做鬼脸" for:@"<img name=\"SystemFace\" src=\"../../image/face/xiaoxiao/zuoguilian.gif\">"]];
        
    }
}

-(void) initBangBingInfos
{
    if(bangbingArray == nil)
    {
        bangbingArray = [NSMutableArray arrayWithCapacity:33];
        [bangbingArray addObject:[self createSmileyInfo:@"b000.png" with:@"&扮鬼脸" for:@"<img name=\"SystemFace\" src=\"../../image/face/ice_candy/banguilian.gif\">"]];
        [bangbingArray addObject:[self createSmileyInfo:@"b001.png" with:@"&被劈" for:@"<img name=\"SystemFace\" src=\"../../image/face/ice_candy/beipi.gif\">"]];
        [bangbingArray addObject:[self createSmileyInfo:@"b002.png" with:@"&鄙视" for:@"<img name=\"SystemFace\" src=\"../../image/face/ice_candy/bishi.gif\">"]];
        [bangbingArray addObject:[self createSmileyInfo:@"b003.png" with:@"&菜叶笑" for:@"<img name=\"SystemFace\" src=\"../../image/face/ice_candy/caiyexiao.gif\">"]];
        [bangbingArray addObject:[self createSmileyInfo:@"b004.png" with:@"&打哈欠" for:@"<img name=\"SystemFace\" src=\"../../image/face/ice_candy/dahaqian.gif\">"]];
        [bangbingArray addObject:[self createSmileyInfo:@"b005.png" with:@"&大哭" for:@"<img name=\"SystemFace\" src=\"../../image/face/ice_candy/daku.gif\">"]];
        [bangbingArray addObject:[self createSmileyInfo:@"b006.png" with:@"&得瑟" for:@"<img name=\"SystemFace\" src=\"../../image/face/ice_candy/dese.gif\">"]];
        [bangbingArray addObject:[self createSmileyInfo:@"b007.png" with:@"&发狂" for:@"<img name=\"SystemFace\" src=\"../../image/face/ice_candy/fakuang.gif\">"]];
        [bangbingArray addObject:[self createSmileyInfo:@"b008.png" with:@"&发怒" for:@"<img name=\"SystemFace\" src=\"../../image/face/ice_candy/fanu.gif\">"]];
        [bangbingArray addObject:[self createSmileyInfo:@"b009.png" with:@"&放电" for:@"<img name=\"SystemFace\" src=\"../../image/face/ice_candy/fangdian.gif\">"]];
        [bangbingArray addObject:[self createSmileyInfo:@"b010.png" with:@"&浮云飘过" for:@"<img name=\"SystemFace\" src=\"../../image/face/ice_candy/fuyunpiaoguo.gif\">"]];
        [bangbingArray addObject:[self createSmileyInfo:@"b011.png" with:@"&害羞" for:@"<img name=\"SystemFace\" src=\"../../image/face/ice_candy/haixiu.gif\">"]];
        [bangbingArray addObject:[self createSmileyInfo:@"b012.png" with:@"&汗" for:@"<img name=\"SystemFace\" src=\"../../image/face/ice_candy/han.gif\">"]];
        [bangbingArray addObject:[self createSmileyInfo:@"b013.png" with:@"&花痴" for:@"<img name=\"SystemFace\" src=\"../../image/face/ice_candy/huachi.gif\">"]];
        [bangbingArray addObject:[self createSmileyInfo:@"b014.png" with:@"&坏笑" for:@"<img name=\"SystemFace\" src=\"../../image/face/ice_candy/huaixiao.gif\">"]];
        [bangbingArray addObject:[self createSmileyInfo:@"b015.png" with:@"&囧" for:@"<img name=\"SystemFace\" src=\"../../image/face/ice_candy/jiong.gif\">"]];
        [bangbingArray addObject:[self createSmileyInfo:@"b016.png" with:@"&开心的感动" for:@"<img name=\"SystemFace\" src=\"../../image/face/ice_candy/kaixindegandong.gif\">"]];
        [bangbingArray addObject:[self createSmileyInfo:@"b017.png" with:@"&可怜" for:@"<img name=\"SystemFace\" src=\"../../image/face/ice_candy/kelian.gif\">"]];
        [bangbingArray addObject:[self createSmileyInfo:@"b018.png" with:@"&抠鼻子" for:@"<img name=\"SystemFace\" src=\"../../image/face/ice_candy/koubizi.gif\">"]];
        [bangbingArray addObject:[self createSmileyInfo:@"b019.png" with:@"&快哭了" for:@"<img name=\"SystemFace\" src=\"../../image/face/ice_candy/kuaichule.gif\">"]];
        [bangbingArray addObject:[self createSmileyInfo:@"b020.png" with:@"&困" for:@"<img name=\"SystemFace\" src=\"../../image/face/ice_candy/kun.gif\">"]];
        [bangbingArray addObject:[self createSmileyInfo:@"b021.png" with:@"&冷汗" for:@"<img name=\"SystemFace\" src=\"../../image/face/ice_candy/lenghan.gif\">"]];
        [bangbingArray addObject:[self createSmileyInfo:@"b022.png" with:@"&流鼻涕" for:@"<img name=\"SystemFace\" src=\"../../image/face/ice_candy/liubiti.gif\">"]];
        [bangbingArray addObject:[self createSmileyInfo:@"b023.png" with:@"&流泪" for:@"<img name=\"SystemFace\" src=\"../../image/face/ice_candy/liulei.gif\">"]];
        [bangbingArray addObject:[self createSmileyInfo:@"b024.png" with:@"&亲亲" for:@"<img name=\"SystemFace\" src=\"../../image/face/ice_candy/qinqin.gif\">"]];
        [bangbingArray addObject:[self createSmileyInfo:@"b025.png" with:@"&偷笑" for:@"<img name=\"SystemFace\" src=\"../../image/face/ice_candy/touxiao.gif\">"]];
        [bangbingArray addObject:[self createSmileyInfo:@"b026.png" with:@"&微笑" for:@"<img name=\"SystemFace\" src=\"../../image/face/ice_candy/weixiao.gif\">"]];
        [bangbingArray addObject:[self createSmileyInfo:@"b027.png" with:@"&委屈" for:@"<img name=\"SystemFace\" src=\"../../image/face/ice_candy/weiqu.gif\">"]];
        [bangbingArray addObject:[self createSmileyInfo:@"b028.png" with:@"&一周表情戏" for:@"<img name=\"SystemFace\" src=\"../../image/face/ice_candy/yizhoubiaoqingxi.gif\">"]];
        [bangbingArray addObject:[self createSmileyInfo:@"b029.png" with:@"&晕" for:@"<img name=\"SystemFace\" src=\"../../image/face/ice_candy/yun.gif\">"]];
        [bangbingArray addObject:[self createSmileyInfo:@"b030.png" with:@"&再见" for:@"<img name=\"SystemFace\" src=\"../../image/face/ice_candy/zaijian.gif\">"]];
        [bangbingArray addObject:[self createSmileyInfo:@"b031.png" with:@"&中毒" for:@"<img name=\"SystemFace\" src=\"../../image/face/ice_candy/zhongdu.gif\">"]];
        [bangbingArray addObject:[self createSmileyInfo:@"b032.png" with:@"&转眼睛" for:@"<img name=\"SystemFace\" src=\"../../image/face/ice_candy/zhuanyanjing.gif\">"]];
    }
}

@end
