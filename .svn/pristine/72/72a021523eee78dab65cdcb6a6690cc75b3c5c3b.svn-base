#pragma once
#include <base/utility/singleton/singleton.hpp>
#include <set>
#include <string>
#include <base/cmd_wrapper/command_wrapper.h>
namespace biz{
	class biz_thread_id
	{
		template<class> friend struct boost::utility::singleton_holder;
	public:
		biz_thread_id();
		std::string gen_id();
		bool is_id_exist(std::string id);
		void delete_id(std::string id);

		epius::thread_switch::WrapHelper wrap_helper_;
	private:
		std::set<std::string> id_set_;
	};

	typedef boost::utility::singleton_holder<biz_thread_id> thread_id;
}