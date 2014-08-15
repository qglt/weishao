#pragma once
#include "boost/shared_ptr.hpp"
#include "boost/signal.hpp"
#include "base/universal_res/uni_res.h"
#include "anan_biz_bind.h"
#include "anan_type.h"
#include "roster_type.h"
#include "biz_groups_type.h"
#include "an_roster_manager_type.h"
#include <vector>
#include <string>
#include "event_collection.h"

namespace gloox { class Client;};

namespace biz
{
	struct TBizGroupsImpl;
	struct anan_biz_impl;

	using namespace gloox;

	typedef std::pair<std::string /*jid*/, std::string /*name*/> JIDRemarkItem;
	typedef std::list<JIDRemarkItem> JIDRemarkList;

class BizGroups : public anan_biz_bind<anan_biz_impl>
{
	BIZ_FRIEND();
public:
	BizGroups(void);
	virtual ~BizGroups(void);

public:
	// 登录成功后，收到组列表
	boost::signal< void( std::list<std::string>) > recv_groups;

public:
	void addGroup(std::string seqID, std::string groupName, std::string beforegroupName);
	void moveGroup(std::string seqID,std::string groupName, std::string beforegroupName);
	void removeGroup(std::string seqID,std::string groupName);
	void renameGroup(std::string seqID,std::string oldGoupName, std::string newGoupName);
protected:
	void handleGroups(const std::list<std::string>& groupNames);

protected:
	void sync_BuildGroupsList(std::list<std::string>& groupNames);
	std::list<TGroupItem>::iterator syncget_ItByGroupName(std::string groupName);
	void recvIQNotice(std::string id, int /*IqType*/ type);
	bool fixedGroupsPerhaps( const std::list<std::string>& groupNames );
	void sync_changeAllContactsGroup(std::string oldGoupName, std::string newGoupName );
private:
	boost::shared_ptr<TBizGroupsImpl> impl_;
	_DECLARE_E();
	std::string format_groupname(std::string groupName );
};

}; // biz