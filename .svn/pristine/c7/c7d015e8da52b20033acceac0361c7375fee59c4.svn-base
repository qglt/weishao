#include <boost/shared_ptr.hpp>
#include <boost/function.hpp>
#include <third_party/threadpool/threadpool.hpp>
#include <base/utility/singleton/singleton.hpp>

namespace epius{
	class one_pool_decl
	{
		template<class> friend struct boost::utility::singleton_holder;
public:
		void schedule(boost::function<void()> cmd){pool_->schedule(cmd);}
		void stop(){pool_.reset();}
private:
		one_pool_decl():pool_(new boost::threadpool::pool(3)){}
		boost::shared_ptr<boost::threadpool::pool> pool_;
	};
	typedef boost::utility::singleton_holder<one_pool_decl> one_pool;
}