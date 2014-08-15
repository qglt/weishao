#pragma once
#include <map>
#include "anan_type.h"
#include "gloox_src/stanzaextension.h"
#include "iq_filter.h"

namespace biz 
{
	using namespace gloox;

	enum KOrgMapTuple 
	{
		kot_tree_type,
		kot_timestamp,
		kot_query_type,
		kot_parent_id,
		kot_callback
	};

#define TREE_TYPE_ORG "organization"
#define TREE_TYPE_NOTICE "notice"

	typedef std::map<int, boost::tuple<std::string, std::string, query_organization::KOrg_query_type, std::string, JsonCallback> > OrgMapJsonCallback;

	struct organization_impl
	{
		organization_impl()
		{
			finished_ = false;
			autoinc_context_ = 0;
		}
		bool finished_;

		int autoinc_context_;
		OrgMapJsonCallback callback_;

		/*
		m_store_org 用于缓存从服务端取回的组织结构数据
		其结构形式如下：
		m_store_org[pid]["user"]= []; 数组的每个成员包括： {type:"user", name:"", status:"Online/Offline", jid:"", identity:"teacher/student",sex:""}
		m_store_org[pid]["organization"]= []; 数组的每个成员包括：   {type:"organization", id:"", parent_id:"",name:""}
		m_store_org[pid]["last_time"] = 上次从服务端取数据的时间。
		将来扩展可以把该缓存写入本地数据库，启动时候加载，根据上次取服务的时间，决定下次什么时候再取。
		*/
		json::jobject m_store_org;
	};

}; // namespace biz