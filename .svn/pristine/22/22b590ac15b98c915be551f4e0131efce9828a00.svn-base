#include <lua_ext/lua_json.h>

using namespace boost;
using namespace std;
using namespace luabind;
using namespace epius;

namespace epius
{

lua_json::lua_json()
{

}

json::jobject lua_json::from_lua_obj( luabind::object const& obj )
{
	boost::shared_ptr<boost::function<json::jobject(luabind::object const&)> > copy_cmd(new boost::function<json::jobject(luabind::object const&)>);
	*copy_cmd = [=](luabind::object const& obj) ->json::jobject
	{
		json::jobject jobj;
		if(luabind::type(obj)==LUA_TTABLE)
		{
			int curr_type = 0;//0 unknown, 1 is array, 2 is object
			for( luabind::iterator i( obj ), end; i != end; ++i )
			{
				luabind::object key = i.key();
				if ( luabind::type( key ) == LUA_TNUMBER )
				{
					if(curr_type==0)curr_type = 1;
					else if(curr_type!=1)break;
					int index = object_cast<int>(key);
					json::jobject tmpObj = (*copy_cmd)(*i);
					jobj[index-1] = tmpObj;
				}
				else if ( luabind::type( key ) == LUA_TSTRING )
				{
					if(curr_type==0)curr_type = 2;
					else if(curr_type!=2)break;
					std::string mykey = object_cast<std::string>(key);
					json::jobject tmpObj = (*copy_cmd)(*i);
					jobj[mykey] = tmpObj;
				}
				else if( luabind::type( key ) == LUA_TFUNCTION )
				{
					std::string mykey = object_cast<std::string>(key);
					jobj[mykey] = "[LUA function object]";
				}
				else
				{
					cout<<"error object"<<endl;
				}
			}
		}
		else
		{
			int objtype = luabind::type( obj );
			switch(objtype)
			{
			case LUA_TNIL:break;
			case LUA_TBOOLEAN:jobj = object_cast<bool>(obj);break;
			case LUA_TNUMBER:jobj = object_cast<double>(obj);break;
			case LUA_TSTRING:jobj = object_cast<std::string>(obj);break;
			case LUA_TFUNCTION:jobj = "[LUA function object]";
			default:
				cout<<"error elem"<<endl;
			}
		}
		return jobj;
	};
	json::jobject jobj = (*copy_cmd)(obj);
	return jobj;
}

std::string lua_json::encode( luabind::object const& obj,lua_State* lstate )
{
	json::jobject jobj = from_lua_obj(obj);
	return jobj.to_string();
}

luabind::object lua_json::to_lua_obj( json::jobject jobj, lua_State* lstate )
{
	luabind::object obj = newtable( lstate );
	if(!jobj)return obj;
	boost::shared_ptr<boost::function<void(json::jobject, luabind::object&)> >copy_cmd(new boost::function<void(json::jobject, luabind::object&)>);
	*copy_cmd = [=](json::jobject jobj, luabind::object& obj) mutable{
		if(jobj.is_array())
		{
			boost::function<void(json::jobject)> copy_array = [&](json::jobject tmp) mutable{
				if(tmp.is_array() || tmp.is_object())
				{
					luabind::object tmpobj = newtable( lstate );
					(*copy_cmd)(tmp,tmpobj);
					settable(obj,obj_size(obj)+1,tmpobj);
				}
				else if(tmp)
				{
					settable(obj,obj_size(obj)+1,tmp.get<std::string>());
				}
			};
			jobj.each(copy_array);
		}
		else if(jobj.is_object())
		{
			boost::function<void(std::string,json::jobject)> copy_obj = [&](std::string key, json::jobject tmp) mutable{
				if(tmp.is_array() || tmp.is_object())
				{
					luabind::object tmpobj = newtable( lstate );
					(*copy_cmd)(tmp,tmpobj);
					settable(obj,key,tmpobj);
				}
				else if(tmp)
				{
					settable(obj,key,tmp.get<std::string>());
				}
			};
			jobj.each(copy_obj);
		}
		else
		{
			luabind::object tmp = luabind::object(lstate, jobj.get<std::string>());
			
			obj.swap(tmp);
		}
	};
	(*copy_cmd)(jobj,obj);
	return obj;
}

luabind::object lua_json::decode( std::string str,lua_State* lstate )
{
	json::jobject jobj(str);
	return to_lua_obj(jobj, lstate);
}

}
