#include "eipc_rpc.h"
#include <map>
#include <vector>
#include <boost/tuple/tuple.hpp>
#include <boost/interprocess/ipc/message_queue.hpp>
#include <base/thread/time_thread/time_thread.h>
#include <base/utility/uuid/uuid.hpp>
#include <base/cmd_factory/cmd_factory.h>

namespace epius
{
	using namespace boost::interprocess;
	using namespace std;
	class sender_info
	{
	public:
		void set_msg_queue(boost::shared_ptr<message_queue> mq){send_mq_ = mq;}
		void add_data(string package_id, string pack_data)
		{
			all_pack_data_.push_back(boost::make_tuple(package_id, pack_data, 0));
		}
		bool send_data();
	private:
		boost::shared_ptr<message_queue> send_mq_;
		vector<boost::tuple<string, string, int> > all_pack_data_;
	};
	class package_info
	{
	public:
		bool add_one_pack(json::jobject jobj)
		{
			bool bpack_fin = jobj["pack_finish"].get<bool>();
			seq_packs_[jobj["curr_seq"].get<int>()] = jobj["pack_data"].get<string>();
			if(jobj["pack_finish"] && jobj["pack_finish"].get<bool>())return true;
			return false;
		}
		json::jobject get_pack_cmd()
		{
			string entire_pack;
			for(map<int,string>::iterator it = seq_packs_.begin();it!=seq_packs_.end();++it)
			{
				entire_pack += it->second;
			}
			return json::jobject(entire_pack);
		}
	private:
		bool is_pack_ready();
	private:
		map<int,string> seq_packs_;
	};
	class eipc_rpc_interface::eipc_rpc_impl
	{
		void recv_package(string one_pak)
		{
			json::jobject jobj(one_pak);
			string pak_id = jobj["package_id"].get<string>();
			if(all_packages_[pak_id].add_one_pack(jobj))
			{
				json::jobject cmd_obj = all_packages_[pak_id].get_pack_cmd();
				cmd_handler_.exec_cmd(cmd_obj);
				all_packages_.erase(pak_id);
			}
		}
		void do_send_package()
		{
			if(is_eipc_rpc_stoped())return;
			if(all_output_msgs_.empty())return;
			std::map<std::string, sender_info>::iterator it = all_output_msgs_.begin();
			for(;it!=all_output_msgs_.end();)
			{
				if(it->second.send_data())
				{
					it = all_output_msgs_.erase(it);
				}
				else
				{
					it++;
				}
			}
			if(!all_output_msgs_.empty())
			{
				rpc_thread_->set_timer(100,boost::bind(&eipc_rpc_impl::do_send_package,this));
			}
		}
	public:
		boost::shared_ptr<message_queue> msg_queue_;//msg queue for owner instance
		std::string process_name_;
		boost::shared_ptr<time_thread> rpc_thread_;
		cmd_factory_impl cmd_handler_;				//to handle cmd register and dispatch
		std::map<std::string, package_info> all_packages_; //all packages received from different process
		std::map<std::string, sender_info> all_output_msgs_;//all packages prepared to send out
		bool stop_eipc_;
		static const int one_msg_len_ = 1024;
		void stop_eipc_rpc()
		{
			stop_eipc_ = true;
		}
		bool is_eipc_rpc_stoped()
		{
			return stop_eipc_;
		}
		void start_recv_msg()
		{
			if(is_eipc_rpc_stoped())return;
			size_t recvd_size; 
			unsigned int priority; 
			char buffer[one_msg_len_] = {0};
			while(msg_queue_->try_receive((void*) &buffer, sizeof(buffer), recvd_size, priority))
			{
				//received package is a json string, will contain {package_id:"", pack_finish:true/false,curr_seq:"",pack_data:""}
				//and, all pack_datas will be an json string, will contain {method:"",args:{},callback:{id:"",from:""}}
				string trunk_pack = buffer;
				eipc_rpc::instance().eipc_log_("receive:" + trunk_pack);
				recv_package(trunk_pack);
			}
			rpc_thread_->set_timer(100,boost::bind(&eipc_rpc_impl::start_recv_msg,this));
		}
		void init( std::string my_process_name )
		{
			process_name_ = my_process_name;
			permissions perms;
			perms.set_unrestricted();
			msg_queue_.reset(new message_queue(open_or_create, my_process_name.c_str(), 10, one_msg_len_, perms));
			rpc_thread_.reset(new time_thread);
			stop_eipc_ = false;
		}
		void add_listener(std::string event_name, boost::function<void(json::jobject)> env_handler)
		{
			cmd_handler_.register_cmd(event_name,env_handler);
		}
		void async_call( std::string dst_process, json::jobject jobj )
		{
			string send_data = jobj.to_string();
			string package_id = gen_uuid();
			if(all_output_msgs_.find(dst_process)!=all_output_msgs_.end())
			{
				all_output_msgs_[dst_process].add_data(package_id, send_data);
			}
			else
			{
				try
				{
					sender_info tmp_info;
					permissions perms;
					perms.set_unrestricted();
					boost::shared_ptr<message_queue> tmp_queue(new message_queue(open_or_create, dst_process.c_str(), 10,  eipc_rpc_interface::eipc_rpc_impl::one_msg_len_, perms));
					tmp_info.set_msg_queue(tmp_queue);
					tmp_info.add_data(package_id, send_data);
					all_output_msgs_[dst_process] = tmp_info;
				}
				catch(interprocess_exception &ex)
				{
					eipc_rpc::instance().eipc_log_(ex.what());
					return;
				}
			}
			do_send_package();
		}
		void async_call( std::string dst_process, json::jobject jobj, boost::function<void(json::jobject)> callback )
		{
			if(!callback.empty())
			{
				string callback_id = gen_uuid();
				jobj["callback"]["id"] = callback_id;
				jobj["callback"]["from"] = process_name_;
				cmd_handler_.register_cmd(callback_id, callback);
			}
			async_call(dst_process,jobj);
		}
	};

	bool sender_info::send_data()
	{
		if(all_pack_data_.empty())return true;
		string pack_id, pack_data;
		int seq_id;
		boost::tie(pack_id,pack_data,seq_id) = *all_pack_data_.begin();
		json::jobject jobj;
		jobj["package_id"] = pack_id;
		jobj["pack_finish"] = true;
		jobj["pack_data"] = pack_data;
		jobj["curr_seq"] = seq_id;
		string send_pack = jobj.to_string();
		char buf[eipc_rpc_interface::eipc_rpc_impl::one_msg_len_] = {0};
		copy(send_pack.begin(),send_pack.end(),buf);
		if(send_mq_->try_send(buf,sizeof(buf),0))
		{
			eipc_rpc::instance().eipc_log_("sendout:" + send_pack);
			all_pack_data_.erase(all_pack_data_.begin());
		}
		if(all_pack_data_.empty())return true;
		return false;
	}


	void eipc_rpc_interface::init( std::string my_process_name )
	{
		impl_->init(my_process_name);
	}

	void eipc_rpc_interface::async_call( std::string dst_process, json::jobject jobj, boost::function<void(json::jobject)> callback )
	{
		impl_->rpc_thread_->post(boost::bind(&eipc_rpc_impl::async_call,impl_,dst_process,jobj,callback));
	}

	eipc_rpc_interface::eipc_rpc_interface():impl_(new eipc_rpc_interface::eipc_rpc_impl)
	{
	}

	void eipc_rpc_interface::on( std::string method_name, boost::function<void(json::jobject)> env_handler )
	{
		impl_->rpc_thread_->post(boost::bind(&eipc_rpc_impl::add_listener,impl_,method_name,env_handler));
	}

	void eipc_rpc_interface::callback( json::jobject jobj )
	{
		if(jobj["callback"])
		{
			jobj["method"] = jobj["callback"]["id"].get<string>();
			string dst_process = jobj["callback"]["from"].get<string>();
			async_call(dst_process, jobj);
		}
	}

	void eipc_rpc_interface::start()
	{
		eipc_rpc::instance().eipc_log_("server ipc is started");
		impl_->rpc_thread_->post(boost::bind(&eipc_rpc_impl::start_recv_msg,impl_));
	}

	void eipc_rpc_interface::stop()
	{
		eipc_rpc::instance().eipc_log_("server ipc is stopped");
		impl_->rpc_thread_->post(boost::bind(&eipc_rpc_impl::stop_eipc_rpc,impl_));
		impl_->rpc_thread_->stop();
	}

	void eipc_rpc_interface::set_timer(int ms, boost::function<void()> cmd )
	{
		impl_->rpc_thread_->set_timer(ms, cmd);
	}

	act_post_cmd eipc_rpc_interface::get_post_cmd()
	{
		return impl_->rpc_thread_->get_post_cmd();
	}

	void eipc_rpc_interface::post( boost::function<void()> cmd )
	{
		impl_->rpc_thread_->post(cmd);
	}

}
