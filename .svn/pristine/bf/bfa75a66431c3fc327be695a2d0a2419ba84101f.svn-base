#pragma once
#include <map>
#include <boost/tuple/tuple.hpp>
#include <base/json/jsonfile.hpp>
#include <base/utility/singleton/singleton.hpp>

class anan_config_impl
{
    template<class> friend struct boost::utility::singleton_holder;
public:
	void init();
    std::string get_server();
    std::string get_domain();
	std::string get_version();
	std::string get_productionname();
	std::string get_whistle_update_uri();
	std::string get_whistle_change_password_uri();
    int get_port();
	std::string get_logon_config();
	void set_logon_config(std::string config);
	void set_db_version(std::string);
	std::string get_db_version();
	std::string get_http_upload_path();
	std::string get_http_down_path();
	std::string get_lightapp_resources_down_path();
	std::string get_html_path();
	std::string get_app_path(std::string platform);
	json::jobject get_app_name_cfg();
    json::jobject get_loginui_page();
	json::jobject get_whistle_background_page();
    json::jobject get_mainui_page();
	json::jobject get_screen_shot_toolbar();
	json::jobject get_screen_shot_colorbar();
    json::jobject get_log_configuration();
	int get_update_interval_mins();
	std::string get_native_app(std::string app_id);
	std::string get_qr_code(std::string target_name);
	std::string get_feedback_uri();
	std::string get_open_platform_url();
	bool is_group_enable();
	bool is_crowd_enable();
	json::jobject get_auth_types();
	int get_update_version();
	std::string get_client_type();
	std::string get_file_upload_path();
	std::string get_file_download_path();
	std::string get_whistle_androidupdate_check();
	std::string get_whistle_mobile_crash();
	std::string get_whistle_androidupdate_uri();
	int get_round_radius();
	std::string get_whistle_curriculum_uri();
	int get_network_connect_timeout();
	void config_from_user_data(std::string password);
	void get_hot_key_from_user_data(std::string password,json::jobject& key_jobj);
	std::string get_network_test_url_external();
	std::string get_eportal_explorer_url();
	std::string get_auth_eportal_label();
	std::string get_auth_sam_label();
	std::string get_crowd_policy();
	std::string get_crowd_vote();
	std::string get_growth_info_url();
	std::string get_http_root();
	std::string get_cloud_config_url();
	void set_config_server(std::string server);
	void set_config_domain(std::string domain);
	void set_config_port(int port);
	void set_config_http_root(std::string http_root);
	void set_config_eportal_url(std::string eportal_explorer_url);
	json::jobject get_mconfig();
private:
    anan_config_impl(void);
    ~anan_config_impl(void);
	json::jobject m_config;
	std::string db_version_;
};

typedef boost::utility::singleton_holder<anan_config_impl> anan_config;
