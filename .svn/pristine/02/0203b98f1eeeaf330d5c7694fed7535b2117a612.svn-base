#pragma once
#include "boost/signal.hpp"
#include "boost/function.hpp"
#include "base/json/tinyjson.hpp"
#include "anan_biz_bind.h"
#include "anan_type.h"
#include "biz_groups.h"
#include "an_roster_manager_type.h"
#include "an_roster_manager.h"
#include "gloox_src/vcardhandler.h"
#include "gloox_src/privacylisthandler.h"
#include "gloox_src/rosterlistener.h"
#include "gloox_src/rostermanager.h"
#include "biz_recent_contact.h"
#include <string>
#include <map>
#include <set>
#include <base/utility/callback_def/callback_define.hpp>
#include <base/thread/time_thread/time_thread.h>
#include "event_collection.h"
namespace gloox
{
	class PrivacyManager;
}; // gloox

namespace biz
{
	using namespace gloox;
	struct anan_biz_impl;
	struct AnRosterManagerImpl;
	struct TContactNoteInfo;
	class AnClient;

	extern std::string GROUPNAME_MY_FRIEND;
	extern std::string GROUPNAME_STRANGER;
	extern std::string GROUPNAME_BLACKED;

class AnRosterManager : public anan_biz_bind<anan_biz_impl>
	, public RosterManager
	, protected PrivacyListHandler
	, protected RosterListener
{
	BIZ_FRIEND();

public:

	std::set<std::string> can_return_recent_;
	std::set<std::string> requesting_vcard_jid_;
	std::set<std::string> change_presence_jids_;
	std::set<std::string> requestVcard_jids_;
public:
	BizGroups& refBizGroupsObject();

	// 取自己的vcard信息
	json::jobject getSelfVcardInfo();

	// 联系人增、删、加黑
	void addContact(std::string jid_string, std::string name, std::string msg, StringList groups);
	void removeContact(std::string jid_string, bool with_remote = false);
	void ackBeAdded(const std::string jid, bool ack, std::string msg = "");
	void blackedContact(std::string jid_string, bool blocked, UIVCallback callback);
	void moveContactToGroup(std::string jid_string, std::string groupName,UIVCallback callback );
    
	void setContactRemark(std::string jid_string, std::string remarkName,UIVCallback callback );

	void get_contact(JsonCallback callback);
	void get_contact_history(JsonCallback callback);
	boost::signal<void()> roster_ready_;
	boost::signal<void()> privacy_ready_;
    void listFriends(JsonCallback);
    void storeVCard( json::jobject jobj, UIVCallback callback );

	void uploadImage_cb(json::jobject jobj, std::string cache_path, UIVCallback callback, bool succ, std::string result);
	void uploadImage(json::jobject jobj, UIVCallback callback);

	// 最近联系人
	void listRecentContact(JsonCallback callback);
	void removeRecentContact( std::string jid_string, UIVCallback callback );
	// 更新数据库 showname
	void updateMessageShowname(std::string jid, json::jobject data);

#ifndef _WIN32
	void removeSystemRecentContact(UIVCallback callback );
#endif

	// 本地查找联系人
	void findContact(std::string filterString, bool include_stranger, bool withGroups, FilterJsonCallback callback);
	void findFriend(json::jobject jobj, boost::function<void(json::jobject jobj, bool err, universal_resource)> callback);
	void findFriend_cb(json::jobject jobj,  boost::function<void(json::jobject jobj, bool err, universal_resource)> callback, bool err, json::jobject data);
	void is_my_friend( std::string jid_string, JsonCallback callback );
	void UpdateRecentContact(std::string contactID, KRecentJIDType type);

	static void apply_privacy_item(json::jobject& jobj, KContactType st, std::string key, json::jobject val);
	KContactType is_my_friend_( std::string jid_string );
	void buildShownameHelper(json::jobject& that);
	void finished_syncdown_image(std::string jid_string,std::string ui_image_field,std::string down_load_path,bool succ,std::string uri_string);
	void change_user_showname(std::string show_name);
protected:
	void regist_to_gloox( Client* p_client );
	void unregist_to_gloox( Client* p_client );
	void discontion(universal_resource res);
	void connected();
	void recvIQNotice(std::string id, int /*IqType*/ type);
	void synclist_Contacts(/*KContactType*/int contactType, Roster& myRoster);
	void sync_listContactsByGroup(std::string group, Roster& myRoster);
	void sync_moveContactsToGroups( StringList contacts, StringList groups, UIVCallback callback );
	void saveRosterLocAndSrv();
	void loadRosterLocation();

public:
	AnRosterManager(anan_biz_impl* parent/*AnClient* parent*/);
	virtual ~AnRosterManager(void);

public:
	void requestVCardByItems( const Roster& rosters);
	void get_vcard_by_jid( std::string jid , JsonCallback callback);
    json::jobject syncget_VCardJson(std::string jid, bool need_duplcateJson = false);
	json::jobject syncget_VCardJsonUI(std::string jid);
	ContactMap::iterator syncget_VCard(std::string jid_string);

	void addgetRequestVCard( std::string jid_string, SubscriptionType subscription, whistle_vcard_type the_vcard_type);
	void addgetRequestVCardWait( std::string jid_string, SubscriptionType subscription, whistle_vcard_type the_vcard_type, JsonCallback callback );
	void addgetRequestVCard_cb(std::string jid_string, JsonCallback callback);
	void removeVCard( const std::string jid_string );
	void addVcard( json::jobject jobj );
	json::jobject buildVCardNotice(KRosterNoticeType type, json::jobject jobj, KRosterNoticeAdditionType addition_action);
	json::jobject buildVCardNotice(KRosterNoticeType type, std::string jid_string, KRosterNoticeAdditionType addition_action);
	void broad_vcard_in_presence(json::jobject jobj);
	KPresenceType get_calculate_presence(std::string jid_string);
	void temporaryAttention( std::string jid, bool cancel, UIVCallback callback);
	void get_stranger_presence( std::string jid);
	void get_stranger_presence_cb(std::string jid);
	void updateStatus2Json(std::string jid, json::jobject jobj);
	void find_friend_and_finish_download(std::string jid, bool err, universal_resource res, std::string local_path);
	boost::shared_ptr<AnRosterManagerImpl> impl_;
protected: // RosterListener
	virtual void handleItemAdded( const JID& jid );
	virtual void handleItemSubscribed( const JID& jid );
	virtual void handleItemRemoved( const JID& jid );
	virtual void handleItemUpdated( const JID& jid );
	virtual void handleItemUnsubscribed( const JID& jid, std::string& msg);
	virtual void handleRoster( const Roster& roster );
	virtual void handleRosterPresence( const RosterItem& item, const std::string& resource, Presence::PresenceType presence, const std::string& msg );
	virtual void handleSelfPresence( const RosterItem& item, const std::string& resource, Presence::PresenceType presence, const std::string& msg );
	virtual bool handleSubscriptionRequest( const JID& jid, const std::string& msg );
	virtual bool handleUnsubscriptionRequest( const JID& jid, const std::string& msg );
	virtual void handleNonrosterPresence( const Presence& presence );
	virtual void handleRosterError( const IQ& iq );
public:
	void remove_someone_form_privacy_list(std::string jid,Result_Data_Callback callback);

protected: // PrivacyListHandler
	  /**
       * Reimplement this function to retrieve the list of privacy list names after requesting it using
       * PrivacyManager::requestListNames().
       * @param active The name of the active list.
       * @param def The name of the default list.
       * @param lists All the lists.
       */
      virtual void handlePrivacyListNames( const std::string& active, const std::string& def,
                                           const StringList& lists );

      /**
       * Reimplement this function to retrieve the content of a privacy list after requesting it using
       * PrivacyManager::requestList().
       * @param name The name of the list.
       * @param items A list of PrivacyItem's.
       */
      virtual void handlePrivacyList( const std::string& name, const PrivacyList& items );

      /**
       * Reimplement this function to be notified about new or changed lists.
       * @param name The name of the new or changed list.
       */
      virtual void handlePrivacyListChanged( const std::string& name );

      /**
       * Reimplement this function to receive results of stores etc.
       * @param id The ID of the request, as returned by the initiating function.
       * @param plResult The result of an operation.
       */
      virtual void handlePrivacyListResult( const std::string& id, PrivacyListResult plResult );

protected:
    virtual bool handleIq( const IQ& iq );
    virtual void handleIqID( const IQ& iq, int context );

    json::jobject RosterGroupToJSON(contact_tree_map &the_contact_tree);
	json::jobject RosterGroupToHistoryJSON(contact_tree_map &the_contact_tree);
	
	void queryRecentContact_callback(json::jobject jobj);
	void noticeRecentContactChanged();
	void BuildRecentContactJson(json::jobject& jobj);
	void _MatchEach(json::jobject& jobj, std::string& filterString,json::jobject& item,std::string& JidServerString);
	void PaserRecentContactJson(json::jobject& jobj);
	void buildItemShowname(std::string showname,json::jobject userVCard, json::jobject& that);
	void fireMatch(json::jobject& jobj, json::jobject& item);
	KRecentJIDType RPaserRecentContactType(std::string typeString);
	void doRequestVCard( std::string jid_string, TContactNoteInfo &info, boost::function<void()> waitCallback);
	bool contact_in_group(const RosterItem& item, std::string groupName) const;
	void sync_replaceVCardByJobj(const RosterItem& item, json::jobject& jobj);
	bool handleGroups( const Roster& roster );
	void removeAllVcard();
	void clearVcardStatus();
	void getMyDeviceList(json::jobject list);
private:
	biz_recent_contact& refRecentContact();
	void push_contact_tree_map( contact_tree_map& the_contact_tree, std::string group_name, RosterItem* roster_item );
	void init_contact_tree_map( contact_tree_map& the_contact_tree );
	void updatePresenceToVCard( const RosterItem& item, const std::string& resource, Presence::PresenceType presence);
	void updatePresenceToVCard( const std::string jid, const std::string& resource, Presence::PresenceType presence);
	void updatePresence( const std::string jid, const std::string& resource, Presence::PresenceType presence);
	void setPresence( const std::string jid, KPresenceType presence);
	void fixedGroupsPerhaps(const Roster& roster);
	void push_roster_to_friend_tree( const Roster &contacts, contact_tree_map &the_contact_tree);
	void fixed_roster( const Roster& roster );
	ContactMap::iterator addEmptyVCard( std::string jid_string, SubscriptionType subscription );
	void updateSelfPrsenceToJson( bool notice_ui = false );
	SubscriptionType syncget_subscription(std::string jid_string);
	void apply_privacy(json::jobject& jobj);

private:
	_DECLARE_E();

private:
	static void reorganize_result(json::jobject *ret, std::string key, json::jobject value);
	StringList trans_group_name( KContactType newtype, const RosterItem* item);
	void appendUnkownContactList(json::jobject& jobj, contact_tree_map &the_contact_tree, std::string key, json::jobject val);
	json::jobject fill_search_field(const gloox::Tag* org_tag);

	json::jobject device_list_;
private:
	/*
		privacy_jobj_["jids"]
		privacy_jobj_["orders"]
	*/
	json::jobject privacy_jobj_;
	bool roster_is_ready_;
	bool privacy_is_ready_;
	bool device_is_ready_;
};

}; // biz
