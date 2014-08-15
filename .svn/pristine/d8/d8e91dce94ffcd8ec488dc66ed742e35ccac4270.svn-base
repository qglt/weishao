#pragma once
#include <boost/function.hpp>
#include <boost/shared_ptr.hpp>
#include <base/config/configure.hpp>
#include <base/cmd_wrapper/command_wrapper.h>

namespace epius
{
	class time_thread
	{
		class time_thread_impl;
	public:
		time_thread();
		void stop();
		void post(boost::function<void()>cmd);
		act_post_cmd get_post_cmd();
		bool is_in_work_thread();
		void set_timer( int ms,boost::function<void()> cmd );
		void set_timer( std::string timer_key, int ms,boost::function<void()> cmd );
		void kill_timer(std::string timer_key);
		void test_timer(std::string timer_key, boost::function<void(bool)> callback);
		void kill_all_timer();
		void wait();
		void timed_wait(int ms);
		void notify();
		std::size_t thread_id();
	private:
		boost::shared_ptr<time_thread_impl> impl_;
	};

}