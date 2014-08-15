#include "notice_msg.h"
#include "boost/bind.hpp"
#include "base/utility/bind2f/bind2f.hpp"
#include "agent.h"
#include "agent_impl.h"
#include "anan_biz_impl.h"
#include "base/tcpproactor/TcpProactor.h"
#include <iostream>
#include "iq_filter.h"
#include "notice_msg_impl.h"
#include "anan_private.h"
#include "gloox_src/tag.h"
#include "gloox_src/clientbase.h"
#include "client_anan.h"
#include "login.h"
#include "gloox_src/message.h"
#include "msg_extension.h"
#include "notice_msg_ack.h"
#include "local_config.h"
#include "biz_app_settings.h"
#include "anan_config.h"
#include "gloox_wrap/UserStanzaExtensionType.h"
#include "gloox_wrap/basicStanza.hpp"
#include "gloox_wrap/glooxWrapInterface.h"
#include "base/http_trans/http_request.h"
#include "base/utility/file_digest/file2uri.hpp"
#include <base/time/time_format.h>
#include <base/universal_res/uni_res.h>
#include "lightapp.h"
namespace biz 
{
	notice_msg::notice_msg(void) : impl_(new notice_msg_impl())
	{
				
	}

	notice_msg::~notice_msg( void )
	{

	}

	void notice_msg::notice_result( UIVCallback callback )
	{

	}

	void notice_msg::publish( json::jobject jobj, UIVCallback callback )
	{
		IN_TASK_THREAD_WORKx( notice_msg::publish, jobj, callback);

		iq_ext_notice query(jobj);
		query.send(app_settings::instance().get_domain(), this, ++impl_->autoinc_context_);
		NoticeResult nr;
		nr.callback = callback;
		nr.jobj = jobj;
		impl_->callback_.insert(std::make_pair(impl_->autoinc_context_, nr));
	}

	bool notice_msg::handleIq( const IQ& iq )
	{
		return true;

	}

// 	void notice_msg::request_notice_msg()
// 	{
// <!-- 获取消息通知 -->
// <iq id="s9Fg6-51" type="get" to="notification.ruijie.com.cn">
// 	<query>
// 		<notification id="5"/>
// 		<notification id="6"/>
// 	</query>
// </iq>
// 
// 	}

	void notice_msg::handleIqID( const IQ& iq, int context )
	{
		NoticeMapJsonCallback::iterator it = impl_->callback_.find(context);
		if(it != impl_->callback_.end())
		{
			NoticeResult& nr = it->second;
			json::jobject jobj = nr.jobj;
			UIVCallback callback = nr.callback;
			if (!callback.empty()) 
			{
				if (iq.subtype() == IQ::Result)
				{
					std::string cdata = boost::shared_ptr<gloox::Tag>(iq.tag())->findCData("/iq/id");
					if (!cdata.empty())
					{
						int id = boost::lexical_cast<int>(cdata);
						get_parent_impl()->bizLocalConfig_->savePublish(id, jobj);
					}
					callback(false, XL(""));
				}
				else
				{
					callback(true, XL("biz.notice_msg.request.failed"));
				}
			}
			impl_->callback_.erase(it);
		}
	}

	void notice_msg::regist_to_gloox( AnClient* p_client )
	{
		p_client->registerMessageSessionHandler(this, Message::Normal);
		p_client->registerStanzaExtension(new msg_ext_notification());

		typedef BasicStanza<kExtUser_msg_filter_appmessage> msg_app_message;
		p_client->registerStanzaExtension(new msg_app_message(NULL, "/message[@from='message." + anan_config::instance().get_domain() +  "']"));

	}

	void notice_msg::sam_publish_notice( json::jobject jobj )
	{
		//解决sam认证消息出现在应用提醒中的功能
		IN_TASK_THREAD_WORKx( notice_msg::sam_publish_notice, jobj);
		json::jobject app_msg;
		std::string msg_str = jobj["args"].get();
		app_msg["body"] = msg_str;
		app_msg["html"] = msg_str;
		std::string msg_id = "1";
		std::string s_id = "sam_service";
		std::string s_name = XL("sam_service_name").res_value_utf8;
		boost::posix_time::ptime time = boost::posix_time::second_clock::local_time();
		std::string time_str = time_format(time);
		get_parent_impl()->bizLocalConfig_->SaveAppMessage(msg_id, s_id,s_name, "", app_msg.to_string(), time_str, true);
	}

	void notice_msg::handleMessage( const Message& msg, MessageSession* session /*= 0 */ )
	{

		if (msg.from().bare().find(LIGHTAPP_DOMAIN)!=msg.from().bare().npos)
		{
			g_lightapp::instance().handleMessage(msg,session);
			return;
		}

		const msg_ext_notification* p_notice = msg.findExtension<msg_ext_notification>(kExtUser_iq_filter_noticemsg);
		if (p_notice) 
		{
			json::jobject jobj;
			json::jobject notice_jobj;
			std::string expired_time,priority;
			std::string id_string = p_notice->reftag().findCData("/message/id[@xmlns='http://ruijie.com.cn/notification']");
			if (id_string.empty())
			{
				id_string = p_notice->reftag().findCData("/message/id");
			}
			jobj["id"] = id_string;
			jobj["title"]  = p_notice->reftag().findCData("/message/title");
			jobj["signature"]  = p_notice->reftag().findCData("/message/signature");
			priority  = p_notice->reftag().findCData("/message/priority");
			expired_time  = p_notice->reftag().findCData("/message/expired_time");
			jobj["priority"]  = p_notice->reftag().findCData("/message/priority");
			jobj["expired_time"]  = p_notice->reftag().findCData("/message/expired_time");
			jobj["publish_time"]  = p_notice->reftag().findCData("/message/publish_time");
			jobj["body"]  = p_notice->reftag().findCData("/message/body");
			jobj["html"]  = p_notice->reftag().findCData("/message/html");

			std::string hyperlink = p_notice->reftag().findCData("/message/hyperlink");
			if (!hyperlink.empty())
			{
				jobj["hyperlink"] = hyperlink;
			}
			std::string service_id = p_notice->reftag().findCData("/message/sdk/service_id");

			if (service_id.empty())
			{
				//过滤已经收到的通知。
				json::jobject notice_obj = get_parent_impl()->bizLocalConfig_->LoadOneNoticeMessage(id_string);
				if (notice_obj["data"]) 
				{
					return;
				}
				assert(!id_string.empty());
				if (!id_string.empty()) 
				{
					//已过期重要通知不弹窗口
					std::string cur_time = get_parent_impl()->bizLocalConfig_->getCurrentTime();
					notice_msg_ack(id_string, kna_recv).send(get_parent_impl()->bizClient_);
					std::string rowid = get_parent_impl()->bizLocalConfig_->save_notice_message(id_string, jobj["signature"].get<std::string>(), jobj.to_string(),expired_time,priority);
					if (cur_time <= jobj["expired_time"].get<std::string>())
					{
						notice_jobj["subid"] = jobj["signature"].get<std::string>();
						notice_jobj["showname"] = jobj["signature"].get<std::string>();
						notice_jobj["rowid"] = rowid;
						notice_jobj["priority"] = jobj["priority"].get<std::string>();
						notice_jobj["jid"] = id_string;
						notice_jobj["is_read"] = 0;
						notice_jobj["expired_time"] = jobj["expired_time"].get<std::string>();
						notice_jobj["dt"] = cur_time;
						notice_jobj["msg"] = jobj.to_string();
						event_collect::instance().recv_notice_message(notice_jobj);
					}										
				}
				return;
			}
			else
			{
				//已过期重要通知不弹窗口				
				notice_msg_ack(id_string, kna_recv).send(get_parent_impl()->bizClient_);
				json::jobject app_notice_msg;
				app_notice_msg["body"] = jobj["body"].get<std::string>();
				app_notice_msg["html"] = jobj["html"].get<std::string>();
				app_notice_msg["publish_time"] = jobj["publish_time"].get<std::string>();
				app_notice_msg["title"] = jobj["title"].get<std::string>();
				if (!hyperlink.empty())
				{
					app_notice_msg["hyperlink"] = hyperlink;
				}
				std::string rowid = get_parent_impl()->bizLocalConfig_->SaveAppNoticeMessage(id_string, jobj["signature"].get<std::string>(), app_notice_msg.to_string(), expired_time, priority);
				std::string cur_time = get_parent_impl()->bizLocalConfig_->getCurrentTime();
				if (cur_time <= jobj["expired_time"].get<std::string>())
				{
					json::jobject app_notice_jobj;
					app_notice_jobj["subid"] = jobj["signature"].get<std::string>();
					app_notice_jobj["showname"] = jobj["signature"].get<std::string>();
					app_notice_jobj["rowid"] = rowid;
					app_notice_jobj["priority"] = jobj["priority"].get<std::string>();
					app_notice_jobj["jid"] = id_string;
					app_notice_jobj["is_read"] = 0;
					app_notice_jobj["expired_time"] = jobj["expired_time"].get<std::string>();
					app_notice_jobj["dt"] = cur_time;
					app_notice_jobj["msg"] = jobj.to_string();
					event_collect::instance().recv_notice_message(app_notice_jobj);
				}
			}
		}
		else if(msg.findExtension(kExtUser_msg_filter_appmessage))
		{
			boost::shared_ptr<gloox::Tag> tag(msg.findExtension(kExtUser_msg_filter_appmessage)->tag());
			if (tag)
			{
				std::string id = tag->findCData("/message/id");
				std::string body = tag->findCData("/message/body");
				std::string html = tag->findCData("/message/html");
				std::string hyperlink = tag->findCData("/message/hyperlink");
				std::string publish_time = tag->findCData("/message/timestamp");
				std::string service_id = tag->findCData("/message/sdk[@xmlns='sdk:message']/service_id");
				std::string service_name = tag->findCData("/message/sdk[@xmlns='sdk:message']/alias_name");
				std::string service_icon = tag->findCData("/message/sdk[@xmlns='sdk:message']/service_icon");
				gWrapInterface::instance().ack_app_message( id, "recv");
				json::jobject app_msg;
				app_msg["body"] = body;
				app_msg["html"] = html;
				if (!hyperlink.empty())
				{
					app_msg["hyperlink"] = hyperlink;
				}

				get_parent_impl()->bizLocalConfig_->SaveAppMessage(id, service_id, service_name, service_icon, app_msg.to_string(), publish_time);

				json::jobject service;
				service["service_info"]["id"] = service_id;
				service["service_info" ]["name"] = service_name;
				service["service_info"]["icon"] = service_icon;

				//新UE移动端需要重复的 service_info 在msg里 
				service["msg"]["service_info"]["id"] = service_id;
				service["msg"]["service_info" ]["name"] = service_name;
				service["msg"]["service_info"]["icon"] = service_icon;

				std::string download_path;
				json::jobject s_info = service["service_info"];
				if (is_need_download_icon(s_info, download_path))
				{
					service["msg"]["service_info"]["icon"] = service["service_info"]["icon"].get<std::string>();
					get_parent_impl()->bizLocalConfig_->createDirectories();
					boost::function<void(bool,std::string)> callback = boost::bind(&notice_msg::finished_syncdown_icon, get_parent_impl()->bizNotice_, service_id, service_name, download_path, _1, _2);
					epius::http_requests::instance().download(anan_config::instance().get_http_down_path(), download_path, service_icon, "", boost::function<void(int)>(), epius::thread_switch::CmdWrapper(get_parent_impl()->_p_private_task_->get_post_cmd(),callback));
				}
				service["msg"]["sendTime"] = publish_time;
				service["msg"]["message_id"] = id;
				service["msg"]["msg"] = app_msg;

				get_parent_impl()->bizLocalConfig_->GetUnreadAppMessageCountByServiceID(service_id, service);
				event_collect::instance().recv_app_message(service);
			}
		}

		return;
	}

	void notice_msg::finished_syncdown_icon( std::string service_id, std::string service_name, std::string download_path, bool succ, std::string uri_string )
	{
		if (succ)
		{	
			boost::function<void(std::string)> work_body = [=](std::string image_uri)
			{
				//判断下载下来的图片是否正确
				if (image_uri == uri_string)
				{
					//通知UI Icon准备完毕
					json::jobject jobj;
					jobj["id"]   = service_id;
					jobj["icon"] = download_path;
					jobj["name"] = service_name;
					event_collect::instance().update_app_icon(jobj);
				}
				else
				{
					ELOG("app")->error("failed download 3rd app icon: file uri different!");
					return;
				}			
			};
			epius::async_get_uri(download_path, get_parent_impl()->wrap(work_body));
		}
		else
		{
			ELOG("app")->error("failed download 3rd app icon!");
		}
	}

	bool notice_msg::is_need_download_icon(json::jobject& service, std::string &download_path )
	{
		std::string uri_string = service["icon"].get<std::string>();
		if (uri_string.empty())
		{
			return false;
		}

		std::string the_path_from_uri = file_manager::instance().from_uri_to_path(uri_string);
		bool is_need = !file_manager::instance().file_is_valid(the_path_from_uri);
		if (!is_need) 
		{
			service["icon"] = the_path_from_uri;
		} 
		else
		{
			service["icon"] = "";
			download_path = the_path_from_uri;
		}
		return (is_need);
	}

	void notice_msg::handleMessageSession( MessageSession* session )
	{
		session->registerMessageHandler(this);
	}
}; // namespace biz





