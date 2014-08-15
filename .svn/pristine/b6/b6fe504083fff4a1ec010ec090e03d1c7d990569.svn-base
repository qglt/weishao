#include "statistics_data.h"
#include <base/utility/bind2f/bind2f.hpp>
namespace biz{

	biz_statistics_data::biz_statistics_data()
	{
	}

	void biz_statistics_data::add_data( std::string item, int number)
	{
		wrap_helper_.wrap(bind2f(&biz_statistics_data::do_add_data, this, item, number))();
	}


	void biz_statistics_data::do_add_data( std::string item, int number)
	{
		std::map<std::string, int>::iterator it = item_num.find(item);
		if (it == item_num.end())
		{
			item_num.insert(make_pair(item, number));
		}
		else
		{
			it->second =  it->second + number;
		}
	}

	void biz_statistics_data::get_data( std::map<std::string, int>& data )
	{
		data = item_num;
		item_num.clear();
	}
}