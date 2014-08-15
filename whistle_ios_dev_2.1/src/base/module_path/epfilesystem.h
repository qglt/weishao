#include <base/config/configure.hpp>
#include <string>
#include <boost/function.hpp>
#include <base/utility/singleton/singleton.hpp>
#include <fstream>

namespace epius{

	class epfilesystemimpl
	{
		template<class> friend struct boost::utility::singleton_holder;
	public:
		void open_stream(std::string file_path, std::ifstream& ism, std::ios::openmode mode);
		void open_stream(std::string file_path, std::ofstream& ism, std::ios::openmode mode);
		std::string find_first_file(std::string root_path, std::string filename);
		bool file_exists(std::string filename);
		std::string branch_path(std::string full_path);
		std::string sub_path(std::string root, std::string sub);
		bool is_absolute(std::string filepath);
		//copy_file only copy file, not include dir
		bool copy_file(std::string oldpath, std::string newpath, bool overwrite = false);
		//copy_files can copy file and dir, and in overwrite mode
		bool copy_files(std::string oldpath, std::string newpath, boost::function<bool(std::string)> exclude_filter = boost::function<bool(std::string)>());
		bool is_directory(std::string pathStr);
		bool is_regular_file(std::string file_path);
		void create_directories(std::string dst);
		void remove_file(std::string filename);
		void remove_all_file(std::string filename);
		//remove files can remove a dir
		bool remove_files(std::string oldpath, boost::function<bool(std::string)> exclude_filter = boost::function<bool(std::string)>());
		void rename_file(std::string oldpath, std::string newpath);
		boost::uintmax_t file_size(std::string filename);
		std::string file_name(std::string filename);
		std::string file_extension(std::string filename);
		std::string change_extension(std::string filename, std::string new_ext);
	};

	typedef boost::utility::singleton_holder<epfilesystemimpl> epfilesystem;
}
