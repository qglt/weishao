#include <base/module_path/create_dir_nofailed.h>
#include <base/txtutil/txtutil.h>
#include "boost/filesystem/operations.hpp"

namespace epius {

	template<class pathType>
	static bool create_directories_nofailed_base(pathType curr_path)
	{
		if(curr_path.generic_string().empty())return true;
		if(boost::filesystem::exists(curr_path))
		{
			if(boost::filesystem::is_directory(curr_path))return true;
			return false;
		}
		if(create_directories_nofailed_base(curr_path.branch_path()))
		{
			try
			{
				boost::filesystem::create_directory(curr_path);
				return true;
			}
			catch(...)
			{
				if (boost::filesystem::exists(curr_path) && boost::filesystem::is_directory(curr_path))
				{
					return true;
				}
				return false;
			}
		}
		return false;
	}
#ifdef _WIN32
	bool create_dir_nofailed::create_directories_nofailed(std::wstring wpath_string)
	{
		return create_directories_nofailed_base(boost::filesystem::wpath(wpath_string));
	}
#endif
	void create_dir_nofailed::create_directories_nofailed_utf8(std::string path_string_utf8)
	{
#ifdef _WIN32
		std::wstring path_string_ucs2 = epius::txtutil::convert_utf8_to_wcs(path_string_utf8);
		create_directories_nofailed(path_string_ucs2);
#else
		create_directories_nofailed_base(boost::filesystem::path(path_string_utf8));
#endif
	}

}; // namespace biz