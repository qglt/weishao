#include "local_config.h"
#include <base/tcpproactor/TcpProactor.h>
#include "boost/smart_ptr.hpp"
#include "boost/bind.hpp"
#include <boost/lambda/lambda.hpp>
#include <utility>
#include "base/txtutil/txtutil.h"
#include <boost/uuid/uuid.hpp>
#include <boost/uuid/uuid_generators.hpp>
#include <boost/uuid/uuid_io.hpp>
#include <base/utility/bind2f/bind2f.hpp>
#include <base/json/json_algorithm.hpp>
#include "gloox_src/privacymanager.h"
#include "an_roster_manager_error.h"
#include "anan_biz_bind.h"
#include "anan_biz_impl.h"
#include "agent.h"
#include "client_anan.h"
#include "agent_impl.h"
#include "an_vcard_type.h"
#include "user.h"
#include "user_impl.h"
#include "agent_type.h"
#include "an_roster_manager_impl.h"
#include "biz_groups.h"
#include "biz_groups_impl.h"
#include "login.h"
#include "anan_private.h"
#include <vector>
#include "boost/filesystem/operations.hpp"
#include "biz_recent_contact.h"
#include "conversation.h"
#include "base/module_path/file_manager.h"
#include "discussions.h"
#include "gloox_wrap/glooxWrapInterface.h"
#include "biz_app_settings.h"
#include <base/utility/file_digest/file2uri.hpp>
#include "whistle_vcard_handler.h"
#include "gloox_wrap/basicStanza.hpp"
#include "whistle_vcard.h"
#include "base/module_path/epfilesystem.h"
#include "anan_config.h"
#include "base/http_trans/http_request.h"
#include "gloox_src/rosteritemdata.h"
#include "base/thread/time_thread/time_thread_mgr.h"
#include "crowd.h"
#include "boost/assign/list_of.hpp"
#include <base/local_search/local_search.h>
#include <map>

using namespace epius;

namespace biz {
	static const std::string XMLNX_PRIVATE_XML_RUIJIE_GROUP = "jabber:iq:roster-group";
	static const std::string PRIVATE_NODE_RUIJIE_GROUP = "roster-group";
	static const std::string MY_PRIVACY_NAME = "invisable";
	static const char* const s_NoticeTypeTranslation[] = {"Add", "Remove", "Update"};
	
	std::string PRIVACY_ALL = "all";
	std::string PRIVACY_NONE = "none";
	std::string PRIVACY_FRIEND = "friend";


	std::string GROUPNAME_MY_FRIEND;
	std::string GROUPNAME_STRANGER;
	std::string GROUPNAME_BLACKED;

	using namespace gloox;
	using namespace std;
	using namespace boost::assign;
	static std::map<std::string, gloox::Presence::PresenceType> status_map = map_list_of("Online", Presence::Available)("Offline", Presence::Unavailable)("away",Presence::Away)("xa",Presence::XA)("dnd", Presence::DND)("invisible",Presence::Invisible);
	static std::map<std::string, std::string> state_map = map_list_of("online", "Online")("offline", "Offline")("away","Away")("xa","Away")("dnd", "Busy")("invisible","Invisible");
	static std::map<std::string, KPresenceType> pres_map = map_list_of("Online", kptOnline)("Offline", kptOffline)("Away",kptAway)("Busy", kptBusy)("Invisible",kptInvisible);
AnRosterManager::AnRosterManager(anan_biz_impl* parent/*AnClient* parent*/)
	: RosterManager(parent->bizClient_)
	, impl_(new AnRosterManagerImpl(parent->bizClient_))
{
	if( parent && parent->bizClient_)
	{
		typedef BasicStanza<ExtVCard> vcardid;
		parent->bizClient_->registerStanzaExtension( new vcardid(NULL, "/iq/vCard[@xmlns='" + XMLNS_VCARD_TEMP + "']"));
		impl_->vPrivacy_->registerPrivacyListHandler( this );
	}

	GROUPNAME_MY_FRIEND = "biz.default_group.my_friends";
	GROUPNAME_STRANGER = "biz.default_group.my_stranger";
	GROUPNAME_BLACKED = "biz.default_group.my_blacklist";

	//隐私列表和roster是否都准备好标志
	roster_is_ready_ = false;
	privacy_is_ready_ = false;
	device_is_ready_ = false;
	device_list_ = json::jobject();
	can_return_recent_.clear();
	change_presence_jids_.clear();
	requestVcard_jids_.clear();
}

AnRosterManager::~AnRosterManager(void)
{
}

bool AnRosterManager::handleIq( const IQ& iq )
{
	if (iq.subtype() == IQ::Set)
	{
		const Query* q = iq.findExtension<Query>( ExtRoster );
		RosterData::const_iterator it = q->roster().begin();
		for( ; it != q->roster().end(); ++it )
		{
			if ( (*it)->jid() == get_parent_impl()->bizClient_->jid().bare())
			{
				refBizGroupsObject().handleGroups((*it)->groups());
				break;
			}
		}
	}	
	return RosterManager::handleIq(iq);
}

void AnRosterManager::handleIqID( const IQ& iq, int context )
{
	const char* const err_info[] = {"", "biz.roster.handle_wrong_iq"};
	RosterManager::handleIqID(iq, context);

	bool res = ((IQ::IqType)iq.subtype() == IQ::Error);

	UICallbackByJid::iterator it = impl_->mapIqIdAndSeqID.find(iq.id());
	if (it != impl_->mapIqIdAndSeqID.end()) 
	{
		it->second(res, XL(err_info[(int)res]));
		impl_->mapIqIdAndSeqID.erase(it);
	} 
	else
	{
		refBizGroupsObject().recvIQNotice(iq.id(), iq.subtype());
	}

	std::set<std::string>::iterator itcan = can_return_recent_.find("roster");
	if (itcan == can_return_recent_.end())
	{
		can_return_recent_.insert("roster");
		get_parent_impl()->bizRecent_->noticeRecentContactChanged();
	}
}

void AnRosterManager::doRequestVCard( std::string jid_string, TContactNoteInfo &info, boost::function<void()> waitCallback )
{
	if (jid_string.empty())
	{
		return;
	}
	JID jid(jid_string);
	if (info.the_vcard_type == vard_type_base ) 
	{
		Tag* v = new Tag( "vCard" );
		v->setXmlns( XMLNS_VCARD_TEMP );
		v->addAttribute( "version", "3.0" );
		for (int i=0; !sc_basenametb[i].empty(); ++i)
		{
			if (sc_basenametb[i].compare(s_VcardModificationDate) == 0)
			{
				new Tag( v, sc_basenametb[i], info.get_vcardinfo()[s_VcardModificationDate].get<std::string>() );
			}
			else
			{
				new Tag( v, sc_basenametb[i], "" );
			}
		}
		typedef BasicStanza<ExtVCard> vcardid;

		const std::string& id = get_parent_impl()->bizClient_->getID();
		IQ iq ( IQ::Get, jid, id );
		iq.addExtension( new vcardid(v) );
		get_parent_impl()->bizClient_->send( iq, new whistleVcardHandler(waitCallback), VCardHandler::FetchVCard, true);
	}
	else
	{
		typedef BasicStanza<ExtVCard> vcardid;
		Tag* v = new Tag( "vCard" );
		v->setXmlns( XMLNS_VCARD_TEMP );
		v->addAttribute( "version", "3.0" );
		
		const std::string& id = get_parent_impl()->bizClient_->getID();
		IQ iq ( IQ::Get, jid, id );
		iq.addExtension( new vcardid(v) );
		get_parent_impl()->bizClient_->send( iq, new whistleVcardHandler(waitCallback), VCardHandler::FetchVCard, true);
	}
}

void AnRosterManager::requestVCardByItems( const Roster& rosters )
{
	// 超过600好友时界面处理很慢 先处理自己 使vcard处理均匀送给界面层
	std::string Userjid_string = get_parent_impl()->bizClient_->jid().bare();
	Roster::const_iterator cit = rosters.find(Userjid_string);
	if (cit != rosters.end())
	{
		const RosterItem* item = cit->second;
		ContactMap::iterator vcard_it = impl_->vcard_manager_.find(item->jid());
		if (vcard_it == impl_->vcard_manager_.end())
		{
			vcard_it = addEmptyVCard(item->jid(), item->subscription());
		}

		addgetRequestVCard(item->jid(), item->subscription(), vard_type_full);
	}

	for (Roster::const_iterator cit = rosters.begin(); cit != rosters.end(); ++cit)
	{
		const RosterItem* item = cit->second;

		if (item->jid() == Userjid_string)
		{
			continue;
		}

		ContactMap::iterator vcard_it = impl_->vcard_manager_.find(item->jid());
		if (vcard_it == impl_->vcard_manager_.end())
		{
			vcard_it = addEmptyVCard(item->jid(), item->subscription());
		}
		
		addgetRequestVCard(item->jid(), item->subscription(), vard_type_base);
	}
}

void AnRosterManager::handlePrivacyListResult( const std::string& id, PrivacyListResult plResult )
{
	UICallbackByJid::iterator it = impl_->mapIqIdAndSeqID.find(id);
	if (it == impl_->mapIqIdAndSeqID.end())
	{
		return;
	}
	UIVCallback callback = it->second;
	impl_->mapIqIdAndSeqID.erase(it);
	if (callback.empty())
	{
		return;
	}
	switch(plResult)
	{
	default:
		assert(false);
		break;
	case ResultStoreSuccess:             /**< Storing was successful. */
	case ResultActivateSuccess:          /**< Activation was successful. */
	case ResultDefaultSuccess:           /**< Setting the default list was successful. */
	case ResultRemoveSuccess:            /**< Removing a list was successful. */
	case ResultRequestNamesSuccess:      /**< Requesting the list names was successful. */
	case ResultRequestListSuccess:       /**< The list was requested successfully. */
		callback(false, XL(""));
		break;
	case ResultConflict:                 /**< A conflict occurred when activating a list or setting the default */
	case ResultItemNotFound:             /**< The requested list does not exist. */
	case ResultBadRequest:               /**< Bad request. */
	case ResultUnknownError:              /**< An unknown error occured. */
		callback(true,XL("biz.privacy.wrong"));
		break;
	}
}

void AnRosterManager::handlePrivacyListChanged( const std::string& name )
{
	assert(name == MY_PRIVACY_NAME);
	if (name != MY_PRIVACY_NAME)
	{
		return;
	}
}

void AnRosterManager::handlePrivacyList( const std::string& name, const PrivacyList& items )
{
	if (name != MY_PRIVACY_NAME)
	{
		return;
	}
	impl_->privacyList_ = items;
	PrivacyListHandler::PrivacyList::const_iterator it = impl_->privacyList_.begin();

	//用于规避以前的隐私列表（组）
	if (it->type() == PrivacyItem::TypeGroup)
	{		
		privacy_is_ready_ = true;
		roster_ready_();
		privacy_ready_();
		return;
	}

	//本地缓存隐私列表
	int i = 0;
	for( ; it != impl_->privacyList_.end(); it++ ) 
	{		
		privacy_jobj_["jids"][i] = it->value();
		privacy_jobj_["orders"][i] = it->value().substr(0,it->value().find("@"));
		if (it->value() == "9999@whistle.privacy.list")
		{
			++i;
			continue;
		}
		addgetRequestVCard(it->value(), S10nNone, vard_type_base);
		++i;
	}
	privacy_is_ready_ = true;
	roster_ready_();
	privacy_ready_();
}

void AnRosterManager::handlePrivacyListNames( const std::string& active, const std::string& def, const StringList& lists )
{
	StringList::const_iterator it = lists.begin();
	bool is_find_privacy = false;
	for( ; it != lists.end(); it++ ) 
	{
		if (*it == MY_PRIVACY_NAME) 
		{
			is_find_privacy = true;
			break;
		}
	}
	if(is_find_privacy)
	{
		if (active.empty())
		{
			impl_->vPrivacy_->setActive(MY_PRIVACY_NAME);
		}
		if (def.empty())
		{
			impl_->vPrivacy_->setDefault(MY_PRIVACY_NAME);
		}
		impl_->vPrivacy_->requestList(*it);
	}
	else
	{
		privacy_is_ready_ = true;
		roster_ready_();
		privacy_ready_();
	}
}

void AnRosterManager::handleRosterError( const IQ& iq )
{

}

bool AnRosterManager::handleUnsubscriptionRequest( const JID& jid, const std::string& msg )
{
 	ackSubscriptionRequest(jid, false);
	return false;
}

bool AnRosterManager::handleSubscriptionRequest( const JID& jid, const std::string& msg )
{
	if (privacy_is_ready_)
	{
		privacy_ready_.disconnect_all_slots();
		if ( RosterItem* ri = this->getRosterItem(jid.bareJID()) )
		{
			gloox::SubscriptionType st = ri->subscription();
			if (st == S10nBoth || st == S10nTo || st == S10nToIn )	
			{
				ackSubscriptionRequest(jid, true);
				return false;
			}
		}
		//查看是否在黑名单里
		boost::function<bool(json::jobject,std::string)> find_condition = [=](json::jobject jobj, std::string param)->bool
		{
			if(jobj.get() == param)
			{
				return true;
			}
			return false;
		};
		if (privacy_jobj_["jids"].find_if(bind2f(boost::apply<bool>(), find_condition, _1, jid.bare())))
		{
			return false;
		}
		//存储好友请求消息
		json::jobject req_jobj;
		json::jobject info_jobj;
		json::jobject extra_info_jobj;
		extra_info_jobj["operate"] = "";
		info_jobj["info"] = XL("biz.lower.add_you_as_friend_request").res_value_utf8;//请求添加您为好友
		info_jobj["extra_info"] = msg;
		req_jobj["info"] = info_jobj;
		req_jobj["extra_info"] = extra_info_jobj;
		req_jobj["msg_type"] = "request";
		req_jobj["server_time"] = "";
		req_jobj["is_read"] = false;
		std::string rowid = get_parent_impl()->bizLocalConfig_->saveRequestMsg(jid.bare(),req_jobj);
		event_collect::instance().recv_add_request(jid.bare(),rowid,msg);
		return false;
	}
	else
	{
		privacy_ready_.disconnect_all_slots();
		privacy_ready_.connect(bind2f(&AnRosterManager::handleSubscriptionRequest, this, jid,msg));
	}	
	return false;
}

void AnRosterManager::sync_replaceVCardByJobj(const RosterItem& item, json::jobject& jobj)
{
	ContactMap::iterator it = impl_->vcard_manager_.find(item.jid());
	if (it != impl_->vcard_manager_.end()) 
	{
		gwhistleVcard::instance().sync_replaceVCard(it->second.get_vcardinfo(), jobj);
	}
}

json::jobject AnRosterManager::buildVCardNotice(KRosterNoticeType type, std::string jid_string, KRosterNoticeAdditionType addition_action)
{
	json::jobject jobj = syncget_VCardJson(jid_string, false);
	if ( RosterItem* ri = this->getRosterItem(jid_string))
	{
		jobj["remark_name"] = ri->name();
	}

	// 通知除自己以外的在线状态
	if (jid_string != get_parent_impl()->bizClient_->jid().bare())
	{
		jobj["presence"]=s_trans[get_calculate_presence(jid_string)];
	}
	
	return buildVCardNotice(type, jobj, addition_action);
}

void AnRosterManager::apply_privacy_item(json::jobject& jobj, KContactType st, std::string key, json::jobject val)
{
	if(jobj.is_nil(key))
	{
		return;
	}
	std::string s_value = val.get<std::string>();
	if (s_value == PRIVACY_FRIEND)
	{
		if (st != kctContact)
		{
			jobj[key] = "biz.privacy.maintain.secrecy";
		}
	} 
	else if (s_value == PRIVACY_ALL) 
	{
		// do nothing.
	} 
	else 
	{ 
 		assert( s_value == PRIVACY_NONE );
		jobj[key] = "biz.privacy.maintain.secrecy";
	} 
}

void AnRosterManager::apply_privacy(json::jobject& jobj)
{
	std::string jid_string = jobj[s_VcardJid].get<std::string>();
	KContactType ct = is_my_friend_(jid_string);
	if (ct == kctSelf)
	{
		return;
	}
	
	json::jobject privacy_jobj;
	if ( jobj.is_nil(s_VcardPrivacy))
	{
		// 好友只修改vcard 没有改变隐私设置 隐私不跟随presence发送 此时使用本地vacrd里的隐私设置
		ContactMap::iterator it = impl_->vcard_manager_.find(jid_string);;
		if (it != impl_->vcard_manager_.end()) 
		{
			privacy_jobj = it->second.get_vcardinfo()[s_VcardPrivacy];
		}
	}
	else
	{
		privacy_jobj= jobj[s_VcardPrivacy];
	}
	
	
	if (privacy_jobj)
	{
		privacy_jobj.each(bind2f(&AnRosterManager::apply_privacy_item, jobj, ct, _1, _2));
	}	
}

json::jobject AnRosterManager::buildVCardNotice(KRosterNoticeType type, json::jobject jobj, KRosterNoticeAdditionType addition_action)
{
	static std::string s_typetb[] = {"",XLVU("biz.add_friend_is_agreed"),XLVU("biz.add_friend_is_agreed_and_also_add_you"),XLVU("biz.you_are_add_as_friend")};

	assert(sizeof(s_NoticeTypeTranslation)/sizeof(s_NoticeTypeTranslation[0]) > type);
	assert(addition_action < sizeof(s_typetb)/sizeof(s_typetb[0]));

	json::jobject ret_jobj;
	ret_jobj[s_VcardJid] = jobj[s_VcardJid].get<std::string>();
	ret_jobj["operation"] = s_NoticeTypeTranslation[type];
	ret_jobj["changes"] = jobj.clone();
	ret_jobj["original"] = jobj.clone();

	KContactType ct = is_my_friend_(jobj[s_VcardJid].get<std::string>());
	if (ct != kctSelf && ct == kctContact)
	{
		ret_jobj["original"]["is_my_friend"] = true;
	}
	else
	{
		ret_jobj["original"]["is_my_friend"] = false;
	}
	ret_jobj["type"] = s_typetb[addition_action];

	json::jobject changes_jobj = ret_jobj["changes"];
	apply_privacy(changes_jobj);

	//好友的隐私已经生效 隐私设置，拼音不用传给JS层展示
	if (ct != kctSelf)
	{
		ret_jobj["changes"].erase_if(bind2f(&json::search_obj_by_key<char>, s_VcardPrivacy, _1, _2));
	}

	ret_jobj["changes"].erase_if(bind2f(&json::search_obj_by_key<char>, s_VcardRemarkPinYin, _1, _2));
	ret_jobj["changes"].erase_if(bind2f(&json::search_obj_by_key<char>, s_VcardNickPinYin, _1, _2));
	ret_jobj["changes"].erase_if(bind2f(&json::search_obj_by_key<char>, s_VcardNamePinYin, _1, _2));

	return ret_jobj;
}

void AnRosterManager::setPresence( const std::string jid, KPresenceType presence)
{
	ContactMap::iterator it_vcard = impl_->vcard_manager_.find(jid);
	if (it_vcard != impl_->vcard_manager_.end())
	{
		it_vcard->second.presence = presence;
	}
}

void AnRosterManager::updatePresence( const std::string jid, const std::string& resource, Presence::PresenceType presence)
{
	KPresenceType pre_type;
	pre_type = sPresenceTypeTransTable[presence];

	ContactMap::iterator it_vcard = impl_->vcard_manager_.find(jid);
	if (it_vcard != impl_->vcard_manager_.end())
	{
		if (presence != Presence::Unavailable)
		{
			if (pre_type == kptInvisible)
			{
				it_vcard->second.presence = pre_type;
			}
			else
			{
				if (resource == "pc")
				{
					it_vcard->second.presence = pre_type;
				}
				else
				{
					if (resource == "android")
					{
						it_vcard->second.presence = kptAndroid;
					}
					else if (resource == "ios")
					{
						it_vcard->second.presence = kptIOS;
					}
				}				
			}	
		}
		else
		{		
			it_vcard->second.presence = kptOffline;
		}
	}	
}

void AnRosterManager::updatePresenceToVCard( const std::string jid, const std::string& resource, Presence::PresenceType presence)
{
	updatePresence(jid, resource, presence);
}

void AnRosterManager::updatePresenceToVCard( const RosterItem& item, const std::string& resource, Presence::PresenceType presence)
{
	updatePresence(item.jid(), resource, presence);
	ContactMap::iterator it = impl_->vcard_manager_.find(item.jid());
	if (it != impl_->vcard_manager_.end())
	{
		gwhistleVcard::instance().updateByRosterItem(it->second.get_vcardinfo(), item);
	}
}

void AnRosterManager::handleSelfPresence( const RosterItem& item, const std::string& resource, Presence::PresenceType presence, const std::string& msg )
{
	return;
}

biz::KPresenceType AnRosterManager::get_calculate_presence( std::string jid_string)
{
	KPresenceType ret = kptOffline;
	ContactMap::iterator it = impl_->vcard_manager_.find(jid_string);
	if ( it == impl_->vcard_manager_.end())
	{
		return ret;
	}
	else
	{
		if (it->second.presence != kptInvalid)
		{
			ret = it->second.presence;
		}		
	}
	return ret;
}

json::jobject AnRosterManager::fill_search_field(const gloox::Tag* org_tag)
{
	json::jobject jobj;
	if(org_tag)
	{
		if ("organization" == org_tag->findAttribute("type"))
		{
 			jobj["organization"] = org_tag->findAttribute("action");
			return jobj;
		}
		if ("user" == org_tag->findAttribute("type"))
		{
			jobj["action"] = org_tag->findAttribute("action");
			if (org_tag->findChild("username"))
			{
				jobj["jid"] = org_tag->findChild("username")->cdata() + "@" + app_settings::instance().get_domain();
			}	
			if (org_tag->findChild("resource"))
			{
				jobj["resource"] = org_tag->findChild("resource")->cdata();
			}
			if (org_tag->findChild("sort_string"))
			{
				jobj["sort_string"] = org_tag->findChild("sort_string")->cdata();
			}

			if (org_tag->findChild("status"))
			{
				jobj["status"] = org_tag->findChild("status")->cdata();
				jobj["presence"] = state_map[org_tag->findChild("status")->cdata()];
				if (org_tag->findChild("status")->cdata() != "invisible")
				{
					if (jobj["resource"].get<std::string>() == "ios") //pc > ios > android 
					{
						jobj["presence"] = "IOS";
					}
					else if(jobj["resource"].get<std::string>() == "android")
					{
						jobj["presence"] = "Android";
					}
				}	
				ContactMap::iterator it = impl_->vcard_manager_.find(jobj["jid"].get<std::string>());
				if (it != impl_->vcard_manager_.end())
				{
					it->second.presence = pres_map[jobj["presence"].get<std::string>()];
				}
			}			
		}
	}
	return jobj;
}

void AnRosterManager::handleNonrosterPresence( const Presence& presence )
{
	std::string jid_string = presence.from().bare();
	//组织结构树上下线状态通知
	std::string org_xmls = "organization." + app_settings::instance().get_domain();
	if (jid_string == org_xmls)
	{
		json::jobject jobj;
		gloox::Tag* org_tag = presence.get_tag();
		{
			bool is_update_org = false;
			if (org_tag)
			{
				gloox::ConstTagList org_list = org_tag->findTagList("//organization");
				for (gloox::ConstTagList::iterator it = org_list.begin();it != org_list.end();it++)
				{
					json::jobject org_jobj;
					if (*it)
					{
						org_jobj["key"] = (*it)->findAttribute("id");
						gloox::ConstTagList item_list = (*it)->findTagList("//item");
						for (gloox::ConstTagList::iterator item_it = item_list.begin();item_it != item_list.end();item_it++)
						{
							json::jobject tmp_jobj = fill_search_field(*item_it);
							if (tmp_jobj["organization"])
							{
								//从新获取组织结构树
								org_jobj["operation"] = "update";
								org_jobj["changes"].arr_push(tmp_jobj);
								is_update_org = true;
								break;
							}
							org_jobj["changes"].arr_push(tmp_jobj);
							org_jobj["operation"] = "change_status";
						}
						jobj["changes"].arr_push(org_jobj);
						jobj["operation"] = "change_status";
					}					
				}
				if (is_update_org)
				{
					jobj["operation"] = "update";
				}
				event_collect::instance().recv_organization_status_update(jobj);
			}
		}
	}
	else//陌生人更新vcard
	{
		json::jobject jobj;
		updatePresenceToVCard(jid_string, presence.from().resource(), presence.presence());			
		if (presence.status() != "")
		{	
			json::jobject presenceJ = json::jobject(epius::txtutil::convert_from_base64(presence.status()));			
			if (presenceJ)
			{
				ContactMap::iterator it = impl_->vcard_manager_.find(jid_string);
				if (it != impl_->vcard_manager_.end()) 
				{
					gwhistleVcard::instance().sync_replaceVCard(it->second.get_vcardinfo(), jobj);
				}
				//如果修改了昵称，需要同时更新showname
				if (!presenceJ.is_nil(s_VcardNickname))
				{				
					if (it != impl_->vcard_manager_.end()) 
					{
						presenceJ[s_VcardShowname] = it->second.get_vcardinfo()[s_VcardShowname].get<std::string>();
					}
				}
				else if (!presenceJ.is_nil(s_VcardHeadURI)) 
				{
					if (it != impl_->vcard_manager_.end()) 
					{
						std::string head = it->second.get_vcardinfo()[s_VcardHead].get<std::string>();
						if (!head.empty())
						{
							presenceJ[s_VcardHead] = head;
						}
						else
						{
							// 只修改头像不通知UI， 下载完毕回自动通知
							return;
						}
					}
				}
				else if (!presenceJ.is_nil(s_VcardLivePhotoURI)) 
				{
					if (it != impl_->vcard_manager_.end()) 
					{
						std::string photo = it->second.get_vcardinfo()[s_VcardLivePhoto].get<std::string>();
						if (!photo.empty())
						{
							presenceJ[s_VcardLivePhoto] = photo;
						}
						else
						{
							// 只修改生活照不通知UI， 下载完毕回自动通知
							return;
						}
					}
				}
				presenceJ[s_VcardJid] = jid_string;
				apply_privacy(presenceJ);
				jobj[s_VcardJid] = jid_string;
				jobj["operation"] = s_NoticeTypeTranslation[krntUpdate];
				jobj["changes"] = presenceJ;
				jobj["type"] = "";
			}
		}
		event_collect::instance().recv_presence(jid_string, get_calculate_presence(jid_string), jobj);
	}
}

void AnRosterManager::handleRosterPresence( const RosterItem& item, const std::string& resource, Presence::PresenceType presence, const std::string& msg )
{
	std::string jid_string = item.jid();		
	if(!msg.empty()) 
	{
		json::jobject jobj = json::jobject(epius::txtutil::convert_from_base64(msg));
		if(jobj) 
		{
			sync_replaceVCardByJobj(item, jobj);
		}
	}

	std::set<std::string>::iterator set_it = change_presence_jids_.find(jid_string);
	if (set_it == change_presence_jids_.end() || presence != Presence::PresenceType::Invisible)
	{
		//处理好友的presence
		//处理自己设备的presence
		if ( item.jidJID().bareJID() != get_parent_impl()->bizClient_->jid().bareJID() || resource == anan_config::instance().get_client_type()	) 
		{
			updatePresenceToVCard(item, resource, presence);
		} //处理自己其他设备非下线状态
		else if (item.jidJID().bareJID() == get_parent_impl()->bizClient_->jid().bareJID() && resource != anan_config::instance().get_client_type() &&	presence != Presence::Unavailable)
		{
			// 手机的状态 需要转化成 在线状态
			// pc的状态如果是 离开或忙碌 
			std::string tmp_resource;
			if (presence != Presence::Invisible)	
			{
				tmp_resource = "pc";
			}
			updatePresenceToVCard(item, tmp_resource, presence);
		}
	}
	
	
	StringList s_list = trans_group_name(sContactTypeTransTable[item.subscription()], &item);
	json::jobject jobj = json::jobject();
	if(!msg.empty()) 
	{
		json::jobject presenceJ = json::jobject(epius::txtutil::convert_from_base64(msg));
		if (presenceJ)
		{
			ContactMap::iterator it = impl_->vcard_manager_.find(jid_string);;
			//如果修改了昵称，需要同时更新showname
			if (!presenceJ.is_nil(s_VcardNickname))
			{				
				
				if (it != impl_->vcard_manager_.end()) 
				{
					presenceJ[s_VcardShowname] = it->second.get_vcardinfo()[s_VcardShowname].get<std::string>();
				}
			}
			else if (!presenceJ.is_nil(s_VcardHeadURI)) 
			{
				if (it != impl_->vcard_manager_.end()) 
				{
					std::string head = it->second.get_vcardinfo()[s_VcardHead].get<std::string>();
					if (!head.empty())
					{
						presenceJ[s_VcardHead] = head;
					}
					else
					{
						// 只修改头像不通知UI， 下载完毕回自动通知
						return;
					}
				}
			}
			else if (!presenceJ.is_nil(s_VcardLivePhotoURI)) 
			{
				if (it != impl_->vcard_manager_.end()) 
				{
					std::string photo = it->second.get_vcardinfo()[s_VcardLivePhoto].get<std::string>();
					if (!photo.empty())
					{
						presenceJ[s_VcardLivePhoto] = photo;
					}
					else
					{
						// 只修改生活照不通知UI， 下载完毕回自动通知
						return;
					}
				}
			}
			presenceJ[s_VcardJid] = jid_string;
			apply_privacy(presenceJ);
			jobj[s_VcardGroup] = *s_list.begin();
			jobj[s_VcardJid] = jid_string;
			jobj["operation"] = s_NoticeTypeTranslation[krntUpdate];
			jobj["changes"] = presenceJ;
			jobj["type"] = "";
		}
	}	
	//如果设置了隐身定时器kill掉timer
	if (presence != Presence::PresenceType::Invisible)
	{
		epius::time_mgr::instance().kill_timer(jid_string);
		std::set<std::string>::iterator set_it = change_presence_jids_.find(jid_string);
		if (set_it != change_presence_jids_.end())
		{
			change_presence_jids_.erase(set_it);
		}
	}	
	event_collect::instance().recv_presence(jid_string, get_calculate_presence(jid_string), jobj);		
}

void AnRosterManager::get_vcard_by_jid( std::string jid_string, JsonCallback callback)
{
	IN_TASK_THREAD_WORKx(AnRosterManager::get_vcard_by_jid, jid_string, callback);

	if (callback.empty())
	{
		return;
	}

	if(jid_string.empty())
	{
		jid_string = get_parent_impl()->bizClient_->jid().bare();
	}

	//支持脱机使用vcard
	if((get_parent_impl()->bizLogin_->conn_msm_.getCurrentState()) != CONN_CONNECTED)//不是在线状态
	{
		json::jobject jobj = buildVCardNotice( krntUpdate, jid_string, krntAdd_none );
		json::jobject changes_jobj;
		changes_jobj["changes"]= jobj["changes"];
		changes_jobj["original"]= jobj["original"];
		callback(changes_jobj);
		return;
	}
	
	ContactMap::iterator it = impl_->vcard_manager_.find(jid_string);
	if (it != impl_->vcard_manager_.end()) 
	{
		KContactType ct = is_my_friend_(jid_string);
		if(it->second.the_vcard_type != vard_type_full || ct != kctContact)
		{
			requesting_vcard_jid_.insert(jid_string);
			addgetRequestVCardWait(jid_string, (SubscriptionType)it->second.subscription, vard_type_full, callback);
		}
		else
		{
			std::set<std::string>::iterator reqit = requesting_vcard_jid_.find(jid_string);
			if ( reqit != requesting_vcard_jid_.end())
			{
				//此jid正在等待服务端返回, 在此等待50毫秒
				epius::time_mgr::instance().set_timer(50, bind2f(&AnRosterManager::get_vcard_by_jid, this, jid_string, callback));
				return;
			}

			json::jobject jobj = buildVCardNotice( krntUpdate, jid_string, krntAdd_none );
			json::jobject changes_jobj;
			changes_jobj["changes"]= jobj["changes"];
			changes_jobj["original"]= jobj["original"];
			callback(changes_jobj);
		}
	}
	else
	{
		requesting_vcard_jid_.insert(jid_string);
		addgetRequestVCardWait(jid_string, S10nNone, vard_type_full, callback);
	}
}

//展示在主面板里的项
json::jobject AnRosterManager::syncget_VCardJsonUI( std::string jid_string)
{
	json::jobject jobj;
	json::jobject buddy;
	jobj = syncget_VCardJson(jid_string, true);
	
	if ( RosterItem* ri = this->getRosterItem(jid_string))
	{
		buddy["remark_name"] = ri->name();
	}
	buddy["presence"] = s_trans[get_calculate_presence(jid_string)];
	buddy[s_VcardJid] = jobj[s_VcardJid];
	buddy[s_VcardShowname] = jobj[s_VcardShowname];
	buddy[s_VcardName] = jobj[s_VcardName];
	buddy[s_VcardHead] = jobj[s_VcardHead];
	buddy[s_VcardLivePhoto] = jobj[s_VcardLivePhoto];
	buddy[s_VcardSexShow] = jobj[s_VcardSexShow];
	buddy[s_VcardIdentityShow] = jobj[s_VcardIdentityShow];
	buddy["student_number"] = jobj["student_number"];
	buddy["mood_words"] = jobj["mood_words"];
	buddy["type"] = "conversation";
	buddy[s_VcardSex] = jobj[s_VcardSex];
	buddy[s_VcardIdentity] = jobj[s_VcardIdentity];
#ifndef _WIN32
	buddy[s_VcardNickname] = jobj[s_VcardNickname];
	buddy[s_VcardAge] = jobj[s_VcardAge];
#endif
	return buddy;
}

json::jobject AnRosterManager::syncget_VCardJson( std::string jid_string, bool need_duplcateJson /*= false*/)
{
	json::jobject jobj;
    ContactMap::iterator it = impl_->vcard_manager_.find(jid_string);
 	if (it != impl_->vcard_manager_.end()) 
	{
		if(need_duplcateJson)
		{
			jobj = it->second.get_vcardinfo().clone();
		}
		else
		{
			jobj = it->second.get_vcardinfo();
		}
	}
	return jobj;
}

void AnRosterManager::buildItemShowname(std::string showname,json::jobject userVCard, json::jobject& that)
{	
	// 清空showname
	that[s_VcardShowname] = "";	
	std::string idString = userVCard[s_VcardIdentity].get<std::string>();
	if (userVCard["username"].get<std::string>() != that["username"].get<std::string>())
	{
		idString = that[s_VcardIdentity].get<std::string>();
	}
	//如果职务为空添加默认职务
	if (that["title"].get<std::string>() == "")
	{
		if (idString == "biz.vcard.teacher")
		{
			that["title"] = XL("position_teacher").res_value_utf8;
		}
		else if (idString == "biz.vcard.student")
		{
			that["title"] = XL("position_student").res_value_utf8;
		}
		else
		{
			that["title"] = XL("position_other").res_value_utf8;
		}
	}
	// 自己： 昵称优先姓名
	if (that[s_VcardJid].get<std::string>() == get_parent_impl()->bizClient_->jid().bare()) 
	{
		if (that[s_VcardNickname].get<std::string>() != "")
		{
			that[s_VcardShowname] = that[s_VcardNickname].get<std::string>();
		}
		else
		{
			that[s_VcardShowname] = that[s_VcardName].get<std::string>();
		}
		return;
	}

	// 获取备注信息
	std::string strRemark;
	if ( RosterItem* ri = this->getRosterItem(that[s_VcardJid].get<std::string>()))
	{
		strRemark = ri->name();
	}

	if (showname == "name")
	{
		// 配置为按照姓名优先显示,无姓名时备注优先昵称
		if (that[s_VcardName].get<std::string>() != "")
		{
			that[s_VcardShowname] = that[s_VcardName].get<std::string>();
		}
		else 
		{
			if (!strRemark.empty())
			{
				that[s_VcardShowname] = strRemark;
			}
			else
			{
				that[s_VcardShowname] = that[s_VcardNickname].get<std::string>();
			}
		}
	}	
	else if (showname == "remark_name")
	{
		//配置为按照备注优先显示, 无备注时老师身份姓名优先昵称， 其他身份昵称优先姓名
		if (!strRemark.empty())
		{
			that[s_VcardShowname] = strRemark;
		}
		else 
		{
			if (userVCard[s_VcardIdentity].get<std::string>() == "biz.vcard.teacher")
			{
				if (that[s_VcardName].get<std::string>() != "")
				{
					that[s_VcardShowname] = that[s_VcardName].get<std::string>();
				}
				else
				{
					that[s_VcardShowname] = that[s_VcardNickname].get<std::string>();
				}
			}
			else
			{
				if (that[s_VcardNickname].get<std::string>() != "")
				{
					that[s_VcardShowname] = that[s_VcardNickname].get<std::string>();
				}
				else
				{
					that[s_VcardShowname] = that[s_VcardName].get<std::string>();
				}
			}
		}
	}
	else
	{
		// 配置为按照优先昵称显示,无昵称时备注优先姓名
		if (that[s_VcardNickname].get<std::string>() != "")
		{
			that[s_VcardShowname] = that[s_VcardNickname].get<std::string>();
		}
		else 
		{
			if (!strRemark.empty())
			{
				that[s_VcardShowname] = strRemark;
			}
			else
			{
				that[s_VcardShowname] = that[s_VcardName].get<std::string>();
			}
		}
	}
}

void AnRosterManager::buildShownameHelper(json::jobject& that)
{		
	if (impl_->show_name.empty())
	{
		impl_->show_name = get_parent_impl()->bizLocalConfig_->get_show_name();	
	}
	if (impl_->buildShowNameTask_.find(that[s_VcardJid].get<std::string>()) == impl_->buildShowNameTask_.end())
	{
		impl_->buildShowNameTask_.insert(make_pair(that[s_VcardJid].get<std::string>(),that));
	}
	std::string Userjid_string = get_parent_impl()->bizClient_->jid().bare();
	ContactMap::iterator it = impl_->vcard_manager_.find(Userjid_string);
	if (it != impl_->vcard_manager_.end() && it->second.fetch_done_) 
	{
		// 缓存中已经存在自己的数据， 可以计算showname
		std::map<std::string, json::jobject>::iterator it_vcard;
		for (it_vcard = impl_->buildShowNameTask_.begin();it_vcard != impl_->buildShowNameTask_.end(); ++it_vcard) 
		{
			buildItemShowname(impl_->show_name,it->second.get_vcardinfo(), it_vcard->second);
		}
		impl_->buildShowNameTask_.clear();
	}
}

bool AnRosterManager::handleGroups( const Roster& roster )
{
	// 在名册找自己，因为自己的名册条目保存着所有的组信息。
	bool self_in_roster = false;
	std::string userJid = get_parent_impl()->bizClient_->jid().bare();
	Roster::const_iterator cit_roster = roster.find(userJid);
	if(cit_roster != roster.end()) 
	{
		self_in_roster = true;
		RosterItem* p_item = cit_roster->second;
		refBizGroupsObject().handleGroups(p_item->groups());
	}
	fixedGroupsPerhaps(roster);
	return self_in_roster;
}

void AnRosterManager::fixedGroupsPerhaps(const Roster& roster)
{
	bool fix = false;
	for(Roster::const_iterator cit = roster.begin(); cit != roster.end(); ++cit) 
	{
		RosterItem* item = cit->second;
		if (sContactTypeTransTable[item->subscription()] == kctContact)
		{
			fix |= refBizGroupsObject().fixedGroupsPerhaps(item->groups());
		}
	}
	if (fix)
	{
		StringList groups;
		refBizGroupsObject().sync_BuildGroupsList(groups);
		std::string id = add(get_parent_impl()->bizClient_->jid(), "", groups);
	}
}

void AnRosterManager::fixed_roster( const Roster& roster )
{
	std::string domain_string = "@" + app_settings::instance().get_domain();
	std::string user_jid_string = get_parent_impl()->bizClient_->jid().bare();
	bool b_found = false;
	for(Roster::const_iterator cit = roster.begin(); cit != roster.end(); ++cit)
	{
		RosterItem* item = cit->second;
		if (item->jid().find(domain_string)==std::string::npos)
		{
			remove(item->jidJID());
		}
		if (user_jid_string == item->jid())
		{
			b_found = true;
		}
	}

	if (!b_found) 
	{
		StringList groups;
		refBizGroupsObject().sync_BuildGroupsList(groups);
		std::string id = add(get_parent_impl()->bizClient_->jid(), "", groups);
	}
}

void AnRosterManager::updateSelfPrsenceToJson( bool notice_ui /*= false*/ )
{
	std::string my_jid_string = get_parent_impl()->bizClient_->jid().bare();
	Roster::const_iterator cit_roster = roster()->find(my_jid_string);
	if(cit_roster != roster()->end())
	{
		RosterItem* item = cit_roster->second;
		std::string resource = get_parent_impl()->bizClient_->jid().resource();
		Presence::PresenceType presence = get_parent_impl()->bizClient_->presence().subtype();
		updatePresenceToVCard(*item, resource, presence);

		if (notice_ui) 
		{
			json::jobject jobj = buildVCardNotice(krntUpdate, item->jid(), krntAdd_none);
			event_collect::instance().recv_presence(item->jid(), get_calculate_presence(item->jid()), jobj);
		}
	}
}

void AnRosterManager::handleRoster( const Roster& roster )
{
	//标记roster已经取回来了
	roster_is_ready_ = true;
	handleGroups(roster);
	fixed_roster(roster);
	requestVCardByItems(roster);
	updateSelfPrsenceToJson();
	roster_ready_();
}

void AnRosterManager::handleItemUnsubscribed( const JID& jid, std::string& msg)
{
	json::jobject data(msg);
	if (data && data["type"])
	{
		if(data["type"].get<std::string>().compare("refuse") == 0)
		{
			data["from"] = syncget_VCardJson(jid.bare(), true)[s_VcardShowname].get<std::string>();
			//存储好友请求的应答
			json::jobject req_jobj;
			json::jobject info_jobj;
			json::jobject extra_info_jobj;
			extra_info_jobj["operate"] = "";
			info_jobj["extra_info"] = data["msg"].get<std::string>();
			info_jobj["info"] = XL("biz.lower.rejict_add_you_as_friend").res_value_utf8;//"拒绝了您的请求"
			req_jobj["extra_info"] = extra_info_jobj;			
			req_jobj["server_time"] = "";
			req_jobj["is_read"] = false;	
			req_jobj["info"] = info_jobj;
			req_jobj["msg_type"] = "reject";
			std::string rowid = get_parent_impl()->bizLocalConfig_->saveRequestMsg(jid.bare(),req_jobj);	
			event_collect::instance().recv_add_ack(jid.bare(),rowid,false, data);
		}
	}
	else
	{
		event_collect::instance().recv_add_ack(jid.bare(), "",false, data);
	}	
}

StringList AnRosterManager::trans_group_name( KContactType newtype, const RosterItem* item)
{
	std::string group_name;
	switch(newtype)
	{
	default:
		assert(false);
		break;
	case kctNone:
		group_name = "";
		break;
	case kctContact:
		{
			StringList groups = item->groups();
			if (!groups.empty())
				group_name = *groups.begin();
			if (group_name.empty())
				group_name = XLVU(GROUPNAME_MY_FRIEND);
			else if (group_name == GROUPNAME_BLACKED)
				group_name = XLVU(GROUPNAME_BLACKED);
			break;
		}
	case kctStranger:
		group_name = XLVU(GROUPNAME_STRANGER);
		break;
	}
	StringList sl;
	sl.push_back(group_name);
	return sl;
}

void AnRosterManager::handleItemUpdated( const JID& jid )
{
	RosterItem* item = getRosterItem(jid);
	assert(item);
	
	json::jobject jobj = syncget_VCardJson(item->jid(), false);
	std::string pre_group_name;
	if (jobj[s_VcardGroup])
	{
		pre_group_name = jobj[s_VcardGroup].get<std::string>();
	}
	// subcribe
	SubscriptionType st = syncget_subscription(item->jid());
	KContactType oldtype = sContactTypeTransTable[st];
	KContactType newtype = sContactTypeTransTable[item->subscription()];
	const int action_trans_tb[][3] = {{-1,krntAdd,krntAdd/*删好友到陌生人改用add不用update*/},{krntRemove,krntUpdate,krntUpdate},{krntRemove,krntAdd,krntUpdate}};
	int action = action_trans_tb[oldtype][newtype];

	// remark maybe changed, update showname
	std::string Userjid_string = get_parent_impl()->bizClient_->jid().bare();
	ContactMap::iterator it = impl_->vcard_manager_.find(Userjid_string);
	if (it != impl_->vcard_manager_.end() && it->second.fetch_done_) 
	{
		buildItemShowname(impl_->show_name, it->second.get_vcardinfo(), jobj);
	}

	KRosterNoticeAdditionType addition_action = krntAdd_none;
	switch(item->subscription())
	{
	default:
		assert(false);
	case S10nNone:
	case S10nNoneOut:
	case S10nNoneIn:
	case S10nNoneOutIn:
	case S10nFrom:
	case S10nFromOut:
		break;
	case S10nTo: // agree
		if (st < S10nTo) 
		{
			addition_action = krntAdd_new;
		}
		break;
	case S10nToIn: // agree & add
		if (st < S10nTo) 
		{
			addition_action = krntAdd_newme;
		}
		break;
	case S10nBoth: // be add
		if (st >= S10nTo && st <= S10nToIn) 
		{
			addition_action = krntAdd_me;
		}
		break;
	}

	if (action != -1) 
	{
		StringList sl = trans_group_name(newtype, item);
		jobj[s_VcardGroup] = *sl.begin();
		if (pre_group_name == GROUPNAME_BLACKED || pre_group_name == XLVU(GROUPNAME_BLACKED)) 
		{
			if (newtype == kctContact)
			{
				action = krntAdd; // 从黑名单组移回好友，使用add通知类型.
			}
		}
		std::wstring gn = txtutil::convert_utf8_to_wcs(*sl.begin());
		jobj = buildVCardNotice((KRosterNoticeType)action, item->jid(), addition_action);
		event_collect::instance().recv_item_updated(jobj.to_string());
		event_collect::instance().recv_presence(item->jid(), get_calculate_presence(item->jid()), jobj);
	}
}

void AnRosterManager::removeAllVcard()
{
	if(impl_->vcard_manager_.size())
	{
		impl_->vcard_manager_.clear();
	}
}

void AnRosterManager::clearVcardStatus()
{
	ContactMap::iterator it ;

	for (it = impl_->vcard_manager_.begin();it != impl_->vcard_manager_.end(); it++)
	{
		it->second.clearStatus();
		it->second.the_vcard_type = vard_type_base;
	}
}

void AnRosterManager::removeVCard( const std::string jid_string )
{
	ContactMap::iterator it = impl_->vcard_manager_.find(jid_string);
	if (it != impl_->vcard_manager_.end()) 
	{
		impl_->vcard_manager_.erase(it);
	}
}

void AnRosterManager::handleItemRemoved( const JID& jid )
{
	event_collect::instance().recv_item_updated(buildVCardNotice(krntRemove, jid.bare(), krntAdd_none).to_string());
}

void AnRosterManager::handleItemSubscribed( const JID& jid )
{
	//存储好友请求的应答
	json::jobject req_jobj;
	json::jobject info_jobj;
	json::jobject extra_info_jobj;
	extra_info_jobj["operate"] = "";
	info_jobj["extra_info"] = "";
	info_jobj["info"] = XL("biz.lower.agree_add_you_as_friend").res_value_utf8;//同意了您的请求并且添加您为好友";
	req_jobj["extra_info"] = extra_info_jobj;			
	req_jobj["server_time"] = "";
	req_jobj["is_read"] = false;	
	req_jobj["msg_type"] = "agree";
	req_jobj["info"] = info_jobj;
	std::string rowid = get_parent_impl()->bizLocalConfig_->saveRequestMsg(jid.bare(),req_jobj);	
	event_collect::instance().recv_add_ack(jid.bare(),rowid,true, json::jobject(""));
}

void AnRosterManager::handleItemAdded( const JID& jid )
{
	RosterItem* item = getRosterItem(jid);
	assert(item);
	addgetRequestVCard(item->jid(), item->subscription(), vard_type_base);
	gloox::SubscriptionType st = item->subscription();
	if (st == S10nBoth || st == S10nTo || st == S10nToIn || st ==S10nFrom)
	{
		event_collect::instance().recv_item_updated(buildVCardNotice(krntAdd, item->jid(), krntAdd_new).to_string());
	}
}

BizGroups& AnRosterManager::refBizGroupsObject()
{
	return *get_parent_impl()->bizGroups_.get();
}

void AnRosterManager::regist_to_gloox( Client* p_client )
{
	registerRosterListener( static_cast<RosterListener*>(this), false );
	get_parent_impl()->bizLogin_->conn_msm_.disconnected_signal_.connect(boost::bind(&AnRosterManager::discontion, this, _1));
	get_parent_impl()->bizLogin_->conn_msm_.connected_signal_.connect(boost::bind(&AnRosterManager::connected,this));
}

void AnRosterManager::unregist_to_gloox( Client* p_client )
{
	get_parent_impl()->bizLogin_->conn_msm_.disconnected_signal_.disconnect(&AnRosterManager::discontion);
	get_parent_impl()->bizLogin_->conn_msm_.connected_signal_.disconnect(&AnRosterManager::connected);
}

void AnRosterManager::addContact(std::string jid_string, std::string name, std::string msg, StringList groups)
{
	IN_TASK_THREAD_WORKx(AnRosterManager::addContact, jid_string, name, msg, groups);

	JID jid(jid_string);
	subscribe(jid, name, groups, msg);
}

void AnRosterManager::removeContact( std::string contactID, bool with_remote /*= false*/ )
{
	IN_TASK_THREAD_WORKx(AnRosterManager::removeContact, contactID, with_remote);
	JID jid(contactID);
	if (with_remote)
	{
		remove(jid);
	}
	else
	{
		unsubscribe(jid);
	}
}

void AnRosterManager::ackBeAdded( const std::string contactID, bool ack, std::string msg /*= ""*/ )
{
	IN_TASK_THREAD_WORKx(AnRosterManager::ackBeAdded, contactID, ack, msg);
	json::jobject jobj(msg);	
	json::jobject extra_info_jobj;
	std::string rowid = jobj["rowid"].get<std::string>();
	extra_info_jobj["operate"] = jobj["type"].get<std::string>();
	JID real_jid(contactID );
	if (ack)
	{
		ackSubscriptionRequest(real_jid, ack);				
	}
	else
	{
		cancel(real_jid, msg);
	}
	get_parent_impl()->bizLocalConfig_->update_request_msg(rowid,extra_info_jobj.to_string());
}

void AnRosterManager::moveContactToGroup(std::string contact_id, std::string groupName,UIVCallback callback )
{
	IN_TASK_THREAD_WORKx(AnRosterManager::moveContactToGroup, contact_id, groupName,callback);

    RosterItem* pri = getRosterItem(JID(contact_id));
    if (!pri) 
	{
        if (!callback.empty())
		{
            callback(true, XL(AE(kbizRosterMgrError_ContactNameNotExists)));
		}
        return;
    }

	if(groupName == XLVU(GROUPNAME_MY_FRIEND))
	{
		groupName = "";
	}
	if(groupName == XLVU(GROUPNAME_BLACKED))
	{
		groupName = GROUPNAME_BLACKED;
	}
	if(groupName == XLVU(GROUPNAME_STRANGER))
	{
		unsubscribe(JID(contact_id));
		if (!callback.empty())
		{
			callback(false, XL(AE(kbizRosterMgrError_NoError)));
		}
	}

    if(!groupName.empty()) 
	{
		if(groupName != GROUPNAME_BLACKED) 
		{
			if (groupName == GROUPNAME_MY_FRIEND || groupName == GROUPNAME_STRANGER || refBizGroupsObject().syncget_ItByGroupName(groupName) == refBizGroupsObject().impl_->groups_.end())
			{
				if (!callback.empty())
				{
					callback(true, XL(AE(kbizRosterMgrError_GroupNameNotExists)));
				}
				return;
			}
		}
		else
		{
			Result_Data_Callback wraped_callback = [=](bool err,universal_resource res,json::jobject jobj) mutable
			{
				if(!err) 
				{
					//解除好友关系
					this->remove( JID(contact_id));
					//通知界面移动到黑名单分组
					callback(err, res);					
				}				
			};
			
			int privacy_list_size = privacy_jobj_["jids"].arr_size();
			privacy_jobj_["jids"][privacy_list_size ] = contact_id;
			privacy_jobj_["orders"][privacy_list_size ] = contact_id.substr(0,contact_id.find("@"));			
			gWrapInterface::instance().edit_privacy_list(privacy_jobj_,wraped_callback);
			return;
		}
	}
	//将好友移动到别的分组
	StringList groups;
	groups.push_back(groupName);
	KContactType ct = is_my_friend_(pri->jidJID().bare());	
	if (ct == kctStranger && groupName != GROUPNAME_BLACKED)
	{
		subscribe(pri->jidJID().bareJID(), pri->name(), groups);
	}
	std::string id = add(pri->jidJID().bareJID(), pri->name(), groups);
	impl_->mapIqIdAndSeqID.insert(std::make_pair(id, callback));
}

void AnRosterManager::recvIQNotice(std::string id, int /*IqType*/ type)
{
	const char* const err_info[] = {"", "biz.roster.got_error_iq_notice"};

	bool res = ((IQ::IqType)type == IQ::Error);

	UICallbackByJid::iterator it = impl_->mapIqIdAndSeqID.find(id);
	if (it != impl_->mapIqIdAndSeqID.end()) 
	{
		it->second(res, XL(err_info[(int)res]));
		impl_->mapIqIdAndSeqID.erase(it);
	}
}

void AnRosterManager::discontion(universal_resource res)
{
	can_return_recent_.clear();
	change_presence_jids_.clear();
	saveRosterLocAndSrv();
	refBizGroupsObject().impl_->groups_.clear();
	impl_->mapIqIdAndSeqID.clear();
	//清空状态信息
	clearVcardStatus();
	impl_->show_name = "";
}
void AnRosterManager::connected()
{
	requestVcard_jids_.clear();
	removeAllVcard();
	loadRosterLocation();
	privacy_jobj_ = json::jobject(); 
	roster_is_ready_ = false;
	privacy_is_ready_ = false;
	device_is_ready_ = false;
	device_list_ = json::jobject();
	impl_->vPrivacy_->requestListNames();
	get_parent_impl()->bizAnanPrivate_->get_data("private:::device", bind2f(&AnRosterManager::getMyDeviceList, this, _1));
	epius::time_mgr::instance().kill_all_timer();
}

void AnRosterManager::blackedContact( std::string jid_string, bool blocked, UIVCallback callback )
{
	IN_TASK_THREAD_WORKx(AnRosterManager::blackedContact, jid_string, blocked, callback);
	
	std::string jid_str = jid_string;
	if (blocked)
	{
		moveContactToGroup(jid_string, GROUPNAME_BLACKED, callback);
	} 
	else
	{
		moveContactToGroup(jid_string, "", callback);
	}
}

void AnRosterManager::synclist_Contacts(int contactType, Roster& myRoster )
{
	bool is_need_edit_privacy = false;
	std::string my_jid_string = get_parent_impl()->bizClient_->jid().bare();
	for (Roster::iterator it = roster()->begin(); it != roster()->end(); ++it) 
	{
		RosterItem* item = it->second;
		if (item->jid() == my_jid_string)
		{
			continue;
		}
		int ct = sContactTypeTransTable[item->subscription()];		
		StringList groups = item->groups();
		for (StringList::iterator it_g = groups.begin(); it_g != groups.end(); ++it_g)
		{
			if(*it_g == GROUPNAME_BLACKED) 
			{
				ct = kctNone;
				remove(item->jid());
				int privacy_list_size = privacy_jobj_["jids"].clone().arr_size();
				privacy_jobj_["jids"][privacy_list_size] = item->jid();
				privacy_jobj_["orders"][privacy_list_size] = item->jid().substr(0,item->jid().find("@"));
				is_need_edit_privacy = true;
				break;
			}
		}	
		if (contactType & ct)
		{
			myRoster.insert(std::make_pair(item->jid(),item));
		}
	}
	Result_Data_Callback wraped_callback = [=](bool err,universal_resource res,json::jobject jobj) mutable
	{
		if(!err) 
		{	
			//移到黑名单成功不需要做别的操作了
		}				
	};
	if (is_need_edit_privacy)
	{
		gWrapInterface::instance().edit_privacy_list(privacy_jobj_,wraped_callback);
		is_need_edit_privacy = false;
	}	
}

json::jobject AnRosterManager::RosterGroupToHistoryJSON(contact_tree_map &the_contact_tree)
{
	json::jobject contact_data;

	int idx = 0;
	for(contact_tree_map::iterator it = the_contact_tree.begin();it!=the_contact_tree.end();++it)
	{
		contact_data[idx]["type"] = "friend";

		if(it->first == XLVU(GROUPNAME_STRANGER))
		{
			contact_data[idx]["type"] = "stranger";
		}
		else if(it->first == XLVU(GROUPNAME_BLACKED))
		{
			contact_data[idx]["type"] = "black";
		}
		contact_data[idx]["name"] = it->first;
		contact_data[idx]["headCount"] = (int)it->second.get<0>().size();
		int member_idx = 0;
		JidPresenceItem& second_item = the_contact_tree[it->first];
		JidPresenceMap& items = second_item.get<0>();
		for (JidPresenceMap::iterator it_item = items.begin(); it_item != items.end(); ++it_item)
		{
			contact_data[idx]["sublist"].arr_push(syncget_VCardJsonUI(it_item->first));
			++member_idx;
		}
		++idx;
	}
	json::jobject jobj;
	jobj["buddy_list"] = contact_data;
	return jobj;
}

json::jobject AnRosterManager::RosterGroupToJSON(contact_tree_map &the_contact_tree)
{
    json::jobject contact_data;

	int idx = 0;
    for(contact_tree_map::iterator it = the_contact_tree.begin();it!=the_contact_tree.end();++it)
    {
		contact_data[idx]["type"] = "friend";

		if(it->first == XLVU(GROUPNAME_STRANGER))
		{
			contact_data[idx]["type"] = "stranger";
		}
		else if(it->first == XLVU(GROUPNAME_BLACKED))
		{
			contact_data[idx]["type"] = "black";
		}
        contact_data[idx]["name"] = it->first;
        contact_data[idx]["headCount"] = (int)it->second.get<0>().size();
        contact_data[idx]["headOnline"] = it->second.get<1>();
        int member_idx = 0;
		JidPresenceItem& second_item = the_contact_tree[it->first];
		JidPresenceMap& items = second_item.get<0>();
		for (JidPresenceMap::iterator it_item = items.begin(); it_item != items.end(); ++it_item)
		{
			contact_data[idx]["sublist"].arr_push(syncget_VCardJsonUI(it_item->first));
            contact_data[idx]["sublist"][member_idx]["type"] = "conversation";
            ++member_idx;
        }
        ++idx;
    }
    json::jobject jobj;
    jobj["buddy_list"] = contact_data;
    return jobj;
}

void AnRosterManager::push_contact_tree_map( contact_tree_map& the_contact_tree, std::string group_name, RosterItem* roster_item )
{
	KPresenceType pt = sPresenceTypeTransTable[roster_item->online() ? roster_item->highestResource()->presence() : Presence::Unavailable];
	JidPresenceItem& the_contact_tree_item = the_contact_tree[group_name];
	the_contact_tree_item.get<k_jid_presence_item>().insert(std::make_pair(roster_item->jid(), pt));
	if(pt == kptOnline)
	{
		the_contact_tree_item.get<k_online_counter>()++;
	}
}

void AnRosterManager::init_contact_tree_map( contact_tree_map& the_contact_tree )
{
	the_contact_tree[XLVU(GROUPNAME_MY_FRIEND)] = boost::make_tuple(JidPresenceMap(),0);	
	StringList contact_group;
	refBizGroupsObject().sync_BuildGroupsList(contact_group);
	
	BOOST_FOREACH(std::string group_name, contact_group)
	{
		if (GROUPNAME_BLACKED != group_name && GROUPNAME_MY_FRIEND != group_name)
		{
			the_contact_tree[group_name] = boost::make_tuple(JidPresenceMap(),0);
		}
	}
}

void AnRosterManager::get_contact_history(JsonCallback callback )
{
	IN_TASK_THREAD_WORKx(AnRosterManager::get_contact_history, callback);

	if (callback.empty())
	{
		return;
	}
	contact_tree_map the_contact_tree;
	init_contact_tree_map(the_contact_tree);
	//我的好友
	Roster contacts;
	synclist_Contacts(kctContact | kctBlacked, contacts);
	push_roster_to_friend_tree(contacts, the_contact_tree);

	//陌生人
	the_contact_tree[XLVU(GROUPNAME_STRANGER)] = boost::make_tuple(JidPresenceMap(),0);
	Roster strangers;
	synclist_Contacts(kctStranger, strangers);
	for (Roster::iterator it = strangers.begin(); it != strangers.end(); ++it) 
	{
		push_contact_tree_map(the_contact_tree, XLVU(GROUPNAME_STRANGER), it->second);
	}
	JidPresenceItem strangeItem = the_contact_tree[XLVU(GROUPNAME_STRANGER)];
	the_contact_tree.erase(XLVU(GROUPNAME_STRANGER));
	the_contact_tree[XLVU(GROUPNAME_STRANGER)] = strangeItem;

	//黑名单
	the_contact_tree[XLVU(GROUPNAME_BLACKED)] = boost::make_tuple(JidPresenceMap(),0);
	for (int i = 0;i < privacy_jobj_["jids"].arr_size();i++ )
	{
		if (privacy_jobj_["jids"][i].get<std::string>() == "9999@whistle.privacy.list")
		{
			continue;
		}
		RosterItem* roster_item = new RosterItem(privacy_jobj_["jids"][i].get<std::string>(),"");
		push_contact_tree_map(the_contact_tree, XLVU(GROUPNAME_BLACKED), roster_item);	
	}
	JidPresenceItem blackedItem = the_contact_tree[XLVU(GROUPNAME_BLACKED)];
	the_contact_tree.erase(XLVU(GROUPNAME_BLACKED));
	the_contact_tree[XLVU(GROUPNAME_BLACKED)] = blackedItem;

	json::jobject jobj = RosterGroupToHistoryJSON(the_contact_tree);	  
	json::jobject tmp = syncget_VCardJson(get_parent_impl()->bizClient_->jid().bare(), true);
	jobj["my_info"][s_VcardJid] = tmp[s_VcardJid];
	jobj["my_info"][s_VcardShowname] = tmp[s_VcardShowname];
	jobj["my_info"][s_VcardHead] = tmp[s_VcardHead];
	jobj["my_info"][s_VcardSexShow] = tmp[s_VcardSexShow];
	jobj["my_info"][s_VcardIdentityShow] = tmp[s_VcardIdentityShow];
	json::jobject device, device_list, tmp_device;
	device["type"] = "device";

    if(!device_list_.is_nil("android")&&device_list_["android"].get<bool>() == true)	
	{
		tmp_device["jid"] = get_parent_impl()->bizClient_->jid().bare()+"/android";
		device_list.arr_push(tmp_device.clone());
	}
	if(!device_list_.is_nil("ios")&&device_list_["ios"].get<bool>() == true)	
	{
		tmp_device["jid"] = get_parent_impl()->bizClient_->jid().bare()+"/ios";
		device_list.arr_push(tmp_device);
	}
	device["sublist"] = device_list;

 	for (int i=jobj["buddy_list"].arr_size()-1;i != 0;i--)
 	{
 			jobj["buddy_list"][i] = jobj["buddy_list"][i-1];
 	}
	jobj["buddy_list"][0]=device;
	// 添加最后会话时间
	json::jobject timebyjid = get_parent_impl()->bizLocalConfig_->getLastConversation();
	jobj["last_conv_time"] = timebyjid;

	//从最近会话中查找出非好友的临时会话
	//增加临时会话分组 并加入返回结果集
	json::jobject appendContact;
	json::jobject contact_jobj;
	timebyjid.each(bind2f(&AnRosterManager::appendUnkownContactList, this, boost::ref(appendContact), the_contact_tree, _1, _2));

	if (appendContact.arr_size()>0)
	{
		for (int i = 0;i < appendContact.arr_size();++i)
		{
			std::string tmp_jid = appendContact[i]["jid"].get<std::string>();
			if (appendContact[i]["type"].get<std::string>() == "group_chat" ||
				appendContact[i]["type"].get<std::string>() == "crowd_chat")
			{
				continue;
			}
			else
			{
 				if (tmp_jid.substr(0,tmp_jid.find_last_of("/")) != get_parent_impl()->bizClient_->jid().bare())//清理我的设备在最近联系人列表
 				{
 					contact_jobj.arr_push(appendContact[i]);
 				}
			}
		}
		if (contact_jobj.arr_size() > 0)
		{
			json::jobject contact_data = jobj["buddy_list"];
			json::jobject tmp;
			tmp["name"] = epius::txtutil::convert_wcs_to_utf8(L"临时会话");
			tmp["headCount"] = contact_jobj.arr_size();
			tmp["sublist"] = contact_jobj;
			contact_data.arr_push(tmp);
		}
	}
	callback(jobj);
}

void AnRosterManager::get_contact(JsonCallback callback )
{
	IN_TASK_THREAD_WORKx(AnRosterManager::get_contact, callback);
	
	if (callback.empty())
	{
		return;
	}

	if(roster_is_ready_ && privacy_is_ready_ && device_is_ready_)
	{
		//解除绑定
		roster_ready_.disconnect_all_slots();
		//开始获取好友 陌生人 黑名单 列表
		contact_tree_map the_contact_tree;
		init_contact_tree_map(the_contact_tree);

		//我的好友
		Roster contacts;
		synclist_Contacts(kctContact | kctBlacked, contacts);
		push_roster_to_friend_tree(contacts, the_contact_tree);

		//陌生人
		the_contact_tree[XLVU(GROUPNAME_STRANGER)] = boost::make_tuple(JidPresenceMap(),0);
		Roster strangers;
		synclist_Contacts(kctStranger, strangers);
		
		for (Roster::iterator it = strangers.begin(); it != strangers.end(); ++it)
		{			
			push_contact_tree_map(the_contact_tree, XLVU(GROUPNAME_STRANGER), it->second);
		}
		JidPresenceItem strangeItem = the_contact_tree[XLVU(GROUPNAME_STRANGER)];
		the_contact_tree.erase(XLVU(GROUPNAME_STRANGER));
		the_contact_tree[XLVU(GROUPNAME_STRANGER)] = strangeItem;

		//黑名单
		the_contact_tree[XLVU(GROUPNAME_BLACKED)] = boost::make_tuple(JidPresenceMap(),0);
		for (int i = 0;i < privacy_jobj_["jids"].arr_size();i++ )
		{
			if (privacy_jobj_["jids"][i].get<std::string>() == "9999@whistle.privacy.list")
			{
				continue;
			}
			RosterItem* roster_item = new RosterItem(privacy_jobj_["jids"][i].get<std::string>(),"");
			push_contact_tree_map(the_contact_tree, XLVU(GROUPNAME_BLACKED), roster_item);	
		}
		JidPresenceItem blackedItem = the_contact_tree[XLVU(GROUPNAME_BLACKED)];
		the_contact_tree.erase(XLVU(GROUPNAME_BLACKED));
		the_contact_tree[XLVU(GROUPNAME_BLACKED)] = blackedItem;

		json::jobject jobj = RosterGroupToJSON(the_contact_tree);
		jobj["my_info"] = syncget_VCardJsonUI(get_parent_impl()->bizClient_->jid().bare());
		jobj["my_info"]["jid"] = get_parent_impl()->bizClient_->jid().bare();
		jobj["my_info"]["device"] = device_list_;
		callback(jobj);
	}
	else
	{
		if(roster_ready_.num_slots() == 0)
		{
			roster_ready_.connect(bind2f(&AnRosterManager::get_contact, this, callback));
		}
	}	
}

void AnRosterManager::push_roster_to_friend_tree( const Roster &contacts, contact_tree_map &the_contact_tree)
{
	for (Roster::const_iterator it = contacts.begin(); it != contacts.end(); ++it) 
	{
		RosterItem *item = it->second;
		StringList groups = item->groups();
		if(groups.empty())
		{
			groups.push_back(XLVU(GROUPNAME_MY_FRIEND));
		}
		BOOST_FOREACH(std::string groupName, groups)
		{
			if(groupName == GROUPNAME_BLACKED) 
			{
				groupName = XLVU(GROUPNAME_BLACKED);
			}
			if(groupName == GROUPNAME_MY_FRIEND || groupName.empty())
			{
				groupName = XLVU(GROUPNAME_MY_FRIEND);
			}
			push_contact_tree_map(the_contact_tree, groupName, item);
		}
	}
}

void AnRosterManager::listFriends( JsonCallback callback)
{
	IN_TASK_THREAD_WORKx(AnRosterManager::listFriends, callback);

	if (callback.empty())
		return;

	//客户端 IM-1160  讨论组会话：邀请好友加入讨论组，好友分组未按排序显示
	contact_tree_map the_contact_tree;
	StringList contact_group;
	refBizGroupsObject().sync_BuildGroupsList(contact_group);
	the_contact_tree[XLVU(GROUPNAME_MY_FRIEND)] = boost::make_tuple(JidPresenceMap(),0);
	BOOST_FOREACH(std::string group_name, contact_group)
	{
		if (GROUPNAME_BLACKED != group_name && GROUPNAME_MY_FRIEND != group_name)
			the_contact_tree[group_name] = boost::make_tuple(JidPresenceMap(),0);
	}

	Roster contacts;
	synclist_Contacts(kctContact, contacts);
	push_roster_to_friend_tree(contacts, the_contact_tree);
	callback(RosterGroupToJSON(the_contact_tree));
}

biz_recent_contact& AnRosterManager::refRecentContact()
{
	return *get_parent_impl()->bizRecent_.get();
}

void AnRosterManager::listRecentContact(JsonCallback callback)
{
	IN_TASK_THREAD_WORKx(AnRosterManager::listRecentContact, callback);

	refRecentContact().listRecentContact(callback);
}

#ifndef _WIN32
void AnRosterManager::removeSystemRecentContact(UIVCallback callback )
{
	IN_TASK_THREAD_WORKx(AnRosterManager::removeSystemRecentContact, callback);

	refRecentContact().removeSystemRecentContact(callback);
}

#endif

void AnRosterManager::removeRecentContact( std::string jid_string, UIVCallback callback )
{
	IN_TASK_THREAD_WORKx(AnRosterManager::removeRecentContact, jid_string, callback);

	refRecentContact().removeRecentContact(jid_string, callback);
}

void AnRosterManager::UpdateRecentContact(std::string contactID, KRecentJIDType type)
{
	IN_TASK_THREAD_WORKx(AnRosterManager::UpdateRecentContact, contactID, type);

	refRecentContact().UpdateRecentContact(contactID, type);
}

void AnRosterManager::uploadImage( json::jobject jobj, UIVCallback callback )
{
	IN_TASK_THREAD_WORKx(AnRosterManager::uploadImage, jobj, callback);

	std::string local_path;
	if (jobj[s_VcardHead_up])
	{
		local_path = jobj[s_VcardHead_up].get<std::string>();
	}
	if (jobj[s_VcardLivePhoto_up])
	{
		local_path = jobj[s_VcardLivePhoto_up].get<std::string>();
	}
	if (local_path.empty())
	{
		return;
	}
	boost::function<void(bool /*succ*/, std::string)> upload_callback = boost::bind(&AnRosterManager::uploadImage_cb, this, jobj, local_path, callback, _1, _2);
	epius::http_requests::instance().upload(anan_config::instance().get_http_upload_path(), local_path, "", "", boost::function<void(int)>(), upload_callback);

	if(callback)
	{
		callback(false, XL(""));
	}
}


void AnRosterManager::uploadImage_cb( json::jobject jobj, std::string cache_path, UIVCallback callback, bool succ, std::string result )
{
	IN_TASK_THREAD_WORKx( AnRosterManager::uploadImage_cb, jobj, cache_path, callback, succ, result);

	ELOG("app")->error( "------> cache path:" + cache_path + " result:" +result + (succ?" succ t":" succ f"));

	json::jobject upload_obj(result);
	if (upload_obj)
	{
		result = upload_obj["file_uri"].get<std::string>();
	}
	// step 2/2.
	if (!succ) 
	{
		epfilesystem::instance().remove_file(cache_path);
	}
	else 
	{
		std::string target_path = file_manager::instance().from_uri_to_path(result);
		if (file_manager::instance().file_is_valid(cache_path)) 
		{
			if (!file_manager::instance().file_is_valid(target_path))
			{
				epfilesystem::instance().rename_file(cache_path, target_path);
			}
			else
			{
				epfilesystem::instance().remove_file(cache_path);
			}
		}
		
		// 上传成功
		std::string jid_string = get_parent_impl()->bizClient_->jid().bare();		
		ContactMap::iterator it = syncget_VCard(jid_string);
		if (it != impl_->vcard_manager_.end())
		{
			if (jobj[s_VcardHead_up])
			{
				it->second.get_storeinfo()[s_VcardHead] = target_path;
				it->second.get_storeinfo()[s_VcardHeadURI] = result;
			}
			else if(jobj[s_VcardLivePhoto_up])
			{
				it->second.get_storeinfo()[s_VcardLivePhoto] = target_path;
				it->second.get_storeinfo()[s_VcardLivePhotoURI] = result;
			}
			ELOG("app")->error( "target: "+ target_path + " result: "+ result);
			Tag* v = new Tag( "vCard" );
			v->setXmlns( XMLNS_VCARD_TEMP );
			v->addAttribute( JSON_VCARD_VERSION_NAME, JSON_VCARD_VERSION );
			it->second.get_storeinfo().each(bind2f(&whistleVcard::appendStoreFields, gwhistleVcard::instance(), boost::ref(v), _1, _2));
			typedef BasicStanza<ExtVCard> vcardid;
			const std::string& id = m_parent->getID();
			IQ iq( IQ::Set, JID(), id );
			iq.addExtension( new vcardid(v));
			get_parent_impl()->bizClient_->send( iq, new whistleVcardHandler(boost::function<void()>()), VCardHandler::StoreVCard, true );
		}		
	}
}

void AnRosterManager::storeVCard( json::jobject jobj, UIVCallback callback )
{
	IN_TASK_THREAD_WORKx(AnRosterManager::storeVCard, jobj.clone(), callback);

	std::string jid_string = get_parent_impl()->bizClient_->jid().bare();
	ContactMap::iterator it = syncget_VCard(jid_string);
	
	if ( it != impl_->vcard_manager_.end())
	{
		it->second.get_storeinfo() = jobj;

		Tag* v = new Tag( "vCard" );
		v->setXmlns( XMLNS_VCARD_TEMP );
		v->addAttribute( JSON_VCARD_VERSION_NAME, JSON_VCARD_VERSION );
		it->second.get_storeinfo().each(bind2f(&whistleVcard::appendStoreFields, gwhistleVcard::instance(), boost::ref(v), _1, _2));

		typedef BasicStanza<ExtVCard> vcardid;
		const std::string& id = m_parent->getID();
		IQ iq( IQ::Set, JID(), id );
		iq.addExtension( new vcardid(v));
		get_parent_impl()->bizClient_->send( iq, new whistleVcardHandler(boost::function<void()>()), VCardHandler::StoreVCard, true );

		if(callback)
		{
			callback(false, XL(""));
		}
	}
}

void AnRosterManager::fireMatch(json::jobject& jobj, json::jobject& item)
{
	std::string jid = item[s_VcardJid].get<std::string>();
	assert(!jid.empty());
	jobj[jid][s_VcardJid] = jid;
	jobj[jid][s_VcardShowname] = item[s_VcardShowname].get<std::string>();
	jobj[jid][s_VcardHead] = item[s_VcardHead].get<std::string>();
	jobj[jid]["type"] = message_conversation;
	// 性别身份需要转译
	jobj[jid]["sex_show"] = item[s_VcardSexShow].get<std::string>();
	jobj[jid]["identity_show"] = item[s_VcardIdentityShow].get<std::string>();
}

void AnRosterManager::_MatchEach(json::jobject& jobj, std::string& filterString,json::jobject& item,std::string& JidServerString)
{
	// 检查一下 filterString 是否 remarkname 子串
	if (eplocal_find::instance().match(filterString,getRosterItem(item[s_VcardJid].get<std::string>())->name()))
	{
		fireMatch(jobj, item);
		return;
	}
	// 检查一下 filterString 是否 nickname 子串
	if (eplocal_find::instance().match(filterString,item["nick_name"].get<std::string>()))
	{
		fireMatch(jobj, item);
		return;
	}
	// 检查一下 filterString 是否 name 子串
	if (eplocal_find::instance().match(filterString,item["name"].get<std::string>()))
	{
		fireMatch(jobj, item);
		return;
	}
	// 匹配remark拼音字串
	if (eplocal_find::instance().match(filterString,getRosterItem(item[s_VcardJid].get<std::string>())->name()))
	{
		fireMatch(jobj, item);
		return;
	}
	// 匹配nickname拼音字串
	if (eplocal_find::instance().match(filterString,item["nick_name"].get<std::string>()))
	{
		fireMatch(jobj, item);
		return;
	}
	// 匹配name拼音字串
	if (eplocal_find::instance().match(filterString,item["name"].get<std::string>()))
	{
		fireMatch(jobj, item);
		return;
	}
	// 手机号含子串
	if (eplocal_find::instance().match(filterString,item["cellphone"].get<std::string>()))
	{
		fireMatch(jobj, item);
		return;
	}
	// 邮箱含子串
	if (eplocal_find::instance().match(filterString,item["email"].get<std::string>()))
	{
		fireMatch(jobj, item);
		return;
	}
	// 固定电话含子串
	if (eplocal_find::instance().match(filterString,item["landline"].get<std::string>()))
	{
		fireMatch(jobj, item);
		return;
	}
	// 学号含子串
	if (eplocal_find::instance().match(filterString,item["student_number"].get<std::string>()))
	{
		fireMatch(jobj, item);
		return;
	}
	// jid含子串
	std::string str = item["jid"].get<std::string>();
	if (!JidServerString.empty()) 
	{
		int at_pos = str.find(JidServerString);
		if (at_pos != std::string::npos)
		{
			str.erase(at_pos, JidServerString.size());
		}
	}
	if (eplocal_find::instance().match(filterString,str))
	{
		fireMatch(jobj, item);
		return;
	}
}

void AnRosterManager::reorganize_result(json::jobject *ret, std::string key, json::jobject value)
{
    value[s_VcardJid] = key;
    ret->arr_push(value);
}

void AnRosterManager::findContact( std::string filterString, bool include_stranger, bool withGroups, FilterJsonCallback callback )
{
	IN_TASK_THREAD_WORKx(AnRosterManager::findContact, filterString,include_stranger, withGroups, callback);
	
	if (callback.empty())
		return;
	
	int contact_type = include_stranger ? kctStranger | kctContact : kctContact;

	json::jobject jobj;
	if (!filterString.empty())
	{
		std::string JidServerString = "@" + get_parent_impl()->bizClient_->jid().server();
		for(Roster::iterator it = this->roster()->begin(); it != this->roster()->end(); ++it)
		{
			RosterItem* pri = it->second;
			if (!pri)
			{
				continue;
			}
			if(sContactTypeTransTable[pri->subscription()] == kctNone)
			{
				continue;
			}
			ContactMap::iterator it_info = impl_->vcard_manager_.find(pri->jid());
			if (it_info == impl_->vcard_manager_.end())
			{
				continue;
			}
			if(!(is_my_friend_(it_info->second.get_vcardinfo()[s_VcardJid].get<std::string>()) & contact_type))
			{
				continue;
			}
			_MatchEach(jobj, filterString, it_info->second.get_vcardinfo(), JidServerString);
		}
		if (withGroups) 
		{
			g_discussions::instance().search_local_discussions(filterString, jobj);
			g_crowd::instance().search_local_crowd(filterString, jobj);
		}
	}

    json::jobject re_org;
    jobj.each(bind2f(&reorganize_result,&re_org,_1,_2));
 	callback(filterString, re_org);
}

void AnRosterManager::saveRosterLocAndSrv()
{
	std::string head_path = syncget_VCardJson(get_parent_impl()->bizClient_->jid().bare())[s_VcardHead].get<std::string>();
	if (get_parent_impl()->bizLocalConfig_->isNeedSaveUserInfo()) 
	{
		Tuser_info info = get_parent_impl()->bizUser_->get_user();
		info.avatar_file = head_path;
		get_parent_impl()->bizUser_->set_user(info);
		get_parent_impl()->bizLocalConfig_->saveUserAvatar(get_parent_impl()->bizUser_->get_user());
	}
}

void AnRosterManager::loadRosterLocation()
{
	get_parent_impl()->bizLocalConfig_->loadCurRoster(impl_->vcard_manager_);
}

bool AnRosterManager::contact_in_group(const RosterItem& item, std::string groupName) const
{
	StringList belongGroups = item.groups();
	StringList::iterator it_group = std::find(belongGroups.begin(), belongGroups.end(), groupName);
	return (it_group != belongGroups.end());
}

void AnRosterManager::sync_listContactsByGroup( std::string groupName, Roster& myRoster )
{
	myRoster.clear();
	for (Roster::const_iterator cit = roster()->begin(); cit != roster()->end(); ++cit)
	{
		RosterItem *item = cit->second;
		if (contact_in_group(*item, groupName))
		{
			myRoster.insert(std::make_pair(item->jid(), item));
		}
	}
}


void AnRosterManager::setContactRemark( std::string jid_string, std::string remarkName, UIVCallback callback )
{
	IN_TASK_THREAD_WORKx(AnRosterManager::setContactRemark, jid_string, remarkName, callback);

	RosterItem* pri = getRosterItem(JID(jid_string));
	assert(pri);

	if (!pri)
	{
		if (!callback.empty())
		{
			callback(true, XL("biz.roster.change_remark_for_none_buddy"));
		}
		return;
	}

	std::string id = add(pri->jidJID().bareJID(), remarkName, pri->groups());
	impl_->mapIqIdAndSeqID.insert(std::make_pair(id, callback));

}

void AnRosterManager::is_my_friend( std::string jid_string, JsonCallback callback )
{
	IN_TASK_THREAD_WORKx(AnRosterManager::is_my_friend, jid_string, callback);

	if (callback.empty())
	{
		return;
	}
	static const std::string subscription_e2c_table[] = {"None","Contact","Stranger", "Blacked", "Self"};
	int ct = (int)is_my_friend_(jid_string);
	int idx = 0;
	while(ct>0) ct>>=1,idx++;
	json::jobject jobj;
	jobj["relationship"] = subscription_e2c_table[idx];
	callback(jobj);
}

KContactType AnRosterManager::is_my_friend_( std::string jid_string )
{
	boost::function<bool(json::jobject,std::string)> find_condition = [=](json::jobject jobj, std::string param)->bool
	{
		if(jobj.get() == param)
		{
			return true;
		}
		return false;
	};
	if (privacy_jobj_["jids"].find_if(bind2f(boost::apply<bool>(), find_condition, _1, jid_string)))
	{
		return kctBlacked;
	}

	if (RosterItem* item = getRosterItem(JID(jid_string)))
	{
		if (item->jid() == get_parent_impl()->bizClient_->jid().bare()) 
		{
			return kctSelf;
		} 
		else 
		{			
			return sContactTypeTransTable[item->subscription()];
		}
	}
	else 
	{
		return kctNone;
	}
}

ContactMap::iterator AnRosterManager::syncget_VCard(std::string jid_string )
{
	return impl_->vcard_manager_.find(jid_string);
}

SubscriptionType AnRosterManager::syncget_subscription(std::string jid_string)
{
	ContactMap::iterator vcard_it = impl_->vcard_manager_.find(jid_string);
	if (vcard_it != impl_->vcard_manager_.end()) 
	{
		return (SubscriptionType)vcard_it->second.subscription;
	}
	else 
	{
		assert(false);
		return S10nNone;
	}
}

ContactMap::iterator AnRosterManager::addEmptyVCard( std::string jid_string, SubscriptionType subscription )
{
	ContactMap::iterator it;
	if ((it = impl_->vcard_manager_.find(jid_string)) != impl_->vcard_manager_.end())
	{
		ELOG("app")->error("AnRosterManager::addEmptyVCard:try to add a empty vcard which already exist in the manager : " + jid_string);
		return it;
	}

	TContactNoteInfo info;
	info.presence = kptOffline;
	info.subscription = subscription;
	info.the_vcard_type = vard_type_none;
	info.raw_vcardinfo[s_VcardJid] = jid_string;
	info.raw_vcardinfo[s_VcardShowname] = epius::txtutil::convert_wcs_to_utf8(L"微哨用户");
	gwhistleVcard::instance().FinishFields(info.raw_vcardinfo);
	ContactMapItem mapItem = std::make_pair(jid_string, info);
	impl_->vcard_manager_.insert(mapItem);
	return impl_->vcard_manager_.find(jid_string);
}

void AnRosterManager::addgetRequestVCard_cb(std::string jid_string, JsonCallback callback)
{
	if (!callback.empty())
	{
		json::jobject jobj = buildVCardNotice( krntUpdate, jid_string, krntAdd_none );
		json::jobject changes_jobj;
		changes_jobj["changes"] = jobj["changes"];
		changes_jobj["original"] = jobj["original"];
		callback(changes_jobj);
	}

	std::set<std::string>::iterator reqit = requesting_vcard_jid_.find(jid_string);
	if ( reqit != requesting_vcard_jid_.end())
	{
		requesting_vcard_jid_.erase(reqit);
	}
}

void AnRosterManager::addgetRequestVCardWait( std::string jid_string,SubscriptionType subscription, whistle_vcard_type the_vcard_type, JsonCallback callback )
{
	ContactMap::iterator vcard_it = impl_->vcard_manager_.find(jid_string);
	if (vcard_it == impl_->vcard_manager_.end())
	{
		vcard_it = addEmptyVCard(jid_string, subscription);
	}
	vcard_it->second.subscription = subscription;
	std::string tmp_jid_string = vcard_it->second.get_vcardinfo()[s_VcardJid].get<std::string>();
	if (tmp_jid_string.empty() && !jid_string.empty())
	{
		vcard_it->second.get_vcardinfo()[s_VcardJid] = jid_string;
	}
	vcard_it->second.the_vcard_type = the_vcard_type;
	doRequestVCard(vcard_it->first, vcard_it->second, bind2f(&AnRosterManager::addgetRequestVCard_cb, this, jid_string, callback));
}

void AnRosterManager::addgetRequestVCard( std::string jid_string,SubscriptionType subscription, whistle_vcard_type the_vcard_type)
{
	ContactMap::iterator vcard_it = impl_->vcard_manager_.find(jid_string);
	if (vcard_it == impl_->vcard_manager_.end())
	{
		vcard_it = addEmptyVCard(jid_string, subscription);
	}
	vcard_it->second.subscription = subscription;
	std::string tmp_jid_string = vcard_it->second.get_vcardinfo()[s_VcardJid].get<std::string>();
	if (tmp_jid_string.empty() && !jid_string.empty())
	{
		vcard_it->second.get_vcardinfo()[s_VcardJid] = jid_string;
	}
	vcard_it->second.the_vcard_type = the_vcard_type;
	doRequestVCard(vcard_it->first, vcard_it->second, boost::function<void()>());

}

void AnRosterManager::appendUnkownContactList( json::jobject& jobj, contact_tree_map &the_contact_tree, std::string key, json::jobject val )
{
	//排除讨论组
	if (key.find(DISCUSSIONS_DOMAIN)!= std::string::npos)
	{
		if (!g_discussions::instance().is_group_exist(key))
		{
			json::jobject discussions;
			discussions[s_VcardJid] = key;
			discussions[s_VcardShowname] = val[0]["group_name"];
			discussions["type"] = "group_chat";
			jobj.arr_push(discussions);
		}
		return;
	}

	if (key.find(GROUPS_DOMAIN)!= std::string::npos)
	{
		if (!g_crowd::instance().is_crowd_exist(key))
		{
			json::jobject crowd;
			crowd[s_VcardJid] = key;
			crowd[s_VcardShowname] = val[0]["crowd_name"];
			crowd["type"] = "crowd_chat";
			jobj.arr_push(crowd);
		}
		return;
	}

	//最后聊天记录的jid没有在contacts里查找到，表明次jid是一个临时会话记录，或是曾经好友的聊天记录
	bool found = false;
	for(contact_tree_map::iterator it = the_contact_tree.begin();it!=the_contact_tree.end();++it)
	{
		JidPresenceItem& second_item = the_contact_tree[it->first];
		JidPresenceMap& items = second_item.get<0>();
		if(items.find(key)!=items.end())
		{
			found = true;
			break;
		}
	}
	
	//没有在所有分组找到jid， 此jid是临时会话jid
	if (!found)
	{
		//添加一个fake联系人
		ContactMap::iterator vcard_it = addEmptyVCard(key, S10nNone);
		std::string tmp_jid_string = vcard_it->second.get_vcardinfo()[s_VcardJid].get<std::string>();
		if (tmp_jid_string.empty())
		{
			vcard_it->second.get_vcardinfo()[s_VcardJid] = key;
		}
		vcard_it->second.the_vcard_type = vard_type_full;
		doRequestVCard(vcard_it->first, vcard_it->second,  boost::function<void()>());

		json::jobject tmp = vcard_it->second.get_vcardinfo();
		json::jobject buddy;
		buddy[s_VcardJid] = tmp[s_VcardJid];
		buddy[s_VcardShowname] = tmp[s_VcardShowname];
		buddy[s_VcardHead] = tmp[s_VcardHead];
		buddy[s_VcardSexShow] = tmp[s_VcardSexShow];
		buddy[s_VcardIdentityShow] = tmp[s_VcardIdentityShow];
		buddy["student_number"] = tmp["student_number"];
		buddy["type"] = "conversation";

		jobj.arr_push(buddy);
	}
}

void AnRosterManager::finished_syncdown_image( std::string jid_string,std::string ui_image_field,std::string down_load_path,bool succ,std::string uri_string )
{	
	if (succ)
	{	
		boost::function<void(std::string)> work_body = [=](std::string image_uri){
			ContactMap::iterator it;
			if ((it =impl_->vcard_manager_.find(jid_string)) != impl_->vcard_manager_.end())
			{
				//判断下载下来的图片是否正确
				if (image_uri == uri_string)
				{
					it->second.get_vcardinfo()[ui_image_field] = down_load_path;

					json::jobject ret_jobj;
					json::jobject image;
					image[ui_image_field] = down_load_path;
					image[s_VcardJid] = jid_string;
					ret_jobj[s_VcardJid] = jid_string;
					ret_jobj["operation"] = s_NoticeTypeTranslation[krntUpdate];
					ret_jobj["changes"] = image;
					ret_jobj["type"] = "";
					event_collect::instance().recv_item_updated(ret_jobj.to_string());
					//保存head到本地roster表
					get_parent_impl()->bizLocalConfig_->scheduleSaveRoster(jid_string, it->second.get_vcardinfo());
				}
				else
				{
					ELOG("http")->error("failed download head or live image! image_uri:" + image_uri + " uri_string:" +uri_string.c_str());
					return;
				}			
			}
		};
		epius::async_get_uri(down_load_path, get_parent_impl()->wrap(work_body));
	}
}

void AnRosterManager::broad_vcard_in_presence( json::jobject jobj )
{
	get_parent_impl()->bizUser_->set_Presence(epius::txtutil::convert_to_base64(jobj.to_string()));
}

void AnRosterManager::temporaryAttention( std::string jid, bool cancel, UIVCallback callback)
{
	IN_TASK_THREAD_WORKx(AnRosterManager::temporaryAttention, jid, cancel, callback);

	ContactMap::iterator vcard_it = impl_->vcard_manager_.find(jid);
	if (vcard_it != impl_->vcard_manager_.end())
	{
		// 清空状态
		vcard_it->second.get_vcardinfo()[s_VcardStatus] = json::jobject();
		vcard_it->second.presence = kptOffline;
	}

	gWrapInterface::instance().temporary_attention( JID(jid).username(), cancel, callback);
}

void AnRosterManager::get_stranger_presence( std::string jid )
{
	IN_TASK_THREAD_WORKx(AnRosterManager::get_stranger_presence, jid);

	ContactMap::iterator vcard_it = impl_->vcard_manager_.find(jid);
	if (vcard_it == impl_->vcard_manager_.end())
	{
		//添加陌生人到vcardmanager
		json::jobject juser;
		juser[s_VcardJid] = jid;
		get_parent_impl()->bizRoster_->addVcard(juser);
	}

	vcard_it->second.the_vcard_type = vard_type_full;
	
	typedef BasicStanza<ExtVCard> vcardid;
	Tag* v = new Tag( "vCard" );
	v->setXmlns( XMLNS_VCARD_TEMP );
	v->addAttribute( "version", "3.0" );

	if (!vcard_it->second.get_vcardinfo()[s_VcardModificationDate])
	{
		new Tag( v, s_VcardModificationDate, vcard_it->second.get_vcardinfo()[s_VcardModificationDate].get<std::string>() );
	}

	const std::string& id = get_parent_impl()->bizClient_->getID();
	IQ iq ( IQ::Get, jid, id );
	iq.addExtension( new vcardid(v) );
	get_parent_impl()->bizClient_->send( iq, new whistleVcardHandler(bind2f(&AnRosterManager::get_stranger_presence_cb, this, jid)), VCardHandler::FetchVCard, true);

}

void AnRosterManager::updateStatus2Json(std::string jid, json::jobject jobj)
{
	updatePresence(jid, jobj["resource"].get<std::string>(), status_map[jobj["show"].get<std::string>()]);
}

void AnRosterManager::get_stranger_presence_cb(std::string jid)
{
	// 多设备状态同步到vcard manager中
	ContactMap::iterator vcard_it = impl_->vcard_manager_.find(jid);
	if (vcard_it != impl_->vcard_manager_.end())
	{
		vcard_it->second.get_vcardinfo()[s_VcardStatus].each(bind2f(&AnRosterManager::updateStatus2Json, this, jid ,_1));
		vcard_it->second.get_vcardinfo()[s_VcardStatus] = json::jobject();
	}
	
	event_collect::instance().recv_presence(jid, get_calculate_presence(jid), json::jobject());
}

void AnRosterManager::addVcard( json::jobject jobj )
{
	std::string jid_string = jobj["jid"].get<std::string>();
	ContactMap::iterator vcard_it = impl_->vcard_manager_.find(jid_string);
	if (vcard_it == impl_->vcard_manager_.end())
	{
		vcard_it = addEmptyVCard(jid_string, S10nNone);
	}
}

void AnRosterManager::change_user_showname(std::string show_name)
{
	IN_TASK_THREAD_WORKx(AnRosterManager::change_user_showname,show_name);
	std::string Userjid_string = get_parent_impl()->bizClient_->jid().bare();
	ContactMap::iterator it = impl_->vcard_manager_.find(Userjid_string);
	if (it == impl_->vcard_manager_.end()) 
	{
		return;
	}
	ContactMap::iterator showname_index ;

	impl_->show_name = show_name;

	for (showname_index = impl_->vcard_manager_.begin();showname_index != impl_->vcard_manager_.end(); ++showname_index) 
	{
		if (m_roster.find(showname_index->first) != m_roster.end())
		{
			buildItemShowname(impl_->show_name, it->second.get_vcardinfo() ,showname_index->second.get_vcardinfo());
			json::jobject ret_jobj;
			json::jobject showname;
			showname[s_VcardShowname] = showname_index->second.get_vcardinfo()[s_VcardShowname];
			showname[s_VcardJid] = showname_index->second.get_vcardinfo()[s_VcardJid];
			ret_jobj[s_VcardJid] = showname_index->second.get_vcardinfo()[s_VcardJid].get<std::string>();
			ret_jobj["operation"] = s_NoticeTypeTranslation[krntUpdate];
			ret_jobj["changes"] = showname;
			ret_jobj["type"] = "";
			event_collect::instance().recv_item_updated(ret_jobj.to_string());
		}
	}	
}

static void get_search_conditions(std::map<std::string,std::string> &search_info, std::string key, json::jobject jobj)
{
	search_info[key] = jobj.get<string>();
}

void AnRosterManager::findFriend( json::jobject jobj, boost::function<void(json::jobject jobj, bool err, universal_resource)> callback )
{
	IN_TASK_THREAD_WORKx(AnRosterManager::findFriend, jobj, callback);
	std::map<std::string,std::string> friend_info;

	jobj["args"].each(bind2f(&get_search_conditions,boost::ref(friend_info),_1,_2));

	gWrapInterface::instance().find_friend( friend_info, boost::bind(&AnRosterManager::findFriend_cb, this, jobj, callback, _1 ,_2) );
}

void AnRosterManager::findFriend_cb( json::jobject jobj, boost::function<void(json::jobject jobj, bool err, universal_resource)> callback, bool err,json::jobject data )
{
	if (!err)
	{
		// andriod-708 按群号查找后输入中文条件查找失败，系统提示错误，返回空结果集即可，不用返回失败
		callback(jobj, false, XL("biz.conversation.failed_to_search_friend_on_server"));
	}

	for (int i = 0; i != data.arr_size();++i)
	{
		data[i]["jid"] = data[i]["jid"].get<string>()+ "@" + app_settings::instance().get_domain();
		data[i]["head"] = "";
		std::string uri = data[i]["photo_credential"].get<std::string>();
		if (!uri.empty())
		{
			std::string uri_file_str = biz::file_manager::instance().from_uri_to_valid_path(uri);
			if (!uri_file_str.empty())
			{
				data[i]["head"] = uri_file_str;
			}
			else
			{
				get_parent_impl()->bizAnanPrivate_->download_uri(uri,boost::bind(&AnRosterManager::find_friend_and_finish_download, this,data[i]["jid"].get<std::string>() , _1, _2, _3));
			}
		}
		//处理隐私
		json::jobject privacy_jobj;
		if(data[i][s_VcardPrivacy].get<std::string>().empty())
		{
			privacy_jobj = json::jobject(s_VcardDefaultPrivacy);
		}
		else
		{
			privacy_jobj = json::jobject(data[i][s_VcardPrivacy].get<std::string>());
		}
		data[i][s_VcardPrivacy] = privacy_jobj.clone();
		//更新roster里的缓存vcard
		ContactMap::iterator itvcard = get_parent_impl()->bizRoster_->syncget_VCard(data[i]["jid"].get<std::string>());
		if (itvcard != get_parent_impl()->bizRoster_->impl_->vcard_manager_.end())
		{
			gwhistleVcard::instance().sync_replaceVCard(itvcard->second.get_vcardinfo(),data[i]);
		}
		//设置隐私
		KContactType ct = get_parent_impl()->bizRoster_->is_my_friend_(data[i]["jid"].get<std::string>());
		if (ct != kctSelf)
		{
			data[i][s_VcardPrivacy].each(bind2f(&AnRosterManager::apply_privacy_item, data[i], ct, _1, _2));
		}
	}
	 // 把查找结果data里的数据 放入jobj中
	jobj["friend_list"] = data;
	// 下载头像
	callback(jobj, false, XL(""));
}

void AnRosterManager::find_friend_and_finish_download(std::string jid, bool err, universal_resource res, std::string local_path)
{
	//更新roster里的缓存vcard
	ContactMap::iterator itvcard = get_parent_impl()->bizRoster_->syncget_VCard(jid);
	if (itvcard != get_parent_impl()->bizRoster_->impl_->vcard_manager_.end())
	{
		itvcard->second.get_vcardinfo()["head"] = local_path;
	}
	json::jobject jobj;
	jobj["jid"] = jid;
	jobj["operation"] = "Update";
	jobj["changes"]["head"] = local_path;
	event_collect::instance().recv_item_updated(jobj.to_string());
}

json::jobject AnRosterManager::getSelfVcardInfo()
{
	std::string jid = get_parent_impl()->bizClient_->jid().bare();

	ContactMap::iterator it = impl_->vcard_manager_.find(jid);
	if (it != impl_->vcard_manager_.end())
	{
		return it->second.get_vcardinfo();
	}
	else
	{
		ELOG("app")->error( "AnRosterManager::getSelfVcardInfo: Cannot find self in vcard_manager");
		return json::jobject();
	}
}

void AnRosterManager::remove_someone_form_privacy_list(std::string jid,Result_Data_Callback callback)
{
	IN_TASK_THREAD_WORKx( AnRosterManager::remove_someone_form_privacy_list, jid, callback);

	boost::function<bool(json::jobject,std::string)> erase_condition = [=](json::jobject jobj, std::string param)->bool
	{
		if(jobj.get() == param)
		{
			return true;
		}
		return false;
	};
	privacy_jobj_["jids"].erase_if(bind2f(boost::apply<bool>(), erase_condition, _1, jid));
	privacy_jobj_["orders"].erase_if(bind2f(boost::apply<bool>(), erase_condition, _1, jid.substr(0,jid.find("@"))));
	if (privacy_jobj_["jids"].arr_size() == 0)
	{
		privacy_jobj_["jids"][0] = "9999@whistle.privacy.list";
		privacy_jobj_["orders"][0] = "9999";
	}
	gWrapInterface::instance().edit_privacy_list(privacy_jobj_,callback);
}

void AnRosterManager::updateMessageShowname( std::string jid, json::jobject data )
{
	IN_TASK_THREAD_WORKx(AnRosterManager::updateMessageShowname, jid, data);

	requestVcard_jids_.erase(jid);

	//取 showname
	ContactMap::iterator itvcard = get_parent_impl()->bizRoster_->syncget_VCard(jid);
	std::string show_name, name;
	if (itvcard != get_parent_impl()->bizRoster_->impl_->vcard_manager_.end()){
		KContactType ct = get_parent_impl()->bizRoster_->is_my_friend_(jid);
		// 双人会话 陌生人显示showname
		// 讨论组和群 陌生人 显示姓名
		show_name = itvcard->second.get_vcardinfo()[s_VcardShowname].get<std::string>();
		if (ct != kctNone)
		{
			name = show_name;
		}
		else
		{
			name = itvcard->second.get_vcardinfo()[s_VcardName].get<std::string>();
		}
		ELOG("app")->debug("updateMessageShowname find vcard show_name : "  + show_name);
	}
	else
	{
		ELOG("app")->error("updateMessageShowname cannot find vcard show_name : " + jid);
		return;
	}

	// update 会话数据库
	get_parent_impl()->bizLocalConfig_->updateMessageShowname(jid, show_name, name);

	// 通知界面update
	json::jobject jobj;
	jobj["jid"] = jid;
	jobj[s_VcardShowname] = show_name;
	jobj["member_name"] = name;
	event_collect::instance().update_dialog_showname(jobj);
}

void AnRosterManager::getMyDeviceList( json::jobject list )
{
	IN_TASK_THREAD_WORKx(AnRosterManager::getMyDeviceList, list);

	device_is_ready_ = true;

	// check if client type exist in the list
	if (list.get<bool>(anan_config::instance().get_client_type()) == false)
	{
		list[anan_config::instance().get_client_type()] = true;
		
		// store it
		boost::function<void(bool)> store_callback = [=](bool ret)
		{
			if (ret)
			{
				ELOG("app")->debug("getMyDeviceList store device list succeed");
			}
			else
			{
				ELOG("app")->debug("getMyDeviceList store device list failed");
			}
		};
		get_parent_impl()->bizAnanPrivate_->store_data("private:::device", list, store_callback);
	}

	list.erase_if(boost::function<bool(std::string, json::jobject)>(boost::lambda::_1 == anan_config::instance().get_client_type()));

	device_list_ = list;

	roster_ready_();
}

} // namespace biz
