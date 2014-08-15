
// Copyright (C) 2012, All rights reserved
//
// descrption: entrypoint file.
// ver: 2.0
// auther: majiazhi
// date: (YMD)2012/07/04
//---------------------------------------------------
#include <boost/uuid/uuid.hpp>
#include <boost/uuid/uuid_generators.hpp>
#include <boost/uuid/uuid_io.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/lambda/lambda.hpp>
#include <boost/bind.hpp>
#include <boost/filesystem.hpp>
#include <base/utility/bind2f/bind2f.hpp>
#include <base/utility/file_digest/file2uri.hpp>
#include <base/module_path/file_manager.h>
#include "base/module_path/epfilesystem.h"
#include "base/http_trans/http_request.h"
#include "base/thread/time_thread/time_thread_mgr.h"
#include "gloox_src/message.h"
#include "conversation.h"
#include "anan_biz_impl.h"
#include "login.h"
#include "anan_assert.h"
#include "an_roster_manager.h"
#include "an_roster_manager_impl.h"
#include "client_anan.h"
#include "local_config.h"
#include "anan_biz_bind.h"
#include "agent.h"
#include "agent_impl.h"
#include "user_impl.h"
#include "user.h"
#include "anan_private.h"
#include "roster_type.h"
#include "biz_presence_type.h"
#include "iq_filter.h"
#include "event_collection.h"
#include "discussions.h"
#include "anan_config.h"
#include "biz_app_settings.h"
#include "whistle_vcard.h"
#include "gloox_wrap/glooxWrapInterface.h"
#include "crowd.h"
using namespace std;

namespace biz{
	conversation::conversation(anan_biz_impl* parent)
	{
		set_parent_impl(parent);
		gWrapInterface::instance().discussions_get_image.connect(bind2f(&conversation::handleMessage, this, _1, _2));
		gWrapInterface::instance().filedak_get_message.connect(bind2f(&conversation::handleFiledakMessage, this, _1));
	}

	conversation::~conversation(void)
	{
	}

	void conversation::regist_to_gloox( Client* p_client )
	{
		// 注册消息接收句柄。
		get_parent_impl()->bizClient_->registerMessageSessionHandler(this, Message::Chat);
	}

	void conversation::handleMessage( const Message& msg, MessageSession* session /*= 0 */)
	{
		
		std::string jid_str;
		
		if (session->target().bare() == get_parent_impl()->bizClient_->jid().bare())
		{
			// 我的设备需要保存发送方的全jid
			jid_str = session->target().full();
		}
		else
		{
			jid_str = session->target().bare();
		}

		json::jobject msg_html_jobj(msg.html());

		//讨论组消息退出
		if( msg.from().full().find(DISCUSSIONS_DOMAIN) != std::string::npos)
		{
			return;
		}
		//存储消息
		get_parent_impl()->bizLocalConfig_->saveRecvMessage(message_conversation, jid_str, "", msg_html_jobj);
		get_parent_impl()->bizRoster_->UpdateRecentContact(jid_str, kRecentContact);

		//查看对方是否在线
		KPresenceType pres = get_parent_impl()->bizRoster_->get_calculate_presence(jid_str);
		if ( pres == kptInvisible)
		{
			//通知对方上线并设置定时器监控监控时间为5分钟
			json::jobject tmp_jobj;
			KPresenceType tmp_presence = kptOnline; //默认是pc在线状态

			if (msg.from().resource() == "android") //android回话则显示android在线
			{
				tmp_presence = kptAndroid;
			}
			else if (msg.from().resource() == "ios") //ios回话则显示ios在线
			{
				tmp_presence = kptIOS;
			}

			get_parent_impl()->bizRoster_->setPresence(jid_str, tmp_presence);
			get_parent_impl()->bizRoster_->change_presence_jids_.insert(jid_str);
			event_collect::instance().recv_presence(jid_str, tmp_presence, tmp_jobj);
			
			//定时器超过2分钟没发消息就发送隐身
			boost::function<void()> invisible_cmd = [=]()
			{
				get_parent_impl()->bizRoster_->setPresence(jid_str, kptInvisible);
				get_parent_impl()->bizRoster_->change_presence_jids_.erase(jid_str);
				event_collect::instance().recv_presence(jid_str, kptInvisible, tmp_jobj);
			};
			epius::time_mgr::instance().set_timer(jid_str,2*60*1000, get_parent_impl()->wrap(invisible_cmd));					
		}
		//将收到的消息通知给ui
		event_collect::instance().recv_session_msg(jid_str, msg.from().full(), "", msg_html_jobj.to_string());
	}		

	void conversation::handleMessageSession( MessageSession* session )
	{ 
		session->registerMessageHandler(this);
		m_sessions.insert(make_pair(session->target().bare(), session));
	}

	void conversation::send_msg_in_session(MessageSession *session, std::string const& txt_msg, std::string const& msg)
	{
		session->send(txt_msg, EmptyString, msg);
	}

	std::string conversation::save_send_message(json::jobject msg_jobj, std::string const& msg, std::string& msg_type)
	{
		json::jobject message(msg);
		std::string session_jid = msg_jobj["args"]["target"].get<string>();
		
		if( session_jid.find(DISCUSSIONS_DOMAIN) != std::string::npos)
		{
			std::string group_name = g_discussions::instance().get_group_name(session_jid);
			get_parent_impl()->bizLocalConfig_->saveChatGroupMessage(group_name, session_jid, get_parent_impl()->bizClient_->jid().bare(),
				get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardShowname].get<std::string>(), message, "", true);
			get_parent_impl()->bizRoster_->UpdateRecentContact(session_jid , kRecentMUC);
			msg_type = "group_chat";
		}
		else if (session_jid.find(GROUPS_DOMAIN) != std::string::npos)
		{
			std::string crowd_name = g_crowd::instance().get_crowd_name(session_jid);
			get_parent_impl()->bizLocalConfig_->saveCrowdMessage(crowd_name, session_jid, get_parent_impl()->bizClient_->jid().bare(), 
				get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardShowname].get<std::string>(), message, "", true);
			get_parent_impl()->bizRoster_->UpdateRecentContact(session_jid , kRecentCrowd);
			msg_type = "crowd_chat";
		}
		else
		{
			if (message["msg_extension"].get<std::string>() != "send_file")
				get_parent_impl()->bizLocalConfig_->saveSendMessage(message_conversation, session_jid, "", message);
			get_parent_impl()->bizRoster_->UpdateRecentContact(session_jid , kRecentContact);
			msg_type = message_conversation;
		}

		return message["rowid"].get<std::string>();
	}

	void conversation::send_msg( json::jobject msg_jobj, std::string const& txt_msg, std::string const& msg, boost::function<void(json::jobject, bool, universal_resource)> callback )
	{
		IN_TASK_THREAD_WORKx( conversation::send_msg, msg_jobj, txt_msg, msg, callback );

		std::string session_jid = msg_jobj["args"]["target"].get<string>();
		
		//不在线时不允许发送消息

		if((get_parent_impl()->bizLogin_->conn_msm_.getCurrentState()) != CONN_CONNECTED)
		{
			if(!callback.empty())callback(msg_jobj,true,XL("biz.conversation.cannot_send_message_on_disconnect"));
			return;
		}
		if( session_jid.find(DISCUSSIONS_DOMAIN) != std::string::npos){
			g_discussions::instance().send_msg(session_jid, txt_msg, msg);
			if(!callback.empty())callback(msg_jobj,false,XL(""));
			return;
		}else if (session_jid.find(GROUPS_DOMAIN) != std::string::npos)
		{
			g_crowd::instance().send_msg(session_jid, txt_msg, msg);
			if(!callback.empty())callback(msg_jobj,false,XL(""));
			return;
		}
		// 我的设备 发送消息给自己不能使用MessageSession
		else if (JID(session_jid).bare() == get_parent_impl()->bizClient_->jid().bare())
		{
			Message smessage( Message::Chat, session_jid, txt_msg, EmptyString, msg );
			get_parent_impl()->bizClient_->send( smessage );
			if(!callback.empty())callback(msg_jobj,false,XL(""));
			return;
		}

		std::map<std::string, MessageSession*>::iterator it = m_sessions.find(session_jid);
		if ( it != m_sessions.end() )
		{
			send_msg_in_session(it->second, txt_msg, msg);
		}
		else
		{
			JID jid(session_jid);
			MessageSession *session;
			session = new MessageSession(get_parent_impl()->bizClient_, jid, true, gloox::Message::Chat);
			m_sessions.insert(std::make_pair(jid.bare(), session));
			session->registerMessageHandler(this);
			send_msg_in_session(session, txt_msg, msg);
		}
		if(!callback.empty())
		{
			callback(msg_jobj,false,XL(""));
		}
	}

	void conversation::download_image_cb( std::string local_image_path,bool succ, std::string uri,boost::function<void(json::jobject)>callback )
	{
		if (succ)
		{
			//给js返回从服务器下载好的图片
			json::jobject jobj;
			std::string download_image_uri = epius::get_uri(local_image_path);
			if (download_image_uri == uri)
			{				
				jobj["src"] = local_image_path; 
				if (!callback.empty())
				{
					callback(jobj);
					ELOG("http")->debug("download image ok" + jobj.to_string());
					return;
				}
				else
				{
					ELOG("http")->error("callback in conversation::download_image_cb is wrong! ");
				}				
			}
			else
			{
				ELOG("http")->error("download image "+uri+" failed!");
			}			
		}

		if (!callback.empty())
		{
			json::jobject jobj;
			jobj["result"] = "fail";
			jobj["reason"] = "biz.conversation.get_image_failed";
			callback(jobj);
		}
	}

	void conversation::download_image( json::jobject jobj,boost::function<void(json::jobject)>callback)
	{
		std::string image_path = file_manager::instance().from_uri_to_path(jobj["url"].get<std::string>());
		std::string image_uri = jobj["url"].get<std::string>();
		epius::http_requests::instance().download( anan_config::instance().get_http_down_path(), image_path, image_uri,"", boost::function<void(int)>(), boost::bind(&conversation::download_image_cb,this,image_path,_1,image_uri,callback));
	}

	void conversation::download_voice_cb( std::string local_voice_path, bool succ, std::string uri, boost::function<void(json::jobject)>callback )
	{
		if (succ)
		{
			//给js返回从服务器下载好的语音
			json::jobject jobj;
			std::string download_voice_uri = epius::get_uri(local_voice_path);
			if (download_voice_uri == uri)
			{				
				jobj["src"] = local_voice_path; 
				if (!callback.empty())
				{
					callback(jobj);
					ELOG("http")->debug("download voice ok" + jobj.to_string());
					return;
				}
				else
				{
					ELOG("http")->error("callback in conversation::download_voice_cb is wrong! ");
				}				
			}
			else
			{
				ELOG("http")->error("download voice "+uri+" failed!");
			}			
		}

		if (!callback.empty())
		{
			json::jobject jobj;
			jobj["result"] = "fail";
			jobj["reason"] = "biz.conversation.get_voice_failed";
			callback(jobj);
		}
	}

	void conversation::download_voice( json::jobject jobj,boost::function<void(json::jobject)>callback)
	{
		std::string voice_path = file_manager::instance().from_uri_to_voice_path(jobj["url"].get<std::string>());
		std::string voice_uri = jobj["url"].get<std::string>();
		epius::http_requests::instance().download( anan_config::instance().get_http_down_path(), voice_path, voice_uri,"", boost::function<void(int)>(), boost::bind(&conversation::download_voice_cb, this, voice_path, _1, voice_uri, callback));
	}

	void conversation::add_image_uri(json::jobject jobj,std::string key,json::jobject val)
	{
		if (val)
		{
			std::string file_name = val.get<std::string>();
			std::string str_tmp = "file:///";
			std::string::size_type temp_pos = file_name.find(str_tmp);
			if (temp_pos != std::string::npos)
			{
				file_name = file_name.substr(temp_pos + strlen(str_tmp.c_str()));
			}

			if(epfilesystem::instance().file_exists(file_name))
			{			
				//计算uri
				std::string file_uri = epius::get_uri(file_name);

				ELOG("http")->debug("now will upload " + file_name + " to " + file_uri );
				jobj["args"]["msg"]["image"][key] = file_uri;
				//拷贝计算好uri的图片到指定目录
				if(file_manager::instance().file_is_valid(file_manager::instance().from_uri_to_path(file_uri)))return;
				try
				{
					epfilesystem::instance().copy_file(file_name, file_manager::instance().from_uri_to_path(file_uri), true);
				}
				catch(...)
				{
					jobj["args"]["msg"]["image"][key] = json::jobject();
					ELOG("app")->error("copy image file" + file_name + "error");
				}
			}
			else
			{
				jobj["args"]["msg"]["image"][key] = json::jobject();
			}
		}
	}

	void conversation::add_voice_uri(json::jobject jobj,std::string key,json::jobject val)
	{
		if (val)
		{
			std::string file_name = val.get<std::string>();
			if(epfilesystem::instance().file_exists(file_name))
			{			
				//计算uri
				std::string file_uri = epius::get_uri(file_name);

				ELOG("http")->debug("now will upload " + file_name + " to " + file_uri );
				jobj["args"]["msg"]["voice"][key] = file_uri;
				//拷贝计算好uri的语音到指定目录
				if(file_manager::instance().file_is_valid(file_manager::instance().from_uri_to_voice_path(file_uri)))return;
				try
				{
					epfilesystem::instance().copy_file(file_name, file_manager::instance().from_uri_to_voice_path(file_uri), true);
				}
				catch(...)
				{
					jobj["args"]["msg"]["voice"][key] = json::jobject();
					ELOG("app")->error("copy voice file" + file_name + "error");
				}
			}
			else
			{
				jobj["args"]["msg"]["voice"][key] = json::jobject();
			}
		}
	}

	void conversation::send_message( json::jobject msg_jobj,boost::function<void(json::jobject, bool, universal_resource)> callback )
	{
		IN_TASK_THREAD_WORKx( conversation::send_message, msg_jobj, callback);

		if((get_parent_impl()->bizLogin_->conn_msm_.getCurrentState()) != CONN_CONNECTED)
		{
			if(!callback.empty())callback(msg_jobj, true,XL("biz.conversation.cannot_send_message_on_disconnect"));
			return;
		}

#ifdef _WIN32 //自动回复延时处理
		if (!msg_jobj["args"].is_nil("sleep"))
		{
			int sleep_time = msg_jobj["args"]["sleep"].get<int>();
			_sleep(sleep_time*1000);
		}
#endif

		json::jobject jobj_image, jobj_voice;
		jobj_image = msg_jobj["args"]["msg"]["image"].clone();
		jobj_voice = msg_jobj["args"]["msg"]["voice"].clone();

		std::string target = msg_jobj["args"]["target"].get<std::string>();
		//替换图片uri
		msg_jobj["args"]["msg"]["image"].each(bind2f(&conversation::add_image_uri,this,msg_jobj,_1,_2));
		while(msg_jobj["args"]["msg"]["image"].erase_if(boost::function<bool(std::string, json::jobject)>(boost::lambda::_2 == json::jobject())));
		//替换语音uri
		msg_jobj["args"]["msg"]["voice"].each(bind2f(&conversation::add_voice_uri,this,msg_jobj,_1,_2));
		while(msg_jobj["args"]["msg"]["voice"].erase_if(boost::function<bool(std::string, json::jobject)>(boost::lambda::_2 == json::jobject())));

		//将修好的uri发送出去
		std::string msg_txt = msg_jobj["args"]["txt"].get<string>();
		if (msg_txt == "")
		{
			//发送消息body不能为空 如果是空就发送空格
			msg_txt = " ";
		}

		if (msg_jobj["args"]["msg"]["image"].size() == 0)
		{
			msg_jobj["args"]["msg"].erase_if(boost::function<bool(std::string, json::jobject)>(boost::lambda::_1 == "image"));
		}

		if (msg_jobj["args"]["msg"]["voice"].size() == 0)
		{
			msg_jobj["args"]["msg"].erase_if(boost::function<bool(std::string, json::jobject)>(boost::lambda::_1 == "voice"));
		}

		boost::posix_time::ptime time = boost::posix_time::second_clock::local_time();
		tm tm1 = boost::posix_time::to_tm( time );
		time_t tt = mktime( &tm1 );
		msg_jobj["args"]["msg"]["stdtime"] = (int)tt;

		std::string msg = msg_jobj["args"]["msg"].to_string();

		if (msg.size() >= 1024*10 /*10kb*/)
		{
			if(!callback.empty())callback(msg_jobj, true, XL("biz.conversation.message_too_large_to_send"));
			return;
		}

		std::string msg_type;
		std::string rowid = save_send_message(msg_jobj, msg, msg_type);
		msg_jobj["rowid"] = rowid;

		boost::function<void(bool, std::string)> upload_callback = [=]() mutable ->boost::function<void(bool, std::string)> {
			int total_upload = jobj_image.size() + jobj_voice.size();
			boost::shared_ptr<int> succeed_count(new int(0));
			boost::shared_ptr<int> returned_count(new int(0));
			return [=](bool succ, std::string uri) mutable 
			{
				*succeed_count += succ;
				(*returned_count)++;
				if(*returned_count >= total_upload)
				{
					if(*succeed_count >= total_upload)
					{
						send_msg(msg_jobj, msg_txt, msg, callback);	
					}
					else
					{
						//保存发送失败到会话记录
						json::jobject rep_msg = msg_jobj["args"]["msg"].clone();
						rep_msg["msg_status"] = "sendout_failed";
						get_parent_impl()->bizLocalConfig_->updateMessage(rowid, msg_type, rep_msg);
						event_collect::instance().send_message_failed(msg_jobj["args"]["target"].get<string>(), msg_jobj["rowid"].get<std::string>(), msg_type);
					}
				}
		};
		}();
		boost::function<void(std::string, json::jobject)> upload_cmd = [=](std::string key, json::jobject val)
		{
			std::string file_name = val.get<std::string>();
			std::string str_tmp = "file:///";
			std::string::size_type temp_pos = file_name.find(str_tmp);
			if (temp_pos != std::string::npos)
			{
				file_name = file_name.substr(temp_pos + strlen(str_tmp.c_str()));
			}
			if (file_name.empty())
			{
				return;
			}
			epius::http_requests::instance().upload(anan_config::instance().get_http_upload_path(),file_name,"", "", boost::function<void(int)>(),upload_callback);
		};
		if (msg_jobj["args"]["msg"]["image"] || msg_jobj["args"]["msg"]["voice"])
		{
			callback(msg_jobj, false, XL(""));
			jobj_image.each(upload_cmd);
			jobj_voice.each(upload_cmd);
		}
		else
		{
			send_msg(msg_jobj, msg_txt, msg, callback);	
		}
	}

	void conversation::get_image( json::jobject jobj,boost::function<void(json::jobject)>callback )
	{
		IN_TASK_THREAD_WORKx( conversation::get_image, jobj,callback );
		if (!jobj)
		{
			ELOG("http")->debug("get_image jobj is null");
			return;
		}
		ELOG("http")->debug("get_image downdload image");
		std::string image_id = jobj["id"].get<std::string>();
		std::string image_uri = jobj["url"].get<std::string>();
		json::jobject image_jobj;
		std::string valid_path_from_uri = file_manager::instance().from_uri_to_valid_path(image_uri);
		if (!valid_path_from_uri.empty())
		{
			image_jobj["src"] = valid_path_from_uri;
			callback(image_jobj);
		}
		else
		{
			//文件在服务器上已经ready从服务器下载
				download_image(jobj,callback);
		}
	}

	void conversation::get_voice( json::jobject jobj,boost::function<void(json::jobject)>callback )
	{
		IN_TASK_THREAD_WORKx( conversation::get_voice, jobj,callback );
		if (!jobj)
		{
			ELOG("http")->debug("get_voice jobj is null");
			return;
		}
		ELOG("http")->debug("get_voice downdload voice");

		std::string voice_id = jobj["id"].get<std::string>();
		std::string voice_uri = jobj["url"].get<std::string>();

		json::jobject voice_jobj;
		std::string valid_path_from_uri = file_manager::instance().from_voice_uri_to_valid_path(voice_uri);
		if (!valid_path_from_uri.empty())
		{
			voice_jobj["src"] = valid_path_from_uri;
			callback(voice_jobj);
		}
		else
		{
			//文件在服务器上已经ready从服务器下载
			download_voice(jobj,callback);					
		}
	}

	void conversation::handleFiledakMessage( json::jobject jobj )
	{
		// 消息属于一个已经存在的会话。
		json::jobject html = json::jobject(jobj["html"].get<std::string>());
		get_parent_impl()->bizLocalConfig_->saveRecvMessage(message_conversation, jobj["from"].get<std::string>(), "", html);
		get_parent_impl()->bizRoster_->UpdateRecentContact(jobj["from"].get<std::string>(), kRecentContact);
		std::string jid_str = jobj["from"].get<std::string>();
		//查看对方是否在线
		KPresenceType pres = get_parent_impl()->bizRoster_->get_calculate_presence(jid_str);
		if ( pres == kptInvisible)
		{
			//通知对方上线并设置定时器监控监控时间为5分钟
			json::jobject tmp_jobj;
			KPresenceType tmp_presence = kptOnline; //默认是pc在线状态

			if (jobj["resource"].get<std::string>() == "android") //android回话则显示android在线
			{
				tmp_presence = kptAndroid;
			}
			else if (jobj["resource"].get<std::string>() == "ios") //ios回话则显示ios在线
			{
				tmp_presence = kptIOS;
			}

			get_parent_impl()->bizRoster_->setPresence(jid_str, tmp_presence);
			get_parent_impl()->bizRoster_->change_presence_jids_.insert(jid_str);
			event_collect::instance().recv_presence(jid_str, tmp_presence, tmp_jobj);

			//定时器超过2分钟没发消息就发送隐身
			boost::function<void()> invisible_cmd = [=]()
			{
				get_parent_impl()->bizRoster_->setPresence(jid_str, kptInvisible);
				get_parent_impl()->bizRoster_->change_presence_jids_.erase(jid_str);
				event_collect::instance().recv_presence(jid_str, kptInvisible, tmp_jobj);
			};
			epius::time_mgr::instance().set_timer(jid_str,2*60*1000, get_parent_impl()->wrap(invisible_cmd));					
		}

		event_collect::instance().recv_session_msg(jobj["from"].get<std::string>(), jobj["from"].get<std::string>(), "", html.to_string());
		
		// send recv file transfer iq to server
		gWrapInterface::instance().cancel_send_file_msg(jobj["from"].get<std::string>(), html["id"].get<std::string>(), boost::bind(&conversation::cancel_send_file_msg_cb, this, _1,_2));
	}

	void conversation::cancel_send_file_msg_cb( bool err, universal_resource reason )
	{
		if (err)
		{
			ELOG("app")->error("conversation::cancel_send_file_msg_cb: cancel transfer file message failed.");
		}
	}

};
