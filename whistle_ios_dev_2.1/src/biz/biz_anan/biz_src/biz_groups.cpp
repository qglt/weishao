#include <base/tcpproactor/TcpProactor.h>
#include "biz_groups.h"
#include "anan_biz_bind.h"
#include "anan_biz_impl.h"
#include "biz_groups_impl.h"
#include "boost/lexical_cast.hpp"
#include "gloox_src/rostermanager.h"
#include "login.h"
#include "gloox_src/gloox.h"
#include "user.h"
#include "user_impl.h"
#include "agent.h"
#include "agent_impl.h"
#include "biz_groups_error.h"
#include "an_roster_manager.h"
#include "client_anan.h"
#include "gloox_src/rosterlistener.h"
#include "biz_app_settings.h"

namespace biz
{

BizGroups::BizGroups(void)
	: impl_(new TBizGroupsImpl())
{
}

BizGroups::~BizGroups(void)
{
}

std::string BizGroups::format_groupname(std::string groupName )
{
	int pos = groupName.find_first_not_of(" \t");
	if (pos > 0)
	{
		groupName = groupName.substr(pos);
	}
	pos = groupName.size() -1;
	while(pos>=0 && (groupName[pos] == ' ' || groupName[pos] == '\t'))
	{	
		pos--;
	}
	if (pos<0)
	{
		groupName.clear();
	}
	else if (pos != groupName.size()-1)
	{
		groupName = groupName.substr(0, pos+1);
	}
	return groupName;
}

void BizGroups::addGroup(std::string seqID, std::string groupName, std::string beforegroupName )
{
	IN_TASK_THREAD_WORKx(BizGroups::addGroup, seqID, groupName, beforegroupName );
	
	if (syncget_ItByGroupName(groupName) != impl_->groups_.end()) 
	{
		event_collect::instance().recv_groups_changed(seqID, true, XL(AE(kbizGroupError_GroupNameExists)));
		return;
	}
	groupName = format_groupname(groupName);
	if(groupName.empty()) 
	{
		event_collect::instance().recv_groups_changed(seqID, true, XL(AE(kbizGroupError_GroupNameInvalid)));
		return;
	}

	bool b_failed = false;
	if(groupName == XLVU(GROUPNAME_MY_FRIEND) || groupName == GROUPNAME_MY_FRIEND)
	{
		b_failed = true;
	}
	if(groupName == XLVU(GROUPNAME_BLACKED) || groupName == GROUPNAME_BLACKED)
	{
		b_failed = true;
	}
	if(groupName == XLVU(GROUPNAME_STRANGER) || groupName == GROUPNAME_STRANGER)
	{
		b_failed = true;
	}
	if(b_failed)
	{
        event_collect::instance().recv_groups_changed(seqID, true, XL(AE(kbizGroupError_GroupNameExists)));
        return;
    }
	int group_size = impl_->groups_.size();
	std::list<TGroupItem>::iterator it_group = impl_->groups_.begin();
	for (;it_group != impl_->groups_.end();++it_group)
	{
		if (it_group->groupName == GROUPNAME_MY_FRIEND)
		{
			group_size -=1;
		}
		else if (it_group->groupName == GROUPNAME_STRANGER)
		{
			group_size -=1;
		}
		else if (it_group->groupName == GROUPNAME_BLACKED)
		{
			group_size -=1;
		}
		else if (it_group->groupName == XLVU(GROUPNAME_MY_FRIEND))
		{
			group_size -=1;
		}
		else if (it_group->groupName == XLVU(GROUPNAME_STRANGER))
		{
			group_size -=1;
		}
		else if (it_group->groupName == XLVU(GROUPNAME_BLACKED))
		{
			group_size -=1;
		}
	}

	if(group_size >= 12)
	{
		event_collect::instance().recv_groups_changed(seqID, true, XL("biz.group_number_exceed_limit"));
		return;
	}
	TGroupItem gi = {groupName};
	impl_->groups_.insert(syncget_ItByGroupName(beforegroupName), gi);

	StringList groups;
	sync_BuildGroupsList(groups);
	std::string id = get_parent_impl()->bizClient_->rosterManager()->add(JID(get_parent_impl()->bizUser_->get_userName() + "@" + app_settings::instance().get_domain()), "", groups);
	impl_->mapIqIdAndSeqID.insert(std::make_pair(id, seqID));
}

void BizGroups::moveGroup(std::string seqID,std::string groupName, std::string beforegroupName )
{
	IN_TASK_THREAD_WORKx(BizGroups::moveGroup, seqID, groupName, beforegroupName);

	std::list<TGroupItem>::iterator it_GroupName = syncget_ItByGroupName(groupName);
	if ( it_GroupName == impl_->groups_.end()) 
	{
		event_collect::instance().recv_groups_changed(seqID, true, XL(AE(kbizGroupError_GroupNameNotExists)));
		return;
	}
	impl_->groups_.erase(it_GroupName);

	TGroupItem gi = {groupName};
	impl_->groups_.insert(syncget_ItByGroupName(beforegroupName), gi);

	StringList groups;
	sync_BuildGroupsList(groups);

	std::string id = get_parent_impl()->bizClient_->rosterManager()->add(get_parent_impl()->bizClient_->jid().bareJID(), "", groups);

	impl_->mapIqIdAndSeqID.insert(std::make_pair(id, seqID));

}

void BizGroups::removeGroup(std::string seqID,std::string groupName )
{
	IN_TASK_THREAD_WORKx(BizGroups::removeGroup, seqID, groupName);

	std::list<TGroupItem>::iterator it_GroupName = syncget_ItByGroupName(groupName);
	if ( it_GroupName == impl_->groups_.end())
	{
		event_collect::instance().recv_groups_changed(seqID, true, XL(AE(kbizGroupError_GroupNameNotExists)));
		return;
	}

	sync_changeAllContactsGroup( groupName, "" );

	impl_->groups_.erase(it_GroupName);

	StringList groups;
	sync_BuildGroupsList(groups);

	std::string id = get_parent_impl()->bizClient_->rosterManager()->add(JID(get_parent_impl()->bizUser_->get_userName() + "@" + app_settings::instance().get_domain()), "", groups);

	impl_->mapIqIdAndSeqID.insert(std::make_pair(id, seqID));
}

void BizGroups::renameGroup(std::string seqID,std::string oldGoupName, std::string newGoupName )
{
	IN_TASK_THREAD_WORKx(BizGroups::renameGroup, seqID, oldGoupName, newGoupName);

	std::list<TGroupItem>::iterator it_GroupName = syncget_ItByGroupName(newGoupName);
	if ( it_GroupName != impl_->groups_.end()) 
	{
		event_collect::instance().recv_groups_changed(seqID, true, XL(AE(kbizGroupError_GroupNameExists)));
		return;
	}

	newGoupName = format_groupname(newGoupName);
	if(newGoupName.empty()) 
	{
		event_collect::instance().recv_groups_changed(seqID, true, XL(AE(kbizGroupError_GroupNameInvalid)));
		return;
	}

	if(oldGoupName == XLVU("biz.default_group.my_friends")|| oldGoupName==XLVU("biz.default_group.my_stranger")	|| oldGoupName==XLVU("biz.default_group.my_blacklist")) 
	{
        event_collect::instance().recv_groups_changed(seqID, true, XL("biz.rename_group.cannot_rename_a_default_group"));
        return;
    }

    if(newGoupName == XLVU("biz.default_group.my_friends") || newGoupName==XLVU("biz.default_group.my_stranger") || newGoupName==XLVU("biz.default_group.my_blacklist"))
    {
       event_collect::instance().recv_groups_changed(seqID, true, XL("biz.rename_group.cannot_rename_to_default_group"));
        return;
    }

	it_GroupName = syncget_ItByGroupName(oldGoupName);
	if ( it_GroupName == impl_->groups_.end())
	{
		event_collect::instance().recv_groups_changed(seqID, true, XL(AE(kbizGroupError_GroupNameNotExists)));
		return;
	}
	
	sync_changeAllContactsGroup( oldGoupName, newGoupName );

	it_GroupName->groupName = newGoupName;
	StringList groups;
	sync_BuildGroupsList(groups);

	std::string id = get_parent_impl()->bizClient_->rosterManager()->add(JID(get_parent_impl()->bizUser_->get_userName() + "@" + app_settings::instance().get_domain()), "", groups);

	impl_->mapIqIdAndSeqID.insert(std::make_pair(id, seqID));
}

std::list<TGroupItem>::iterator BizGroups::syncget_ItByGroupName( std::string groupName )
{
	std::list<TGroupItem>::iterator it;
	for (it = impl_->groups_.begin(); it != impl_->groups_.end(); ++it)
	{
		if (!groupName.compare(it->groupName))
		{
			break;
		}
	}
	return it;
}

void BizGroups::handleGroups( const std::list<std::string>& groupNames )
{
	bool b_found_empty = false;
	impl_->groups_.clear();
	for (std::list<std::string>::const_iterator cit = groupNames.begin(); cit != groupNames.end(); ++cit)
	{
		TGroupItem gi = {*cit};
		if (!gi.groupName.empty() && gi.groupName != XLVU(GROUPNAME_MY_FRIEND) && gi.groupName != XLVU(GROUPNAME_BLACKED)) 
		{
			if (syncget_ItByGroupName(gi.groupName) == impl_->groups_.end())
			{
				impl_->groups_.push_back(gi);
			}
		} 
		else
		{
			b_found_empty = true;
		}
	}
	if (b_found_empty) 
	{
		TGroupItem gi = {GROUPNAME_MY_FRIEND};
		impl_->groups_.push_front(gi);
	}
}

bool BizGroups::fixedGroupsPerhaps( const std::list<std::string>& groupNames )
{
	bool bfixed = false;
	for (std::list<std::string>::const_iterator cit = groupNames.begin(); cit != groupNames.end(); ++cit) 
	{
		bool bfound = false;
		for (std::list<TGroupItem>::const_iterator cit1 = impl_->groups_.begin(); cit1 != impl_->groups_.end();	++cit1)
		{
			if(cit1->groupName == *cit) 
			{
				bfound = true;
				break;
			}
		}
		if (!bfound && !cit->empty() ) 
		{
			bfixed = true;
			TGroupItem gi={*cit};
			impl_->groups_.insert(impl_->groups_.end(), gi);
		}
	}
	return bfixed;
}

void BizGroups::sync_BuildGroupsList( std::list<std::string>& groupNames )
{
	groupNames.clear();
	for (std::list<TGroupItem>::iterator it = impl_->groups_.begin();it != impl_->groups_.end();++it)
	{
		TGroupItem& item = *it;
		groupNames.push_back(item.groupName);
	}
}

void BizGroups::recvIQNotice(std::string id, int /*IqType*/ type)
{
	IQ::IqType iqType = (IQ::IqType)type;
	
	std::map<std::string, std::string>::iterator it = impl_->mapIqIdAndSeqID.find(id);
	if (it != impl_->mapIqIdAndSeqID.end()) 
	{
		if (iqType == IQ::Result)
		{
			event_collect::instance().recv_groups_changed(it->second, false, XL(""));
		} else if (iqType == IQ::Error) 
		{
			event_collect::instance().recv_groups_changed(it->second, true, XL(AE(kbizGroupError_IOError)));
		}
		impl_->mapIqIdAndSeqID.erase(it);
	}
}

void BizGroups::sync_changeAllContactsGroup(std::string oldGoupName, std::string newGoupName )
{
	Roster myRoster;
	get_parent_impl()->bizRoster_->sync_listContactsByGroup(oldGoupName, myRoster);

	JIDRemarkList jids;
	std::string myJid = get_parent_impl()->bizClient_->jid().bare();
	for (Roster::iterator it = myRoster.begin(); it != myRoster.end(); ++it) 
	{
		RosterItem* roster_item = it->second;
		if (roster_item->jid() != myJid)
		{
			jids.push_back(std::make_pair(roster_item->jid(), roster_item->name()));
		}
	}

	StringList groups;
	if (!newGoupName.empty())
	{
		groups.push_back(newGoupName);
	}
	std::for_each(jids.begin(), jids.end(), [=](JIDRemarkItem item)
	{
		this->get_parent_impl()->bizClient_->rosterManager()->add(item.first,item.second,groups);	
	}
	);
}

}; // biz
