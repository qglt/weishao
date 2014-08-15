
#pragma once

#include <string>
#include <base/utility/singleton/singleton.hpp>

namespace biz
{
    class app_settings_impl
    {
    public:
        std::string get_domain() const;
        void set_domain(std::string val);
		std::string get_db_key();
		std::string get_localupdate_folder();
    private:
        std::string domain_;
    };
    typedef boost::utility::singleton_holder<app_settings_impl> app_settings;
}