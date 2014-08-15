//---------------------------------------------------
// Copyright (C) 2012, All rights reserved
//
// descrption: entrypoint file.
// ver: 2.0
// auther: majiazhi
// date: (YMD)2012/07/04
//---------------------------------------------------

#pragma once
#include <string>
#include "boost/shared_ptr.hpp"
#include "boost/function.hpp"
#include "boost/signal.hpp"
#include <base/utility/bind2f/bind2f.hpp>
#include <base/universal_res/uni_res.h>
#include <base/json/tinyjson.hpp>
#include "gloox_src/messagesessionhandler.h"
#include "gloox_src/messagehandler.h"
#include "anan_type.h"
#include "anan_biz_bind.h"
#include "event_collection.h"
namespace gloox {class Client;}
using namespace gloox;

namespace biz {

	struct anan_biz_impl;
	class conversation : protected anan_biz_bind<anan_biz_impl>,

		public ::gloox::MessageHandler,
		public ::gloox::MessageSessionHandler
	{
		BIZ_FRIEND();
	public:
		conversation(anan_biz_impl* parent);
		virtual ~conversation(void);

		void send_message(json::jobject msg_jobj, boost::function<void(json::jobject, bool, universal_resource)> callback);
		std::string save_send_message(json::jobject msg_jobj, std::string const& msg, std::string& msg_type);
		void send_msg(json::jobject msg_jobj, std::string const& txt_msg, std::string const& msg, boost::function<void(json::jobject, bool, universal_resource)> callback);

		// 获取图片
		void get_image(json::jobject jobj,boost::function<void(json::jobject)>callback);
		// 获取语音
		void get_voice(json::jobject jobj,boost::function<void(json::jobject)>callback);

	protected:
		//发送图片接口
		void download_image(json::jobject jobj,boost::function<void(json::jobject)>callback);											//下载图片
		void download_image_cb(std::string local_image_path,bool succ, std::string uri,boost::function<void(json::jobject)>callback);
		void add_image_uri(json::jobject jobj,std::string key,json::jobject val);														//计算图片uri
		
		//发送语音接口
		void download_voice(json::jobject jobj,boost::function<void(json::jobject)>callback);											//下载语音
		void download_voice_cb(std::string local_voice_path,bool succ, std::string uri,boost::function<void(json::jobject)>callback);
		void add_voice_uri(json::jobject jobj,std::string key,json::jobject val);

		void regist_to_gloox( Client* p_client );
		void handleFiledakMessage(json::jobject jobj);
		void cancel_send_file_msg_cb(bool err, universal_resource reason);
		virtual void handleMessageSession( MessageSession* session );
		virtual void handleMessage( const Message& msg, MessageSession* session = 0 );
	private:
		void send_msg_in_session(MessageSession *session, std::string const& txt_msg, std::string const& msg);
		std::map<std::string, MessageSession*> m_sessions;
	};
}; //biz
