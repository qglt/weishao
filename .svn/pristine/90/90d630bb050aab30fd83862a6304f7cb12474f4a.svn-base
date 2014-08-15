
#pragma once
#include "boost/shared_ptr.hpp"
#include <base/epiusdb/ep_sqlite.h>
#include "anan_biz_bind.h"
#include "agent_type.h"
#include "anan_type.h"
#include "an_roster_manager_type.h"
#include "user_type.h"
#include <string>
#include <list>
#include <map>
#include "gloox_src/rosterlistener.h"
#include "sqlite_connections.h"
#include "base/utility/singleton/singleton.hpp"
#include <string>
#include <base/thread/time_thread/time_thread.h>

namespace biz {
static const std::string s_rootConfigName = "common.dat";
static const std::string s_userConfigName = "user/%s/user.dat";
static const std::string s_userHistoryName = "user/%s/history.dat";
#ifdef _WIN32
static const std::string s_userCourseName = "user/%s/courses.dat";
#endif
static const std::string s_userCacheDir = "cache";
static const std::string message_conversation = "conversation";
static const std::string message_group_chat = "group_chat";
static const std::string message_crowd_chat = "crowd_chat";
static const std::string message_notice = "notice";
static const std::string s_local_log =  "log";

using namespace gloox;

struct anan_biz_impl;
struct TLocalConfigImpl;
enum KUserHeadType{khead_boy_teacher, khead_gril_teacher, khead_boy_student, khead_gril_student};
enum KMsgReadState{kmrs_unknown, kmrs_read, kmrs_recv};

class LocalConfig : protected anan_biz_bind<anan_biz_impl>
{
	BIZ_FRIEND();
public:
	LocalConfig(void);
	virtual ~LocalConfig(void);

public:
	void init();
	void uninit();

public: // 登录用户列表存取。
	void loadLocalUsers(std::list<Tuser_info>& list);
	void ui_loadLocalUsers(const std::string& jid, boost::function<void(json::jobject)> callback);

	void saveSamUser(Tuser_info user);
	void saveLocalUser(Tuser_info user);
	void saveUserAvatar(Tuser_info user);
	void ui_saveLocalUser(const std::string& jid, bool autologin, boost::function<void(json::jobject)> callback);
	bool saveAnanDir(const std::string& target_dir);
	bool isNeedSaveUserInfo();
	std::string removeUser(const std::string& userName);
	std::string get_show_name();
	void loadCurRoster( ContactMap& contactInfos_ );
	void scheduleSaveRoster( std::string jid_string, json::jobject& jobj );
	void processSaveRoster();
	void doSaveRoster();
	void updateMessage( std::string rowid, std::string type_string, json::jobject msg );
private:
	void loadUnreadSystemMessageCount(boost::function<void(json::jobject)> callback);	
	void loadUnreadAppMessageCount(boost::function<void(json::jobject)> callback);
	void loadUnreadLightappMessageCount(json::jobject &jobj);
	void create_userHistoryDB();
	void create_userConfigDB();
	void create_rootConfigDB();
public:
	//存储系统消息 好友请求
	std::string saveRequestMsg( std::string jid_string, json::jobject& jobj );
	void update_request_msg(std::string rowid,std::string operate);
	void replaceRequestMsg( std::string jid_string, json::jobject& jobj ,std::string rowid);
	void loadALLSystemtMsg(std::string type, int offset, int count, boost::function<void(json::jobject,bool,universal_resource)> callback);
	void loadAllUnreadSystemMsg(std::string type, boost::function<void(json::jobject,bool,universal_resource)> callback);
	void updateSystemMsgIsread(std::string rowid,boost::function<void(bool err, universal_resource)> callback);
	void loadOneSystemMsg(std::string rowid,boost::function<void(json::jobject,bool,universal_resource)> callback);
	void deleteAllRequestMsg(std::string type, boost::function<void(bool err, universal_resource)> callback);
	void deleteOneRequestMsg(std::string rowid,boost::function<void(bool err, universal_resource)> callback);
	bool deleteRecentContact(const std::string jid_string);
	//从history数据库中groupmsg表中获取所有讨论组的jid
	void get_quit_group_list(json::jobject jobj,json::jobject& quit_group_jobj);
#ifndef _WIN32
	bool deleteSystemRecentContact();
#endif
	void saveData(std::string id, std::string data);
	void deleteData( std::string id);
	std::string loadData( std::string id );
	void saveGlobalData(std::string id, std::string data);
	std::string loadGlobalData( std::string id );
	void saveSendMessage(std::string type_string,  std::string jidTo, std::string subid, json::jobject msg );
	void saveRecvMessage(std::string type_string,  std::string jidFrom, std::string subid, json::jobject msg);
	void updateMessageShowname(std::string jid, std::string showname, std::string name);
	void fixMessageShowname();

	void saveChatGroupMessage(std::string group_name,  std::string jid, std::string subid, std::string showname, json::jobject msg, std::string id, bool is_send);
	void saveCrowdMessage(std::string crowd_name,  std::string jid, std::string subid, std::string showname, json::jobject msg, std::string id, bool is_send);
	void get_quit_crowd_list( json::jobject jobj,json::jobject& quit_crowd_jobj);
	void UpdateCrowdName(std::string session_id, std::string crowdname);
	json::jobject getLastCrowd(json::jobject jobj);
	void getLastCrowd(std::map<std::string, std::string>& msg);

	bool isChatGroupMessageExist(std::string jid, std::string subid, std::string id);
	bool isCrowdMessageExist(std::string jid, std::string subid, std::string id);
	void UpdateChatGroupName(std::string session_id, std::string groupname);
	void MarkOneNoticeAsRead(std::string id_string);
	std::string save_notice_message( std::string notice_id, std::string publisher_id,std::string msg,std::string expired_time,std::string priority );

	//保存第三方消息
	void SaveAppMessage( std::string message_id, std::string service_id, std::string service_name, std::string service_icon, std::string msg, std::string timestamp);
	void SaveAppMessage( std::string message_id, std::string service_id, std::string service_name, std::string service_icon, std::string msg, std::string timestamp, bool is_has_read);
	void MarkAppMessage(std::string service_id, std::string message_id, boost::function<void(bool err, universal_resource)> callback);
	void DeleteAppMessageByID(std::string message_id, boost::function<void(bool err, universal_resource)> callback);
	void DeleteAppMessageByServiceID(std::string service_id, boost::function<void(bool err, universal_resource)> callback);
	void DeleteAllAppMessageByID(boost::function<void(bool err, universal_resource)> callback);
	void DeleteAllReadedAppMessage(boost::function<void(bool err, universal_resource)> callback);
	void GetAppMessageHistory(std::string service_id, int begin_idx, int count, boost::function<void(bool err, json::jobject)> callback);
	void GetUnreadAppMessage(std::string service_id, boost::function<void(bool err, json::jobject)> callback);
	void loadAllUnreadAppMessage(bool count_only, boost::function<void(bool err, json::jobject)> callback);
	void GetRecentAppMessages(boost::function<void(bool err, json::jobject)> callback);
	void GetUnreadAppMessageCountByServiceID(std::string service_id, json::jobject jobj);
	std::string SaveAppNoticeMessage( std::string notice_id, std::string publisher, std::string msg, std::string expired_time, std::string priority);

	//Lightapp 消息接口
	int SaveLightappMessage( std::string appid, bool is_send, json::jobject msg, std::string msgid);
	void loadUnreadLightappMessage(std::string appid, bool mark_read, boost::function<void(json::jobject)> callback);
	void GetLightappMessageHistory(std::string appid, int begin_idx, int count, boost::function<void(bool err, json::jobject)> callback);

	bool isLightAppMessageExist(std::string appid, std::string msg_id);
	void DeleteLightappMessage(std::string appid, std::string rowid, boost::function<void(bool err, universal_resource)> callback);


	//获取收到的历史通知
	void LoadMessage( std::string type_string, std::string id_string, int offset, int count, json::jobject& jobj, KMsgReadState mrs = kmrs_unknown );
	//删除单条通话记录双人会话 讨论组 群
	void deleteOneConvMsg(std::string type_string,std::string rowid,boost::function<void(bool err, universal_resource)> callback);
	void deleteAllConvMsg(std::string type_string,std::string jid,std::string priority,boost::function<void(bool err, universal_resource)> callback);
	//取发送历史消息
	void LoadpublishMessage( std::string id_string, json::jobject& jobj);
	void MarkMessageRead(std::string type_string, std::string id_string);
	void removeMessageBy(std::string type_string, std::string whereString);
	void LoadPublish(int offset,int count, boost::function<void(json::jobject)> callback);
	void loadUnreadNoticeCount(bool important_notice, boost::function<void(json::jobject)> callback);
	void loadUnreadNotice(bool important_notice, int offset,int count, boost::function<void(json::jobject)> callback);

	void deleteConversationHistory(std::string jid, boost::function<void(bool err, universal_resource)> callback);
	void deleteNoticeHistory(std::string notice_id, boost::function<void(bool err, universal_resource)> callback);
	void deleteAllNotice(boost::function<void(bool err, universal_resource)> callback);
	void deleteAllReadedNotice(boost::function<void(bool err, universal_resource)> callback);

	void replaceMessageByRowid(std::string type, std::string rowid, std::string msg, boost::function<void(bool err, universal_resource)> callback);

	json::jobject getLastConversation();
	json::jobject getLastConversation(json::jobject jobj);
	json::jobject getLastGroup(json::jobject jobj);

	void getLocalContactList(boost::function<void(bool err, universal_resource, json::jobject)> callback);
	void createDirectories();
	std::string getCurrentTime();
	void saveOrganizationData( int parentid, json::jobject jobj, std::string time);
	json::jobject loadOrganizationData( int parentid);
	void saveFileTransferMsg( std::string jid, std::string msg, boost::function<void(json::jobject)> callback);
	void uninitdbs();
protected:
	void connected();
	void disconnection(universal_resource res);
	void loadRecentContact( RecentRoster& recentContact );
	void saveMessage( std::string jid, std::string subid, std::string type_string, bool is_send, json::jobject msg);
	
	void LoadAscMessage(std::string type_string, std::string id_string, int rowid, int offset, int count, json::jobject& jobj,KMsgReadState mrs );
	
	//取发送历史通知
	void LoadpublishDescMessage(epius::epius_sqlite3::epDb& cur_epdb,std::string id_string,json::jobject& jobj);
	//获取接收历史通知
	json::jobject LoadDescNoticeMessage(int offset, int count);
	json::jobject LoadOneNoticeMessage(std::string id_string);
	void LoadDescMessage(std::string type_string, std::string id_string, int rowid, int offset, int count, json::jobject& jobj,KMsgReadState mrs );	
	unsigned long LoadMessageCount_(std::string type_string, std::string id_string, KMsgReadState mrs);
	void LoadUnreadMessageCount(json::jobject& jobj);
	void fixedUserInfoForSaveIt(Tuser_info& user_info);
	void initdbs();
	void savePublish(int id, json::jobject jobj );
	int LoadPublishCount();
private:
	void LoadUnreadMessageCount(std::string type_string, json::jobject& jobj);
	boost::shared_ptr<TLocalConfigImpl> impl_;
	std::wstring createsql_;
	std::map<std::string, std::vector<std::wstring> > createindexsql_;
	std::wstring insertsql_;
	std::wstring insert_notice_sql_;
	std::wstring deletesql_;
	std::wstring selectsql_;
	std::wstring countsql_;
	std::wstring makereadsql_;
	std::wstring unreadsql_;
	std::map<std::string, std::string> pendingSaveRoster_;
};

}; // biz
