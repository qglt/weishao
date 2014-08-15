#include "biz_app_settings.h"

namespace biz
{
	std::string app_settings_impl::get_db_key()
	{
		return "whistle_2013_will_win";
	}

	void app_settings_impl::set_domain( std::string val )
	{
		domain_ = val;
	}

	std::string app_settings_impl::get_domain() const
	{
		return domain_;
	}

	std::string app_settings_impl::get_localupdate_folder()
	{
		return "localupdate";
	}
}
