#pragma once
#include <base/utility/linkedhashmap/linkedhashmap.hpp>
#include "roster_type.h"
#include "biz_presence_type.h"
#include <string>
#include <map>
#include <list>
#include <time.h>
namespace biz 
{
	enum KRecentJIDType
	{
		kRecentContact,
		kRecentCrowd,
		kRecentMUC,
		KRecentLightApp,
		kRecentInvalid
	};
	typedef std::list<std::pair<std::string, KRecentJIDType> > RecentRoster;

	enum KRosterNoticeType
	{
		krntAdd,
		krntRemove,
		krntUpdate
	};

	enum KRosterNoticeAdditionType
	{
		krntAdd_none,
		krntAdd_new,
		krntAdd_me,
		krntAdd_newme
	};

	struct TContactNoteInfo
	{
		TContactNoteInfo()
		{
			fetch_done_ = false;
			presence = kptInvalid;
		};

		void clearStatus()
		{
			presence = kptOffline;
		}

		bool fetch_done_;
		int subscription;
		json::jobject raw_vcardinfo;
		json::jobject storeinfo;
		whistle_vcard_type the_vcard_type;
		json::jobject& get_vcardinfo() { return raw_vcardinfo; };
		json::jobject& get_storeinfo() { return storeinfo;};
		KPresenceType presence;
	};

	#define ContactMapItem std::pair<std::string /*jid*/, TContactNoteInfo>
	#define ContactMap std::map<std::string /*jid*/, TContactNoteInfo >

	enum { k_jid_presence_item, k_online_counter};
	typedef std::list<std::string> StringList;
	typedef std::map<std::string,KPresenceType> JidPresenceMap;
	typedef boost::tuple<JidPresenceMap,int> JidPresenceItem;
	typedef epius::linkedhashmap<std::string, JidPresenceItem > contact_tree_map;

	typedef boost::function<void(std::string /*filterString*/, json::jobject)> FilterJsonCallback;
	typedef std::map<std::string, UIVCallback > UICallbackByJid;

	enum KbizRosterMgrError
	{
		kbizRosterMgrError_NoError=0,
		kbizRosterMgrError_GroupNameNotExists,
		kbizRosterMgrError_ContactNameNotExists,
		kbizRosterMgrError_IOError,
		kbizRosterMgrError_
	};

	#define XLVU(x) XL((x)).res_value_utf8

}; // biz