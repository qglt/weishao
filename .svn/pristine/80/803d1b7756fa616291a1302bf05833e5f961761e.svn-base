#pragma once
#include <base/json/tinyjson.hpp>
#include <base/utility/singleton/singleton.hpp>
#include <base/universal_res/uni_res.h>
#include <boost/shared_ptr.hpp>
#include "biz_adapter.h"

namespace biz{
	struct Tuser_info;   
	class biz_lower_impl;
	class biz_lower_interface
	{
		template<class> friend struct boost::utility::singleton_holder;
	public:
		void init(boost::shared_ptr<biz_adapter> adapt, boost::function<void(boost::function<void()>) > postCmd = boost::function<void(boost::function<void()>) >());
		void uninit();
	private:
		
		biz_lower_interface();
		boost::shared_ptr<biz_lower_impl> impl_;
	};

	typedef boost::utility::singleton_holder<biz_lower_interface> biz_lower;

}
