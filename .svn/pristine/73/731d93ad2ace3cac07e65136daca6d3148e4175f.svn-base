#pragma once
#include "boost/function.hpp"
#include "biz_groups.h"
#include "gloox_src/rostermanager.h"
#include "gloox_src/privacymanager.h"
#include "boost/assign/list_of.hpp"
#include "an_roster_manager_type.h"
#include <map>
#include <string>
#include <list>
#include <set>
#include "client_anan.h"

namespace biz {

	using namespace gloox;

	const KContactType sContactTypeTransTable[] = {kctNone,kctNone,kctNone,kctNone,kctContact,kctContact,kctStranger,kctStranger,kctContact};
	const KPresenceType sPresenceTypeTransTable[] = {kptOnline, kptOnline, kptAway, kptBusy, kptAway, kptOffline, kptInvisible, kptOffline, kptInvisible,kptOffline};

	struct AnRosterManagerImpl 
	{
		AnRosterManagerImpl(AnClient* parent)
			:vPrivacy_(new PrivacyManager( parent ))
		{
		}

		virtual ~AnRosterManagerImpl()
		{
			delete vPrivacy_;
			vPrivacy_ = NULL;
		}
		std::map<std::string, boost::function<void(const std::list<std::string>&)> > map_callback_vec;
		std::map<std::string /* jid */, int /*count*/ > mapHead_;
		
		UICallbackByJid mapIqIdAndSeqID;
		ContactMap vcard_manager_;
		std::map<std::string, json::jobject> buildShowNameTask_;
		PrivacyManager *vPrivacy_;
		PrivacyListHandler::PrivacyList privacyList_;
		//保存右键名称显示选项标志 nick_name name remark_name
		std::string show_name;
	};

};