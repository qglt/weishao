#pragma once

#include <string>
#include <boost/uuid/uuid.hpp>
#include <boost/uuid/uuid_generators.hpp>
#include <boost/uuid/uuid_io.hpp>
#include <boost/lexical_cast.hpp>

namespace epius {
	inline std::string gen_uuid()
	{
		boost::uuids::uuid u = boost::uuids::random_generator()();
		std::string result = boost::lexical_cast<std::string>(u);
		return result;
	}
}