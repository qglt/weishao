#pragma once

#include <map>
#include <list>
#include <vector>
#include <iterator>
#include <algorithm>
#include <base/utility/singleton/singleton.hpp>
#include "base/json/tinyjson.hpp"
#include <boost/shared_ptr.hpp>

namespace epius
{
	class local_search_impl;
	class local_search
	{
	public:
		template<class> friend struct boost::utility::singleton_holder;		
		bool match(std::string filter_string,std::string name);
	private:
		local_search();
	private:	
		boost::shared_ptr<local_search_impl> impl_;
	};

	typedef boost::utility::singleton_holder<local_search> eplocal_find;
};


