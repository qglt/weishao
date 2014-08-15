#include <base/utility/file_digest/file2uri.hpp>
#include <fstream>
#include <boost/crc.hpp>
#include <boost/uuid/sha1.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/shared_array.hpp>
#include <boost/shared_ptr.hpp>
#include <base/txtutil/txtutil.h>
#include <base/utility/netbyte/netbyte.hpp>
#include <base/module_path/epfilesystem.h>
#include <base/thread/one_pool/one_pool.hpp>
namespace epius
{
	namespace
	{
		std::string get_digist(std::ifstream &ifs)
		{
			boost::crc_32_type result;
			boost::uuids::detail::sha1 sha;
			ifs.seekg(0, std::ios::beg);
			boost::shared_array<char> buf(new char[1024*1024]);
			while(!ifs.eof())
			{
				ifs.read(buf.get(),1024*1024);
				result.process_block(buf.get(), buf.get() + ifs.gcount());
				sha.process_block(buf.get(), buf.get() + ifs.gcount());
			}
			unsigned int digest[5] = {0};
			sha.get_digest(digest);
			char all_dig[24] = {0};
			((int*)all_dig)[0] = result.checksum();
			for(int i=0;i<5;++i)
			{
				std::string tmp = NetByte<int>(digest[i]).toString();
				std::copy(tmp.begin(),tmp.end(),all_dig+(1+i)*4);
			}
			std::string retVal = txtconv::convert_to_base64(std::string(all_dig,sizeof(all_dig)));
			boost::replace_all(retVal,"+","_");
			boost::replace_all(retVal,"/","-");
			boost::replace_all(retVal,"=","");
			return retVal;
		}
		void get_uri_helper(std::string filename, boost::function<void(std::string)> callback)
		{
			callback(get_uri(filename));
		}
	}
	std::string get_digist(std::string const& info)
	{
		boost::crc_32_type result;
		boost::uuids::detail::sha1 sha;
		boost::shared_array<char> buf(new char[1024*1024]);
		result.process_bytes((void const *)info.c_str(), info.size());
		sha.process_bytes((void const *)info.c_str(),info.size());
		unsigned int digest[5] = {0};
		sha.get_digest(digest);
		char all_dig[24] = {0};
		((int*)all_dig)[0] = result.checksum();
		for(int i=0;i<5;++i)
		{
			std::string tmp = NetByte<int>(digest[i]).toString();
			std::copy(tmp.begin(),tmp.end(),all_dig+(1+i)*4);
		}
		std::string retVal = txtconv::convert_to_base64(std::string(all_dig,sizeof(all_dig)));
		boost::replace_all(retVal,"+","_");
		boost::replace_all(retVal,"/","-");
		boost::replace_all(retVal,"=","");
		return retVal;
	}

	std::string get_uri(std::string const& filename)
	{
		if(!epfilesystem::instance().file_exists(filename))return "";
#ifdef _WIN32
		std::ifstream ifs(UTF2WS(filename), std::ios::binary);
#else
		std::ifstream ifs(filename.c_str(), std::ios::binary);
#endif
		std::string content_uri =  get_digist(ifs);
		return content_uri + epfilesystem::instance().file_extension(filename);
	}

	void async_get_uri( std::string filename, boost::function<void(std::string)> callback )
	{
		one_pool::instance().schedule(boost::bind(&get_uri_helper, filename, callback));
	}

}