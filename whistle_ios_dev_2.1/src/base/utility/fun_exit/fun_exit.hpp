#pragma once

#include <boost/any.hpp>
#include <boost/shared_ptr.hpp>

namespace epius
{
	struct fun_exit
	{
		template<class T> struct fun_exit_helper
		{
			fun_exit_helper(T cmd):leave_cmd_(cmd){}
			T leave_cmd_;
			~fun_exit_helper()
			{
				leave_cmd_();
			}
		};
		template<class T> fun_exit(T cmd)
		{
			alive_obj_ = boost::make_shared<fun_exit_helper<T> >(cmd);
		}
		boost::any alive_obj_;
	};
}