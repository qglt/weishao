#pragma once
#include <string>
#include <base/config/configure.hpp>
#include <base/json/tinyjson.hpp>
#include <base/utility/singleton/singleton.hpp>
#include <base/cmd_wrapper/command_wrapper.h>

namespace epius
{
	class eipc_rpc_interface
	{
	public:
		class eipc_rpc_impl;
		eipc_rpc_interface();
		void start();
		void stop();
		void init(std::string my_process_name);
		//jobj for async_call is in such format: {method:"", args:{}}
		void set_timer(int ms, boost::function<void()> cmd);
		void async_call(std::string dst_process, json::jobject jobj, boost::function<void(json::jobject)> callback = boost::function<void(json::jobject)>());
		void timed_async_call(std::string dst_process, json::jobject jobj, boost::function<void(json::jobject)> callback, int timeout_ms, boost::function<void()> fail_cmd);
		//jobj for env_handler: {method:"",args:{},callback:{id:"",from:""}
		void on(std::string method_name, boost::function<void(json::jobject)> env_handler);
		//jobj for callback {callback:{id:"", from:""}, ...}
		void callback(json::jobject jobj);
		void post(boost::function<void()> cmd);
		act_post_cmd get_post_cmd();
		boost::signal<void(std::string)> eipc_log_;
	private:
		boost::shared_ptr<eipc_rpc_impl> impl_;
	};
	typedef boost::utility::singleton_holder<eipc_rpc_interface> eipc_rpc;
}

/************************************************************************/
/* samples to use eipc_rpc
   receiver:  
		void test(json::jobject jobj)
		{
			do_something...
			eipc_rpc::instance().callback(jobj);//if need callabck
		}
		eipc_rpc::instance().init("t1_process")
		eipc_rpc::instance().on("do_test", bind(&test,_1));
		eipc_rpc::instance().start();

	sender:
		void test_callback(json::jobject jobj)
		{
			.....
		}
		eipc_rpc::instance().init("t2_process");
		eipc_rpc::instance().start();
		eipc_rpc::instance().async_call("t1_process",{method:"do_test",args:{...}, bind(&test_callback,_1)});
*/
/************************************************************************/