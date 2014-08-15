#pragma once

#include <base/utility/singleton/singleton.hpp>
namespace json
{
	class json_error_impl
	{
		boost::signal<void(std::string)> m_sig;
	public:
		void connect(boost::function<void(std::string)> cmd){m_sig.connect(cmd);}
		void sig(std::string const& err_info){m_sig(err_info);}
	};

	typedef boost::utility::singleton_holder<json_error_impl> json_error;
}//namespace json