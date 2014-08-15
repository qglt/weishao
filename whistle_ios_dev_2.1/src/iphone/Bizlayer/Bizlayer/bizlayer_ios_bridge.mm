
#import "bizlayer_ios_bridge.h"

#import <base/cmd_factory/cmd_factory.h>
#import <base/json/tinyjson.hpp>
#import <base/log/elog/elog.h>
#import <base/module_path/file_manager.h>
#import <base/http_trans/http_request.h>
#import <base/universal_res/uni_res.h>
#import <base/txtutil/txtutil.h>

#import <biz/biz_anan/biz_src/anan_config.h>
#import <biz/biz_anan/biz_src/biz_lower.h>
#import <base/lua/lua_ext/lua_mgr.h>

#import "ios_biz_higher.h"

static bizlayer_ios_bridge* singlebizlayer_ios_bridge = nil;
boost::shared_ptr<biz::ios_biz_higher> biz_higher;


@implementation bizlayer_ios_bridge 


+ (bizlayer_ios_bridge*)getSingleInstance
{
    if(!singlebizlayer_ios_bridge){
        singlebizlayer_ios_bridge = [[bizlayer_ios_bridge alloc] init];
    }
	return singlebizlayer_ios_bridge;
}



- (void)initBizLayerWithNotifier:(id<bizlayer_ios_notifier>)handler
{
    
    self.notifyHandler = handler;
   	//1.初始化log和配置信息
    epius::http_requests::instance().init();
    
	biz::file_manager::instance().init();
    printf("startBizLayer file_manager done!\n");
	uni_res::instance().init();
    printf("startBizLayer uni_res done!\n");
    anan_config::instance().init();
    printf("startBizLayer anan_config done!\n");
    epius::elog_factory::instance().set_root_path(biz::file_manager::instance().get_app_root_path());
	epius::elog_factory::instance().init(anan_config::instance().get_log_configuration());
    printf("startBizLayer elog done!\n");

    epius::lua_mgr::instance().init(biz::file_manager::instance().get_app_root_path());
    epius::lua_mgr::instance().load_engine("lua/engine.lua");
    epius::lua_mgr::instance().load_engine("lua/srv_index.lua");
    
    //2.创建biz_higher对象
    biz::biz_higher::instance().init();
    
}


- (void)startBizLayer: (NSString*)dataPath :(id<bizlayer_ios_notifier>)handler
{
    std::string device_dataroot([dataPath UTF8String], [dataPath lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
    
    biz::whistle_device_approot += device_dataroot + "/";
    
    printf("startBizLayer with dataPath %s \n",biz::whistle_device_approot.c_str());
    
    
    [self initBizLayerWithNotifier:handler];
    
    
}

- (void) callback:(NSString*) para
{
    std::string stdPara ([para UTF8String], [para lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
    json::jobject jsonPara(stdPara);

    cmd_factory::instance().callback(jsonPara);
}

- (void)callBiz:(NSString *)para
{
    
    std::string stdPara ([para UTF8String], [para lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
    json::jobject jsonPara(stdPara);
    //json::jobject jsonPara = para->jsonObject;
    
    ELOG("log_jstune")->debug("callBiz start : " + jsonPara.to_string());
    
    
	if(!jsonPara || !jsonPara["method"]) return;
    
    biz::biz_higher::instance().executeCommand(jsonPara);
    
}

- (NSString *) getAppConfig
{
	json::jobject resultJson;

	json::jobject jsoncfg = anan_config::instance().get_app_name_cfg();
	resultJson["app_name_cfg"] = jsoncfg;

    std::string config_str = anan_config::instance().get_domain();
	resultJson["domain"] = config_str;

    config_str = anan_config::instance().get_crowd_vote();
	resultJson["crowd_vote"] = config_str;

	config_str = anan_config::instance().get_whistle_change_password_uri();
	resultJson["change_password_uri"] = config_str;

	config_str = anan_config::instance().get_crowd_policy();
	resultJson["crowd_policy"] = config_str;

	config_str = anan_config::instance().get_feedback_uri();
	resultJson["feedback_url"] = config_str;
    
    config_str = anan_config::instance().get_http_root();
    resultJson["http_root"] = config_str;
    
    config_str = anan_config::instance().get_eportal_explorer_url();
    resultJson["eportal_explorer_url"] = config_str;
    
    config_str = anan_config::instance().get_domain();
    resultJson["domain"] = config_str;
    
    config_str = anan_config::instance().get_server();
    resultJson["server"] = config_str;
    
    config_str = anan_config::instance().get_growth_info_url();
    resultJson["growth_info_url"] = config_str;
	
	NSString *cfg = [[NSString alloc] initWithUTF8String:resultJson.to_string().c_str()];
	return cfg;
}


- (void)dealloc
{
    biz_higher.reset();
    //delete biz_higher;
    //[super dealloc]; // omit if using ARC
}


@end
