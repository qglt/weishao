#pragma once
#include <string>
#include <base/config/configure.hpp>
namespace epius {

	class create_dir_nofailed
	{
	public:
		static void create_directories_nofailed_utf8(std::string path_string_utf8);
#ifdef _WIN32
		static bool create_directories_nofailed(std::wstring wpath_string);
#endif
	};
}; // namespace biz