#include <base/module_path/epfilesystem.h>
#include <base/txtutil/txtutil.h>
#include <boost/filesystem.hpp>
#include <base/log/elog/elog.h>
#include <base/module_path/create_dir_nofailed.h>
#include <vector>
using namespace std;
namespace epius{

	bool epfilesystemimpl::file_exists( std::string filename )
	{
		try{
#ifdef _WIN32
			return boost::filesystem::exists(epius::txtutil::convert_utf8_to_wcs(filename));
#else
			return boost::filesystem::exists(filename);
#endif
		}
		catch(...) 
		{
			ELOG("app")->error("catch:failed call epfilesystem::file_exists");
			return false;
		}
	}

	bool epfilesystemimpl::copy_file( std::string oldpath, std::string newpath, bool overwrite /* = false*/)
	{
		try{
#ifdef _WIN32
			std::wstring wold_path = epius::txtutil::convert_utf8_to_wcs(oldpath);
			std::wstring wnew_path = epius::txtutil::convert_utf8_to_wcs(newpath);
			if (overwrite)
			{
				boost::filesystem::copy_file(wold_path, wnew_path, boost::filesystem::copy_option::overwrite_if_exists);
			}
			else
			{
				boost::filesystem::copy_file(wold_path, wnew_path);
			}
#else
			if (overwrite)
			{
				boost::filesystem::copy_file(oldpath, newpath, boost::filesystem::copy_option::overwrite_if_exists);
                //boost::filesystem::copy_file(boost::filesystem::path(oldpath), boost::filesystem::path(newpath), boost::filesystem::copy_option::overwrite_if_exists);
			}
			else
			{
				boost::filesystem::copy_file(oldpath, newpath);
				//boost::filesystem::copy_file(boost::filesystem::path(oldpath), boost::filesystem::path(newpath));
			}
#endif
			return true;
		}
		catch(...) 
		{
			ELOG("app")->error("catch:failed call epfilesystem::copy_file from " + oldpath + " to " + newpath);
			return false;
		}
	}

	void epfilesystemimpl::remove_file(std::string filename)
	{
		try{
#ifdef _WIN32
			boost::filesystem::remove(epius::txtutil::convert_utf8_to_wcs(filename));
#else
			boost::filesystem::remove(filename);
#endif
		}
		catch(...) 
		{
			ELOG("app")->error("catch:failed call epfilesystem::remove_file");
		}
	}

	void epfilesystemimpl::rename_file( std::string oldpath, std::string newpath )
	{
		try{
#ifdef _WIN32
			boost::filesystem::rename(epius::txtutil::convert_utf8_to_wcs(oldpath), epius::txtutil::convert_utf8_to_wcs(newpath));
#else
			boost::filesystem::rename(oldpath, newpath);
#endif
		}
		catch(boost::filesystem::filesystem_error e) 
		{
			ELOG("app")->error("catch:failed call epfilesystem::rename_file : " + std::string(e.what()));
		}
	}

	void epfilesystemimpl::remove_all_file( std::string filename )
	{
		try{
#ifdef _WIN32
			boost::filesystem::remove_all(epius::txtutil::convert_utf8_to_wcs(filename));
#else
			boost::filesystem::remove_all(filename);
#endif
		}
		catch(...) 
		{
			ELOG("app")->error("catch:failed call epfilesystem::remove_all_file");
		}
	}


	bool epfilesystemimpl::copy_files( std::string oldpath, std::string newpath, boost::function<bool(std::string)> exclude_filter )
	{
		try
		{
			if (! file_exists(newpath))
			{  
				create_directories(newpath);
			}
#ifdef _WIN32
			boost::filesystem::wpath src(txtconv::convert_utf8_to_wcs(oldpath));
			boost::filesystem::wpath dst(txtconv::convert_utf8_to_wcs(newpath));
			for (boost::filesystem::directory_iterator it(src); it != boost::filesystem::directory_iterator(); ++it)  
			{  
				std::string newSrc = WS2UTF(it->path().generic_wstring());
				if(!exclude_filter.empty() && exclude_filter(newSrc))continue;
				std::string newDst = WS2UTF((dst / it->path().leaf()).generic_wstring());
				if (is_directory(newSrc))  
				{  
					if(!copy_files(newSrc, newDst,exclude_filter))return false;
				}  
				else if (is_regular_file(newSrc))  
				{  
					copy_file(newSrc, newDst, true);
				}
				else  
				{  
					ELOG("app")->error("encounter unknown file type during migration of user data");
					return false;
				}
			}
#else
			boost::filesystem::path src(oldpath);
			boost::filesystem::path dst(newpath);
			for (boost::filesystem::directory_iterator it(src); it != boost::filesystem::directory_iterator(); ++it)  
			{  
				std::string newSrc = it->path().generic_string();
				if(!exclude_filter.empty() && exclude_filter(newSrc))continue;
				std::string newDst = (dst / it->path().leaf()).generic_string();
				if (is_directory(newSrc))  
				{  
					if(!copy_files(newSrc, newDst,exclude_filter))return false;
				}  
				else if (is_regular_file(newSrc))  
				{  
					copy_file(newSrc, newDst, true);
				}
				else  
				{  
					ELOG("app")->error("encounter unknown file type during migration of user data");
					return false;
				}
			}
#endif
			return true;
		}
		catch (...)
		{
			return false;
		}
	}

	void epfilesystemimpl::create_directories( std::string dst )
	{
		create_dir_nofailed::create_directories_nofailed_utf8(dst);
	}

	bool epfilesystemimpl::is_directory( std::string pathStr )
	{
#ifdef _WIN32
		return boost::filesystem::is_directory(txtconv::convert_utf8_to_wcs(pathStr));
#else
		return boost::filesystem::is_directory(pathStr);
#endif
	}

	bool epfilesystemimpl::remove_files( std::string oldpath, boost::function<bool(std::string)> exclude_filter )
	{
		try
		{
#ifdef _WIN32
			boost::filesystem::wpath src(txtconv::convert_utf8_to_wcs(oldpath));
			for (boost::filesystem::directory_iterator it(src); it != boost::filesystem::directory_iterator(); ++it)  
			{  
				std::string newSrc = WS2UTF(it->path().generic_wstring());
				if(!exclude_filter.empty()&&exclude_filter(newSrc))continue;
				if (is_directory(newSrc))
				{
					if(!remove_files(newSrc,exclude_filter))return false;
					remove_file(newSrc);
				}  
				else if (is_regular_file(newSrc))  
				{  
					remove_file(newSrc);
				}  
				else  
				{  
					ELOG("app")->error("encounter unknown file type during migration of user data");
					return false;
				}  
			}
			if(exclude_filter.empty() || !exclude_filter(oldpath))
			{
				remove_file(oldpath);
			}
#else
			boost::filesystem::path src(oldpath);
			for (boost::filesystem::directory_iterator it(src); it != boost::filesystem::directory_iterator(); ++it)
			{  
				std::string newSrc = it->path().generic_string();  
				if(!exclude_filter.empty()&&exclude_filter(newSrc))continue;
				if (is_directory(newSrc))
				{
					if(!remove_files(newSrc,exclude_filter))return false;
					remove_file(newSrc);
				}  
				else if (is_regular_file(newSrc))  
				{  
					remove_file(newSrc);
				}  
				else  
				{  
					ELOG("app")->error("encounter unknown file type during migration of user data");
					return false;
				}  
			}
			if(exclude_filter.empty() || !exclude_filter(oldpath))
			{
				remove_file(oldpath);
			}
#endif
			return true;
		}catch(...)
		{
			return false;
		}
	}

	std::string epfilesystemimpl::branch_path( std::string full_path )
	{
#ifdef _WIN32
		boost::filesystem::wpath entire_path(epius::txtutil::convert_utf8_to_wcs(full_path));
		return epius::txtutil::convert_wcs_to_utf8(entire_path.branch_path().generic_wstring());
#else
		boost::filesystem::path entire_path(full_path);
		return entire_path.branch_path().generic_string();
#endif
	}

	std::string epfilesystemimpl::sub_path( std::string root, std::string sub )
	{
#ifdef _WIN32
		boost::filesystem::wpath entire_path(epius::txtutil::convert_utf8_to_wcs(root));
		entire_path /= epius::txtutil::convert_utf8_to_wcs(sub);
		return epius::txtutil::convert_wcs_to_utf8(entire_path.generic_wstring());
#else
		boost::filesystem::path entire_path(root);
		entire_path /= sub;
		return entire_path.generic_string();
#endif
	}

	std::string epfilesystemimpl::find_first_file(std::string root_path, std::string filename )
	{
		if(!is_directory(root_path)) 
		{
			if(file_name(root_path) == filename) return root_path;
			return "";
		}
		try
		{
#ifdef _WIN32
			boost::filesystem::wpath src(txtconv::convert_utf8_to_wcs(root_path));
#else
			boost::filesystem::path src(root_path);
#endif
			vector<string> dir_paths;
			for (boost::filesystem::directory_iterator it(src); it != boost::filesystem::directory_iterator(); ++it)  
			{  
#ifdef _WIN32
				std::string newSrc = WS2UTF(it->path().generic_wstring());
#else
				std::string newSrc = it->path().generic_string();
#endif
				if (is_directory(newSrc))
				{
					dir_paths.push_back(newSrc);
				}  
				else if (is_regular_file(newSrc))  
				{
#ifdef _WIN32
					if(it->path().filename().generic_wstring()==UTF2WS(filename))
					{
						return WS2UTF(it->path().generic_wstring());
					}
#else
					if(it->path().filename().generic_string()==filename)
					{
						return it->path().generic_string();
					}
#endif
				}
				else  
				{  
					ELOG("app")->error("encounter unknown file type during migration of user data");
					return "";
				}
			}
			for(vector<string>::iterator it = dir_paths.begin();it!=dir_paths.end();++it)
			{
				std::string dest_file = find_first_file(*it, filename);
				if(!dest_file.empty())
				{
					return dest_file;
				}
			}
			return "";
		}
		catch (...)
		{
			return "";
		}
	}

	bool epfilesystemimpl::is_regular_file( std::string file_path )
	{
#ifdef _WIN32
		return boost::filesystem::is_regular_file(txtconv::convert_utf8_to_wcs(file_path));
#else
		return boost::filesystem::is_regular_file(file_path);
#endif
	}


	boost::uintmax_t epfilesystemimpl::file_size( std::string filename )
	{
		try{
#ifdef _WIN32
			return boost::filesystem::file_size(epius::txtutil::convert_utf8_to_wcs(filename));
#else
			return boost::filesystem::file_size(filename);
#endif
		}
		catch(...) 
		{
			ELOG("app")->error("catch:failed call epfilesystem::file_size");
		}

		return 0;
	}

	std::string epfilesystemimpl::file_name( std::string filename )
	{
#ifdef _WIN32
		boost::filesystem::wpath path(epius::txtutil::convert_utf8_to_wcs(filename));
		return epius::txtutil::convert_wcs_to_utf8(path.filename().generic_wstring());
#else
		boost::filesystem::path path(filename);
		return path.filename().generic_string();
#endif
	}

	std::string epfilesystemimpl::file_extension( std::string filename )
	{
#ifdef _WIN32
		boost::filesystem::wpath path(epius::txtutil::convert_utf8_to_wcs(filename));
		return epius::txtutil::convert_wcs_to_utf8(path.filename().extension().generic_wstring());
#else
		boost::filesystem::path path(filename);
		return path.extension().generic_string();
#endif
	}

	bool epfilesystemimpl::is_absolute( std::string filepath )
	{
#ifdef _WIN32
		boost::filesystem::wpath path(epius::txtutil::convert_utf8_to_wcs(filepath));
		return path.is_absolute();
#else
		boost::filesystem::path path(filepath);
		return path.is_absolute();
#endif
	}

	std::string epfilesystemimpl::change_extension( std::string filename, std::string new_ext )
	{
#ifdef _WIN32
		std::string file_ext = file_extension(filename);
		if(!file_ext.empty())
		{
			filename = filename.substr(0, filename.size() - file_ext.size() - 1);
		}
		filename += new_ext;
		return filename;

#else
		return boost::filesystem::change_extension(filename, new_ext).generic_string();
#endif
	}

	void epfilesystemimpl::open_stream( std::string file_path, std::ifstream& ism, std::ios::openmode mode )
	{
#ifdef _WIN32
		std::wstring w_file_path = UTF2WS(file_path);
		ism.open(w_file_path.c_str(),mode);
#else
		ism.open(file_path.c_str(), mode);
#endif
	}

	void epfilesystemimpl::open_stream( std::string file_path, std::ofstream& ism, std::ios::openmode mode)
	{
#ifdef _WIN32
		std::wstring w_file_path = UTF2WS(file_path);
		ism.open(w_file_path.c_str(),mode);
#else
		ism.open(file_path.c_str(), mode);
#endif
	}

}
