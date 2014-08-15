#include "anan_config.h"
#include <base/module_path/file_manager.h>
#include <base/epiusdb/ep_sqlite.h>
#include <base/json/json_algorithm.hpp>
#include <base/utility/bind2f/bind2f.hpp>
#include <base/module_path/epfilesystem.h>
#include <base/module_path/file_manager.h>
using namespace epius;

anan_config_impl::anan_config_impl(void)
{

}


anan_config_impl::~anan_config_impl(void)
{
}

std::string anan_config_impl::get_server()
{
	if(m_config&&m_config["server"])return m_config["server"].get<std::string>();
	return "";
}

std::string anan_config_impl::get_domain()
{
	if(m_config&&m_config["domain"])
		return m_config["domain"].get<std::string>();
	return "jabber.ruijie.com.cn";
}

std::string anan_config_impl::get_version()
{
	std::wstring dir = biz::file_manager::instance().get_module_path() + L"/antversion.json";
	json::jobject version = json::from_file(dir);
	std::string inner_version = " inner-build:9896";
	std::string show_version = version["version"].get<std::string>();
	if(m_config&&m_config["show_inner_version"].get<bool>())
	{
		show_version += inner_version;
	}
	return show_version;
}
int anan_config_impl::get_update_version()
{
	std::wstring dir = biz::file_manager::instance().get_module_path() + L"/antversion.json";
	json::jobject version = json::from_file(dir);
	if (version&&version["ID"])return version["ID"].get<int>();
	return 0;
}
int anan_config_impl::get_port()
{
	if(m_config && m_config["port"])return m_config["port"].get<int>();
	return 5222;
}

std::string anan_config_impl::get_whistle_update_uri()
{
	std::string http_root = "";
	if (m_config&&m_config["http_root"])
	{
		if (m_config["http_root"].get<std::string>() != "")
		{
			http_root = m_config["http_root"].get<std::string>();
		}
	}
	if (m_config&&m_config["whistle_update_uri"])return http_root + m_config["whistle_update_uri"].get<std::string>();
	return "";
}


json::jobject anan_config_impl::get_whistle_background_page()
{
	if(m_config)return m_config["whistle_background"].clone();
	return json::jobject();
}

json::jobject anan_config_impl::get_loginui_page()
{
	if(m_config)return m_config["login_ui"].clone();
	return json::jobject();
}

json::jobject anan_config_impl::get_mainui_page()
{
	if(m_config)return m_config["main_ui"].clone();
	return json::jobject();

}

json::jobject anan_config_impl::get_screen_shot_toolbar()
{
	if(m_config)return m_config["screen_shot_toolbar"].clone();
	return json::jobject();
}

json::jobject anan_config_impl::get_screen_shot_colorbar()
{
	if(m_config)return m_config["screen_shot_colorbar"].clone();
	return json::jobject();
}

json::jobject anan_config_impl::get_log_configuration()
{
	return m_config["log_init"];
}

std::string anan_config_impl::get_http_upload_path()
{
	std::string http_root = "";
	if (m_config&&m_config["http_root"])
	{
		if (m_config["http_root"].get<std::string>() != "")
		{
			http_root = m_config["http_root"].get<std::string>();
		}
	}
	if (m_config&&m_config["http_upload_path"])return http_root + m_config["http_upload_path"].get<std::string>();

	return "";
}

std::string anan_config_impl::get_http_down_path()
{

	std::string http_root = "";
	if (m_config&&m_config["http_root"])
	{
		if (m_config["http_root"].get<std::string>() != "")
		{
			http_root = m_config["http_root"].get<std::string>();
		}
	}
	if (m_config&&m_config["http_download_path"])return http_root + m_config["http_download_path"].get<std::string>();
	return "";
}

std::string anan_config_impl::get_lightapp_resources_down_path()
{

	std::string http_root = "";
	if (m_config&&m_config["http_root"])
	{
		if (m_config["http_root"].get<std::string>() != "")
		{
			http_root = m_config["http_root"].get<std::string>();
		}
	}
	if (m_config&&m_config["light_app_resources"])return http_root + m_config["light_app_resources"].get<std::string>();
	return "";
}

std::string anan_config_impl::get_logon_config()
{
	if(m_config&&m_config["logon_sam"])return m_config["logon_sam"].get<std::string>();
	return "802.1x";
}

void anan_config_impl::set_logon_config(std::string config)
{
	m_config["logon_sam"] = config;
}

void anan_config_impl::init()
{
	using namespace epius::epius_sqlite3;
	std::string dir = biz::file_manager::instance().get_app_root_path();
	std::string config_file_path = biz::file_manager::instance().get_default_config_dir();
	std::string config_dat =  epfilesystem::instance().sub_path(dir, "appconfig.dat");
	std::string local_config_file =  epfilesystem::instance().sub_path(dir, "antconfig.json");
	std::string config_from_cloud =  epfilesystem::instance().sub_path(config_file_path, "config_from_cloud.json");
	boost::shared_ptr<epDb> configDb(new epDb(config_dat));
	try{

		configDb->execDML(L"create table if not exists configuration (settings varchar)");
		data_iterator it = configDb->execQuery(L"select settings from configuration");

		if(it!=data_iterator())
		{
			std::string setting_str = it->getField<std::string>(0);
			json::jobject jobj(setting_str);
			jobj.each(bind2f(&json::apply_new_field<char>,boost::ref(m_config),_1,_2));
		}
		it = data_iterator();
		if (configDb->tableExists(L"version"))
		{			
			data_iterator it = configDb->execQuery(L"select version_id from version");
			if(it!=data_iterator())
			{
				set_db_version(it->getField<std::string>(0));
			}
		}
	}
	catch(...)
	{
		//now log is not ready, because log will also depend on configuration
	}
	json::jobject url_jobj = json::from_file(local_config_file);
	url_jobj.each(bind2f(&json::apply_new_field<char>,boost::ref(m_config),_1,_2));
	if (epfilesystem::instance().file_exists(config_from_cloud))
	{
		json::jobject jobj = json::from_file(config_from_cloud);
		jobj.each(bind2f(&json::apply_new_field<char>,boost::ref(m_config),_1,_2));
	}
}

std::string anan_config_impl::get_feedback_uri()
{
	if (m_config&&m_config["feedback_url"])
		return m_config["feedback_url"].get<std::string>();
	return "";
}

std::string anan_config_impl::get_open_platform_url()
{
	std::string http_root = "";
	if (m_config&&m_config["http_root"])
	{
		if (m_config["http_root"].get<std::string>() != "")
		{
			http_root = m_config["http_root"].get<std::string>();
		}
	}
	if (m_config&&m_config["open_platform_url"])
		return http_root + m_config["open_platform_url"].get<std::string>();
	return "";
}

bool anan_config_impl::is_group_enable()
{
	if (m_config&&m_config["group_enable"])
		return m_config["group_enable"].get<bool>();
	return false;
}

bool anan_config_impl::is_crowd_enable()
{
	if (m_config&&m_config["crowd_enable"])
		return m_config["crowd_enable"].get<bool>();
	return false;
}

json::jobject anan_config_impl::get_auth_types()
{
	if (m_config&&m_config["auth_types"])
		return m_config["auth_types"].clone();
	return json::jobject();
}

std::string anan_config_impl::get_productionname()
{
	std::string dir = epfilesystem::instance().sub_path(WS2UTF(biz::file_manager::instance().get_module_path()), "antversion.json");
	json::jobject version = json::from_file(dir);
	if (version&&version["product_name"])return version["product_name"].get<std::string>();
	return "Whistle 2013";
}

std::string anan_config_impl::get_client_type()
{
	if (m_config&&m_config["client_type"])return m_config["client_type"].get<std::string>();
#ifdef _WIN32
	return "pc";
#elif defined(ANDROID)
	return "android";
#elif defined(__APPLE__)
	return "ios";
#else
	return "unknow";
#endif
}

std::string anan_config_impl::get_file_upload_path()
{
	std::string http_root = "";
	if (m_config&&m_config["http_root"])
	{
		if (m_config["http_root"].get<std::string>() != "")
		{
			http_root = m_config["http_root"].get<std::string>();
		}
	}
	if (m_config&&m_config["http_file_upload_path"])
		return http_root + m_config["http_file_upload_path"].get<std::string>();
	return "";
}

std::string anan_config_impl::get_file_download_path()
{
	std::string http_root = "";
	if (m_config&&m_config["http_root"])
	{
		if (m_config["http_root"].get<std::string>() != "")
		{
			http_root = m_config["http_root"].get<std::string>();
		}
	}
	if (m_config&&m_config["http_file_download_path"])
		return http_root + m_config["http_file_download_path"].get<std::string>();
	return "";
}

std::string anan_config_impl::get_whistle_change_password_uri()
{
	std::string http_root = "";
	if (m_config&&m_config["http_root"])
	{
		if (m_config["http_root"].get<std::string>() != "")
		{
			http_root = m_config["http_root"].get<std::string>();
		}
	}
	if(m_config&&m_config["change_password_uri"])
	{
		return http_root + m_config["change_password_uri"].get<std::string>();
	}
	return "";
}

std::string anan_config_impl::get_whistle_curriculum_uri()
{
	std::string http_root = "";
	if (m_config&&m_config["http_root"])
	{
		if (m_config["http_root"].get<std::string>() != "")
		{
			http_root = m_config["http_root"].get<std::string>();
		}
	}
	if(m_config&&m_config["curriculum_uri"])
	{
		return http_root + m_config["curriculum_uri"].get<std::string>();
	}
	return "";
}

std::string anan_config_impl::get_crowd_vote()
{
	std::string http_root = "";
	if (m_config&&m_config["http_root"])
	{
		if (m_config["http_root"].get<std::string>() != "")
		{
			http_root = m_config["http_root"].get<std::string>();
		}
	}
	if(m_config&&!m_config.is_nil("crowd_vote"))
	{
		return http_root + m_config["crowd_vote"].get<std::string>();
	}
	return "";
}

std::string anan_config_impl::get_growth_info_url()
{
	std::string http_root = "";
	if (m_config&&m_config["http_root"])
	{
		if (m_config["http_root"].get<std::string>() != "")
		{
			http_root = m_config["http_root"].get<std::string>();
		}
	}
	if(m_config&&!m_config.is_nil("growth_info_url"))
	{
		return http_root + m_config["growth_info_url"].get<std::string>();
	}
	return "";
}

void anan_config_impl::set_db_version( std::string db_version )
{
	db_version_ = db_version; 
}

std::string anan_config_impl::get_db_version()
{
	return db_version_;
}

int anan_config_impl::get_round_radius()
{
	if(m_config&&m_config["wnd_round_radius"])
	{
		return m_config["wnd_round_radius"].get<int>();
	}
	return 5;
}

int anan_config_impl::get_network_connect_timeout()
{
	if(m_config&&m_config["network_connect_timeout"])
	{
		return m_config["network_connect_timeout"].get<int>();
	}
	return 3;
}

void anan_config_impl::config_from_user_data( std::string password )
{
	using namespace epius::epius_sqlite3;
	std::string whistle_dir = biz::file_manager::instance().get_default_config_dir();
	if (!epfilesystem::instance().file_exists(whistle_dir))
	{
		epfilesystem::instance().create_directories(whistle_dir);
	}
	else
	{	
		std::string common_dat_dir = epfilesystem::instance().sub_path(whistle_dir, "common.dat");
		boost::shared_ptr<epDb> commonDb(new epDb(common_dat_dir,password));
		try
		{
			commonDb->execDML(L"create table if not exists special (id varchar(252) primary key,data blob)"); 
			data_iterator it = commonDb->execQuery(L"select id,data from special where id = \"user_identity\" ");

			if(it!=data_iterator())
			{
				std::string user_identity = it->getField<std::string>(1);
				if (user_identity == "free" || user_identity == "direct")
				{
					m_config["logon_sam"] = "direct";
				}
				else
				{
					m_config["logon_sam"] = user_identity;
				}
			}
		}
		catch(...)
		{
			//now log is not ready, because log will also depend on configuration
		}
	}
}

std::string anan_config_impl::get_html_path()
{
	if(m_config && !m_config.is_nil("login_ui"))
	{
		std::string relative_path =  m_config["login_ui"]["wnd_url"].get<std::string>();
		std::string::size_type find_pos = relative_path.find("html/");
		if(find_pos!=std::string::npos)
		{
			return relative_path.substr(0, find_pos+4);
		}
	}
	return "";

}

std::string anan_config_impl::get_app_path( std::string platform )
{
	std::string app_path;
	if(platform == "pc")
	{
		std::string html_path = get_html_path();
		app_path = epfilesystem::instance().sub_path(WS2UTF(biz::file_manager::instance().get_module_path()), html_path);
		app_path = epfilesystem::instance().sub_path(app_path, "app/app_" + platform + ".json");
	}
	else
	{
		app_path = biz::file_manager::instance().get_app_root_path();
		app_path = epfilesystem::instance().sub_path(app_path, "app_" + platform + ".json");
	}
	return app_path;
}

json::jobject anan_config_impl::get_app_name_cfg()
{
	if(m_config&&!m_config.is_nil("app_name_cfg"))
	{
		json::jobject jobj = m_config["app_name_cfg"].clone();
		if(jobj && !jobj.is_nil("academy_app"))
		{
			std::string root = m_config&&m_config["http_root"] ? m_config["http_root"].get<std::string>() : "";
			jobj["academy_app"]["url"] = root + jobj["academy_app"]["url"].get<std::string>();
		}
		return jobj;
	}
	return json::jobject();
}

std::string anan_config_impl::get_network_test_url_external()
{
	if(m_config&&!m_config.is_nil("eportal_cfg"))
	{
		return m_config["eportal_cfg"]["network_test_url_external"].get<std::string>();
	}
	return "";
}

std::string anan_config_impl::get_eportal_explorer_url()
{
	if(m_config&&!m_config.is_nil("eportal_explorer_url"))
	{
		return m_config["eportal_explorer_url"].get<std::string>();
	}
	return "";
}

std::string anan_config_impl::get_auth_eportal_label()
{
	if(m_config&&!m_config.is_nil("eportal_cfg"))
	{
		return m_config["eportal_cfg"]["auth_eportal_label"].get<std::string>();
	}
	return "";
}

std::string anan_config_impl::get_auth_sam_label()
{
	if(m_config&&!m_config.is_nil("eportal_cfg"))
	{
		return m_config["eportal_cfg"]["auth_sam_label"].get<std::string>();
	}
	return "";
}


void anan_config_impl::get_hot_key_from_user_data( std::string password,json::jobject& key_jobj )
{
	using namespace epius::epius_sqlite3;
	std::string whistle_dir = biz::file_manager::instance().get_default_config_dir();
	if (!epfilesystem::instance().file_exists(whistle_dir))
	{
		epfilesystem::instance().create_directories(whistle_dir);
	}
	else
	{	
		std::string common_dat_dir = epfilesystem::instance().sub_path(whistle_dir, "common.dat");
		boost::shared_ptr<epDb> commonDb(new epDb(common_dat_dir,password));
		try
		{
			commonDb->execDML(L"create table if not exists special (id varchar(252) primary key,data blob)"); 
			data_iterator it_hot_key = commonDb->execQuery(L"select id,data from special where id = \"set_hot_key\" ");
			if(it_hot_key != data_iterator())
			{
				std::string key_str = it_hot_key->getField<std::string>(1);
				key_jobj = json::jobject(key_str);
			}
		}
		catch(...)
		{
			//now log is not ready, because log will also depend on configuration
		}
	}
}

std::string anan_config_impl::get_crowd_policy()
{
	std::string http_root = "";
	if (m_config&&m_config["http_root"])
	{
		if (m_config["http_root"].get<std::string>() != "")
		{
			http_root = m_config["http_root"].get<std::string>();
		}
	}
	if(m_config&&!m_config.is_nil("crowd_policy"))
	{
		return http_root + m_config["crowd_policy"].get<std::string>();
	}
	return "";
}

std::string anan_config_impl::get_whistle_androidupdate_check()
{
	std::string http_root = "";
	if (m_config&&m_config["http_root"])
	{
		if (m_config["http_root"].get<std::string>() != "")
		{
			http_root = m_config["http_root"].get<std::string>();
		}
	}
	if(m_config&&!m_config.is_nil("whistle_androidupdate_check"))
	{
		return http_root + m_config["whistle_androidupdate_check"].get<std::string>();
	}
	return "";
}

std::string anan_config_impl::get_whistle_mobile_crash()
{
	if(m_config&&!m_config.is_nil("whistle_mobile_crash"))
	{
		return m_config["whistle_mobile_crash"].get<std::string>();
	}
	return "";
}

std::string anan_config_impl::get_whistle_androidupdate_uri()
{
	std::string http_root = "";
	if (m_config&&m_config["http_root"])
	{
		if (m_config["http_root"].get<std::string>() != "")
		{
			http_root = m_config["http_root"].get<std::string>();
		}
	}
	if(m_config&&!m_config.is_nil("whistle_androidupdate_uri"))
	{
		return http_root + m_config["whistle_androidupdate_uri"].get<std::string>();
	}
	return "";
}

std::string anan_config_impl::get_qr_code( std::string target_name )
{
	std::string http_root = "";
	if (m_config&&m_config["http_root"])
	{
		if (m_config["http_root"].get<std::string>() != "")
		{
			http_root = m_config["http_root"].get<std::string>();
		}
	}
	if(m_config&&!m_config.is_nil("qr_code")&&!m_config["qr_code"].is_nil(target_name))
	{
		return http_root + m_config["qr_code"][target_name].get<std::string>();
	}
	return "";
}

int anan_config_impl::get_update_interval_mins()
{
	if(!m_config.is_nil("update_interval_mins"))return m_config["update_interval_mins"].get<int>();
	return 0;
}

std::string anan_config_impl::get_native_app( std::string app_id )
{
	if(m_config.is_nil("native_app") || m_config["native_app"].is_nil(app_id))return "";
	return m_config["native_app"][app_id].get();
}

std::string anan_config_impl::get_http_root()
{
	if (m_config&&m_config["http_root"])
	{		
		return m_config["http_root"].get<std::string>();		
	}
	else
	{
		return "";
	}
}

void anan_config_impl::set_config_server( std::string server )
{
	m_config["server"] = server;
}

void anan_config_impl::set_config_domain( std::string domain )
{
	m_config["domain"] = domain;
}

void anan_config_impl::set_config_port( int port )
{
	m_config["port"] = port;
}

void anan_config_impl::set_config_http_root( std::string http_root )
{
	m_config["http_root"] = http_root;
}

void anan_config_impl::set_config_eportal_url( std::string eportal_explorer_url )
{
	m_config["eportal_explorer_url"] = eportal_explorer_url;
}

json::jobject anan_config_impl::get_mconfig()
{
	return m_config;
}

std::string anan_config_impl::get_cloud_config_url()
{
	if (m_config&&m_config["cloud_config_url"])
	{		
		return m_config["cloud_config_url"].get<std::string>();		
	}
	else
	{
		return "";
	}
}

