#pragma once
#include <base/config/configure.hpp>
#include <base/json/tinyjson.hpp>
#include <base/utility/singleton/singleton.hpp>
#include <base/universal_res/uni_res.h>
#include <boost/shared_ptr.hpp>
#include <map>

// 管理安装和工作路径 

namespace biz{
	class biz_file_manager_impl;
	class biz_file_manager_interface
	{
		template<class> friend struct boost::utility::singleton_holder;
	public:
		void init();						

		std::string get_app_root_path();
		std::wstring get_module_path();		// get exe path
		std::wstring get_appdata_path();		// get appdata path
		std::wstring get_userdata_path();	// get login user path
		std::wstring get_module_file();		// get exe file name

		std::string  get_default_config_dir();
		std::string  get_default_cache_dir();
		std::string  get_tmp_file_path();
		boost::tuple<bool, std::string> get_config_dir();
		std::string get_bare_config_dir();
		void set_config_dir(bool isDefault, std::string dir);
		void set_default_data_dir(std::string dir);
		std::string get_default_data_dir();

		std::wstring get_filepath_by_key(const std::string key); // not use
		void set_filepath(std::string key, std::wstring path);
		std::string from_uri_to_path( std::string uri_string );
		std::string from_uri_to_voice_path( std::string uri_string );
		std::string from_uri_to_lightapp_path( std::string uri_string );
		std::string format_recvFile_path( std::string path );
		//valid path will exist and is not empty
		std::string from_uri_to_valid_path( std::string uri_string );
		std::string from_voice_uri_to_valid_path( std::string uri_string );
		std::string get_extern_name( std::string uri_string );
		bool file_is_valid(std::string wpath_string);
		bool file_is_valid_not_remove(std::string wpath_string);
		std::string format_file_path(std::string file_path_utf8);

		std::string get_user_image_dir();
		std::string get_user_voice_dir();
	private:
#ifdef _WIN32
		bool file_is_valid(std::wstring wpath_string);
#endif
		bool file_is_valid_not_remove(std::wstring wpath_string);
		biz_file_manager_interface();
		~biz_file_manager_interface();
		boost::shared_ptr<biz_file_manager_impl> impl_;

	};

	typedef boost::utility::singleton_holder<biz_file_manager_interface> file_manager;
}