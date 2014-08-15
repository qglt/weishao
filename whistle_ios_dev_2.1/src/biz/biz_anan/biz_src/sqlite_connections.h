#pragma once
#include <map>
#include <string>
#include "base/epiusdb/ep_sqlite.h"
#include <stack>
#include <base/utility/singleton/singleton.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/tuple/tuple.hpp>

namespace biz {

class db_connection_impl
{
	struct dbinfos 
	{
		friend class db_connection_impl;
		dbinfos();
		dbinfos(std::string base_dir, std::string db_dir);
		dbinfos(const dbinfos& that);
		void rebuild_connection(std::string new_base_path);
	private:
		boost::shared_ptr<epius::epius_sqlite3::epDbAutoCreate> db_connection_; //db pointer
		std::string db_relative_dir_;//relative path to the db_base_dir
		std::string db_base_dir_;//may be empty or user_specified place, if db_base_dir is empty, the db is in %appdata%/anan/
	};

	typedef std::map<std::string, dbinfos> dbconnectmap;
public:
	db_connection_impl();
	epius::epius_sqlite3::epDbAutoCreate* get_db(std::string key);
	void remove( std::string key );
	void add(std::string key, std::string base_dir, std::string db_dir);
	void push(void);
	void pop(std::string config_path);

private:
	dbconnectmap mapdbs;
};
typedef boost::utility::singleton_holder<db_connection_impl> db_connection;
}; // namespace biz