#include <base/tcpproactor/TcpProactor.h>
#include <base/utility/linkedhashmap/linkedhashmap.hpp>
#include "base/utility/bind2f/bind2f.hpp"
#include <base/json/tinyjson.hpp>
#include <base/json/json_algorithm.hpp>
#include "biz_groups.h"
#include "anan_biz_bind.h"
#include "anan_biz_impl.h"
#include "biz_groups_type.h"
#include "biz_groups_impl.h"
#include "boost/lexical_cast.hpp"
#include "gloox_src/rostermanager.h"
#include "login.h"
#include "gloox_src/gloox.h"
#include "user.h"
#include "user_impl.h"
#include "an_roster_manager.h"
#include "client_anan.h"
#include "gloox_src/rosterlistener.h"
#include "biz_recent_contact.h"
#include "an_roster_manager_type.h"
#include "anan_private.h"
#include "local_config.h"
#include "discussions.h"
#include "crowd.h"
namespace biz
{

	static const std::string PRIVATE_RECENT_CONTACT = "private::recent";
	static const unsigned int MAX_RECENT_CONTACT_COUNT = 20;
	static const char* const s_recentContactTranslation[] = {"kRecentContact", "kRecentCrowd", "kRecentMUC", "kRecentLightapp"};

	struct Tbiz_recent_contactImpl	
	{
		RecentRoster recentRoster_;
	};

biz_recent_contact::biz_recent_contact(void)
	: impl_(new Tbiz_recent_contactImpl())
{
}


biz_recent_contact::~biz_recent_contact(void)
{
}

void biz_recent_contact::regist_to_gloox( Client* p_client )
{
	get_parent_impl()->bizLogin_->conn_msm_.connected_signal_.connect(boost::bind(&biz_recent_contact::connected,this));
}

void biz_recent_contact::unregist_to_gloox( Client* p_client )
{
	get_parent_impl()->bizLogin_->conn_msm_.connected_signal_.disconnect(&biz_recent_contact::connected);
}

void biz_recent_contact::listRecentContact(JsonCallback callback)
{
	IN_TASK_THREAD_WORKx(biz_recent_contact::listRecentContact, callback);
	
	json::jobject jobj;
	BuildRecentContactJson(jobj);
	if (!callback.empty())
	{
		callback(jobj);
	}		
}

static bool erase_discussion_crowd(json::jobject jvalue){
	if(jvalue["type"].get()== "kRecentMUC"){
		if ( !g_discussions::instance().is_group_exist( jvalue["jid"].get()))
		{
			return true;
		}
	}
	else if(jvalue["type"].get()== "kRecentCrowd")
	{
		if ( !g_crowd::instance().is_crowd_exist( jvalue["jid"].get()))
		{
			return true;
		}
	}

	return false;
}

void biz_recent_contact::BuildRecentContactJson(json::jobject& jobj)
{
	RecentRoster::iterator it_tmp;
	epius::linkedhashmap<std::string, KRecentJIDType> remove_dup;
	for(it_tmp=impl_->recentRoster_.begin();it_tmp!=impl_->recentRoster_.end();++it_tmp)
	{
		remove_dup[it_tmp->first] = it_tmp->second;
	}
	impl_->recentRoster_.clear();
	for(epius::linkedhashmap<std::string, KRecentJIDType>::iterator it = remove_dup.begin();it!=remove_dup.end();++it)
	{
		impl_->recentRoster_.push_back(make_pair(it->first, it->second));
	}
	it_tmp = impl_->recentRoster_.begin();
	for (int i=0; it_tmp !=impl_->recentRoster_.end(); ++it_tmp,++i)
	{
		std::pair<std::string, KRecentJIDType>& item = *it_tmp;
		jobj[i]["jid"] = item.first;
		jobj[i]["type"] = s_recentContactTranslation[item.second];
	}

	//删除已经退出的讨论组和群
	while(jobj.erase_if(bind2f(&erase_discussion_crowd, _1)));
}

KRecentJIDType biz_recent_contact::RPaserRecentContactType(std::string typeString)
{
	for(int i=0; i<sizeof(s_recentContactTranslation)/sizeof(s_recentContactTranslation[0]); ++i)
	{
		if ( typeString == s_recentContactTranslation[i] )
		{
			return (KRecentJIDType)i;
		}
	}
	return kRecentInvalid;
}

void biz_recent_contact::PaserRecentContactJson(json::jobject& jobj)
{
	impl_->recentRoster_.clear();
	std::string jid_full = get_parent_impl()->bizClient_->jid().full();
	for(int i = 0; i < jobj.arr_size(); ++i) 
	{
		std::pair<std::string, KRecentJIDType> item;
		item.first = jobj[i]["jid"].get<std::string>();
		KRecentJIDType type = RPaserRecentContactType(jobj[i]["type"].get<std::string>());
		if (type == kRecentInvalid || jid_full == item.first)
		{
			continue;
		}
		item.second = type;
		impl_->recentRoster_.push_back(item);
	}
}

void biz_recent_contact::UploadRecentContact()
{
	json::jobject jobj;
	BuildRecentContactJson(jobj);
	
	get_parent_impl()->bizAnanPrivate_->store_data(PRIVATE_RECENT_CONTACT, jobj, boost::function<void(bool)>());
}

void biz_recent_contact::UpdateRecentContact(std::string jid_string, KRecentJIDType type)
{

	for (RecentRoster::iterator it = impl_->recentRoster_.begin(); it != impl_->recentRoster_.end(); ++it)
	{
		if (jid_string != it->first)
		{
			continue;
		}
		if (impl_->recentRoster_.begin() == it)
		{
			return;
		}
		else
		{
			impl_->recentRoster_.erase(it);
			break;
		}		
	}

	impl_->recentRoster_.push_front(std::make_pair(jid_string,type));

	while (impl_->recentRoster_.size() > MAX_RECENT_CONTACT_COUNT)
	{
		impl_->recentRoster_.pop_back();
	}

//PC端使用 漫游的最近联系人列表
#ifdef _WIN32
	noticeRecentContactChanged();
#endif
}

#ifndef _WIN32
void biz_recent_contact::removeSystemRecentContact(UIVCallback callback)
{
	//IN_TASK_THREAD_WORKx(biz_recent_contact::removeSystemRecentContact, callback);
	if(get_parent_impl()->bizLocalConfig_->deleteSystemRecentContact()){

		if (!callback.empty())
			callback(false, XL(""));
	}else{

		if (!callback.empty())
			callback(true, XL("biz.failed.delete.recent.systemcontact"));
		
	}


}
#endif

void biz_recent_contact::removeRecentContact( std::string jid_string, UIVCallback callback )
{
	IN_TASK_THREAD_WORKx(biz_recent_contact::removeRecentContact, jid_string, callback);

	for (RecentRoster::iterator it = impl_->recentRoster_.begin(); it != impl_->recentRoster_.end(); ++it)	
	{
		if (jid_string != it->first)
		{
			continue;
		}
		impl_->recentRoster_.erase(it);

		//从user.dat中删除
		if(get_parent_impl()->bizLocalConfig_->deleteRecentContact(jid_string)){
			noticeRecentContactChanged();

			if (!callback.empty())
				callback(false, XL(""));
			return;
		}
		break;
	}

	if (!callback.empty())
		callback(true, XL("biz.failed.delete.recent.contact"));
}

void biz_recent_contact::noticeRecentContactChanged()
{
	if (get_parent_impl()->bizRoster_->can_return_recent_.size() != 3)
	{
		return;
	}
	json::jobject jobj;
	BuildRecentContactJson(jobj);
	event_collect::instance().recv_recent_contact(jobj);
}

void biz_recent_contact::queryRecentContact_callback(json::jobject jobj)
{
	impl_->recentRoster_.clear();
	if (!jobj.arr_size())
		return;

	PaserRecentContactJson(jobj);
	noticeRecentContactChanged();
}

void biz_recent_contact::connected()
{
	//PC端使用 漫游的最近联系人列表
#ifdef _WIN32
	get_parent_impl()->bizAnanPrivate_->get_data(PRIVATE_RECENT_CONTACT,bind2f(&biz_recent_contact::queryRecentContact_callback, this, _1));
#else
	get_parent_impl()->bizLocalConfig_->loadRecentContact(impl_->recentRoster_);
#endif
}

}; // biz