#pragma once

#include <vector>
#include <list>
#include <base/utility/singleton/singleton.hpp>
#include "base/universal_res/uni_res.h"
#include "base/json/tinyjson.hpp"
#include <base/utility/callback_def/callback_define.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/function.hpp>
#include "anan_biz_bind.h"
#include "anan_biz_impl.h"
#include <third_party/threadpool/threadpool.hpp>
#include "base/tcpproactor/TcpProactor.h"
#include "gloox_src/message.h"
#include "gloox_src/messagesession.h"


namespace biz {

	class LightApp 
	{
		template<class> friend struct boost::utility::singleton_holder;
		typedef struct app_info{
			std::string name;				//
			std::string appid;					//
		}app_info;
		json::jobject app_list_info;
	public:
		LightApp ();
		virtual ~LightApp();

		void set_biz_bind_impl(anan_biz_impl* impl);
		void init();
		void connected();
		//向轻应用发送消息
		void handleMessage( const Message& msg, MessageSession* session /*= 0 */ );
		void errorMessage( std::string appid, std::string err_type, std::string is_show);
		void do_handleMessage( const Message& msg, MessageSession* session /*= 0 */ );
		void download_lightapp_resources(std::string url, bool is_uri, boost::function<void(bool err, universal_resource res, std::string local_path)> callback);
		void download_lightapp_resources_cb( bool bsuccess , std::string reason, std::string local_path, boost::function<void(bool err, universal_resource res, std::string local_path)> callback);
		boost::signal< void(json::jobject) > app_icon_update;
		void do_get_lightapp_message();
		void send_lightapp_message(std::string appid , json::jobject msg , Result_Data_Callback callback);	
		void add_image_uri(json::jobject jobj);
		void upload_pic_cb(std::string appid ,json::jobject msg , std::string rowid , std::string msgid, Result_Data_Callback callback ,bool succ,std::string uri);
		void upload_voice_cb(std::string appid ,json::jobject msg , std::string rowid , std::string msgid, Result_Data_Callback callback ,bool succ,std::string uri);
		void can_recv_lightapp_message(Result_Callback callback);	
		std::string safe_get_childcdata(const gloox::Tag* tag_name, std::string name);

		anan_biz_impl*	get_parent_impl() { return anan_biz_impl_;};
		anan_biz_impl*	anan_biz_impl_;
		std::deque<json::jobject>  msg_queue_;
	};

	typedef boost::utility::singleton_holder<LightApp> g_lightapp;
};