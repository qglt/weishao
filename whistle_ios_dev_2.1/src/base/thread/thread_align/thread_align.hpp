#pragma once
#include <boost/function.hpp>
namespace epius
{
	struct thread_align
	{
		thread_align(){};
		thread_align(boost::function<bool()> teller, boost::function<void(boost::function<void()>) > do_post):tell_in_expect_thread_(teller),postCmd_(do_post){}
		//if one of the aligner is empty, have no condition to swith thread, so just ignore
		bool is_in_expect_thread()
		{
			if(tell_in_expect_thread_.empty() || postCmd_.empty())return true;
			return tell_in_expect_thread_();
		}
		void post(boost::function<void()> cmd) {if(!postCmd_.empty()){postCmd_(cmd);}}
	
		boost::function<bool()> tell_in_expect_thread_;
		boost::function<void(boost::function<void()>) > postCmd_;
	};


}