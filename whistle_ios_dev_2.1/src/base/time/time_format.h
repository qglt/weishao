#pragma once

#include <boost/date_time/time_clock.hpp>
#include <boost/date_time/posix_time/ptime.hpp>
#include <boost/date_time/posix_time/time_formatters.hpp>

namespace epius {

inline std::string time_format(boost::posix_time::ptime time)
{
	int year = time.date().year();
	int month = time.date().month();
	int day = time.date().day();
	std::string time_str = boost::str(boost::format("%d-%02d-%02d")%year%month%day);
	if(!time.time_of_day().is_special()) {
		char sep = ' ';
		time_str += sep + boost::posix_time::to_simple_string(time.time_of_day());
	}
	return time_str;
}

}

