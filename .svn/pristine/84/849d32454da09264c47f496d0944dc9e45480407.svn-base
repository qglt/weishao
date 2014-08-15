#include <base/tcpproactor/TcpProactor.h>
#include "boost/lexical_cast.hpp"
#include "user.h"
#include "user_impl.h"
#include "anan_biz_impl.h"
#include "anan_assert.h"
#include "an_roster_manager.h"
#include "gloox_wrap/glooxWrapInterface.h"
#include "client_anan.h"
#include "anan_biz_bind.h"
#include "login.h"
#include "an_roster_manager_impl.h"
#include "local_config.h"
#include "notice_msg_ack.h"
#include "agent.h"
#include "agent_impl.h"
#include "anan_config.h"
#include <base/utility/bind2f/bind2f.hpp>
#include "base/epiusdb/ep_sqlite.h"
#include "gloox_wrap/basicStanza.hpp"
#include "gloox_wrap/UserStanzaExtensionType.h"
#include "thread_id.h"

namespace biz {

static const Presence::PresenceType s_gloox_presencetype[] = {	Presence::Available,Presence::Away,Presence::DND,Presence::Unavailable,Presence::Unavailable,Presence::Unavailable,Presence::Invisible};

user::user(void) : impl_(new user_impl())
{
}

user::~user(void)
{
}

void user::inner_set_presence(KPresenceType presence)
{
	impl_->user_.presence = presence;
	get_parent_impl()->bizClient_->setPresence( s_gloox_presencetype[presence], 0, "");	
}

user::KUser_presence_scheme user::switch_scheme_by_login_state()
{	
	CONN_STATE state = get_parent_impl()->bizLogin_->conn_msm_.getCurrentState();
	switch(state)
	{
	case CONN_DISCONNECTED:
		return kups_by_logon;
	case CONN_CONNECTING:
		return kups_do_nothing;
	case CONN_CONNECTED:
		return kups_direct_do;		
	default:
		return kups_do_nothing;
	}

}

void user::set_Presence(KPresenceType presence)
{
	IN_TASK_THREAD_WORKxo((void (user::*)(KPresenceType))(&user::set_Presence),presence);

	switch(switch_scheme_by_login_state())
	{
	default:
		assert(false);
	case kups_do_nothing:
		break;
	case kups_by_logon:
		get_parent_impl()->bizLogin_->to_logon(presence);
		break;
	case kups_direct_do:
		inner_set_presence(presence);
		get_parent_impl()->bizRoster_->updateSelfPrsenceToJson(false);
		notice_presence();
		break;
	}
}

void user::regist_to_gloox( AnClient* p_client )
{
	impl_->m_p_private_xml = new PrivateXML(p_client);
	get_parent_impl()->bizLogin_->conn_msm_.connected_signal_.connect(boost::bind(&user::connected,this));
	get_parent_impl()->bizLogin_->conn_msm_.disconnected_signal_.connect(boost::bind(&user::disconnection, this, _1));
}

void user::store_data(std::string private_ns, std::string str, PrivateXMLHandler* callback)
{
    IN_TASK_THREAD_WORKx(user::store_data, private_ns, str, callback);
    Tag query_groups( "query", XMLNS, private_ns);
    Tag elem("pdata", str);
    query_groups.addChild(elem.clone());
    impl_->m_p_private_xml->storeXML(query_groups.clone(), callback);
}

void biz::user::get_data( std::string private_ns, PrivateXMLHandler* callback )
{
    IN_TASK_THREAD_WORKx(user::get_data, private_ns, callback);
    impl_->m_p_private_xml->requestXML("anan", private_ns, callback);
}

void biz::user::set_Presence(std::string msg /*=""*/)
{
	IN_TASK_THREAD_WORKxo((void (user::*)(std::string))(&user::set_Presence), msg);

	get_parent_impl()->bizClient_->setPresence( s_gloox_presencetype[impl_->user_.presence], 0, msg);
	//给自己发送一个重复的presence用于多设备同步	
	gloox::Tag* threadid = new gloox::Tag("ext_threadid");
	threadid->addCData(thread_id::instance().gen_id());
	typedef BasicStanza<kExtUser_presence_filter_threadid> presence_filter_threadid;
	get_parent_impl()->bizClient_->addPresenceExtension(new presence_filter_threadid(threadid, ""));
	get_parent_impl()->bizClient_->setPresence( get_parent_impl()->bizClient_->jid().bareJID(), s_gloox_presencetype[impl_->user_.presence], 0, msg);
	get_parent_impl()->bizClient_->removePresenceExtension(kExtUser_presence_filter_threadid);

	get_parent_impl()->bizRoster_->updateSelfPrsenceToJson();
}

void user::unregist_to_gloox( AnClient* p_client )
{
	if (impl_->m_p_private_xml)
	{
		delete impl_->m_p_private_xml;
		impl_->m_p_private_xml = NULL;
	}
	get_parent_impl()->bizLogin_->conn_msm_.connected_signal_.disconnect(&user::connected);
	get_parent_impl()->bizLogin_->conn_msm_.disconnected_signal_.disconnect(&user::disconnection);
}

void user::notice_presence()
{
	std::string jid_string = get_parent_impl()->bizClient_->jid().bare();
	// 向UI发出自己的出席状态
	event_collect::instance().recv_presence(jid_string,(KPresenceType)impl_->user_.presence,json::jobject());

	RosterItem* item = get_parent_impl()->bizRoster_->getRosterItem(get_parent_impl()->bizClient_->jid().bareJID());
	if (!item)
	{
		return;
	}
	get_parent_impl()->bizRoster_->updatePresenceToVCard(*item, anan_config::instance().get_client_type(), get_parent_impl()->bizClient_->presence().subtype()) ;
}

void user::connected()
{
	notice_presence();
}


void user::disconnection(universal_resource res)
{
	// 如果登入8秒内退出， 需要保存没有处理的离线聊天记录
	epius::epius_sqlite3::epDbAutoCreate* cur_epdb = db_connection::instance().get_db(s_userHistoryName);
	if(cur_epdb)
	{
		boost::shared_ptr<epius::epius_sqlite3::epDbTrans> trans = cur_epdb->beginTrans();
		get_parent_impl()->bizClient_->do_process_hanlded_message();
	}

	std::string jid_string = get_parent_impl()->bizClient_->jid().bare();
	// 向UI发出自己的出席状态
	event_collect::instance().recv_presence(jid_string, kptOffline, json::jobject());
}


biz::KPresenceType user::syncquery_MyPresence()
{
	return sPresenceTypeTransTable[get_parent_impl()->bizClient_->presence().subtype()];
}

std::string user::get_userName() const
{
	return impl_->user_.user_id;
}

void user::loadNoticeMessage(int offset, int count,boost::function<void(json::jobject)> callback )
{
	IN_TASK_THREAD_WORKx(user::loadNoticeMessage,offset,count,callback);
	if (!callback.empty())
	{
		json::jobject jobj = get_parent_impl()->bizLocalConfig_->LoadDescNoticeMessage(offset,count);		
		callback(jobj);
	}
}

void user::loadOneNoticeMessage(std::string id_string,boost::function<void(json::jobject)> callback )
{
	IN_TASK_THREAD_WORKx(user::loadOneNoticeMessage,id_string,callback);
	if (!callback.empty())
	{
		json::jobject jobj = get_parent_impl()->bizLocalConfig_->LoadOneNoticeMessage(id_string);
		callback(jobj);
	}
}

void user::loadMessage( std::string type_string, std::string id_string, int offset, int count, boost::function<void(json::jobject)> callback )
{
	IN_TASK_THREAD_WORKx(user::loadMessage, type_string, id_string, offset, count, callback);
	
	if (!callback.empty())
	{
		json::jobject jobj;
		get_parent_impl()->bizLocalConfig_->LoadMessage(type_string, id_string, offset, count, jobj);
		callback(jobj);
	}
}

//查看发送历史消息
void user::loadpublishMessage(std::string id_string,boost::function<void(json::jobject)> callback )
{
	IN_TASK_THREAD_WORKx(user::loadpublishMessage,id_string,callback);
	if (!callback.empty())
	{
		json::jobject jobj;
		get_parent_impl()->bizLocalConfig_->LoadpublishMessage(id_string,jobj);
		jobj["myinfo"] = json::jobject();
		std::string myJid = get_parent_impl()->bizClient_->jid().bare();
		ContactMap::iterator itvcard = get_parent_impl()->bizRoster_->syncget_VCard(myJid);
		if (itvcard != get_parent_impl()->bizRoster_->impl_->vcard_manager_.end())
		{
			jobj["myinfo"] = itvcard->second.get_vcardinfo().clone();
		}
		callback(jobj);
	}
}


void user::loadUnReadMessage( std::string type_string, std::string id_string, bool mark_read, boost::function<void(json::jobject)> callback )
{
	IN_TASK_THREAD_WORKx(user::loadUnReadMessage, type_string, id_string, mark_read, callback);

	if (!callback.empty())
	{
		json::jobject jobj;
		get_parent_impl()->bizLocalConfig_->LoadMessage(type_string, id_string, -1, -1, jobj, kmrs_recv);
		//查找jobj中的jid相关的showname 替换成现在内存中的showname		
		if (jobj["type"].get<std::string>() == "conversation")
		{
			for (int j = 0;j < jobj["data"].arr_size();j++)
			{
				std::string jid = jobj["data"][j]["jid"].get<std::string>();
				ContactMap::iterator itvcard;
				itvcard = get_parent_impl()->bizRoster_->syncget_VCard(jid);
				std::string show_name;
				if (itvcard != get_parent_impl()->bizRoster_->impl_->vcard_manager_.end())
				{
					show_name = itvcard->second.get_vcardinfo()["showname"].get<std::string>();
					jobj["data"][j]["showname"] = show_name;
				}				
			}
		}	
		callback(jobj);
	}
	if (mark_read) 
	{
		MarkMessageRead(type_string, id_string);
	}
}

void user::MarkMessageRead(std::string type_string, std::string id_string)
{
	IN_TASK_THREAD_WORKx(user::MarkMessageRead, type_string, id_string );

	if (type_string == message_notice) 
	{
		if (!id_string.empty()) 
		{
			get_parent_impl()->bizLocalConfig_->MarkOneNoticeAsRead(id_string);
		}
	}
	else 
	{
		get_parent_impl()->bizLocalConfig_->MarkMessageRead(type_string, id_string);
	}
}

void user::loadUnReadMessageCount(boost::function<void(json::jobject)> callback )
{
	IN_TASK_THREAD_WORKx(user::loadUnReadMessageCount, callback);

	if (!callback.empty())
	{
		json::jobject jobj;
		get_parent_impl()->bizLocalConfig_->LoadUnreadMessageCount(jobj);
		
		for (int j = 0;j < jobj["data"].arr_size();j++)
		{
			if (jobj["data"][j]["type"].get<std::string>() == "conversation")
			{
				std::string jid = jobj["data"][j]["jid"].get<std::string>();
				ContactMap::iterator itvcard;
				itvcard = get_parent_impl()->bizRoster_->syncget_VCard(jid);
				std::string show_name;
				if (itvcard != get_parent_impl()->bizRoster_->impl_->vcard_manager_.end())
				{
					show_name = itvcard->second.get_vcardinfo()["showname"].get<std::string>();
					jobj["data"][j]["showname"] = show_name;
				}			
			}					
		}

		callback(jobj);
	}
}

void user::disposeMessage( json::jobject jobj, UIVCallback callback )
{
	IN_TASK_THREAD_WORKx(user::disposeMessage, jobj, callback);

	std::string inString;
	if (jobj.arr_size()) {
		inString = " where rowid in (" + jobj[0].get<std::string>();
		for (int i=1; i<jobj.arr_size() ; ++i)
		{
			inString += "," + (boost::lexical_cast<std::string>(jobj[i].get<int>()));
		}
		inString += ");";
	}

	get_parent_impl()->bizLocalConfig_->removeMessageBy( "fakedata", inString);

	if (!callback.empty())
	{
		callback(false, XL(""));
	}
}

void user::get_privilege( boost::function<void( bool err, universal_resource res, json::jobject data)> callback)
{
	IN_TASK_THREAD_WORKx(user::get_privilege, callback);

	gWrapInterface::instance().get_privilege(callback);
}

void user::set_user( Tuser_info const& user )
{
	impl_->user_ = user;
}

Tuser_info const& biz::user::get_user()
{
	return impl_->user_;
}

}; // biz

