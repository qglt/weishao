#include <base/eipc/eipc_rpc.h>
#include <map>
#include <vector>
#include <set>
#include <boost/tuple/tuple.hpp>
#include <base/interprocess/managed_shared_memory.hpp>
#include <base/interprocess/containers/vector.hpp>
#include <base/interprocess/allocators/allocator.hpp>
#include <base/interprocess/ipc/message_queue.hpp>
#include <base/thread/time_thread/time_thread.h>
#include <base/utility/uuid/uuid.hpp>
#include <base/cmd_factory/cmd_factory.h>
#include <base/txtutil/txtutil.h>

namespace epius
{
	using namespace boost::interprocess;
	using namespace std;
	struct shm_remove  
	{  
		typedef boost::interprocess::allocator<char, managed_shared_memory::segment_manager>  ShmemAllocator;
		typedef boost::interprocess::vector<char, ShmemAllocator> MyVector;
		shm_remove(std::string shm_name):shm_name_(shm_name)
		{
			std::string old_tunnel_name = get_dest_process_real_name(shm_name);
			if(!old_tunnel_name.empty())
			{
				boost::interprocess::message_queue::remove(old_tunnel_name.c_str());
			}
			msg_queue_name_ = shm_name + "_" + gen_uuid();
			shared_memory_object::remove(shm_name.c_str());
			permissions perms;
			perms.set_unrestricted();
			eipc_rpc::instance().eipc_log_(boost::str(boost::format("try to create tunnel for process %s, amd tunnel name is %s")%shm_name%msg_queue_name_));
			managed_shared_memory segment(create_only, shm_name.c_str(), 65536, 0, perms);
			const ShmemAllocator alloc_inst (segment.get_segment_manager());
			MyVector *myvector = segment.construct<MyVector>("process_name")(alloc_inst);
			for(unsigned int i = 0; i < msg_queue_name_.size(); ++i)  //Insert data in the vector  
			{
				myvector->push_back(msg_queue_name_.at(i));
			}
		}
		~shm_remove()
		{
			eipc_rpc::instance().eipc_log_(boost::str(boost::format("will delete process %s and its tunnel %s")%shm_name_%msg_queue_name_));
			shared_memory_object::remove(shm_name_.c_str()); 
			boost::interprocess::message_queue::remove(msg_queue_name_.c_str());
		}

		std::string get_dest_process_real_name(std::string process_name)
		{
			if(process_real_name_.find(process_name)!=process_real_name_.end())
				return process_real_name_[process_name];
			eipc_rpc::instance().eipc_log_(boost::str(boost::format("try to get current tunnel for process %s, from get_dest_process_real_name")%process_name));
			return update_dest_process_real_name(process_name);
		}
		void found_valid_process_tunnel(std::string process_name)
		{
			auto it = obsolete_process_name_.find(process_name);
			if(it != obsolete_process_name_.end())
			{
				if(it->second.size()>0)
				{
					std::string tunnel_name = get_process_tunnel(process_name);
					if(!tunnel_name.empty())
					{
						std::for_each(it->second.begin(),it->second.end(),[=](std::string tmp_tunnel_name){
							if(tmp_tunnel_name != tunnel_name)
							{
								boost::interprocess::message_queue::remove(tmp_tunnel_name.c_str());
							}
						});
					}
				}
				obsolete_process_name_.erase(process_name);
			}
		}
		std::string get_process_tunnel(std::string process_name)
		{
			try
			{
				managed_shared_memory segment(open_only, process_name.c_str());  
				MyVector *myvector = segment.find<MyVector>("process_name").first;
				std::string real_name;
				if(myvector)
				{
					std::copy(myvector->begin(),myvector->end(),back_inserter(real_name));
				}
				return real_name;
			}
			catch(...)
			{
				eipc_rpc::instance().eipc_log_(boost::str(boost::format("try to get tunnel for %s, and failed on construct myvector")%process_name));
				return "";
			}
		}
		std::string update_dest_process_real_name(std::string process_name)
		{
			if(process_real_name_.find(process_name)!=process_real_name_.end())
			{
				std::string real_name = process_real_name_[process_name];
				eipc_rpc::instance().eipc_log_(boost::str(boost::format("dest process is %s, real name is %s, and the tunnel is not ready")%process_name%real_name));
				obsolete_process_name_[process_name].insert(real_name);
				process_real_name_.erase(process_name);
				return "";
			}
			else
			{
				std::string real_name = get_process_tunnel(process_name);
				if(real_name.empty())return "";
				if(obsolete_process_name_[process_name].find(real_name)!=obsolete_process_name_[process_name].end())
				{
					eipc_rpc::instance().eipc_log_(boost::str(boost::format("try to send to %s, and got tunnel name %s, but its obsolete")%process_name%real_name));
					real_name = "";
				}
				else
				{
					process_real_name_[process_name] = real_name;
					eipc_rpc::instance().eipc_log_(boost::str(boost::format("try to get tunnel for %s, and got %s")%process_name%real_name));
				}
				return real_name;
			}
		}
		std::map<std::string, std::string> process_real_name_;//process_name, process_real_name
		std::map<std::string, std::set<std::string> > obsolete_process_name_;//key is process name, std::set is obsolete queue names for process
		std::string shm_name_;
		std::string msg_queue_name_;
	};
	class sender_info
	{
	public:
		sender_info(boost::shared_ptr<shm_remove> shm_holder):shm_holder_(shm_holder){}
		void add_data(string package_id, string pack_data)
		{
			all_pack_data_.push_back(boost::make_tuple(package_id, pack_data, 0));
		}
		bool remove_data(string package_id)
		{
			for(std::vector<boost::tuple<string, string, int> >::iterator it = all_pack_data_.begin();it!=all_pack_data_.end();++it)
			{
				if(it->get<0>()==package_id)
				{
					all_pack_data_.erase(it);
					return true;
				}
			}
			return false;
		}
		bool send_data(std::string dest_process);
	private:
		std::vector<boost::tuple<string, string, int> > all_pack_data_;
		boost::shared_ptr<shm_remove> shm_holder_;
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
	public:
		~eipc_rpc_impl()
		{
			
		}
	private:
		void recv_package(string one_pak)
		{
			json::jobject jobj(one_pak);
			string pak_id = jobj["package_id"].get<string>();
			if(all_packages_[pak_id].add_one_pack(jobj))
			{
				json::jobject cmd_obj = all_packages_[pak_id].get_pack_cmd();
				if(cmd_obj["rpc_type"]&&cmd_obj["rpc_type"].get<string>()=="response")
				{
					//we got response
					std::string come_from = cmd_obj["callback"]["to"].get<std::string>();
					shm_holder_->found_valid_process_tunnel(come_from);
					cmd_handler_.callback(cmd_obj);
				}
				else
				{
					std::string come_from = cmd_obj["from"].get<std::string>();
					shm_holder_->found_valid_process_tunnel(come_from);
					cmd_handler_.exec_cmd(cmd_obj);
				}
				all_packages_.erase(pak_id);
			}
		}
		void do_send_package()
		{
			if(is_eipc_rpc_stoped())return;
			if(all_output_msgs_.empty())return;
			std::map<std::string, boost::shared_ptr<sender_info> >::iterator it = all_output_msgs_.begin();
			for(;it!=all_output_msgs_.end();)
			{
				if(!it->second || it->second->send_data(it->first))
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
				will_send_data_by_timer_ = true;
				rpc_thread_->set_timer(500,boost::bind(&eipc_rpc_impl::do_send_package,this));
			}
			else
			{
				will_send_data_by_timer_ = false;
			}
		}
	public:
		boost::shared_ptr<message_queue> msg_queue_;//msg queue for owner instance
		boost::shared_ptr<time_thread> rpc_thread_;
		cmd_factory_impl cmd_handler_;				//to handle cmd register and dispatch
		std::map<std::string, package_info> all_packages_; //all packages received from different process
		std::map<std::string, boost::shared_ptr<sender_info> > all_output_msgs_;//all packages prepared to send out
		bool stop_eipc_;
		bool will_send_data_by_timer_;
		static const int one_msg_len_ = 4096;
		boost::shared_ptr<shm_remove> shm_holder_;
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
			try
			{
				while(msg_queue_->try_receive((void*) &buffer, sizeof(buffer), recvd_size, priority))
				{
					//received package is a json string, will contain {package_id:"", pack_finish:true/false,curr_seq:"",pack_data:""}
					//and, all pack_datas will be an json string, will contain {method:"",args:{},callback:{id:"",from:""}}
					string trunk_pack = buffer;
					eipc_rpc::instance().eipc_log_("receive:" + trunk_pack);
					recv_package(trunk_pack);
				}
			}
			catch(interprocess_exception const& e)
			{
				wchar_t wbuffer[1000] = {0};
				char* curr_local = setlocale(LC_CTYPE,"chs");
				int len = mbstowcs( wbuffer, e.what(), 1000 );
				eipc_rpc::instance().eipc_log_("recieve_data fail:" + WS2UTF(wbuffer));
				setlocale(LC_CTYPE,curr_local);
			}
			rpc_thread_->set_timer(100,boost::bind(&eipc_rpc_impl::start_recv_msg,this));
		}
		void init( std::string my_process_name )
		{
			shm_holder_.reset(new shm_remove(my_process_name));
			permissions perms;
			perms.set_unrestricted();
			msg_queue_.reset(new message_queue(open_or_create, shm_holder_->msg_queue_name_.c_str(), 10, one_msg_len_, perms));
			rpc_thread_.reset(new time_thread);
			stop_eipc_ = false;
			will_send_data_by_timer_ = false;
		}
		void add_listener(std::string event_name, boost::function<void(json::jobject)> env_handler)
		{
			cmd_handler_.register_cmd(event_name,env_handler);
		}
		string async_call( std::string dst_process, json::jobject jobj )
		{
			string send_data = jobj.to_string();
			string package_id = gen_uuid();
			if(all_output_msgs_.find(dst_process)!=all_output_msgs_.end() && all_output_msgs_[dst_process])
			{
				all_output_msgs_[dst_process]->add_data(package_id, send_data);
			}
			else
			{
				boost::shared_ptr<sender_info> tmp_info(new sender_info(shm_holder_));
				tmp_info->add_data(package_id, send_data);
				all_output_msgs_[dst_process] = tmp_info;
			}
			if(!will_send_data_by_timer_)
			{
				do_send_package();
			}
			return package_id;
		}
		void time_call_wrapper(std::string dst_process, boost::tuple<string,string> package_send, boost::function<void()> fail_cmd)
		{
			//check if the package is sent first, if yes, then check if the response already come.
			if(all_output_msgs_.find(dst_process)!=all_output_msgs_.end() && all_output_msgs_[dst_process] && all_output_msgs_[dst_process]->remove_data(package_send.get<0>()))
			{
				eipc_rpc::instance().eipc_log_("command has not be sent out");
				if(shm_holder_)shm_holder_->update_dest_process_real_name(dst_process);
				fail_cmd();
				return;
			}
			if(cmd_handler_.remove_callback(package_send.get<1>()))
			{
				eipc_rpc::instance().eipc_log_("command has no callback so fail.");
				if(shm_holder_)shm_holder_->update_dest_process_real_name(dst_process);
				fail_cmd();
				return;
			}
		}
		void timed_async_call( std::string dst_process, json::jobject jobj,boost::function<void(json::jobject)> callback, int timeout_ms, boost::function<void()> fail_cmd )
		{
			boost::tuple<string,string> send_info = async_call(dst_process, jobj, callback);
			rpc_thread_->set_timer(timeout_ms, boost::bind(&eipc_rpc_impl::time_call_wrapper,this, dst_process, send_info, fail_cmd));
		}
		boost::tuple<string,string> async_call( std::string dst_process, json::jobject jobj, boost::function<void(json::jobject)> callback )
		{
			string callback_id;
			if(!callback.empty())
			{
				callback_id = gen_uuid();
				jobj["callback_id"] = callback_id;
				if(shm_holder_)jobj["callback"]["from"] = shm_holder_->shm_name_;
				jobj["callback"]["to"] = dst_process;
				cmd_handler_.register_callback(callback_id, callback);
			}
			else
			{
				if(shm_holder_)jobj["from"] = shm_holder_->shm_name_;
			}
			string package_id = async_call(dst_process,jobj);
			return boost::make_tuple(package_id,callback_id);
		}
	};

	bool sender_info::send_data(std::string dest_process)
	{
		if(all_pack_data_.empty())return true;
		//get real dest_process name
		if(!shm_holder_) return false;
		std::string real_process_name = shm_holder_->get_dest_process_real_name(dest_process);
		if(real_process_name.empty()) return false;
		boost::shared_ptr<message_queue> send_mq;
		try
		{
			boost::shared_ptr<message_queue> tmp_queue(new message_queue(open_only, real_process_name.c_str()));
			send_mq = tmp_queue;
		}
		catch(interprocess_exception const&)
		{
			eipc_rpc::instance().eipc_log_(boost::str(boost::format("will update tunnel name because open %s failed")%real_process_name));
			shm_holder_->update_dest_process_real_name(dest_process);
			return false;
		}
		do{
			if(all_pack_data_.empty())break;
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
			boost::posix_time::ptime expires = boost::posix_time::microsec_clock::universal_time() + boost::posix_time::milliseconds(2000);
			if(send_mq->timed_send(buf,sizeof(buf),0,expires))
			{
				eipc_rpc::instance().eipc_log_("sendout:" + send_pack);
				all_pack_data_.erase(all_pack_data_.begin());
			}
			else
			{
				eipc_rpc::instance().eipc_log_(boost::str(boost::format("will update tunnel name because send message timeout to tunnel %s failed")%real_process_name));
				shm_holder_->update_dest_process_real_name(dest_process);
				break;
			}
		}while(true);
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

	void eipc_rpc_interface::timed_async_call( std::string dst_process, json::jobject jobj, boost::function<void(json::jobject)> callback, int timeout_ms, boost::function<void()> fail_cmd )
	{
		impl_->rpc_thread_->post(boost::bind(&eipc_rpc_impl::timed_async_call,impl_,dst_process,jobj,callback,timeout_ms,fail_cmd));
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
			jobj["rpc_type"] = "response";
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
