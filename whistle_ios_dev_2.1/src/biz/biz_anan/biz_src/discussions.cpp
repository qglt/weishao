#include "discussions.h"
#include "gloox_wrap/glooxWrapInterface.h"
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
#include <base/local_search/local_search.h>
#include "base/http_trans/http_request.h"
#include "anan_config.h"
#include "conn_msm.h"

using namespace epius::proactor;
namespace biz {


	Discussions::Discussions()
	{
		had_fetch_list_ = false;
		gWrapInterface::instance().discussions_list_change.connect(boost::bind(&Discussions::get_group_list_changed, this, _1));
		gWrapInterface::instance().discussions_member_change.connect(boost::bind(&Discussions::get_group_member_list_changed, this, _1));
		gWrapInterface::instance().discussions_get_message.connect(boost::bind(&Discussions::get_group_message, this, _1));
	}

	Discussions::~Discussions()
	{

	}

	void Discussions::init()
	{
		if (get_parent_impl() && get_parent_impl()->bizLogin_)
		{
			get_parent_impl()->bizLogin_->conn_msm_.connected_signal_.connect(boost::bind(&Discussions::connected,this));
		}		
	}


	void Discussions::set_biz_bind_impl( anan_biz_impl* impl )
	{
		anan_biz_impl_ = impl;
	}

	void Discussions::get_group_list( Result_Data_Callback callback )
	{
		IN_TASK_THREAD_WORKx( Discussions::get_group_list, callback);

		if (had_fetch_list_)
		{
			json::jobject jobj;
			std::map<std::string, discussions_info>::iterator it;
			for (it = discussions_.begin(); it!= discussions_.end(); it++)
			{
				json::jobject data;
				data["session_id"] = it->first;
				data["group_name"] = it->second.topic;

				jobj.arr_push(data);
			}

			if (jobj.arr_size())
			{

				std::set<std::string>::iterator it = get_parent_impl()->bizRoster_->can_return_recent_.find("grouplist");
				if (it == get_parent_impl()->bizRoster_->can_return_recent_.end())
				{
					get_parent_impl()->bizRoster_->can_return_recent_.insert("grouplist");
					get_parent_impl()->bizRecent_->noticeRecentContactChanged();
				}

				if(!callback.empty())
				{

					json::jobject quit_group_jobj;
					json::jobject group_jobj;
					get_parent_impl()->bizLocalConfig_->get_quit_group_list(jobj.clone(),quit_group_jobj);
					group_jobj["quit_group_list"] = quit_group_jobj; 
					group_jobj["group_list"] = jobj;

					callback(false, XL(""), group_jobj);
					return;
				}
			}
		}

		gWrapInterface::instance().get_discussions_list(bind2f(&Discussions::get_group_list_cb,this, callback, _1,_2,_3));
	}

	void Discussions::get_group_list_cb( Result_Data_Callback callback,bool err, universal_resource reason, json::jobject data )
	{
		if (!err)
		{
			for (int i=0; i< data.arr_size(); i++)
			{
				discussions_info dinfo;
				dinfo.topic = data[i]["group_name"].get<std::string>();
				discussions_.insert(make_pair(data[i]["session_id"].get<std::string>(), dinfo));

				//更新无讨论组名称讨论组聊天记录
				get_parent_impl()->bizLocalConfig_->UpdateChatGroupName(data[i]["session_id"].get<std::string>(), dinfo.topic);
			}
		}

		had_fetch_list_ = true;

		std::set<std::string>::iterator it = get_parent_impl()->bizRoster_->can_return_recent_.find("grouplist");
		if (it == get_parent_impl()->bizRoster_->can_return_recent_.end())
		{
			get_parent_impl()->bizRoster_->can_return_recent_.insert("grouplist");
			get_parent_impl()->bizRecent_->noticeRecentContactChanged();
		}

		if (!callback.empty())
		{
			json::jobject quit_group_jobj;
			json::jobject jobj;
			get_parent_impl()->bizLocalConfig_->get_quit_group_list(data.clone(),quit_group_jobj);
			jobj["quit_group_list"] = quit_group_jobj; 
			jobj["group_list"] = data;	
			callback(err, reason, jobj);
		}	
	}

	void Discussions::create_chat_group( std::string room_name, std::vector<std::string> to_users, Result_Data_Callback callback )
	{
		IN_TASK_THREAD_WORKx(Discussions::create_chat_group, room_name, to_users, /*reason, */callback);

		gWrapInterface::instance().create_discussions(room_name, bind2f(&Discussions::create_chat_group_cb,this, room_name, to_users, callback, _1, _2, _3));
	}

	void Discussions::create_chat_group_cb( std::string room_name, std::vector<std::string> to_users, 
		Result_Data_Callback callback, bool err, universal_resource reason, json::jobject data )
	{
		if (!err)
		{
			gWrapInterface::instance().invite_discussions( data["session_id"].get<std::string>(), to_users , Result_Data_Callback());
		}


		discussions_info dinfo;
		dinfo.topic = data["group_name"].get<std::string>();
		discussions_.insert(make_pair(data["session_id"].get<std::string>(), dinfo));

		callback(err, reason, data);
	}

	void Discussions::change_chat_group_name(std::string group_chat_jid,std::string group_topic,std::string group_chat_id,std::string uid,std::string user_name,Result_Callback callback)
	{
		IN_TASK_THREAD_WORKx(Discussions::change_chat_group_name, group_chat_jid, group_topic,group_chat_id ,uid,user_name,callback);

		gWrapInterface::instance().change_discussions_name(group_chat_jid,group_topic,group_chat_id ,uid,user_name, bind2f(&Discussions::change_chat_group_name_cb,this, callback, _1, _2));
	}

	void Discussions::change_chat_group_name_cb(Result_Callback callback,bool err, universal_resource reason)
	{
		callback(err, reason);
	}

	void Discussions::invite_chat_group( std::string session_id, std::vector<std::string> to_users, Result_Data_Callback callback )
	{
		IN_TASK_THREAD_WORKx(Discussions::invite_chat_group, session_id, to_users, callback);

		gWrapInterface::instance().invite_discussions( session_id, to_users , callback);
	}

	void Discussions::get_chat_group_member_list(std::string session_id, boost::function<void(bool err, universal_resource reason, json::jobject data,std::string group_name)> callback)
	{
		IN_TASK_THREAD_WORKx(Discussions::get_chat_group_member_list, session_id, callback);

		gWrapInterface::instance().get_discussions_memberlist(session_id, bind2f(&Discussions::get_chat_group_member_list_cb, this, session_id, callback, _1, _2, _3));
	}

	void Discussions::get_chat_group_member_list_cb( std::string session_id, boost::function<void(bool err, universal_resource reason, json::jobject data,std::string group_name)> callback, 
		bool err, universal_resource reason, json::jobject data )
	{
		std::map<std::string, discussions_info>::iterator it = discussions_.find(session_id);
		std::string group_name;
		if (it!= discussions_.end())
		{
			group_name = it->second.topic;
		}

		if (!err)
		{
			data = build_member_info(data);
		}

		callback(err, reason, data,group_name);
	}

	void Discussions::syncdown_head_image(json::jobject jobj, std::string field_name, std::string uri_string)
	{
		if (uri_string.empty())
		{
			return;
		}
		boost::function<void(bool,std::string)> callback = boost::bind(&Discussions::finished_syncdown_image, this, jobj, field_name, _1, _2);
		std::string download_path = file_manager::instance().from_uri_to_path(uri_string);
		epius::http_requests::instance().download(anan_config::instance().get_http_down_path(), download_path, uri_string, "", boost::function<void(int)>(), callback);
	}

	void Discussions::finished_syncdown_image(json::jobject jobj,std::string field_name,bool succ,std::string uri_string)
	{
		IN_TASK_THREAD_WORKx(Discussions::finished_syncdown_image, jobj, field_name, succ, uri_string);

		if (succ) {
			std::string local_path = file_manager::instance().from_uri_to_path(uri_string);
			json::jobject update_jobj;
			update_jobj["jid"] = jobj["jid"].get<std::string>();
			update_jobj[field_name] = local_path;
			update_head(update_jobj);
		}
		else
		{
			json::jobject update_jobj;
			update_jobj["jid"] = jobj["jid"].get<std::string>();
			update_jobj[s_VcardSexShow] = jobj[s_VcardSex].get<std::string>();
			update_jobj[s_VcardIdentityShow] = jobj[s_VcardIdentity].get<std::string>();
			update_jobj[field_name] = "";
			update_head(update_jobj);
		}
	}

	void Discussions::quit_chat_group( std::string session_id, std::string uid, Result_Data_Callback callback )
	{
		IN_TASK_THREAD_WORKx(Discussions::quit_chat_group, session_id, uid,  callback);

		gWrapInterface::instance().quit_discussions(session_id, uid, bind2f(&Discussions::quit_chat_group_cb, this, session_id, callback, _1, _2, _3));
	}

	void Discussions::quit_chat_group_cb( std::string session_id, Result_Data_Callback callback, bool err, universal_resource reason, json::jobject data )
	{
		if (!err)
		{
			std::map<std::string, discussions_info>::iterator it = discussions_.find(session_id);
			if (it!= discussions_.end())
			{
				//删除缓存前通知页面删除讨论组列表
				json::jobject jobj;
				jobj["type"] = "remove";
				json::jobject data;
				data["session_id"] = it->first;
				jobj["group_info"].arr_push(data);
				event_collect::instance().chat_group_list_changed(jobj.clone());

				discussions_.erase(it);
			}
		}
		callback(err, reason, data);
	}

	void Discussions::connected()
	{
		//上线后重新取讨论组列表
		clear_chat_group();
		had_fetch_list_ = false;
	}
	void Discussions::clear_chat_group()
	{
		discussions_.clear();
	}

	void Discussions::get_group_list_changed( json::jobject jobj )
	{
		int i;
		if (jobj["type"].get<std::string>().compare("remove") == 0 ||
			jobj["type"].get<std::string>().compare("destroy") == 0)
		{
			for(i=0; i < jobj["group_info"].arr_size(); i++)
			{
				std::string session_id = jobj["group_info"][i]["session_id"].get<std::string>();
				std::map<std::string, discussions_info>::iterator it = discussions_.find(session_id);
				if (it!=discussions_.end())
				{
					jobj["group_info"][i]["group_name"] = it->second.topic;
					discussions_.erase(it);
				}
			}
		}else if (jobj["type"].get<std::string>().compare("modify") == 0 )
		{
			std::string session_id = jobj["id"].get<std::string>();
			std::map<std::string, discussions_info>::iterator it = discussions_.find(session_id);
			if (it!=discussions_.end())
			{
				it->second.topic = jobj["topic"].get<std::string>();
			}
		}
		else if (jobj["type"].get<std::string>().compare("add") == 0)
		{
			for(i=0; i < jobj["group_info"].arr_size(); i++)
			{
				discussions_info dinfo;
				dinfo.topic = jobj["group_info"][i]["group_name"].get<std::string>();
				discussions_.insert(make_pair(jobj["group_info"][i]["session_id"].get<std::string>(), dinfo));
			}
		}

		event_collect::instance().chat_group_list_changed(jobj.clone());
	}

	void Discussions::get_group_member_list_changed( json::jobject jobj )
	{
		//如果更新类型不是remove
		if (jobj["type"].get<std::string>().compare("remove"))
		{
			jobj["member_info"] = build_member_info(jobj["member_info"]);
		}

		event_collect::instance().chat_group_member_changed(jobj.clone());
	}

	void Discussions::do_get_group_message()
	{
		if(msg_queue_.empty())return;
		json::jobject jobj = msg_queue_.front();
		msg_queue_.pop_front();

		std::string jid = jobj["jid"].get<std::string>();
		if (jid.empty() || jid==get_parent_impl()->bizUser_->get_userName())
		{
			return;
		}

		jid += "@";
		jid += app_settings::instance().get_domain();

		std::string group_name;
		if (had_fetch_list_)
		{
			//get discussion topic
			std::map<std::string, discussions_info>::iterator it = discussions_.find(jobj["from"].get<std::string>());
			if (it!= discussions_.end())
			{
				group_name = it->second.topic;
			}
			else
			{
				ELOG("app")->error(WCOOL(L"收到讨论组会话消息 但查找不到相应讨论组信息 session_id : ") + jobj["from"].get<std::string>());
				return;
			}
		}
		json::jobject msg_html_jobj(jobj["html"].get<std::string>());
		if (!msg_html_jobj.is_nil("image_ready") || !msg_html_jobj.is_nil("voice_ready")){
			return;
		}

		//讨论组会话祛重
		if (get_parent_impl()->bizLocalConfig_->isChatGroupMessageExist(jobj["from"].get<std::string>(), jid, jobj["id"].get<std::string>()))
		{
			ELOG("app")->error(WCOOL(L"收到讨论组会话消息 但此消息已经接收过 session_id : ") + jobj["from"].get<std::string>() + 
				" msg :" + jobj["html"].get<std::string>() + " id : " + jobj["id"].get<std::string>());
			return;
		}


		//取 showname
		ContactMap::iterator itvcard = get_parent_impl()->bizRoster_->syncget_VCard(jid);
		std::string show_name;
		if (itvcard != get_parent_impl()->bizRoster_->impl_->vcard_manager_.end()){
			std::set<std::string>::iterator it_req = get_parent_impl()->bizRoster_->requestVcard_jids_.find(jid);
			if (it_req != get_parent_impl()->bizRoster_->requestVcard_jids_.end())
			{
				show_name = WS2UTF(L"微哨用户");
			}
			else
			{
				KContactType ct = get_parent_impl()->bizRoster_->is_my_friend_(jid);
				if (ct != kctNone)
				{
					show_name =itvcard->second.get_vcardinfo()[s_VcardShowname].get<std::string>();
				}
				else
				{
					show_name = itvcard->second.get_vcardinfo()[s_VcardName].get<std::string>();
				}
			}
			
		}
		else{
			ELOG("app")->error(WCOOL(L"addgetRequestVCardWait 讨论组没有找到会话人的名片 session_id : ") + jid + " msg_queue_ size: " + lexical_cast<std::string>(msg_queue_.size()));
			get_parent_impl()->bizRoster_->addgetRequestVCardWait(jid, S10nNone, vard_type_full, bind_s(&AnRosterManager::updateMessageShowname, get_parent_impl()->bizRoster_, jid, _1));
			get_parent_impl()->bizRoster_->requestVcard_jids_.insert(jid);
			show_name = WS2UTF(L"微哨用户");
		}

		json::jobject msg(jobj["html"].get<std::string>());
		get_parent_impl()->bizLocalConfig_->saveChatGroupMessage(group_name, jobj["from"].get<std::string>(), jid, show_name, msg,
			jobj["id"].get<std::string>(), false);
		get_parent_impl()->bizRoster_->UpdateRecentContact(jobj["from"].get<std::string>() , kRecentMUC);
		event_collect::instance().recv_session_msg(jobj["from"].get<std::string>(), jid, show_name, msg.to_string());
		get_parent_impl()->_p_private_task_->post(bind2f(&Discussions::do_get_group_message, this));

	}
	void Discussions::get_group_message( json::jobject jobj )
	{
		msg_queue_.push_back(jobj);
		do_get_group_message();
	}
	std::string Discussions::get_group_name(std::string session_id)
	{
		std::map<std::string, discussions_info>::iterator it = discussions_.find(session_id);
		if (it!= discussions_.end())
		{
			return it->second.topic;
		}
		return "";
	}
	std::string Discussions::send_msg( std::string session_id, std::string const& txt_msg, std::string const& msg )
	{
		//get discussion topic
		std::map<std::string, discussions_info>::iterator it = discussions_.find(session_id);
		std::string group_name;
		if (it!= discussions_.end())
		{
			group_name = it->second.topic;
		}
		else
		{
			ELOG("app")->error(WCOOL(L"发送讨论组会话消息 但查找不到相应讨论组信息 session_id : ") + session_id);
			return group_name;
		}

		gWrapInterface::instance().send_msg(session_id, txt_msg, msg);

		return group_name;
	}

	json::jobject Discussions::build_member_info( json::jobject jobj )
	{
		//获取vcard信息
		for (int i=0; i< jobj.arr_size(); i++)
		{
			// 判断显示姓名规则：
			// 1. 可以在vcard中找到，使用vcard中的showname
			// 2. 找不到，显示服务端返回的姓名
			ContactMap::iterator itvcard = get_parent_impl()->bizRoster_->syncget_VCard(jobj[i]["jid"].get<std::string>());
			std::string show_name;
			if (itvcard != get_parent_impl()->bizRoster_->impl_->vcard_manager_.end()){
				KContactType ct = get_parent_impl()->bizRoster_->is_my_friend_(jobj[i]["jid"].get<std::string>());
				if (ct != kctNone)
				{
					show_name = itvcard->second.get_vcardinfo()[s_VcardShowname].get<std::string>();
				}
				else
				{
					show_name = itvcard->second.get_vcardinfo()[s_VcardName].get<std::string>();
				}
				jobj[i][s_VcardShowname] = show_name;
			}

			// 性别和身份 需要转译
			if (jobj[i][s_VcardSex])
			{
				if (!jobj[i][s_VcardSex].get<std::string>().empty())
				{
					jobj[i][s_VcardSexShow] = XL(jobj[i][s_VcardSex].get<std::string>()).res_value_utf8;
				}
			}
			if (jobj[i][s_VcardIdentity])
			{
				if (!jobj[i][s_VcardIdentity].get<std::string>().empty())
				{
					jobj[i][s_VcardIdentityShow] = XL(jobj[i][s_VcardIdentity].get<std::string>()).res_value_utf8;
				}
			}			

			// 下载个性图片
			if (jobj[i][s_VcardHeadURI])
			{
				if (!jobj[i][s_VcardHeadURI].get<std::string>().empty())
				{
					jobj[i][s_VcardHead] = "";
					std::string uri_string = jobj[i][s_VcardHeadURI].get<std::string>();
					std::string local_string;
					if(!uri_string.empty())
					{
						local_string = biz::file_manager::instance().from_uri_to_valid_path(uri_string);
						if (local_string.empty())
						{
							syncdown_head_image(jobj[i], s_VcardHead, uri_string);
						}else{
							jobj[i][s_VcardHead] = local_string;
						}
					}
				}
			}			
		}		
		return jobj;
	}

	bool Discussions::is_group_exist( std::string session_id )
	{
		return discussions_.find(session_id) != discussions_.end();
	}

	void Discussions::search_local_discussions( std::string filterString, json::jobject& jobj )
	{
		if (filterString.empty())
		{
			return;
		}
		std::map<std::string, discussions_info>::iterator it;
		for (it = discussions_.begin(); it!= discussions_.end(); it++)
		{
			std::string name = it->second.topic;
			if(name.empty())
			{
				continue;
			}
			// 执行匹配。
			_MatchEach(jobj,filterString,name,it->first,"");
		}
	}

	void Discussions::_MatchEach( json::jobject& jobj, const std::string& filterString, const std::string& name, const std::string session_id, std::string head_uri)
	{
		if (eplocal_find::instance().match(filterString,name))
		{
			fireMatch(jobj, session_id, name, head_uri);
		}
	}

	void Discussions::fireMatch( json::jobject& jobj, std::string session_id, std::string name, std::string head_uri)
	{
		jobj[session_id][s_VcardJid] = session_id;
		jobj[session_id][s_VcardShowname] = name;
		jobj[session_id][s_VcardHead] = head_uri;
		jobj[session_id]["type"] = message_group_chat;
	}

	void Discussions::get_group_list2( std::vector<std::string>& group_list )
	{
		std::map<std::string, discussions_info>::iterator it = discussions_.begin();
		for (; it!=discussions_.end();it++)
		{
			group_list.push_back(it->first);
		}
	}

}

