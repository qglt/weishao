//
//  BizlayerProxy.m
//  Whistle
//
//  Created by chao.wang on 13-1-15.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//

#import "BizlayerProxy.h"
#import "JSONObjectHelper.h"
#import "BizBridge.h"
#import "Constants.h"


@implementation BizlayerProxy


SINGLETON_IMPLEMENT(BizlayerProxy)


-(id)init
{
    self = [super init];
    if(self){
        self.whistleBizBridge = [BizBridge getSingleInstance];
        self.pushMap = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

-(void)reset
{
    [self.whistleBizBridge removeAllListener];
}

-(void)login:(NSString*)userName password:(NSString*)pss rememberPW:(BOOL)savePss autoLogin:(BOOL)autoLog status:(NSString*) status callback:(WhistleCommandCallbackType)listener
{
    @autoreleasepool {
        NSMutableDictionary *jsonObj = [NSMutableDictionary dictionaryWithCapacity:6];
        [jsonObj setValue:userName forKey:KEY_USER_NAME];
        [jsonObj setValue:pss forKey:KEY_USER_PASSWD];
        [jsonObj setValue:status forKey:KEY_LAST_LOGIN_STATUS];
        [jsonObj setValue: [NSNumber numberWithInt: savePss?1:0] forKey:KEY_SAVE_PASSWD];
        [jsonObj setValue: [NSNumber numberWithInt: autoLog?1:0] forKey:KEY_AUTO_LOGIN];
        
//        [jsonObj setValue:self.headImg forKey:KEY_HEAD_IMG];
        [self.whistleBizBridge asyncCall:LOGIN inputPara:[JSONObjectHelper encodeStringFromJSON:jsonObj] callback:listener];
    }
}

-(void)getLoginHistory:(WhistleCommandCallbackType)listener
{
    @autoreleasepool {
        

    [self.whistleBizBridge asyncCall:GETLOGINHISTORY inputPara:@"{}" callback:listener];
    }
}

-(void)changeUser:(WhistleCommandCallbackType)listener
{
    @autoreleasepool {
        
 
    [self.whistleBizBridge asyncCall:CHANGE_USER inputPara:@"{}" callback:listener];
    }
}

-(void)getRoster:(WhistleCommandCallbackType)listener
{
    @autoreleasepool {
        

    [self.whistleBizBridge asyncCall:GETROSTER inputPara:@"{}" callback:listener];

    }
}
-(void)getUserDetailInfo:(NSString *)jid callback:(WhistleCommandCallbackType)listener  {
    @autoreleasepool {
        

    NSMutableDictionary *jsonObj = [[NSMutableDictionary alloc] init];
    [jsonObj setObject:jid forKey:KEY_JID];
    [self.whistleBizBridge asyncCall:GETDETAILEDINFO inputPara:[JSONObjectHelper encodeStringFromJSON:jsonObj] callback:listener];
        jsonObj = nil;
    }
}

//会话列表
-(void) getLocalRecentList:(WhistleCommandCallbackType)listener {
    @autoreleasepool {
        

    [self.whistleBizBridge asyncCall:GET_LOCAL_RECENT_LIST inputPara:@"{}" callback:listener];
    }
}



-(void)getUnreadNotices:(WhistleCommandCallbackType)listener  {
    @autoreleasepool {
        

    NSMutableDictionary *jsonObj = [[NSMutableDictionary alloc] init];
    [jsonObj setValue:@"notice" forKey:KEY_TYPE];
    [self.whistleBizBridge asyncCall:@"get_conv_unread" inputPara:[JSONObjectHelper encodeStringFromJSON:jsonObj] callback:listener];
        jsonObj = nil;
    }
}


-(void) closeApp:(WhistleCommandCallbackType)listener  {
    NSLog(@"%@",@"closeApp");
    @autoreleasepool {
        

    [self.whistleBizBridge asyncCall:CLOSE_APP inputPara:@"{}" callback:listener];
    }
}

-(void) goOffline:(WhistleCommandCallbackType)listener  {
    NSLog(@"%@",@"goOffline");
    @autoreleasepool {
        

    [self.whistleBizBridge asyncCall:@"go_offline" inputPara:@"{}" callback:listener];
    }
}


-(void) storeMyInfo:(NSMutableDictionary *)param withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"storeMyInfo");
    @autoreleasepool {
        

    [self.whistleBizBridge asyncCall:STOREMYINFO inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
    }
}


-(void) sendMessage:(NSString *)jid withMsg:(NSString *)msg withListener:(WhistleCommandCallbackType)listener {
    @autoreleasepool {
        

    NSLog(@"%@",@"sendMessage");
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *msgJSON = [[NSMutableDictionary alloc] init];
    [msgJSON setValue:msg forKey:KEY_TXT];
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* str = [formatter stringFromDate:date];
    [msgJSON setValue:str forKey:KEY_TIME];
    [msgJSON setValue:[NSString stringWithFormat:@"%i",(int)[[NSDate date] timeIntervalSince1970]] forKey:KEY_STDTIME];
    [msgJSON setValue:@"details" forKey:@"yourcls"];
    [msgJSON setValue:@"outline: none; " forKey:@"details"];
    [msgJSON setValue:@"color: rgb(49, 49, 49); font-family: 微软雅黑; font-size: 15px;" forKey:@"style"];
    [param setValue:msgJSON forKey:KEY_MSG];
    [param setValue:msg forKey:KEY_TXT];
    [param setValue:jid forKey:KEY_TARGET];
    NSLog(@"send message is %@",msgJSON);
    //    JSONObjectHelper.putObjectToJSONObject(param, , );
    [self.whistleBizBridge asyncCall:SENDMESSAGE inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
        param = nil;
        msgJSON = nil;
        formatter = nil;
    }
    
}
-(void) sendImageMessage:(NSString *)jid withID:(NSString *)id withSRC:(NSString *)src withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"sendImageMessage");
    @autoreleasepool {
        

    NSString *msg = [NSString stringWithFormat: @"<img src=\"../../image/default/imgloading.gif\" class=\"%@\" style='max-height:200px;'>",id];

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:jid forKey:KEY_TARGET];

    NSMutableDictionary *msgJSON = [[NSMutableDictionary alloc] init];
    [msgJSON setValue:msg forKey:KEY_TXT];
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* str = [formatter stringFromDate:date];
    [msgJSON setValue:str forKey:KEY_TIME];
    [msgJSON setValue:[NSString stringWithFormat:@"%i",(int)[[NSDate date] timeIntervalSince1970]] forKey:KEY_STDTIME];
    [msgJSON setValue:@"details" forKey:@"yourcls"];
    [msgJSON setValue:@"outline: none; " forKey:@"details"];

    NSMutableDictionary *idObj = [[NSMutableDictionary alloc] init];
    [idObj setValue:src forKey:id];
    [msgJSON setValue:idObj forKey:KEY_IMAGE];

    [param setValue:msgJSON forKey:KEY_MSG];
    //    JSONObjectHelper.putObjectToJSONObject(param, , );
    [self.whistleBizBridge asyncCall:SENDMESSAGE inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
        param = nil;
        msgJSON = nil;
        formatter = nil;
        idObj = nil;
    }
}

-(void) sendVoiceMessage:(NSString *)jid withID:(NSString *)src_id withSRC:(NSString *)src duration:(int) duration withListener:(WhistleCommandCallbackType)listener {
    @autoreleasepool {
        NSString *msg = @"";
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:jid forKey:KEY_TARGET];
        
        NSMutableDictionary *msgJSON = [[NSMutableDictionary alloc] init];
        [msgJSON setValue:msg forKey:KEY_TXT];
        NSDate* date = [NSDate date];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString* str = [formatter stringFromDate:date];
        [msgJSON setValue:str forKey:KEY_TIME];
        [msgJSON setValue:@"details" forKey:@"yourcls"];
        [msgJSON setValue:@"outline: none; " forKey:@"details"];
        
        NSMutableDictionary *idObj = [[NSMutableDictionary alloc] init];
        [idObj setValue:src forKey:src_id];
        [msgJSON setValue:idObj forKey:KEY_VOICE];
        [msgJSON setValue:[NSNumber numberWithInt:duration] forKey:KEY_DURATION];
        
        [param setValue:msgJSON forKey:KEY_MSG];
        [self.whistleBizBridge asyncCall:SENDMESSAGE inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
        param = nil;
        msgJSON = nil;
        formatter = nil;
        idObj = nil;
    }
}

-(void)sendHelloMessage:(NSString *)jid withID:(NSString *)uuid withListener:(WhistleCommandCallbackType)listener
{
    @autoreleasepool {
        
        NSMutableDictionary*        param                   = [[NSMutableDictionary alloc] init];
        [param setValue:jid forKey:KEY_TARGET];
        
        NSMutableDictionary*        msgJSON                 = [[NSMutableDictionary alloc] init];
        
        [msgJSON setObject:uuid forKey:@"hello_id"];//hello
        
        [msgJSON setObject:@"hello" forKey:KEY_TYPE];
        
        [param setValue:msgJSON forKey:KEY_MSG];
        
        [self.whistleBizBridge asyncCall:SEND_LIGHTAPP_MESSAGE inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
        param = nil;
        msgJSON = nil;
    }
}

-(void) sendVideoMessage:(NSString *)jid withID:(NSString *)src_id withSRC:(NSString *)src duration:(int) duration withListener:(WhistleCommandCallbackType)listener
{
    
}

- (void) sendLightAppMessage:(NSString *)appid event:(NSString *)event eventKey:(NSString *)eventKey callback:(WhistleCommandCallbackType)callback
{
    NSMutableDictionary* tmp = [[NSMutableDictionary alloc] init];
    [tmp setValue:appid forKey:KEY_TARGET];
    
    NSDictionary* event_dic = [[NSDictionary alloc] initWithObjectsAndKeys:event, KEY_EVENT, eventKey, KEY_EVENTKEY, nil];
    NSDictionary* msg_dic = [[NSDictionary alloc] initWithObjectsAndKeys:event_dic, KEY_EVENT, KEY_EVENT, KEY_TYPE, nil];
    
    [tmp setValue:msg_dic forKey:KEY_MSG];
    [self.whistleBizBridge asyncCall:SEND_LIGHTAPP_MESSAGE inputPara:[JSONObjectHelper encodeStringFromJSON:tmp] callback:callback];
    tmp = nil;
}

- (void) sendLightAppMessage:(NSString *)appid image:(NSString *)filepath callback:(WhistleCommandCallbackType)callback
{
    NSMutableDictionary* tmp = [[NSMutableDictionary alloc] init];
    [tmp setValue:appid forKey:KEY_TARGET];
    
    NSDictionary* msg_dic = [[NSDictionary alloc] initWithObjectsAndKeys: filepath, KEY_IMAGE , KEY_IMAGE, KEY_TYPE, nil];
    
    [tmp setValue:msg_dic forKey:KEY_MSG];
    
    [self.whistleBizBridge asyncCall:SEND_LIGHTAPP_MESSAGE inputPara:[JSONObjectHelper encodeStringFromJSON:tmp] callback:callback];
    tmp = nil;
}

- (void) sendLightAppMessage:(NSString *)appid voice:(NSString *)filepath length:(NSUInteger) length callback:(WhistleCommandCallbackType)callback
{
    NSDictionary* tmp = @{KEY_TARGET : appid, KEY_MSG : @{KEY_TYPE : KEY_VOICE, KEY_VOICE : filepath, KEY_VOICE_LENGTH : [NSNumber numberWithInt:length]}};
    [self asyncCall:SEND_LIGHTAPP_MESSAGE param:tmp callback:callback];
    tmp = nil;
}

- (void) sendLightAppMessage:(NSString *)appid linkTitle:(NSString *)title description:(NSString *)description url:(NSString *)url callback:(WhistleCommandCallbackType)callback
{
    NSMutableDictionary* tmp = [[NSMutableDictionary alloc] init];
    [tmp setValue:appid forKey:KEY_TARGET];
    
    NSDictionary* link_dic = [[NSDictionary alloc] initWithObjectsAndKeys:title, KEY_title, description, KEY_DESCRIPTION, url, KEY_URL, nil];
    NSDictionary* msg_dic = [[NSDictionary alloc] initWithObjectsAndKeys:link_dic, KEY_LINK, KEY_LINK, KEY_TYPE, nil];
    
    [tmp setValue:msg_dic forKey:KEY_MSG];
    
    [self.whistleBizBridge asyncCall:SEND_LIGHTAPP_MESSAGE inputPara:[JSONObjectHelper encodeStringFromJSON:tmp] callback:callback];
    tmp = nil;
}

- (void) sendLightAppMessage:(NSString *)appid text:(NSString *)content callback:(WhistleCommandCallbackType)callback
{
    NSMutableDictionary* tmp = [[NSMutableDictionary alloc] init];
    [tmp setValue:appid forKey:KEY_TARGET];
    
    NSDictionary* msg_dic = [[NSDictionary alloc] initWithObjectsAndKeys:content, KEY_CONTENT, KEY_TEXT, KEY_TYPE, nil];
    
    [JSONObjectHelper putObject:msg_dic withKey:KEY_MSG toJSONObject:tmp];
    
    [self.whistleBizBridge asyncCall:SEND_LIGHTAPP_MESSAGE inputPara:[JSONObjectHelper encodeStringFromJSON:tmp] callback:callback];
    tmp = nil;

}

- (void) sendLightAppMessage:(NSString *)appid x:(double)x y:(double)y scale:(double)scale label:(NSString *)label callback:(WhistleCommandCallbackType)callback
{
    NSMutableDictionary* tmp = [[NSMutableDictionary alloc] init];
    [tmp setValue:appid forKey:KEY_TARGET];
    
    NSDictionary* loc_dic = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%f", x], KEY_LOCATION_X, [NSString stringWithFormat:@"%f", y], KEY_LOCATION_Y, [NSString stringWithFormat:@"%f", scale], KEY_SCALE, label, KEY_LABEL, nil];
    NSDictionary* msg_dic = [[NSDictionary alloc] initWithObjectsAndKeys:loc_dic, KEY_LOCATION, KEY_LOCATION, KEY_TYPE, nil];
    
    [tmp setValue:msg_dic forKey:KEY_MSG];
    
    [self.whistleBizBridge asyncCall:SEND_LIGHTAPP_MESSAGE inputPara:[JSONObjectHelper encodeStringFromJSON:tmp] callback:callback];
    tmp = nil;
}

- (void) getLightappMsgHistory:(NSString *)appid index:(NSInteger)index count:(NSInteger)count callback:(WhistleCommandCallbackType)callback
{
    NSDictionary* tmp = [[NSDictionary alloc] initWithObjectsAndKeys:appid, KEY_APPID, [NSString stringWithFormat:@"%d", index], KEY_BEGIN_IDX, [NSString stringWithFormat:@"%d", count], KEY_COUNT, nil];
    [self.whistleBizBridge asyncCall:GET_LIGHTAPP_MESSAGE_HISTORY inputPara:[JSONObjectHelper encodeStringFromJSON:tmp] callback:callback];
    tmp = nil;
}

- (void) deleteLightappMessage:(NSString *)appid rowid:(NSString *)rowid callback:(WhistleCommandCallbackType)callback
{
    NSDictionary* tmp = [[NSDictionary alloc] initWithObjectsAndKeys:appid, KEY_APPID, rowid, KEY_ROWID, nil];
    [self.whistleBizBridge asyncCall:DELETE_LIGHTAPP_MESSAGE inputPara:[JSONObjectHelper encodeStringFromJSON:tmp] callback:callback];
    tmp = nil;
}
//删除appid的所有消息
- (void) deleteLightappMessage:(NSString *)appid callback:(WhistleCommandCallbackType)callback
{
    [self deleteLightappMessage:appid rowid:nil callback:callback];
}
- (void) getLightappMessageNotifyServer:(WhistleCommandCallbackType)callback
{
    [self.whistleBizBridge asyncCall:GET_LIGHTAPP_MESSAGE inputPara:@"" callback:callback];
}

- (void) getLightappUnreadMsg:(NSString *)appid callback:(WhistleCommandCallbackType)callback
{
    NSDictionary* tmp = [[NSDictionary alloc] initWithObjectsAndKeys:@"lightapp", KEY_TYPE, appid, KEY_APPID, nil];
    [self.whistleBizBridge asyncCall:GET_CONV_UNREAD inputPara:[JSONObjectHelper encodeStringFromJSON:tmp] callback:callback];
    tmp = nil;
}

-(void) getConversationUnreadCount:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"getConversationUnreadCount");
    @autoreleasepool {
        

    //    JSONObjectHelper.putObjectToJSONObject(param, , );
    [self.whistleBizBridge asyncCall:GETCONVUNREADCOUNT inputPara:@"{}" callback:listener];
    }
}

-(void) getConversationUnreadMessage:(NSString *)jid withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"getConversationUnreadMessage");
    @autoreleasepool {
        

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:jid forKey:KEY_JID];
    //    JSONObjectHelper.putObjectToJSONObject(param, , );
    [self.whistleBizBridge asyncCall:GET_CONV_UNREAD inputPara:[JSONObjectHelper encodeStringFromJSON:param]  callback:listener];
        param = nil;
    }
}

-(void) deleteAccountFromHistory:(NSString *)userName withDeleteLocalFile:(Boolean)deleteLocalFile withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"deleteAccountFromHistory");
    
    @autoreleasepool {
        

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:userName forKey:KEY_USER_NAME];
    if (deleteLocalFile) {
        [param setValue:@"true" forKey:KEY_DELETE_LOCAL_FILE];
        
    }else{
        [param setValue:@"false" forKey:KEY_DELETE_LOCAL_FILE];
        
    }
    //    JSONObjectHelper.putObjectToJSONObject(param, , );
    [self.whistleBizBridge asyncCall:DELETEACCOUNTFROMHISTORY inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
        param = nil;
    }
}

-(void) getConversationHistoryWithTargetDetail:(NSString *)userName withDeleteLocalFile:(Boolean)deleteLocalFile withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"getConversationHistoryWithTargetDetail");
    
    @autoreleasepool {
        

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:userName forKey:KEY_USER_NAME];
    if (deleteLocalFile) {
        [param setValue:@"true" forKey:KEY_DELETE_LOCAL_FILE];
        
    }else{
        [param setValue:@"false" forKey:KEY_DELETE_LOCAL_FILE];
        
    }
    //    JSONObjectHelper.putObjectToJSONObject(param, , );
    [self.whistleBizBridge asyncCall:AGREEJOINCROWD inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
        param = nil;
    }
}

-(void) getConversationHistoryWithTargetDetail:(NSString *)jid withConvType:(NSString *)convType withBeginIndex:(int)beginIndex withCount:(int)count withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"getConversationHistoryWithTargetDetail");
    
    @autoreleasepool {
        

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:jid forKey:KEY_JID];
    [param setValue:[NSString stringWithFormat:@"%d",beginIndex] forKey:KEY_BEGIN_IDX];
    [param setValue:[NSString stringWithFormat:@"%d",count] forKey:KEY_COUNT];
    [param setValue:convType forKey:KEY_TYPE];
    
    //    JSONObjectHelper.putObjectToJSONObject(param, , );
    [self.whistleBizBridge asyncCall:GET_CONV_HISTORY inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
        param = nil;
    }
}

-(void) getNoticeList:(int)beginIndex withCount:(int)count withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"getConversationHistoryWithTargetDetail");
    
    @autoreleasepool {
        

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:[NSString stringWithFormat:@"%d",beginIndex] forKey:KEY_BEGIN_IDX];
    [param setValue:[NSString stringWithFormat:@"%d",count] forKey:KEY_COUNT];
    [param setValue:@"notice" forKey:KEY_TYPE];
    
    //    JSONObjectHelper.putObjectToJSONObject(param, , );
    [self.whistleBizBridge asyncCall:GET_CONV_HISTORY inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
        param = nil;
    }
}

-(void) findContact:(NSString *)searchStr withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"findContact");
    
    @autoreleasepool {
        

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:searchStr forKey:KEY_SEARCH];
    
    //    JSONObjectHelper.putObjectToJSONObject(param, , );
    [self.whistleBizBridge asyncCall:FINDCONTACT inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
        param = nil;
    }
}

-(void) findFriendOnLine:(NSString *)type withSearchStr:(NSString *)searchStr wihtIndex:(int)index withMax:(int)max withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"findFriendOnLine");
    @autoreleasepool {
        

    id searchObject;
    
    searchObject = [NSNull null];
    
    if (searchStr != nil){
        searchObject = searchStr;
    }
    
    NSString *searchMode = @"fuzzy";
    
    if ([type isEqualToString:@"aid"]) {
        searchMode = @"exact";
    }
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:searchObject forKey:type];
    [param setValue:searchMode forKey:@"mode"];
    [param setValue:[NSString stringWithFormat:@"%d",index] forKey:KEY_INDEX];
    [param setValue:[NSString stringWithFormat:@"%d",max] forKey:KEY_MAX];
    //[param setValue:searchStr forKey:KEY_SEARCH];
    
    //    JSONObjectHelper.putObjectToJSONObject(param, , );
    [self.whistleBizBridge asyncCall:FINDFRIEND inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
        param = nil;
    }
}

-(void) setBuddyRemark:(NSString *)jid withRemark:(NSString *)remark withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"setBuddyRemark");
    
    @autoreleasepool {
        

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:jid forKey:KEY_JID];
    [param setValue:remark forKey:KEY_REMARK];
    
    //    JSONObjectHelper.putObjectToJSONObject(param, , );
    [self.whistleBizBridge asyncCall:SETBUDDYREMARK inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
        param = nil;
    }
}

-(void) removeBuddy:(NSString *)jid withRemoveMeFromHisList:(Boolean)removeMeFromHisList withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"removeBuddy");
    
    @autoreleasepool {
        

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:jid forKey:KEY_BUDDY_ID];
    if (removeMeFromHisList) {
        [param setValue:[NSNumber numberWithBool:YES] forKey:KEY_REMOVE_ME_FROM_HIS_LIST];

    }else{
        [param setValue:[NSNumber numberWithBool:NO] forKey:KEY_REMOVE_ME_FROM_HIS_LIST];
    }
    
    //    JSONObjectHelper.putObjectToJSONObject(param, , );
    [self.whistleBizBridge asyncCall:REMOVEBUDDY inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
        param = nil;
    }
}
-(void) addFriend:(NSString *)jid withName:(NSString *)name withMsg:(NSString *)msg withGroupName:(NSString *)group_name withListener:(WhistleCommandCallbackType)listener {
    @autoreleasepool {
        

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:jid forKey:KEY_JID];
    [param setValue:name forKey:KEY_NAME];
    [param setValue:msg forKey:KEY_MSG];
    [param setValue:group_name forKey:KEY_GROUP];
    
    //    JSONObjectHelper.putObjectToJSONObject(param, , );
    [self.whistleBizBridge asyncCall:ADDFRIEND inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
    param = nil;
    }
}

-(void) ackAddFriend:(NSString *)jid withAck:(Boolean)ack withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"ackAddFriend");
    
    @autoreleasepool {
        

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:jid forKey:KEY_JID];
    
    if (ack) {
        [param setValue:[NSNumber numberWithBool:YES] forKey:KEY_ACK];
        
    }else{
        [param setValue:[NSNumber numberWithBool:NO] forKey:KEY_ACK];
        NSMutableDictionary *subParam = [[NSMutableDictionary alloc] init];
        [subParam setValue:@"refuse" forKey:KEY_TYPE];
        [subParam setValue:@"" forKey:KEY_MSG];
        [param setValue:subParam forKey:KEY_REASON];
        
    }

    //    JSONObjectHelper.putObjectToJSONObject(param, , );
    [self.whistleBizBridge asyncCall:ACKADDFRIEND inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
        param = nil;
    }
}
-(void) deleteConversationHistory:(NSString *)jid withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"deleteConversationHistory");
    
    @autoreleasepool {
        

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:jid forKey:KEY_JID];
    //    JSONObjectHelper.putObjectToJSONObject(param, , );
    [self.whistleBizBridge asyncCall:DELETE_CONVERSATION_HISTORY inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
        param = nil;
    }
}

-(void) deleteNoticeHistory:(NSString *)noticeId withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"deleteNoticeHistory");
    
    @autoreleasepool {
        

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:noticeId forKey:KEY_NOTICE_ID];
    //    JSONObjectHelper.putObjectToJSONObject(param, , );
    [self.whistleBizBridge asyncCall:DELETE_NOTICE_HISTORY inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
        param = nil;
    }
}

- (void) deleteReadedNotices:(WhistleCommandCallbackType)callback
{
    [self asyncCall:COMMAND_DELETE_ALL_READED_NOTICE param:nil callback:callback];
}

- (void) deleteAllNotices:(WhistleCommandCallbackType)callback
{
    [self asyncCall:COMMAND_DELETE_ALL_NOTICE param:nil callback:callback];
}

-(void) setStatus:(NSString *)status withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"deleteNoticeHistory");
    
    @autoreleasepool {
        

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:status forKey:@"presence"];
    //    JSONObjectHelper.putObjectToJSONObject(param, , );
    [self.whistleBizBridge asyncCall:SETSTATUS inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
        param = nil;
    }
}

-(void) storeLocal:(NSString *)key withValue:(NSString *)value withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"storeLocal");
    
    @autoreleasepool {
        

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:key forKey:KEY_KEY];
    [param setValue:value forKey:KEY_VALUE];
    
    //    JSONObjectHelper.putObjectToJSONObject(param, , );
    [self.whistleBizBridge asyncCall:STORELOCAL inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
        
        param =nil;
    }
}

-(void) getLocal:(NSString *)key withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"getLocal");
    
    @autoreleasepool {
        

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:key forKey:KEY_KEY];
    
    //    JSONObjectHelper.putObjectToJSONObject(param, , );
    [self.whistleBizBridge asyncCall:GETLOCAL inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
        param = nil;
    }
}

-(void) getRelationship:(NSString *)jid withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"getRelationship");
    @autoreleasepool {
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:jid forKey:KEY_JID];
    
    //    JSONObjectHelper.putObjectToJSONObject(param, , );
    [self.whistleBizBridge asyncCall:GETRELATIONSHIP inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
        param = nil;
    }
}

-(void) getUnreadNotices:(NSString *)jid withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"getUnreadNotices");
    
    @autoreleasepool {
        

    //    JSONObjectHelper.putObjectToJSONObject(param, , );
    [self.whistleBizBridge asyncCall:GET_CONV_UNREAD inputPara:@"{}" callback:listener];
        
    }
}

-(void) setLightAppReaded:(NSString *)jid withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"setLightAppReaded");
    
    @autoreleasepool {
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:jid forKey:KEY_APPID];
        [param setValue:[NSNumber numberWithBool:true] forKey:@"mark_read"];
        [param setValue:@"lightapp" forKey:KEY_TYPE];
        //    JSONObjectHelper.putObjectToJSONObject(param, , );
        [self.whistleBizBridge asyncCall:GET_CONV_UNREAD inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
        
    }
}

-(void) markMessageRead:(NSString *)jid withType:(NSString *)type withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"markMessageRead");
    @autoreleasepool {
        

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:jid forKey:KEY_JID];
    [param setValue:type forKey:KEY_TYPE];
    
    //    JSONObjectHelper.putObjectToJSONObject(param, , );
    [self.whistleBizBridge asyncCall:MARK_MESSAGE_READ inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
//    [self sendUpdateRecentContactNotify:jid from:[AnanUtils getChatType:jid] to:MARKREAD];
        param = nil;
    }
}

-(void) updateImage:(NSString *)imgPath withimgWidth:(int)imgWidth  withimgHeight:(int)imgHeight withcropTop:(int)cropTop withcropLeft:(int)cropLeft withcropBotton:(int)cropBotton withcropRight:(int)cropRight withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"updateImage");
    @autoreleasepool {
        

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:imgPath forKey:KEY_IMG_PATH];
    [param setValue:@"head_up" forKey:KEY_IMG_TYPE];
 
    NSMutableDictionary *imgSizeJson = [[NSMutableDictionary alloc] init];
    [imgSizeJson setValue:[NSString stringWithFormat:@"%d",imgWidth] forKey:KEY_WIDTH];
    [imgSizeJson setValue:[NSString stringWithFormat:@"%d",imgHeight] forKey:KEY_HEIGHT];
    [param setValue:imgSizeJson forKey:KEY_IMG_SIZE];
    
    NSMutableDictionary *cropJson = [[NSMutableDictionary alloc] init];
    [cropJson setValue:[NSString stringWithFormat:@"%d",cropTop] forKey:KEY_TOP];
    [cropJson setValue:[NSString stringWithFormat:@"%d",cropLeft] forKey:KEY_LEFT];
    [cropJson setValue:[NSString stringWithFormat:@"%d",cropBotton] forKey:KEY_BOTTOM];
    [cropJson setValue:[NSString stringWithFormat:@"%d",cropRight] forKey:KEY_RIGHT];
        
        NSDictionary* stretch = @{KEY_WIDTH: [NSNumber numberWithInt:150], KEY_HEIGHT: [NSNumber numberWithInt:150]};
        [param setValue:stretch forKey:KEY_STRETCH];
    [param setValue:cropJson forKey:KEY_CROP_AREA];
    //    JSONObjectHelper.putObjectToJSONObject(param, , );
    [self.whistleBizBridge asyncCall:UPDATE_IMAGE inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
        param = nil;
        imgSizeJson = nil;
        cropJson = nil;
    }
}

-(void) getImage:(NSString *)imgid withName:(NSString *)name withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"getImage");
    @autoreleasepool {
        

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:imgid forKey:KEY_ID];
    [param setValue:name forKey:KEY_URL];
    
    //    JSONObjectHelper.putObjectToJSONObject(param, , );
    [self.whistleBizBridge asyncCall:GET_IMAGE inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
     
        param = nil;
    }
}
-(void) getVoice:(NSString *)voiceid withName:(NSString *)name withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"getImage");
    @autoreleasepool {
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:voiceid forKey:KEY_ID];
        [param setValue:name forKey:KEY_URL];
        
        [self.whistleBizBridge asyncCall:COMMAND_GET_VOICE inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
     
        param = nil;
    }
}

- (void) replaceMsgByRowid:(NSString *)msg rowid:(NSString *)rowid withType:(NSString *)type callback:(WhistleCommandCallbackType)callback
{
    NSDictionary* tmp = [[NSDictionary alloc] initWithObjectsAndKeys:type,KEY_TYPE, rowid, KEY_ROW_ID, msg, KEY_MSG, nil];
    [self.whistleBizBridge asyncCall:COMMAND_REPLACE_MESSAGE_BY_ROWID inputPara:[JSONObjectHelper encodeStringFromJSON:tmp] callback:callback];
    tmp = nil;
}

-(void) removeRecentContact:(NSString *)jid withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"removeRecentContact");

    @autoreleasepool {


    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:jid forKey:KEY_JID];
    
    //    JSONObjectHelper.putObjectToJSONObject(param, , );
    [self.whistleBizBridge asyncCall:REMOVE_RECENT_CONTACT inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
//    [self sendUpdateRecentContactNotify:jid from:[AnanUtils getChatType:jid] to:DELETE];
        param = nil;
    }
}

-(void) removeRecentSystemContact:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"removeRecentContact");
    @autoreleasepool {
        
    //    JSONObjectHelper.putObjectToJSONObject(param, , );
    [self.whistleBizBridge asyncCall:REMOVE_RECENT_SYSTEMCONTACT inputPara:@"{}" callback:listener];
//    [self sendUpdateRecentContactNotify:@"system" from:SessionType_System to:DELETE];
    }
}

-(void) getNoticeDetailInfoAndMarkReaded:(NSString *)jid withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"getNoticeDetailInfoAndMarkReaded");
    @autoreleasepool {
        
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:jid forKey:KEY_JID];
    [param setValue:@"notice" forKey:KEY_TYPE];
    
    //    JSONObjectHelper.putObjectToJSONObject(param, , );
    [self.whistleBizBridge asyncCall:GET_CONV_UNREAD inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
        param = nil;
    }
}


-(void) changeChatGroupName:(NSString *)sessionId withchatName:(NSString *)chatName withchatId:(NSString *)chatId withuid:(NSString *)uid withuName:(NSString *)uName withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"changeChatGroupName");
    @autoreleasepool {
        

        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:sessionId forKey:KEY_GROUP_CHAT_JID];
        [param setValue:chatName forKey:KEY_GROUP_TOPIC];
        [param setValue:chatId forKey:KEY_GROUP_CHAT_ID];
        [param setValue:uid forKey:KEY_UID];
        [param setValue:uName forKey:KEY_USER_NAME];
    
    //    JSONObjectHelper.putObjectToJSONObject(param, , );
        [self.whistleBizBridge asyncCall:CHANGE_CHAT_GROUP_NAME inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
        param = nil;
    }
}



-(void) setSystemMessageReaded:(NSString *)rowId withidList:(NSArray *)idList withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"setSystemMessageReaded");
    @autoreleasepool {
        

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:rowId forKey:KEY_ROW_ID];
    
    //    JSONObjectHelper.putObjectToJSONObject(param, , );
    [self.whistleBizBridge asyncCall:UPDATE_SYSTEM_MESSAGE inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
        param = nil;
    }
}

-(void) deleteSystemMessage:(NSString *)rowId withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"deleteSystemMessage");
    @autoreleasepool {
        

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:rowId forKey:KEY_ROW_ID];
    
    //    JSONObjectHelper.putObjectToJSONObject(param, , );
    [self.whistleBizBridge asyncCall:DEL_SYSTEM_MESSAGE inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
        param = nil;
    }
}

-(void) getChatGroupSettings:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"deleteSystemMessage");
    @autoreleasepool {
        

    
    //    JSONObjectHelper.putObjectToJSONObject(param, , );
    [self.whistleBizBridge asyncCall:GET_CHAT_GROUP_SETTINGS inputPara:@"{}" callback:listener];
    }
}

-(void) getSystemMessage:(NSString *)rowId withbeginidx:(int)beginidx  withcount:(int)count withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"getSystemMessage");
    @autoreleasepool {
        

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    if(rowId != nil) {
        [param setValue:rowId forKey:KEY_ROW_ID];
    }else{
        [param setValue:@"" forKey:KEY_ROW_ID];
    }
    [param setValue:[[NSNumber alloc] initWithInt:beginidx] forKey:KEY_BEGIN_IDX];
    
    [param setValue:[[NSNumber alloc] initWithInt:count ] forKey:KEY_COUNT];
    [self.whistleBizBridge asyncCall:GET_SYSTEM_MESSAGE inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
        param = nil;
    }
}

-(void) deleteOneHistoryMessage:(NSString *)type withrowId:(NSString *)rowId withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"deleteOneHistoryMessage");
    @autoreleasepool {
        
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:rowId forKey:KEY_ROW_ID];
  
    [param setValue:type forKey:KEY_TYPE];
    
    [self.whistleBizBridge asyncCall:DEL_ONE_HISTORY_MSG inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
        param = nil;
    }
}

-(void) deleteAllHistoryMessage:(NSString *)type withjid:(NSString *)jid withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"deleteAllHistoryMessage");
    @autoreleasepool {
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:jid forKey:KEY_JID];
    //
        [param setValue:type forKey:KEY_TYPE];
    //
        [self.whistleBizBridge asyncCall:DEL_ALL_HISTORY_MSG inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
    //    [self sendUpdateRecentContactNotify:jid from:[AnanUtils getChatType:jid] to:EMPTY];
        param = nil;
    }
}

-(void) getChangePasswordUri:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"getChangePasswordUri");
    @autoreleasepool {

    [self.whistleBizBridge asyncCall:GET_CHANGE_PASSWORD_URI inputPara:@"{}" callback:listener];
    }
}

-(void) canUserChangedPassword:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"canUserChangedPassword");
    @autoreleasepool {
        
    [self.whistleBizBridge asyncCall:USER_CAN_CHANGE_PASSWORD inputPara:@"{}" callback:listener];
    }
}

-(void) getRecentAppMsg:(WhistleCommandCallbackType)listener {
    @autoreleasepool {
        

    [self.whistleBizBridge asyncCall:@"get_recent_app_messages" inputPara:@"{}" callback:listener];
    }
}
- (void) getAppMsgList:(NSInteger)index count:(NSInteger)count callback:(WhistleCommandCallbackType)listener
{
    NSDictionary* tmp = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d", index], KEY_BEGIN_IDX, [NSString stringWithFormat:@"%d", count], KEY_COUNT, nil];
    [self.whistleBizBridge asyncCall:COMMAND_GET_APP_MESSAGE_LIST inputPara:[JSONObjectHelper encodeStringFromJSON:tmp] callback:listener];
    tmp = nil;
}

-(void) getAppMsgHistory:(NSString *)sid from:(int)beginIdx withCount:(int)count withListener:(WhistleCommandCallbackType)listener
{
    @autoreleasepool {
        

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:sid forKey:KEY_ID];
    [param setValue:[[NSNumber alloc] initWithInt:beginIdx ] forKey:KEY_BEGIN_IDX];
    [param setValue:[[NSNumber alloc] initWithInt:count ] forKey:KEY_COUNT];
    [self.whistleBizBridge asyncCall:@"get_app_message_history" inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
        param = nil;
    }
}

-(void) markAppMsgRead:(NSString *)sid withListener:(WhistleCommandCallbackType)listener
{
    @autoreleasepool {
        

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:sid forKey:KEY_ID];
    [self.whistleBizBridge asyncCall:@"mark_app_message_read" inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
        param = nil;
    }
}

-(void) deleteAppMessage:(NSString *)sid withListener:(WhistleCommandCallbackType)listener
{
    @autoreleasepool {
        

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:sid forKey:KEY_ID];
    [self.whistleBizBridge asyncCall:@"delete_app_message" inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
        param = nil;
    }
    
}

- (void) deleteAllAppMsg:(WhistleCommandCallbackType)callback
{
    [self.whistleBizBridge asyncCall:COMMAND_DELETE_ALL_APP_MESSAGE inputPara:@"{}" callback:callback];
}

- (void) deleteAllReadAppMsg:(WhistleCommandCallbackType)callback
{
    [self.whistleBizBridge asyncCall:COMMAND_DELETE_ALL_READED_APP_MESSAGE inputPara:@"{}" callback:callback];
}

- (void) getFeedbackURL:(WhistleNotificationListenerType)listener
{
    @autoreleasepool {
        

    [self.whistleBizBridge asyncCall:@"get_feedback_url" inputPara:@"{}" callback:listener];
        
    }
}

- (void) getWhistleVersion:(WhistleNotificationListenerType)listener
{
    @autoreleasepool {
        

    [self.whistleBizBridge asyncCall:@"get_version" inputPara:@"{}" callback:listener];
    }
}

- (void) markSystemMessageRead:(NSString *)rowId withListener:(WhistleCommandCallbackType)listener
{
    @autoreleasepool {
        
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:rowId forKey:KEY_ROW_ID];
    [self.whistleBizBridge asyncCall:KEY_MARK_SYSTEM_MSG_READ inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
        
        param = nil;
    }
 
}

//- (void) answerCrowdInvite:(BOOL)isAccpet WIthSessionID:(NSString *)session_id WithRowID:(NSString *)rowid WithJID:(NSString *)jid withListener:(WhistleCommandCallbackType)listener
//{
//    
//    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
//    [param setValue:session_id forKey:KEY_SESSION_ID];
//    [param setValue:rowid forKey:KEY_ROW_ID];
//    [param setValue:jid forKey:KEY_JID];
//    [param setValue:isAccpet ? @"yes" : @"no" forKey:@"accept"];
//    [self.whistleBizBridge asyncCall:ANSWERCROWDINVITE inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
//}






- (void) callback2biz:(NSString *)callback_id withDomain:(NSString *)domain
{
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    [data setValue:callback_id forKey:KEY_CALLBACKID];
    [data setValue:domain forKey:KEY_DOMAIN];
    [self.whistleBizBridge callback: [JSONObjectHelper encodeStringFromJSON:data]];
}

- (void) searchCloudConfig:(NSString *)text withListener:(WhistleCommandCallbackType)listener
{
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    NSString* txt = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [data setValue:txt forKey:KEY_SEARCH_SCHOOL];
    [self.whistleBizBridge asyncCall:KEY_CLOUD_CONFIG_FIND_SCHOOL inputPara:[JSONObjectHelper encodeStringFromJSON:data] callback:listener];
}

- (void) getToken:(NSString *)service_id forceNew:(BOOL)force callback:(WhistleCommandCallbackType)callback
{
    NSDictionary* tmp = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:force ? 1 : 0], KEY_FORCE_NEW, service_id, KEY_SERVICE_ID, nil];
    [self.whistleBizBridge asyncCall:COMMAND_GET_TOKEN inputPara:[JSONObjectHelper encodeStringFromJSON:tmp] callback:callback];
    tmp = nil;
}

#pragma mark -- 其他函数

- (void) doUploadImage:(NSString *)path width:(NSUInteger)width height:(NSUInteger)height crop_left:(NSUInteger)left crop_right:(NSUInteger)right crop_top:(NSUInteger)top crop_bottom:(NSUInteger)bottom callback:(WhistleCommandCallbackType)callback
{
    NSDictionary* image = @{KEY_WIDTH : [[NSNumber alloc] initWithInt:width], KEY_HEIGHT : [[NSNumber alloc] initWithInt:height]};
    NSDictionary* crop = @{KEY_LEFT : [[NSNumber alloc] initWithInt:left], KEY_RIGHT : [[NSNumber alloc] initWithInt:right], KEY_TOP : [[NSNumber alloc] initWithInt:top], KEY_BOTTOM : [[NSNumber alloc] initWithInt:bottom]};
    NSDictionary* tmp = @{KEY_IMG_PATH : path, KEY_IMG_SIZE : image, KEY_CROP_AREA : crop};
    [self asyncCall:COMMAND_DO_UPLOAD_IMAGE param:tmp callback:callback];
    tmp = nil;
}


#pragma mark -- 群相关

- (void) getCreateCrowdSetting:(WhistleCommandCallbackType)callback
{
    [self.whistleBizBridge asyncCall:COMMAND_GET_CREATE_CROWD_SETTING inputPara:@"{}" callback:callback];
}

-(void) getCrowdList:(WhistleCommandCallbackType)listener {
    @autoreleasepool {       
        [self.whistleBizBridge asyncCall:GETCROWDLIST inputPara:@"{}" callback:listener];
    }
}

- (void) createCrowd:(NSString *)name icon:(NSString *)icon category:(NSInteger)category auth:(NSInteger)authType callback:(void (^)(NSDictionary *))callback
{
    NSDictionary* tmp = [[NSDictionary alloc] initWithObjectsAndKeys:name, KEY_NAME, icon, KEY_ICON, [NSNumber numberWithInt: category], KEY_CATEGORY, [NSNumber numberWithInt:authType], KEY_AUTH_TYPE, nil];
    [self.whistleBizBridge asyncCall:COMMAND_CREATE_CROWD inputPara:[JSONObjectHelper encodeStringFromJSON:tmp] callback:callback];
    tmp = nil;
}

- (void) dismissCrowd:(NSString *)sessionID callback:(WhistleCommandCallbackType)callback
{
    NSDictionary* tmp = @{KEY_SESSION_ID : sessionID};
    [self.whistleBizBridge asyncCall:COMMAND_DISMISS_CROWD inputPara:[JSONObjectHelper encodeStringFromJSON:tmp] callback:callback];
    tmp = nil;
}

- (void) inviteIntoCrowd:(NSString *)sessionID friend:(NSString *)jid callback:(WhistleCommandCallbackType)callback
{
    NSDictionary* tmp = @{KEY_SESSION_ID : sessionID, KEY_JID : jid};
    [self.whistleBizBridge asyncCall:COMMAND_INVITE_INTO_CROWD inputPara:[JSONObjectHelper encodeStringFromJSON:tmp] callback:callback];
    tmp = nil;
}
- (void) answerCrowdInvite:(BOOL)isAccpet WithRowID:(NSString *)rowid WithSessionID:(NSString *)session_id WithCrowdName:(NSString*) crowd_name
                  WithIcon:(NSString*) icon WithCategory:(NSUInteger) category WithJID:(NSString *)jid WithName:(NSString*) name
                WithReason:(NSString*) reason WithNeverAccpte:(BOOL) isNeverAccpt withListener:(WhistleCommandCallbackType)listener
{
    @autoreleasepool {
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:isAccpet ? @"yes" : @"no" forKey:@"accept"];
        [param setValue:rowid forKey:KEY_ROW_ID];
        [param setValue:session_id forKey:KEY_SESSION_ID];
        [param setValue:crowd_name forKey:KEY_CROWD_NAME];
        [param setValue:icon forKey:KEY_ICON];
        [param setValue:[NSString stringWithFormat:@"%d", category] forKey:KEY_CROWD_CATEGORY];
        [param setValue:jid forKey:KEY_JID];
        [param setValue:name forKey:@"name"];
        [param setValue:reason forKey:@"reason"];
        //    [param setValue:isNeverAccpt ? @"true" : @"false" forKey:@"never_accept"];//当前不使用这个
        [self.whistleBizBridge asyncCall:ANSWERCROWDINVITE inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
        param = nil;
    }
}

- (void) applyJoinCrowd:(NSString *)sessionID reason:(NSString *)reason callback:(WhistleCommandCallbackType)callback
{
    NSDictionary* tmp = @{KEY_SESSION_ID : sessionID, KEY_REASON : reason};
    [self.whistleBizBridge asyncCall:COMMAND_APPLY_JOIN_CROWD inputPara:[JSONObjectHelper encodeStringFromJSON:tmp] callback:callback];
    tmp = nil;
}

- (void) answerApplyJonCrowd:(BOOL)isAccpet WithSessionID:(NSString *)session_id actorName:(NSString*) actor_name actorJID:(NSString*) actor_jid actorIcon:(NSString*) actor_icon actorSex:(NSString*) actor_sex
               actorIdentity:(NSString*) actor_identity reason:(NSString*) reason WithListener:(WhistleCommandCallbackType)listener
{
    @autoreleasepool {
        NSDictionary* tmp = @{KEY_SESSION_ID : session_id, KEY_ACTOR_JID : actor_jid, KEY_ACTOR_NAME : actor_name, KEY_ACTOR_ICON : actor_icon, KEY_ACTOR_SEX : actor_sex, KEY_ACTOR_IDENTITY : actor_identity,
                              KEY_REASON : reason, KEY_ACCEPT : isAccpet ? @"yes" : @"no"};
        [self.whistleBizBridge asyncCall: ANSWER_APPLY_JOIN_CROWD inputPara:[JSONObjectHelper encodeStringFromJSON:tmp] callback:listener];
        tmp = nil;
    }
    
}

- (void) crowdApplySuperadmin:(NSString *)sessionID reason:(NSString *)reason callback:(WhistleCommandCallbackType)callback
{
    NSDictionary* tmp = @{KEY_SESSION_ID : sessionID, KEY_REASON : reason};
    [self asyncCall:COMMAND_CROWD_APPLY_SUPERADMIN param:tmp callback:callback];
    tmp = nil;
}

-(void) crowdMemberKickout:(NSString *)session_id withJID:(NSString *)kickJid wihtReson:(NSString *)reason withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"crowdKick");
    @autoreleasepool {
        NSMutableDictionary *jsonObj = [[NSMutableDictionary alloc] init];
        [jsonObj setValue:session_id forKey:KEY_SESSION_ID];
        [jsonObj setValue:kickJid forKey:KEY_JID];
        [jsonObj setValue:reason forKey:KEY_REASON];
        [self.whistleBizBridge asyncCall:COMMAND_CROWD_MEMBER_KICKOUT inputPara:[JSONObjectHelper encodeStringFromJSON:jsonObj] callback:listener];
        jsonObj = nil;
    }
}

- (void) crowdRoleDemise:(NSString *)sessionID friend:(NSString *)jid callback:(WhistleCommandCallbackType)callback
{
    NSDictionary* tmp = @{KEY_SESSION_ID : sessionID, KEY_JID : jid};
    [self asyncCall:COMMAND_CROWD_ROLE_DEMISE param:tmp callback:callback];
    tmp = nil;
}

- (void) crowdRoleChange:(NSString *)sessionID friend:(NSString *)jid role:(NSString *)role callback:(WhistleCommandCallbackType)callback
{
    NSDictionary* tmp = @{KEY_SESSION_ID : sessionID, KEY_JID : jid};
    [self asyncCall:COMMAND_CROWD_ROLE_CHANGE param:tmp callback:callback];
    tmp = nil;
}

-(void) getCrowdMemberList:(NSString *)sessionId withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"getCrowdMemberList");
    
    @autoreleasepool {
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:sessionId forKey:KEY_SESSION_ID];
        [param setValue:@"all" forKey:KEY_ROLE];
        
        [self.whistleBizBridge asyncCall:GETCROWDGROUPMEMBERLIST inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
        param = nil;
        
    }
}

- (void) setCrowdMemberInfo:(NSString *)sessionID friend:(NSString *)jid name:(NSString *)name remark:(NSString *)remark callback:(WhistleCommandCallbackType)callback
{
    NSMutableDictionary* tmp = [[NSMutableDictionary alloc] init];
    if (sessionID) {
        [tmp setObject:sessionID forKey:KEY_SESSION_ID];
    }
    if (jid) {
        [tmp setObject:jid forKey:KEY_JID];
    }
    if (name) {
        [tmp setObject:name forKey:KEY_NAME];
    }
    if (remark) {
        [tmp setObject:remark forKey:KEY_REMARK];
    }
    [self asyncCall:COMMAND_SET_CROWD_MEMBER_INFO param:tmp callback:callback];
    tmp = nil;
}

-(void) getCrowdInfo:(NSString *)session_id withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"getCrowdDetailInfo");
    @autoreleasepool {
        NSMutableDictionary *jsonObj = [[NSMutableDictionary alloc] init];
        [jsonObj setValue:session_id forKey:KEY_SESSION_ID];
        [self.whistleBizBridge asyncCall:COMMAND_GET_CROWD_INFO inputPara:[JSONObjectHelper encodeStringFromJSON:jsonObj] callback:listener];
        jsonObj = nil;
    }
}

- (void) setCrowdInfo:(NSString *)sessionID announce:(NSString *)announce description:(NSString *)description icon:(NSString *)icon authType:(int)anth_type name:(NSString *)name category:(int)category callback:(WhistleCommandCallbackType)callback
{
    NSDictionary* tmp = @{KEY_SESSION_ID : sessionID, KEY_ANNOUNCE : announce, KEY_DESCRIPTION : description, KEY_ICON : icon, KEY_AUTH_TYPE : [[NSNumber alloc] initWithInt: anth_type], KEY_NAME : name, KEY_CATEGORY : [[NSNumber alloc] initWithInt: category]};
    [self asyncCall:COMMAND_SET_CROWD_INFO param:tmp callback:callback];
    tmp = nil;
}

-(void) setCrowdInfo:(NSString *)session_id wihtParams:(NSMutableDictionary *)param withListener:(WhistleCommandCallbackType)listener {
    NSLog(@"%@",@"setCrowdInfo");
    @autoreleasepool {
        NSMutableDictionary* tmp = [[NSMutableDictionary alloc] init];
        [tmp addEntriesFromDictionary:param];
        [tmp setValue:session_id forKey:KEY_SESSION_ID];
        [self.whistleBizBridge asyncCall:COMMAND_SET_CROWD_INFO inputPara:[JSONObjectHelper encodeStringFromJSON:tmp] callback:listener];
        tmp = nil;
    }
}

-(void) leaveCrowd:(NSString *)session_id withListener:(WhistleCommandCallbackType)listener {
    @autoreleasepool {
        NSMutableDictionary *jsonObj = [[NSMutableDictionary alloc] init];
        [jsonObj setValue:session_id forKey:KEY_SESSION_ID];
        [self.whistleBizBridge asyncCall:COMMAND_LEAVE_CROWD inputPara:[JSONObjectHelper encodeStringFromJSON:jsonObj] callback:listener];
        jsonObj = nil;
    }
}

- (void) openCrowdWindow:(NSString *)sessionID callback:(WhistleCommandCallbackType)callback
{
    NSDictionary* tmp = @{KEY_SESSION_ID : sessionID};
    [self asyncCall:COMMAND_OPEN_CROWD_WINDOW param:tmp callback:callback];
    tmp = nil;
}

- (void) closeCrowdWindow:(NSString *)sessionID callback:(WhistleCommandCallbackType)callback
{
    NSDictionary* tmp = @{KEY_SESSION_ID : sessionID};
    [self asyncCall:COMMAND_CLOSE_CROWD_WINDOW param:tmp callback:callback];
    tmp = nil;
}

- (void) setCrowdAlert:(NSString *)sessionID alert:(int)alert callback:(WhistleCommandCallbackType)callback
{
    NSDictionary* tmp = @{KEY_SESSION_ID : sessionID, KEY_ALERT : [[NSNumber alloc] initWithInt:alert]};
    [self asyncCall:COMMAND_SET_CROWD_ALERT param:tmp callback:callback];
    tmp = nil;
}

-(void) findCrowd:(NSString *)type withSearchStr:(NSString *)searchStr wihtIndex:(int)index withMax:(int)max withListener:(WhistleCommandCallbackType)listener {
    @autoreleasepool {
        id searchObject;
        searchObject = [NSNull null];
        if (searchStr != nil){
            searchObject = searchStr;
        }
        NSString *searchMode = @"fuzzy";
        if ([type isEqualToString:@"aid"]) {
            searchMode = @"exact";
        }
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:searchObject forKey:type];
        [param setValue:searchMode forKey:@"mode"];
        [param setValue:[NSString stringWithFormat:@"%d",index] forKey:KEY_INDEX];
        [param setValue:[NSString stringWithFormat:@"%d",max] forKey:KEY_MAX];
        [self.whistleBizBridge asyncCall:COMMAND_FIND_CROWD inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:listener];
        param = nil;
    }
}

- (NSString*) getCrowdPolicy
{
    return [[self getAppConfig] valueForKey:KEY_CROWD_POLICY];
}

#pragma mark -- 讨论组相关

-(void) createChatGroup:(NSString *)groupName withidList:(NSArray *)idList callback:(WhistleCommandCallbackType) callback
{
    @autoreleasepool {
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:groupName forKey:KEY_GROUP_NAME];
        [param setValue:idList forKey:KEY_ID_LIST];
        [self.whistleBizBridge asyncCall:COMMAND_CREATE_CHAT_GROUP inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback: callback];
        param = nil;
    }
}

-(void) getChatGroupMemberList:(NSString *) sessionId callback:(WhistleCommandCallbackType)listener {
    @autoreleasepool {
        NSDictionary* tmp = @{KEY_SESSION_ID : sessionId};
        [self.whistleBizBridge asyncCall:COMMAND_GET_CHAT_GROUP_MEMBER_LIST inputPara:[JSONObjectHelper encodeStringFromJSON:tmp] callback:listener];
        tmp = nil;
    }
}

- (void) inviteBuddyIntoChatGroup:(NSString *)session_id buddies:(NSArray *)buddies callback:(WhistleCommandCallbackType)callback
{
    NSDictionary* tmp = @{KEY_SESSION_ID : session_id, KEY_BUDDIES : buddies};
    [self asyncCall:COMMAND_INVITE_BUDDY_INTO_CHAT_GROUP param:tmp callback:callback];
    tmp = nil;
}

-(void) getChatGroupList:(WhistleCommandCallbackType) callback
{
    [self asyncCall:COMMAND_GET_CHAT_GROUP_LIST param:nil callback:callback];
}

-(void) leaveChatGroup:(NSString *)sessionId callback:(WhistleCommandCallbackType)callback
{
    NSDictionary* tmp = @{KEY_SESSION_ID : sessionId};
    [self asyncCall:COMMAND_LEAVE_CHAT_GROUP param:tmp callback:callback];
    tmp = nil;
}

-(void) openChatGroupWindow:(NSString *)sessionId callback:(WhistleCommandCallbackType)callback
{
    NSDictionary* tmp = @{KEY_SESSION_ID : sessionId};
    [self asyncCall:COMMAND_OPEN_CHAT_GROUP_WINDOW param:tmp callback:callback];
    tmp = nil;
}

-(void) closeChatGroupWindow:(NSString *)sessionId callback:(WhistleCommandCallbackType)callback
{
    NSDictionary* tmp = @{KEY_SESSION_ID : sessionId};
    [self asyncCall:COMMAND_CLOSE_CHAT_GROUP_WINDOW param:tmp callback:callback];
    tmp = nil;
}

#pragma mark -- 配置信息相关

- (NSDictionary*) getAppConfig
{
    return [JSONObjectHelper decodeJSON:[self.whistleBizBridge getAppConfig]];
}

- (NSString*) getGrowthInfoUrl
{
    return [[self getAppConfig] valueForKey:KEY_GROWTH_INFO_RUL];
}
- (NSString*) getCrowdVoteURL
{
    return [[self getAppConfig] valueForKey:KEY_CROWD_VOTE];
}

- (NSString*) getHttpRoot
{
    return [[self getAppConfig] valueForKey:KEY_HTTP_ROOT];
}

- (NSString*) getExportUrl
{
    return [[self getAppConfig] valueForKey: KEY_EPORTAL_EXPLORER_URL];
}

- (NSString*) getDomain
{
    return [[self getAppConfig] valueForKey:@"domain"];
}

- (void) asyncCall:(NSString*) commandCode param:(NSDictionary*) param callback:(WhistleCommandCallbackType) callback
{
    if (param) {
        [self.whistleBizBridge asyncCall:commandCode inputPara:[JSONObjectHelper encodeStringFromJSON:param] callback:callback];
    }else{
        [self.whistleBizBridge asyncCall:commandCode inputPara:@"{}" callback:callback];
    }

}

@end
