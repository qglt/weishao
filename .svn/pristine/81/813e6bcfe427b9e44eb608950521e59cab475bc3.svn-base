#include <boost/filesystem/operations.hpp>
#include <boost/date_time/time_clock.hpp>
#include <boost/date_time/posix_time/ptime.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/format.hpp>
#include <boost/thread/thread_time.hpp>
#include <base/json/tinyjson.hpp>
#include <base/txtutil/txtutil.h>
#include "an_roster_manager.h"
#include "an_roster_manager_type.h"
#include "local_config.h"
#include "biz_sql.h"
#include "anan_assert.h"
#include "login.h"
#include "anan_biz_impl.h"
#include "an_roster_manager.h"
#include "an_roster_manager_impl.h"
#include "user.h"
#include "user_impl.h"
#include <deque>
#include "client_anan.h"
#include "gloox_src/rosterlistener.h"
#include "agent.h"
#include "agent_impl.h"
#include "anan_type.h"
#include "sqlite_connections.h"
#include "base/module_path/file_manager.h"
#include "base/log/elog/elog.h"
#include <base/thread/time_thread/time_thread_mgr.h>
#include "conversation.h"
#include "boost/date_time/posix_time/ptime.hpp"
#include "biz_app_data.h"
#include <boost/lambda/lambda.hpp>
#include "notice_msg_ack.h"
#include <base/utility/bind2f/bind2f.hpp>
#include "discussions.h"
#include "whistle_vcard.h"
#include "base/module_path/epfilesystem.h"
#include "gloox_wrap/glooxWrapInterface.h"
#include "notice_msg.h"
#include "base/http_trans/http_request.h"
#include "anan_config.h"
#include "crowd.h"
#ifdef _WIN32
#include <windows.h>
#endif
#include <base/time/time_format.h>
using namespace epius::epius_sqlite3;
using namespace epius;
namespace biz {

	struct TLocalConfigImpl
	{
		TLocalConfigImpl()
		{
			needSaveUserInfo_ = false;
		}
		~TLocalConfigImpl()
		{
		}
		std::wstring get_tablename_by_type(std::string chattype)
		{
			if(chattype.compare("conversation") == 0)
			{
				return biz_sql::s_tablename_message;
			}
			else if (chattype.compare("group_chat") == 0)
			{
				return biz_sql::s_tablename_group;
			}
			else if (chattype.compare("crowd_chat") == 0)
			{
				return biz_sql::s_tablename_crowd;
			}
			else if (chattype.compare("lightapp") == 0)
			{
				return biz_sql::s_tablename_lightapp;
			}
			else if (chattype.compare("notice") == 0)
			{
				return biz_sql::s_tablename_notice;
			}
			else
			{
				ELOG("app")->error("preparesql.bad.type.string -- " + chattype);
				return L"";
			}
		}
		std::string curUserDir_; // 当前登录的用户数据目录。
		bool needSaveUserInfo_; // 需要保存用户信息。
	};

	LocalConfig::LocalConfig(void):impl_(new TLocalConfigImpl)
	{
	}


	LocalConfig::~LocalConfig(void)
	{
	}

	void LocalConfig::loadLocalUsers(std::list<Tuser_info>& list)
	{
		if(!db_connection::instance().get_db(s_rootConfigName))
		{
			ELOG("app")->error("Cannot load user login history because db is NULL");
			return;
		}
		list.clear();
		epDb& cur_epdb = *db_connection::instance().get_db(s_rootConfigName);
		try
		{
			data_iterator dt = cur_epdb.execQuery(biz_sql::s_sqlSelectAccounts);
			while(dt!=data_iterator())
			{
				Tuser_info tui(dt);
				++dt;
				list.push_back(tui);
			}
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"获取本地帐号错误") + err.what());
		}
	}

	void LocalConfig::fixedUserInfoForSaveIt(Tuser_info& user_info)
	{
		// fixed passwd to empty if needn't save passwd.
		if (!user_info.savePasswd)
		{
			user_info.password.clear();
		}
	}

	void LocalConfig::saveSamUser(Tuser_info user)
	{
		IN_TASK_THREAD_WORKx(LocalConfig::saveSamUser, user);
		if(!db_connection::instance().get_db(s_rootConfigName))
		{
			ELOG("app")->error("Cannot saveSamUser because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_rootConfigName);

		fixedUserInfoForSaveIt(user);
		try
		{
			data_iterator it = cur_epdb.execQuery(biz_sql::s_sqlSelectUserFromAccountsByName, epDbBinder(user.sam_id));
			int ncount = cur_epdb.execDML(biz_sql::s_sqlUpdateUserAccountByName, epDbBinder(user.last_login_time, user.password, user.presence, user.auto_login, user.savePasswd,user.sam_id));
			if(ncount==0)
			{		
				cur_epdb.execDML(biz_sql::s_sqlInsertAccounts,user.TieAll());
			}
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"保存用户数据到登录历史表出错,原因是:") + err.what());
		}
	}

	void LocalConfig::saveUserAvatar(Tuser_info user_info)
	{
		IN_TASK_THREAD_WORKx(LocalConfig::saveUserAvatar, user_info);
		if(!db_connection::instance().get_db(s_rootConfigName))
		{
			ELOG("app")->error("Cannot saveLocalUser because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_rootConfigName);
		try
		{
			if(!user_info.user_id.empty() && !user_info.avatar_file.empty())
			{
				cur_epdb.execDML(biz_sql::s_sqlUpdateHeadForAccounts, epDbBinder(user_info.avatar_file, user_info.user_id));
			}
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"保存用户数据到登录历史表出错,原因是:") + err.what());
		}
	}

	void LocalConfig::saveLocalUser( Tuser_info user )
	{
		IN_TASK_THREAD_WORKx(LocalConfig::saveLocalUser, user);
		if(!db_connection::instance().get_db(s_rootConfigName))
		{
			ELOG("app")->error("Cannot saveLocalUser because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_rootConfigName);

		Tuser_info user_info = user;
		fixedUserInfoForSaveIt(user_info);
		try
		{
			int ncount = cur_epdb.execDML(biz_sql::s_sqlUpdateAccountByName, epDbBinder(user_info.last_login_time, user_info.password, user_info.presence, user_info.auto_login, user_info.savePasswd,user_info.user_id,user_info.sam_id));
			if(ncount==0)
			{				
				cur_epdb.execDML(biz_sql::s_sqlInsertAccounts,user_info.TieAll());
			}
			if(!user_info.user_id.empty() && !user_info.avatar_file.empty())
			{
				cur_epdb.execDML(biz_sql::s_sqlUpdateHeadForAccounts, epDbBinder(user_info.avatar_file, user_info.user_id));
			}
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"保存用户数据到登录历史表出错,原因是:") + err.what());
		}
		impl_->needSaveUserInfo_ = false;
	}

	void LocalConfig::init()
	{
		get_parent_impl()->bizLogin_->conn_msm_.connected_signal_.connect(boost::bind(&LocalConfig::connected,this));
		get_parent_impl()->bizLogin_->conn_msm_.disconnected_signal_.connect(boost::bind(&LocalConfig::disconnection, this, _1));
		get_parent_impl()->_p_private_task_->post(boost::bind(&db_connection_impl::add, boost::ref(db_connection::instance()),s_rootConfigName,"", s_rootConfigName));		
	}

	void LocalConfig::uninit()
	{
		get_parent_impl()->bizLogin_->conn_msm_.connected_signal_.disconnect(&LocalConfig::connected);
		get_parent_impl()->bizLogin_->conn_msm_.disconnected_signal_.disconnect(&LocalConfig::disconnection);
	}

	void LocalConfig::connected()
	{	
		initdbs();	
		get_parent_impl()->bizLocalConfig_->saveLocalUser(get_parent_impl()->bizUser_->get_user());
		impl_->needSaveUserInfo_ = true;
		epius::time_mgr::instance().set_timer(30000, bind2f(&LocalConfig::fixMessageShowname, this));
	}

	void LocalConfig::disconnection(universal_resource res)
	{
		if (!pendingSaveRoster_.empty())
		{
			doSaveRoster();
		}
	}

	std::string LocalConfig::removeUser( const std::string& userName )
	{
		if(!db_connection::instance().get_db(s_rootConfigName))
		{
			ELOG("app")->error("Cannot removeUser because db is NULL");
			return "";
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_rootConfigName);
		try
		{
			data_iterator it = cur_epdb.execQuery( biz_sql::s_sqlSelectUserFromAccountsByName, epDbBinder(userName));
			Tuser_info info;
			info.TieAll() = it;
			cur_epdb.execDML( biz_sql::s_sqlDeleteAccountsOnSamID, epDbBinder(epius::txtutil::convert_utf8_to_wcs(userName)));
			return info.anan_id;
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"删除用户帐号错误") + err.what());
			return "";
		}
	}

	void LocalConfig::uninitdbs()
	{
		db_connection::instance().remove(s_userConfigName);
		db_connection::instance().remove(s_userHistoryName);
		impl_->curUserDir_.clear();
	}

	void LocalConfig::initdbs()
	{
		uninitdbs();
		createDirectories();
		std::string strAnId = get_parent_impl()->bizUser_->get_user().anan_id;
		db_connection::instance().add(s_userConfigName, file_manager::instance().get_config_dir().get<1>(), (boost::format(s_userConfigName)%strAnId).str());
		db_connection::instance().add(s_userHistoryName, file_manager::instance().get_config_dir().get<1>(),(boost::format(s_userHistoryName)%strAnId).str());
		create_userHistoryDB();  //"user/%s/history.dat";
		create_userConfigDB();  //"user/%s/user.dat";
		create_rootConfigDB();  //"common.dat";
	}
	void LocalConfig::create_userHistoryDB()
	{
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("cannot open database "+ s_userHistoryName);
			return;
		}

		static std::wstring sql_create_conversation =   // create
			L"create table if not exists conversation " \
			L"(" \
			L"   jid      varchar(252)," \
			L"   subid    varchar(252)," \
			L"   is_read  bool," \
			L"   is_send  bool," \
			L"   showname varchar(252)," \
			L"   msg      text," \
			L"   dt       char(19)" \
			L");";

		static std::wstring sql_create_crowd =   // create
			L"create table if not exists crowdmsg " \
			L"(" \
			L"   jid      varchar(252)," \
			L"   subid    varchar(252)," \
			L"   is_read  bool," \
			L"   is_send  bool," \
			L"   showname varchar(252)," \
			L"   msg      text," \
			L"   dt       char(19)," \
			L"   crowdname    varchar(252),"\
			L"   id    varchar(252)"
			L");";
		static std::wstring s_sqlCreateRequestFriends =   // create systemmessage
			L"create table if not exists systemmessage " \
			L"(" \
			L"   jid  varchar(252)," \
			L"   info text," \
			L"   extra_info text," \
			L"   time char(19),"\
			L"   server_time char(19)," \
			L"   msg_type char(19)," \
			L"   is_read  bool" \
			L");";

		static std::wstring s_sqlCreateRecentContact =   // create
			L"create table if not exists recentcontact " \
			L"(" \
			L"   jid  varchar(252)," \
			L"   type integer," \
			L"   time char(19)," \
			L"   primary key (jid,type)" \
			L");";

		static std::wstring s_sqlCreateGroupMessage =   // create
			L"create table if not exists groupmsg " \
			L"(" \
			L"   jid      varchar(252)," \
			L"   subid    varchar(252)," \
			L"   is_read  bool," \
			L"   is_send  bool," \
			L"   showname varchar(252)," \
			L"   msg      text," \
			L"   dt       char(19)," \
			L"   groupname    varchar(252),"\
			L"   id    varchar(252)"
			L");";

		static std::wstring sql_create_lightapp =   // create
			L"create table if not exists lightapp " \
			L"(" \
			L"   appid    varchar(252)," \
			L"   is_read  bool," \
			L"   is_send  bool," \
			L"   msg      text," \
			L"   dt       integer," \
			L"   id       varchar(252)" \
			L");";

		static std::wstring sql_conv_index1 = L"create index if not exists conversation_index1 on conversation(jid);";
		static std::wstring sql_conv_index2 = L"create index if not exists conversation_index2 on conversation(subid);";
		static std::wstring sql_conv_index3 = L"create index if not exists conversation_index3 on conversation(is_read);";
		static std::wstring sql_conv_index4 = L"create index if not exists conversation_index4 on conversation(is_send);";
		static std::wstring sql_conv_index5 = L"create index if not exists conversation_index5 on conversation(showname);";
		static std::wstring sql_conv_index6 = L"create index if not exists conversation_index6 on conversation(dt);";

		static std::wstring sql_group_index1 = L"create index if not exists groupmsg_index1 on groupmsg(jid);";
		static std::wstring sql_group_index2 = L"create index if not exists groupmsg_index2 on groupmsg(subid);";
		static std::wstring sql_group_index3 = L"create index if not exists groupmsg_index3 on groupmsg(is_read);";
		static std::wstring sql_group_index4 = L"create index if not exists groupmsg_index4 on groupmsg(is_send);";
		static std::wstring sql_group_index5 = L"create index if not exists groupmsg_index5 on groupmsg(showname);";
		static std::wstring sql_group_index6 = L"create index if not exists groupmsg_index6 on groupmsg(dt);";
		static std::wstring sql_group_index7 = L"create index if not exists groupmsg_index7 on groupmsg(groupname);";
		static std::wstring sql_group_index8 = L"create index if not exists groupmsg_index8 on groupmsg(id);";

		static std::wstring sql_crowd_index1 = L"create index if not exists crowdmsg_index1 on crowdmsg(jid);";
		static std::wstring sql_crowd_index2 = L"create index if not exists crowdmsg_index2 on crowdmsg(subid);";
		static std::wstring sql_crowd_index3 = L"create index if not exists crowdmsg_index3 on crowdmsg(is_read);";
		static std::wstring sql_crowd_index4 = L"create index if not exists crowdmsg_index4 on crowdmsg(is_send);";
		static std::wstring sql_crowd_index5 = L"create index if not exists crowdmsg_index5 on crowdmsg(showname);";
		static std::wstring sql_crowd_index6 = L"create index if not exists crowdmsg_index6 on crowdmsg(dt);";
		static std::wstring sql_crowd_index7 = L"create index if not exists crowdmsg_index7 on crowdmsg(crowdname);";
		static std::wstring sql_crowd_index8 = L"create index if not exists crowdmsg_index8 on crowdmsg(id);";

		static std::wstring sql_recent_index1 = L"create index if not exists recentcontact_index1 on recentcontact(jid);";
		static std::wstring sql_recent_index2 = L"create index if not exists recentcontact_index2 on recentcontact(type);";
		static std::wstring sql_recent_index3 = L"create index if not exists recentcontact_index3 on recentcontact(time);";

		static std::wstring sql_lightapp_index1 = L"create index if not exists lightapp_index1 on lightapp(appid);";


		static std::wstring s_sqlCreateNoticeMessage =   // create
			L"create table if not exists notice " \
			L"(" \
			L"   notice_id				varchar," \
			L"   publisher_id			varchar," \
			L"   is_read				varchar," \
			L"   publisher_show_name	varchar," \
			L"   msg					text," \
			L"   dt						varchar," \
			L"   expired_time			varchar," \
			L"   priority				varchar" \
			L");";

		const std::wstring s_sqlCreatePublish = // create publish.
			L"create table if not exists publish "\
			L"(" \
			L"   id integer,"\
			L"   title varchar(256),"\
			L"   signature varchar(256),"\
			L"   priority varchar(256),"\
			L"   identity varchar(256),"\
			L"   html text,"\
			L"   expired_time varchar(256),"\
			L"   body text,"\
			L"   address text,"\
			L"   dt char(19)"\
			L");";

		const std::wstring s_sqlCreateOrg = // create organization.
			L"create table if not exists organization "\
			L"(" \
			L"   parentid integer,"\
			L"   info text,"\
			L"   time varchar(256)"\
			L");";

		const std::wstring s_sqlCreateAppMessage =   // create
			L"create table if not exists app_message " \
			L"(" \
			L"   id				varchar(252)," \
			L"   service_id		varchar(252)," \
			L"   service_name	varchar(252)," \
			L"   service_icon	varchar(252)," \
			L"   is_read		bool," \
			L"   msg			text," \
			L"   send_time		char(19)," \
			L"   dt				char(19)" \
			L");";

		try
		{
			epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
			boost::shared_ptr<epDbTrans> trans = cur_epdb.beginTrans();
			cur_epdb.execQuery( sql_create_conversation);
			cur_epdb.execQuery( sql_create_crowd);
			cur_epdb.execQuery( s_sqlCreateRequestFriends);
			cur_epdb.execQuery( s_sqlCreateRecentContact);
			cur_epdb.execQuery( s_sqlCreateGroupMessage);
			cur_epdb.execQuery( sql_create_crowd);
			cur_epdb.execQuery( s_sqlCreateNoticeMessage);
			cur_epdb.execQuery( s_sqlCreatePublish);
			cur_epdb.execQuery( s_sqlCreateOrg);
			cur_epdb.execQuery( s_sqlCreateAppMessage);

			cur_epdb.execQuery( sql_conv_index1);
			cur_epdb.execQuery( sql_conv_index2);
			cur_epdb.execQuery( sql_conv_index3);
			cur_epdb.execQuery( sql_conv_index4);
			cur_epdb.execQuery( sql_conv_index5);
			cur_epdb.execQuery( sql_conv_index6);

			cur_epdb.execQuery( sql_group_index1);
			cur_epdb.execQuery( sql_group_index2);
			cur_epdb.execQuery( sql_group_index3);
			cur_epdb.execQuery( sql_group_index4);
			cur_epdb.execQuery( sql_group_index5);
			cur_epdb.execQuery( sql_group_index6);
			cur_epdb.execQuery( sql_group_index7);
			cur_epdb.execQuery( sql_group_index8);

			cur_epdb.execQuery( sql_crowd_index1);
			cur_epdb.execQuery( sql_crowd_index2);
			cur_epdb.execQuery( sql_crowd_index3);
			cur_epdb.execQuery( sql_crowd_index4);
			cur_epdb.execQuery( sql_crowd_index5);
			cur_epdb.execQuery( sql_crowd_index6);
			cur_epdb.execQuery( sql_crowd_index7);
			cur_epdb.execQuery( sql_crowd_index8);


			cur_epdb.execQuery( sql_recent_index1);
			cur_epdb.execQuery( sql_recent_index2);
			cur_epdb.execQuery( sql_recent_index3);

			cur_epdb.execQuery( sql_create_lightapp);
			cur_epdb.execQuery( sql_lightapp_index1);

		}
		catch(std::exception const&)
		{
			ELOG("app")->error("can not create tables for create_userHistoryDB");
			return;
		}
	}
	void LocalConfig::create_userConfigDB()
	{
		if(!db_connection::instance().get_db(s_userConfigName))
		{
			ELOG("app")->error("cannot open database "+s_userConfigName);
			return;
		}
		static std::wstring s_sqlCreateRoster =   // create
			L"create table if not exists roster " \
			L"(" \
			L"   jid  varchar(252) primary key," \
			L"   info text," \
			L"   time char(19)" \
			L");";
		static std::wstring s_sqlCreateSpecial =   // create
			L"create table if not exists special " \
			L"(" \
			L"   id  varchar(252) primary key," \
			L"   data blob" \
			L");";

		try
		{
			epDb& cur_epdb = *db_connection::instance().get_db(s_userConfigName);
			boost::shared_ptr<epDbTrans> trans = cur_epdb.beginTrans();
			cur_epdb.execQuery( s_sqlCreateRoster);
			cur_epdb.execQuery( s_sqlCreateSpecial);
		}
		catch(std::exception const&)
		{
			ELOG("app")->error("can not create tables for create_userConfigDB");
			return;
		}

	}
	void LocalConfig::create_rootConfigDB()
	{
		if(!db_connection::instance().get_db(s_rootConfigName))
		{
			ELOG("app")->error("cannot open database "+s_rootConfigName);
			return;
		}
		static std::wstring s_sqlCreateAccounts = 
			L"create table if not exists accounts " \
			L"(" \
			L"   last_login_time     VARCHAR," \
			L"   user_id			 VARCHAR," \
			L"   password			 VARCHAR," \
			L"   presence			 INTEGER," \
			L"   auto_login			 INTEGER, " \
			L"   save_password		 INTEGER," \
			L"   avatar_file		 VARCHAR," \
			L"   sam_id				 VARCHAR," \
			L"   anan_id			 VARCHAR" \
			L");";
		static std::wstring s_sqlCreateSpecial =   // create
			L"create table if not exists special " \
			L"(" \
			L"   id  varchar(252) primary key," \
			L"   data blob" \
			L");";
		static std::wstring s_sqlCreateUserDataDir =   // create
			L"create table if not exists userDataDir " \
			L"(" \
			L"   path       varchar(1020) primary key" \
			L");";
		try
		{
			epDb& cur_epdb = *db_connection::instance().get_db(s_rootConfigName);
			boost::shared_ptr<epDbTrans> trans = cur_epdb.beginTrans();
			cur_epdb.execQuery( s_sqlCreateAccounts);
			cur_epdb.execQuery( s_sqlCreateSpecial);
			cur_epdb.execQuery( s_sqlCreateUserDataDir);
		}
		catch(std::exception const&)
		{
			ELOG("app")->error("can not create tables for create_rootConfigDB");
			return;
		}
	}
	void LocalConfig::createDirectories()
	{
		impl_->curUserDir_ = file_manager::instance().get_config_dir().get<1>() + "user/" + get_parent_impl()->bizUser_->get_user().anan_id + "/";
		if (!epfilesystem::instance().file_exists(impl_->curUserDir_))
		{
			epfilesystem::instance().create_directories(impl_->curUserDir_);
		}
		std::string curUserImageDir = epfilesystem::instance().sub_path(file_manager::instance().get_config_dir().get<1>() ,file_manager::instance().get_user_image_dir());
		if(!epfilesystem::instance().file_exists(curUserImageDir))
		{
			epfilesystem::instance().create_directories(curUserImageDir);
		}
		std::string curUserVoiceDir = epfilesystem::instance().sub_path(file_manager::instance().get_config_dir().get<1>(),file_manager::instance().get_user_voice_dir());
		if(!epfilesystem::instance().file_exists(curUserVoiceDir))
		{
			epfilesystem::instance().create_directories(curUserVoiceDir);
		}
	}


	void LocalConfig::replaceRequestMsg( std::string jid_string, json::jobject& jobj ,std::string rowid)
	{
		IN_TASK_THREAD_WORKx(LocalConfig::replaceRequestMsg, jid_string ,jobj, rowid);
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot loadCurRequestFriends because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		std::wstring sqlUpdate = L"update systemmessage set info=?,extra_info=?,time=?,server_time=?,msg_type=?, is_read=? where rowid = ?;";
		std::string cur_time = getCurrentTime();
		std::string extra_info;
		std::string info;
		std::string server_time, msg_type;
		bool is_read = false;
		try
		{
			extra_info = jobj["extra_info"].get<std::string>();
			info = jobj["info"].to_string();
			server_time = jobj["server_time"].get<std::string>();	
			msg_type = jobj["msg_type"].get<std::string>();		
			is_read = jobj["is_read"].get<bool>();

			epDbBinder tmpBind = epDbBinder(info,extra_info,cur_time,server_time,msg_type,(int)is_read,rowid);
			cur_epdb.execDML( sqlUpdate,tmpBind);
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"好友请求信息错误") + err.what());
			return ;
		}


#ifndef _WIN32

		//专门给移动端提供的解决方案，type=100表示系统消息。
		std::wstring sql1 = L"delete from recentcontact where type = 100;";

		try
		{
			cur_epdb.execQuery( sql1);
		}
		catch (epius_dberror const& err)
		{
			ELOG("app")->error("删除系统消息在最近联系人列表失败。");
			return;
		}
		try
		{
			sql1 = L"insert into recentcontact(jid,type,time) values(?,100,?);";
			epDbBinder tmpBind1 = epDbBinder(jid_string,cur_time);
			cur_epdb.execQuery( sql1,tmpBind1);
		}
		catch (epius_dberror const& err)
		{
			ELOG("app")->error("把系统消息插入最近联系人列表失败。");
			return;
		}
		int rowCount = 0;
		try
		{
			data_iterator dtcount;

			dtcount = cur_epdb.execQuery( L"select count(*) from systemmessage where is_read=0");


			if (dtcount!=data_iterator())
			{
				rowCount = dtcount->getField<int>(0);
			}
			dtcount =data_iterator();

		}
		catch (epius_dberror const& err)
		{
			ELOG("app")->error("无法获取未读系统消息数目。");
			rowCount = 0;
		}
		//通知界面最近联系人更新
		json::jobject jobj1;
		jobj1["info"]["jid"] = jid_string;
		jobj1["unread_account"] = rowCount;
		jobj1["time"] = cur_time;
		jobj1["type"] = "system";
		jobj1["flag"] = "new";
		json::jobject sysmsg;
		sysmsg["info"] = info;
		sysmsg["extra_info"] = extra_info;
		sysmsg["msg_type"] = msg_type;
		sysmsg["jid"] = jobj1["info"]["jid"];
		sysmsg["time"] = cur_time;

		jobj1["msg"] = sysmsg;

		event_collect::instance().update_recent_contact(jobj1.clone());

#endif

	}


	std::string LocalConfig::saveRequestMsg( std::string jid_string, json::jobject& jobj )
	{
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot saveCurRoster because db is NULL");
			return "";
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		std::wstring sqlInsert = L"insert into systemmessage (jid,info,extra_info,time,server_time,msg_type,is_read) values (?,?,?,?,?,?,?);";
		std::string cur_time = getCurrentTime();
		std::string extra_info;
		std::string info;
		std::string server_time;
		std::string msg_type;
		bool is_read = false;
		std::string last_rowid;
		try
		{
			extra_info = jobj["extra_info"].get<std::string>();
			info = jobj["info"].to_string();
			server_time = jobj["server_time"].get<std::string>();	
			msg_type = jobj["msg_type"].get<std::string>();		
			is_read = jobj["is_read"].get<bool>();

			epDbBinder tmpBind = epDbBinder(jid_string,info,extra_info,cur_time,server_time,msg_type,(int)is_read);
			cur_epdb.execDML( sqlInsert,tmpBind);
			last_rowid = boost::lexical_cast<std::string>(cur_epdb.last_insert_rowid());

		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"好友请求信息错误") + err.what());
			return "";
		}

#ifndef _WIN32

		//专门给移动端提供的解决方案，type=100表示系统消息。
		std::wstring sql1 = L"delete from recentcontact where type = 100;";

		try
		{
			cur_epdb.execQuery( sql1);
		}
		catch (epius_dberror const& err)
		{
			ELOG("app")->error("删除系统消息在最近联系人列表失败。");
			return last_rowid;
		}
		try
		{
			sql1 = L"insert into recentcontact(jid,type,time) values(?,100,?);";
			epDbBinder tmpBind1 = epDbBinder(jid_string,cur_time);
			cur_epdb.execQuery( sql1,tmpBind1);
		}
		catch (epius_dberror const& err)
		{
			ELOG("app")->error("把系统消息插入最近联系人列表失败。");
			return last_rowid;
		}
		int rowCount = 0;
		try
		{
			data_iterator dtcount;

			dtcount = cur_epdb.execQuery( L"select count(*) from systemmessage where is_read=0");


			if (dtcount!=data_iterator())
			{
				rowCount = dtcount->getField<int>(0);
			}
			dtcount =data_iterator();

		}
		catch (epius_dberror const& err)
		{
			ELOG("app")->error("无法获取未读系统消息数目。");
			rowCount = 0;
		}

		//通知界面最近联系人更新
		json::jobject jobj1;
		jobj1["info"]["jid"] = jid_string;
		jobj1["unread_account"] = rowCount;
		jobj1["time"] = cur_time;
		jobj1["type"] = "system";
		jobj1["flag"] = "new";
		json::jobject sysmsg;
		sysmsg["info"] = info;
		sysmsg["extra_info"] = extra_info;
		sysmsg["msg_type"] = msg_type;
		sysmsg["jid"] = jobj1["info"]["jid"];
		sysmsg["time"] = cur_time;

		jobj1["msg"] = sysmsg;

		event_collect::instance().update_recent_contact(jobj1.clone());

#endif
		return last_rowid;
	}

	void LocalConfig::deleteAllRequestMsg(std::string type, boost::function<void(bool err, universal_resource)> callback)
	{
		IN_TASK_THREAD_WORKx(LocalConfig::deleteAllRequestMsg, type, callback);
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot loadCurRequestFriends because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);	
		std::wstring sql_type; 
		if (type == "crowd")
		{
			sql_type = L" where msg_type not in ( \"request\", \"reject\", \"agree\") ";
		}
		else if (type == "friend")
		{
			sql_type = L" where msg_type in ( \"request\", \"reject\", \"agree\") ";
		}

		const std::wstring s_sql_DeleteAllRequestMsg = L"delete from systemmessage" + sql_type;
		try
		{
			cur_epdb.execQuery(s_sql_DeleteAllRequestMsg);
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"删除全部消息记录失败") + err.what());
			callback(true,XL("deleteAllRequestMsg.error"));
			return;
		}
		callback(false,XL(""));

#ifndef _WIN32
		//针对移动端，通知会话页面
		json::jobject jobj;
		jobj["type"] = "system";
		jobj["flag"] = "empty";

		event_collect::instance().update_recent_contact(jobj.clone());

#endif
	}

	void LocalConfig::deleteOneRequestMsg(std::string rowid,boost::function<void(bool err, universal_resource)> callback)
	{
		IN_TASK_THREAD_WORKx(LocalConfig::deleteOneRequestMsg, rowid,callback);
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot loadCurRequestFriends because db is NULL");
			return;
		}
		const std::wstring s_sql_DeleteOneRequestMsg = L"delete from systemmessage where rowid = ?";
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		epDbBinder tmpBind;
		tmpBind = epDbBinder(rowid);
		try
		{
			cur_epdb.execQuery(s_sql_DeleteOneRequestMsg,tmpBind);
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"删除单条消息记录失败") + err.what());
			callback(true,XL("deleteOneRequestMsg.error"));
			return;
		}
		callback(false,XL(""));

#ifndef _WIN32
		data_iterator dt;
		data_iterator dtcount;
		int rowCount = 0;	
		try
		{
			dtcount = cur_epdb.execQuery(L"select count(*) from systemmessage");

			if(dtcount != data_iterator())
			{
				rowCount = dtcount->getField<int>(0);
			}
			dtcount =data_iterator();
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error("无法获取未读系统消息数目。");
			rowCount  = 0;
		}	
		//通知界面最近联系人更新
		json::jobject jobj;

		if(rowCount > 0)
		{
			std::string max_time = getCurrentTime();
			try
			{
				dt = cur_epdb.execQuery(L"select time from recentcontact where type = 100");

				if(dt!=data_iterator())
				{
					max_time = dt->getField<std::string>(0);	
				}

				dt = data_iterator();

			}
			catch (epius_dberror const& err)
			{
				ELOG("app")->error("通知会话列表出错，无法获取系统消息的最近时间。");
			}

			int newCount = 0;
			try
			{
				dtcount = cur_epdb.execQuery(L"select count(*) from systemmessage where is_read=0");


				if (dtcount!=data_iterator())
				{
					newCount = dtcount->getField<int>(0);
				}
				dtcount =data_iterator();

			}
			catch (epius_dberror const& err)
			{
				ELOG("app")->error("无法获取未读系统消息的数目。");
				newCount = 0;
			}

			try
			{
				dt = cur_epdb.execQuery(L"select jid, info, extra_info, msg_type, is_read, time from systemmessage where systemmessage.time = (select max(time) from systemmessage)");
				std::string jid_string;
				std::string extra_info;
				std::string info;
				std::string msg_type;
				std::string msg_time;
				int is_read = 0;
				std::string operate;

				if(dt!=data_iterator())
				{
					jid_string = dt->getField<std::string>(0);
					json::jobject info_jobj(dt->getField<std::string>(1));
					json::jobject extra_info_jobj(dt->getField<std::string>(2));
					if (info_jobj["info"])
					{
						info = info_jobj["info"].get<std::string>();
						extra_info = info_jobj["extra_info"].get<std::string>();
						operate = extra_info_jobj["operate"].get<std::string>();
					}
					else
					{
						info = dt->getField<std::string>(1);
						extra_info = dt->getField<std::string>(2);
						operate = "";
					}				
					msg_type = dt->getField<std::string>(3);
					is_read = dt->getField<int>(4);
					msg_time = dt->getField<std::string>(5);
				}

				dt = data_iterator();
				jobj["info"]["jid"] = jid_string;
				jobj["time"] = max_time;
				jobj["type"] = "system";
				jobj["flag"] = "update";
				jobj["unread_account"] = newCount;
				json::jobject sysmsg;
				sysmsg["info"] = info;
				sysmsg["extra_info"] = extra_info;
				sysmsg["msg_type"] = msg_type;
				sysmsg["jid"] = jobj["info"]["jid"];
				sysmsg["time"] = msg_time;
				sysmsg["operate"] = operate;
				jobj["msg"] = sysmsg;
			}
			catch (epius_dberror const& err)
			{
				ELOG("app")->error("通知会话列表失败，因为无法获取最近的系统消息内容。");
				return;
			}
		}
		else
		{
			jobj["type"] = "system";
			jobj["flag"] = "empty";
		}
		event_collect::instance().update_recent_contact(jobj.clone());
#endif
	}

	void LocalConfig::scheduleSaveRoster( std::string jid_string, json::jobject& jobj )
	{
		bool queueEmpty = pendingSaveRoster_.empty();

		std::map<std::string, std::string>::iterator it = pendingSaveRoster_.find(jid_string);
		if (it == pendingSaveRoster_.end())
		{
			pendingSaveRoster_.insert(make_pair(jid_string, jobj.to_string()));
		}
		else
		{
			it->second = jobj.to_string();
		}

		if (queueEmpty)
		{
			epius::time_mgr::instance().set_timer(20000, bind2f(&LocalConfig::processSaveRoster, this));
		}
	}

	void LocalConfig::doSaveRoster()
	{
		if(!db_connection::instance().get_db(s_userConfigName))
		{
			ELOG("app")->error("Cannot doSaveRoster because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userConfigName);
		try
		{
			std::map<std::string, std::string>::iterator it;
			boost::shared_ptr<epDbTrans> trans = cur_epdb.beginTrans();
			for (it = pendingSaveRoster_.begin(); it!= pendingSaveRoster_.end(); it++)
			{
				cur_epdb.execDML( biz_sql::s_sqlReplaceRoster, epDbBinder(it->first, it->second, getCurrentTime()));
			}

			pendingSaveRoster_.clear();
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"doSaveRoster 保存用户联系人错误") + err.what());
		}
	}

	void LocalConfig::processSaveRoster()
	{
		IN_TASK_THREAD_WORK0(LocalConfig::processSaveRoster);
		doSaveRoster();
	}

	void LocalConfig::loadCurRoster( ContactMap& the_vcards )
	{
		if(!db_connection::instance().get_db(s_userConfigName))
		{
			ELOG("app")->error("Cannot loadCurRoster because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userConfigName);
		try
		{
			data_iterator dt = cur_epdb.execQuery(biz_sql::s_sqlSelectRoster);
			while(dt!=data_iterator())
			{
				std::string jidString = dt->getField<std::string>(0); // 0: jid.
				std::string jsonString = dt->getField<std::string>(1); // 1: json.
				json::jobject jobj(jsonString);
				if (jobj)
				{
					ContactMap::iterator it = get_parent_impl()->bizRoster_->addEmptyVCard(jidString, S10nNone);
					// 标记vcard信息从服务端已经返回
					it->second.fetch_done_ = true;
					gwhistleVcard::instance().sync_replaceVCard(it->second.get_vcardinfo(), jobj);
				}
				++dt;
			}
		}catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"获取用户联系人错误") + err.what());
		}
	}


	void LocalConfig::loadALLSystemtMsg(std::string type, int offset, int count, boost::function<void(json::jobject,bool,universal_resource)> callback)
	{
		IN_TASK_THREAD_WORKx(LocalConfig::loadALLSystemtMsg,type,offset, count, callback);
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot loadCurRequestFriends because db is NULL");
			return;
		}

		std::wstring sql_type; 
		if (type == "crowd")
		{
			sql_type = L" where msg_type not in ( \"request\", \"reject\", \"agree\") ";
		}
		else if (type == "friend")
		{
			sql_type = L" where msg_type in ( \"request\", \"reject\", \"agree\") ";
		}

		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);	
		std::wstring sql_count = L"select count(*) from systemmessage" + sql_type;
		json::jobject jobj,jobj_data;
		int count_all;
		try
		{
			data_iterator dt_count = cur_epdb.execQuery(sql_count);
			jobj["count_all"] = dt_count->getField<std::string>(0);
			count_all = dt_count->getField<int>(0);
			dt_count = epius::epius_sqlite3::data_iterator();
		}
		catch(std::exception const&err)
		{
			ELOG("app")->error(WCOOL(L"LoadDescMessage读取数据库错误")+err.what());
		}
		std::wstring wstr_count = txtutil::convert_utf8_to_wcs((boost::format("%d")%count).str());
		std::wstring wstr_offect = txtutil::convert_utf8_to_wcs((boost::format("%d")%offset).str());
		std::wstring sql_all;

		if (offset == -1)
		{
			int first_offect = count_all - count;		
			wstr_offect = txtutil::convert_utf8_to_wcs((boost::format("%d")%first_offect).str());
			sql_all = L"select jid,info,extra_info,time,server_time,msg_type,rowid,is_read from systemmessage" + sql_type + L" order by time asc limit "+ wstr_offect+ L"," + wstr_count;
		}
		else
		{	
			sql_all = L"select jid,info,extra_info,time,server_time,msg_type,rowid,is_read from systemmessage" + sql_type + L" order by time asc limit "+ wstr_offect+ L"," + wstr_count;
		}

		try
		{
			data_iterator dt = cur_epdb.execQuery(sql_all);
			int i = 0;
			while(dt!=data_iterator())
			{
				json::jobject tmp_jobj;
				tmp_jobj["jid"] = dt->getField<std::string>(0); // 0: id.			
				json::jobject info_jobj(dt->getField<std::string>(1));
				json::jobject extra_info_jobj(dt->getField<std::string>(2));
				if (info_jobj["info"])
				{
					tmp_jobj["info"] = info_jobj["info"].get<std::string>(); // 1: info.
					tmp_jobj["extra_info"] = info_jobj["extra_info"].get<std::string>(); 
					tmp_jobj["operate"] = extra_info_jobj["operate"].get<std::string>();
				}
				else//兼容以前的数据库
				{
					tmp_jobj["info"] = dt->getField<std::string>(1); // 1: info.
					tmp_jobj["extra_info"] = dt->getField<std::string>(2); // 2: extra_info.
					tmp_jobj["operate"] = "";
				}			
				std::string date_time = dt->getField<std::string>(3); // 1: info
				tmp_jobj["last-time"] = date_time;
				tmp_jobj["date"] = date_time.substr(0,date_time.find(" "));
				tmp_jobj["time"] = date_time.substr(date_time.find(" ") + 1); // 1: info.
				tmp_jobj["server_time"] = dt->getField<std::string>(4); // 4: dt.
				tmp_jobj["msg_type"] = (dt->getField<std::string>(5)); // 5: subid.
				tmp_jobj["rowid"] = (dt->getField<std::string>(6)); // 5: subid.
				std::string is_read_string = (dt->getField<std::string>(7));//7: is_read
				tmp_jobj["is_read"] = is_read_string;
				jobj_data.arr_push(tmp_jobj);
				++dt;
				++i;
			}
#ifndef _WIN32
			//手机端分页后倒叙输出
			int k = i/2-1;
			json::jobject j;
			for (; k>=0; --k)
			{
				j = jobj_data[k];
				jobj_data[k] = jobj_data[i-k-1];
				jobj_data[i-k-1] = j;
			}
#endif
			jobj["data"] = jobj_data;
			callback(jobj,false,XL(""));
		}
		catch(std::exception const&err)
		{
			ELOG("app")->error(WCOOL(L"loadALLSystemtMsg读取数据库错误")+err.what());
			callback(jobj,true,XL(""));
		}
	}

	void LocalConfig::loadOneSystemMsg( std::string rowid,boost::function<void(json::jobject,bool,universal_resource)> callback )
	{
		IN_TASK_THREAD_WORKx(LocalConfig::loadOneSystemMsg, rowid, callback);
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot loadCurRequestFriends because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		epDbBinder tmpBind;
		tmpBind = epDbBinder(rowid);
		json::jobject jobj,jobj_data;
		try
		{
			data_iterator dt = cur_epdb.execQuery(biz_sql::s_sqlSelectOneRequest,tmpBind);
			json::jobject tmp_jobj;
			tmp_jobj["jid"] = dt->getField<std::string>(0); // 0: jid.		
			json::jobject info_jobj(dt->getField<std::string>(1));
			json::jobject extra_info_jobj(dt->getField<std::string>(2));
			if (info_jobj["info"])
			{
				tmp_jobj["info"] = info_jobj["info"].get<std::string>(); 
				tmp_jobj["extra_info"] = info_jobj["extra_info"].get<std::string>(); 
				tmp_jobj["operate"] = extra_info_jobj["operate"].get<std::string>();
			}
			else//兼容以前的数据库
			{
				tmp_jobj["info"] = dt->getField<std::string>(1); // 1: info.
				tmp_jobj["extra_info"] = dt->getField<std::string>(2); // 2: extra_info.
				tmp_jobj["operate"] = "";
			}	
			std::string date_time = dt->getField<std::string>(3); // 1: info
			tmp_jobj["last-time"] = date_time;
			tmp_jobj["date"] = date_time.substr(0,date_time.find(" "));
			tmp_jobj["time"] = date_time.substr(date_time.find(" ") + 1); // 1: info.
			tmp_jobj["server_time"] = dt->getField<std::string>(4);//server_time
			tmp_jobj["rowid"] = dt->getField<std::string>(5);//server_time
			tmp_jobj["msg_type"] = dt->getField<std::string>(6);
			std::string is_read_string = (dt->getField<std::string>(7));//7: is_read
			tmp_jobj["is_read"] = is_read_string;//dt->getField<std::string>(7);//is_read
			jobj_data.arr_push(tmp_jobj);
			jobj["data"] = jobj_data;
			callback(jobj,false,XL(""));
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"获取消息记录错误") + err.what());
			callback(jobj,false,XL(""));
		}
	}


	void LocalConfig::loadRecentContact( RecentRoster& recentContact )
	{
		recentContact.clear();
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot loadRecentContact because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		try
		{
			data_iterator dt = cur_epdb.execQuery( biz_sql::s_sqlSelectRecentContact);
			while(dt!=data_iterator())
			{
				std::string jidString = dt->getField<std::string>(0); // 0: jid.
				KRecentJIDType jidType = (KRecentJIDType)dt->getField<int>(1); // 1: type.
				recentContact.push_back(std::make_pair(jidString,jidType));
				++dt;
			}
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"获取最近联系人失败") + err.what());
		}
	}

	void LocalConfig::saveSendMessage(std::string type_string, std::string jidTo, std::string subid, json::jobject msg )
	{
		saveMessage(jidTo, subid, type_string, true, msg);
	}

	void LocalConfig::savePublish(int id, json::jobject jobj )
	{
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot savePublish because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		try
		{
			cur_epdb.execDML(biz_sql::s_sqlInsertPublish,epDbBinder(id,jobj["title"].get<std::string>(),
				jobj["signature"].get<std::string>(),
				jobj["priority"].get<std::string>(),
				jobj["identity"].get<std::string>(),
				jobj["html"].get<std::string>(),
				jobj["expired_time"].get<std::string>(),
				jobj["body"].get<std::string>(),
				jobj["address"].to_string(),
				getCurrentTime()));
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"保存发布通知失败") + err.what());
		}
	}
	void LocalConfig::LoadPublish(int offset,int count, boost::function<void(json::jobject)> callback)
	{
		IN_TASK_THREAD_WORKx(LocalConfig::LoadPublish, offset, count, callback);

		if (callback.empty())return;
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot LoadPublish db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName); 
		std::wstring sql_tail;
		if (count != -1) 
		{
			sql_tail += (boost::wformat(L" order by id desc limit %d,%d;")%offset%count).str();
		}
		else 
		{
			sql_tail += L" order by rowid desc;";
		}
		std::wstring sql_all = biz_sql::s_sqlSelectPublish + sql_tail;
		data_iterator dt;
		try
		{
			dt = cur_epdb.execQuery(sql_all, epDbBinder());
		}
		catch(std::exception const& e)
		{
			ELOG("app")->error(WCOOL(L"获取发送通知历史失败，原因是:") + e.what());
		}

		json::jobject jobj;
		json::jobject jobj_data;
		int i = 0;
		while(dt!=data_iterator())
		{
			jobj_data[i]["id"] = dt->getField<int>(0); // 0: id.
			jobj_data[i]["title"] = dt->getField<std::string>(1); // 1: title.
			jobj_data[i]["signature"] = dt->getField<std::string>(2); // 2: signature.
			jobj_data[i]["priority"] = dt->getField<std::string>(3); // 3: priority.
			jobj_data[i]["identity"] = dt->getField<std::string>(4); // 4: identity.
			jobj_data[i]["html"] = dt->getField<std::string>(5); // 5: html.
			jobj_data[i]["expired_time"] = dt->getField<std::string>(6); // 6: expired_time.
			jobj_data[i]["body"] = dt->getField<std::string>(7); // 7: body.
			json::jobject tmp_jobj = json::jobject(dt->getField<std::string>(8)); // 8: address.
			std::string addr_string = (tmp_jobj.arr_size()?tmp_jobj[0]["name"].get<std::string>():"");
			for (int k=1; k<tmp_jobj.arr_size(); ++k)
			{
				addr_string += epius::txtutil::convert_wcs_to_utf8(L"、") + tmp_jobj[k]["name"].get<std::string>();
			}
			jobj_data[i]["address"] = addr_string;
			std::string dt_string = dt->getField<std::string>(9); // 9: dt.
			jobj_data[i]["datetime"] = dt_string.substr(0,10);
			++dt;
			++i;
		}

		jobj["count_all"] = LoadPublishCount();
		jobj["type"] = message_notice;
		jobj["data"] = jobj_data;
		callback(jobj);
	}
	std::string LocalConfig::getCurrentTime()
	{
		boost::posix_time::ptime time_now(boost::posix_time::second_clock::local_time());
		return time_format(time_now);
	}
	//save_notice_message
	std::string LocalConfig::save_notice_message( std::string notice_id, std::string publisher_id,std::string msg,std::string expired_time,std::string priority )
	{
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot save_notice_message because db is NULL");
			return "";
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		ContactMap::iterator itvcard = get_parent_impl()->bizRoster_->syncget_VCard(publisher_id);
		std::string show_name;
		std::string last_rowid;
		if (itvcard != get_parent_impl()->bizRoster_->impl_->vcard_manager_.end())
		{
			show_name = itvcard->second.get_vcardinfo()[s_VcardShowname].get<std::string>();
		}
		else
		{
			show_name = publisher_id;
		}

		try
		{
			cur_epdb.execDML(biz_sql::s_sqlInsert_NoticeMessage,epius::epius_sqlite3::epDbBinder(notice_id,publisher_id,(int)0,show_name,msg,getCurrentTime(),expired_time,priority));
			last_rowid = boost::lexical_cast<std::string>(cur_epdb.last_insert_rowid());
		}
		catch(std::exception const& e)
		{
			ELOG("app")->error(WCOOL(L"保存通知消息失败") + e.what());
			return "";
		}
		return last_rowid;
	}

	void LocalConfig::updateMessageShowname(std::string jid, std::string showname, std::string name)
	{
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot updateMessageShowname because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);

		try
		{
			cur_epdb.execDML(L"update conversation set showname = ? where jid = ? and showname=\"微哨用户\";", epDbBinder(showname, jid));
			cur_epdb.execDML(L"update groupmsg set showname = ? where subid = ? and showname=\"微哨用户\";", epDbBinder(name, jid));
			cur_epdb.execDML(L"update crowdmsg set showname = ? where subid = ? and showname=\"微哨用户\";", epDbBinder(name, jid));
		}
		catch(std::exception const& e)
		{
			ELOG("db")->debug(WCOOL(L"跟新历史记录showname失败，原因是：") + e.what());
		}
	}


	void LocalConfig::updateMessage( std::string rowid, std::string type_string, json::jobject msg )
	{
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot updateMessage because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		std::wstring table_name = impl_->get_tablename_by_type(type_string);
		epDbBinder tmpBind = epDbBinder(msg.to_string(), rowid);
		try
		{
			std::wstring sqlupdate =  L"update " + table_name + L" set msg = ? where rowid = ?";
			cur_epdb.execQuery(sqlupdate, tmpBind);
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"重新发送消息是替换message失败") + err.what());
			return;
		}
	}

	void LocalConfig::saveMessage( std::string jid, std::string subid, std::string type_string, bool is_send, json::jobject msg )
	{
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot saveMessage because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName); 

		if (type_string.empty())
		{
			ELOG("app")->error("saveMessage.bad.type.string");
			return;
		}

		ContactMap::iterator itvcard;
		std::string my_jid_string = get_parent_impl()->bizClient_->jid().bare();
		if (type_string == message_conversation)
		{
			if (is_send) 
			{
				itvcard = get_parent_impl()->bizRoster_->syncget_VCard(my_jid_string);
			}
			else
			{
				itvcard = get_parent_impl()->bizRoster_->syncget_VCard(jid);
			}
		} 
		else
		{
			ELOG("app")->error("saveMessage.bad.type.string");
			return;
		}

		std::wstring table_name = impl_->get_tablename_by_type(type_string);
		insertsql_ = (boost::wformat(biz_sql::s_sqlInsertMessage)%table_name.c_str()).str();

		std::string show_name;
		std::string dt = getCurrentTime();
		if (itvcard != get_parent_impl()->bizRoster_->impl_->vcard_manager_.end())
		{
			std::set<std::string>::iterator it_req = get_parent_impl()->bizRoster_->requestVcard_jids_.find(jid);
			if (it_req != get_parent_impl()->bizRoster_->requestVcard_jids_.end())
			{
				show_name = WS2UTF(L"微哨用户");
			}
			else
			{
				show_name = itvcard->second.get_vcardinfo()[s_VcardShowname].get<std::string>();
			}
		}
		else
		{
			get_parent_impl()->bizRoster_->addgetRequestVCardWait(is_send?my_jid_string:jid, S10nNone, vard_type_base, 
				bind_s(&AnRosterManager::updateMessageShowname, get_parent_impl()->bizRoster_, is_send?my_jid_string:jid, _1));
			get_parent_impl()->bizRoster_->requestVcard_jids_.insert(is_send?my_jid_string:jid);
			show_name = WS2UTF(L"微哨用户");
		}

		try
		{
			int nrow = cur_epdb.execDML(insertsql_, epDbBinder(jid,subid,(int)is_send,(int)is_send,show_name,msg.to_string(),dt));
			if (nrow == 1)
			{
				int nrowid = cur_epdb.last_insert_rowid();
				msg["rowid"] = nrowid;
			}
		}
		catch(std::exception const& e)
		{
			ELOG("db")->debug(WCOOL(L"保存历史记录失败，原因是：") + e.what());
		}

		try
		{
			cur_epdb.execDML(biz_sql::s_sqlReplaceRecentContact, epDbBinder(jid, (int)kRecentContact, dt));

#ifndef _WIN32
			//通知界面最近联系人更新
			json::jobject jobj;
			jobj["info"]["jid"] = jid;
			jobj["is_send"]=is_send;
			jobj["time"] = dt;
			jobj["type"] = "conversation";
			jobj["msg"]  = msg.to_string();
			//添加未读会话条数
			try
			{
				data_iterator  dtcount;
				dtcount = cur_epdb.execQuery(L"select count(*) from conversation where jid =? and is_read=0 and is_send=0", epDbBinder(epius::txtutil::convert_utf8_to_wcs(jid)));
				if (dtcount!=data_iterator())
				{
					jobj["unread_account"]  = dtcount->getField<int>(0);
				}
				dtcount =data_iterator();
			}
			catch(std::exception const&)
			{
				jobj["unread_account"]  = 0;
			}

			event_collect::instance().update_recent_contact(jobj.clone());
#endif

		}
		catch(std::exception const&e)
		{
			ELOG("db")->debug(WCOOL(L"保存最近聊天记录失败，原因是：") + e.what());
		}
	}

	void LocalConfig::saveRecvMessage(std::string type_string,  std::string jidFrom, std::string subid, json::jobject msg )
	{
		saveMessage(jidFrom, subid, type_string, false, msg);
	}



	void LocalConfig::UpdateCrowdName(std::string session_id, std::string crowdname)
	{
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot UpdateCrowdName because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		try
		{
			cur_epdb.execDML(L"update crowdmsg set crowdname = ? where crowdname=\"\" and jid = ?", epDbBinder(crowdname, session_id));
		}
		catch(std::exception const&err)
		{
			ELOG("db")->error(WCOOL(L"UpdateCrowdName failed for ") + err.what());
		}
	}

	void LocalConfig::saveCrowdMessage(std::string crowd_name,  std::string jid, std::string subid, std::string showname, json::jobject msg, std::string id, bool is_send)
	{
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot saveCrowdMessage because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName); 

		std::string dt = getCurrentTime();
		std::wstring table_name = impl_->get_tablename_by_type(message_crowd_chat);
		try
		{
			int nrow = cur_epdb.execDML(biz_sql::s_sqlInsertCrowdMessage,epDbBinder(jid,subid,(int)is_send,(int)is_send,showname,msg.to_string(),dt, crowd_name, id));
			if (nrow == 1)
			{
				msg["rowid"] = (int)cur_epdb.last_insert_rowid();
			}
		}
		catch(std::exception const& e)
		{
			ELOG("db")->debug(WCOOL(L"保存历史记录失败，原因是：") + e.what());
		}

		try
		{
			cur_epdb.execDML(biz_sql::s_sqlReplaceRecentContact, epDbBinder(jid, (int)kRecentCrowd, dt));
#ifndef _WIN32
			//通知界面最近联系人更新
			json::jobject jobj;
			jobj["info"]["jid"] = jid;
			jobj["time"] = dt;
			jobj["jid"] = subid;//ios需要在最近联系人列表的群图标旁显示用户信息。
			jobj["type"] = "crowd";
			jobj["msg"]  = msg.to_string();
			jobj["speaker"] = showname;
			//添加未读会话条数
			try{
				data_iterator  dtcount;
				dtcount = cur_epdb.execQuery(L"select count(*) from crowdmsg where jid =? and is_read=0 and is_send=0", epDbBinder(epius::txtutil::convert_utf8_to_wcs(jid)));
				if (dtcount!=data_iterator())
				{
					jobj["unread_account"]  = dtcount->getField<int>(0);
				}
				dtcount =data_iterator();
			}
			catch(std::exception const&)
			{
				jobj["unread_account"]  = 0;
			}

			event_collect::instance().update_recent_contact(jobj.clone());
#endif

		}
		catch(std::exception const&e)
		{
			ELOG("db")->debug(WCOOL(L"保存最近聊天记录失败，原因是：") + e.what());
		}
	}

	void LocalConfig::getLastCrowd(std::map<std::string, std::string>& msg)
	{
		if(db_connection::instance().get_db(s_userHistoryName) == NULL)
		{
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName); 
		try
		{
			data_iterator dt = cur_epdb.execQuery(L"select jid, id from crowdmsg group by jid;");
			while(dt!=data_iterator()) 
			{
				std::string jid = dt->getField<std::string>(0);
				std::string id = dt->getField<std::string>(1);
				msg.insert(make_pair(jid, id));
				++dt;
			}
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"获取最后群消息发生错误，原因是:") + err.what());
		}
		return;
	}

	json::jobject LocalConfig::getLastCrowd(json::jobject jobj )
	{
		if(db_connection::instance().get_db(s_userHistoryName) == NULL)
		{
			return jobj;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName); 
		try
		{
			data_iterator dt = cur_epdb.execQuery(biz_sql::s_sqlLastCrowd);
			while(dt!=data_iterator())
			{
				std::string jid = dt->getField<std::string>(0);
				std::string crowdname = dt->getField<std::string>(1);
				std::string tm = dt->getField<std::string>(2);
				json::jobject data;
				data["crowd_name"] = crowdname;
				data["tm"] = tm;
				jobj[jid].arr_push(data);
				++dt;
			}
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"获取最后群消息发生错误，原因是:") + err.what());
		}
		return jobj;
	}

	void LocalConfig::get_quit_crowd_list( json::jobject jobj,json::jobject& quit_crowd_jobj)
	{
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot get_quit_crowd_list because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName); 
		std::wstring sqlselect;
		if (jobj.arr_size() > 0)
		{
			std::string tmp = "\"" + jobj[0]["session_id"].get<std::string>() + "\"";
			for (int i=1; i < jobj.arr_size(); i++)
			{
				tmp = tmp + ",\"" + jobj[i]["session_id"].get<std::string>() + "\"";
			}
			sqlselect = L"select jid, crowdname from crowdmsg where jid not in (" + epius::txtutil::convert_utf8_to_wcs(tmp) + L") group by jid;";
		}
		else
		{
			sqlselect = L"select jid, crowdname from crowdmsg group by jid;";
		}

		try
		{
			data_iterator dt = cur_epdb.execQuery(sqlselect);
			while(dt != data_iterator())
			{ 
				json::jobject crowd;
				crowd["session_id"] = dt->getField<std::string>(0); //jid
				crowd["name"] = dt->getField<std::string>(1);//name
				quit_crowd_jobj.arr_push(crowd);
				++dt;
			}
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"获取讨论组jid失败") + err.what());
		}
	}

	bool LocalConfig::isCrowdMessageExist(std::string jid, std::string subid, std::string id)
	{
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("db")->error("Cannot isCrowdMessageExist because db is NULL");
			return false;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		try
		{
			data_iterator dt;
			dt = cur_epdb.execQuery(L"select count(*) from crowdmsg where jid=? and subid=? and id=?", epDbBinder(jid,subid,id));
			if(dt!=data_iterator())
			{
				int count = dt->getField<int>(0);
				return count==0?false:true;
			}
		}
		catch(std::exception const&)
		{
			//no nothing
		}
		return false;
	}

	void LocalConfig::UpdateChatGroupName(std::string session_id, std::string groupname)
	{
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot UpdateChatGroupName because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		try
		{
			cur_epdb.execDML(L"update groupmsg set groupname = ? where groupname=\"\" and jid = ?", epDbBinder(groupname, session_id));
		}
		catch(std::exception const&err)
		{
			ELOG("db")->error(WCOOL(L"UpdateChatGroupName failed for ") + err.what());
		}
	}

	void LocalConfig::saveChatGroupMessage(std::string group_name, std::string jid, std::string subid, std::string showname, json::jobject msg, std::string id, bool is_send)
	{
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot saveChatGroupMessage because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName); 

		std::string dt = getCurrentTime();
		std::wstring table_name = impl_->get_tablename_by_type(message_group_chat);
		try
		{
			int nrow = cur_epdb.execDML(biz_sql::s_sqlInsertGroupMessage,epDbBinder(jid,subid,(int)is_send,(int)is_send,showname,msg.to_string(),dt, group_name, id));
			if (nrow == 1)
			{
				msg["rowid"] = (int)cur_epdb.last_insert_rowid();
			}
		}
		catch(std::exception const& e)
		{
			ELOG("db")->debug(WCOOL(L"保存历史记录失败，原因是：") + e.what());
		}

		try
		{
			cur_epdb.execDML(biz_sql::s_sqlReplaceRecentContact, epDbBinder(jid, (int)kRecentMUC, dt));
#ifndef _WIN32
			//通知界面最近联系人更新
			json::jobject jobj;
			jobj["info"]["jid"] = jid;
			jobj["jid"] = subid;
			jobj["time"] = dt;
			jobj["type"] = "group";
			jobj["msg"]  = msg.to_string();
			jobj["speaker"] = showname;
			//添加未读会话条数
			try{
				data_iterator  dtcount;
				dtcount = cur_epdb.execQuery(L"select count(*) from groupmsg where jid =? and is_read=0 and is_send=0", epDbBinder(epius::txtutil::convert_utf8_to_wcs(jid)));
				if (dtcount!=data_iterator())
				{
					jobj["unread_account"]  = dtcount->getField<int>(0);
				}
				dtcount =data_iterator();
			}
			catch(std::exception const&)
			{
				jobj["unread_account"]  = 0;
			}

			event_collect::instance().update_recent_contact(jobj.clone());
#endif

		}
		catch(std::exception const&e)
		{
			ELOG("db")->debug(WCOOL(L"保存最近聊天记录失败，原因是：") + e.what());
		}
	}

	bool LocalConfig::isChatGroupMessageExist( std::string jid, std::string subid, std::string id )
	{
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("db")->error("Cannot isChatGroupMessageExist because db is NULL");
			return false;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		try
		{
			data_iterator dt;
			dt = cur_epdb.execQuery(L"select count(*) from groupmsg where jid=? and subid=? and id=?", epDbBinder(jid,subid,id));
			if(dt!=data_iterator())
			{
				int count = dt->getField<int>(0);
				return count==0?false:true;
			}
		}
		catch(std::exception const&)
		{
			//no nothing
		}
		return false;
	}

	void LocalConfig::LoadAscMessage(std::string type_string, std::string id_string, int rowid, int offset, int count, json::jobject& jobj,KMsgReadState mrs )
	{
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		std::wstring table_name = impl_->get_tablename_by_type(type_string);
		std::wstring sql_tail = L" (rowid>=?) ";
		switch(mrs)
		{
		default:
			assert(false);
			break;
		case kmrs_read:
			sql_tail += L" and is_read=1 ";
			break;
		case kmrs_recv:
			sql_tail += L" and is_read=0 ";
			break;
		case kmrs_unknown:
			// 				sql_tail = sql_tail; // do nothing.
			break;
		}

		if (!id_string.empty())
		{
			sql_tail += L" and jid = '" + epius::txtutil::convert_utf8_to_wcs(id_string) + L"' ";
		}
		if (count != -1) 
		{
			sql_tail += (boost::wformat(L" order by rowid asc limit %d,%d ;")%offset%count).str();
		} 
		else
		{
			sql_tail += L"order by rowid asc;";
		}
		try
		{
			std::wstring sql_all;
			if (type_string == "group_chat")
			{
				selectsql_ = biz_sql::s_sqlSelectGroupMessage;
			}
			else if ( type_string == "crowd_chat")
			{
				selectsql_ = biz_sql::s_sqlSelectCrowdMessage;
			}
			else
			{
				selectsql_ = (boost::wformat(biz_sql::s_sqlSelectMessage)%table_name.c_str()).str();
			}
			sql_all = selectsql_ + sql_tail;

			data_iterator dt = cur_epdb.execQuery(sql_all, epDbBinder(rowid));
			int i = 0;
			while(dt!=data_iterator())
			{
				/*id,jid,is_send,msg,dt*/
				jobj[i]["rowid"] = dt->getField<std::string>(0); // 0: id.
				jobj[i]["jid"] = dt->getField<std::string>(1); // 1: jid.
				jobj[i]["is_send"] = (dt->getField<int>(2)) ? "1" : "0"; // 2: is_send.
				jobj[i]["msg"] = dt->getField<std::string>(3); // 3: msg.
				jobj[i]["datetime"] = dt->getField<std::string>(4); // 4: dt.
				jobj[i]["speaker"] = (dt->getField<std::string>(5)); // 5: subid.
				jobj[i]["showname"] = dt->getField<std::string>(6); // 6: showname.
				jobj[i]["is_read"] = dt->getField<std::string>(7); // 7: is_read.
				if (type_string == "group_chat")
				{
					jobj[i]["group_name"] = dt->getField<std::string>(8); // 8: group_name
				}
				else if (type_string == "crowd_chat")
				{
					jobj[i]["crowd_name"] = dt->getField<std::string>(8); // 8: crowd_name
				}

				++dt;
				++i;
			}
		}
		catch(std::exception const&e)
		{
			ELOG("db")->debug(WCOOL(L"获取聊天记录失败，原因是：") + e.what());
		}
	}

	void LocalConfig::LoadDescMessage(std::string type_string,std::string id_string,int rowid, int offset,int count, json::jobject& jobj,KMsgReadState mrs)
	{
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName); 
		if (rowid == -1)
		{
			rowid = 0x7FFFFFFF;
		}
		std::wstring sql_tail = L" (rowid<?) ";
		switch(mrs)
		{
		default:
			assert(false);
			break;
		case kmrs_read:
			sql_tail += L" and is_read=1 ";
			break;
		case kmrs_recv:
			sql_tail += L" and is_read=0 ";
			break;
		case kmrs_unknown:
			break;
		}

		if (!id_string.empty())
		{
			sql_tail += L" and jid = '" + epius::txtutil::convert_utf8_to_wcs(id_string) + L"'";
		}
		if (count != -1) 
		{
			sql_tail += (boost::wformat(L" order by rowid desc limit %d,%d;")%offset%count).str();
		}
		else
		{
			sql_tail += L" order by rowid desc;";
		}
		std::wstring sql_all;
		std::wstring table_name = impl_->get_tablename_by_type(type_string);
		if (type_string == "group_chat")
		{
			selectsql_ = biz_sql::s_sqlSelectGroupMessage;
		}
		else if ( type_string == "crowd_chat")
		{
			selectsql_ = biz_sql::s_sqlSelectCrowdMessage;
		}
		else
		{
			selectsql_ = (boost::wformat(biz_sql::s_sqlSelectMessage)%table_name.c_str()).str();
		}
		sql_all = selectsql_ + sql_tail;

		try
		{
			data_iterator dt = cur_epdb.execQuery(sql_all, epDbBinder(rowid));
			int i = 0;
			while(dt!=data_iterator())
			{
				/*id,jid,is_send,msg,dt*/
				jobj[i]["rowid"] = dt->getField<std::string>(0); // 0: id.
				jobj[i]["jid"] = dt->getField<std::string>(1); // 1: jid.
				jobj[i]["is_send"] = (dt->getField<int>(2)) ? "1" : "0"; // 2: is_send.
				jobj[i]["msg"] = dt->getField<std::string>(3); // 3: msg.
				jobj[i]["datetime"] = dt->getField<std::string>(4); // 4: dt.
				jobj[i]["speaker"] = dt->getField<std::string>(5); // 5: subid.
				jobj[i]["showname"] = dt->getField<std::string>(6); // 6: showname.
				jobj[i]["is_read"] = dt->getField<std::string>(7); // 7: is_read.
				if (type_string == "group_chat")
				{
					jobj[i]["group_name"] = dt->getField<std::string>(8); // 8: group_name
				}
				else if (type_string == "crowd_chat")
				{
					jobj[i]["crowd_name"] = dt->getField<std::string>(8); // 8: crowd_name
				}

				++dt;
				++i;
			}
			// notice表 不需要再排序 最后通知在上
			if(type_string.compare("notice")){
				int k = i/2-1;
				json::jobject j;
				for (; k>=0; --k)
				{
					j = jobj[k];
					jobj[k] = jobj[i-k-1];
					jobj[i-k-1] = j;
				}
			}
		}
		catch(std::exception const&err)
		{
			ELOG("app")->error(WCOOL(L"LoadDescMessage读取数据库错误")+err.what());
		}
	}
	//获取接收通知历史
	json::jobject LocalConfig::LoadDescNoticeMessage(int offset, int count)
	{
		json::jobject jobj;
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot LoadDescNoticeMessage history.dat because db is NULL");
			return jobj;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		data_iterator dt;
		std::wstring sql_tail = L"";
		try
		{	
			if (count <= 0)
			{
				count = 100;
			}
			if (offset < 0)
			{
				offset = 0;
			}			
			std::wstring sqlGetAllMessage = (boost::wformat(L"select rowid,* from notice order by rowid desc limit %d,%d")%offset%count).str();
			dt = cur_epdb.execQuery(sqlGetAllMessage);
			int i = 0;
			while(dt!=data_iterator())
			{
				/*id,jid,is_send,msg,dt*/
				jobj[i]["rowid"] = dt->getField<std::string>(0); 
				jobj[i]["jid"] = dt->getField<std::string>(1); 
				jobj[i]["subid"] = dt->getField<std::string>(2); 
				jobj[i]["is_read"] = dt->getField<int>(3);
				jobj[i]["showname"] = dt->getField<std::string>(4); 
				jobj[i]["msg"] = (dt->getField<std::string>(5)); 
				jobj[i]["dt"] = dt->getField<std::string>(6); 
				jobj[i]["expired_time"] = dt->getField<std::string>(7); 
				jobj[i]["priority"] = dt->getField<std::string>(8);
				++dt;
				++i;
			}
			json::jobject jobj_ret;
			jobj_ret["type"] = "notice";
			jobj_ret["data"] = jobj;
			return jobj_ret;
		}
		catch(std::exception const&err)
		{
			ELOG("app")->error(WCOOL(L"LoadDescNoticeMessage读取数据库错误")+err.what());
			return jobj;
		}
	}

	json::jobject LocalConfig::LoadOneNoticeMessage(std::string id_string)
	{
		json::jobject jobj;
		if (id_string.empty())return jobj;
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot LoadOneNoticeMessage because db is NULL");
			return jobj;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		try
		{	
			static const std::wstring s_sqlGetOneNotice = L"select * from notice where notice_id = ?";			
			data_iterator dt = cur_epdb.execQuery(s_sqlGetOneNotice,epDbBinder(id_string));
			if(dt!=data_iterator())
			{
				jobj[0]["jid"] = dt->getField<std::string>(0); 
				jobj[0]["subid"] = dt->getField<std::string>(1); 
				jobj[0]["is_read"] = dt->getField<int>(2);
				jobj[0]["showname"] = dt->getField<std::string>(3); 
				jobj[0]["msg"] = (dt->getField<std::string>(4)); 
				jobj[0]["dt"] = dt->getField<std::string>(5); 
				jobj[0]["expired_time"] = dt->getField<std::string>(6); 
				jobj[0]["priority"] = dt->getField<std::string>(7);
			}
			json::jobject jobj_ret;
			jobj_ret["jid"] = id_string;
			jobj_ret["type"] = "notice";
			jobj_ret["data"] = jobj;
			return jobj_ret;
		}
		catch(std::exception const&)
		{
			ELOG("app")->error(WCOOL(L"读取通知消息错误"));
			return jobj;
		}
	}
	//取发送历史通知	
	void LocalConfig::LoadpublishDescMessage(epDb& cur_epdb,	std::string id_string,json::jobject& jobj)
	{
		int retry_times = 0;
		data_iterator dt;
		std::wstring sql_tail = L"";
		try
		{			
			sql_tail += L" id = '" + epius::txtutil::convert_utf8_to_wcs(id_string) + L"'";
			const std::wstring s_sqlUnionSendMessage = L"select title,body,priority,identity,html,address,expired_time,dt,signature from publish where";			
			sql_tail = s_sqlUnionSendMessage + sql_tail;
			dt = cur_epdb.execQuery(sql_tail, epDbBinder());
			retry_times = 0;
		}
		catch(std::exception const&)
		{
			++retry_times;
			cur_epdb.execDML(createsql_);
		}		
		jobj["title"] = dt->getField<std::string>(0); // 0: title.
		jobj["body"] = dt->getField<std::string>(1); // 1: body.
		jobj["priority"] = (dt->getField<int>(2)) ? "1" : "0"; // 2: priority.
		jobj["identity"] = dt->getField<std::string>(3); // 3: identity.
		jobj["html"] = dt->getField<std::string>(4); // 4: html.
		jobj["address"] = (dt->getField<std::string>(5)); // 5: subid.
		jobj["expired_time"] = dt->getField<std::string>(6); // 6: expired_time.
		jobj["dt"] = dt->getField<std::string>(7); // 7: dt.
		jobj["signature"] = dt->getField<std::string>(8); // 7: dt.
		dt = data_iterator();
	}

	unsigned long LocalConfig::LoadMessageCount_(std::string type_string, std::string id_string, KMsgReadState mrs)
	{
		if (type_string.empty())
		{
			ELOG("app")->error("LoadMessageCount_.bad.type.string");
			return 0;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName); 
		std::wstring sql_tail = L" (1=1)";
		switch(mrs)
		{
		default:
			break;
		case kmrs_read:
			sql_tail += L" and is_read=1 ";
			break;
		case kmrs_recv:
			sql_tail += L" and is_read=0 ";
			break;
		}
		if (!id_string.empty())
		{
			if(type_string==message_notice)
			{
				sql_tail += L" and notice_id = '" + epius::txtutil::convert_utf8_to_wcs(id_string) + L"'";
			}
			else
			{
				sql_tail += L" and jid = '" + epius::txtutil::convert_utf8_to_wcs(id_string) + L"'";
			}
		}
		std::wstring sql_all;
		std::wstring tablename = impl_->get_tablename_by_type(type_string);
		countsql_ = (boost::wformat(biz_sql::s_sqlSelectMessageCount)%tablename.c_str()).str();
		sql_all = countsql_ + sql_tail + L";";

		try
		{
			data_iterator dt = cur_epdb.execQuery(sql_all);
			if (dt!=data_iterator())
			{
				return dt->getField<int>(0);
			}
			return 0;
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"获取消息记录总数发生错误，原因是:") + err.what());
			return 0;
		}
	}

	void LocalConfig::MarkMessageRead(std::string type_string, std::string id_string)
	{
		if (type_string.empty())
		{
			ELOG("app")->error("MarkMessageRead.bad.type.string");
			return;
		}
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot MarkMessageRead because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName); 
		std::wstring table_name = impl_->get_tablename_by_type(type_string);
		makereadsql_ = (boost::wformat(biz_sql::s_sqlMarkMessageRead)%table_name.c_str()).str();
		std::wstring sql_tail = L" (is_read=0) ";
		if (!id_string.empty())
		{
			sql_tail += L" and jid = '" + epius::txtutil::convert_utf8_to_wcs(id_string) + L"'";
		}
		std::wstring sql_all = makereadsql_ + sql_tail + L";";
		try
		{
			cur_epdb.execDML(sql_all);
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"标记用户数据为已读发生错误，原因是:") + err.what());
		}
	}

	void LocalConfig::LoadMessage(std::string type_string, std::string id_string, int offset, int count, json::jobject& jobj, KMsgReadState mrs)
	{
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot LoadMessage because db is NULL");
			return;
		}
		json::jobject jobj_data;
		if (type_string.empty())
		{
			ELOG("app")->error("LoadMessage.bad.type.string");
		}

		if (offset == -1) 
		{
			LoadDescMessage(type_string, id_string, -1, 0, count, jobj_data, mrs);
			jobj["count_all"] = (int)LoadMessageCount_(type_string, id_string, mrs);
		}
		else
		{
			LoadAscMessage(type_string, id_string, 0, offset, count, jobj_data, mrs);
			jobj["count_all"] = (int)LoadMessageCount_(type_string, id_string, mrs);
		}

		jobj["jid"] = id_string;
		jobj["type"] = type_string;
		jobj["data"] = jobj_data;
	}

	//取发送历史通知
	void LocalConfig::LoadpublishMessage(std::string id_string,json::jobject& jobj)
	{
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot LoadpublishMessage because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName); 
		json::jobject jobj_data;
		//从数据库读取历史通知记录
		LoadpublishDescMessage(cur_epdb,id_string,jobj_data);
		jobj["jid"] = id_string;
		jobj["data"] = jobj_data;
	}

	int LocalConfig::LoadPublishCount()
	{
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot LoadPublishCount because db is NULL");
			return 0;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName); 
		try
		{
			data_iterator dt = cur_epdb.execQuery(biz_sql::s_sqlSelectCountPublish);
			if(dt!=data_iterator())
			{
				return dt->getField<int>(0);
			}
			return 0;
		}
		catch(epius_dberror const& err)
		{
			ELOG("db")->error(WCOOL(L"获取用户通知数目发生错误") + err.what());
			return 0;
		}
	}

	void LocalConfig::LoadUnreadMessageCount(json::jobject& jobj)
	{
		IN_TASK_THREAD_WORKx(LocalConfig::LoadUnreadMessageCount, jobj);

		// 取所有表的未读取信息
		json::jobject notice_obj;
		json::jobject system_msg_obj;
		json::jobject app_msg_obj;

		LoadUnreadMessageCount(message_conversation, jobj);
		LoadUnreadMessageCount(message_group_chat, jobj);
		LoadUnreadMessageCount(message_crowd_chat, jobj);

		loadUnreadNoticeCount(false,lambda::var(notice_obj)=lambda::_1);
		if(notice_obj && notice_obj["count_all"].get<int>()>0)
		{
			notice_obj["type"] = message_notice;
			jobj["data"].arr_push(notice_obj);
		}

		loadUnreadSystemMessageCount(lambda::var(system_msg_obj)=lambda::_1);
		if(system_msg_obj && system_msg_obj["count_all"].get<int>()>0)
		{
			system_msg_obj["type"] = "system_message";
			jobj["data"].arr_push(system_msg_obj);
		}

		loadUnreadAppMessageCount(lambda::var(app_msg_obj)=lambda::_1);
		if(app_msg_obj && app_msg_obj["count_all"].get<int>()>0)
		{
			app_msg_obj["type"] = "app_message";
			jobj["data"].arr_push(app_msg_obj);
		}

		loadUnreadLightappMessageCount(jobj);
		int unread_count = 0;
		for (int i = 0;i < jobj["data"].arr_size();i++)
		{
			if (jobj["data"][i]["type"].get<std::string>() != "conversation" && jobj["data"][i]["type"].get<std::string>() != "group_chat" && jobj["data"][i]["type"].get<std::string>() != "crowd_chat" && jobj["data"][i]["type"].get<std::string>() != "lightapp" && jobj["data"][i]["type"].get<std::string>() != "lightapp_msg" )
			{
				unread_count += jobj["data"][i]["count_all"].get<int>();
			}
		}
		jobj["unread_count"] = unread_count;
	}

	void LocalConfig::LoadUnreadMessageCount(std::string type_string, json::jobject& jobj)
	{
		std::wstring tablename = impl_->get_tablename_by_type(type_string);
		std::wstring unreadsql_count;
		if (type_string == "group_chat")
		{
			std::wstring group_sql;
			unreadsql_ = L"select jid,subid,showname,msg,dt,count(*),groupname from groupmsg where" + group_sql + L" is_send=0 and is_read=0 group by jid ";
			unreadsql_count = L"select count(*) from (select jid from groupmsg where" + group_sql + L" is_read = 0 and is_send = 0 group by jid)";
		}
		else if (type_string == "conversation")
		{
			unreadsql_ = (boost::wformat(biz_sql::s_sqlUnRead)%tablename.c_str()).str();
			unreadsql_count = L"select count(*) from (select jid from conversation where is_read = 0 and is_send = 0 group by jid)";
		}
		else if (type_string == "crowd_chat")
		{
			std::wstring crowd_sql;
			unreadsql_ = L"select jid,subid,showname,msg,dt,count(*),crowdname from crowdmsg where " + crowd_sql +  L"is_send=0 and is_read=0 group by jid ";
			unreadsql_count = L"select count(*) from (select jid from crowdmsg where " + crowd_sql + L"is_read = 0 and is_send = 0 group by jid)";
		}
		else
		{
			ELOG("app")->error("type_string error!");
			return;
		}

		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot LoadUnreadMessageCount because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);

		int retry_times = 0;
		data_iterator dt;
		json::jobject count_jobj;
		try
		{
			//取会话、讨论组 未读消息总数（人数，讨论组数）
			data_iterator dt2;
			dt2 = cur_epdb.execQuery(unreadsql_count);
			if (dt2 != data_iterator())
			{
				if (type_string == "group_chat")
				{
					count_jobj["type"] = "group";				
				}	
				else if (type_string == "conversation")
				{
					count_jobj["type"] = "conv";
				}
				else if (type_string == "crowd_chat")
				{
					count_jobj["type"] = "crowd";
				}
				if (dt2->getField<int>(0) > 0)
				{
					count_jobj["count_all"] = dt2->getField<int>(0);
					jobj["data"].arr_push(count_jobj);
				}			
			}	

			dt = cur_epdb.execQuery(unreadsql_);
		}
		catch(std::exception const& e)
		{
			ELOG("db")->debug(WCOOL(L"读取未读记录失败，原因是：") + e.what());
		}

		json::jobject jobj_data = json::jobject();
		int i = 0;
		while (dt!=data_iterator()) 
		{
			std::string jid_string = dt->getField<std::string>(0); // jid
			int rowCount = dt->getField<int>(5); 
			if (!rowCount) 
			{
				++dt;
				continue;
			}
			jobj_data[i]["count_all"] = rowCount;

			if (type_string.compare("group_chat") == 0)
			{
				jobj_data[i]["group_name"] = dt->getField<std::string>(6);
			}else if (type_string.compare("crowd_chat") == 0)
			{
				jobj_data[i]["crowd_name"] = dt->getField<std::string>(6);
				jobj_data[i]["alert"] = g_crowd::instance().get_alert_by_session_id(jid_string);
			}

			jobj_data[i]["last-msg"] = dt->getField<std::string>(3); // max(msg)
			// 最后未读消息的时间
			std::string msgDT = dt->getField<std::string>(4); // max(dt)
			jobj_data[i]["last-time"] = msgDT;
			jobj_data[i]["jid"] = jid_string;
			std::string subjid_string = dt->getField<std::string>(1); // subid
			jobj_data[i]["subid"] = subjid_string;

			jobj_data[i]["type"] = type_string; 		// type
			jobj_data[i]["showname"] = dt->getField<std::string>(2); // showname

			// 有未读消息的联系人头像
			ContactMap::iterator itvcard;
			if (type_string == message_conversation)
			{
				itvcard = get_parent_impl()->bizRoster_->syncget_VCard(jid_string);
			} 
			else
			{
				itvcard = get_parent_impl()->bizRoster_->syncget_VCard(subjid_string);
			}

			if(type_string.compare("crowd_chat"))
			{
				std::string headpath, sexshow, identityshow;
				if (itvcard != get_parent_impl()->bizRoster_->impl_->vcard_manager_.end())
				{
					headpath = itvcard->second.get_vcardinfo()[s_VcardHead].get<std::string>();
					sexshow = itvcard->second.get_vcardinfo()[s_VcardSexShow].get<std::string>();
					identityshow = itvcard->second.get_vcardinfo()[s_VcardIdentityShow].get<std::string>();	
				}
				// 性别身份需要转译
				jobj_data[i][s_VcardHead] = headpath;
				jobj_data[i][s_VcardSexShow] = XL(sexshow).res_value_utf8;
				jobj_data[i][s_VcardIdentityShow] = XL(identityshow).res_value_utf8;
			}
			else
			{
				//群的图标
				jobj_data[i][s_VcardHead] = g_crowd::instance().get_crowd_icon_by_id(jid_string);
				jobj_data[i]["category"] = g_crowd::instance().get_crowd_category_by_id(jid_string);
			}
			++dt;
			++i;
		}

		for(int datai =0;datai<jobj_data.arr_size();++datai)
		{
			jobj["data"].arr_push(jobj_data[datai]);
		}
	}

	void LocalConfig::removeMessageBy(std::string type_string, std::string whereString)
	{
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot removeMessageBy because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName); 
		std::wstring table_name = impl_->get_tablename_by_type(type_string);
		std::wstring deletesql = (boost::wformat(biz_sql::s_sqlDeleteMessage)%table_name.c_str()).str();
		try
		{
			cur_epdb.execDML(deletesql + epius::txtutil::convert_utf8_to_wcs(whereString));
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"移除用户数据发生错误") + err.what());
		}
	}

	void LocalConfig::loadUnreadNoticeCount(bool important_notice, boost::function<void(json::jobject)> callback)
	{
		IN_TASK_THREAD_WORKx(LocalConfig::loadUnreadNoticeCount, important_notice, callback);
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("try to load unread notice when db is not ready.");
			return;
		}
		if (callback.empty())
			return;

		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName); 
		std::string cur_time = getCurrentTime();
		json::jobject jobj;		
#ifndef _WIN32
		try
		{
			std::wstring priority_str = L" and priority = 'important'";
			std::wstring sql_get_notice_count = L"select count(*) from notice where is_read=0";
			if(important_notice) sql_get_notice_count += priority_str;
			data_iterator dt = cur_epdb.execQuery(sql_get_notice_count);
			if(dt!=data_iterator())
			{
				jobj["count_all"] = dt->getField<int>(0);
			}
			std::wstring sql_get_last_notice = L"select * from notice where is_read=0 ";
			if(important_notice) sql_get_last_notice += priority_str;
			sql_get_last_notice += L" order by rowid desc limit 0, 1";
			dt = cur_epdb.execQuery(sql_get_last_notice);
			if(dt!=data_iterator())
			{
				jobj["jid"] = dt->getField<std::string>(0);
				jobj["subid"] = dt->getField<std::string>(1);
				jobj["is_read"] = dt->getField<std::string>(2);
				jobj["showname"] = dt->getField<std::string>(3);
				jobj["last-msg"] = dt->getField<std::string>(4);
				jobj["last-time"] = dt->getField<std::string>(5);
			}
			callback(jobj);
		}
		catch(std::exception const&err)
		{
			ELOG("app")->error(WCOOL(L"loadUnreadNoticeCount 取未读数量消息失败")+err.what());
			callback(jobj);
		}
#else
		try
		{
			std::wstring priority_str = L" and priority = 'important'";
			std::wstring sql_get_notice_count = L"select count(*) from notice where is_read=0 and expired_time>=?";
			if(important_notice) sql_get_notice_count += priority_str;
			data_iterator dt = cur_epdb.execQuery(sql_get_notice_count,epDbBinder(cur_time));
			if(dt!=data_iterator())
			{
				jobj["count_all"] = dt->getField<int>(0);
			}
			std::wstring sql_get_last_notice = L"select * from notice where is_read=0 and expired_time>=?";
			if(important_notice) sql_get_last_notice += priority_str;
			sql_get_last_notice += L" order by rowid desc limit 0, 1";
			dt = cur_epdb.execQuery(sql_get_last_notice,epDbBinder(cur_time));
			if(dt!=data_iterator())
			{
				jobj["jid"] = dt->getField<std::string>(0);
				jobj["subid"] = dt->getField<std::string>(1);
				jobj["is_read"] = dt->getField<std::string>(2);
				jobj["showname"] = dt->getField<std::string>(3);
				jobj["last-msg"] = dt->getField<std::string>(4);
				jobj["last-time"] = dt->getField<std::string>(5);
			}
			callback(jobj);
		}
		catch(std::exception const&err)
		{
			ELOG("app")->error(WCOOL(L"loadUnreadNoticeCount 取未读数量消息失败")+err.what());
			callback(jobj);
		}
#endif
	}

	void LocalConfig::loadUnreadNotice(bool important_notice, int offset,int count, boost::function<void(json::jobject)> callback)
	{
		IN_TASK_THREAD_WORKx(LocalConfig::loadUnreadNotice, important_notice, offset, count, callback);

		if (callback.empty())
			return;
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot loadUnreadNotice because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		json::jobject jobj, jobj_data;
		std::string cur_time = getCurrentTime();
		try
		{
			std::wstring sql_get_notice = L"select rowid, * from notice where is_read=0 and expired_time>=?";
			if(important_notice) sql_get_notice += L" and priority = 'important'";
			sql_get_notice +=  L" order by rowid desc";
			epDbBinder tmpBind;
			if(offset>=0)
			{
				sql_get_notice += L" limit ?, ?";
				tmpBind = epDbBinder(cur_time,offset, count);
			}
			else
			{
				tmpBind = epDbBinder(cur_time);
			}
			data_iterator dt = cur_epdb.execQuery( sql_get_notice, tmpBind);
			for(;dt!=data_iterator();++dt)
			{
				json::jobject tmp_jobj;
				tmp_jobj["rowid"] = dt->getField<std::string>(0);
				tmp_jobj["speaker"] = dt->getField<std::string>(2);
				tmp_jobj["showname"] = dt->getField<std::string>(4);
				tmp_jobj["msg"] = dt->getField<std::string>(5);
				tmp_jobj["jid"] = dt->getField<std::string>(1);
				tmp_jobj["is_send"] = 0;
				tmp_jobj["is_read"] = dt->getField<std::string>(3);
				tmp_jobj["datetime"] = dt->getField<std::string>(6);
				tmp_jobj["priority"] = dt->getField<std::string>(8);
				jobj_data.arr_push(tmp_jobj);
			}
			jobj["data"] = jobj_data;
			jobj["count_all"] = jobj_data.arr_size();
			callback(jobj);
		}
		catch(std::exception const&err)
		{
			ELOG("app")->error(WCOOL(L"loadUnreadNotice 取未读消息失败")+err.what());
		}
	}
	void LocalConfig::saveData( std::string id, std::string data )
	{
		if(!db_connection::instance().get_db(s_userConfigName))
		{
			ELOG("app")->error("Cannot saveData because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userConfigName); 
		try
		{
			cur_epdb.execDML( biz_sql::s_sqlReplaceSpecial, epDbBinder(epius::txtutil::convert_utf8_to_wcs(id),epDbBinder::blob(data.c_str(), data.size())));
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"保存用户数据错误") + (boost::format(" id=%s and data=%s")%id%data).str() + err.what());
		}
	}

	void LocalConfig::deleteData( std::string id)
	{
		if(!db_connection::instance().get_db(s_userConfigName))
		{
			ELOG("app")->error("Cannot saveData because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userConfigName); 
		try
		{
			cur_epdb.execDML( biz_sql::s_sqlDeleteSpecial, epDbBinder(epius::txtutil::convert_utf8_to_wcs(id)));
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"删除用户数据错误") + (boost::format(" id=%s")%id).str() + err.what());
		}
	}

	std::string LocalConfig::loadData( std::string id )
	{
		if(!db_connection::instance().get_db(s_userConfigName))
		{
			ELOG("app")->error("Cannot loadData because db is NULL");
			return "";
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userConfigName); 
		try
		{
			data_iterator dt = cur_epdb.execQuery( biz_sql::s_sqlSelectSpecial, epDbBinder(epius::txtutil::convert_utf8_to_wcs(id)));
			if(dt!=data_iterator())
			{
				return dt->getField<epDbBinder::blob>(1); // 1: data.
			}
			return "";
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"获取全局数据错误") + (boost::format(" id=%s")%id).str() + err.what());
			return "";
		}
	}
	void LocalConfig::saveGlobalData( std::string id, std::string data )
	{
		if(!db_connection::instance().get_db(s_rootConfigName))
		{
			ELOG("app")->error("Cannot saveGlobalData because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_rootConfigName); 

		try
		{
			cur_epdb.execDML( biz_sql::s_sqlReplaceSpecial, 
				epDbBinder(epius::txtutil::convert_utf8_to_wcs(id),
				epDbBinder::blob(data.c_str(), data.size())));
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"保存全局数据错误") + (boost::format(" id=%s and data=%s")%id%data).str() + err.what());
		}
	}

	std::string LocalConfig::loadGlobalData( std::string id )
	{
		if(!db_connection::instance().get_db(s_rootConfigName))
		{
			ELOG("app")->error("Cannot loadGlobalData because db is NULL");
			return "";
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_rootConfigName); 
		try
		{
			data_iterator dt = cur_epdb.execQuery( biz_sql::s_sqlSelectSpecial, epDbBinder(epius::txtutil::convert_utf8_to_wcs(id)));
			if(dt!=data_iterator())
			{
				return dt->getField<epDbBinder::blob>(1); // 1: data.
			}
			return "";
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"获取全局数据错误") + (boost::format(" id=%s")%id).str() + err.what());
			return "";
		}
	}

	json::jobject LocalConfig::getLastConversation()
	{
		json::jobject jobj;
		jobj = getLastConversation(jobj);
		jobj = getLastGroup(jobj);
		jobj = getLastCrowd(jobj);
		return jobj;
	}

	json::jobject LocalConfig::getLastConversation(json::jobject jobj )
	{
		if(db_connection::instance().get_db(s_userHistoryName) == NULL)
		{
			return jobj;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName); 
		try
		{
			data_iterator dt = cur_epdb.execQuery( biz_sql::s_sqlLastConversation);
			while(dt!=data_iterator()) 
			{
				std::string jid = dt->getField<std::string>(0);
				std::string tm = dt->getField<std::string>(1);
				jobj[jid]=tm;
				++dt;
			}
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"获取最后聊天记录发生错误，原因是:") + err.what());
		}
		return jobj;
	}

	json::jobject LocalConfig::getLastGroup(json::jobject jobj )
	{
		if(db_connection::instance().get_db(s_userHistoryName) == NULL){
			return jobj;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName); 
		try
		{
			data_iterator dt = cur_epdb.execQuery( biz_sql::s_sqlLastGroup);
			while(dt!=data_iterator())
			{
				std::string jid = dt->getField<std::string>(0);
				std::string groupname = dt->getField<std::string>(1);
				std::string tm = dt->getField<std::string>(2);
				json::jobject data;
				data["group_name"] = groupname;
				data["tm"] = tm;
				jobj[jid].arr_push(data);
				++dt;
			}
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"获取最后讨论组发生错误，原因是:") + err.what());
		}
		return jobj;
	}

	void LocalConfig::ui_loadLocalUsers( const std::string& jid, boost::function<void(json::jobject)> callback )
	{
		IN_TASK_THREAD_WORKx(LocalConfig::ui_loadLocalUsers, jid, callback);
		std::wstring select_sql = biz_sql::s_sqlSelectUserFromAccountsByName;
		if(!db_connection::instance().get_db(s_rootConfigName))
		{
			ELOG("app")->error("Cannot ui_loadLocalUsers because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_rootConfigName);
		try
		{
			std::string curr_user_sam_id = get_parent_impl()->bizUser_->get_user().sam_id;
			data_iterator it = cur_epdb.execQuery( select_sql,epDbBinder(curr_user_sam_id));
			json::jobject jobj;
			if(it == data_iterator())
			{
				jobj["result"] = "fail";
				jobj["reason"] = XL("biz.get_user_auto_login.nouser").res_value_utf8;
				callback(jobj);
			}
			else
			{
				Tuser_info info(it);
				jobj["can_auto_login"] = info.password.empty()?false:true;
				jobj["curr_auto_login"] = (!info.password.empty() && info.auto_login) ? true:false;
				jobj["result"] = "success";
				callback(jobj);
			}
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"获取用户信息错误") + err.what());
		}
	}

	void LocalConfig::ui_saveLocalUser( const std::string& jid, bool autologin, boost::function<void(json::jobject)> callback )
	{
		IN_TASK_THREAD_WORKx(LocalConfig::ui_saveLocalUser, jid, autologin, callback);

		std::wstring update_sql = L"update accounts set auto_login = ? where sam_id = ?";
		if(!db_connection::instance().get_db(s_rootConfigName))
		{
			ELOG("app")->error("Cannot ui_saveLocalUser because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_rootConfigName);
		std::string curr_user_sam_id =  get_parent_impl()->bizUser_->get_user().sam_id;
		try
		{
			int line_affected = cur_epdb.execDML(  update_sql,epDbBinder((int)autologin,curr_user_sam_id));
			json::jobject jobj;
			if(line_affected==1)
			{
				jobj["result"] = "success";
				callback(jobj);
			}
			else
			{
				jobj["result"] = "failed";
				jobj["reason"] = XL("biz.save_user_update_user_not_exist").res_value_utf8;
				callback(jobj);
			}
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"保存自动登录错误") + err.what());
		}

	}

	bool LocalConfig::saveAnanDir(const std::string& target_dir)
	{

		if(!db_connection::instance().get_db(s_rootConfigName))
		{
			ELOG("app")->error("Cannot saveAnanDir because db is NULL");
			return false;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_rootConfigName);
		try
		{
			cur_epdb.execDML( s_sqlDeleteUserDataDir);
			cur_epdb.execDML( s_sqlInsertUserDataDir, epDbBinder(target_dir));
			file_manager::instance().set_config_dir(false, target_dir);
			epfilesystem::instance().create_directories(file_manager::instance().get_config_dir().get<1>());
			return true;
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"保存本地帐号错误") + err.what());
			return false;
		}
	}

	bool LocalConfig::deleteRecentContact( const std::string jid_string )
	{
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot deleteRecentContact because db is NULL");
			return false;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);

		try
		{
			cur_epdb.execDML( biz_sql::s_sqlDeleteRecentContactByJID,jid_string);
			return true;
		}
		catch(std::exception const&err)
		{
			ELOG("db")->error(WCOOL(L"删除最近联系人发生错误，原因是:") + err.what());
			return false;
		}
	}

#ifndef _WIN32
	bool LocalConfig::deleteSystemRecentContact(  )
	{
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot deleteSystemRecentContact because db is NULL");
			return false;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);

		try
		{
			cur_epdb.execDML( biz_sql::s_sqlDeleteSystemRecentContact);
			return true;
		}
		catch(std::exception const&err)
		{
			ELOG("db")->error(WCOOL(L"删除最近联系人发生错误，原因是:") + err.what());
			return false;
		}
	}

#endif 

	void LocalConfig::MarkOneNoticeAsRead( std::string id_string )
	{
		IN_TASK_THREAD_WORKx(LocalConfig::MarkOneNoticeAsRead, id_string);

		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot MarkOneNoticeAsRead because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		try
		{
			notice_msg_ack(id_string, kna_read).send(get_parent_impl()->bizClient_);
			std::wstring sql_update_notice = L"update notice set is_read = 1 where notice_id = ?";
			cur_epdb.execDML( sql_update_notice, epDbBinder(id_string));
		}
		catch(epius_dberror const& err)
		{
			ELOG("db")->error(WCOOL(L"更新notice表发生错误") + err.what());
		}
	}

	void LocalConfig::deleteConversationHistory( std::string jid, boost::function<void(bool err, universal_resource)> callback )
	{
		IN_TASK_THREAD_WORKx(LocalConfig::deleteConversationHistory, jid, callback);

		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot deleteConversationHistory because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		try
		{
			cur_epdb.execDML( L"delete from conversation where jid=? and is_read=1" , epDbBinder(jid));
		}
		catch(std::exception const&err)
		{
			ELOG("db")->error(WCOOL(L"删除聊天历史发生错误") + err.what());
			callback(true, XL("biz.deleteConversationHistory.failed"));
			return;
		}
		callback(false, XL(""));
	}

	void LocalConfig::deleteNoticeHistory( std::string notice_id, boost::function<void(bool err, universal_resource)> callback )
	{
		IN_TASK_THREAD_WORKx(LocalConfig::deleteNoticeHistory, notice_id, callback);

		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot deleteNoticeHistory because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		try
		{
			cur_epdb.execDML( L"delete from notice where notice_id=?" , epDbBinder(epius::txtutil::convert_utf8_to_wcs(notice_id)));
		}
		catch(std::exception const&err)
		{
			ELOG("db")->error(WCOOL(L"删除通知历史发生错误") + err.what());
			callback(true, XL("biz.deleteNoticeHistory.failed"));
			return;
		}
		callback(false, XL(""));
	}

	void LocalConfig::deleteAllNotice( boost::function<void(bool err, universal_resource)> callback )
	{
		IN_TASK_THREAD_WORKx(LocalConfig::deleteAllNotice, callback);

		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot deleteAllNotice because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		try
		{
			cur_epdb.execDML( L"delete from notice");
		}
		catch(std::exception const&err)
		{
			ELOG("db")->error(WCOOL(L"删除所有通知发生错误") + err.what());
			callback(true, XL("biz.deleteAllNotice.failed"));
			return;
		}
		callback(false, XL(""));
	}

	void LocalConfig::deleteAllReadedNotice(boost::function<void(bool err, universal_resource)> callback )
	{
		IN_TASK_THREAD_WORKx(LocalConfig::deleteAllReadedNotice, callback);

		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot deleteAllReadedNotice because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		try
		{
			cur_epdb.execDML( L"delete from notice where is_read = 1");
		}
		catch(std::exception const&err)
		{
			ELOG("db")->error(WCOOL(L"删除所有已读通知发生错误") + err.what());
			callback(true, XL("biz.deleteAllReadedNotice.failed"));
			return;
		}
		callback(false, XL(""));
	}

	void LocalConfig::getLocalContactList(boost::function<void(bool err, universal_resource, json::jobject)> callback)
	{
		IN_TASK_THREAD_WORKx(LocalConfig::getLocalContactList, callback);

		json::jobject data;
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			callback(true, XL("biz.getLocalContactList.failed.cannot.open.database"), data);
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		data_iterator dt;
		data_iterator dtcount;

		/*
		std::wstring sql =	L"select recentcontact.jid,  recentcontact.type, " \
		L"conversation.showname as c_showname, " \
		L"conversation.msg as c_msg, " \
		L"groupmsg.groupname as g_groupname, " \
		L"groupmsg.msg as g_msg, " \
		L"groupmsg.showname as g_showname, " \
		L"recentcontact.time " \
		L"from recentcontact " \
		L"left join  conversation " \
		L"on recentcontact.jid=conversation.jid left join groupmsg " \
		L"on recentcontact.jid=groupmsg.jid " \
		L"group by recentcontact.jid " \
		L"order by recentcontact.time desc" ;
		*/
		std::wstring sql =	L"select * from " \
			L"(select recentcontact.jid as jid ,  recentcontact.type as type, conversation.showname as c_showname, " \
			L"conversation.msg as c_msg, groupmsg.groupname as g_groupname, groupmsg.msg as g_msg, " \
			L"groupmsg.showname as g_showname, crowdmsg.crowdname as crowdname, crowdmsg.msg as crowdmsg, crowdmsg.showname as cr_showname, null as extra_info, null as msg_type, recentcontact.time as time, " \
			L"lightapp.msg as app_msg "
			L"from recentcontact left join conversation on recentcontact.jid=conversation.jid " \
			L"left join lightapp on recentcontact.jid=lightapp.appid "
			L"left join groupmsg on recentcontact.jid=groupmsg.jid left join crowdmsg on recentcontact.jid=crowdmsg.jid where type != 100 group by jid " \
			L"union select sys.jid, 100 as type, null as c_showname, sys.info as c_msg, null as g_groupname, " \
			L"null as g_msg, null as g_showname, null as crowdname, null as crowdmsg, null as cr_showname, sys.extra_info, sys.msg_type, sys.time, null as app_msg from  "\
			L"systemmessage as sys join recentcontact as rec on 100 = rec.type where sys.time = (select max(time) from systemmessage)) " \
			L"order by time desc;";

		try
		{
			dt = cur_epdb.execQuery( sql);
			bool hasSystem = false;
			while(dt!=data_iterator()) 
			{
				int type = dt->getField<int>(1);
				if((type!=100) || (type == 100 && !hasSystem))
				{

					json::jobject jobj;
					jobj["info"]["jid"] = dt->getField<std::string>(0);

					jobj["time"] = dt->getField<std::string>(12);
					if (type == (int)kRecentContact)//双人聊天
					{
						jobj["type"] = "conversation";
						jobj["msg"]  = dt->getField<std::string>(3);
						//添加未读会话条数
						try
						{
							dtcount = cur_epdb.execQuery(L"select count(*) from conversation where jid =? and is_read=0 and is_send=0", epDbBinder(epius::txtutil::convert_utf8_to_wcs(dt->getField<std::string>(0))));
							if (dtcount!=data_iterator())
							{
								jobj["unread_account"]  = dtcount->getField<int>(0);
							}
							dtcount =data_iterator();
						}
						catch(std::exception const&)
						{
							jobj["unread_account"]  = 0;
						}
					}
					else if(type == (int)kRecentMUC)//讨论组聊天
					{
						jobj["type"] = "group";
						jobj["msg"]  = dt->getField<std::string>(5);
						jobj["speaker"] = dt->getField<std::string>(6);
						//添加未读会话条数
						try
						{
							dtcount = cur_epdb.execQuery(L"select count(*) from groupmsg where jid=? and is_read=0 and is_send=0", epDbBinder(epius::txtutil::convert_utf8_to_wcs(dt->getField<std::string>(0))));
							if (dtcount!=data_iterator())
							{
								jobj["unread_account"]  = dtcount->getField<int>(0);
							}
							dtcount =data_iterator();
						}
						catch(std::exception const&)
						{
							jobj["unread_account"]  = 0;
						}
					}
					else if(type == (int)kRecentCrowd)//群聊天
					{
						jobj["type"] = "crowd";
						jobj["msg"]  = dt->getField<std::string>(8);
						jobj["speaker"] = dt->getField<std::string>(9);
						//添加未读会话条数
						try
						{
							dtcount = cur_epdb.execQuery(L"select count(*) from crowdmsg where jid=? and is_read=0 and is_send=0", epDbBinder(epius::txtutil::convert_utf8_to_wcs(dt->getField<std::string>(0))));
							if (dtcount!=data_iterator())
							{
								jobj["unread_account"]  = dtcount->getField<int>(0);
							}
							dtcount =data_iterator();
						}
						catch(std::exception const&)
						{
							jobj["unread_account"]  = 0;
						}
					}
					else if(type == 100)//系统消息
					{
						hasSystem = true;
						jobj["type"] = "system";
						json::jobject sysmsg;
						json::jobject info_jobj(dt->getField<std::string>(3));
						json::jobject extra_info_jobj(dt->getField<std::string>(10));
						if(info_jobj["info"])
						{
							sysmsg["info"] = info_jobj["info"].get<std::string>();
							sysmsg["extra_info"] = info_jobj["extra_info"].get<std::string>();
							sysmsg["operate"] = extra_info_jobj["operate"].get<std::string>();
						}
						else
						{
							sysmsg["info"] = dt->getField<std::string>(3);
							sysmsg["extra_info"] = dt->getField<std::string>(10);
							sysmsg["operate"] = "";
						}

						sysmsg["msg_type"] = dt->getField<std::string>(11);
						sysmsg["jid"] = jobj["info"]["jid"];

						jobj["msg"] = sysmsg;
						//添加未读会话条数
						try
						{
							dtcount = cur_epdb.execQuery(L"select count(*) from systemmessage where is_read=0");
							if (dtcount!=data_iterator())
							{
								jobj["unread_account"]  = dtcount->getField<int>(0);
							}
							dtcount =data_iterator();
						}
						catch(std::exception const&)
						{
							jobj["unread_account"]  = 0;
						}

					}
					else if (type == (int)KRecentLightApp)
					{
						jobj["type"] = "lightapp";
						jobj["msg"]  = json::jobject(dt->getField<std::string>(13));
						//添加未读会话条数
						try
						{
							dtcount = cur_epdb.execQuery(L"select count(*) from lightapp where appid=? and is_read=0 and is_send=0", epDbBinder(epius::txtutil::convert_utf8_to_wcs(dt->getField<std::string>(0))));
							if (dtcount!=data_iterator())
							{
								jobj["unread_account"]  = dtcount->getField<int>(0);
							}
							dtcount =data_iterator();
						}
						catch(std::exception const&)
						{
							jobj["unread_account"]  = 0;
						}
					}

					data.arr_push(jobj);
				}
				++dt;

			}
			dt=data_iterator();
		}
		catch(std::exception const&)
		{			
			ELOG("app")->error("can not fetch localmessages");
			callback(true, XL("biz.getLocalContactList.failed"), data);
			return;
		}
		ELOG("app")->error("local recent list return " + data.to_string());
		callback(false, XL(""), data);
	}

	bool LocalConfig::isNeedSaveUserInfo()
	{
		return impl_->needSaveUserInfo_;
	}

	void LocalConfig::deleteAllConvMsg( std::string type_string,std::string jid,std::string priority,boost::function<void(bool err, universal_resource)> callback)
	{
		IN_TASK_THREAD_WORKx(LocalConfig::deleteAllConvMsg, type_string,jid,priority,callback);
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot deleteAllConvMsg because db is NULL");
			return;
		}
		if (type_string.empty())
		{
			ELOG("app")->error("deleteAllConvMsg.bad.type.string");
			return;
		}		
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName); 
		std::wstring sql_deleteOneConvMsg;
		std::wstring table_name = impl_->get_tablename_by_type(type_string);
		epDbBinder epdb_bander;
		if (type_string.compare("lightapp") == 0)
		{
			sql_deleteOneConvMsg = L"delete from " + table_name + L" where appid = ?";
			epdb_bander = epDbBinder(jid);
		}
		else
		{
			if(jid != "")
			{
				//删除单条消息
				sql_deleteOneConvMsg = L"delete from " + table_name + L" where jid = ?";
				epdb_bander = epDbBinder(jid);
			}
			else
			{
				if (priority == "")
				{
					sql_deleteOneConvMsg = L"delete from " + table_name ;
				}
				else
				{
					//删除通知消息
					sql_deleteOneConvMsg = L"delete from " + table_name + L" where priority = ?";
					epdb_bander = epDbBinder(priority); 
				}		
			}	
		}
		
		try
		{
			cur_epdb.execQuery( sql_deleteOneConvMsg,epdb_bander);
		}
		catch(std::exception const&err)
		{
			ELOG("app")->error(WCOOL(L"deleteOneConvMsg  删除所有聊天记录失败")+err.what());
			callback(true, XL(""));
			return;
		}
		callback(false, XL(""));
	}

	void LocalConfig::deleteOneConvMsg( std::string type_string,std::string rowid ,boost::function<void(bool err, universal_resource)> callback)
	{
		//
		IN_TASK_THREAD_WORKx(LocalConfig::deleteOneConvMsg, type_string,rowid, callback);

		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot deleteOneConvMsg because db is NULL");
			return;
		}
		if (type_string.empty())
		{
			ELOG("app")->error("deleteOneConvMsg.bad.type.string");
			return;
		}		
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName); 
		std::wstring table_name = impl_->get_tablename_by_type(type_string);
		std::wstring sql_deleteOneConvMsg ;
		sql_deleteOneConvMsg = L"delete from " + table_name + L" where rowid = ?";

		try
		{
			cur_epdb.execQuery( sql_deleteOneConvMsg, epDbBinder(rowid));
		}
		catch(std::exception const&err)
		{
			ELOG("app")->error(WCOOL(L"deleteOneConvMsg  删除聊天记录失败")+err.what());
			callback(true, XL(""));
			return;
		}
		callback(false, XL(""));
	}

	void LocalConfig::updateSystemMsgIsread( std::string rowid,boost::function<void(bool err, universal_resource)> callback )
	{
		IN_TASK_THREAD_WORKx(LocalConfig::updateSystemMsgIsread, rowid, callback);
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot loadCurRequestFriends because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		epDbBinder tmpBind = epDbBinder(rowid);
		try
		{
			cur_epdb.execQuery( L"update systemmessage set is_read = 1 where rowid = ?",tmpBind);
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"获取消息记录错误") + err.what());
			callback(true,XL("deleteOneRequestMsg.error"));
			return;
		}
		callback(false,XL(""));
#ifndef _WIN32
		//通知界面最近联系人更新
		data_iterator dt;
		data_iterator dtcount;
		json::jobject jobj;
		std::string max_time = getCurrentTime();

		try
		{
			dt = cur_epdb.execQuery( L"select time from recentcontact where type = 100");
			if(dt!=data_iterator())
			{
				max_time = dt->getField<std::string>(0);	
			}
			dt = data_iterator();
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error("通知会话列表出错，无法获取系统消息的最近时间。");
		}
		int newCount = 0;	
		try
		{
			dtcount = cur_epdb.execQuery( L"select count(*) from systemmessage where is_read=0");
			if (dtcount!=data_iterator())
			{
				newCount = dtcount->getField<int>(0);
			}
			dtcount =data_iterator();
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error("无法获取未读系统消息的数目。");
			newCount = 0;

		}

		try{
			dt = cur_epdb.execQuery( L"select jid, info, extra_info, msg_type, is_read, time from systemmessage where systemmessage.time = (select max(time) from systemmessage)");
			std::string jid_string;
			std::string extra_info;
			std::string info;
			std::string msg_type;
			std::string msg_time;
			std::string operate;
			int is_read = 0;

			if(dt!=data_iterator())
			{
				jid_string = dt->getField<std::string>(0);
				json::jobject info_jobj(dt->getField<std::string>(1));
				json::jobject extra_info_jobj(dt->getField<std::string>(2));
				if (info_jobj["info"])
				{
					info = info_jobj["info"].get<std::string>();
					extra_info = info_jobj["extra_info"].get<std::string>();
					operate = extra_info_jobj["operate"].get<std::string>();
				}
				else//兼容以前数据库
				{
					info = dt->getField<std::string>(1);
					extra_info = dt->getField<std::string>(2);
					operate = "";
				}			
				msg_type = dt->getField<std::string>(3);
				is_read = dt->getField<int>(4);
				msg_time = dt->getField<std::string>(5);
			}

			dt = data_iterator();

			jobj["info"]["jid"] = jid_string;
			jobj["time"] = max_time;
			jobj["type"] = "system";
			jobj["flag"] = "update";
			jobj["unread_account"] = newCount;
			json::jobject sysmsg;
			sysmsg["info"] = info;
			sysmsg["operate"] = operate;
			sysmsg["extra_info"] = extra_info;
			sysmsg["msg_type"] = msg_type;
			sysmsg["jid"] = jobj["info"]["jid"];
			sysmsg["time"] = msg_time;

			jobj["msg"] = sysmsg;
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error("通知会话列表失败，因为无法获取最近的系统消息内容。");
			return;

		}
		event_collect::instance().update_recent_contact(jobj.clone());
#endif
	}

	std::string LocalConfig::get_show_name()
	{
		// 默认配置为按照备注显示
		std::string show_name = "remark_name";
		if(!db_connection::instance().get_db(s_rootConfigName))
		{
			ELOG("app")->error("Cannot loadCurRequestFriends because db is NULL");
			return show_name;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_rootConfigName);
		try
		{			
			data_iterator it = cur_epdb.execQuery( L"select id,data from special where id = \"showNameSelect\" ");
			if(it!=data_iterator())
			{
				show_name = it->getField<std::string>(1);
			}
		}
		catch(...)
		{
			return show_name;
		}	
		return show_name;
	}

	void LocalConfig::saveOrganizationData( int parentid, json::jobject jobj, std::string time)
	{
		IN_TASK_THREAD_WORKx(LocalConfig::saveOrganizationData, parentid, jobj, time);

		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot saveOrganizationData because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		epDbBinder tmpBind = epDbBinder(parentid);
		try
		{
			cur_epdb.execDML(  L"delete from organization where parentid = (?)",tmpBind);
			cur_epdb.execDML( L"insert into organization (parentid, info, time) values (?,?,?);",epDbBinder(parentid, jobj.to_string(), time));
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"存储组织节点错误") + err.what());
		}
	}

	json::jobject LocalConfig::loadOrganizationData( int parentid )
	{
		json::jobject jobj;
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot loadOrganizationData because db is NULL");
			return jobj;
		}

		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		try
		{
			data_iterator dt = cur_epdb.execQuery( L"select info,time from organization where parentid = (?);",epDbBinder(parentid));
			if(dt!=data_iterator())
			{
				std::string info = dt->getField<std::string>(0); // 0: info.
				std::string time = dt->getField<std::string>(1); // 1: time.
				jobj = json::jobject(info);
				jobj["timestamp"] = time;
			}
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"读取组织节点错误") + err.what());
		}

		return jobj;
	}

	void LocalConfig::saveFileTransferMsg( std::string jid, std::string msg, boost::function<void(json::jobject)> callback )
	{
		IN_TASK_THREAD_WORKx(LocalConfig::saveFileTransferMsg, jid, msg, callback);

		json::jobject message(msg);
		saveMessage(jid, "", "conversation", true, message);
		callback(message);
	}

	//从history数据库中groupmsg表中获取所有讨论组的jid
	void LocalConfig::get_quit_group_list( json::jobject jobj,json::jobject& quit_group_jobj)
	{
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot get_all_group_jid because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName); 
		int j = 0;
		try
		{
			data_iterator dt = cur_epdb.execQuery( L"select jid,groupname from groupmsg group by jid;");
			while(dt != data_iterator())
			{ 
				std::string group_jid = dt->getField<std::string>(0); //group jid
				std::string group_name = dt->getField<std::string>(1);//group name
				if (jobj.arr_size() > 0)
				{
					for (int i = 0;i < jobj.arr_size();i++ )
					{
						if (group_jid == jobj[i]["session_id"].get<std::string>())
						{
							break;
						}
						else
						{
							if (i == jobj.arr_size() - 1)
							{
								quit_group_jobj[j]["session_id"] = group_jid;
								quit_group_jobj[j]["group_name"] = group_name;
								++j;
							}
						}
					}			
				}
				else
				{
					quit_group_jobj[j]["session_id"] = group_jid;
					quit_group_jobj[j]["group_name"] = group_name;
					++j;
				}
				++dt;
			}
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"获取讨论组jid失败") + err.what());
		}
	}

	void LocalConfig::replaceMessageByRowid( std::string type, std::string rowid, std::string msg, boost::function<void(bool err, universal_resource)> callback )
	{
		IN_TASK_THREAD_WORKx(LocalConfig::replaceMessageByRowid, type, rowid, msg, callback);

		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot replaceMessageByRowid because db is NULL");
			callback(true,XL("replaceMessageByRowid.error"));
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		std::wstring table_name = impl_->get_tablename_by_type(type);
		if (table_name.empty())
		{
			ELOG("app")->error("Cannot replaceMessageByRowid bad tablename");
			callback(true,XL("replaceMessageByRowid.error"));
			return;
		}
		std::wstring sqlstr = (boost::wformat(L"update %s set msg = ? where rowid = ?")%table_name.c_str()).str();
		try
		{
			int ncount = cur_epdb.execDML(sqlstr, epDbBinder(epius::txtutil::convert_utf8_to_wcs(msg), rowid));
			if (ncount ==1)
			{
				callback(false,XL(""));
				return;
			}
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"替换指定rowid消息错误") + err.what());
		}

		callback(true,XL("replaceMessageByRowid.error"));
	}

	std::string LocalConfig::SaveAppNoticeMessage( std::string notice_id, std::string publisher, std::string msg, std::string expired_time, std::string priority)
	{
		std::string last_rowid;
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot SaveAppNoticeMessage because db is NULL");
			return "";
		}		
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		try
		{
			std::string publisher_id; // not used
			cur_epdb.execDML( biz_sql::s_sqlInsert_NoticeMessage,epius::epius_sqlite3::epDbBinder(notice_id, publisher_id, (int)0, publisher, msg, getCurrentTime(), expired_time, priority));
			last_rowid = boost::lexical_cast<std::string>(cur_epdb.last_insert_rowid());
		}
		catch(std::exception const& e)
		{
			ELOG("app")->error(WCOOL(L"保存第三方通知消息失败") + e.what());
			return "";
		}
		return last_rowid;
	}

	void LocalConfig::SaveAppMessage( std::string message_id, std::string service_id, std::string service_name, std::string service_icon, std::string msg, std::string timestamp, bool is_has_read)
	{
		IN_TASK_THREAD_WORKx(LocalConfig::SaveAppMessage, message_id, service_id, service_name, service_icon, msg, timestamp, is_has_read);

		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot SaveAppMessage because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		try
		{
			if (is_has_read)
			{
				cur_epdb.execDML( L"insert into app_message (id, service_id, service_name, service_icon, is_read, msg, send_time, dt) values (?, ?, ?, ?, ?, ?, ?, ?);", 
					epius::epius_sqlite3::epDbBinder( message_id, service_id, service_name, service_icon, (int)1, msg, timestamp, getCurrentTime()));
			}
			else
			{
				cur_epdb.execDML( L"insert into app_message (id, service_id, service_name, service_icon, is_read, msg, send_time, dt) values (?, ?, ?, ?, ?, ?, ?, ?);", 
					epius::epius_sqlite3::epDbBinder( message_id, service_id, service_name, service_icon, (int)0, msg, timestamp, getCurrentTime()));
			}

		}
		catch(std::exception const& e)
		{
			ELOG("app")->error(WCOOL(L"保存第三方消息失败") + e.what());
		}
	}

	void LocalConfig::SaveAppMessage( std::string message_id, std::string service_id, std::string service_name, std::string service_icon, std::string msg, std::string timestamp)
	{
		SaveAppMessage(message_id, service_id, service_name, service_icon, msg, timestamp, false);
	}

	void LocalConfig::MarkAppMessage( std::string service_id, std::string message_id, boost::function<void(bool err, universal_resource)> callback )
	{
		IN_TASK_THREAD_WORKx(LocalConfig::MarkAppMessage, service_id, message_id, callback);

		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot MarkAppMessage because db is NULL");
			callback(true, XL(""));
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		try
		{
			if (!service_id.empty())
			{
				std::wstring sql_query = L"select id from app_message where is_read =0 and service_id = ?";
				data_iterator dt = cur_epdb.execQuery(sql_query, epDbBinder(service_id));
				std::vector<std::string> message_ids;
				while(dt!=data_iterator())
				{
					message_ids.push_back(dt->getField<std::string>(0));
					++dt;
				}

				if (message_ids.size() == 0)
				{
					callback(false, XL(""));
					return;
				}

				std::wstring sql_update = L"update app_message set is_read = 1 where service_id = ?";
				cur_epdb.execDML(sql_update, epDbBinder(service_id));


				for (int index =0; index<message_ids.size(); index++)
				{
					gWrapInterface::instance().ack_app_message( message_ids[index], "read");
				}

				callback(false, XL(""));
			}
			else if (!message_id.empty())
			{
				std::wstring sql_update = L"update app_message set is_read = 1 where id = ?";
				cur_epdb.execDML(sql_update, epDbBinder(message_id));

				gWrapInterface::instance().ack_app_message( message_id, "read");
				
				callback(false, XL(""));
			}
		}
		catch(epius_dberror const& err)
		{
			ELOG("db")->error(WCOOL(L"更新app_message表发生错误") + err.what());
			callback(true, XL(""));
		}
	}

	void LocalConfig::DeleteAppMessageByID( std::string message_id, boost::function<void(bool err, universal_resource)> callback )
	{
		IN_TASK_THREAD_WORKx(LocalConfig::DeleteAppMessageByID, message_id, callback);

		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot DeleteAppMessageByID because db is NULL");
			callback(true, XL(""));
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		try
		{
			std::wstring sql_delete = L"delete from app_message where id = ?";
			cur_epdb.execDML(sql_delete, epDbBinder(message_id));

			callback(false, XL(""));
		}
		catch(epius_dberror const& err)
		{
			ELOG("db")->error(WCOOL(L"删除app_message表发生错误") + err.what());
			callback(true, XL(""));
		}
	}

	void LocalConfig::DeleteAppMessageByServiceID( std::string service_id, boost::function<void(bool err, universal_resource)> callback )
	{
		IN_TASK_THREAD_WORKx(LocalConfig::DeleteAppMessageByServiceID, service_id, callback);

		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot DeleteAppMessageByServiceID because db is NULL");
			callback(true, XL(""));
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		try
		{
			std::wstring sql_delete = L"delete from app_message where service_id = ?";
			cur_epdb.execDML(sql_delete, epDbBinder(service_id));
			callback(false, XL(""));
		}
		catch(epius_dberror const& err)
		{
			ELOG("db")->error(WCOOL(L"删除app_message表发生错误") + err.what());
			callback(true, XL(""));
		}
	}

	void LocalConfig::DeleteAllAppMessageByID(boost::function<void(bool err, universal_resource)> callback)
	{
		IN_TASK_THREAD_WORKx(LocalConfig::DeleteAllAppMessageByID, callback);

		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot DeleteAllAppMessageByID because db is NULL");
			callback(true, XL(""));
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		try
		{
			std::wstring sql_delete = L"delete from app_message";
			cur_epdb.execDML(sql_delete);
			callback(false, XL(""));
		}
		catch(epius_dberror const& err)
		{
			ELOG("db")->error(WCOOL(L"删除app_message表发生错误") + err.what());
			callback(true, XL(""));
		}
	}

	void LocalConfig::DeleteAllReadedAppMessage( boost::function<void(bool err, universal_resource)> callback )
	{
		IN_TASK_THREAD_WORKx(LocalConfig::DeleteAllReadedAppMessage, callback);

		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot DeleteAllReadedAppMessage because db is NULL");
			callback(true, XL(""));
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		try
		{
			std::wstring sql_delete = L"delete from app_message where is_read = 1";
			cur_epdb.execDML(sql_delete);
			callback(false, XL(""));
		}
		catch(epius_dberror const& err)
		{
			ELOG("db")->error(WCOOL(L"删除app_message表发生错误") + err.what());
			callback(true, XL(""));
		}
	}

	void LocalConfig::GetAppMessageHistory(std::string service_id, int begin_idx, int count, boost::function<void(bool err, json::jobject)> callback )
	{
		IN_TASK_THREAD_WORKx(LocalConfig::GetAppMessageHistory, service_id, begin_idx, count, callback);

		json::jobject jobj;
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot GetAppMessageHistory because db is NULL");
			callback(true, jobj);
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		try	
		{
			std::wstring sql_query;
			data_iterator dt;
			if (service_id.empty())
			{
				if (begin_idx == -1)
				{
					sql_query = L"select id, service_id, service_name, service_icon, is_read, msg, send_time, dt from app_message order by send_time desc limit ? , ?;";
				}
				else
				{
					sql_query = L"select id, service_id, service_name, service_icon, is_read, msg, send_time, dt from app_message order by send_time asc limit ? , ?;";
				}
				dt = cur_epdb.execQuery( sql_query, epDbBinder(begin_idx, count));
			}
			else
			{
				if (begin_idx == -1)
				{
					sql_query = L"select id, service_id, service_name, service_icon, is_read, msg, send_time, dt from app_message where service_id =? order by send_time desc limit ? , ?;";
				}
				else
				{
					sql_query = L"select id, service_id, service_name, service_icon, is_read, msg, send_time, dt from app_message where service_id =? order by send_time asc limit ? , ?;";
				}
				dt = cur_epdb.execQuery( sql_query, epDbBinder(service_id, begin_idx, count));
			}
						
			json::jobject tmp_result;
			while(dt!=data_iterator())
			{
				std::string id = dt->getField<std::string>(0);
				std::string service_id = dt->getField<std::string>(1);
				std::string service_name = dt->getField<std::string>(2);
				std::string service_icon = dt->getField<std::string>(3);
				int is_read = dt->getField<int>(4);
				std::string msg = dt->getField<std::string>(5);
				std::string send_time = dt->getField<std::string>(6);
				std::string save_time = dt->getField<std::string>(7);

				json::jobject msgtmp;
				msgtmp["message_id"] = id;
				msgtmp["is_read"] = is_read;
				msgtmp["sendTime"] = send_time;
				msgtmp["msg"] = json::jobject(msg);
				msgtmp["service_info"]["id"] = service_id;
				msgtmp["service_info"]["name"] = service_name;
				msgtmp["service_info"]["icon"] = service_icon;
				tmp_result.arr_push(msgtmp);
				++dt;
			}

			if (begin_idx == -1)
			{
				int i = tmp_result.arr_size() -1;
				for ( ; i>= 0; i--)
				{
					jobj["msgs"].arr_push(tmp_result[i]);
				}
			}
			else
			{
				jobj["msgs"] = tmp_result;
			}

			std::wstring sql_count ;
			data_iterator dtcount;
			if (service_id.empty())
			{
				sql_count = L"select count(*) from app_message";
				dtcount = cur_epdb.execQuery( sql_count);
			}
			else
			{
				sql_count = L"select count(*) from app_message where service_id = ?";
				dtcount = cur_epdb.execQuery( sql_count, epDbBinder(service_id));		
			}	
			if(dtcount!=data_iterator())
			{
				jobj["count_all"] = dtcount->getField<int>(0);
			}
			callback(false, jobj);
		}
		catch(epius_dberror const& err)
		{
			ELOG("db")->error(WCOOL(L"查询app_message表发生错误") + err.what());
			callback(true, jobj);
		}
	}

	void LocalConfig::GetRecentAppMessages( boost::function<void(bool err, json::jobject)> callback )
	{
		IN_TASK_THREAD_WORKx(LocalConfig::GetRecentAppMessages, callback);
		json::jobject jobj;
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot GetRecentAppMessages because db is NULL");
			callback(true, jobj);
			return;
		}

		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		try
		{
			std::wstring sql_query;
			sql_query = L"select id, service_id, service_name, service_icon, is_read, msg, send_time, dt from app_message group by service_id order by send_time desc, service_id asc;";
			data_iterator dt = cur_epdb.execQuery( sql_query);
			while(dt!=data_iterator()){

				json::jobject service;

				std::string message_id = dt->getField<std::string>(0);
				std::string service_id = dt->getField<std::string>(1);
				std::string service_name = dt->getField<std::string>(2);
				std::string service_icon = dt->getField<std::string>(3);
				std::string msg = dt->getField<std::string>(5);
				std::string send_time = dt->getField<std::string>(6);

				service["msg"]["sendTime"] = send_time;
				service["msg"]["msg"] = json::jobject(msg);
				service["msg"]["message_id"] = message_id;
				service["service_info"]["id"] = service_id;
				service["service_info"]["name"] = service_name;
				service["service_info"]["icon"] = service_icon;
				std::string download_path;
				json::jobject s_info = service["service_info"];
				//if (get_parent_impl()->bizNotice_->is_need_download_icon(service["service_info"], download_path))
				if (get_parent_impl()->bizNotice_->is_need_download_icon(s_info, download_path))
				{
					createDirectories();

					boost::function<void(bool,std::string)> callback = boost::bind(&notice_msg::finished_syncdown_icon, get_parent_impl()->bizNotice_, service_id, service_name, download_path, _1, _2);
					epius::http_requests::instance().download(anan_config::instance().get_http_down_path(), download_path, service_icon, "", boost::function<void(int)>(), epius::thread_switch::CmdWrapper(get_parent_impl()->_p_private_task_->get_post_cmd(),callback));
				}

				std::wstring sql_count = L"select count(*) from app_message where is_read = 0 and service_id = ?";

				data_iterator dtcount = cur_epdb.execQuery( sql_count, epDbBinder(service_id));
				if(dtcount!=data_iterator())
				{
					service["unread_count"] = dtcount->getField<int>(0);
				}

				sql_count = L"select count(*) from app_message where service_id = ?";

				dtcount = cur_epdb.execQuery( sql_count, epDbBinder(service_id));
				if(dtcount!=data_iterator())
				{
					service["count_all"] = dtcount->getField<int>(0);
				}

				jobj.arr_push(service);

				++dt;
			}
			callback(false, jobj);
		}
		catch(epius_dberror const& err)
		{
			ELOG("db")->error(WCOOL(L"查询app_message表发生错误") + err.what());
			callback(true, jobj);
		}
	}

	void LocalConfig::GetUnreadAppMessageCountByServiceID( std::string service_id, json::jobject jobj)
	{	
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot GetUnreadAppMessageCountByServiceID because db is NULL");
			return;
		}

		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		try
		{

			std::wstring sql_count = L"select count(*) from app_message where is_read = 0 and service_id = ?";

			data_iterator dtcount = cur_epdb.execQuery( sql_count, epDbBinder(service_id));
			if(dtcount!=data_iterator())
			{
				jobj["unread_count"] = dtcount->getField<int>(0);
			}
		}
		catch(epius_dberror const& err)
		{
			ELOG("db")->error(WCOOL(L"查询app_message表发生错误") + err.what());
		}
	}

	void LocalConfig::loadUnreadSystemMessageCount( boost::function<void(json::jobject)> callback )
	{
		IN_TASK_THREAD_WORKx(LocalConfig::loadUnreadSystemMessageCount, callback);
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("try to load unread systemmessage when db is not ready.");
			return;
		}
		if (callback.empty())
			return;
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName); 
		json::jobject jobj;
		try
		{
			std::wstring sql_get_systemmessage_count = L"select count(*) from systemmessage where is_read=0";
			data_iterator dt = cur_epdb.execQuery( sql_get_systemmessage_count);
			if(dt!=data_iterator())
			{
				jobj["count_all"] = dt->getField<int>(0);
				callback(jobj);
			}	
		}
		catch(std::exception const&err)
		{
			ELOG("app")->error(WCOOL(L"loadUnreadSystemMessageCount 取未读数量消息失败")+err.what());
		}
	}
	void LocalConfig::GetUnreadAppMessage( std::string service_id, boost::function<void(bool err, json::jobject)> callback )
	{
		IN_TASK_THREAD_WORKx(LocalConfig::GetUnreadAppMessage, service_id, callback);
		json::jobject jobj;
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot GetUnreadAppMessage because db is NULL");
			callback(true, jobj);
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		try	
		{
			std::wstring sql_query;
			sql_query = L"select id, service_id, service_name, service_icon, is_read, msg, send_time, dt from app_message where is_read = 0 and service_id =? order by send_time;";

			data_iterator dt = cur_epdb.execQuery( sql_query, epDbBinder(service_id));
			while(dt!=data_iterator())
			{
				std::string id = dt->getField<std::string>(0);
				std::string service_id = dt->getField<std::string>(1);
				std::string service_name = dt->getField<std::string>(2);
				std::string service_icon = dt->getField<std::string>(3);
				int is_read = dt->getField<int>(4);
				std::string msg = dt->getField<std::string>(5);
				std::string send_time = dt->getField<std::string>(6);
				std::string save_time = dt->getField<std::string>(7);

				json::jobject msgtmp;
				msgtmp["message_id"] = id;
				msgtmp["sendTime"] = send_time;
				msgtmp["msg"] = json::jobject(msg);
				jobj.arr_push(msgtmp);
				++dt;
			}

			callback(false, jobj);
		}
		catch(epius_dberror const& err)
		{
			ELOG("db")->error(WCOOL(L"查询app_message表发生错误") + err.what());
			callback(true, jobj);
		}
	}

	void LocalConfig::loadAllUnreadSystemMsg( std::string type, boost::function<void(json::jobject,bool,universal_resource)> callback )
	{
		IN_TASK_THREAD_WORKx(LocalConfig::loadAllUnreadSystemMsg,type, callback);
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot loadAllUnreadSystemMsg because db is NULL");
			return;
		}
		std::wstring sql_type; 
		if (type == "crowd")
		{
			sql_type = L" and msg_type not in ( \"request\", \"reject\", \"agree\") ";
		}
		else if (type == "friend")
		{
			sql_type = L" and msg_type in ( \"request\", \"reject\", \"agree\") ";
		}

		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);	
		std::wstring sql_count = L"select count(*) from systemmessage where is_read = 0" + sql_type;
		std::wstring sql_all = L"select jid,info,extra_info,time,server_time,msg_type,rowid,is_read from systemmessage where is_read = 0" + sql_type;
		json::jobject jobj,jobj_data;
		int count_all;
		try
		{
			data_iterator dt_count = cur_epdb.execQuery( sql_count);
			jobj["count"] = dt_count->getField<std::string>(0);
			count_all = dt_count->getField<int>(0);
			dt_count = epius::epius_sqlite3::data_iterator();

			data_iterator dt = cur_epdb.execQuery( sql_all);
			int i = 0;
			while(dt!=data_iterator())
			{
				json::jobject tmp_jobj;
				tmp_jobj["jid"] = dt->getField<std::string>(0); // 0: id.
				json::jobject info_jobj(dt->getField<std::string>(1));
				json::jobject extra_info_jobj(dt->getField<std::string>(2));
				if (info_jobj["info"])
				{
					tmp_jobj["info"] = info_jobj["info"].get<std::string>();
					tmp_jobj["extra_info"] = info_jobj["extra_info"].get<std::string>();
					tmp_jobj["operate"] = extra_info_jobj["operate"].get<std::string>();
				}
				else
				{
					tmp_jobj["info"] = dt->getField<std::string>(1);
					tmp_jobj["extra_info"] = dt->getField<std::string>(2);
					tmp_jobj["operate"] = "";
				}
				std::string date_time = dt->getField<std::string>(3); // 1: info
				tmp_jobj["date"] = date_time.substr(0,date_time.find(" "));
				tmp_jobj["time"] = date_time.substr(date_time.find(" ") + 1); // 1: info.
				tmp_jobj["server_time"] = dt->getField<std::string>(4); // 4: dt.
				tmp_jobj["msg_type"] = (dt->getField<std::string>(5)); // 5: subid.
				tmp_jobj["rowid"] = (dt->getField<std::string>(6)); // 5: subid.
				std::string is_read_string = (dt->getField<std::string>(7));//7: is_read
				tmp_jobj["is_read"] = is_read_string;
				jobj_data.arr_push(tmp_jobj);
				++dt;
			}
			jobj["data"] = jobj_data;
			callback(jobj,false,XL(""));
		}
		catch(std::exception const&err)
		{
			ELOG("app")->error(WCOOL(L"loadAllUnreadSystemMsg读取数据库错误")+err.what());
			callback(jobj,true,XL(""));
		}
	}

	void LocalConfig::loadAllUnreadAppMessage(bool count_only, boost::function<void(bool err, json::jobject)> callback )
	{
		IN_TASK_THREAD_WORKx(LocalConfig::loadAllUnreadAppMessage, count_only, callback);
		json::jobject jobj;
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot GetUnreadAppMessage because db is NULL");
			callback(true, jobj);
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		try	
		{
			std::wstring sql_query = L"select id, service_id, service_name, service_icon, is_read, msg, send_time, dt from app_message where is_read = 0";
			std::wstring sql_get_app_message_count = L"select count(*) from app_message where is_read=0";
			data_iterator dt_count = cur_epdb.execQuery( sql_get_app_message_count);
			if(dt_count != data_iterator())
			{
				jobj["count_all"] = dt_count->getField<int>(0);
			}	

			if (!count_only)
			{
				data_iterator dt = cur_epdb.execQuery( sql_query);
				while(dt != data_iterator())
				{
					std::string id = dt->getField<std::string>(0);
					std::string service_id = dt->getField<std::string>(1);
					std::string service_name = dt->getField<std::string>(2);
					std::string service_icon = dt->getField<std::string>(3);
					int is_read = dt->getField<int>(4);
					std::string msg = dt->getField<std::string>(5);
					std::string send_time = dt->getField<std::string>(6);
					std::string save_time = dt->getField<std::string>(7);

					json::jobject msgtmp;
					msgtmp["message_id"] = id;
					msgtmp["sendTime"] = send_time;
					msgtmp["msg"] = json::jobject(msg);
					jobj.arr_push(msgtmp);
					++dt;
				}
			}

			callback(false, jobj);
		}
		catch(epius_dberror const& err)
		{
			ELOG("db")->error(WCOOL(L"查询app_message表发生错误") + err.what());
			callback(true, jobj);
		}
	}

	void LocalConfig::loadUnreadAppMessageCount( boost::function<void(json::jobject)> callback )
	{
		IN_TASK_THREAD_WORKx(LocalConfig::loadUnreadAppMessageCount, callback);
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("try to load unread app_messsage when db is not ready.");
			return;
		}
		if (callback.empty())
		{
			return;	
		}

		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName); 
		json::jobject jobj;
		try
		{
			std::wstring sql_get_app_message_count = L"select count(*) from (select service_id from app_message where is_read=0 group by service_id)";
			data_iterator dt = cur_epdb.execQuery( sql_get_app_message_count);
			if(dt != data_iterator())
			{
				jobj["count_all"] = dt->getField<int>(0);
				callback(jobj);			
			}

		}
		catch(std::exception const&err)
		{
			ELOG("app")->error(WCOOL(L"loadUnreadAppMessageCount 取未读数量消息失败")+err.what());
		}
	}

	void LocalConfig::fixMessageShowname()
	{
		IN_TASK_THREAD_WORK0(LocalConfig::fixMessageShowname);

		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("fixMessageShowname failed when db is not ready.");
			return;
		}

		std::set<std::string> update_jids;
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName); 

		try
		{
			// 修复会话记录数据库中 showname为"微哨用户“的会话数据
			std::wstring sql = L"select distinct subid from crowdmsg where showname = \'微哨用户\'";
			data_iterator dt = cur_epdb.execQuery( sql);
			while(dt != data_iterator())
			{
				update_jids.insert( dt->getField<std::string>(0) );
				++dt;
			}

			sql = L"select distinct subid from groupmsg where showname = \'微哨用户\'";
			dt = cur_epdb.execQuery( sql);
			while(dt != data_iterator())
			{
				update_jids.insert( dt->getField<std::string>(0) );
				++dt;
			}

			sql = L"select distinct jid from conversation where showname = \'微哨用户\'";
			dt = cur_epdb.execQuery( sql);
			while(dt != data_iterator())
			{
				update_jids.insert( dt->getField<std::string>(0) );
				++dt;
			}

			std::set<std::string>::iterator it;
			for(it = update_jids.begin(); it!= update_jids.end(); it++)
			{
				if (get_parent_impl()->bizRoster_->requesting_vcard_jid_.find(*it) == get_parent_impl()->bizRoster_->requesting_vcard_jid_.end())
				{
					get_parent_impl()->bizRoster_->addgetRequestVCardWait(*it, S10nNone, vard_type_base, 
						bind_s(&AnRosterManager::updateMessageShowname, get_parent_impl()->bizRoster_, *it, _1));
					get_parent_impl()->bizRoster_->requestVcard_jids_.insert(*it);
				}
			}

		}
		catch(std::exception const&err)
		{
			ELOG("app")->error(WCOOL(L"fixMessageShowname 失败")+err.what());
		}
	}


	void LocalConfig::update_request_msg( std::string rowid,std::string operate )
	{
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot updateCurRoster because db is NULL");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);	
		try
		{
			cur_epdb.execDML( L"update systemmessage set extra_info = ? where rowid = ? ", epDbBinder(operate,rowid));
		}
		catch(epius_dberror const& err)
		{
			ELOG("app")->error(WCOOL(L"更新好友处理操作失败") + err.what());
			return;
		}
	}

	int LocalConfig::SaveLightappMessage(std::string appid, bool is_send, json::jobject msg, std::string msgid )
	{
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot SaveLightappMessage because db is NULL");
			return -1;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		int nrowid = 0;
		try
		{
			time_t now;
			now = time(NULL);
			int nrow= cur_epdb.execDML( L"insert into lightapp (appid, is_read, is_send, msg, dt, id) values (?,?,?,?,?,?);" , 
				epius::epius_sqlite3::epDbBinder( appid, (int)is_send, (int)is_send, msg.to_string(), (int)now, msgid));

			if (nrow == 1)
			{
				nrowid = cur_epdb.last_insert_rowid();
			}
			struct tm *lnow = localtime(&now);
			boost::posix_time::ptime t = boost::posix_time::ptime_from_tm(*lnow);
			std::string dt = epius::time_format(t);
			cur_epdb.execDML( biz_sql::s_sqlReplaceRecentContact, epDbBinder(appid, (int)KRecentLightApp, dt));

#ifndef _WIN32
			//通知界面最近联系人更新
			json::jobject jobj;
			jobj["info"]["appid"] = appid;
			jobj["time"] = dt;
			jobj["type"] = "lightapp";
			jobj["msg"]  = msg.to_string();
			//添加未读会话条数
			try
			{
				data_iterator  dtcount;
				dtcount = cur_epdb.execQuery( L"select count(*) from lightapp where appid =? and is_read=0 and is_send=0", epDbBinder(epius::txtutil::convert_utf8_to_wcs(appid)));
				if (dtcount!=data_iterator())
				{
					jobj["unread_account"]  = dtcount->getField<int>(0);
				}
				dtcount =data_iterator();
			}
			catch(std::exception const&)
			{
				jobj["unread_account"]  = 0;
			}

			event_collect::instance().update_recent_contact(jobj.clone());
#endif
		}
		catch(std::exception const& e)
		{
			ELOG("app")->error(WCOOL(L"保存轻应用消息失败") + e.what());
			return -1;
		}
		return nrowid;
	}

	void LocalConfig::loadUnreadLightappMessageCount( json::jobject &jobj )
	{
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("loadUnreadLightappMessageCount failed when db is not ready.");
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName); 
		try
		{
			json::jobject count;
			std::wstring sql_get_lightapp_message_count = L"select count(*) from (select appid from lightapp where is_read=0 group by appid)";
			data_iterator dt = cur_epdb.execQuery( sql_get_lightapp_message_count);
			if(dt != data_iterator())
			{
				if (dt->getField<int>(0) > 0) //存在轻应用未读消息
				{
					count["type"] = "lightapp";
					count["count_all"] = dt->getField<int>(0);
					jobj["data"].arr_push(count);

					std::wstring sql_get_lightapp_message = L"select appid, msg, dt, rowid, count(*) from lightapp where is_send=0 and is_read=0 group by appid";
					data_iterator dt2 = cur_epdb.execQuery( sql_get_lightapp_message);
					if(dt2 != data_iterator())
					{
						json::jobject msg;
						msg["type"] = "lightapp_msg";
						msg["appid"] = dt2->getField<std::string>(0);
						msg["last-msg"] = json::jobject(dt2->getField<std::string>(1));

						time_t ntime = dt2->getField<int>(2);
						struct tm *lnow = localtime(&ntime);
						boost::posix_time::ptime t = boost::posix_time::ptime_from_tm(*lnow);
						std::string time = epius::time_format(t);

						msg["last-ntime"] = (int)ntime;
						msg["last-time"] = time;
						msg["rowid"] = dt2->getField<std::string>(3);
						msg["count_all"] = dt2->getField<int>(4);
						jobj["data"].arr_push(msg);
					}
				}
			}	
		}
		catch(std::exception const&err)
		{
			ELOG("app")->error(WCOOL(L"loadUnreadLightappMessageCount 取未读数量消息失败")+err.what());
		}

	}

	void LocalConfig::loadUnreadLightappMessage( std::string appid, bool mark_read, boost::function<void(json::jobject)> callback )
	{
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("loadUnreadLightappMessage failed when db is not ready.");
			return;
		}

		json::jobject jobj;
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName); 
		try
		{
			std::wstring sql_get_lightapp_message = L"select appid, msg, dt, rowid from lightapp where is_send=0 and is_read=0 and appid=?";
			data_iterator dt = cur_epdb.execQuery( sql_get_lightapp_message, epius::epius_sqlite3::epDbBinder(appid));
			while(dt != data_iterator())
			{
				json::jobject msg;
				msg["type"] = "lightapp_msg";
				msg["appid"] = dt->getField<std::string>(0);
				msg["msg"] = json::jobject(dt->getField<std::string>(1));

				time_t ntime = dt->getField<int>(2);
				struct tm *lnow = localtime(&ntime);
				boost::posix_time::ptime t = boost::posix_time::ptime_from_tm(*lnow);
				std::string time = epius::time_format(t);

				msg["ntime"] = (int)ntime;
				msg["dt"] = time;
				msg["rowid"] = dt->getField<std::string>(3);
				jobj["data"].arr_push(msg);
				++dt;
			}

			jobj["count_all"] = jobj["data"].arr_size();

			if (mark_read)
			{
				std::wstring sql_set_lightapp_read = L"update lightapp set is_read=1 where is_send=0 and is_read=0 and appid=?";
				cur_epdb.execDML( sql_set_lightapp_read, epius::epius_sqlite3::epDbBinder(appid));
			}

			if (!callback.empty())
			{
				callback(jobj);
			}
		}
		catch(std::exception const&err)
		{
			ELOG("app")->error(WCOOL(L"loadUnreadLightappMessage 取未读消息失败")+err.what());
		}
	}

	void LocalConfig::GetLightappMessageHistory( std::string appid, int begin_idx, int count, boost::function<void(bool err, json::jobject)> callback )
	{
		IN_TASK_THREAD_WORKx(LocalConfig::GetLightappMessageHistory, appid, begin_idx, count, callback);

		json::jobject jobj;
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot GetLightappMessageHistory because db is NULL");
			callback(true, jobj);
			return;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		try	
		{
			std::wstring sql_query;
			if (begin_idx == -1)
			{
				sql_query = L"select appid, is_read, msg, dt, rowid, is_send from lightapp where appid =? order by rowid desc limit ? , ?;";
			}
			else
			{
				sql_query = L"select appid, is_read, msg, dt, rowid, is_send from lightapp where appid =? order by rowid asc limit ? , ?;";
			}


			data_iterator dt = cur_epdb.execQuery( sql_query, epDbBinder(appid, begin_idx, count));
			json::jobject tmp_result;
			while(dt!=data_iterator())
			{
				json::jobject msgtmp;
				msgtmp["appid"] = dt->getField<std::string>(0);
				msgtmp["is_read"] = dt->getField<int>(1);
				msgtmp["msg"] = json::jobject(dt->getField<std::string>(2));

				time_t ntime = dt->getField<int>(3);
				struct tm *lnow = localtime(&ntime);
				boost::posix_time::ptime t = boost::posix_time::ptime_from_tm(*lnow);
				std::string time = epius::time_format(t);

				msgtmp["ntime"] = (int)ntime;
				msgtmp["dt"] = time;
				msgtmp["rowid"] = dt->getField<std::string>(4);
				msgtmp["is_send"] = dt->getField<int>(5);
				tmp_result.arr_push(msgtmp);
				++dt;
			}

			if (begin_idx == -1)
			{
				int i = tmp_result.arr_size() -1;
				for ( ; i>= 0; i--)
				{
					jobj["msgs"].arr_push(tmp_result[i]);
				}
			}
			else
			{
				jobj["msgs"] = tmp_result;
			}

			std::wstring sql_count = L"select count(*) from lightapp where appid = ?";

			data_iterator dtcount = cur_epdb.execQuery( sql_count, epDbBinder(appid));
			if(dtcount!=data_iterator())
			{
				jobj["count_all"] = dtcount->getField<int>(0);
			}

			callback(false, jobj);
		}
		catch(epius_dberror const& err)
		{
			ELOG("db")->error(WCOOL(L"查询lightapp_message表发生错误") + err.what());
			callback(true, jobj);
		}
	}
	bool LocalConfig::isLightAppMessageExist(std::string appid, std::string msg_id)
	{
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("db")->error("Cannot isLightAppMessageExist because db is NULL");
			return false;
		}
		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);
		try
		{
			data_iterator dt;
			dt = cur_epdb.execQuery( L"select count(*) from lightapp where appid=? and id=?", epDbBinder(appid,msg_id));
			if(dt!=data_iterator())
			{
				int count = dt->getField<int>(0);
				return count==0?false:true;
			}
		}
		catch(std::exception const&)
		{
			//no nothing
		}
		return false;
	}
	void LocalConfig::DeleteLightappMessage( std::string appid, std::string rowid, boost::function<void(bool err, universal_resource)> callback )
	{
		if(!db_connection::instance().get_db(s_userHistoryName))
		{
			ELOG("app")->error("Cannot DeleteLightappMessage because db is NULL");
			callback(true, XL(""));
			return ;
		}

		epDb& cur_epdb = *db_connection::instance().get_db(s_userHistoryName);

		try
		{
			if (rowid.empty())
			{
				cur_epdb.execDML( L"delete from lightapp where appid=? ", epius::epius_sqlite3::epDbBinder(appid));
			}
			else
			{
				cur_epdb.execDML( L"delete from lightapp where appid=? and rowid=? ", epius::epius_sqlite3::epDbBinder(appid, rowid));
			}
			callback(false, XL(""));
			return;
		}
		catch(std::exception const& e)
		{
			ELOG("app")->error(WCOOL(L"删除轻应用消息失败") + e.what());
			callback(true, XL(""));
		}
	}



}; // namespace biz


