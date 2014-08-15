//---------------------------------------------------
// Copyright (C) 2012, All rights reserved
//
// descrption: entrypoint file.
// ver: 2.0
// auther: majiazhi
// date: (YMD)2012/07/04
//---------------------------------------------------
// #pragma warning(push)
//#pragma warning(disable:4996 4503)
#include <boost/uuid/uuid.hpp>
#include <boost/uuid/uuid_generators.hpp>
#include <boost/uuid/uuid_io.hpp>
#include <base/epiusdb/ep_sqlite.h>
#include <base/txtutil/txtutil.h>
#include "boost/filesystem.hpp"
#include "boost/lexical_cast.hpp"
#include "boost/filesystem/operations.hpp"
#include <boost/assign/list_of.hpp>
#include "gloox_src/AsyncConnectionTcpClient.h"
#include "agent.h"
#include "anan_biz_impl.h"
#include "agent_impl.h"
#include "anan_assert.h"
#include "biz_sql.h"
#include "client_anan.h"
#include "an_roster_manager.h"
#include "local_config.h"
#include "login.h"
#include "user.h"
#include "conversation.h"
#include "an_roster_manager_impl.h"
#include "biz_app_settings.h"
#include "organization.h"
#include "notice_msg.h"
#include "biz_recent_contact.h"
#include "msg_extension.h"
#include "anan_biz_bind.h"
#include "anan_type.h"
#include "base/module_path/file_manager.h"
#include "gloox_wrap/glooxWrapInterface.h"
#include "discussions.h"
#include "whistle_vcard.h"
#include "base/module_path/epfilesystem.h"
#include "statistics_data.h"
#include "file_transfer_manager.h"
#include "thread_id.h"
#include "crowd.h"
#include "lightapp.h"
#include "anan_config.h"
namespace biz {

agent::agent()
	: impl_( new agent_impl())
{
}


agent::~agent(void)
{
}


void agent::init_language()
{
	std::string lang = get_parent_impl()->bizLocalConfig_->loadGlobalData("Soft_Language");
	std::string language = "chinese";
	//设置语言
	if (lang == "CN")
	{
		language = "chinese";
	}
	else if (lang == "EN")
	{
		language = "english";
	}
	uni_res::instance().SetLanguage(language);
}

void agent::init()
{
	// 初始化业务对象。
	get_parent_impl()->_p_private_task_.reset(new epius::proactor::tcp_proactor());
	g_statistics_data::instance().wrap_helper_.setPostCmd(get_parent_impl()->_p_private_task_->get_post_cmd());
	thread_id::instance().wrap_helper_.setPostCmd(get_parent_impl()->_p_private_task_->get_post_cmd());	
	get_parent_impl()->bizLogin_->init_to_discontion();	
	get_parent_impl()->bizLocalConfig_->init();	
	
}

void agent::update_domain()
{
	get_parent_impl()->bizClient_->setServer(anan_config::instance().get_server());
	get_parent_impl()->bizClient_->setPort(anan_config::instance().get_port());
	gWrapInterface::instance().set_domain(anan_config::instance().get_domain());
}

void agent::init(std::string domain)
{
	app_settings::instance().set_domain( domain );
	
	if (!impl_->init_)
	{
		//初始化语言包
		init_language();
		createGloox();		
		impl_->init_ = true;
	}

	update_domain();
}

bool MoveFiles(const std::string &src, const std::string &dest)  
{  
	bool bSucc = epfilesystem::instance().copy_files(src,dest,[](std::string dest_str)->bool {
		std::vector<std::string> ignore_list = boost::assign::list_of(epfilesystem::instance().sub_path(file_manager::instance().get_config_dir().get<1>(), s_rootConfigName))
			(epfilesystem::instance().sub_path(file_manager::instance().get_config_dir().get<1>(), app_settings::instance().get_localupdate_folder()))
			(epfilesystem::instance().sub_path(file_manager::instance().get_config_dir().get<1>(), s_userCacheDir))
			(epfilesystem::instance().sub_path(file_manager::instance().get_config_dir().get<1>(), "dump"))
			(epfilesystem::instance().sub_path(file_manager::instance().get_config_dir().get<1>(), s_local_log))
			(epfilesystem::instance().sub_path(file_manager::instance().get_config_dir().get<1>(), "config_from_cloud.json"));
		return std::find(ignore_list.begin(),ignore_list.end(),dest_str)!=ignore_list.end();
	});
	if(bSucc)
	{
		epfilesystem::instance().remove_files(src,[](std::string dest_str)->bool {
			std::vector<std::string> ignore_list = boost::assign::list_of(file_manager::instance().get_config_dir().get<1>())
				(epfilesystem::instance().sub_path(file_manager::instance().get_default_config_dir(), s_rootConfigName))
				(epfilesystem::instance().sub_path(file_manager::instance().get_config_dir().get<1>(), file_manager::instance().get_user_image_dir()))
				(epfilesystem::instance().sub_path(file_manager::instance().get_config_dir().get<1>(), file_manager::instance().get_user_voice_dir()))
				(epfilesystem::instance().sub_path(file_manager::instance().get_config_dir().get<1>(), s_userCacheDir))
				(epfilesystem::instance().sub_path(file_manager::instance().get_config_dir().get<1>(), "dump"))
				(epfilesystem::instance().sub_path(file_manager::instance().get_config_dir().get<1>(), app_settings::instance().get_localupdate_folder()))
				(epfilesystem::instance().sub_path(file_manager::instance().get_config_dir().get<1>(), s_local_log))
				(epfilesystem::instance().sub_path(file_manager::instance().get_config_dir().get<1>(), "config_from_cloud.json"));
			return std::find(ignore_list.begin(),ignore_list.end(),dest_str)!=ignore_list.end();
		});
	}
	return bSucc;
}
void agent::move_data_dir(json::jobject jobj, UIVCallback callback)
{
	IN_TASK_THREAD_WORKx(agent::move_data_dir, jobj, callback);

	//检查参数 比较目标dir
	json::jobject params = jobj["args"];
	boost::tuple<bool, std::string> path = file_manager::instance().get_config_dir();
	std::string target_dir_utf8 = params["path"].get<std::string>();

	if (target_dir_utf8.empty())
	{
		if (params["type"].get<std::string>().compare("default_dir") == 0)
		{
			target_dir_utf8 = epius::txtutil::convert_wcs_to_utf8(file_manager::instance().get_appdata_path());
			params["path"] = target_dir_utf8;
		}
		else
		{
			callback(true,XL("biz.set_storage_dir.badargs"));
			return;
		}
	}

	//准备拷贝
	if((get_parent_impl()->bizLogin_->conn_msm_.getCurrentState()) != CONN_CONNECTED) 
	{//不是connected状态
		assert(false);
		if(!callback.empty())
			callback(true, XL("agent.move_data_dir.nologin"));
		return;
	}
	if (!epfilesystem::instance().file_exists(target_dir_utf8)){
		if(!callback.empty())
			callback(true, XL("agent.move_data_dir.target.noexists"));
		return;
	}
	std::string source_dir_utf8 = path.get<1>();
	std::string target_path = epfilesystem::instance().sub_path(target_dir_utf8, file_manager::instance().get_default_data_dir());

	if (source_dir_utf8 == target_dir_utf8) {
		if(!callback.empty())
			callback(true, XL("agent.move_data_dir.source_same_asm_target"));
		return;
	}
	db_connection::instance().push();
	if(MoveFiles(source_dir_utf8,target_path))
	{
		db_connection::instance().pop(target_path);
		if (params["type"].get<std::string>().compare("default_dir") != 0)
		{
			get_parent_impl()->bizLocalConfig_->saveAnanDir(target_dir_utf8);// set target path 到 common.dat
			file_manager::instance().set_config_dir(false, target_dir_utf8);// set file_manager
		}
		else
		{
			get_parent_impl()->bizLocalConfig_->saveAnanDir("");// 清空common.dat里的path
			file_manager::instance().set_config_dir(true, target_dir_utf8);// set file_manager
		}
		if(!callback.empty())callback(false, XL(""));
	}
	else
	{
		db_connection::instance().pop(source_dir_utf8);
		if(!callback.empty())callback(true, XL("agent.move_data_dir.no_privilege_for_target_path"));
	}
}
void agent::stop_work()
{
	get_parent_impl()->_p_private_task_->stop();
}
void agent::uninit()
{
	if (!impl_->init_)
	{
		return;
	}
	impl_->init_ = false;
	get_parent_impl()->bizClient_->setConnectionImpl(NULL);
	impl_->conn0 = NULL;

	get_parent_impl()->bizRoster_->unregist_to_gloox(get_parent_impl()->bizClient_);
	get_parent_impl()->bizUser_->unregist_to_gloox(get_parent_impl()->bizClient_);
	get_parent_impl()->bizOrg_->unregist_to_gloox(get_parent_impl()->bizClient_);
	
	delete get_parent_impl()->bizClient_;
	get_parent_impl()->bizClient_ = NULL;
}

std::string agent::get_autorun_dir()
{
	std::string the_path;
	return the_path;
}

void agent::removeUser( std::string userName , bool withLocalData)
{
	IN_TASK_THREAD_WORKx(agent::removeUser, userName, withLocalData);

	std::string user_data_path = get_parent_impl()->bizLocalConfig_->removeUser(userName);
	
	std::string user_dir_utf8 = file_manager::instance().get_config_dir().get<1>() + "user/" + user_data_path;
	if (withLocalData && epfilesystem::instance().file_exists(user_dir_utf8))
	{
		epfilesystem::instance().remove_all_file(user_dir_utf8);
	}
}

void agent::createGloox()
{
	get_parent_impl()->bizClient_ = new AnClient( anan_config::instance().get_domain() );
   	get_parent_impl()->bizClient_->set_parent_impl(get_parent_impl());
	get_parent_impl()->bizClient_->changeRosterManager();
	get_parent_impl()->bizClient_->anRosterManager()->set_parent_impl(get_parent_impl());
	get_parent_impl()->bizClient_->registerStanzaExtension(new iq_ext_notice());

	get_parent_impl()->bizClient_->setTls(TLSDisabled);
	g_discussions::instance().set_biz_bind_impl(get_parent_impl());
	g_crowd::instance().set_biz_bind_impl(get_parent_impl());
	g_lightapp::instance().set_biz_bind_impl(get_parent_impl());
	gwhistleVcard::instance().set_biz_bind_impl(get_parent_impl());
	file_transfer::instance().set_biz_bind_impl(get_parent_impl());
	g_discussions::instance().init();
	g_crowd::instance().init();
	g_lightapp::instance().init();
	gWrapInterface::instance().set_client(get_parent_impl()->bizClient_);
	gWrapInterface::instance().set_aligner(epius::thread_align(get_parent_impl()->_p_private_task_->get_thread_tell_cmd(), get_parent_impl()->_p_private_task_->get_post_cmd()));
	get_parent_impl()->bizConversation_ = new conversation(get_parent_impl());
	get_parent_impl()->bizConversation_->regist_to_gloox(get_parent_impl()->bizClient_);
	get_parent_impl()->bizRoster_->regist_to_gloox(get_parent_impl()->bizClient_);
	get_parent_impl()->bizUser_->regist_to_gloox(get_parent_impl()->bizClient_);
	get_parent_impl()->bizLogin_->regist_to_gloox(get_parent_impl()->bizClient_);
	get_parent_impl()->bizRecent_->regist_to_gloox(get_parent_impl()->bizClient_);
	get_parent_impl()->bizOrg_->regist_to_gloox(get_parent_impl()->bizClient_);
	get_parent_impl()->bizNotice_->regist_to_gloox(get_parent_impl()->bizClient_);
}

std::string agent::get_domain() const
{
	return anan_config::instance().get_domain();
}

}; // namespace biz
// #pragma warning(pop)
