#pragma once

#include <map>
#include <boost/function.hpp>
#include <base/config/configure.hpp>
#include <base/utility/singleton/singleton.hpp>
#include <base/json/tinyjson.hpp>
#include <base/thread/thread_align/thread_align.hpp>

class cmd_factory_impl
{
private:
	std::map<std::string, boost::function<void(json::jobject)> >m_cmds;
    std::map<std::string, boost::function<void(json::jobject)> >m_callbacks;
	epius::thread_align m_aligner;
public:
	cmd_factory_impl();
	void set_thread_align(epius::thread_align aligner);
    void callback(json::jobject jobj);
    void register_callback(std::string funName, boost::function<void(json::jobject)>);
	void register_cmd(std::string funName, boost::function<void(json::jobject)> cmd);
	bool remove_callback(std::string funName);
    void exec_cmd(json::jobject jobj);
	bool exec_cmd_direct(json::jobject jobj);
	void exec_cmd(json::jobject jobj, boost::function<void(json::jobject)> cmd);
};
typedef boost::utility::singleton_holder<cmd_factory_impl> cmd_factory;