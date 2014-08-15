#include <base/module_path/file_manager.h>
#include <base/txtutil/txtutil.h>
#include <boost/filesystem.hpp>
#include <boost/lambda/lambda.hpp>
#include <base/epiusdb/ep_sqlite.h>
#include <base/module_path/epfilesystem.h>
#include <base/utility/uuid/uuid.hpp>

#ifdef _WIN32
#include <Windows.h>
#include <shlobj.h>
#pragma comment(lib, "shell32.lib")
#endif 

#ifdef __APPLE__
#include "TargetConditionals.h"

namespace biz
{
	extern std::string whistle_device_approot;

}	
#endif


namespace biz
{
	class biz_file_manager_impl
	{
		public:
			biz_file_manager_impl()
			{
			}

			bool init()
			{
#ifdef _WIN32
				// 1 改变工作目录到 module path
				wchar_t szPath[MAX_PATH] = {0};
				if(!GetModuleFileName( NULL, szPath, MAX_PATH ) )
				{
					return false;
				}
				module_file_ = szPath;
				std::wstring::size_type split_pos = module_file_.find_last_of(L'\\');
				if(split_pos != std::wstring::npos)
				{
					work_dir_str_ = module_file_.substr(0, split_pos);
					BOOL ret = SetCurrentDirectory(work_dir_str_.c_str());
					if (!ret)
					{
						return false;
					}
				}
				// 3 设置default目录
#endif
				default_data_dir_ = "Whistle/";
				userImagesDir_ = "vcard-images";
				userVoiceMsgDir_ = "voice-messages";
				userRecvFileDir_ = "recvFile/";
				userLightAppDir_ = "lightapp-resources";
				return true;
			}
			
			std::wstring get_module_path()
			{
				return  work_dir_str_;
			}
			std::wstring get_appdata_path()
			{
#ifdef _WIN32
				if (!appdata_path_.empty())
				{
					return appdata_path_;
				}

				TCHAR szPath[MAX_PATH];
				SHGetSpecialFolderPath(NULL,szPath,CSIDL_APPDATA,FALSE);

				appdata_path_ = szPath;
				return  appdata_path_;
#else
				return L"";
#endif
			}
			std::wstring get_userdata_path()
			{
				// is login ?
				// get user data path userdata_path_
				return  L"a";
			}
			
			std::wstring get_filepath_by_key(const std::string key)
			{
				std::map<std::string,std::wstring>::iterator it = keymap_.find(key);
				if (it != keymap_.end())
				{
					return it->second;
				}
				return  L"";
			}
			std::wstring work_dir_str_;
			std::map<std::string,std::wstring> keymap_;
			std::wstring userdata_path_;
			std::wstring appdata_path_;
			std::wstring module_file_;
			std::string default_data_dir_;
			std::string config_dir_;
			bool		is_default_config_dir_;
			std::string user_name_;
			std::string userImagesDir_;
			std::string userVoiceMsgDir_;
			std::string userRecvFileDir_;
			std::string userLightAppDir_;
	};


	biz_file_manager_interface::biz_file_manager_interface()
	{
	}

	biz_file_manager_interface::~biz_file_manager_interface()
	{

	}
	void biz_file_manager_interface::init()
	{
		impl_.reset(new biz_file_manager_impl);
		impl_->init();
		std::string cache_path = get_default_cache_dir();
		epius::epfilesystem::instance().remove_files(cache_path, boost::lambda::_1 == cache_path);
	}

	// exe 的运行目录
	// 例子D:\ANAN\trunk\client\bin\debug
	std::wstring biz_file_manager_interface::get_module_path()
	{
		return impl_->get_module_path();
	}

	std::string biz_file_manager_interface::get_app_root_path()
	{
#ifdef _WIN32
		return WS2UTF(get_module_path());
#else
#ifndef TARGET_OS_IPHONE
		return get_default_config_dir();
#else
		return whistle_device_approot;
#endif
#endif
	}
	//用户数据目录
	//例子：C:\Users\quanli\AppData\Roaming
	std::wstring biz_file_manager_interface::get_appdata_path()
	{
		return impl_->get_appdata_path();
	}

	//当前login的用户目录
	//暂时还没有实现
	std::wstring biz_file_manager_interface::get_userdata_path()
	{
		return impl_->get_userdata_path();
	}

	//取回接口设置的目录 配合
	//暂时还没有使用这个接口set_filepath使用
	std::wstring biz_file_manager_interface::get_filepath_by_key(const std::string key)
	{
		return impl_->get_filepath_by_key(key);
	}

	// exe 的运行目录
	// 例子D:\ANAN\trunk\client\bin\debug\Whistle.exe
	std::wstring biz_file_manager_interface::get_module_file()
	{
		return impl_->module_file_;
	}

	//程序第一次运行创建 common.dat文件的路径
	//例子 C:\Users\quanli\AppData\Roaming\Whistle
	std::string biz_file_manager_interface::get_default_config_dir()
	{
#ifdef _WIN32
		return epius::epfilesystem::instance().sub_path(WS2UTF(get_appdata_path()),impl_->default_data_dir_);
#else
#ifndef TARGET_OS_IPHONE
		return std::string("/sdcard/"+impl_->default_data_dir_);
#else
		return whistle_device_approot;
#endif
#endif
	}

	void biz_file_manager_interface::set_default_data_dir( std::string dir )
	{
		impl_->default_data_dir_ = dir;
	}

	//在用户自定义或默认用户数据目录后加子目录default_data_dir_("Whistle")
	boost::tuple<bool, std::string> biz_file_manager_interface::get_config_dir()
	{
	
#ifdef _WIN32
			return boost::make_tuple(impl_->is_default_config_dir_, epius::epfilesystem::instance().sub_path(impl_->config_dir_, impl_->default_data_dir_));
#else
		return boost::make_tuple(impl_->is_default_config_dir_, get_default_config_dir());
#endif
	
	}
	//默认的用户数据聊天记录等的文件写入目录
	//isDefault true/false
	//true  程序默认的用户数据目录 默认get_appdata_path目录
	//false 用户自定义用户数据目录 
	//在biz层此路径，会保存到common.dat的userDataDir表
	void biz_file_manager_interface::set_config_dir(bool isDefault,  std::string dir )
	{
		impl_->is_default_config_dir_ = isDefault;
		impl_->config_dir_ = dir;
	}

	// anan子目录
	std::string biz_file_manager_interface::get_default_data_dir()
	{
		return impl_->default_data_dir_;
	}
	//通过key设定和获取文件路径
	void biz_file_manager_interface::set_filepath( std::string key, std::wstring path )
	{
		impl_->keymap_[key] = path;
	}

	std::string biz_file_manager_interface::get_bare_config_dir()
	{
		return impl_->config_dir_;
	}

	std::string biz_file_manager_interface::from_uri_to_path( std::string uri_string )
	{
		std::string filename = epius::epfilesystem::instance().file_name(uri_string);
		std::string parent_path = epius::epfilesystem::instance().sub_path(get_config_dir().get<1>(), impl_->userImagesDir_);
		std::string local_path = epius::epfilesystem::instance().sub_path(parent_path, filename);
		return local_path;
	}

	std::string biz_file_manager_interface::from_uri_to_voice_path( std::string uri_string )
	{
		std::string filename = epius::epfilesystem::instance().file_name(uri_string);
		std::string parent_path = epius::epfilesystem::instance().sub_path(get_config_dir().get<1>(), impl_->userVoiceMsgDir_);
		std::string local_path = epius::epfilesystem::instance().sub_path(parent_path, filename);
		return local_path;
	}

	std::string biz_file_manager_interface::from_uri_to_lightapp_path( std::string uri_string )
	{
		std::string filename = epius::epfilesystem::instance().file_name(uri_string);
		std::string parent_path = epius::epfilesystem::instance().sub_path(get_config_dir().get<1>(), impl_->userLightAppDir_);
		std::string local_path = epius::epfilesystem::instance().sub_path(parent_path, filename);
		return local_path;
	}
	
	std::string biz_file_manager_interface::get_extern_name( std::string uri_string )
	{
		std::string extName;
		std::string::size_type pos = uri_string.rfind('.');
		if (pos != std::string::npos)
			extName = uri_string.substr(pos);
		return extName;
	}
#ifdef _WIN32
	bool biz_file_manager_interface::file_is_valid(std::wstring wpath_string)
	{
		try {
			if (boost::filesystem::exists(wpath_string)) {
				if (boost::filesystem::is_directory(wpath_string))
					return false;
				if(!boost::filesystem::file_size(wpath_string)) {
					boost::filesystem::remove(wpath_string);
					return false;
				}
				return true;
			} else {
				return false;
			}
		}catch(...) { return false;}
	}
#endif
    
	bool biz_file_manager_interface::file_is_valid(std::string path_string)
	{
#ifdef _WIN32
		return file_is_valid(txtconv::convert_utf8_to_wcs(path_string));
#else
		try {
			if (boost::filesystem::exists(path_string)) {
				if (boost::filesystem::is_directory(path_string))
					return false;
				if(!boost::filesystem::file_size(path_string)) {
					boost::filesystem::remove(path_string);
					return false;
				}
				return true;
			} else {
				return false;
			}
		}catch(...) { return false;}
#endif
	}

	bool biz_file_manager_interface::file_is_valid_not_remove(std::wstring wpath_string)
	{
		try {
			if (boost::filesystem::exists(wpath_string)) {
				if (boost::filesystem::is_directory(wpath_string))
					return false;
				if(!boost::filesystem::file_size(wpath_string)) {					
					return false;
				}
				return true;
			} else {
				return false;
			}
		}catch(...) { return false;}
	}

	bool biz_file_manager_interface::file_is_valid_not_remove(std::string path_string)
	{
#ifdef _WIN32
		return file_is_valid_not_remove(txtconv::convert_utf8_to_wcs(path_string));
#else
		try {
			if (boost::filesystem::exists(path_string)) {
				if (boost::filesystem::is_directory(path_string))
					return false;
				if(!boost::filesystem::file_size(path_string)) {
					return false;
				}
				return true;
			} else {
				return false;
			}
		}catch(...) { return false;}
#endif
	}

	std::string biz_file_manager_interface::from_uri_to_valid_path( std::string uri_string )
	{
		if (uri_string.empty())
			return "";

		std::string the_path_from_uri = file_manager::instance().from_uri_to_path(uri_string);
		if(file_is_valid(the_path_from_uri))
		{
			return the_path_from_uri;
		}
		return "";
	}

	std::string biz_file_manager_interface::from_voice_uri_to_valid_path( std::string uri_string )
	{
		if (uri_string.empty())
			return "";

		std::string the_path_from_uri = file_manager::instance().from_uri_to_voice_path(uri_string);
		if(file_is_valid(the_path_from_uri))
		{
			return the_path_from_uri;
		}
		return "";
	}


	std::string biz_file_manager_interface::format_file_path( std::string file_path_utf8 )
	{
#ifdef _WIN32
		boost::filesystem::wpath path_tmp(UTF2WS(file_path_utf8));
		return WS2UTF(path_tmp.generic_wstring());
#else
		boost::filesystem::path path_tmp(file_path_utf8);
		return path_tmp.generic_string();
#endif

	}

	std::string biz_file_manager_interface::format_recvFile_path( std::string path )
	{
#ifdef _WIN32
		boost::filesystem::wpath filepath(UTF2WS(path));
		if (!filepath.branch_path().generic_wstring().empty())
		{
			return path;
		}
#else
        boost::filesystem::path filepath(path);
		if (!filepath.branch_path().generic_string().empty())
		{
			return path;
		}
        
#endif
		std::string local_path = get_config_dir().get<1>() + impl_->userRecvFileDir_ + path;
		int i = 1;
		while (epius::epfilesystem::instance().file_exists(local_path))
		{
			std::string pad = boost::str(boost::format("(%d)")%i);
			std::string ext = epius::epfilesystem::instance().file_extension(path);
			local_path = get_config_dir().get<1>() + impl_->userRecvFileDir_ + path.substr(0, path.length()- ext.length()) + pad + ext;
			i++;
		}

		return local_path;
	}

	std::string biz_file_manager_interface::get_default_cache_dir()
	{
		std::string default_data_path = get_default_config_dir();
		default_data_path = epius::epfilesystem::instance().sub_path(default_data_path, "cache");
		epius::epfilesystem::instance().create_directories(default_data_path);
		return default_data_path;
	}

	std::string biz_file_manager_interface::get_tmp_file_path()
	{
		std::string cache_path = get_default_cache_dir();
		std::string file_name = epius::gen_uuid();
		return epius::epfilesystem::instance().sub_path(cache_path, file_name);
	}

	std::string biz_file_manager_interface::get_user_image_dir()
	{
		return impl_->userImagesDir_;
	}

	std::string biz_file_manager_interface::get_user_voice_dir()
	{
		return impl_->userVoiceMsgDir_;
	}


};
