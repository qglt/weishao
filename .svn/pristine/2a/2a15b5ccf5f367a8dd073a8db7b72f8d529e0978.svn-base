#include <base/module_path/module_path.h>
#include <boost/filesystem.hpp>
#include <base/txtutil/txtutil.h>

namespace epius
{
    std::string get_module_path()
    {
#ifdef _WIN32
        std::wstring tmp = boost::filesystem::initial_path<boost::filesystem::wpath>().generic_wstring();
        return epius::txtutil::convert_wcs_to_utf8(tmp);
#else
        std::string tmp = boost::filesystem::initial_path<boost::filesystem::path>().generic_string();
        
        return tmp;
#endif
    }
}
