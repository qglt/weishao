#include "boost/filesystem/operations.hpp"
#include "base/txtutil/txtutil.h"
#include "sqlite_connections.h"
#include "anan_type.h"
#include <base/module_path/file_manager.h>
#include <boost/assign.hpp>
#include <vector>
#include "biz_app_data.h"
#include "local_config.h"
#include "biz_sql.h"
#include "biz_app_settings.h"
#include "base/module_path/epfilesystem.h"
#include "base/epiusdb/ep_sqlite.h"
#include "anan_config.h"

namespace biz {
using namespace epius::epius_sqlite3;
using namespace epius;
using namespace boost::assign;
// static std::map<std::wstring, std::vector< boost::tuple<std::wstring, std::wstring> > > db_table_name2createSql = 

void db_connection_impl::push(void)
{
	for (dbconnectmap::iterator it = mapdbs.begin(); it != mapdbs.end(); ++it) {
		dbinfos& di = it->second;
		di.db_connection_.reset();
	}
}

void db_connection_impl::pop(std::string config_path)
{
	//restore db connection
	for (dbconnectmap::iterator it = mapdbs.begin(); it != mapdbs.end(); ++it) {
		dbinfos &di = it->second;
		{
			di.rebuild_connection(config_path);
		}
	}
}

epius::epius_sqlite3::epDbAutoCreate* db_connection_impl::get_db( std::string key )
{
	dbconnectmap::iterator it = mapdbs.find(key);
	if (it != mapdbs.end())
	{
		return it->second.db_connection_.get();
	}
	else
	{
		return NULL;
	}
}

void db_connection_impl::add( std::string key, std::string base_dir, std::string db_dir)
{
	if(mapdbs.find(key)!=mapdbs.end())return;
	dbinfos dbi(base_dir,db_dir);
	mapdbs[key] = dbi;
}

void db_connection_impl::remove( std::string key )
{
	mapdbs.erase(key);
}

db_connection_impl::db_connection_impl()
{
}

db_connection_impl::dbinfos::dbinfos()
{
}

db_connection_impl::dbinfos::dbinfos( const dbinfos& that )
{
	db_connection_ = that.db_connection_;
	db_relative_dir_ = that.db_relative_dir_;
	db_base_dir_ = that.db_base_dir_;
}

db_connection_impl::dbinfos::dbinfos( std::string base_dir, std::string db_dir )
{
	db_base_dir_ = base_dir;
	db_relative_dir_ = db_dir;
	rebuild_connection(base_dir);
}
static std::map<std::string, std::map<std::wstring, std::vector<std::wstring> > >& get_table_name2createSql()
{
#ifdef _WIN32
	static std::wstring sql_create_course_info =   // create
		L"create table if not exists course_info " \
		L"(" \
		L"   total    integer," \
		L"   timestamp varchar(252)" \
		L");";
	static std::wstring sql_create_course =   // create
		L"create table if not exists course " \
		L"(" \
		L"   course_id    integer," \
		L"   course_code  varchar(252)," \
		L"   name  varchar(252)," \
		L"   category_num  integer," \
		L"   category  varchar(252)" \
		L");";
	static std::wstring sql_create_course_detail =   // create
		L"create table if not exists course_detail " \
		L"(" \
		L"   course_id    integer," \
		L"   course_detail_id  integer," \
		L"   start_weeks  integer," \
		L"   end_weeks  integer," \
		L"   day  integer," \
		L"   start_lesson integer," \
		L"   end_lesson integer," \
		L"   single_double_week varchar(252)," \
		L"   class_room varchar(252)" \
		L");";
	static std::wstring sql_create_course_teacher =   // create
		L"create table if not exists course_teacher " \
		L"(" \
		L"   course_detail_id  integer," \
		L"   teacher_uid   varchar(252)," \
		L"   teacher_name  varchar(252)" \
		L");";
#endif

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

	static std::wstring sql_lightapp_index1 = L"create index if not exists lightapp_index1 on lightapp(appid);";

	static std::wstring sql_recent_index1 = L"create index if not exists recentcontact_index1 on recentcontact(jid);";
	static std::wstring sql_recent_index2 = L"create index if not exists recentcontact_index2 on recentcontact(type);";
	static std::wstring sql_recent_index3 = L"create index if not exists recentcontact_index3 on recentcontact(time);";

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
	
	static std::wstring s_sqlCreateUserDataDir =   // create
		L"create table if not exists userDataDir " \
		L"(" \
		L"   path       varchar(1020) primary key" \
		L");";

	static std::wstring s_sqlCreateRoster =   // create
		L"create table if not exists roster " \
		L"(" \
		L"   jid  varchar(252) primary key," \
		L"   info text," \
		L"   time char(19)" \
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
	static std::wstring s_sqlCreateSpecial =   // create
		L"create table if not exists special " \
		L"(" \
		L"   id  varchar(252) primary key," \
		L"   data blob" \
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

	static std::map<std::string, std::map<std::wstring, std::vector<std::wstring> > > db_table_name2createSql;
	if(db_table_name2createSql.empty())
	{
		//common.dat
		std::map<std::wstring, std::vector<std::wstring> > rootConfigInit;
		rootConfigInit[L"accounts"].push_back(s_sqlCreateAccounts);
		rootConfigInit[L"special"].push_back(s_sqlCreateSpecial);
		rootConfigInit[L"userDataDir"].push_back(s_sqlCreateUserDataDir);
		db_table_name2createSql[s_rootConfigName] = rootConfigInit;
	    //user.dat
		std::map<std::wstring, std::vector<std::wstring> > userConfig;
		userConfig[L"roster"].push_back(s_sqlCreateRoster);
		userConfig[L"special"].push_back(s_sqlCreateSpecial);		
		db_table_name2createSql[s_userConfigName] = userConfig;
	    //history.dat
		std::map<std::wstring, std::vector<std::wstring> > userHistory;
		userHistory[L"recentcontact"].push_back(s_sqlCreateRecentContact);
		userHistory[L"recentcontact"].push_back(sql_recent_index1);
		userHistory[L"recentcontact"].push_back(sql_recent_index2);
		userHistory[L"recentcontact"].push_back(sql_recent_index3);

		userHistory[L"conversation"].push_back(sql_create_conversation);
		userHistory[L"conversation"].push_back(sql_conv_index1);
		userHistory[L"conversation"].push_back(sql_conv_index2);
		userHistory[L"conversation"].push_back(sql_conv_index3);
		userHistory[L"conversation"].push_back(sql_conv_index4);
		userHistory[L"conversation"].push_back(sql_conv_index5);
		userHistory[L"conversation"].push_back(sql_conv_index6);

		userHistory[L"crowdmsg"].push_back(sql_create_crowd);
		userHistory[L"crowdmsg"].push_back(sql_crowd_index1);
		userHistory[L"crowdmsg"].push_back(sql_crowd_index2);
		userHistory[L"crowdmsg"].push_back(sql_crowd_index3);
		userHistory[L"crowdmsg"].push_back(sql_crowd_index4);
		userHistory[L"crowdmsg"].push_back(sql_crowd_index5);
		userHistory[L"crowdmsg"].push_back(sql_crowd_index6);
		userHistory[L"crowdmsg"].push_back(sql_crowd_index7);
		userHistory[L"crowdmsg"].push_back(sql_crowd_index8);

		userHistory[L"groupmsg"].push_back(s_sqlCreateGroupMessage);
		userHistory[L"groupmsg"].push_back(sql_group_index1);
		userHistory[L"groupmsg"].push_back(sql_group_index2);
		userHistory[L"groupmsg"].push_back(sql_group_index3);
		userHistory[L"groupmsg"].push_back(sql_group_index4);
		userHistory[L"groupmsg"].push_back(sql_group_index5);
		userHistory[L"groupmsg"].push_back(sql_group_index6);
		userHistory[L"groupmsg"].push_back(sql_group_index7);
		userHistory[L"groupmsg"].push_back(sql_group_index8);

		userHistory[L"notice"].push_back(s_sqlCreateNoticeMessage);

		userHistory[L"publish"].push_back(s_sqlCreatePublish);
		userHistory[L"systemmessage"].push_back(s_sqlCreateRequestFriends);

		userHistory[L"organization"].push_back(s_sqlCreateOrg);
		userHistory[L"app_message"].push_back(s_sqlCreateAppMessage);

		userHistory[L"lightapp"].push_back(sql_create_lightapp);
		userHistory[L"lightapp"].push_back(sql_lightapp_index1);

		db_table_name2createSql[s_userHistoryName] = userHistory;
#ifdef _WIN32
		std::map<std::wstring, std::vector<std::wstring> > userCourse;
		userCourse[L"course_info"].push_back(sql_create_course_info);
		userCourse[L"course"].push_back(sql_create_course);
		userCourse[L"course_detail"].push_back(sql_create_course_detail);
		userCourse[L"course_teacher"].push_back(sql_create_course_teacher);
		
		db_table_name2createSql[s_userCourseName] = userCourse;
#endif
	}
		
	return db_table_name2createSql;
}

void db_connection_impl::dbinfos::rebuild_connection(std::string new_base_path)
{
	std::string base_path = file_manager::instance().get_default_config_dir();
	if(!db_base_dir_.empty())
	{
		db_base_dir_ = new_base_path;
		base_path = new_base_path;
	}

	std::string db_exact_path_utf8 = base_path + db_relative_dir_;
		
	if(!epius::epfilesystem::instance().file_exists(db_exact_path_utf8))
	{
		std::string parent_path = epius::epfilesystem::instance().branch_path(db_exact_path_utf8);
		epfilesystem::instance().create_directories(parent_path);
	}
	db_connection_.reset(new epius::epius_sqlite3::epDbAutoCreate(db_exact_path_utf8,app_settings::instance().get_db_key()));
	std::string work_db_version = anan_config::instance().get_db_version();
	if(!work_db_version.empty())
	{
		if (!db_connection_->tableExists(L"version"))
		{
			db_connection_->execDML(L"version",L"create table version(version_id varchar);");
			db_connection_->execDML(L"version", L"insert into version (version_id) values (?)",epDbBinder(work_db_version));
		}
	}
	std::string tmp_relative_dir = db_relative_dir_;
	if(tmp_relative_dir.find_first_of('/')!=std::string::npos)
	{
		tmp_relative_dir = tmp_relative_dir.substr(0,tmp_relative_dir.find_first_of('/')) + "/%s" + tmp_relative_dir.substr(tmp_relative_dir.find_last_of('/'));
	}
	if(get_table_name2createSql().find(tmp_relative_dir)!=get_table_name2createSql().end())
	{
		db_connection_->setTableInit(get_table_name2createSql()[tmp_relative_dir]);
	}
}

}; // namespace biz
