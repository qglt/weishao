#pragma once
#include "biz_presence_type.h"
#include <base/epiusdb/ep_sqlite.h>
#include <boost/bind.hpp>
#include <base/module_path/file_manager.h>
#include <base/txtutil/txtutil.h>

namespace biz
{
struct Tuser_info
{
	epius::epius_sqlite3::epDbBinder TieAll()
	{
		return epius::epius_sqlite3::epDbBinder(boost::ref(last_login_time), boost::ref(user_id), boost::ref(password), 
			boost::ref(presence), boost::ref(auto_login),boost::ref(savePasswd),boost::ref(avatar_file), 
			boost::ref(sam_id), boost::ref(anan_id)
			);
	}
	Tuser_info(){}
	Tuser_info( const epius::epius_sqlite3::data_iterator& it )
	{
		epius::epius_sqlite3::epDbBinder tmpBind = TieAll();
		tmpBind = it;
		
		if (!avatar_file.empty()){
			if(!file_manager::instance().file_is_valid(avatar_file))
			{
				avatar_file = "";
			}
		}
	}

	boost::posix_time::ptime last_login_time;
	std::string user_id;
	std::string password;
	int presence;
	int auto_login;
	int savePasswd;
	std::string avatar_file;
	std::string sam_id;
	std::string anan_id;
	std::string account_type;
};

enum KLoadType
{
	kagFromMemory,
	kagFromStorage
};

}; // biz