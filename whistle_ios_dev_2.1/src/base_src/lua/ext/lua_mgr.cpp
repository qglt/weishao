#include <lua_ext/lua_mgr.h>
#include <lua_ext/lua_all.h>
#include <lua_ext/lua_json.h>
#include <base/log/elog/elog.h>
#include <base/cmd_factory/cmd_factory.h>
#include <base/module_path/epfilesystem.h>
#include <iostream>

using namespace luabind;

namespace epius{
	static void callback(luabind::object obj)
	{
		lua_json conv;
		json::jobject jobj = conv.from_lua_obj(obj);
		cmd_factory::instance().callback(jobj);
	}
	static void native_exec(luabind::object obj,luabind::object callback)
	{
		lua_json conv;
		json::jobject jobj = conv.from_lua_obj(obj);
		if(luabind::type(callback) == LUA_TFUNCTION)
		{
			cmd_factory::instance().exec_cmd(jobj, [=](json::jobject jobjtmp) mutable{
				luabind::object callback_arg = conv.to_lua_obj(jobjtmp,obj.interpreter());
				luabind::call_function<void>(callback, callback_arg);
			});
		}
		else
		{
			cmd_factory::instance().exec_cmd(jobj);
		}
	}
	void native_log(luabind::object obj)
	{
		lua_json conv;
		json::jobject jobj = conv.from_lua_obj(obj);
		lua_mgr::instance().log(jobj);
	}

	class lua_mgr_decl::lua_mgr_impl
	{
		friend class lua_mgr_decl;
		lua_State* lstate_;
		bool luaL_new_state;
		boost::shared_ptr<boost::signal<void(json::jobject)> > log_signals_;
	public:
		bool exec_cmd( std::string method_name, json::jobject jobj )
		{
			try{
				epius::lua_json conv;
				bool found_engine = false;
				do 
				{
					luabind::object engine_obj = luabind::globals(lstate_)["ws_engine"];
					if(luabind::type(engine_obj) != LUA_TTABLE) break;
					luabind::object run_obj = engine_obj["exec"];
					if(luabind::type(run_obj) != LUA_TFUNCTION)break;
					return luabind::call_function<bool>(run_obj,method_name,conv.to_lua_obj(jobj,lstate_));
				} while (0);
				ELOG("app")->error("engine.lua is missed");
				return false;
			}catch(luabind::error& e)
			{
				ELOG("app")->error("error when exec " + method_name + " and reason is: " + e.what());
				return false;
			}
		}
		bool load_engine( std::string file_path )
		{
			int ret = luaL_dofile(lstate_, file_path.c_str());
			if(ret)
			{
				ELOG("app")->error("failed to load lua engine");
				return false;
			}
			return true;
		}
		void set_lua_path( lua_State* L, const char* path )
		{
			lua_getglobal( L, "package" );
			lua_pushstring( L, path ); // push the new one
			lua_setfield( L, -2, "path" );
			lua_pop( L, 1 );
		}
		void init(lua_State* l)
		{
			lstate_ = l;
			luaL_new_state = false;
		}
		void init(std::string root_path)
		{
			lstate_ = luaL_newstate();
			lua_pushboolean(lstate_, 1);  /* signal for libraries to ignore env. vars. */
			lua_setfield(lstate_, LUA_REGISTRYINDEX, "LUA_NOENV");
			root_path = epfilesystem::instance().sub_path(root_path, "lua");
			root_path = boost::str(boost::format("%s/;%s/?.lua;%s/?/init.lua")%root_path%root_path%root_path);
			luaopen_base(lstate_);
			lua_gc(lstate_, LUA_GCSTOP, 0);  /* stop collector during initialization */
			luaL_openlibs(lstate_);  /* open libraries */
			lua_gc(lstate_, LUA_GCRESTART, 0);
			luaopen_os(lstate_);
			open(lstate_);
			set_lua_path(lstate_, root_path.c_str());
			module(lstate_,"cpp_api")
				[
					def("callback",&callback),
					def("async_call",&native_exec),
					def("log",&native_log)
				];
		}
		lua_mgr_impl():lstate_(NULL),luaL_new_state(true)
		{
		}
		~lua_mgr_impl()
		{
			if(luaL_new_state&&lstate_)lua_close(lstate_);
		}
		lua_State* Lstate() const { return lstate_; }
	};

	lua_mgr_decl::lua_mgr_decl():impl_(new lua_mgr_decl::lua_mgr_impl)
	{
	}

	void lua_mgr_decl::init(std::string const& root_path)
	{
		impl_->init(root_path);
	}

	void lua_mgr_decl::init( void* L )
	{
		impl_->init((lua_State*)L);
	}

	bool lua_mgr_decl::exec_cmd( std::string method_name, json::jobject jobj )
	{
		return impl_->exec_cmd(method_name, jobj);
	}

	bool lua_mgr_decl::load_engine( std::string file_path )
	{
		return impl_->load_engine(file_path);
	}

	void lua_mgr_decl::add_lua_log( boost::function<void(json::jobject)> cmd )
	{
		if(!impl_->log_signals_)impl_->log_signals_.reset(new boost::signal<void(json::jobject)>);
		impl_->log_signals_->connect(cmd);
	}

	void lua_mgr_decl::log( json::jobject jobj )
	{
		if(impl_->log_signals_)(*impl_->log_signals_)(jobj);
	}

}
