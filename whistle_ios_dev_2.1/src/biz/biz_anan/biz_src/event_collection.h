#pragma once
#include <string>
#include <boost/function.hpp>
#include <boost/signal.hpp>
#include <base/json/tinyjson.hpp>
#include <base/utility/singleton/singleton.hpp>
#include "biz_presence_type.h"
#include "../universal_res/uni_res.h"

namespace biz{
    class event_collection_impl
    {
    public:
		boost::signal<void(json::jobject)>chat_group_member_changed; //讨论组成员变更通知
		boost::signal<void(json::jobject)> chat_group_list_changed;  //讨论组列表变更通知
		boost::signal<void()> hander_show_msg_dlg; //托盘通知应用程序
		//优化信号连接
		// 组变更通知
		boost::signal< void( std::string /*seqID*/,	bool /*error*/,	universal_resource /*const std::string*/) > recv_groups_changed;
		boost::signal< void(std::string, std::string, std::string, std::string) > recv_session_msg;
		boost::signal< void(std::string, std::string, std::string) > send_message_failed;
		boost::signal< void(json::jobject) > update_recent_contact;
		boost::signal< void(json::jobject) > recv_recent_contact;
		boost::signal< void(std::string /*jid*/,KPresenceType /*presence*/,json::jobject) > recv_presence;
		boost::signal< void( std::string /*jid*/, std::string /*rowid*/, std::string /*msg*/) > recv_add_request;
		boost::signal< void( std::string /*jid*/,std::string /*rowid*/, bool /*ack*/, json::jobject msg) > recv_add_ack;
		boost::signal< void(json::jobject) > update_head;
		boost::signal< void(json::jobject) > update_dialog_showname;
		/*
		jobject j;
		j["operation"] = "delete";//update,add
		j["jid"] = xxx
		j["changes"] = [];
		*/
		boost::signal<void(std::string)> recv_item_updated;
		boost::signal<void(json::jobject)> recv_organization_status_update;
		boost::signal<void(json::jobject)> recv_cloud_config;
		boost::signal<void(json::jobject)> recv_notice_message;
		boost::signal<void(json::jobject)> recv_app_message;
		boost::signal<void(json::jobject)> update_app_icon;
		boost::signal<void(json::jobject)> update_customize_login;
	};
	typedef boost::utility::singleton_holder<event_collection_impl> event_collect;
}

