#pragma once

#include <string>
#include <boost/function.hpp>

namespace epius
{
	std::string get_digist(std::string const& info);
	std::string get_uri(std::string const& filename);
	void async_get_uri(std::string filename, boost::function<void(std::string)> callback);
}
