#pragma once
#include <base/config/configure.hpp>
#include <base/json/tinyjson.hpp>
#include <base/utility/singleton/singleton.hpp>
#include <base/universal_res/uni_res.h>
#include <boost/shared_ptr.hpp>
#include <map>
#include "anan_type.h"
#include <base/thread/time_thread/time_thread.h>
#include "anan_biz_bind.h"
#include "anan_biz_impl.h"
#include "base/tcpproactor/TcpProactor.h"

namespace biz
{
	class file_transfer_manager
	{
		template<class> friend struct boost::utility::singleton_holder;

	public:
		void init();
		void send_file_to(std::string filename, std::string uid, std::string jid, boost::function<void(bool,universal_resource,std::string)> callback, bool resumable );
		void upload_file_cb( boost::function<void(bool,universal_resource,std::string)> callback, std::string jid, std::string filename, time_t starttime, bool succ, std::string result );
		void send_file_msg_cb(boost::function<void(bool,universal_resource,std::string)> callback, std::string result, bool check_succ, std::string uid, boost::uintmax_t filesize, json::jobject jobj_msg, bool err, universal_resource reason);		
		void download_file(std::string filename, boost::uintmax_t filesize, std::string relative_path, std::string uri, std::string uid, boost::function<void(bool,universal_resource,std::string)> callback);
		void download_file_cb(boost::function<void(bool,universal_resource,std::string)> callback, time_t starttime, std::string filename, bool succ, std::string result);
		void cancel_transfer_file(std::string uid);
		bool is_file_trans_canceled(std::string uid);
		void insert_cancle_trans_file_map(std::string uid);
		void set_biz_bind_impl(anan_biz_impl* impl);
		void cancel_all_transfer_file();
		void check_file_on_server_cb(std::string filename, std::string uri, std::string uid, std::string jid, bool resumable, boost::function<void(bool,universal_resource,std::string)> callback, bool succ, std::string response);
		boost::function<void(int)> get_common_progress_callback(std::string uid ,std::string uri);
		boost::function<void(int)> get_common_progress_callback(std::string trans_type, std::string uid ,std::string uri, std::string jid);

	private:
		anan_biz_impl*	get_parent_impl() { return anan_biz_impl_;};
		anan_biz_impl*	anan_biz_impl_;
		std::map<std::string,bool> cancle_trans_file_map_;

	private:
		void do_send_file_to( std::string filename, std::string uri, std::string uid, std::string jid, boost::function<void(bool,universal_resource,std::string)> callback, bool resumable );
	};


	typedef boost::utility::singleton_holder<file_transfer_manager> file_transfer;
}