#include <set>
#include <base/thread/time_thread/time_thread.h>
#include <boost/asio.hpp>
#include <boost/thread.hpp>
#include <boost/bind.hpp>
#include <boost/thread/condition.hpp>
#include <boost/asio/steady_timer.hpp>

using namespace boost;
using boost::system::error_code;

namespace epius
{
	typedef boost::asio::basic_waitable_timer<boost::chrono::steady_clock> steady_timer;
	class time_thread::time_thread_impl
	{
	public:
		time_thread_impl();
		~time_thread_impl();
		void run();
		void stop();
		void handle_timer(shared_ptr<steady_timer> time_key, boost::function<void()> cmd, const error_code& e );
	public:
		asio::io_service io_service_;
		boost::shared_ptr<thread> proactor_thread_;
		boost::shared_ptr<asio::io_service::work> work_;
		boost::mutex m_mutex;
		boost::condition m_cond;
		std::set<shared_ptr<steady_timer> > remember_timers_;
		std::map<std::string, shared_ptr<steady_timer> > named_timer_set_;
	};

	time_thread::time_thread_impl::time_thread_impl():work_(new asio::io_service::work(io_service_))
	{
		proactor_thread_ = shared_ptr<boost::thread>(new boost::thread(boost::bind(&time_thread_impl::run, this)));
	}

	time_thread::time_thread_impl::~time_thread_impl()
	{
		stop();
	}

	void time_thread::time_thread_impl::run()
	{
		io_service_.run();
	}

	void time_thread::time_thread_impl::stop()
	{
		io_service_.post(boost::bind(&boost::asio::io_service::stop,&io_service_));
		work_.reset();
		try {proactor_thread_->join();}catch(...){}
	}

	void time_thread::time_thread_impl::handle_timer( shared_ptr<steady_timer> time_key, boost::function<void()> cmd, const error_code& e )
	{
		if(!e)cmd();
	}

	void time_thread::post( boost::function<void()>cmd )
	{
		impl_->io_service_.post(cmd);
	}

	bool time_thread::is_in_work_thread()
	{
		return (impl_->proactor_thread_->get_id() == boost::this_thread::get_id());
	}

	void time_thread::set_timer( int ms,boost::function<void()> cmd )
	{
		post([=](){
			shared_ptr<steady_timer> timer_key(new steady_timer(impl_->io_service_));
			timer_key->expires_from_now(boost::chrono::milliseconds(ms));
			impl_->remember_timers_.insert(timer_key);
			timer_key->async_wait([=](const error_code& e){
				if(!e) {
					cmd();
					impl_->remember_timers_.erase(timer_key);
				}
			});
		});
	}

	void time_thread::set_timer( std::string timer_key, int ms,boost::function<void()> cmd )
	{
		post([=](){
			if(impl_->named_timer_set_.find(timer_key)==impl_->named_timer_set_.end())
			{
				shared_ptr<steady_timer> tmp_timer(new steady_timer(impl_->io_service_));
				impl_->named_timer_set_[timer_key] = tmp_timer;
			}
			impl_->named_timer_set_[timer_key]->expires_from_now(boost::chrono::milliseconds(ms));
			impl_->named_timer_set_[timer_key]->async_wait([=](const error_code& e){
				if(!e){
					cmd();
					impl_->named_timer_set_.erase(timer_key);
				}
			});
		});
	}

	time_thread::time_thread():impl_(new time_thread_impl)
	{

	}

	void time_thread::stop()
	{
		impl_->stop();
	}

	act_post_cmd time_thread::get_post_cmd()
	{
		return boost::bind(&time_thread::post, this, _1);
	}

	void time_thread::wait()
	{
		boost::mutex::scoped_lock lock(impl_->m_mutex);
		impl_->m_cond.wait(lock);
	}

	void time_thread::notify()
	{
		impl_->m_cond.notify_one();
	}

	std::size_t time_thread::thread_id()
	{
		return hash_value(impl_->proactor_thread_->get_id());
	}

	void time_thread::timed_wait( int ms )
	{
		shared_ptr<steady_timer> timer_key(new steady_timer(impl_->io_service_));
		timer_key->expires_from_now(boost::chrono::milliseconds(ms));
		timer_key->async_wait(boost::bind(&time_thread::notify,this));
		boost::mutex::scoped_lock lock(impl_->m_mutex);
		impl_->m_cond.wait(lock);
	}

	void time_thread::kill_timer( std::string timer_key)
	{
		post([=](){
			boost::system::error_code code;
			if(impl_->named_timer_set_.find(timer_key)!=impl_->named_timer_set_.end())
			{
				impl_->named_timer_set_[timer_key]->cancel(code);
				impl_->named_timer_set_.erase(timer_key);
			}
		});
	}
	void time_thread::kill_all_timer()
	{
		post([=](){
			boost::system::error_code code;
			std::for_each(impl_->named_timer_set_.begin(),impl_->named_timer_set_.end(), [=](std::pair<std::string, shared_ptr<steady_timer> > time_value) mutable{
				time_value.second->cancel(code);
			});
			impl_->named_timer_set_.clear();
		});
	}

	void time_thread::test_timer( std::string timer_key, boost::function<void(bool)> callback )
	{
		post([=](){
			if(impl_->named_timer_set_.find(timer_key)!=impl_->named_timer_set_.end())
			{
				callback(true);
				return;
			}
			callback(false);
		});
	}

}
