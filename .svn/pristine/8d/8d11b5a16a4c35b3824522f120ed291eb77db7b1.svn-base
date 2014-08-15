#include <base/config/configure.hpp>
#include <base/utility/singleton/singleton.hpp>
#include <boost/shared_ptr.hpp>
#include <base/json/tinyjson.hpp>

namespace epius
{
	class lua_mgr_decl
	{
		template<class> friend struct boost::utility::singleton_holder;
		class lua_mgr_impl;
		boost::shared_ptr<lua_mgr_impl> impl_;
		lua_mgr_decl();
	public:
		void init(std::string const& root_path);
		void init(void* L);
		bool load_engine(std::string file_path);
		bool exec_cmd(std::string method_name, json::jobject jobj);
		void add_lua_log(boost::function<void(json::jobject)> cmd);
		void log(json::jobject jobj);
	};
	typedef boost::utility::singleton_holder<lua_mgr_decl> lua_mgr;
}