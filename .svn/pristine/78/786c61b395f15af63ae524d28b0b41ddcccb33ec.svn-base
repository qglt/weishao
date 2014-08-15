#pragma once
#include <string>
#include <iostream>
#include <boost/shared_ptr.hpp>
#include <base/config/configure.hpp>
#include <base/utility/singleton/singleton.hpp>
#include <base/json/tinyjson.hpp>

#include "boost/filesystem.hpp"
#include "boost/date_time/gregorian/gregorian.hpp"
#include <boost/filesystem/path.hpp>
#include <boost/filesystem/operations.hpp> 

#define ELOG(x) epius::elog_factory::instance().get_elog(x)
#define COOL(x) (boost::format("%s:%d %s")%__FILE__%__LINE__%(x)).str()
#define WCOOL(x) txtconv::convert_wcs_to_utf8((boost::wformat(L"%s:%d %s")%__FILE__%__LINE__%(x)).str())

namespace epius {
    class elog_impl;
    class elog
    {
        friend class elog_factory_decl;
    public:
        elog();
        void debug(std::string info);
        void warn(std::string info);
        void error(std::string info);
        void fatal(std::string info);
    private:
        boost::shared_ptr<elog_impl> impl_;
    };
    class elog_factory_impl;
    class elog_factory_decl
    {
    public:
        elog_factory_decl();
        void init();
		void set_root_path(std::string root_path);
		std::string get_root_path();
        void init(json::jobject jobj);
        boost::shared_ptr<elog> get_elog(std::string elogName);
		bool is_in_work_thread();
		void post(boost::function<void()> cmd);
		void set_version_num(std::string version_num);
		std::string get_version_num();
		void stop();
	private:
		boost::shared_ptr<elog_factory_impl> impl_;
    };
    typedef boost::utility::singleton_holder<elog_factory_decl> elog_factory;
}