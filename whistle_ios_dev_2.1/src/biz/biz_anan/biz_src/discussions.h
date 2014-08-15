#pragma once

#include <boost/shared_ptr.hpp>
#include <base/utility/singleton/singleton.hpp>
#include "base/universal_res/uni_res.h"
#include <vector>
#include <boost/function.hpp>
#include "base/json/tinyjson.hpp"
#include <base/utility/callback_def/callback_define.hpp>
#include "anan_biz_bind.h"
#include "anan_biz_impl.h"
#include "base/tcpproactor/TcpProactor.h"

namespace biz {

	class Discussions 
	{
		typedef struct discussions_info{
			std::string topic;
			std::list<std::string> memberlist;
		}discussions_info;

		template<class> friend struct boost::utility::singleton_holder;
	public:
		Discussions ();
		virtual ~Discussions();

		void init();

		void set_biz_bind_impl(anan_biz_impl* impl);

		//获取讨论组列表
		void get_group_list(Result_Data_Callback callback);	
		void get_group_list_cb(Result_Data_Callback callback,bool err, universal_resource reason, json::jobject data);	

		//创建讨论组
		void create_chat_group(std::string room_name, std::vector<std::string> to_users, Result_Data_Callback callback);
		void create_chat_group_cb(std::string room_name, std::vector<std::string> to_users, Result_Data_Callback callback,
			bool err, universal_resource reason, json::jobject data);
		//讨论组改名
		void change_chat_group_name(std::string group_chat_jid,std::string group_topic,std::string group_chat_id,std::string uid,std::string user_name,Result_Callback callback);
		void change_chat_group_name_cb(Result_Callback callback,bool err, universal_resource reason);
		//邀请加入讨论组
		void invite_chat_group(std::string session_id, std::vector<std::string> to_users, Result_Data_Callback callback);

		//获取讨论组成员列表
		void get_chat_group_member_list(std::string session_id, boost::function<void(bool err, universal_resource reason, json::jobject data,std::string group_name)> callback);
		void get_chat_group_member_list_cb(std::string session_id, boost::function<void(bool err, universal_resource reason, json::jobject data,std::string group_name)> callback,
			bool err, universal_resource reason, json::jobject data);
		
		//退出讨论组
		void quit_chat_group(std::string session_id, std::string uid, Result_Data_Callback callback);
		void quit_chat_group_cb(std::string session_id, Result_Data_Callback callback,
			bool err, universal_resource reason, json::jobject data);

		//信号处理 更新讨论组成员头像
		boost::signal< void(json::jobject) > update_head;
		//信号处理 收到讨论组列表更新
		void get_group_list_changed(json::jobject jobj);
		//信号处理 收到讨论组成员列表更新
		void get_group_member_list_changed(json::jobject jobj);
		//信号处理 收到讨论组会话消息
		void get_group_message(json::jobject jobj);

		//讨论组是否存在
		bool is_group_exist(std::string session_id);
		
		std::string get_group_name(std::string session_id);
		//发送讨论组会话消息
		std::string send_msg(std::string session_id, std::string const& txt_msg, std::string const& msg);

		//本地查找
		void search_local_discussions(std::string filterString, json::jobject& jobj );

		void get_group_list2(std::vector<std::string>& group_list);
	private:
		void do_get_group_message();
		std::deque<json::jobject>  msg_queue_;
		std::map<std::string, discussions_info> discussions_;
		//标记已经取过讨论组列表，不再从服务端读取
		bool had_fetch_list_;

		// 处理讨论组成员详细信息，下载图片，判断显示姓名
		json::jobject build_member_info(json::jobject jobj);
		// 上下线状态信号处理
		void connected();

		// 清除讨论组
		void clear_chat_group();
		// 下载图片
		void syncdown_head_image(json::jobject jobj, std::string field_name, std::string uri_string);
		void finished_syncdown_image(json::jobject jobj, std::string field_name,bool succ,std::string uri_string);

		void _MatchEach( json::jobject& jobj, const std::string& filterString, const std::string& name, const std::string session_id, std::string head_uri);
		void fireMatch(json::jobject& jobj, std::string session_id, std::string name, std::string head_uri);

		anan_biz_impl*	get_parent_impl() { return anan_biz_impl_;};
		anan_biz_impl*	anan_biz_impl_;
	};

	typedef boost::utility::singleton_holder<Discussions> g_discussions;
};