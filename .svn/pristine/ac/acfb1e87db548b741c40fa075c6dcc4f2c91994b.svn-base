#pragma once
#include <base/utility/singleton/singleton.hpp>
#include <map>
#include <string>
#include <time.h>
#include <base/cmd_wrapper/command_wrapper.h>
namespace biz{
	class biz_statistics_data
	{
		template<class> friend struct boost::utility::singleton_holder;
	public:
		biz_statistics_data();
		void add_data(std::string item, int number);
		void do_add_data(std::string item, int number);
		void get_data(std::map<std::string, int>& data);

		epius::thread_switch::WrapHelper wrap_helper_;
	private:
		std::map<std::string, int> item_num;
	};

	typedef boost::utility::singleton_holder<biz_statistics_data> g_statistics_data;
}