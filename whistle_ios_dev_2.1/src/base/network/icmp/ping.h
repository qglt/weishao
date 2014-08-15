#pragma once
#include <string>
#include <boost/function.hpp>
#include <boost/shared_ptr.hpp>
#include <base/utility/singleton/singleton.hpp>
namespace epius
{
	class ping_mgr_impl;
	class ping_mgr_decl
	{
	public:
		enum PING_STATUS {NO_NETWORK, NEED_AUTH, AUTHED};
		ping_mgr_decl();
		void ping(std::string dest, int timeout_ms,boost::function<void(PING_STATUS)> callback);
		void stop();
	private:
		boost::shared_ptr<ping_mgr_impl> impl_;
	};

	typedef boost::utility::singleton_holder<ping_mgr_decl> ping_mgr;
};
