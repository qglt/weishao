//
//  ios_biz_higher.cpp
//  Whistle
//
//  Created by chao.wang on 13-1-5.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//

#include "ios_biz_higher.h"
#include "boost/shared_ptr.hpp"
#include <map>

#include <base/log/elog/elog.h>
#include <biz_anan/biz_src/biz_lower.h>
#include <base/cmd_factory/cmd_factory.h>
#include <base/utility/bind2f/bind2f.hpp>

#include "biz_anan/biz_src/anan_config.h"
#include "biz_anan/biz_src/login.h"
#include "biz_anan/biz_src/agent.h"
#include "biz_anan/biz_src/roster_type.h"
#include "biz_anan/biz_src/anan_biz.h"
#include "biz_anan/biz_src/agent_type.h"
#include "biz_anan/biz_src/anan_private.h"
#include "biz_anan/biz_src/conversation.h"
#include "biz_anan/biz_src/biz_groups.h"
#include "biz_anan/biz_src/user.h"
#include "biz_anan/biz_src/an_roster_manager.h"
#include "biz_anan/biz_src/event_collection.h"
#include "biz_anan/biz_src/organization.h"
#include "biz_anan/biz_src/biz_adapter.h"


//#import "Whistle.h"
#include <boost/assign/list_of.hpp>
#include <boost/algorithm/string/predicate.hpp>
#import "bizlayer_ios_bridge.h"
#import "UIKit/UIDevice.h"

extern boost::shared_ptr<biz::ios_biz_higher> biz_higher;

namespace biz {
    
    using namespace std;
	using namespace boost::assign;

	static map<KPresenceType, string> status_map_value2string = map_list_of(kptOnline, "Online")(kptAway,"Away")(kptBusy, "Busy")(kptOffline,"Offline")(kptAndroid,"Android")(kptIOS,"IOS")(kptInvisible,"Invisible"); 
	static map<string, KPresenceType> status_map_string2value = map_list_of("Online",kptOnline)("Away",kptAway)("Busy",kptBusy)("Offline",kptOffline)("Invisible",kptInvisible);

    std::string whistle_device_approot("");
    
	class biz_higher_impl : public biz_adapter
	{
		public :
			biz_higher_impl();
			void executeCommand(json::jobject jobj);
			virtual void chat_group_member_changed( json::jobject jobj );
			virtual void recv_recent_list( json::jobject jobj );
			virtual void recv_buddy_add_request( std::string jid, std::string rowid,std::string msg );
			virtual void recv_add_buddy_ack( std::string jid,  std::string rowid,bool bAck, json::jobject msg );
			virtual void recv_msg(json::jobject jobj);
			virtual void send_message_failed(json::jobject jobj);
			virtual void recv_update_org_head( json::jobject jobj );
			virtual void update_buddy_status( std::string jid,KPresenceType presence,json::jobject msg, std::string my_jid);
			virtual void recv_item_updated(std::string json_str,std::string my_jid);
			virtual void recv_notice_message(json::jobject jobj);
			virtual void recv_app_message(json::jobject jobj);
			virtual void update_app_icon(json::jobject jobj);
			virtual void chat_group_list_changed(json::jobject jobj);
			virtual void update_member_head(json::jobject jobj);
			virtual void close_app_cb(bool err, universal_resource res);
			virtual void handle_user_not_exist();
            virtual std::string crop_image_stretch( std::string picture_path, int dst_width, int dst_height, int source_left,int source_top, int source_right, int source_bottom, int stretch_width, int stretch_height);
			virtual std::string crop_image( std::string picture_path, int dst_width, int dst_height, int source_left,int source_top, int source_right, int source_bottom);
			virtual void update_recent_contact(json::jobject jobj);
			virtual json::jobject get_hardware_info();
			virtual void file_transfer_status(json::jobject jobj);
			virtual void openURL(std::string url);
			virtual void crowd_list_changed(json::jobject jobj);
			virtual void crowd_member_changed(json::jobject jobj);
			virtual void crowd_info_changed(json::jobject jobj);
			virtual void crowd_file_changed(json::jobject jobj);
			virtual void crowd_alert_changed(json::jobject jobj);
			virtual void recv_quit_crowd_ack(json::jobject jobj);
			virtual void recv_apply_join_crowd_response(json::jobject jobj);
			virtual void crowd_member_role_changed(json::jobject jobj);
			virtual void crowd_role_changed(json::jobject jobj);
			virtual void crowd_superadmin_applyed(json::jobject jobj);
			virtual void crowd_superadmin_applyed_response(json::jobject jobj);
			virtual void crowd_create_success(json::jobject jobj);
			virtual void apply_join_groups_accepted_msg(json::jobject jobj);
			virtual void crowd_system_message(json::jobject jobj);
			virtual void connected(std::string my_jid);
			virtual void disconnected(universal_resource resource, std::string my_jid);
			virtual void connecting();
            virtual void update_dialog_showname(json::jobject jobj);
			virtual void recv_organization_status_update(json::jobject jobj);
			virtual void app_icon_update(json::jobject jobj);
			virtual void recv_cloud_config(json::jobject jobj);
            virtual void recv_growth_info_message(json::jobject jobj);
			virtual void set_language(json::jobject jobj);
            virtual void update_customize_login(json::jobject jobj);

			void onNativeCommandResult(json::jobject result);
			void log(std::string data);

			epius::time_thread _thread;
		private :
			void notifyResult(std::string result);
	};

    
    biz_higher_impl::biz_higher_impl()
    {
        
    }
	/*
	 * 所有的biz层命令结果回调java都使用该方法
	 */
	void biz_higher_impl::onNativeCommandResult(json::jobject result)
	{
		if(!_thread.is_in_work_thread())
		{
		    _thread.post(boost::bind(&biz_higher_impl::onNativeCommandResult,this,result));
		    return;
		}
        
		ELOG("log_jstune")->debug("jni onNativeCommandResult : " + result.to_string());

		printf("onNativeCommandResult : %s",result.to_string().c_str());
		
		NSString *data = [[NSString alloc] initWithUTF8String:result.to_string().c_str()];

        [[bizlayer_ios_bridge getSingleInstance].notifyHandler onNativeCommandResult:data];
		//[[WHISTLE_APPPROXY whistleBizProxy].whistleBizBridge onCommandResult:data];
	}
    
    
	void biz_higher_impl::chat_group_member_changed( json::jobject jobj )
	{
		//ELOG("log_android")->debug("chat_group_member_changed with tid : " + boost::lexical_cast<std::string>(gettid()));
		
         
         json::jobject jsonPara;
         jsonPara["type"] = "chat_group_member_changed";
         jsonPara["data"] = jobj;
         
		notifyResult(jsonPara.to_string());
         
        
	}
    
	void biz_higher_impl::recv_recent_list( json::jobject jobj )
	{
		//ELOG("log_android")->debug("recv_recent_list with tid : " + boost::lexical_cast<std::string>(gettid()));
        
		json::jobject jsonPara;
		jsonPara["type"] = "recv_recent_list";
		jsonPara["data"] = jobj;

		notifyResult(jsonPara.to_string());
        
        
	}
    
	void biz_higher_impl::recv_buddy_add_request( std::string jid, std::string rowid,std::string msg )
	{
        
		//ELOG("log_android")->debug("recv_buddy_add_request with tid : " + boost::lexical_cast<std::string>(gettid()));
		json::jobject jsonPara;
		jsonPara["type"] = "recv_buddy_add_request";
		json::jobject jsonData;
		jsonData["jid"] = jid;
        jsonData["rowid"] = rowid;
		jsonData["msg"] = msg;
		jsonPara["data"] = jsonData;
        
		notifyResult(jsonPara.to_string());
        
	}
    
	void biz_higher_impl::recv_add_buddy_ack( std::string jid, std::string rowid,bool bAck,  json::jobject msg)
	{
		//ELOG("log_android")->debug("recv_add_buddy_ack with tid : " + boost::lexical_cast<std::string>(gettid()));
        
		json::jobject jsonPara;
		jsonPara["type"] = "recv_add_buddy_ack";
		json::jobject jsonData;
		jsonData["jid"] = jid;
        jsonData["rowid"] = rowid;
		jsonData["ack"] = (int)bAck;
		jsonData["msg"] = msg;
		jsonPara["data"] = jsonData;
        
		notifyResult(jsonPara.to_string());

	}

	void biz_higher_impl::recv_msg(json::jobject jobj) 
	{
		//ELOG("log_android")->debug("recv_msg with tid : " + boost::lexical_cast<std::string>(gettid()));

		json::jobject jsonPara;
		jsonPara["type"] = "recv_msg";
		jsonPara["data"] = jobj;

		notifyResult(jsonPara.to_string());

	}
	void biz_higher_impl::send_message_failed(json::jobject jobj) 
	{
		//ELOG("log_android")->debug("recv_msg with tid : " + boost::lexical_cast<std::string>(gettid()));

		json::jobject jsonPara;
		jsonPara["type"] = "send_message_failed";
		jsonPara["data"] = jobj;

		notifyResult(jsonPara.to_string());
	}



	void biz_higher_impl::recv_update_org_head( json::jobject jobj )
	{
		//ELOG("log_android")->debug("recv_update_org_head with tid : " + boost::lexical_cast<std::string>(gettid()));
		//N/A
	}

	void biz_higher_impl::update_buddy_status( std::string jid,KPresenceType presence,json::jobject msg, std::string my_jid)
	{
		//TODO fix me ?
		ELOG("log_jstune")->debug("update_buddy_status with presence " + boost::lexical_cast<std::string>(presence));

		if(!msg.is_nil("set_user_sex")) return;
		

		json::jobject jobj;
		jobj["type"] = "recv_item_updated";
        jobj["my_jid"] = my_jid;
		if(!msg)
        {
            jobj["data"]["operation"] = "Update";
            jobj["data"]["changes"]["jid"] = jid;
            jobj["data"]["changes"]["presence"] = status_map_value2string[presence];
        }
		else
        {
            jobj["data"]= msg;
            jobj["data"]["changes"]["jid"] = jid;
            jobj["data"]["changes"]["presence"] = status_map_value2string[presence];
        }
        
		notifyResult(jobj.to_string());		
        
	}
    
	void biz_higher_impl::recv_item_updated(std::string json_str,std::string my_jid)
	{
		//ELOG("log_android")->debug("recv_item_updated with tid : " + boost::lexical_cast<std::string>(gettid()) + " data : " + json_str);
		json::jobject jsonPara;
		jsonPara["type"] = "recv_item_updated";
		jsonPara["data"] = json_str;
		jsonPara["my_jid"] = my_jid;
        
		notifyResult(jsonPara.to_string());

    }
	
	void biz_higher_impl::recv_notice_message(json::jobject jobj)
	{
		//ELOG("log_android")->debug("recv_notice_message with tid : " + boost::lexical_cast<std::string>(gettid()));
        
		json::jobject jsonPara;
		jsonPara["type"] = "recv_notice_message";
		jsonPara["data"] = jobj;
        
		notifyResult(jsonPara.to_string());
        
	}
	void biz_higher_impl::recv_app_message(json::jobject jobj)
	{
		//ELOG("log_android")->debug("recv_notice_message with tid : " + boost::lexical_cast<std::string>(gettid()));
        
		json::jobject jsonPara;
		jsonPara["type"] = "recv_app_message";
		jsonPara["data"] = jobj;
        
		notifyResult(jsonPara.to_string());
        
	}
	void biz_higher_impl::update_app_icon(json::jobject jobj)
	{
		json::jobject jsonPara;
		jsonPara["type"] = "update_app_icon";
		jsonPara["data"] = jobj;
        
		notifyResult(jsonPara.to_string());

	}
    
	void biz_higher_impl::chat_group_list_changed(json::jobject jobj)
	{
		//ELOG("log_android")->debug("chat_group_list_changed with tid : " + boost::lexical_cast<std::string>(gettid()));
        
         json::jobject jsonPara;
         jsonPara["type"] = "chat_group_list_changed";
         jsonPara["data"] = jobj;
         
         notifyResult(jsonPara.to_string());
         
	}

	void biz_higher_impl::update_member_head(json::jobject jobj)
	{
		//ELOG("log_android")->debug("recv_update_discussion_head with tid : " + boost::lexical_cast<std::string>(gettid()));
		
		json::jobject jsonPara;
		jsonPara["type"] = "update_member_head";
		jsonPara["data"] = jobj;

		notifyResult(jsonPara.to_string());
		
	}

	


	void biz_higher_impl::close_app_cb(bool err, universal_resource res)
	{
		//ELOG("log_android")->debug("close_app_cb with tid : " + boost::lexical_cast<std::string>(gettid()));
        
		json::jobject jsonPara;
		jsonPara["type"] = "close_app_cb";
		json::jobject jsonData;
		jsonData["err"] = (int)err;
		jsonData[res.res_key.c_str()] = res.res_value_utf8;
		jsonPara["data"] = jsonData;
        
        
		notifyResult(jsonPara.to_string());
        
        
	}
    void biz_higher_impl::handle_user_not_exist()
    {
		//ELOG("log_android")->debug("close_app_cb with tid : " + boost::lexical_cast<std::string>(gettid()));

		json::jobject jsonPara;
		jsonPara["type"] = "handle_user_not_exist";


		notifyResult(jsonPara.to_string());

    }
	
    std::string biz_higher_impl::crop_image_stretch( std::string picture_path, int dst_width, int dst_height, int source_left,int source_top, int source_right, int source_bottom, int stretch_width, int stretch_height)
    {
        return picture_path;
    }

	std::string biz_higher_impl::crop_image( std::string picture_path, int dst_width, int dst_height, int source_left,int source_top, int source_right, int source_bottom)
	{		
        
		return picture_path;
	}

	void biz_higher_impl::update_recent_contact(json::jobject jobj)
	{

		json::jobject jsonPara;
		jsonPara["type"] = "update_recent_contact";
		jsonPara["data"] = jobj;

		notifyResult(jsonPara.to_string());

	}

    json::jobject biz_higher_impl::get_hardware_info()
	{
    
        json::jobject result;
        
        [[UIDevice currentDevice] name];
        
        result["client_type"] = "ios";
        result["whistle_version"] = "1.0005.1919.9999";
//        result["system"] = "ios";
        result["system"] = [[UIDevice currentDevice] systemName];
//        result["system_version"] = "6.1.1";
        result["system_version"] = [[UIDevice currentDevice] systemVersion];
        result["carrier"] = "0111";
//        result["model"] = "iphone5";
        result["model"] = [[UIDevice currentDevice] model];
        result["ram"] = "1G";
        result["rom"] = "1G";
        result["sd"] = "32G";
        return result;
        
    }
    
    void biz_higher_impl::file_transfer_status(json::jobject jobj)
	{
		json::jobject jsonPara;
		jsonPara["type"] = "file_transfer_status";
		jsonPara["data"] = jobj;

		notifyResult(jsonPara.to_string());

	}
    
    void biz_higher_impl::openURL(std::string url)
    {
        
    }
        
	void biz_higher_impl::crowd_list_changed(json::jobject jobj)
	{
		json::jobject jsonPara;
		jsonPara["type"] = "crowd_list_changed";
		jsonPara["data"] = jobj;

		notifyResult(jsonPara.to_string());

	}
	void biz_higher_impl::crowd_member_changed(json::jobject jobj)
	{
		json::jobject jsonPara;
		jsonPara["type"] = "crowd_member_changed";
		jsonPara["data"] = jobj;

		notifyResult(jsonPara.to_string());

	}
	void biz_higher_impl::crowd_info_changed(json::jobject jobj)
	{
		json::jobject jsonPara;
		jsonPara["type"] = "crowd_info_changed";
		jsonPara["data"] = jobj;

		notifyResult(jsonPara.to_string());

	}
	void biz_higher_impl::crowd_file_changed(json::jobject jobj)
	{
		json::jobject jsonPara;
		jsonPara["type"] = "crowd_file_changed";
		jsonPara["data"] = jobj;

		notifyResult(jsonPara.to_string());

	}
	void biz_higher_impl::crowd_alert_changed(json::jobject jobj)
	{
		json::jobject jsonPara;
		jsonPara["type"] = "crowd_alert_changed";
		jsonPara["data"] = jobj;

		notifyResult(jsonPara.to_string());

	}

	void biz_higher_impl::recv_quit_crowd_ack(json::jobject jobj)
	{
		json::jobject jsonPara;
		jsonPara["type"] = "recv_quit_crowd_ack";
		jsonPara["data"] = jobj;

		notifyResult(jsonPara.to_string());

	}

	void biz_higher_impl::recv_apply_join_crowd_response(json::jobject jobj)
	{
		json::jobject jsonPara;
		jsonPara["type"] = "recv_apply_join_crowd_response";
		jsonPara["data"] = jobj;
        
		notifyResult(jsonPara.to_string());
        
	}
	void biz_higher_impl::crowd_member_role_changed(json::jobject jobj)
	{
		json::jobject jsonPara;
		jsonPara["type"] = "crowd_member_role_changed";
		jsonPara["data"] = jobj;
        
		notifyResult(jsonPara.to_string());
        
	}
	void biz_higher_impl::crowd_role_changed(json::jobject jobj)
	{
		json::jobject jsonPara;
		jsonPara["type"] = "crowd_role_changed";
		jsonPara["data"] = jobj;
        
		notifyResult(jsonPara.to_string());
        
	}
	void biz_higher_impl::crowd_superadmin_applyed(json::jobject jobj)
	{
		json::jobject jsonPara;
		jsonPara["type"] = "crowd_superadmin_applyed";
		jsonPara["data"] = jobj;
        
		notifyResult(jsonPara.to_string());
        
	}
	void biz_higher_impl::crowd_superadmin_applyed_response(json::jobject jobj)
	{
		json::jobject jsonPara;
		jsonPara["type"] = "crowd_superadmin_applyed_response";
		jsonPara["data"] = jobj;
        
		notifyResult(jsonPara.to_string());
        
	}
	void biz_higher_impl::crowd_create_success(json::jobject jobj)
	{
		json::jobject jsonPara;
		jsonPara["type"] = "crowd_create_success";
		jsonPara["data"] = jobj;
        
		notifyResult(jsonPara.to_string());
        
	}
	void biz_higher_impl::apply_join_groups_accepted_msg(json::jobject jobj)
	{
		json::jobject jsonPara;
		jsonPara["type"] = "apply_join_groups_accepted_msg";
		jsonPara["data"] = jobj;
        
		notifyResult(jsonPara.to_string());
        
	}
	
	void biz_higher_impl::crowd_system_message(json::jobject jobj)
	{
		json::jobject jsonPara;
		jsonPara["type"] = "crowd_system_message";
		jsonPara["data"] = jobj;
        
		notifyResult(jsonPara.to_string());
        
	}
	void biz_higher_impl::update_customize_login(json::jobject jobj)
	{
		json::jobject jsonPara;
		jsonPara["type"] = "update_customize_login";
		jsonPara["data"] = jobj;
        
		notifyResult(jsonPara.to_string());
        
	}
	void biz_higher_impl::connected(std::string my_jid)
	{
		json::jobject jsonPara;
		jsonPara["type"] = "connected";
		jsonPara["my_jid"] = my_jid;

		notifyResult(jsonPara.to_string());
	}
	void biz_higher_impl::disconnected(universal_resource resource,std::string my_jid)
	{
		json::jobject jsonPara;
		jsonPara["type"] = "disconnected";
		json::jobject jsonData;
		jsonData["status"] = "offline";
		jsonData["need_reconnect"] = true;
		jsonData[resource.res_key.c_str()] = resource.res_value_utf8;

		if(!resource.res_value_utf8.empty())
		{
				if(resource.res_key == "biz.disconnect_by_logon_different_pc")
				{
					jsonData["need_reconnect"] = false;
				}
				if(resource.res_key == "biz.disconnect_by_user_disconnect")
				{
					jsonData["need_reconnect"] = false;
					resource.res_value_utf8 = "";
				}
				jsonData["reason"] = resource.res_value_utf8;
		}

		jsonPara["data"] = jsonData;
		jsonPara["my_jid"] = my_jid;

		notifyResult(jsonPara.to_string());
	}
	void biz_higher_impl::connecting()
	{
		json::jobject jsonPara;
		jsonPara["type"] = "connecting";

		notifyResult(jsonPara.to_string());
	}
	

	void biz_higher_impl::update_dialog_showname(json::jobject jobj)
	{

	}

	void biz_higher_impl::log(std::string data)
	{
	}
	void biz_higher_impl::executeCommand(json::jobject jobj)
	{
		if(!_thread.is_in_work_thread())
		{
		    _thread.post(boost::bind(&biz_higher_impl::executeCommand,this,jobj));
		    return;
		}
		//4.如果callback_id存在，那么该命令需要获取返回值，在命令结果返回时，将通过callback_id返回给应用层的回调函数
		if(jobj["callback_id"] && !(jobj["callback_id"].get<std::string>().empty()))
		{
            //LOGI("register callback handler");
		//注册回调通道
			cmd_factory::instance().register_callback(jobj["callback_id"].get<std::string>(), boost::bind(&biz::biz_higher_impl::onNativeCommandResult, this,  _1));
            
		}
        
		//5.执行命令
		cmd_factory::instance().exec_cmd(jobj);
        
        
	}

    
	void biz_higher_impl::notifyResult(std::string result)
	{
 		if(!_thread.is_in_work_thread())
		{
		    _thread.post(boost::bind(&biz_higher_impl::notifyResult,this,result));
		    return;
		}
       NSString *ntf = [[NSString alloc] initWithUTF8String:result.c_str()];
        [[bizlayer_ios_bridge getSingleInstance].notifyHandler onBizNotify:ntf];
	}
    
	void biz_higher_impl::recv_organization_status_update(json::jobject jobj){}
	void biz_higher_impl::app_icon_update(json::jobject jobj)
	{
		json::jobject jsonPara;
		jsonPara["type"] = "app_icon_update";
		jsonPara["data"] = jobj;

		notifyResult(jsonPara.to_string());
	}
    
    void biz_higher_impl::recv_cloud_config(json::jobject jobj)
	{
		json::jobject jsonPara;
		jsonPara["type"] = "recv_cloud_config";
		jsonPara["data"] = jobj;
		notifyResult(jsonPara.to_string());
	}

    void biz_higher_impl::recv_growth_info_message(json::jobject jobj)
	{
		json::jobject jsonPara;
		jsonPara["type"] = "recv_growth_info_message";
		jsonPara["data"] = jobj;
		notifyResult(jsonPara.to_string());
	}

	void biz_higher_impl::set_language(json::jobject jobj)
	{

	}

	ios_biz_higher::ios_biz_higher()
	{
        

	}
	
	void ios_biz_higher::init()
	{
		impl_.reset(new biz_higher_impl);

		biz::biz_lower::instance().init(impl_,impl_->_thread.get_post_cmd());
	}

	void ios_biz_higher::executeCommand(json::jobject jobj)
	{
		impl_->executeCommand(jobj);
	}

	void ios_biz_higher::stop()
	{
		biz::biz_lower::instance().uninit();
		impl_.reset();
	}
}
