#include <lua_ext/lua_all.h>
#include <base/json/tinyjson.hpp>
#include <string>

namespace epius{
	class lua_json
	{
	public:
		lua_json();
		json::jobject from_lua_obj(luabind::object const& obj);
		std::string encode(luabind::object const& obj,lua_State* lstate);
		luabind::object to_lua_obj(json::jobject jobj, lua_State* lstate);
		luabind::object decode(std::string str,lua_State* lstate);
	};
}