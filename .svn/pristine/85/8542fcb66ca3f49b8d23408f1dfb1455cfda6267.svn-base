#pragma once


#include <fstream>
#include <base/txtutil/txtutil.h>
#include <boost/filesystem.hpp>
#include "tinyjson.hpp"
namespace json
{
    static jobject from_file(std::wstring const& filename)
    {
		try{
			using namespace std;
			char BOM[] = {char(0xEF),char(0xBB), char(0xBF)};
			string BOM_Header(BOM, 3);
#ifdef _WIN32
			ifstream file_inst(filename, ios::binary);
			unsigned int fsize = (unsigned int)boost::filesystem::file_size(filename);
#else
			ifstream file_inst(epius::txtutil::convert_wcs_to_utf8(filename).c_str(), ios::binary);
			unsigned int fsize = (unsigned int)boost::filesystem::file_size(epius::txtutil::convert_wcs_to_utf8(filename));
#endif
			boost::shared_array<char> pbuffer(new char[fsize]);
			file_inst.read(pbuffer.get(),fsize);
			std::string file_content;
			if(fsize>=3 && std::string(pbuffer.get(),3)==BOM_Header)
			{
				file_content = std::string(pbuffer.get()+3,fsize-3);
			}
			else
			{
				file_content = std::string(pbuffer.get(),fsize);
			}
			json::jobject jobj(file_content);
			if(!jobj)
			{
				json_error::instance().sig("error file content:"+ file_content);
			}
			return jobj;
		}catch(...)
		{
			return jobject();
		}
    }
	static jobject from_file(std::string const& filename)//filename in utf8 format
	{
		return from_file(txtconv::convert_utf8_to_wcs(filename));
	}

	static void to_file(jobject jobj,std::wstring const& filename)
	{
		using namespace std;
		char BOM[] = {char(0xEF),char(0xBB), char(0xBF)};
		string BOM_Header(BOM, 3);
#ifdef _WIN32
		ofstream file_inst(filename, ios::ios_base::binary|ios::ios_base::out);
#else
		ofstream file_inst(epius::txtutil::convert_wcs_to_utf8(filename).c_str(), ios::binary);
#endif
		string file_content = jobj.to_string();
		if(file_content.empty())
		{
			json_error::instance().sig("error write file:" + epius::txtutil::convert_wcs_to_utf8(filename));
			return;
		}
		file_inst.write(BOM,3);
		file_inst.write(file_content.c_str(),file_content.size());
	}
	static void to_file(jobject jobj, std::string const& filename)//filename in utf8 format
	{
		to_file(jobj, txtconv::convert_utf8_to_wcs(filename));
	}
}
