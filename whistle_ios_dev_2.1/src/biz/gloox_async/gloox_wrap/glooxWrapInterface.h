#ifndef glooxWrapInterface_H__
#define glooxWrapInterface_H__
#pragma once
#include "base/universal_res/uni_res.h"
#include "../gloox_src/client.h"
#include "boost/bind.hpp"
#include "boost/function.hpp"
#include "base/json/tinyjson.hpp"
#include <base/thread/thread_align/thread_align.hpp>
#include <base/utility/callback_def/callback_define.hpp>

#define DISCUSSIONS_DOMAIN	"discussions."
#define GROUPS_DOMAIN	"groups."
#define FILEDAK_DOMAIN		"filedak."
#define LIGHTAPP_DOMAIN		"lightapp."
#define GROWTH_DOMAIN		"growth."

namespace gloox {
	class Message;
	class MessageSession;
	class glooxWrapInterface 
	{
		template<class> friend struct boost::utility::singleton_holder;
	public:
		glooxWrapInterface();
		virtual ~glooxWrapInterface();

		// 从外部调用的功能接口 
		void set_client(Client* client);
		void set_domain(std::string domain);
		std::string get_domain(){return domain_;};
		Client* get_client(){return pclient_;};

		// interface
		void get_privilege(Result_Data_Callback callback);
		void prelogin_with_sam_account(std::string sam_account,json::jobject jobj_sys_info,Result_Data_Callback callback);
		void get_token(std::string service_id, Result_Data_Callback callback);
		//临时订阅联系人状态接口
		void temporary_attention(std::string uid, bool cancel, boost::function<void(bool,universal_resource)> callback);
		//组织结构成员搜索
		void organization_search(std::string name, Result_Data_Callback callback);
		//查找好友
		void find_friend(std::map<std::string,std::string>& friend_info, boost::function<void(bool,json::jobject)> callback);

		// Discussions 接口
		//忽略好友请求好友消息
		void ignore_request_to_be_friends(std::string to_jid);
		void set_aligner(epius::thread_align const& aligner);
		
		std::string append_discussions_domain(std::string id);
		void get_discussions_list(Result_Data_Callback callback);
		void create_discussions(std::string topic, Result_Data_Callback callback);
		void invite_discussions(std::string did, std::vector<std::string> uid, Result_Data_Callback callback);
		void quit_discussions(std::string did, std::string uid, Result_Data_Callback callback);
		void get_discussions_memberlist(std::string did, Result_Data_Callback callback);
		void send_msg( std::string did, std::string const& txt_msg, std::string const& msg );
		// 发送文件传输msg
		void send_file_msg(std::string jid, std::string uri, std::string filename, int file_size, boost::function<void(bool,universal_resource)> callback);
		// 取消文件传输msg
		void cancel_send_file_msg(std::string jid, std::string id, boost::function<void(bool,universal_resource)> callback);
		void change_discussions_name(std::string group_chat_jid,std::string group_topic,std::string group_chat_id,std::string uid,std::string group_chat_name,Result_Callback callback);
		//陌生人列表操作
		//添加陌生人
		void add_a_stranger(std::string key,std::string uid,std::string name/*,Result_Callback callback*/);
		//删除陌生人
		void remove_a_stranger(std::string key,Result_Callback callback);
		//获取陌生人列表
		void get_stranger_list(Result_Data_Callback callback);
		//新增或者编辑隐私列表
		void edit_privacy_list(json::jobject jobj,Result_Data_Callback callback );
		//查看组织结构树权限
		void is_show_organization(std::string to_jid,Result_Data_Callback callback);
		//groups相关接口
		std::string append_groups_domain( std::string id );
		void get_groups_list(Result_Data_Callback callback);
		void get_groups_info( std::string did, Result_Data_Callback callback );
		void get_groups_member_list( std::string did , Result_Data_Callback callback);
		void set_groups_member_info(std::string session_id , json::jobject jobj , json::jobject actor,Result_Callback callback);
		void get_groups_admin_list( std::string did , Result_Data_Callback callback);
		void change_groups_info(std::string did, json::jobject actor,json::jobject item ,Result_Callback callback);
		void quit_groups( std::string did, json::jobject item, Result_Callback callback );
		void groups_kickout_member( std::string session_id ,json::jobject actor, json::jobject item ,json::jobject groups, Result_Callback callback );
		
		void get_create_groups_setting(Result_Data_Callback callback);
		void create_groups( json::jobject item, Result_Data_Callback callback);
		void invite_into_groups( std::string session_id , json::jobject actor, std::string jid, json::jobject groups, Result_Callback callback );
		void answer_groups_invite( std::string session_id, std::string crowd_name, std::string icon, std::string category, std::string accept ,json::jobject actor, json::jobject item, std::string reason, bool never_accept, Result_Callback callback );
		
		void dismiss_groups( std::string session_id, json::jobject actor, json::jobject item, Result_Callback callback );
		void apply_join_groups( std::string did , json::jobject actor ,std::string reason, Result_Data_Callback callback );
		void enter_groups( std::string did , Result_Callback callback );
		void leave_groups( std::string did );
		void change_groups_member_info( std::string did , std::string alert ,Result_Callback callback );
		void get_groups_share_list( std::string did,std::string orderby, Result_Data_Callback callback);
		void upload_file_groups_share( std::string did ,json::jobject actor,json::jobject item ,Result_Callback callback);
		void download_file_groups_share( std::string did ,std::string id,Result_Callback callback );
		void delete_file_groups_share( std::string did ,std::string id,Result_Callback callback );
		void set_groups_share_info( std::string did ,std::string id,std::string mode,Result_Callback callback );
		void find_groups(std::map<std::string,std::string>& groups_info, Result_Data_Callback callback );
		void get_groups_recent_messages( std::map<std::string , std::string> ids);
		void groups_admin_manage_member( std::string session_id , std::string accept, std::string reject_reason ,  std::string apply_reason , json::jobject actor, json::jobject item, json::jobject crowd ,Result_Callback callback );
		void groups_role_apply( std::string session_id , std::string reason , Result_Callback callback );
		void groups_role_change( std::string session_id ,json::jobject actor, json::jobject item, Result_Callback callback );
		void groups_role_demise(std::string session_id ,std::string jid , json::jobject actor , Result_Callback callback);
		//通知其他设备陌生人列表更新
		void notice_other_stranger_list_updated(std::string jid,std::string key,std::string uid,std::string name);

		//lightapp相关协议接口
		void send_lightapp_message(std::string appid, json::jobject msg, std::string msgid, std::string student_number);
		void recv_msg_report(std::string appid , std::string msg_id);
		void can_recv_lightapp_message(Result_Callback callback );
		//发送第三方消息已读(暂时不用)
		void ack_app_message(std::string message_id, std::string ack_type);

		// Discussions 信号
		boost::signal<void(json::jobject)> discussions_list_change;
		boost::signal<void(json::jobject)> discussions_member_change;
		boost::signal<void(json::jobject)> discussions_get_message;
		boost::signal<void(const Message&, MessageSession*)> discussions_get_image;

		//groups signal
		boost::signal<void(json::jobject)> groups_list_change;//群列表发生变化
		boost::signal<void(json::jobject)> groups_info_change;//群信息发生变化
		boost::signal<void(json::jobject)> groups_upload_file_share;//有人上传文件
		boost::signal<void(json::jobject)> groups_member_list_change;//有成员退出或者加入群
		boost::signal<void(json::jobject)> groups_member_quit;//通知管理员有人退出
		boost::signal<void(json::jobject)> groups_get_message;//群会话接收消息
		boost::signal<void(json::jobject)> apply_join_groups_wait;//等待管理员审批
		boost::signal<void(json::jobject)> apply_join_groups_accepted;//(开放群)通知管理员有人加入了群
		boost::signal<void(json::jobject)> recv_apply_join_crowd_response;//管理员对申请进行审批
		boost::signal<void(json::jobject)> groups_member_role_changed;//群成员角色被改变
		boost::signal<void(json::jobject)> groups_role_changed;//通知用户，其身份被改变
		boost::signal<void(json::jobject)> groups_role_applyed;//通知用户，有人申请了管理员身份，更新界面
		boost::signal<void(json::jobject)> crowd_superadmin_applyed_response;//通知用户，管理员身份申请已审批，更新界面
		boost::signal<void(json::jobject)> groups_role_applyed_self;//通知申请者，申请已审批
		boost::signal<void(json::jobject)> groups_role_demised;//通知群新管理员，身份已经变更
		boost::signal<void(json::jobject)> invited_into_gropus;//通知被邀请人，有人邀请加入某群
		boost::signal<void(json::jobject)> recv_answer_groups_invite;//通知管理员有人应答了邀请
		boost::signal<void(json::jobject)> recv_groups_member_web_change_self;//管理端更改成员信息，被更改者收到信息
		boost::signal<void(json::jobject)> recv_groups_member_kickout_admin_other;//其他管理员收到的通知
		boost::signal<void(json::jobject)> recv_groups_member_kickout_admin_self;//移出成员的管理员收到的通知
		boost::signal<void(json::jobject)> recv_groups_member_apply_accept;//某管理员同意某人申请加入群后通知其他管理员
		
		boost::signal<void(const Message& msg, MessageSession* session)> recv_lightapp_msg;//有成员退出或者加入群
		
		//收到文件传输消息的通知
		boost::signal<void(json::jobject)> filedak_get_message;
		//收到用户升级通知
		boost::signal<void(json::jobject)> recv_growth_info_message;
	private:
		gloox::Tag* create_mobile_tag(std::string sam_account,json::jobject jobj_sys_info);
		gloox::Tag* create_pc_tag(std::string sam_account,json::jobject jobj_sys_info);

		void lightapp_addChild(gloox::Tag* tag , std::string type , std::string child_name , std::string child_data);
	private:
		epius::thread_align work_thread_aligner_;
		Client* pclient_;
		std::string domain_;
		std::string discussions_domain_;
		std::string groups_domain_;
		std::string filedak_domain_;
		MessageSession* session_;
		MessageSession* groups_session_;
		MessageSession* lightapp_session_;
		MessageSession* growth_session_;
		MessageSession* filedak_session_;
	};

	typedef boost::utility::singleton_holder<glooxWrapInterface> gWrapInterface;
};
#endif