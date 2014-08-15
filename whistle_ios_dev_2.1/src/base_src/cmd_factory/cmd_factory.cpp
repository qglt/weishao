#include "base/cmd_factory/cmd_factory.h"
#include <base/log/elog/elog.h>
#include <base/utility/uuid/uuid.hpp>
#include <base/lua/lua_ext/lua_mgr.h>

using namespace std;
cmd_factory_impl::cmd_factory_impl()
{

}

void cmd_factory_impl::register_cmd( std::string funName, boost::function<void(json::jobject)> cmd )
{
	if(!m_aligner.is_in_expect_thread())
	{
		m_aligner.post(boost::bind(&cmd_factory_impl::register_cmd, this, funName, cmd));
		return;
	}
    m_cmds[funName] = cmd;
}

void cmd_factory_impl::callback( json::jobject jobj )
{
	if(!m_aligner.is_in_expect_thread())
	{
		m_aligner.post(boost::bind(&cmd_factory_impl::callback, this, jobj));
		return;
	}
	std::string callback_id;
	if(!jobj.is_nil("callback_id"))
	{
		callback_id = jobj["callback_id"].get<std::string>();
	}
	else if(!jobj.is_nil("aux") && !jobj["aux"].is_nil("from"))
	{
		callback_id = jobj["aux"]["from"].get<std::string>();
		jobj["aux"]["action"] = "callback";
	}
	if(!callback_id.empty())
    {
        if(m_callbacks.find(callback_id)==m_callbacks.end())
        {
            return;
        }
        m_callbacks[callback_id](jobj);
        m_callbacks.erase(callback_id);
    }
}

bool cmd_factory_impl::exec_cmd_direct( json::jobject jobj )
{
	if(!jobj)return false;
	std::string method_name;
	if(!jobj.is_nil("method"))
	{
		method_name = jobj["method"].get<std::string>();
	}
	else if(!jobj.is_nil("aux") && !jobj["aux"].is_nil("to"))
	{
		method_name = jobj["aux"]["to"].get<std::string>();
	}
    if(!method_name.empty())
    {
        if(m_cmds.find(method_name)!=m_cmds.end())
        {
            m_cmds[method_name](jobj);
			return true;
        }
		else if(epius::lua_mgr::instance().exec_cmd(method_name,jobj))
		{
			return true;
		}
    }
	return false;
}

void cmd_factory_impl::exec_cmd( json::jobject jobj )
{
	if(!m_aligner.is_in_expect_thread())
	{
		m_aligner.post(boost::bind(&cmd_factory_impl::exec_cmd, this, jobj));
		return;
	}
	exec_cmd_direct(jobj);
}

void cmd_factory_impl::exec_cmd( json::jobject jobj, boost::function<void(json::jobject)> cmd )
{
	if(!m_aligner.is_in_expect_thread())
	{
		m_aligner.post(boost::bind(&cmd_factory_impl::exec_cmd, this, jobj, cmd));
		return;
	}
	std::string uuid_str = epius::gen_uuid();
	jobj["callback_id"] = uuid_str;
	register_callback(uuid_str,cmd);
	exec_cmd(jobj);
}

void cmd_factory_impl::register_callback(std::string funName, boost::function<void(json::jobject)> cmd)
{
	if(!m_aligner.is_in_expect_thread())
	{
		m_aligner.post(boost::bind(&cmd_factory_impl::register_callback, this, funName, cmd));
		return;
	}
    if(funName.empty())return;
    m_callbacks[funName] = cmd;
}

void cmd_factory_impl::set_thread_align( epius::thread_align aligner )
{
	m_aligner = aligner;
}

bool cmd_factory_impl::remove_callback( std::string funName )
{
	if(!m_aligner.is_in_expect_thread())
	{
		m_aligner.post(boost::bind(&cmd_factory_impl::remove_callback, this, funName));
		return false;
	}
	if(m_callbacks.find(funName)!=m_callbacks.end())
	{
		m_callbacks.erase(funName);
		return true;
	}
	return false;
}
