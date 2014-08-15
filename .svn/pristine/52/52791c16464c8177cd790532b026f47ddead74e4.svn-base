#include <base/utility/file_digest/file2uri.hpp>
#include <base/module_path/epfilesystem.h>
#include "lightapp.h"
#include "gloox_wrap/glooxWrapInterface.h"
#include "gloox_wrap/UserStanzaExtensionType.h"
#include <base/utility/bind2f/bind2f.hpp>
#include "base/module_path/file_manager.h"
#include "login.h"
#include "event_collection.h"
#include "user.h"
#include "agent.h"
#include "an_roster_manager.h"
#include "an_roster_manager_impl.h"
#include "conversation.h"
#include "agent_impl.h"
#include "local_config.h"
#include "whistle_vcard.h"
#include "biz_app_settings.h"
#include "base/http_trans/http_request.h"
#include "anan_config.h"
#include "file_transfer_manager.h"
#include <boost/algorithm/string.hpp>

using namespace epius::proactor;
using namespace std;
namespace biz {


	LightApp::LightApp()
	{
		gWrapInterface::instance().recv_lightapp_msg.connect(boost::bind(&LightApp::handleMessage, this, _1 , _2));
	}
	void LightApp::init()
	{
		if (get_parent_impl() && get_parent_impl()->bizLogin_)
		{
			get_parent_impl()->bizLogin_->conn_msm_.connected_signal_.connect(boost::bind(&LightApp::connected,this));
		}
	}

	LightApp::~LightApp()
	{

	}
	void LightApp::connected()
	{
		app_list_info = json::jobject();
	}
	void LightApp::set_biz_bind_impl( anan_biz_impl* impl )
	{
		anan_biz_impl_ = impl;
	}

	std::string LightApp::safe_get_childcdata( const gloox::Tag* tag_name, std::string name )
	{
		std::string cdata;
		if (tag_name->hasChild(name))
		{
			if (tag_name->hasChildWithCData(name,cdata))
			{
				return "";
			}
			else
			{
				return tag_name->findChild(name)->cdata();
			}
		}
		else
		{
			return "";
		}
	}

	void LightApp::handleMessage( const Message& msg, MessageSession* session /*= 0 */ )
	{
		if (msg.subtype() == Message::Error)
		{
			const Error* e = msg.error();
			if (!e)
			{
				return;
			}
			std::string error_type;
			if ( msg.error()->error() == StanzaErrorItemNotFound)
			{
				ELOG("app")->error(WCOOL(L"轻应用会话：应用不存在。"));
				error_type = "biz_lightapp_ItemNotFound";
			}
			else if (msg.error()->error() == StanzaErrorServiceUnavailable)
			{
				ELOG("app")->error(WCOOL(L"轻应用会话：应用服务异常。"));
				error_type = "biz_lightapp_ServiceUnavailable";
			}
			else if (msg.error()->error() == StanzaErrorGone)
			{
				ELOG("app")->error(WCOOL(L"轻应用会话：应用已下架。"));
				error_type = "biz_lightapp_Gone";
			}
			else
			{
				ELOG("app")->error(WCOOL(L"轻应用会话：服务器返回未知错误类型！") + boost::shared_ptr<gloox::Tag>(msg.tag())->xml());
				error_type = "biz_lightapp_UnknownError";
			}

			json::jobject app_msg;
			std::string appid , appid_bare; 
			appid = msg.from().bare();
			appid_bare = appid.substr(0, appid.find_first_of('@'));
			boost::ireplace_first(appid , appid_bare , boost::to_lower_copy(appid_bare));
			boost::to_lower(appid_bare);
			errorMessage(appid, error_type, "show");
		}
		else
		{
			do_handleMessage(msg , session);
		}
	}
	
	void LightApp::do_handleMessage( const Message& msg, MessageSession* session /*= 0 */ )
	{
		if (!msg.from().bare().empty() /*&& !msg.body().empty()*/)
		{
			json::jobject app_msg;
			std::string error_type;
			boost::shared_ptr<gloox::Tag> tag(msg.findExtension(kExtUser_msg_filter_messagebody)->tag());
			if (tag)
			{
				json::jobject jobj,crowd;
				gloox::Tag* tchild(tag->findChild("xml"));
				if (tchild)
				{
					std::string appid , appid_bare; 
					appid =msg.from().bare();
					appid_bare=appid.substr(0,appid.find_first_of('@'));
					boost::ireplace_first(appid , appid_bare , boost::to_lower_copy(appid_bare));
					boost::to_lower(appid_bare);
					app_msg["appid"] = appid;//待定

					app_msg["createtime"]=safe_get_childcdata(tchild,"createtime");
					app_msg["type"]=safe_get_childcdata(tchild,"msgtype");
					if (app_msg["type"].get<std::string>()=="text")
					{
						app_msg["content"]=safe_get_childcdata(tchild,"content");
					}
					else if (app_msg["type"].get<std::string>()=="music")
					{
						json::jobject music;
						tchild=tchild->findChild("music");
						if (tchild)
						{
							music["title"]=safe_get_childcdata(tchild,"title");
							music["description"]=safe_get_childcdata(tchild,"description");
							music["musicurl"]=safe_get_childcdata(tchild,"musicurl");
							music["hqmusicurl"]=safe_get_childcdata(tchild,"hqmusicurl");
							app_msg["music"]=music;
						}
						else
						{
							ELOG("app")->error("收到的轻应用消息格式为music，但是节点不完整: "  + boost::shared_ptr<gloox::Tag>(msg.tag())->xml());
							return ;
						}
					}
					else if (app_msg["type"].get<std::string>()=="news")
					{
						json::jobject news;
						news["articlecount"]=safe_get_childcdata(tchild,"articlecount");
						tchild=tchild->findChild("articles");
						if (tchild)
						{
							gloox::ConstTagList ptag_list = tchild->findTagList("//item");
							int i = 0;
							for (gloox::ConstTagList::iterator it = ptag_list.begin();it != ptag_list.end();it++,++i)
							{
								json::jobject item;
								item["title"]=safe_get_childcdata(*it,"title");
								item["description"]=safe_get_childcdata(*it,"description");
								item["picurl"]=safe_get_childcdata(*it,"picurl");
								item["url"]=safe_get_childcdata(*it,"url");
								news["articles"].arr_push(item);
							}
							app_msg["news"]=news;
						}
						else
						{
							ELOG("app")->error("收到的轻应用消息格式为news，但是节点不完整: "  + boost::shared_ptr<gloox::Tag>(msg.tag())->xml());
							return ;
						}
					}
					else if(app_msg["type"].get<std::string>() == "")
					{
						ELOG("app")->error("轻应用：收到的消息没有消息类型: "  + app_msg["type"].get<std::string>());
						error_type = "biz_lightapp_XmlError_NoMsgType";
						errorMessage(appid,error_type, "author_show");
						return ;
					}
					else
					{
						ELOG("app")->error("轻应用：收到未识别的消息类型: "  + app_msg["type"].get<std::string>());
						error_type = "biz_lightapp_XmlError_UnknownType";
						errorMessage(appid, error_type, "author_show");
						return ;
					}
				}
				else
				{
					ELOG("app")->error("收到的轻应用消息不含xml节点: "  + boost::shared_ptr<gloox::Tag>(msg.tag())->xml());
					return ;
				}

			}
			if(msg.findExtension(kExtUser_msg_filter_messageid))
			{
				app_msg["msg_id"]= boost::shared_ptr<gloox::Tag>(msg.findExtension(kExtUser_msg_filter_messageid)->tag())->cdata();
				msg_queue_.push_back(app_msg);
				do_get_lightapp_message();
			}
		}
	}

	void LightApp::errorMessage( std::string appid, std::string err_type, std::string is_show )
	{
		json::jobject app_msg;
		app_msg["appid"] = appid;
		app_msg["type"]="text";			
		app_msg["error"]=is_show;		
		app_msg["content"]=XL(err_type).res_value_utf8;		
		msg_queue_.push_back(app_msg);
		do_get_lightapp_message();
	}

	void LightApp::do_get_lightapp_message()
	{
		if(msg_queue_.empty())return;
		json::jobject jobj = msg_queue_.front();
		msg_queue_.pop_front();
		std::string appid=jobj["appid"].get<std::string>().substr(0,jobj["appid"].get<std::string>().find_first_of('@'));

		//会话祛重
		if (jobj["msg_id"].get<std::string>() != "" && get_parent_impl()->bizLocalConfig_->isLightAppMessageExist(appid,  jobj["msg_id"].get<std::string>()))
		{
			ELOG("app")->error(WCOOL(L"收到轻应用消息 但此消息已经接收过 app_id : ") + jobj["appid"].get<std::string>() + 
				" msg :" + jobj.get<std::string>() + " msg_id : " + jobj["msg_id"].get<std::string>());
			return;
		}

		int rowid = get_parent_impl()->bizLocalConfig_->SaveLightappMessage(appid, false, jobj,  jobj["msg_id"].get<std::string>());
		jobj["rowid"] = rowid;
		
		get_parent_impl()->bizRoster_->UpdateRecentContact(appid , KRecentLightApp);//最近联系人
		event_collect::instance().recv_session_msg( "", jobj["appid"].get<std::string>(), "", jobj.to_string());
		
		if (jobj["msg_id"].get<std::string>() != "")
		{
			gWrapInterface::instance().recv_msg_report(jobj["appid"].get<std::string>() , jobj["msg_id"].get<std::string>());
		}
		
		
		// 处理下一条会话消息
		get_parent_impl()->_p_private_task_->post(bind2f(&LightApp::do_get_lightapp_message, this));
	}

	void LightApp::send_lightapp_message( std::string appid, json::jobject msg, Result_Data_Callback callback )
	{
		IN_TASK_THREAD_WORKx(LightApp::send_lightapp_message, appid, msg, callback);

		//离线时不允许发送消息
		if((get_parent_impl()->bizLogin_->conn_msm_.getCurrentState()) != CONN_CONNECTED)
		{
			if(!callback.empty())
				callback(true,XL("biz.conversation.cannot_send_message_on_disconnect"),json::jobject());
			return;
		}

		if (msg.size() >= 1024*10 /*10kb*/)
		{
			if(!callback.empty())
				callback(true, XL("biz.conversation.message_too_large_to_send"), json::jobject());
			return;
		}

		string type = msg["type"].get<string>();
		// 检查参数
		if (type == "text" && msg.is_nil("content") ||
			type == "image" && msg.is_nil("image") ||
			type == "location" && msg.is_nil("location") ||
			type == "voice" && msg.is_nil("voice") ||
			type == "hello" && msg.is_nil("hello_id") ||
			type == "link" && msg.is_nil("link") ||
			type == "event" && msg.is_nil("event") )
		{
			callback(true, XL("biz.lightapp.bad_parameters"), json::jobject());
			return;
		}

		// 保存轻应用消息
		// event 类型消息UI不可见，不保存聊天记录
		std::string msgid = get_parent_impl()->bizClient_->getID();
		json::jobject jobj;
		if ( type == "image")
			add_image_uri(msg);
		if (type != "event" && type != "hello") 
		{
			int rowid = get_parent_impl()->bizLocalConfig_->SaveLightappMessage( appid, true, msg, msgid);
			jobj["rowid"] = rowid;
		}

		get_parent_impl()->bizRoster_->UpdateRecentContact( appid , KRecentLightApp);//最近联系人

		if ( type == "image")
		{
			if (epfilesystem::instance().file_exists(msg["image"].get<std::string>()))
			{
				boost::function<void(bool /*succ*/, std::string)> upload_callback = boost::bind(&LightApp::upload_pic_cb, this, appid, msg, jobj["rowid"].get<std::string>(), msgid, callback, _1, _2);
				epius::http_requests::instance().upload(anan_config::instance().get_http_upload_path(), msg["image"].get<std::string>(), "", "", boost::function<void(int)>(), upload_callback);
				callback(false, XL(""), jobj);
			}
			else
			{
				callback(true, XL("biz.lightapp.bad_parameters"), json::jobject());
			}
			return;
		}
		else if ( type == "voice")
		{
			if (epfilesystem::instance().file_exists(msg["voice"].get<std::string>()))
			{
				boost::function<void(bool /*succ*/, std::string)> upload_callback = boost::bind(&LightApp::upload_voice_cb, this, appid, msg, jobj["rowid"].get<std::string>(), msgid, callback, _1, _2);
				epius::http_requests::instance().upload(anan_config::instance().get_file_upload_path(), msg["voice"].get<std::string>(), "", "", boost::function<void(int)>(), upload_callback);
				callback(false, XL(""), jobj);
			}
			else
			{
				callback(true, XL("biz.lightapp.bad_parameters"), json::jobject());
			}
			return;
		}

		std::string student_number = get_parent_impl()->bizRoster_->getSelfVcardInfo()["student_number"].get<std::string>();
		gWrapInterface::instance().send_lightapp_message( appid+"@"+LIGHTAPP_DOMAIN+get_parent_impl()->bizAgent_->get_domain(), msg, msgid, student_number);
		callback(false, XL(""), jobj);
	}
	void LightApp::add_image_uri(json::jobject jobj)
	{
		if (!jobj.is_nil("image"))
		{
			std::string file_name = jobj["image"].get<std::string>();
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
				jobj["image"] = file_manager::instance().from_uri_to_path(file_uri);
				//拷贝计算好uri的图片到指定目录
				if(file_manager::instance().file_is_valid(file_manager::instance().from_uri_to_path(file_uri)))return;
				try
				{
					epfilesystem::instance().copy_file(file_name, file_manager::instance().from_uri_to_path(file_uri), true);
				}
				catch(...)
				{
					jobj["image"] = json::jobject();
					ELOG("app")->error("copy image file" + file_name + "error");
				}
			}
			else
			{
				jobj["image"] = json::jobject();
			}
		}
	}
	void LightApp::upload_pic_cb(std::string appid,json::jobject msg, std::string rowid, std::string msgid, Result_Data_Callback callback ,bool succ,std::string uri)
	{
		IN_TASK_THREAD_WORKx(LightApp::upload_pic_cb, appid, msg, rowid, msgid, callback, succ, uri);
		if (!succ)
		{
			// 通知失败的发送
			json::jobject rep_msg = msg.clone();
			rep_msg["msg_status"] = "sendout_failed";
			get_parent_impl()->bizLocalConfig_->updateMessage( rowid, "lightapp", rep_msg);
			event_collect::instance().send_message_failed( appid, rowid, "lightapp");

			return;
		}

		json::jobject jobj;
		jobj["rowid"] = rowid;

		json::jobject upload_obj(uri);
		if (upload_obj)
		{
			uri = upload_obj["file_uri"].get<std::string>();
			uri = epfilesystem::instance().sub_path(anan_config::instance().get_http_upload_path(), uri);
		}

		msg["image"]= uri;

		std::string student_number = get_parent_impl()->bizRoster_->getSelfVcardInfo()["student_number"].get<std::string>();
		gWrapInterface::instance().send_lightapp_message( appid+"@"+LIGHTAPP_DOMAIN+get_parent_impl()->bizAgent_->get_domain(), msg, msgid, student_number);
	}

	void LightApp::upload_voice_cb(std::string appid,json::jobject msg, std::string rowid, std::string msgid, Result_Data_Callback callback ,bool succ,std::string uri)
	{
		IN_TASK_THREAD_WORKx(LightApp::upload_voice_cb, appid, msg, rowid, msgid, callback, succ, uri);
		if (!succ)
		{
			// 通知失败的发送
			json::jobject rep_msg = msg.clone();
			rep_msg["msg_status"] = "sendout_failed";
			get_parent_impl()->bizLocalConfig_->updateMessage( rowid, "lightapp", rep_msg);
			event_collect::instance().send_message_failed( appid, rowid, "lightapp");

			return;
		}

		json::jobject jobj;
		jobj["rowid"] = rowid;

		json::jobject upload_obj(uri);
		if (upload_obj)
		{
			uri = upload_obj["file_uri"].get<std::string>();
			uri = epfilesystem::instance().sub_path(anan_config::instance().get_file_upload_path(), uri);
		}

		msg["voiceurl"]= uri;

		std::string student_number = get_parent_impl()->bizRoster_->getSelfVcardInfo()["student_number"].get<std::string>();
		gWrapInterface::instance().send_lightapp_message( appid+"@"+LIGHTAPP_DOMAIN+get_parent_impl()->bizAgent_->get_domain(), msg, msgid, student_number);
	}

	void LightApp::can_recv_lightapp_message( Result_Callback callback )
	{
		gWrapInterface::instance().can_recv_lightapp_message( callback);
	}

	void LightApp::download_lightapp_resources( std::string url, bool is_uri, boost::function<void(bool err, universal_resource res, std::string local_path)> callback )
	{
		IN_TASK_THREAD_WORKx( LightApp::download_lightapp_resources, url, is_uri, callback );
		std::string uri_file_str = file_manager::instance().from_uri_to_lightapp_path(url);
		bool is_need = epius::epfilesystem::instance().file_exists(uri_file_str);
		if(is_need)
		{
			callback(true, XL(""), uri_file_str);
			return;
		}
		else
		{
			epfilesystem::instance().create_directories(epius::epfilesystem::instance().branch_path(uri_file_str));
			if (is_uri)
			{
				epius::http_requests::instance().download(anan_config::instance().get_lightapp_resources_down_path(), uri_file_str, url, "", boost::function<void(int)>(), bind2f(&LightApp::download_lightapp_resources_cb,this,_1,_2, uri_file_str,callback));
			}
			else
			{
				epius::http_requests::instance().download(url, uri_file_str, "", "", boost::function<void(int)>(), bind2f(&LightApp::download_lightapp_resources_cb,this,_1,_2, uri_file_str,callback));		
			}
		}
	}

	void LightApp::download_lightapp_resources_cb( bool bsuccess , std::string reason, std::string local_path, boost::function<void(bool err, universal_resource res, std::string local_path)> callback )
	{
		IN_TASK_THREAD_WORKx( LightApp::download_lightapp_resources_cb, bsuccess, reason , local_path , callback );

		if(bsuccess)
		{
			callback(bsuccess ,XL(""), local_path);
		}
		else
		{
			callback(false,XL("Crowd.failed_to_download_uri"),"");
		}
	}

}
