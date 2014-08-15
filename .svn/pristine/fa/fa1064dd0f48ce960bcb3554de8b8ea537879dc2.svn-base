#pragma once
#include <boost/shared_ptr.hpp>
#include <base/utility/singleton/singleton.hpp>
#include "time_thread.h"

namespace epius
{
	class time_thread_mgr_impl
	{
	public:
		void post(boost::function<void()> cmd);
		void set_timer(int ms, boost::function<void()> cmd);
		void set_timer(std::string timer_key, int ms, boost::function<void()> cmd);
		void kill_timer(std::string timer_key);
		void test_timer(std::string timer_key, boost::function<void(bool)> callback);
		void kill_all_timer();
		void stop();
	private:
		template<class> friend struct boost::utility::singleton_holder;
		time_thread_mgr_impl();
		boost::shared_ptr<time_thread> time_impl_;
	};
	typedef boost::utility::singleton_holder<time_thread_mgr_impl> time_mgr;
}
