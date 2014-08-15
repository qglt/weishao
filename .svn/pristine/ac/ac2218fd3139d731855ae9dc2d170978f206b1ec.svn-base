#include <windows.h>
#include <string>
#include <base/txtutil/txtutil.h>
#include <base/zip/zip.h>
#include <base/zip/unzip.h>

namespace epius
{
	bool uncompress_file( std::string file_path ,std::string file_name)
	{
		HZIP hz;
		std::wstring local_update_wpath = txtconv::convert_utf8_to_wcs(file_path); 
		std::string file_store_path = file_path.substr(0,file_path.rfind(file_name));
		std::wstring file_store_wpath = txtconv::convert_utf8_to_wcs(file_store_path); 
		if (GetFileAttributes(local_update_wpath.c_str())!=0xFFFFFFFF)
		{ 
			hz = OpenZip(local_update_wpath.c_str(),0); 
			if (hz == 0)
			{
				return false;
			}

			ZIPENTRY ze;
			GetZipItem(hz,-1,&ze); 
			int numitems = ze.index;
			// -1 gives overall information about the zipfile
			for (int zi=0; zi<numitems; zi++)
			{
				ZIPENTRY ze; 
				GetZipItem(hz,zi,&ze); // fetch individual details
				std::wstring  s_name = ze.name;
				s_name = file_store_wpath + s_name;
				UnzipItem(hz, zi, s_name.c_str()); 
			}

			CloseZip(hz);
			return true;
		}
		return false;
	}

}