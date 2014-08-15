#include <base/thread/time_thread/time_thread_mgr.h>

namespace epius {
	
	time_thread_mgr_impl::time_thread_mgr_impl():time_impl_(new time_thread)
	{

	}
	
	void time_thread_mgr_impl::set_timer( int ms, boost::function<void()> cmd )
	{
		time_impl_->set_timer(ms, cmd);
	}

	void time_thread_mgr_impl::set_timer( std::string timer_key, int ms, boost::function<void()> cmd )
	{
		time_impl_->set_timer(timer_key, ms, cmd);
	}

	void time_thread_mgr_impl::stop()
	{
		time_impl_->stop();
	}

	void time_thread_mgr_impl::post( boost::function<void()> cmd )
	{
		time_impl_->post(cmd);
	}

	void time_thread_mgr_impl::kill_timer( std::string timer_key)
	{
		time_impl_->kill_timer(timer_key);
	}

	void time_thread_mgr_impl::kill_all_timer()
	{
		time_impl_->kill_all_timer();
	}

	void time_thread_mgr_impl::test_timer( std::string timer_key, boost::function<void(bool)> callback )
	{
		time_impl_->test_timer(timer_key, callback);
	}

}

