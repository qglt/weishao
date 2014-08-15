#include <map>
#include <boost/filesystem.hpp>
#include <base/epiusdb/ep_sqlite.h>
#include <boost/algorithm/string/predicate.hpp>
#include <boost/tuple/tuple.hpp>
#include <base/tcpproactor/TcpProactor.h>
#include <base/log/elog/elog.h>
#include <base/cmd_wrapper/command_wrapper.h>
#include <base/utility/uuid/uuid.hpp>
#include <base/module_path/file_manager.h>
#include <boost/bind.hpp>
#include <boost/assign/list_of.hpp>
#include <boost/unordered_map.hpp>
#include <boost/uuid/uuid.hpp>
#include <boost/uuid/uuid_generators.hpp>
#include <boost/uuid/uuid_io.hpp>
#include <boost/lexical_cast.hpp>
#include <base/cmd_factory/cmd_factory.h>
#include <base/txtutil/txtutil.h>
#include <base/utility/bind2f/bind2f.hpp>
#include <base/utility/file_digest/file2uri.hpp>
#include <base/utility/fun_exit/fun_exit.hpp>
#include "anan_config.h"
#include "login.h"
#include "agent.h"
#include "roster_type.h"
#include "anan_biz.h"
#include "agent_type.h"
#include "anan_private.h"
#include "conversation.h"
#include "biz_groups.h"
#include "user.h"
#include "an_roster_manager.h"
#include "event_collection.h"
#include "organization.h"
#include "biz_lower.h"
#include "biz_app_data.h"
#include "local_config.h"
#include "gloox_wrap/glooxWrapInterface.h"
#include "discussions.h"
#include "base/module_path/epfilesystem.h"
#include "statistics_data.h"
#include "file_transfer_manager.h"
#include "base/module_path/file_manager.h"
#include <base/thread/time_thread/time_thread.h>
#include "base/http_trans/http_request.h"
#include <base/thread/time_thread/time_thread_mgr.h>
#include <base/network/icmp/ping.h>
#include "biz_sql.h"
#include <boost/signal.hpp>
#include <boost/signals/trackable.hpp>
#include "wannianli.h"
#include "whistle_vcard.h"
#include "crowd.h"
#include "lightapp.h"
#include <third_party/qrlib/qrencode.h>
#include <base/local_search/local_search.h>
#include <base/lua/lua_ext/lua_mgr.h>
#ifdef _WIN32
#include "courses.h"
#endif
using namespace epius::epius_sqlite3;
using namespace std;
using namespace biz;
using namespace boost;
using namespace epius;

extern boost::shared_ptr<epius::elog> appLog;

namespace biz 
{
	using namespace boost::assign;
	static map<KPresenceType, string> status_map_value2string = map_list_of(kptOnline, "Online")(kptAway,"Away")(kptBusy, "Busy")(kptOffline,"Offline")(kptAndroid,"Android")(kptIOS,"IOS")(kptInvisible,"Invisible");
	static map<string, KPresenceType> status_map_string2value = map_list_of("Online",kptOnline)("Away",kptAway)("Busy",kptBusy)("Offline",kptOffline)("Android", kptAndroid)("IOS",kptIOS)("Invisible",kptInvisible);

	struct verify_eportal_timeout:public boost::signals::trackable
	{
		verify_eportal_timeout(){timeout_ = 0;}
		void set_timeout(){timeout_ = 1;}
		bool is_timeout(){return timeout_ ==1;}
		json::jobject callback_jobj;
	private:
		int timeout_;
	};
	class biz_lower_impl
	{
	public:
		biz_lower_impl();
		template<class FunType> FunType wrap(FunType cmd)
		{
			return wrap_helper_.wrap(cmd);
		}
		void change_user_cb(json::jobject jobj, bool err, universal_resource res);
		void change_user(json::jobject jobj);
		void close_app_cb(bool err, universal_resource res);
		void close_app(json::jobject jobj);
		void login(json::jobject jobj);
		void set_logon_expired(verify_eportal_timeout* no_cancel);
		void test_network(json::jobject jobj_im, bool openExplorer, verify_eportal_timeout* no_cancel, boost::function<void(json::jobject)> cmd, bool external_url, boost::shared_ptr<int> url_opened, ping_mgr_decl::PING_STATUS succ);
		void do_login(json::jobject jobj);
		void prepare_to_login(json::jobject jobj,json::jobject& tmp_login_jobj,Tuser_info& info);
		void login_callback(json::jobject jobj, bool err, universal_resource res,json::jobject);
		void network_broken(json::jobject jobj);
		void cancel_login(json::jobject jobj);
		void get_login_history(json::jobject jobj);
		void cb_get_login_history(json::jobject jobj, std::list<Tuser_info> userList);
		void update_image(json::jobject jobj);

		void biz_command_callback(std::string,bool /*error*/,universal_resource);
		void biz_command_common_callback(json::jobject jobj, bool err, universal_resource);
		void biz_strore_globle_cb(json::jobject jobj, bool err, universal_resource);

		void opreate_system_message_cb(json::jobject jobj, bool err, universal_resource);
		void run_command(boost::function<void(std::string)> command, json::jobject jobj);
		void run_command(boost::function<void(std::string)> command, boost::function<void(bool, universal_resource)> cmd);

		void get_image(json::jobject jobj);
		void get_voice(json::jobject jobj);
		void biz_media_callback(json::jobject jobj, json::jobject jdata);

		void send_message(json::jobject jobj);
		void add_group(json::jobject jobj);
		void remove_group(json::jobject jobj);
		void rename_group(json::jobject jobj);
		void move_group(json::jobject jobj);
		void recv_msg(std::string, std::string, std::string, std::string);
		void send_message_failed(std::string jid,std::string rowid, std::string msg_tpe);
		void recv_recent_list(json::jobject jobj);
		void get_roster(json::jobject jobj);
		void get_friend_list(json::jobject jobj);
		void move_contact_to_group(json::jobject jobj);
		void set_status(json::jobject jobj);
		void do_set_status(json::jobject jobj);
		void set_stauts_isneed_eportal(json::jobject jobj, json::jobject status);
		void eportal_check(json::jobject jobj, boost::function<void(json::jobject)> cmd);
		void get_qrcode(json::jobject jobj);

		//讨论组接口协议
		void create_chat_group(json::jobject jobj);				//1.创建讨论组
		void create_chat_group_cb(json::jobject jobj, bool err, universal_resource reason, json::jobject data);
		void get_chat_group_list(json::jobject jobj);			//2.获取讨论组列表
		void get_chat_group_list_cb(json::jobject jobj, bool err, universal_resource reason, json::jobject data);
		void invite_buddy_into_chat_group(json::jobject jobj);	//3.讨论组增加成员
		void invite_buddy_into_chat_group_cb(json::jobject jobj, bool err, universal_resource reason, json::jobject data);
		void get_chat_group_member_list(json::jobject jobj);	//4.获取讨论组成员列表
		void get_chat_group_member_list_cb(json::jobject jobj, bool err, universal_resource reason, json::jobject data,string group_name);
		void chat_group_member_changed(json::jobject jobj);		//5.讨论组成员变更通知
		void change_chat_group_name(json::jobject jobj);		//6.修改讨论组主题
		void change_chat_group_name_cb(json::jobject jobj, bool err, universal_resource);
		void leave_chat_group(json::jobject jobj);				//7.退出讨论组	
		void leave_chat_group_cb(json::jobject jobj, bool err, universal_resource reason, json::jobject data);
		void get_chat_group_settings(json::jobject jobj);		//8.取讨论组配置

		//群接口协议
		void get_crowd_list(json::jobject jobj);				//1.取群列表
		void get_crowd_list_cb(json::jobject jobj, bool err, universal_resource reason, json::jobject data);
		void get_crowd_member_list(json::jobject jobj);			//2.取群成员列表
		void get_crowd_member_list_cb(json::jobject jobj, bool err, universal_resource reason, json::jobject data);
		void get_crowd_info(json::jobject jobj);				//3.取群资料
		void get_crowd_info_cb(json::jobject jobj, bool err, universal_resource reason, json::jobject data);
		void set_crowd_info(json::jobject jobj);				//4.修改群资料
		void leave_crowd(json::jobject jobj);					//5.退出群
		void open_crowd_window(json::jobject jobj);				//6.打开群窗口
		void close_crowd_window(json::jobject jobj);			//7.关闭群窗口
		void get_crowd_file_list(json::jobject jobj);			//8.取群共享文件列表
		void get_crowd_file_list_cb(json::jobject jobj, bool err, universal_resource reason, json::jobject data);
		void upload_crowd_file(json::jobject jobj);				//9.上传共享文件列表
		void download_crowd_file(json::jobject jobj);			//10.下载共享文件列表
		void remove_crowd_file(json::jobject jobj);				//11.删除共享文件
		void set_crowd_alert(json::jobject jobj);				//12.设置群屏蔽消息
		void find_crowd(json::jobject jobj);					//13.查找群
		void apply_join_crowd(json::jobject jobj);				//14.申请入群
		void apply_join_crowd_cb( json::jobject jobj, bool err, universal_resource reason, json::jobject data );
		//群完整版增加接口
		void create_crowd(json::jobject jobj);					//15.创建群
		void create_crowd_cb(json::jobject jobj, bool err, universal_resource reason, json::jobject data);
		void dismiss_crowd(json::jobject jobj);				//16.解散群
		void invite_into_crowd(json::jobject jobj);			//17.邀请加入群
		void crowd_member_kickout(json::jobject jobj);  //18.管理员踢成员
		void crowd_apply_superadmin(json::jobject jobj);				//19.申请成为管理员
		void answer_apply_join_crowd(json::jobject jobj);	//20.管理员审批加入申请
		void set_crowd_file_info(json::jobject jobj);		//21.更改文件属性
		void crowd_role_change(json::jobject jobj);                 //超级管理员更改其他成员角色
		void answer_crowd_invite(json::jobject jobj);				//被邀请者应答管理员加入群的邀请
		void crowd_role_demise(json::jobject jobj);						//群管理员转让
		void get_create_crowd_setting(json::jobject jobj);			//判断能否创建群
		void get_create_crowd_setting_cb( json::jobject jobj, bool err, universal_resource reason, json::jobject data );
		void set_crowd_member_info(json::jobject jobj);
		void get_crowd_policy(json::jobject jobj);
		void get_crowd_vote(json::jobject jobj);
		//云配置查找学校
		void cloud_config_find_school(json::jobject);
		//通知和消息
		void crowd_create_success(json::jobject jobj);   //群创建成功通知
		void crowd_list_changed(json::jobject jobj);			//1.通知群列表更新
		void crowd_member_changed(json::jobject jobj);			//2.通知群成员列表更新
		void crowd_info_changed(json::jobject jobj);			//3.通知群资料变更
		void crowd_file_changed(json::jobject jobj);			//4.通知群共享文件列表变更
		void crowd_alert_changed(json::jobject jobj);			//5.通知群屏蔽设置变更
		void recv_quit_crowd_ack(json::jobject jobj);			//6.通知退群系统消息
		void apply_join_groups_accepted_msg(json::jobject jobj); //(开放群)通知管理员有人加入了群
		void recv_apply_join_crowd_response(json::jobject jobj);	      //管理员审批申请加入群申请处理完成通知
		void crowd_member_role_changed(json::jobject jobj);  //群中某成员角色被改变
		void crowd_role_changed(json::jobject jobj);                  //用户角色被超级管理员改变
		void crowd_superadmin_applyed(json::jobject jobj);					//有人申请成为管理员
		void crowd_superadmin_applyed_response(json::jobject jobj);			//通知用户，管理员身份申请已审批，更新界面
		void crowd_system_message(json::jobject jobj);				//系统消息统一接口
		void store_my_info(json::jobject jobj);
		void get_detailed_info(json::jobject jobj);
		void get_org_detailed_info(json::jobject jobj);
		void get_detailed_info_cb(json::jobject jobj, bool isorg, json::jobject data_info);
		void remove_recent_contact(json::jobject jobj);
		void get_token_overtime(json::jobject jobj);
		void response_token(json::jobject jobj, bool err, universal_resource reason, json::jobject data);
		void get_token(json::jobject jobj);
		void reset_token(std::string service_id);
		void get_curriculum_uri(json::jobject jobj);
		void is_file_exist(json::jobject jobj);

		//查看时否有查看组织结构树的权限
		void is_show_organization(json::jobject jobj);
		//设置语言包
		void set_language(json::jobject jobj);

#ifndef _WIN32
		void remove_recent_systemcontact( json::jobject jobj );
#endif

		void get_local_recent_list(json::jobject jobj);
		void get_local_recent_list_cb(json::jobject jobj, bool err, universal_resource reason, json::jobject data);

		void remove_buddy(json::jobject jobj);
		void add_friend(json::jobject jobj);
		void ack_add_friend(json::jobject jobj);
		void set_buddy_remark(json::jobject jobj);
		void get_conv_history(json::jobject jobj);
		//删除单条通话记录
		void del_one_history_msg(json::jobject jobj);
		void del_all_history_msg(json::jobject jobj);

		void get_notice_history(json::jobject jobj);
		void get_one_notice_history(json::jobject jobj);
		void get_notice_history_cb(json::jobject jobj, json::jobject jdata );
		void get_one_notice_history_cb(json::jobject jobj, json::jobject jdata );
		void get_conv_history_cb(json::jobject jobj, json::jobject jdata );
		//获取历史发送通知
		void get_publish_send_history(json::jobject jobj);
		void get_publish_send_history_cb(json::jobject jobj, json::jobject jdata );

		void del_conv_history( json::jobject jobj );
		void get_publish_history( json::jobject jobj );
		void get_publish_history_cb( json::jobject jobj, json::jobject jdata );
		void get_unread_notice_count( json::jobject jobj );
		void get_unread_notice_count_cb( json::jobject jobj, json::jobject jdata );
		void get_unread_notice( json::jobject jobj );
		void get_unread_notice_cb( json::jobject jobj, json::jobject jdata );
		void moveto_blacklist(json::jobject jobj);
		//从隐私列表(黑名单)中移除某人
		void remove_from_blacklist(json::jobject jobj);
		void find_contact_cb(json::jobject jobj,std::string, json::jobject data);
		void find_contact(json::jobject jobj);
		void get_organization_tree(json::jobject jobj);
		void get_organization_tree_cb(json::jobject jobj, json::jobject data);
		void get_notice_tree( json::jobject jobj );
		void get_notice_tree_cb( json::jobject jobj, json::jobject data );
		void find_friend(json::jobject jobj);
		void store_local(json::jobject jobj);
		void delete_local(json::jobject jobj);
		void store_global(json::jobject jobj);
		void get_global(json::jobject jobj);
		void get_local(json::jobject jobj);
		void get_local_storage_cb(json::jobject jobj, bool error, universal_resource res, string data);
		void go_offline(json::jobject jobj);
		void get_relationship(json::jobject jobj);
		void get_relationship_callback(json::jobject jobj, json::jobject jdata);
		void update_buddy_status(std::string jid, KPresenceType presence, json::jobject msg);
		void recv_buddy_add_request(std::string jid, std::string rowid,std::string msg);
		void recv_add_buddy_ack(std::string jid, std::string rowid,bool bAck, json::jobject msg);
		void clear();
		void get_roster_cb(json::jobject data, json::jobject jobj);
		void recv_update_org_head(json::jobject jobj);
		void do_upload_image_cb( json::jobject jobj, bool success, std::string uri, std::string old_path );
		void do_upload_image(json::jobject jobj);
		void do_upload_file(json::jobject jobj);
		void get_user_really_passwd(json::jobject jobj);
		void get_user_really_passwd_cb(json::jobject jobj, std::string passwd);
		void sam_publish_notice(json::jobject jobj);
		void publish_notice( json::jobject jobj );
		void get_conv_unread_cb( json::jobject jobj, json::jobject jdata );
		void get_system_message_cb( json::jobject jobj, json::jobject jdata,bool err,universal_resource unre  );
		void get_conv_unread( json::jobject jobj );
		void get_system_message( json::jobject jobj );
		void get_all_unread_system_message( json::jobject jobj );
		void del_system_message( json::jobject jobj );
		void mark_sysmsg_as_read(json::jobject jobj);
		void get_conv_unread_count_cb( json::jobject jobj, json::jobject jdata );
		void get_conv_unread_count( json::jobject jobj );
		//增加remove user指令
		void remove_user(json::jobject jobj);
		void get_storage_dir(json::jobject jobj);
		void set_storage_dir(json::jobject jobj);
		void move_data_dir_callback(json::jobject jobj, bool error, universal_resource res);
		void recv_item_updated(std::string json_str);
		void recv_organization_status_update(json::jobject jobj);
		void recv_cloud_config(json::jobject jobj);		
		void get_user_auto_login(json::jobject jobj);
		void get_user_auto_login_cb(json::jobject jobj,json::jobject data);

		void set_user_auto_login(json::jobject jobj);
		void set_user_auto_login_cb(json::jobject jobj,json::jobject data);
		//设置主界面名称显示
		void change_user_showname(json::jobject jobj);

		void get_addfriend_policy(json::jobject jobj);
		void get_addfriend_policy_cb(json::jobject jobj, json::jobject data);

		void set_addfriend_policy(json::jobject jobj);
		void set_addfriend_policy_cb(json::jobject jobj, bool err);
		void get_setting_cb(json::jobject jobj, json::jobject data);

		void get_connection_status(json::jobject jobj);
		void get_connection_status_cb(json::jobject jobj, json::jobject data);

		void get_privilege(json::jobject jobj);
		void get_privilege_cb(json::jobject jobj, bool err, universal_resource res, json::jobject data);

		void get_contact_history(json::jobject jobj);
		void get_contact_history_cb(json::jobject data, json::jobject jobj);

		void get_feedback_uri(json::jobject jobj);
		void get_open_platform_url(json::jobject jobj);
		void is_group_crowd_enable(json::jobject jobj);
		void get_auth_types(json::jobject jobj);
		void get_version(json::jobject jobj);
		void get_product_name(json::jobject jobj);
		void delete_conversation_history(json::jobject jobj);
		void delete_notice_history(json::jobject jobj);
		void delete_all_notice(json::jobject jobj);
		void delete_all_readed_notice(json::jobject jobj);
		void mark_message_read(json::jobject jobj);
		void statistics_add(json::jobject jobj);
		void temporary_attention(json::jobject jobj);
		void temporary_attention_cb(json::jobject jobj, bool err, universal_resource res);
		void get_stranger_presence(json::jobject jobj);
		void organization_search(json::jobject jobj);
		void organization_search_cb(json::jobject jobj, bool err, universal_resource res, json::jobject data);
		void send_file_to(json::jobject jobj);
		void download_file(json::jobject jobj);
		void send_file_to_cb(json::jobject jobj, bool err, universal_resource res, std::string filename);
		void download_file_cb(json::jobject jobj, bool err, universal_resource res, std::string filename);
		void file_transfer_status(json::jobject jobj);
		void cancel_transfer_file(json::jobject jobj);
		void save_file_transfer_msg(json::jobject jobj);
		void user_can_change_password(json::jobject jobj);
		void user_can_change_password_cb( json::jobject jobj, bool can_change );
		void get_change_password_uri(json::jobject jobj);
		void get_my_app_callback(json::jobject jobj, std::string platform, bool error, universal_resource res, string data);
		void get_my_app(json::jobject jobj);
		void get_all_app(json::jobject jobj);
		void save_my_app(json::jobject jobj);
		void get_app_name_cfg(json::jobject jobj);
		void get_auth_eportal_label(json::jobject jobj);
		void get_auth_sam_label(json::jobject jobj);
		void get_zodiac(json::jobject jobj); //通过日期取得星座和生肖 YYYY-MM-DD
		void replace_message_by_rowid(json::jobject jobj);
		void get_http_download_url(json::jobject jobj); //获取http下载根url，给移动端下载图片

		//用户升级通知
		void recv_growth_info_message(json::jobject jobj);
		void get_growth_info_url(json::jobject jobj);
		//第三方应用消息接口
		void get_recent_app_messages(json::jobject jobj);
		void get_recent_app_messages_cb(json::jobject jobj, bool err, json::jobject data);
		void get_app_message_history(json::jobject jobj); //pc端使用
		void get_app_message_list(json::jobject jobj); //移动端使用
		void get_app_message_history_cb(json::jobject jobj, bool err, json::jobject data);
		void get_unread_app_message(json::jobject jobj);
		void get_unread_app_message_cb(json::jobject jobj, bool err, json::jobject data);
		void get_all_unread_app_message(json::jobject jobj);
		void mark_app_message_read(json::jobject jobj);
		void delete_app_message(json::jobject jobj);
		void delete_one_app_message(json::jobject jobj);
		void delete_all_app_message(json::jobject jobj);
		void delete_all_readed_app_message(json::jobject jobj);

		//轻应用消息接口
		void get_lightapp_message_history(json::jobject jobj);
		void get_lightapp_message(json::jobject jobj);
		void delete_lightapp_message(json::jobject jobj);
		void send_lightapp_message(json::jobject jobj);
		void send_lightapp_message_cb(json::jobject jobj, bool err, universal_resource reason, json::jobject data);
		void app_icon_update(json::jobject jobj);
		void async_http_get(json::jobject jobj);
		void async_http_get_cb(json::jobject jobj, bool succ, std::string result);
		void async_http_post(json::jobject jobj);
		void async_http_post_cb(json::jobject jobj, bool succ, std::string result);
		void download_lightapp_resources(json::jobject jobj);//轻应用会话资源下载（图片、语音）
		void download_lightapp_resources_cb(json::jobject jobj, bool err, universal_resource reason, std::string local_path);
		void connected();
		void disconnected(universal_resource);
		void connecting();
		
#ifdef _WIN32
		void courses_timestamp(json::jobject jobj);
		void courses_timestamp_cb(json::jobject jobj, bool succ, std::string timestamp);

		void courses_storager(json::jobject jobj);
		void courses_storager_cb(json::jobject jobj, bool succ);

		void courses_search(json::jobject jobj);
		void courses_search_cb(json::jobject jobj, bool succ, json::jobject data);
#endif
	public:
		anan_biz biz_;
		map<string, boost::function<void(bool err, universal_resource res)> > id_to_cmd_;
		int user_logout_;
		epius::thread_switch::WrapHelper wrap_helper_;
		boost::shared_ptr<biz_adapter> adapt_;
		json::jobject privilege_;
		std::map<std::string,json::jobject> token_;
		verify_eportal_timeout* logon_expired_;
		json::jobject school_list_jobj_;
	};

	void biz_lower_interface::init(boost::shared_ptr<biz_adapter> adapt, boost::function<void(boost::function<void()>) > postCmd)
	{
		impl_.reset(new biz_lower_impl);
		impl_->wrap_helper_.setPostCmd(postCmd);
		impl_->adapt_ = adapt;	
		lua_mgr::instance().init(file_manager::instance().get_app_root_path());
		lua_mgr::instance().load_engine("lua\\engine.lua");
		lua_mgr::instance().load_engine("lua\\srv_index.lua");
		//这三个连接信号需要放在agent.init之前
		impl_->biz_.get_login().conn_msm_.connected_signal_.connect(boost::bind(&biz_lower_impl::connected,impl_));
 		impl_->biz_.get_login().conn_msm_.disconnected_signal_.connect(boost::bind(&biz_lower_impl::disconnected, impl_, _1));
 		impl_->biz_.get_login().conn_msm_.connecting_signal_.connect(boost::bind(&biz_lower_impl::connecting, impl_));
		impl_->biz_.get_agent().init();
		//register local command for web pages
		cmd_factory::instance().register_cmd("do_login",bind2f(&biz_lower_impl::login,impl_,_1));
		cmd_factory::instance().register_cmd("close_app", bind2f(&biz_lower_impl::close_app, impl_, _1));
		cmd_factory::instance().register_cmd("do_cancel_login",bind2f(&biz_lower_impl::cancel_login,impl_, _1));
		cmd_factory::instance().register_cmd("get_login_history",bind2f(&biz_lower_impl::get_login_history,impl_,_1));
		cmd_factory::instance().register_cmd("change_user", bind2f(&biz_lower_impl::change_user, impl_, _1));
		cmd_factory::instance().register_cmd("get_roster", bind2f(&biz_lower_impl::get_roster,impl_, _1));
		cmd_factory::instance().register_cmd("send_message", bind2f(&biz_lower_impl::send_message,impl_, _1));
		cmd_factory::instance().register_cmd("get_image", bind2f(&biz_lower_impl::get_image,impl_, _1));
		cmd_factory::instance().register_cmd("get_voice", bind2f(&biz_lower_impl::get_voice,impl_, _1));
		cmd_factory::instance().register_cmd("add_group", bind2f(&biz_lower_impl::add_group,impl_, _1));
		cmd_factory::instance().register_cmd("remove_group", bind2f(&biz_lower_impl::remove_group, impl_, _1));
		cmd_factory::instance().register_cmd("move_group", bind2f(&biz_lower_impl::move_group, impl_, _1));
		cmd_factory::instance().register_cmd("rename_group", bind2f(&biz_lower_impl::rename_group,impl_,_1));
		cmd_factory::instance().register_cmd("get_friend_list",bind2f(&biz_lower_impl::get_friend_list,impl_,_1));
		cmd_factory::instance().register_cmd("move_contact_to_group",bind2f(&biz_lower_impl::move_contact_to_group,impl_,_1));		
		cmd_factory::instance().register_cmd("leave_chat_group", bind2f(&biz_lower_impl::leave_chat_group,impl_,_1));
		cmd_factory::instance().register_cmd("invite_buddy_into_chat_group", bind2f(&biz_lower_impl::invite_buddy_into_chat_group, impl_, _1));
		cmd_factory::instance().register_cmd("get_chat_group_list",bind2f(&biz_lower_impl::get_chat_group_list,impl_,_1));
		cmd_factory::instance().register_cmd("create_chat_group",bind2f(&biz_lower_impl::create_chat_group,impl_,_1));
		cmd_factory::instance().register_cmd("change_chat_group_name",bind2f(&biz_lower_impl::change_chat_group_name,impl_,_1));
		cmd_factory::instance().register_cmd("get_chat_group_member_list",bind2f(&biz_lower_impl::get_chat_group_member_list,impl_,_1));
		cmd_factory::instance().register_cmd("get_chat_group_settings",bind2f(&biz_lower_impl::get_chat_group_settings,impl_,_1));
		//云配置查找学校
		cmd_factory::instance().register_cmd("cloud_config_find_school",bind2f(&biz_lower_impl::cloud_config_find_school,impl_,_1));
		//翻译
		cmd_factory::instance().register_cmd("set_language",bind2f(&biz_lower_impl::set_language,impl_,_1));
		cmd_factory::instance().register_cmd("set_status",bind2f(&biz_lower_impl::set_status,impl_,_1));
		cmd_factory::instance().register_cmd("store_my_info",bind2f(&biz_lower_impl::store_my_info,impl_,_1));
		cmd_factory::instance().register_cmd("get_detailed_info", bind2f(&biz_lower_impl::get_detailed_info,impl_,_1));
		cmd_factory::instance().register_cmd("remove_buddy", bind2f(&biz_lower_impl::remove_buddy, impl_, _1));
		cmd_factory::instance().register_cmd("add_friend",bind2f(&biz_lower_impl::add_friend, impl_, _1));
		cmd_factory::instance().register_cmd("ack_add_friend",bind2f(&biz_lower_impl::ack_add_friend,impl_,_1));
		cmd_factory::instance().register_cmd("set_buddy_remark", bind2f(&biz_lower_impl::set_buddy_remark,impl_,_1));
		cmd_factory::instance().register_cmd("get_conv_history", bind2f(&biz_lower_impl::get_conv_history,impl_,_1));
		cmd_factory::instance().register_cmd("del_one_history_msg", bind2f(&biz_lower_impl::del_one_history_msg,impl_,_1));
		cmd_factory::instance().register_cmd("del_all_history_msg", bind2f(&biz_lower_impl::del_all_history_msg,impl_,_1));
		//获取收到的通知历史
		cmd_factory::instance().register_cmd("get_notice_history", bind2f(&biz_lower_impl::get_notice_history,impl_,_1));
		cmd_factory::instance().register_cmd("get_one_notice_history", bind2f(&biz_lower_impl::get_one_notice_history,impl_,_1));
		//获取历史发送通知
		cmd_factory::instance().register_cmd("get_publish_send_history", bind2f(&biz_lower_impl::get_publish_send_history,impl_,_1));
		cmd_factory::instance().register_cmd("del_conv_history", bind2f(&biz_lower_impl::del_conv_history,impl_,_1));
		cmd_factory::instance().register_cmd("get_conv_unread", bind2f(&biz_lower_impl::get_conv_unread,impl_,_1));
		cmd_factory::instance().register_cmd("get_system_message", bind2f(&biz_lower_impl::get_system_message,impl_,_1));
		cmd_factory::instance().register_cmd("get_all_unread_system_message", bind2f(&biz_lower_impl::get_all_unread_system_message,impl_,_1));
		cmd_factory::instance().register_cmd("del_system_message", bind2f(&biz_lower_impl::del_system_message,impl_,_1));
		cmd_factory::instance().register_cmd("mark_sysmsg_as_read", bind2f(&biz_lower_impl::mark_sysmsg_as_read,impl_,_1));
		cmd_factory::instance().register_cmd("get_conv_unread_count", bind2f(&biz_lower_impl::get_conv_unread_count,impl_,_1));
		cmd_factory::instance().register_cmd("get_publish_history", bind2f(&biz_lower_impl::get_publish_history,impl_,_1));
		cmd_factory::instance().register_cmd("get_unread_notice_count", bind2f(&biz_lower_impl::get_unread_notice_count,impl_,_1));
		cmd_factory::instance().register_cmd("get_unread_notice", bind2f(&biz_lower_impl::get_unread_notice,impl_,_1));
		cmd_factory::instance().register_cmd("moveto_blacklist", bind2f(&biz_lower_impl::moveto_blacklist,impl_,_1));
		//从隐私列表(黑名单)中移除某人
		cmd_factory::instance().register_cmd("remove_from_blacklist", bind2f(&biz_lower_impl::remove_from_blacklist,impl_,_1));
		cmd_factory::instance().register_cmd("find_contact", bind2f(&biz_lower_impl::find_contact,impl_,_1));
		cmd_factory::instance().register_cmd("get_organization_tree",bind2f(&biz_lower_impl::get_organization_tree,impl_,_1));
		cmd_factory::instance().register_cmd("get_notice_tree",bind2f(&biz_lower_impl::get_notice_tree,impl_,_1));
		cmd_factory::instance().register_cmd("publish_notice",bind2f(&biz_lower_impl::publish_notice,impl_,_1));
		cmd_factory::instance().register_cmd("find_friend", bind2f(&biz_lower_impl::find_friend,impl_,_1));
		cmd_factory::instance().register_cmd("store_local", bind2f(&biz_lower_impl::store_local,impl_,_1));
		cmd_factory::instance().register_cmd("delete_local", bind2f(&biz_lower_impl::delete_local,impl_,_1));
		cmd_factory::instance().register_cmd("get_local",bind2f(&biz_lower_impl::get_local,impl_,_1));
		cmd_factory::instance().register_cmd("store_global", bind2f(&biz_lower_impl::store_global,impl_,_1));
		cmd_factory::instance().register_cmd("get_global",bind2f(&biz_lower_impl::get_global,impl_,_1));
		cmd_factory::instance().register_cmd("go_offline",bind2f(&biz_lower_impl::go_offline,impl_, _1));		
		cmd_factory::instance().register_cmd("get_relationship",bind2f(&biz_lower_impl::get_relationship,impl_,_1));		
		cmd_factory::instance().register_cmd("do_upload_image",bind2f(&biz_lower_impl::do_upload_image,impl_,_1));
		cmd_factory::instance().register_cmd("do_upload_file",bind2f(&biz_lower_impl::do_upload_file,impl_,_1));
		cmd_factory::instance().register_cmd("update_image", bind2f(&biz_lower_impl::update_image,impl_,_1));
		cmd_factory::instance().register_cmd("get_user_really_passwd", bind2f(&biz_lower_impl::get_user_really_passwd, impl_, _1));
		cmd_factory::instance().register_cmd("sam_publish_notice", bind2f(&biz_lower_impl::sam_publish_notice, impl_, _1));
		cmd_factory::instance().register_cmd("network_broken", bind2f(&biz_lower_impl::network_broken, impl_, _1));
		cmd_factory::instance().register_cmd("user_can_change_password", bind2f(&biz_lower_impl::user_can_change_password, impl_, _1));
		cmd_factory::instance().register_cmd("get_change_password_uri", bind2f(&biz_lower_impl::get_change_password_uri, impl_, _1));
		cmd_factory::instance().register_cmd("get_token", bind2f(&biz_lower_impl::get_token, impl_, _1));
		cmd_factory::instance().register_cmd("get_curriculum_uri", bind2f(&biz_lower_impl::get_curriculum_uri, impl_, _1));
		cmd_factory::instance().register_cmd("is_file_exist", bind2f(&biz_lower_impl::is_file_exist, impl_, _1));
		cmd_factory::instance().register_cmd("get_my_app", bind2f(&biz_lower_impl::get_my_app, impl_, _1));
		cmd_factory::instance().register_cmd("save_my_app", bind2f(&biz_lower_impl::save_my_app, impl_, _1));
		cmd_factory::instance().register_cmd("get_all_app", bind2f(&biz_lower_impl::get_all_app, impl_, _1));
		cmd_factory::instance().register_cmd("get_app_name_cfg", bind2f(&biz_lower_impl::get_app_name_cfg,impl_, _1));
		cmd_factory::instance().register_cmd("get_auth_eportal_label", bind2f(&biz_lower_impl::get_auth_eportal_label,impl_, _1));
		cmd_factory::instance().register_cmd("get_auth_sam_label", bind2f(&biz_lower_impl::get_auth_sam_label,impl_, _1));			
		// 设置用户显示名称
		cmd_factory::instance().register_cmd("change_user_showname", bind2f(&biz_lower_impl::change_user_showname,impl_, _1));
		//增加remove user指令
		cmd_factory::instance().register_cmd("remove_user", bind2f(&biz_lower_impl::remove_user, impl_, _1));
		//增加get_storage_dir set_storage_dir
		//系统设置->文件管理->自定义文件夹
		cmd_factory::instance().register_cmd("get_storage_dir", bind2f(&biz_lower_impl::get_storage_dir, impl_, _1));
		cmd_factory::instance().register_cmd("set_storage_dir", bind2f(&biz_lower_impl::set_storage_dir, impl_, _1));
		//协议35 取用户是否自动登录
		cmd_factory::instance().register_cmd("get_user_auto_login", bind2f(&biz_lower_impl::get_user_auto_login, impl_, _1));
		//协议36 设置用户是否自动登录
		cmd_factory::instance().register_cmd("set_user_auto_login", bind2f(&biz_lower_impl::set_user_auto_login, impl_, _1));
		//协议32 获取添加好友设置
		cmd_factory::instance().register_cmd("get_addfriend_policy", bind2f(&biz_lower_impl::get_addfriend_policy, impl_, _1));
		//协议33 添加好友的设置
		cmd_factory::instance().register_cmd("set_addfriend_policy", bind2f(&biz_lower_impl::set_addfriend_policy, impl_, _1));
		//协议37 取feedback url的命令
		cmd_factory::instance().register_cmd("get_feedback_url", bind2f(&biz_lower_impl::get_feedback_uri, impl_, _1));

		cmd_factory::instance().register_cmd("get_open_platform_url", bind2f(&biz_lower_impl::get_open_platform_url, impl_, _1));
		//协议38 取是否打开群和讨论组
		cmd_factory::instance().register_cmd("is_group_crowd_enable", bind2f(&biz_lower_impl::is_group_crowd_enable, impl_, _1));
		//协议39 取版本信息
		cmd_factory::instance().register_cmd("get_version", bind2f(&biz_lower_impl::get_version, impl_, _1));
		//协议40 取当前连接状态
		cmd_factory::instance().register_cmd("get_connection_status", bind2f(&biz_lower_impl::get_connection_status, impl_, _1));
		//协议41 取权限集 （由管理端维护）
		cmd_factory::instance().register_cmd("get_privilege", bind2f(&biz_lower_impl::get_privilege, impl_, _1));
		//协议44 取产品名
		cmd_factory::instance().register_cmd("get_product_name", bind2f(&biz_lower_impl::get_product_name, impl_, _1));
		//协议45 删除最近联系人
		cmd_factory::instance().register_cmd("remove_recent_contact", bind2f(&biz_lower_impl::remove_recent_contact, impl_, _1));
		//是否显示认证页面
		cmd_factory::instance().register_cmd("get_auth_types", bind2f(&biz_lower_impl::get_auth_types, impl_, _1));
		
#ifndef _WIN32
		cmd_factory::instance().register_cmd("remove_recent_systemcontact", bind2f(&biz_lower_impl::remove_recent_systemcontact, impl_, _1));
#endif
		//协议46 获取历史聊天记录和最后会话时间
		cmd_factory::instance().register_cmd("get_contact_history", bind2f(&biz_lower_impl::get_contact_history, impl_, _1));
		cmd_factory::instance().register_cmd("delete_conversation_history", bind2f(&biz_lower_impl::delete_conversation_history, impl_, _1));
		cmd_factory::instance().register_cmd("delete_notice_history", bind2f(&biz_lower_impl::delete_notice_history, impl_, _1));
		cmd_factory::instance().register_cmd("delete_all_notice", bind2f(&biz_lower_impl::delete_all_notice, impl_, _1));
		cmd_factory::instance().register_cmd("delete_all_readed_notice", bind2f(&biz_lower_impl::delete_all_readed_notice, impl_, _1));
		cmd_factory::instance().register_cmd("get_local_recent_list", bind2f(&biz_lower_impl::get_local_recent_list, impl_, _1));
		cmd_factory::instance().register_cmd("mark_message_read", bind2f(&biz_lower_impl::mark_message_read, impl_, _1));
		cmd_factory::instance().register_cmd("statistics_add", bind2f(&biz_lower_impl::statistics_add, impl_, _1));
		cmd_factory::instance().register_cmd("temporary_attention", bind2f(&biz_lower_impl::temporary_attention, impl_, _1));
		cmd_factory::instance().register_cmd("get_stranger_presence", bind2f(&biz_lower_impl::get_stranger_presence, impl_, _1));
		cmd_factory::instance().register_cmd("organization_search", bind2f(&biz_lower_impl::organization_search, impl_, _1));
		//文件传输
		cmd_factory::instance().register_cmd("send_file_to", bind2f(&biz_lower_impl::send_file_to, impl_, _1));
		cmd_factory::instance().register_cmd("download_file", bind2f(&biz_lower_impl::download_file, impl_, _1));
		cmd_factory::instance().register_cmd("cancel_transfer_file", bind2f(&biz_lower_impl::cancel_transfer_file, impl_, _1));
		cmd_factory::instance().register_cmd("save_file_transfer_msg", bind2f(&biz_lower_impl::save_file_transfer_msg, impl_, _1));
		cmd_factory::instance().register_cmd("get_org_detailed_info", bind2f(&biz_lower_impl::get_org_detailed_info, impl_, _1));
		cmd_factory::instance().register_cmd("get_zodiac", bind2f(&biz_lower_impl::get_zodiac, impl_, _1));
		cmd_factory::instance().register_cmd("replace_message_by_rowid", bind2f(&biz_lower_impl::replace_message_by_rowid,impl_, _1));
		//第三方应用消息接口
		cmd_factory::instance().register_cmd("get_recent_app_messages", bind2f(&biz_lower_impl::get_recent_app_messages,impl_, _1));
		cmd_factory::instance().register_cmd("get_app_message_history", bind2f(&biz_lower_impl::get_app_message_history,impl_, _1));
		cmd_factory::instance().register_cmd("get_app_message_list", bind2f(&biz_lower_impl::get_app_message_list,impl_, _1));
		cmd_factory::instance().register_cmd("mark_app_message_read", bind2f(&biz_lower_impl::mark_app_message_read,impl_, _1));
		cmd_factory::instance().register_cmd("delete_app_message", bind2f(&biz_lower_impl::delete_app_message,impl_, _1));
		cmd_factory::instance().register_cmd("delete_one_app_message", bind2f(&biz_lower_impl::delete_one_app_message,impl_, _1));
		cmd_factory::instance().register_cmd("delete_all_app_message", bind2f(&biz_lower_impl::delete_all_app_message,impl_, _1));
		cmd_factory::instance().register_cmd("get_unread_app_message", bind2f(&biz_lower_impl::get_unread_app_message,impl_, _1));
		cmd_factory::instance().register_cmd("get_all_unread_app_message", bind2f(&biz_lower_impl::get_all_unread_app_message,impl_, _1));
		cmd_factory::instance().register_cmd("delete_all_readed_app_message", bind2f(&biz_lower_impl::delete_all_readed_app_message,impl_, _1));
		cmd_factory::instance().register_cmd("get_qrcode", bind2f(&biz_lower_impl::get_qrcode, impl_, _1));
		//LightApp应用
		cmd_factory::instance().register_cmd("get_lightapp_message_history", bind2f(&biz_lower_impl::get_lightapp_message_history,impl_, _1));
		cmd_factory::instance().register_cmd("get_lightapp_message", bind2f(&biz_lower_impl::get_lightapp_message,impl_, _1));
		cmd_factory::instance().register_cmd("send_lightapp_message", bind2f(&biz_lower_impl::send_lightapp_message,impl_, _1));
		cmd_factory::instance().register_cmd("delete_lightapp_message", bind2f(&biz_lower_impl::delete_lightapp_message,impl_, _1));
		g_lightapp::instance().app_icon_update.connect(impl_->wrap(bind2f(&biz_lower_impl::app_icon_update,impl_,_1)));
		cmd_factory::instance().register_cmd("async_http_get", bind2f(&biz_lower_impl::async_http_get,impl_, _1));
		cmd_factory::instance().register_cmd("async_http_post", bind2f(&biz_lower_impl::async_http_post,impl_, _1));
		cmd_factory::instance().register_cmd("download_lightapp_resources", bind2f(&biz_lower_impl::download_lightapp_resources,impl_, _1));
		
		//获取用户升级信息url
		cmd_factory::instance().register_cmd("get_growth_info_url", bind2f(&biz_lower_impl::get_growth_info_url,impl_, _1));
		cmd_factory::instance().register_cmd("get_http_download_url", bind2f(&biz_lower_impl::get_http_download_url,impl_, _1));
		
		//组织结构树查看权限获取
		cmd_factory::instance().register_cmd("is_show_organization", bind2f(&biz_lower_impl::is_show_organization, impl_, _1));		
		//群接口
		cmd_factory::instance().register_cmd("create_crowd", bind2f(&biz_lower_impl::create_crowd,impl_, _1));
		cmd_factory::instance().register_cmd("crowd_create_success", bind2f(&biz_lower_impl::crowd_create_success,impl_, _1));		
		cmd_factory::instance().register_cmd("dismiss_crowd", bind2f(&biz_lower_impl::dismiss_crowd,impl_, _1));
		cmd_factory::instance().register_cmd("crowd_member_kickout", bind2f(&biz_lower_impl::crowd_member_kickout,impl_, _1));
		cmd_factory::instance().register_cmd("set_crowd_file_info", bind2f(&biz_lower_impl::set_crowd_file_info,impl_, _1));
		cmd_factory::instance().register_cmd("crowd_apply_superadmin", bind2f(&biz_lower_impl::crowd_apply_superadmin,impl_, _1));
		cmd_factory::instance().register_cmd("answer_apply_join_crowd", bind2f(&biz_lower_impl::answer_apply_join_crowd,impl_, _1));
		cmd_factory::instance().register_cmd("crowd_role_change", bind2f(&biz_lower_impl::crowd_role_change,impl_, _1));
		cmd_factory::instance().register_cmd("answer_crowd_invite", bind2f(&biz_lower_impl::answer_crowd_invite,impl_, _1));
		cmd_factory::instance().register_cmd("crowd_role_demise", bind2f(&biz_lower_impl::crowd_role_demise,impl_, _1));
		cmd_factory::instance().register_cmd("invite_into_crowd", bind2f(&biz_lower_impl::invite_into_crowd,impl_, _1));
		cmd_factory::instance().register_cmd("get_crowd_list", bind2f(&biz_lower_impl::get_crowd_list,impl_, _1));
		cmd_factory::instance().register_cmd("get_crowd_member_list", bind2f(&biz_lower_impl::get_crowd_member_list,impl_, _1));
		cmd_factory::instance().register_cmd("get_crowd_info", bind2f(&biz_lower_impl::get_crowd_info,impl_, _1));
		cmd_factory::instance().register_cmd("set_crowd_info", bind2f(&biz_lower_impl::set_crowd_info,impl_, _1));
		cmd_factory::instance().register_cmd("leave_crowd", bind2f(&biz_lower_impl::leave_crowd,impl_, _1));
		cmd_factory::instance().register_cmd("open_crowd_window", bind2f(&biz_lower_impl::open_crowd_window,impl_, _1));
		cmd_factory::instance().register_cmd("close_crowd_window", bind2f(&biz_lower_impl::close_crowd_window,impl_, _1));
		cmd_factory::instance().register_cmd("get_crowd_file_list", bind2f(&biz_lower_impl::get_crowd_file_list,impl_, _1));
		cmd_factory::instance().register_cmd("upload_crowd_file", bind2f(&biz_lower_impl::upload_crowd_file,impl_, _1));
		cmd_factory::instance().register_cmd("download_crowd_file", bind2f(&biz_lower_impl::download_crowd_file,impl_, _1));
		cmd_factory::instance().register_cmd("remove_crowd_file", bind2f(&biz_lower_impl::remove_crowd_file,impl_, _1));
		cmd_factory::instance().register_cmd("set_crowd_alert", bind2f(&biz_lower_impl::set_crowd_alert,impl_, _1));
		cmd_factory::instance().register_cmd("find_crowd", bind2f(&biz_lower_impl::find_crowd,impl_, _1));
		cmd_factory::instance().register_cmd("apply_join_crowd", bind2f(&biz_lower_impl::apply_join_crowd,impl_, _1));
		cmd_factory::instance().register_cmd("get_create_crowd_setting", bind2f(&biz_lower_impl::get_create_crowd_setting,impl_, _1));
		cmd_factory::instance().register_cmd("set_crowd_member_info", bind2f(&biz_lower_impl::set_crowd_member_info,impl_, _1));
		cmd_factory::instance().register_cmd("get_crowd_policy", bind2f(&biz_lower_impl::get_crowd_policy, impl_, _1));
		cmd_factory::instance().register_cmd("get_crowd_vote", bind2f(&biz_lower_impl::get_crowd_vote, impl_, _1));		
		g_crowd::instance().update_member_head.connect(impl_->wrap(bind2f(&biz_adapter::update_member_head,impl_->adapt_,_1)));
		g_crowd::instance().crowd_list_changed_signal.connect(impl_->wrap(bind2f(&biz_lower_impl::crowd_list_changed,impl_,_1)));
		g_crowd::instance().crowd_member_changed.connect(impl_->wrap(bind2f(&biz_lower_impl::crowd_member_changed,impl_,_1)));
		g_crowd::instance().crowd_info_changed.connect(impl_->wrap(bind2f(&biz_lower_impl::crowd_info_changed,impl_,_1)));
		g_crowd::instance().recv_quit_crowd_ack.connect(impl_->wrap(bind2f(&biz_lower_impl::recv_quit_crowd_ack,impl_,_1)));
		g_crowd::instance().crowd_share_file_changed.connect(impl_->wrap(bind2f(&biz_lower_impl::crowd_file_changed,impl_,_1)));
		g_crowd::instance().crowd_member_info_changed.connect(impl_->wrap(bind2f(&biz_lower_impl::crowd_alert_changed,impl_,_1)));
		g_crowd::instance().recv_apply_join_crowd_response.connect(impl_->wrap(bind2f(&biz_lower_impl::recv_apply_join_crowd_response,impl_,_1)));
		g_crowd::instance().crowd_member_role_changed.connect(impl_->wrap(bind2f(&biz_lower_impl::crowd_member_role_changed,impl_,_1)));
		g_crowd::instance().crowd_role_changed.connect(impl_->wrap(bind2f(&biz_lower_impl::crowd_role_changed,impl_,_1)));
		g_crowd::instance().crowd_superadmin_applyed.connect(impl_->wrap(bind2f(&biz_lower_impl::crowd_superadmin_applyed,impl_,_1)));
		g_crowd::instance().crowd_superadmin_applyed_response.connect(impl_->wrap(bind2f(&biz_lower_impl::crowd_superadmin_applyed_response,impl_,_1)));
		g_crowd::instance().apply_join_groups_accepted_msg.connect(impl_->wrap(bind2f(&biz_lower_impl::apply_join_groups_accepted_msg,impl_,_1)));
		g_crowd::instance().crowd_system_message.connect(impl_->wrap(bind2f(&biz_lower_impl::crowd_system_message,impl_,_1)));		
		
#ifdef _WIN32
		cmd_factory::instance().register_cmd("courses_timestamp", bind2f(&biz_lower_impl::courses_timestamp,impl_, _1));
		cmd_factory::instance().register_cmd("courses_storager", bind2f(&biz_lower_impl::courses_storager,impl_, _1));
		cmd_factory::instance().register_cmd("courses_search", bind2f(&biz_lower_impl::courses_search,impl_, _1));
#endif
		// 讨论组通知
		g_discussions::instance().update_head.connect(impl_->wrap(bind2f(&biz_adapter::update_member_head,impl_->adapt_,_1)));
		event_collect::instance().chat_group_list_changed.connect(impl_->wrap(bind2f(&biz_adapter::chat_group_list_changed,impl_->adapt_,_1)));
		event_collect::instance().chat_group_member_changed.connect(impl_->wrap(bind2f(&biz_lower_impl::chat_group_member_changed,impl_,_1)));
		//文件传输状态
		epius::http_requests::instance().file_transfer_status.connect(impl_->wrap(bind2f(&biz_lower_impl::file_transfer_status,impl_,_1)));
		//listen events from biz layer and send to webpage
		event_collect::instance().recv_groups_changed.connect(impl_->wrap(bind2f(&biz_lower_impl::biz_command_callback,impl_,_1,_2,_3)));
		event_collect::instance().recv_session_msg.connect(impl_->wrap(bind2f(&biz_lower_impl::recv_msg,impl_,_1,_2,_3,_4)));
		event_collect::instance().send_message_failed.connect(impl_->wrap(bind2f(&biz_lower_impl::send_message_failed,impl_,_1,_2,_3)));
		event_collect::instance().update_recent_contact.connect(impl_->wrap(bind2f(&biz_adapter::update_recent_contact,impl_->adapt_,_1)));
		event_collect::instance().recv_recent_contact.connect(impl_->wrap(bind2f(&biz_lower_impl::recv_recent_list,impl_,_1)));
		event_collect::instance().recv_presence.connect(impl_->wrap(bind2f(&biz_lower_impl::update_buddy_status,impl_, _1, _2, _3)));
		event_collect::instance().recv_add_request.connect(impl_->wrap(bind2f(&biz_lower_impl::recv_buddy_add_request, impl_, _1,_2,_3)));
		event_collect::instance().recv_add_ack.connect(impl_->wrap(bind2f(&biz_lower_impl::recv_add_buddy_ack,impl_,_1,_2,_3,_4)));
		event_collect::instance().update_head.connect(impl_->wrap(bind2f(&biz_lower_impl::recv_update_org_head,impl_,_1)));
		event_collect::instance().recv_item_updated.connect(impl_->wrap(bind2f(&biz_lower_impl::recv_item_updated,impl_,_1)));
		event_collect::instance().recv_organization_status_update.connect(impl_->wrap(bind2f(&biz_lower_impl::recv_organization_status_update,impl_,_1)));
		event_collect::instance().recv_cloud_config.connect(impl_->wrap(bind2f(&biz_lower_impl::recv_cloud_config,impl_,_1)));		
		event_collect::instance().recv_notice_message.connect(impl_->wrap(bind2f(&biz_adapter::recv_notice_message,impl_->adapt_,_1)));
		//收到第三方消息通知
		event_collect::instance().recv_app_message.connect(impl_->wrap(bind2f(&biz_adapter::recv_app_message,impl_->adapt_,_1)));
		//更新第三方应用图标
		event_collect::instance().update_app_icon.connect(impl_->wrap(bind2f(&biz_adapter::update_app_icon,impl_->adapt_,_1)));
		//通知用户等级升级变化
		gWrapInterface::instance().recv_growth_info_message.connect(impl_->wrap(bind2f(&biz_lower_impl::recv_growth_info_message,impl_,_1)));
		//通知个性化登入图片下载完毕
		event_collect::instance().update_customize_login.connect(impl_->wrap(bind2f(&biz_adapter::update_customize_login,impl_->adapt_,_1)));
		//通知 “微哨用户” 更新成正确显示名
		event_collect::instance().update_dialog_showname.connect(impl_->wrap(bind2f(&biz_adapter::update_dialog_showname,impl_->adapt_,_1)));
	}

 	biz_lower_interface::biz_lower_interface()
	{

	}

	void biz_lower_interface::uninit()
	{
		impl_->biz_.get_agent().stop_work();
		impl_.reset();
	}

	void biz::biz_lower_impl::go_offline( json::jobject jobj )
	{
		if(!jobj["sam_done"])
		{
			adapt_->go_offline(jobj,boost::bind(&biz_lower_impl::go_offline,this,_1));
			return;
		}
		biz_.get_login().to_offline(wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
	}
	void biz_lower_impl::get_login_history( json::jobject jobj )
	{
		biz_.get_login().load_local_users(wrap(bind2f(&biz_lower_impl::cb_get_login_history,this,jobj,_1)));
	}
	void biz::biz_lower_impl::cancel_login(json::jobject jobj)
	{
		if(!jobj["sam_done"])
		{
			adapt_->cancel_login(jobj,boost::bind(&biz_lower_impl::cancel_login,this,_1));
			return;
		}
		
		if ( logon_expired_ )
		{
			logon_expired_->callback_jobj["result"] = "fail";
			logon_expired_->callback_jobj["reason"] = XL("biz.login.user_cancel").res_value_utf8;
			cmd_factory::instance().callback(logon_expired_->callback_jobj.clone());

			delete logon_expired_;
			logon_expired_ = NULL;
		}
		else
		{
			biz_.get_login().to_cancel(wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
		}
	}
	void biz::biz_lower_impl::update_image( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		json::jobject params = jobj["args"];
		if(!params["img_path"] || !params["img_type"] || !params["img_size"] || !params["crop_area"]|| !params["stretch"]) return;

		string tmp_path = adapt_->crop_image_stretch(params["img_path"].get<string>(), params["img_size"]["width"].get<int>(),params["img_size"]["height"].get<int>(),
			params["crop_area"]["left"].get<int>(),params["crop_area"]["top"].get<int>(),params["crop_area"]["right"].get<int>(),params["crop_area"]["bottom"].get<int>(),
			params["stretch"]["width"].get<int>(), params["stretch"]["height"].get<int>());

		json::jobject update_obj;
		std::string img_type = params["img_type"].get<string>();
		update_obj[img_type] = tmp_path;
		biz_.get_roster().uploadImage(update_obj,UIVCallback());
	}
	void biz::biz_lower_impl::cb_get_login_history( json::jobject jobj, std::list<Tuser_info> userList )
	{
		json::jobject arr_arg;
		BOOST_FOREACH(Tuser_info info, userList)
		{
			json::jobject tmp;
			tmp["user_name"] = info.sam_id;
			tmp["user_passwd"] = info.password;
			tmp["last_login_status"] = status_map_value2string[(KPresenceType)info.presence];
			tmp["auto_login"] = info.auto_login;
			tmp["save_passwd"] = info.savePasswd;
			tmp["head_img"] = info.avatar_file;
			arr_arg.arr_push(tmp);
		}
		jobj["list"] = arr_arg;
		jobj["can_auto_login"] = user_logout_? false:true;
		cmd_factory::instance().callback(jobj);
	}
	void biz::biz_lower_impl::change_user_cb(json::jobject jobj, bool err, universal_resource res)
	{
		biz_command_common_callback(jobj,err,res);
	}
	void biz::biz_lower_impl::change_user(json::jobject jobj)
	{
		if(!jobj["sam_done"])
		{
			adapt_->change_user(jobj,boost::bind(&biz_lower_impl::change_user,this,_1));
			return;
		}
		user_logout_ = true;
		biz_.get_login().change_user(wrap(bind2f(&biz_lower_impl::change_user_cb, this, jobj, _1, _2)));
	}
	void biz::biz_lower_impl::close_app_cb(bool err, universal_resource res)
	{
		adapt_->close_app_cb(err, res);
	}
	void biz::biz_lower_impl::close_app( json::jobject jobj )
	{
		biz_.get_login().to_quit(wrap(bind2f(&biz_lower_impl::close_app_cb,this,_1,_2)));
	}

	void biz::biz_lower_impl::biz_command_callback( std::string uniqueId, bool err, universal_resource res)
	{
		if(id_to_cmd_.find(uniqueId)==id_to_cmd_.end())
		{
			ELOG("app")->warn("cannot find the callback id from biz");
			return;
		}
		id_to_cmd_[uniqueId](err,res);
		id_to_cmd_.erase(uniqueId);
	}

	void biz::biz_lower_impl::run_command( boost::function<void(string)> command, json::jobject jobj)
	{
		run_command(command, boost::bind(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2));
	}
	void biz::biz_lower_impl::run_command( boost::function<void(string)> command, boost::function<void(bool, universal_resource)> cmd)
	{
		using namespace boost::uuids;
		uuid tmpId = random_generator()();
		string strId = boost::lexical_cast<string>(tmpId);
		id_to_cmd_[strId] = cmd;
		command(strId);
	}
	void biz::biz_lower_impl::get_image(json::jobject jobj)
	{
		if(!jobj["args"])
		{
			jobj["result"] = "fail";
			jobj["reason"] = "biz.get_image_invalid_call_format";
			cmd_factory::instance().callback(jobj);
			return;
		}
		json::jobject image_get_jobj;
		image_get_jobj = jobj["args"];
		biz_.get_conversation().get_image(image_get_jobj,wrap(bind2f(&biz_lower_impl::biz_media_callback,this,jobj,_1)));
	}

	void biz::biz_lower_impl::get_voice(json::jobject jobj)
	{
		if(!jobj["args"])
		{
			jobj["result"] = "fail";
			jobj["reason"] = "biz.get_voice_invalid_call_format";
			cmd_factory::instance().callback(jobj);
			return;
		}
		json::jobject voice_get_jobj;
		voice_get_jobj = jobj["args"];
		biz_.get_conversation().get_voice(voice_get_jobj,wrap(bind2f(&biz_lower_impl::biz_media_callback,this,jobj,_1)));
	}

	void biz::biz_lower_impl::biz_media_callback(json::jobject jobj, json::jobject jdata)
	{
		if(jdata["result"].get<string>()=="fail")
		{
			jobj["result"] = "fail";
			jobj["reason"] = jdata["reason"].get<string>();
		}
		else
		{
			jobj["result"] = "success";
			jobj["src"] = adapt_->format_voice_file_format(jdata["src"].get<string>());
		}
		cmd_factory::instance().callback(jobj);
	}

	void biz::biz_lower_impl::send_message( json::jobject jobj )
	{
		if(!jobj["args"] || !jobj["args"]["target"] || !jobj["args"]["msg"])
		{
			jobj["result"] = "fail";
			jobj["reason"] = "biz.send_message_invalid_call_format";
			cmd_factory::instance().callback(jobj);
			return;
		}
		biz_.get_conversation().send_message(jobj,wrap(bind2f(&biz_lower_impl::biz_command_common_callback, this, _1, _2, _3)));
	}

	void biz::biz_lower_impl::biz_strore_globle_cb( json::jobject jobj, bool err, universal_resource res)
	{
		if(!err)
		{
			jobj["result"] = "success";
		}
		else
		{
			jobj["result"] = "fail";
			jobj["reason"] = res.res_value_utf8;
		}
		cmd_factory::instance().callback(jobj);
	}

	void biz::biz_lower_impl::biz_command_common_callback( json::jobject jobj, bool err, universal_resource res)
	{
		if(!err)
		{
			jobj["result"] = "success";
		}
		else
		{
			jobj["result"] = "fail";
			jobj["reason"] = res.res_value_utf8;
		}
		cmd_factory::instance().callback(jobj);
	}

	void biz::biz_lower_impl::opreate_system_message_cb( json::jobject jobj, bool err, universal_resource res)
	{
		if(!err)
		{
			jobj["result"] = "success";
		}
		else
		{
			jobj["result"] = "fail";
		}
		cmd_factory::instance().callback(jobj);
	}

	void biz::biz_lower_impl::add_group( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		if(!jobj["args"]["group_name"])
		{
			jobj["result"] = "fail";
			jobj["reason"] = XL("biz.group.add_group_need_group_name").res_value_utf8;
			cmd_factory::instance().callback(jobj);
			return;
		}
		std::string groupName = jobj["args"]["group_name"].get<std::string>();
		std::string beforeGroupName;
		if(jobj["args"]["before_group_name"]) beforeGroupName = jobj["args"]["before_group_name"].get<std::string>();
		run_command(bind2f(&BizGroups::addGroup, boost::ref(biz_.get_roster().refBizGroupsObject()),_1, groupName, beforeGroupName), jobj);
	}

	void biz::biz_lower_impl::remove_group( json::jobject jobj )
	{
		if(!jobj || !jobj["args"] || !jobj["args"]["group_name"])
		{
			jobj["result"] = "fail";
			jobj["reason"] = XL("biz.group.remove_group_need_group_name").res_value_utf8;
			cmd_factory::instance().callback(jobj);
			return;
		}
		std::string groupName = jobj["args"]["group_name"].get<std::string>();
		run_command(bind2f(&BizGroups::removeGroup, boost::ref(biz_.get_roster().refBizGroupsObject()),_1, groupName), jobj);
	}

	void biz::biz_lower_impl::move_group( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		if(!jobj["args"]["group_name"])
		{
			jobj["result"] = "fail";
			jobj["reason"] = XL("biz.group.add_group_need_group_name").res_value_utf8;
			cmd_factory::instance().callback(jobj);
			return;
		}
		if(!jobj["args"]["before_group_name"])
		{
			jobj["result"] = "fail";
			jobj["reason"] = XL("biz.group.add_group_need_before_group_name").res_value_utf8;
			cmd_factory::instance().callback(jobj);
			return;
		}
		std::string groupName = jobj["args"]["group_name"].get<std::string>();
		std::string beforeGroupName = jobj["args"]["before_group_name"].get<std::string>();
		run_command(bind2f(&BizGroups::moveGroup, boost::ref(biz_.get_roster().refBizGroupsObject()),_1, groupName, beforeGroupName), jobj);

	}

	void biz::biz_lower_impl::rename_group( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		if(!jobj["args"]["group_name"])
		{
			jobj["result"] = "fail";
			jobj["reason"] = XL("biz.group.add_group_need_group_name").res_value_utf8;
			cmd_factory::instance().callback(jobj);
			return;
		}
		if(!jobj["args"]["new_group_name"])
		{
			jobj["result"] = "fail";
			jobj["reason"] = XL("biz.group.add_group_need_before_group_name").res_value_utf8;
			cmd_factory::instance().callback(jobj);
			return;
		}
		std::string groupName = jobj["args"]["group_name"].get<std::string>();
		std::string newGroupName = jobj["args"]["new_group_name"].get<std::string>();
		run_command(bind2f(&BizGroups::renameGroup, boost::ref(biz_.get_roster().refBizGroupsObject()),_1, groupName, newGroupName), jobj);
	}

	void biz::biz_lower_impl::clear()
	{
		id_to_cmd_.clear();
	}

	void biz::biz_lower_impl::get_roster_cb(json::jobject data, json::jobject jobj)
	{
		jobj["buddy_list"] = data["buddy_list"];
		jobj["my_info"] = data["my_info"];
		jobj["my_info"]["presence"] = status_map_value2string[biz_.get_user().syncquery_MyPresence()];

		elog_factory::instance().get_elog("app")->debug("got_roster_callback get: " + jobj.to_string());
		cmd_factory::instance().callback(jobj);
	}
	void biz::biz_lower_impl::get_roster( json::jobject jobj )
	{
		biz_.get_roster().get_contact(wrap(bind2f(&biz_lower_impl::get_roster_cb,this, _1, jobj)));
	}

	//添加取历史聊天记录接口
	void biz_lower_impl::get_contact_history( json::jobject jobj )
	{
		biz_.get_roster().get_contact_history(wrap(bind2f(&biz_lower_impl::get_contact_history_cb,this, _1, jobj)));
	}

	void biz_lower_impl::get_contact_history_cb( json::jobject data, json::jobject jobj )
	{
		jobj["buddy_list"] = data["buddy_list"];
		jobj["my_info"] = data["my_info"];
		jobj["my_info"]["presence"] = status_map_value2string[biz_.get_user().syncquery_MyPresence()];
		jobj["last_conv_time"] = data["last_conv_time"];

		elog_factory::instance().get_elog("app")->debug("get_contact_history_cb get: " + jobj.to_string());
		cmd_factory::instance().callback(jobj);
	}

	void biz::biz_lower_impl::get_friend_list( json::jobject jobj )
	{
		biz_.get_roster().listFriends(wrap(bind2f(&biz_lower_impl::get_roster_cb,this, _1, jobj)));
	}

	void biz::biz_lower_impl::move_contact_to_group( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		if(!jobj["args"]["group_name"])
		{
			jobj["result"] = "fail";
			jobj["reason"] = XL("biz.roster.movecontact_need_group_name").res_value_utf8;
			cmd_factory::instance().callback(jobj);
			return;
		}
		if(!jobj["args"]["jid"])
		{
			jobj["result"] = "fail";
			jobj["reason"] = XL("biz.roster.movecontact_need_jid").res_value_utf8;
			cmd_factory::instance().callback(jobj);
			return;
		}
		biz_.get_roster().moveContactToGroup(jobj["args"]["jid"].get<string>(),jobj["args"]["group_name"].get<string>(),wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
	}

	static vector<string> get_list_from_json(json::jobject jobj)
	{
		vector<string> items;
		for(int i = 0;i<jobj.arr_size();++i)
		{
			items.push_back(jobj[i].get<string>());
		}
		return items;
	}

	void biz::biz_lower_impl::do_set_status( json::jobject jobj )
	{
		if(!jobj || !jobj["args"] || !jobj["args"]["presence"])return;
		string currStatus = jobj["args"]["presence"].get<string>();
		if(status_map_string2value.find(currStatus)!=status_map_string2value.end())
		{
			biz_.get_user().set_Presence(status_map_string2value[currStatus]);
		}
		else
		{
			json::jobject user_def_status;
			user_def_status["extension_status"] = currStatus;
			biz_.get_user().set_Presence(user_def_status.to_string());
		}
	}

	void biz::biz_lower_impl::eportal_check(json::jobject jobj, boost::function<void(json::jobject)> cmd)
	{
		if (anan_config::instance().get_network_test_url_external().empty())
		{
			// 返回配置错误
			jobj["result"] = "fail";
			jobj["reason"] = XL("biz.error_eportal_auth_bad_network_test_url").res_value_utf8;
			cmd_factory::instance().callback(jobj);
		}
		else
		{
			if (logon_expired_)
			{
				delete logon_expired_;
			}

			logon_expired_ = new verify_eportal_timeout;
			logon_expired_->callback_jobj = jobj;

			// 测试网络是否连通，等待30秒
			epius::time_mgr::instance().set_timer(30000,wrap(bind_s(&biz::biz_lower_impl::set_logon_expired, this, logon_expired_)));

			boost::shared_ptr<int> url_opened(new int(0));
			// 探测内部网络

			// 探测外部网络
			epius::ping_mgr::instance().ping(anan_config::instance().get_network_test_url_external(), 3000,
				wrap(bind_s(&biz::biz_lower_impl::test_network, this, jobj, true, logon_expired_, cmd, true, url_opened, _1)));
		}
	}

	void biz::biz_lower_impl::set_stauts_isneed_eportal(json::jobject jobj, json::jobject status)
	{
		if ( status["status"].get<std::string>() == "offline") // 当前状态为离线，尝试eportal认证
		{

			boost::function<void(json::jobject)> cmd = boost::bind(&biz::biz_lower_impl::do_set_status, this, _1);
			eportal_check(jobj, cmd);
		}
		else
		{
			do_set_status(jobj);
		}
	}

	void biz::biz_lower_impl::set_status( json::jobject jobj )
	{
		if(!jobj["sam_done"])
		{
			adapt_->set_status(jobj,boost::bind(&biz_lower_impl::set_status,this,_1));
			return;
		}
		else if ( jobj["args"]["user_action"].get<bool>() && (jobj["args"]["mobile_need_eportal"].get<bool>() || jobj["login_with_eportal"].get<bool>())) // eportal 认证
		{
			biz_.get_login().ui_query_state(wrap(bind2f(&biz_lower_impl::set_stauts_isneed_eportal, this, jobj, _1)));			
		}
		else // 免认证(直连) 或 802.1x sam认证
		{
			do_set_status(jobj);
		}
		
	}


	void biz::biz_lower_impl::create_chat_group_cb(json::jobject jobj, bool err, universal_resource reason, json::jobject data)
	{
		if(!err)
		{
			jobj["result"] = "success";
			jobj["session_id"] = data["session_id"].get<std::string>();
			jobj["group_name"] = data["group_name"].get<std::string>();
		}
		else
		{
			jobj["result"] = "fail";
			jobj["reason"] = reason.res_value_utf8;
		}

		cmd_factory::instance().callback(jobj);
	}
	void biz::biz_lower_impl::create_chat_group( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		vector<string> id_list = get_list_from_json(jobj["args"]["id_list"]);
		string room_name = jobj["args"]["group_name"].get<string>();
		g_discussions::instance().create_chat_group(room_name, id_list,wrap(bind2f(&biz_lower_impl::create_chat_group_cb,this, jobj, _1,_2,_3)));
	}


	void biz::biz_lower_impl::change_chat_group_name_cb( json::jobject jobj, bool err, universal_resource res)
	{
		if(!err)
		{
			jobj["result"] = "success";
		}
		else
		{
			jobj["result"] = "fail";
		}
		cmd_factory::instance().callback(jobj);
	}

	void biz::biz_lower_impl::change_chat_group_name( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		json::jobject params = jobj["args"];
		std::string group_chat_jid = params["group_chat_jid"].get<std::string>();/*"2118@discussions.wuyiu.edu.cn";*/
		std::string group_topic = params["group_topic"].get<std::string>();/*"whistler";*/
		std::string group_chat_id = params["group_chat_id"].get<std::string>();/*"2118";*/
		std::string uid = params["uid"].get<std::string>();/*"392";*/
		std::string user_name = params["user_name"].get<std::string>();/*"test6";*/

		g_discussions::instance().change_chat_group_name(group_chat_jid,group_topic,group_chat_id ,uid,user_name,wrap(bind2f(&biz_lower_impl::change_chat_group_name_cb,this, jobj, _1,_2)));
	}

	void biz::biz_lower_impl::get_chat_group_list( json::jobject jobj )
	{
		if(!jobj)return;
		g_discussions::instance().get_group_list(wrap(bind2f(&biz_lower_impl::get_chat_group_list_cb, this, jobj,_1, _2, _3)));
	}

	void biz::biz_lower_impl::get_chat_group_list_cb( json::jobject jobj, bool err, universal_resource reason, json::jobject data)
	{
		if(!err)
		{
			jobj["result"] = "success";
			jobj["quit_group_list"] = data["quit_group_list"]; 
	 		jobj["group_list"] = data["group_list"];				
		}
		else
		{
			jobj["result"] = "fail";
			jobj["reason"] = reason.res_value_utf8;		
		}
		cmd_factory::instance().callback(jobj);	
	}

	void biz::biz_lower_impl::invite_buddy_into_chat_group( json::jobject jobj )
	{
		if(!jobj || !jobj["args"] || !jobj["args"]["session_id"]||!jobj["args"]["buddies"])return;
		string room_id = jobj["args"]["session_id"].get<string>();
		vector<string> id_list = get_list_from_json(jobj["args"]["buddies"]);

		g_discussions::instance().invite_chat_group(room_id, id_list, wrap(bind2f(&biz_lower_impl::invite_buddy_into_chat_group_cb, this, jobj,_1, _2, _3)));
	}

	void biz_lower_impl::invite_buddy_into_chat_group_cb( json::jobject jobj, bool err, universal_resource reason, json::jobject data )
	{
		if(!err)
		{
			jobj["result"] = "success";
		}
		else
		{
			jobj["result"] = "fail";
			jobj["reason"] = reason.res_value_utf8;
		}

		cmd_factory::instance().callback(jobj);
	}

	void biz::biz_lower_impl::get_chat_group_member_list( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		if(!jobj["args"]["session_id"])
		{
			jobj["result"] = "fail";
			jobj["reason"] = XL("biz.group_talk.error_get_group_list_need_roomid").res_value_utf8;
			cmd_factory::instance().callback(jobj);
			return;
		}
		g_discussions::instance().get_chat_group_member_list(jobj["args"]["session_id"].get<string>(),wrap(bind2f(&biz_lower_impl::get_chat_group_member_list_cb,this,jobj,_1, _2, _3,_4)));
	}

	void biz::biz_lower_impl::get_chat_group_member_list_cb(json::jobject jobj, bool err, universal_resource reason, json::jobject data,string group_name)
	{
		if(!err)
		{
			jobj["result"] = "success";
			jobj["member_list"] = data;
			jobj["group_name"]=group_name;
		}
		else
		{
			jobj["result"] = "fail";
			jobj["reason"] = reason.res_value_utf8;
		}

		cmd_factory::instance().callback(jobj);
	}

	void biz::biz_lower_impl::leave_chat_group( json::jobject jobj )
	{
		if(!jobj || !jobj["args"] || !jobj["args"]["session_id"])return;
		string session_id = jobj["args"]["session_id"].get<string>();
		std::string uid = biz_.get_user().get_userName();
		g_discussions::instance().quit_chat_group(session_id, uid, wrap(bind2f(&biz_lower_impl::leave_chat_group_cb,this,jobj,_1,_2,_3)));
	}

	void biz::biz_lower_impl::leave_chat_group_cb(json::jobject jobj, bool err, universal_resource reason, json::jobject data)
	{
		if(!err)
		{
			jobj["result"] = "success";
		}
		else
		{
			jobj["result"] = "fail";
			jobj["reason"] = reason.res_value_utf8;
		}

		cmd_factory::instance().callback(jobj);
	}

	void biz::biz_lower_impl::chat_group_member_changed( json::jobject jobj )
	{
		adapt_->chat_group_member_changed(jobj);
	}

	void biz::biz_lower_impl::store_my_info( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		biz_.get_roster().storeVCard(jobj["args"],wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
	}

	void biz::biz_lower_impl::get_detailed_info( json::jobject jobj )
	{
		std::string jid_str;
		if(jobj && jobj["args"] && jobj["args"]["jid"])
		{
			jid_str = jobj["args"]["jid"].get<std::string>();
		}
		biz_.get_roster().get_vcard_by_jid(jid_str,wrap(bind2f(&biz_lower_impl::get_detailed_info_cb,this,jobj,false,_1)));
	}

	void biz::biz_lower_impl::get_org_detailed_info( json::jobject jobj )
	{
		std::string jid_str;
		if(jobj && jobj["args"] && jobj["args"]["jid"])
		{
			jid_str = jobj["args"]["jid"].get<std::string>();
		}
		biz_.get_roster().get_vcard_by_jid(jid_str,wrap(bind2f(&biz_lower_impl::get_detailed_info_cb,this,jobj,true,_1)));
	}

	void biz::biz_lower_impl::remove_recent_contact( json::jobject jobj )
	{
		if(!jobj || !jobj["args"] || !jobj["args"]["jid"])return;
		biz_.get_roster().removeRecentContact(jobj["args"]["jid"].get<string>(),wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
	}
#ifndef _WIN32
	void biz::biz_lower_impl::remove_recent_systemcontact( json::jobject jobj )
	{
		biz_.get_roster().removeSystemRecentContact(wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
	}

#endif
	void biz::biz_lower_impl::get_detailed_info_cb( json::jobject jobj, bool isorg, json::jobject data_info )
	{
		if (isorg)
		{
			jobj["id_info"]["name"] = data_info["original"]["name"];
			jobj["id_info"]["landline"] = data_info["original"]["landline"];
			jobj["id_info"]["cellphone"] = data_info["original"]["cellphone"];
			jobj["id_info"]["email"] = data_info["original"]["email"];
			jobj["id_info"]["head"] = data_info["original"]["head"];
			jobj["id_info"]["organization"] = data_info["original"]["organization"];
			jobj["id_info"]["title"] = data_info["original"]["title"];
			jobj["id_info"]["identity_show"] = data_info["original"]["identity_show"];
			jobj["id_info"]["sex_show"] = data_info["original"]["sex_show"];
			jobj["id_info"]["is_my_friend"] = data_info["original"]["is_my_friend"];
			jobj["id_info"]["address_province"] = data_info["original"]["address_province"];
			jobj["id_info"]["address_city"] = data_info["original"]["address_city"];
			jobj["id_info"]["address_district"] = data_info["original"]["address_district"];
			jobj["id_info"]["address_extend"] = data_info["original"]["address_extend"];
		}
		else
		{
			jobj["id_info"] = data_info["changes"];
		}
		
		cmd_factory::instance().callback(jobj);
	}

	void biz::biz_lower_impl::recv_recent_list( json::jobject jobj )
	{
		adapt_->recv_recent_list(jobj);
	}

	void biz::biz_lower_impl::remove_buddy( json::jobject jobj )
	{
		if(!jobj || !jobj["args"] || !jobj["args"]["buddy_id"]||jobj["args"]["buddy_id"].get<string>().empty() || !jobj["args"]["remove_me_from_his_buddy_list"])
		{
			jobj["result"] = "fail";
			jobj["reason"] = XL("biz.roster.remove_buddy_invalid_argument").res_value_utf8;
			cmd_factory::instance().callback(jobj);
			return;
		}
		jobj["result"] = "success";
		biz_.get_roster().removeContact(jobj["args"]["buddy_id"].get<string>(), jobj["args"]["remove_me_from_his_buddy_list"].get<bool>());
		cmd_factory::instance().callback(jobj);
	}

	void biz::biz_lower_impl::add_friend( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		json::jobject params = jobj["args"];
		if(!params["jid"] || !params["name"] || !params["msg"] || !params["group"])return;
		std::list<std::string> groups;
		groups.push_back(params["group"].get<string>());
		biz_.get_roster().addContact(params["jid"].get<string>(), params["name"].get<string>(), params["msg"].get<string>(), groups);
	}

	void biz::biz_lower_impl::recv_buddy_add_request( std::string jid, std::string rowid,std::string msg )
	{		
		//忽略好友请求消
		gWrapInterface::instance().ignore_request_to_be_friends(jid);
		adapt_->recv_buddy_add_request(jid,rowid,msg);
	}

	void biz::biz_lower_impl::recv_add_buddy_ack( std::string jid, std::string rowid,bool bAck, json::jobject msg )
	{	
		adapt_->recv_add_buddy_ack(jid,rowid,bAck,msg);
	}

	void biz::biz_lower_impl::ack_add_friend( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		json::jobject params = jobj["args"];
		if(!params["jid"] || !params["ack"])return;

		std::string reason;
		if(params["reason"])
		{
			reason = params["reason"].to_string();
		}
		biz_.get_roster().ackBeAdded(params["jid"].get<string>(), params["ack"].get<bool>(), reason);
	}

	void biz::biz_lower_impl::set_buddy_remark( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		json::jobject params = jobj["args"];
		if(!params["jid"] || !params["remark"])return;
		biz_.get_roster().setContactRemark(params["jid"].get<string>(),params["remark"].get<string>(),wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
	}

	void biz::biz_lower_impl::get_conv_unread_cb( json::jobject jobj, json::jobject jdata )
	{
		if (jdata["data"])
		{
			jobj["data"] = jdata["data"];
			jobj["count_all"] = jdata["data"].arr_size();
		}
		cmd_factory::instance().callback(jobj);
	}
	void biz::biz_lower_impl::get_conv_unread( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		json::jobject params = jobj["args"];
		if(!params["type"])return;
		std::string jid_string;
		if (params["jid"])
		{
			jid_string = params["jid"].get<std::string>();
		}
		std::string type_string;
		if (params["type"])
		{
			type_string = params["type"].get<std::string>();
		}
		bool mark_read = true;
		if (!params["mark_read"] || params["mark_read"].get<bool>() == true)
		{
			mark_read = true;
		}
		else
		{
			mark_read = false;
		}

		if (type_string == "notice")
		{
			if(jid_string.empty())
			{
				biz_.get_localconfig().loadUnreadNotice(false,-1,0,wrap(bind2f(&biz_lower_impl::get_conv_unread_cb,this,jobj,_1)));
			}
			else
			{
				biz_.get_user().loadOneNoticeMessage(jid_string,wrap(bind2f(&biz_lower_impl::get_conv_unread_cb,this,jobj,_1)));
				if ( mark_read)
				{
					biz_.get_localconfig().MarkOneNoticeAsRead(jid_string);
				}
			}
		}
		else if (type_string == "lightapp")
		{
			std::string appid = params["appid"].get<std::string>();
			biz_.get_localconfig().loadUnreadLightappMessage( appid, mark_read, wrap(bind2f(&biz_lower_impl::get_conv_unread_cb,this,jobj,_1)));
		}
		else
		{
			biz_.get_user().loadUnReadMessage(type_string, jid_string, mark_read, wrap(bind2f(&biz_lower_impl::get_conv_unread_cb,this,jobj,_1)));
		}
	}
	void biz::biz_lower_impl::get_system_message_cb( json::jobject jobj, json::jobject jdata,bool err,universal_resource unre )
	{
		if (!err)
		{
			if (jdata["data"])
			{
				jobj["data"] = jdata["data"];
			}
			if (jdata["count_all"])
			{
				jobj["count_all"] = jdata["count_all"];
			}	
			jobj["result"] = "success";
		}
		else
		{
			jobj["result"] = "failed";
		}
		
		cmd_factory::instance().callback(jobj);
	} 

	void biz::biz_lower_impl::get_system_message( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		json::jobject params = jobj["args"];
		if (!params["begin_idx"]||!params["count"])
		{
			return;
		}

		std::string rowid = params["rowid"].get<std::string>();
		std::string type = params["type"].get<std::string>();  //系统消息类型 crowd/friend

		if(rowid == "")
		{
			biz_.get_localconfig().loadALLSystemtMsg(type, params["begin_idx"].get<int>(),params["count"].get<int>(),wrap(bind2f(&biz_lower_impl::get_system_message_cb,this,jobj,_1,_2,_3)));
		}
		else
		{
			biz_.get_localconfig().loadOneSystemMsg(rowid,wrap(bind2f(&biz_lower_impl::get_system_message_cb,this,jobj,_1,_2,_3)));
		}
	}

	void biz::biz_lower_impl::get_all_unread_system_message( json::jobject jobj )
	{
		boost::function<void(json::jobject,bool,universal_resource)> localdb_callback = [=](json::jobject jdata,bool err,universal_resource unre) mutable
		{
			if (!err)
			{
				if (jdata["data"])
				{
					jobj["data"] = jdata["data"];
				}
				if (jdata["count"])
				{
					jobj["count"] = jdata["count"];
				}
				jobj["result"] = "success";
			}
			else
			{
				jobj["result"] = "falied";
			}			
			cmd_factory::instance().callback(jobj);				
		};

		std::string type = jobj["args"]["type"].get<std::string>();
		biz_.get_localconfig().loadAllUnreadSystemMsg(type, wrap(localdb_callback));
	}

	void biz::biz_lower_impl::mark_sysmsg_as_read(json::jobject jobj)
	{
		if(!jobj || !jobj["args"])return;
		json::jobject params = jobj["args"];
		if (!params["rowid"])
		{
			return;
		}
		std::string rowid = params["rowid"].get<std::string>();
		biz_.get_localconfig().updateSystemMsgIsread(rowid,wrap(bind2f(&biz_lower_impl::opreate_system_message_cb,this,jobj,_1,_2)));
	}

	void biz::biz_lower_impl::del_system_message( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		json::jobject params = jobj["args"];
		if(!params["rowid"])
		{
			return;
		}
		std::string rowid,type;
		rowid = params["rowid"].get<std::string>();
		type = params["type"].get<std::string>();

		if(rowid.empty())
		{
			biz_.get_localconfig().deleteAllRequestMsg(type, wrap(bind2f(&biz_lower_impl::opreate_system_message_cb,this,jobj,_1,_2)));
		}
		else
		{
			biz_.get_localconfig().deleteOneRequestMsg(rowid,wrap(bind2f(&biz_lower_impl::opreate_system_message_cb,this,jobj,_1,_2)));
		}
	}

	void biz::biz_lower_impl::get_conv_unread_count_cb( json::jobject jobj, json::jobject jdata )
	{
		if (jdata["data"])
		{
			jobj["data"] = jdata["data"];			
		}
		jobj["unread_count"] = jdata["unread_count"];
		cmd_factory::instance().callback(jobj);
	}

	void biz::biz_lower_impl::get_conv_unread_count( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
 		biz_.get_user().loadUnReadMessageCount(wrap(bind2f(&biz_lower_impl::get_conv_unread_count_cb,this,jobj,_1)));
	}

	void biz::biz_lower_impl::get_conv_history_cb( json::jobject jobj, json::jobject jdata )
	{
		jobj["count_all"] = jdata["count_all"];
		jobj["data"] = jdata["data"];
		cmd_factory::instance().callback(jobj);
	}
	//获取收到的历史通知
	void biz::biz_lower_impl::get_notice_history_cb( json::jobject jobj, json::jobject jdata )
	{
		jobj["data"] = jdata["data"];
		cmd_factory::instance().callback(jobj);
	}

	void biz::biz_lower_impl::get_one_notice_history_cb( json::jobject jobj, json::jobject jdata )
	{
		//jobj["count_all"] = jdata["count_all"];
		jobj["data"] = jdata["data"];
		cmd_factory::instance().callback(jobj);
	}
	//获取历史发送通知
	void biz::biz_lower_impl::get_publish_send_history_cb( json::jobject jobj, json::jobject jdata )
	{
		jobj["data"] = jdata["data"];
		cmd_factory::instance().callback(jobj);
	}

	//删除单条通话记录
	void biz::biz_lower_impl::del_one_history_msg( json::jobject jobj )
	{		
 		if(!jobj || !jobj["args"])return;
 		json::jobject params = jobj["args"];
 		if(!params["rowid"] && !params["type"])
 			return;
 		std::string type_string;
 		std::string rowid;
 		rowid = params["rowid"].get<std::string>();
 		type_string = params["type"].get<std::string>();
 		//type = conversation
 		// 		 group_chat
 		// 		 crowd_chat
 		//		 notice
 		biz_.get_localconfig().deleteOneConvMsg(type_string,rowid,wrap(bind2f(&biz_lower_impl::opreate_system_message_cb,this,jobj,_1,_2)));

	}

	//删除全部通话记录
	void biz::biz_lower_impl::del_all_history_msg( json::jobject jobj )
	{		
		if(!jobj || !jobj["args"])return;
		json::jobject params = jobj["args"];
		if(!params["jid"] && !params["type"])
			return;
		std::string type_string;
		std::string jid;
		std::string msg_priority;
		if (params["jid"])
		{
			jid = params["jid"].get<std::string>();
		}
		
		type_string = params["type"].get<std::string>();
		if (params["priority"])
		{
			msg_priority = params["priority"].get<std::string>();
		}		
		//type = conversation
		// 		 group_chat
		// 		 crowd_chat		
		//		 notice
		if (type_string == "notice")
		{
			//jid = "";
			biz_.get_localconfig().deleteAllConvMsg(type_string,jid,msg_priority,wrap(bind2f(&biz_lower_impl::opreate_system_message_cb,this,jobj,_1,_2)));
		}
		else
		{
			biz_.get_localconfig().deleteAllConvMsg(type_string,jid,msg_priority,wrap(bind2f(&biz_lower_impl::opreate_system_message_cb,this,jobj,_1,_2)));
		}		
	}

	void biz::biz_lower_impl::get_conv_history( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		json::jobject params = jobj["args"];
		if(!params["jid"] && !params["type"])
			return;
		if(!params["begin_idx"] || !params["count"] )return;

		std::string type_string;
		if (params["type"])
		{
			type_string = params["type"].get<std::string>();
		}
		//type = conversation
		// 		 group_chat
		// 		 crowd_chat
		//		 notice
		if (type_string == "notice")
		{
			if (params["jid"].get<string>() == "")
			{
				biz_.get_user().loadNoticeMessage(params["begin_idx"].get<int>(),params["count"].get<int>(),wrap(bind2f(&biz_lower_impl::get_notice_history_cb,this,jobj,_1)));
			}
			else
			{
				biz_.get_user().loadOneNoticeMessage(params["jid"].get<string>(),wrap(bind2f(&biz_lower_impl::get_notice_history_cb,this,jobj,_1)));
			}
		} 
		else
		{
			biz_.get_user().loadMessage(type_string, params["jid"].get<string>(),params["begin_idx"].get<int>(),params["count"].get<int>(),wrap(bind2f(&biz_lower_impl::get_conv_history_cb,this,jobj,_1)));
		}
	}

	//获取收到的通知历史
	void biz::biz_lower_impl::get_notice_history( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		json::jobject params = jobj["args"];
		if(!params["jid"])return;
		if(!params["begin_idx"] || !params["count"] )return;

		biz_.get_user().loadNoticeMessage( params["begin_idx"].get<int>(),params["count"].get<int>(),wrap(bind2f(&biz_lower_impl::get_notice_history_cb,this,jobj,_1)));
	}
	void biz::biz_lower_impl::get_one_notice_history( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		json::jobject params = jobj["args"];
		if(!params["jid"])return;
		if(!params["begin_idx"] || !params["count"] )
		{
			return;
		}
		biz_.get_user().loadOneNoticeMessage(params["jid"].get<string>(),wrap(bind2f(&biz_lower_impl::get_one_notice_history_cb,this,jobj,_1)));
	}
	//获取历史发送通知
	void biz::biz_lower_impl::get_publish_send_history( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		json::jobject params = jobj["args"];
		if(!params["jid"])return;
		std::string type_string = params["jid"].get<string>();
		biz_.get_user().loadpublishMessage(params["jid"].get<string>(),wrap(bind2f(&biz_lower_impl::get_publish_send_history_cb,this,jobj,_1)));
	}

	void biz::biz_lower_impl::get_publish_history( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		json::jobject params = jobj["args"];
		if(!params["begin_idx"] || !params["count"])return;
		biz_.get_localconfig().LoadPublish(params["begin_idx"].get<int>(),params["count"].get<int>(),wrap(bind2f(&biz_lower_impl::get_publish_history_cb,this,jobj,_1)));
	}

	void biz::biz_lower_impl::get_publish_history_cb( json::jobject jobj, json::jobject jdata )
	{
		jobj["count_all"] = jdata["count_all"];
		jobj["data"] = jdata["data"];
		cmd_factory::instance().callback(jobj);
	}

	void biz::biz_lower_impl::get_unread_notice_count( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		json::jobject params = jobj["args"];
		bool b_only_important_notice = false;
		if (params["priority"] && params["priority"].get<std::string>() == "important")
		{
			b_only_important_notice = true;
		}
		biz_.get_localconfig().loadUnreadNoticeCount( b_only_important_notice,wrap(bind2f(&biz_lower_impl::get_unread_notice_count_cb,this,jobj,_1)));
	}

	void biz::biz_lower_impl::get_unread_notice_count_cb( json::jobject jobj, json::jobject jdata )
	{
		jobj["count_all"] = jdata["count_all"];
		jobj["data"] = jdata["data"];
		cmd_factory::instance().callback(jobj);
	}

	void biz::biz_lower_impl::get_unread_notice( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		json::jobject params = jobj["args"];
		bool b_only_important_notice = false;
		if (params["priority"]&&params["priority"].get<string>()=="important")
		{
			b_only_important_notice = true;
		}
		int offset = -1;
		if(params["begin_idx"])offset = params["begin_idx"].get<int>();
		int count = 20;
		if(params["count"])count = params["count"].get<int>();
		biz_.get_localconfig().loadUnreadNotice( b_only_important_notice,offset,count,wrap(bind2f(&biz_lower_impl::get_unread_notice_cb,this,jobj,_1)));
	}

	void biz::biz_lower_impl::get_unread_notice_cb( json::jobject jobj, json::jobject jdata )
	{
		jobj["count_all"] = jdata["count_all"];
		jobj["data"] = jdata["data"];
		cmd_factory::instance().callback(jobj);
	}

	void biz::biz_lower_impl::del_conv_history( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		json::jobject params = jobj["args"];
		if(!params.arr_size())return;
		biz_.get_user().disposeMessage(params,wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
	}

	void biz::biz_lower_impl::publish_notice( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		json::jobject params = jobj["args"];
		biz_.get_notice().publish(params, wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
	}

	void biz::biz_lower_impl::moveto_blacklist( json::jobject jobj )
	{
		if(!jobj || !jobj["args"] || !jobj["args"]["jid"])return;
		biz_.get_roster().blackedContact(jobj["args"]["jid"].get<string>(),true,wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
	}
	//从隐私列表(黑名单)中移除某人
	void biz::biz_lower_impl::remove_from_blacklist( json::jobject jobj )
	{
		if (!jobj["args"]["jid"])
		{
			return;
		}
		boost::function<void(bool,universal_resource,json::jobject)> callback = [=](bool err,universal_resource unre,json::jobject jdata) mutable
		{
			if (!err)
			{
				jobj["result"] = "success";
			}
			else
			{
				jobj["result"] = "falied";
			}			
			cmd_factory::instance().callback(jobj);				
		};
		biz_.get_roster().remove_someone_form_privacy_list(jobj["args"]["jid"].get<std::string>(),wrap(callback));
	}

	void biz::biz_lower_impl::find_contact_cb( json::jobject jobj,std::string, json::jobject data )
	{
		jobj["data"] = data;
		cmd_factory::instance().callback(jobj);
	}

	void biz::biz_lower_impl::find_contact( json::jobject jobj )
	{
		if(!jobj || !jobj["args"] || !jobj["args"]["search"])return;
		bool include_stranger = true;
		bool include_groups = true;
		if (jobj["args"]["only_contact"] && jobj["args"]["only_contact"].get<bool>())
		{
			include_groups = include_stranger = false;
		}
		biz_.get_roster().findContact(jobj["args"]["search"].get<string>(),include_stranger,include_groups,wrap(bind2f(&biz_lower_impl::find_contact_cb,this,jobj,_1,_2)));
	}

	void biz::biz_lower_impl::get_organization_tree( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])
		{
			return;
		}
		json::jobject param = jobj["args"];
		if(!param["parent_id"] || !param["type"])
		{
			return;
		}		
		biz_.get_org().get_sub_tree(param["parent_id"].get<string>(), wrap(bind2f(&biz_lower_impl::get_organization_tree_cb,this,jobj,_1)));
	}

	void biz_lower_impl::is_show_organization( json::jobject jobj )
	{
		boost::function<void(bool,universal_resource,json::jobject)> callback = [=](bool is_error,universal_resource res,json::jobject org_jobj) mutable
		{
			if (!is_error)
			{
				jobj["is_show_organization"] = org_jobj["is_show_organization"].get<bool>();
				jobj["result"] = "success";
			}
			else
			{
				jobj["result"] = "fail";
				jobj["reason"] = res.res_key;
			}
			cmd_factory::instance().callback(jobj);
		};

		biz_.get_org().is_show_organization(callback);
	}

	void biz::biz_lower_impl::get_organization_tree_cb( json::jobject jobj, json::jobject data )
	{
		jobj["sub_tree"] = data;
		cmd_factory::instance().callback(jobj);
	}

	void biz::biz_lower_impl::get_notice_tree( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		json::jobject param = jobj["args"];
		if(!param["parent_id"])return;
		biz_.get_org().get_notice_tree(param["parent_id"].get<string>(),wrap(bind2f(&biz_lower_impl::get_notice_tree_cb,this,jobj,_1)));
	}

	void biz::biz_lower_impl::get_notice_tree_cb( json::jobject jobj, json::jobject data )
	{
		jobj["sub_tree"] = data;
		cmd_factory::instance().callback(jobj);
	}

	void biz::biz_lower_impl::find_friend( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		biz_.get_roster().findFriend(jobj,wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,_1,_2,_3)));
	}

	void biz::biz_lower_impl::get_local_storage_cb(json::jobject jobj, bool error, universal_resource res, string data)
	{
		if(jobj["args"]["type"].get<std::string>() == "json")
		{
			json::jobject is_json(data);
			if (is_json == json::jobject())
			{
				jobj["value"] = data;
			}
			else
			{
				jobj["value"] = is_json.clone();
			}
		}
		else
		{
			jobj["value"] = data;
		}
		
		biz_command_common_callback(jobj,error, res);
	}
	void biz::biz_lower_impl::store_global( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		json::jobject params = jobj["args"];
		if(!params["key"] || !params["value"])return;
		biz_.get_private().store_global_data(params["key"].get<string>(),params["value"].get<string>(),wrap(bind2f(&biz_lower_impl::biz_strore_globle_cb,this,jobj,_1,_2)));
	}

	void biz::biz_lower_impl::store_local( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		json::jobject params = jobj["args"];
		if(!params["key"] || !params["value"])return;
		biz_.get_private().store_local_data(params["key"].get<string>(),params["value"].get<string>(),wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
	}
	void biz::biz_lower_impl::delete_local(json::jobject jobj)
	{
		if(!jobj || !jobj["args"])return;
		json::jobject params = jobj["args"];
		if(!params["key"])return;
		biz_.get_private().delete_local_data(params["key"].get<string>(),wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
	}

	void biz::biz_lower_impl::get_global( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		json::jobject params = jobj["args"];
		if(!params["key"])return;
		biz_.get_private().get_global_data(params["key"].get<string>(),wrap(bind2f(&biz_lower_impl::get_local_storage_cb,this,jobj,_1,_2,_3)));
	}

	void biz::biz_lower_impl::get_local( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		json::jobject params = jobj["args"];
		if(!params["key"])return;
		biz_.get_private().get_local_data(params["key"].get<string>(),wrap(bind2f(&biz_lower_impl::get_local_storage_cb,this,jobj,_1,_2,_3)));
	}
	void biz::biz_lower_impl::do_upload_image_cb( json::jobject jobj, bool success, std::string uri, std::string old_path )
	{
		jobj["result"] = success? "success":"fail";
		json::jobject upload_obj(uri);
		if (upload_obj)
		{
			uri = upload_obj["file_uri"].get<std::string>();
		}

		if(success)
		{
			jobj["uri"] = uri;
			std::string new_path = file_manager::instance().from_uri_to_path(uri);

			if(new_path != old_path)
			{
				try
				{
					epfilesystem::instance().copy_file( old_path, new_path);
					epfilesystem::instance().remove_file(old_path);
				}catch(std::runtime_error const&)
				{
					ELOG("app")->error("copy and remove file:" + old_path + " wrong");
				}
			}
			jobj["local_img"] = new_path;
		}
		else
		{
			jobj["reason"] = XL("biz.failed_to_upload_image").res_value_utf8;
		}
		cmd_factory::instance().callback(jobj);
	}

	void biz::biz_lower_impl::do_upload_image( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		json::jobject params = jobj["args"];
		if(!params["img_path"] || !params["img_size"] || !params["crop_area"])return;

		string old_path;
		if (!params.is_nil("stretch"))
		{
			old_path = adapt_->crop_image_stretch(params["img_path"].get<string>(), params["img_size"]["width"].get<int>(),params["img_size"]["height"].get<int>(),
				params["crop_area"]["left"].get<int>(),params["crop_area"]["top"].get<int>(),params["crop_area"]["right"].get<int>(),
				params["crop_area"]["bottom"].get<int>(), params["stretch"]["width"].get<int>(), params["stretch"]["height"].get<int>());
		}
		else
		{
			old_path = adapt_->crop_image(params["img_path"].get<string>(), params["img_size"]["width"].get<int>(),params["img_size"]["height"].get<int>(),
				params["crop_area"]["left"].get<int>(),params["crop_area"]["top"].get<int>(),params["crop_area"]["right"].get<int>(),
				params["crop_area"]["bottom"].get<int>());
		}
		

		biz_.get_private().upload(old_path,wrap(bind2f(&biz_lower_impl::do_upload_image_cb,this,jobj,_1,_2,old_path))); \
	}

	void biz::biz_lower_impl::do_upload_file(json::jobject jobj)
	{
		if(!jobj || !jobj["args"])return;
		json::jobject params = jobj["args"];
		if(!params["file_path"])return;
		std::string old_path = params["file_path"].get<std::string>();
		std::string uid;
		if(!params.is_nil("uid")) uid = params["uid"].get<std::string>();
		boost::function<void(bool /*succ*/, std::string)> callback = [=](bool bsucc, std::string uri) mutable
		{
			jobj["result"] = bsucc? "success":"fail";
			json::jobject upload_obj(uri);
			if (upload_obj)
			{
				uri = upload_obj["file_uri"].get<std::string>();
			}
			if(bsucc)
			{
				jobj["uri"] = uri;
			}
			else
			{
				jobj["reason"] = XL("biz.failed_to_upload_file").res_value_utf8;
			}
			cmd_factory::instance().callback(jobj);
		};
		epius::http_requests::instance().upload(anan_config::instance().get_http_upload_path(), old_path, "", uid, boost::function<void(int)>(), callback);
	}

	void biz_lower_impl::get_relationship_callback(json::jobject jobj, json::jobject jdata)
	{
		jobj["relationship"] = jdata["relationship"];
		biz_command_common_callback(jobj,false,XL(""));
	}

	void biz_lower_impl::get_relationship(json::jobject jobj)
	{
		if(!jobj || !jobj["args"])return;
		json::jobject params = jobj["args"];
		if(!params || !params["jid"] )return;

		biz_.get_roster().is_my_friend(params["jid"].get<std::string>(),wrap(bind2f(&biz_lower_impl::get_relationship_callback,this,jobj, _1)));
	}

	void biz_lower_impl::recv_msg( std::string sessionid, std::string from_jid, std::string showname, std::string msg )
	{
		json::jobject jobj;
		jobj["msg"] = msg;
		if(sessionid.find(DISCUSSIONS_DOMAIN)!= std::string::npos)
		{
			jobj["send_id"] = from_jid;
			jobj["session_id"] = sessionid;
			jobj["showname"] = showname;
			jobj["type"] = "group_chat";
		}
		else if (sessionid.find(GROUPS_DOMAIN)!= std::string::npos)
		{
			jobj["send_id"] = from_jid;
			jobj["session_id"] = sessionid;
			jobj["showname"] = showname;
			jobj["alert"] = g_crowd::instance().get_alert_by_session_id(sessionid);
			jobj["type"] = "crowd_chat";
		}
		else if (from_jid.find(LIGHTAPP_DOMAIN)!= std::string::npos)
		{
			jobj["appid"] = from_jid.substr(0,from_jid.find_first_of('@'));
			jobj["type"] = "lightapp_msg";
		}
		else
		{
			jobj["send_id"] = from_jid;
			jobj["session_id"] = sessionid;
			jobj["showname"] = showname;
			jobj["type"] = "conversation";
		}
		lua_mgr::instance().exec_cmd("msg_center.recv_msg",jobj);
		adapt_->recv_msg(jobj);
	}

	void biz_lower_impl::send_message_failed(std::string jid,std::string rowid, std::string msg_type)
	{
		json::jobject jobj;
		jobj["jid"] = jid;
		jobj["type"] = msg_type;
		jobj["rowid"] = rowid;
		adapt_->send_message_failed(jobj);
	}

	void biz_lower_impl::login_callback(json::jobject jobj, bool err, universal_resource res,json::jobject data)
	{
		if(err)
		{
			using namespace boost::assign;
			static std::vector<std::string> hide_window_err = list_of("biz.prelogin.err_Forbidden")("biz.prelogin.err_InternalServerError")("biz.prelogin.err_ItemNotFound")("biz.prelogin.err_NotAcceptable")("biz.prelogin.err_BadRequest");
			if(std::find(hide_window_err.begin(), hide_window_err.end(),res.res_key) != hide_window_err.end())
			{
				adapt_->handle_user_not_exist();	
			}
#ifdef _WIN32
			if (res.res_key == "biz.prelogin.err_Conflict")
			{
				jobj["path"] = data["path"];
				jobj["url"] = data["url"];
				jobj["size"] = data["size"];
				jobj["md5sum"] = data["md5sum"];

			}			
			jobj["reason_id"] = res.res_key;
#endif
		}
		else
		{
			//登陆成功如果本地没有配置文件保存到本地
			std::string config_file_path = file_manager::instance().get_default_config_dir();
			std::string cloud_config_file_path =  epfilesystem::instance().sub_path(config_file_path, "config_from_cloud.json");
			if (!epfilesystem::instance().file_exists(cloud_config_file_path))
			{
				json::jobject config_jobj;
				config_jobj["http_root"] = anan_config::instance().get_http_root();
				config_jobj["port"] = anan_config::instance().get_port();
				config_jobj["server"] = anan_config::instance().get_server();
				config_jobj["domain"] = anan_config::instance().get_domain();
				config_jobj["eportal_explorer_url"] = anan_config::instance().get_eportal_explorer_url();
				json::to_file(config_jobj,cloud_config_file_path);
			}
		}	
		biz_command_common_callback(jobj, err, res);
	}

	void biz_lower_impl::prepare_to_login( json::jobject jobj,json::jobject& tmp_login_jobj,Tuser_info& info )
	{
		privilege_ = json::jobject();
		json::jobject tobj;
		if(!jobj || ! (tobj = jobj["args"])  || !tobj["user_name"] || !tobj["user_passwd"] || !tobj["last_login_status"] || !tobj["save_passwd"] || !tobj["auto_login"])
		{
			jobj["result"] = "fail";
			jobj["reason"] = XL("biz.error_not_enough_info_to_login").res_value_utf8;
			cmd_factory::instance().callback(jobj);
			return;
		}
		//获取硬件配置
		tmp_login_jobj = adapt_->get_hardware_info();
		//设置网络认证类型
		if (!tobj.is_nil("mobile_need_eportal"))
		{
			if (tobj["mobile_need_eportal"].get<bool>())
			{
				tmp_login_jobj["network_type"] = "eportal";
			}
			else
			{
				tmp_login_jobj["network_type"] = "direct";
			}
		}
		else
		{
			tmp_login_jobj["network_type"] = anan_config::instance().get_logon_config();
		}

		clear();

		info.sam_id = tobj["user_name"].get<std::string>();
		info.password = tobj["user_passwd"].get<std::string>();
		map<string, KPresenceType>::iterator it = status_map_string2value.find(tobj["last_login_status"].get<string>());
		if(it==status_map_string2value.end())
		{
			jobj["result"] = "fail";
			jobj["reason"] = XL("biz.login.error_unknown_status").res_value_utf8;
			cmd_factory::instance().callback(jobj);
			return;
		}
		info.presence = it->second;
		info.auto_login = tobj["auto_login"].get<bool>();
		info.savePasswd = tobj["save_passwd"].get<bool>();
		info.last_login_time = boost::posix_time::second_clock::local_time();
		//获取消息提示音设置字段
		if(jobj["sam_will_save_password"] && jobj["sam_will_save_password"].get<bool>())
		{
			jobj["sam_will_save_password"] = false;
			Tuser_info save_info = info;
			save_info.password = jobj["really_passwd"].get<std::string>();
			save_info.auto_login = 0;
			biz_.get_localconfig().saveSamUser(save_info);
		}
	}

	void biz_lower_impl::do_login(json::jobject jobj)
	{
		json::jobject tmp_login_jobj;
		Tuser_info info;
		prepare_to_login(jobj,tmp_login_jobj,info);		
		biz_.get_login().to_login(tmp_login_jobj,info,wrap(bind2f(&biz_lower_impl::login_callback,this,jobj,_1,_2,_3)));
	}

	void biz_lower_impl::test_network(json::jobject jobj_im, bool openExplorer, verify_eportal_timeout* no_cancel, boost::function<void(json::jobject)> cmd,bool external_url, boost::shared_ptr<int> url_opened, ping_mgr_decl::PING_STATUS status)
	{
		if (status == ping_mgr_decl::AUTHED)
		{
			if (logon_expired_)
			{
				delete logon_expired_;
				logon_expired_ = NULL;
			}
			cmd(jobj_im);
		}
		else if(status == ping_mgr_decl::NEED_AUTH)
		{
			if (openExplorer && *url_opened == 0)
			{
				*url_opened = 1;
				adapt_->openURL(anan_config::instance().get_eportal_explorer_url());
			}
			if (no_cancel->is_timeout())
			{
				delete logon_expired_;
				logon_expired_ = NULL;
				
				jobj_im["result"] = "fail";
				jobj_im["reason"] = XL("biz.error_eportal_auth_timeout").res_value_utf8;
				cmd_factory::instance().callback(jobj_im);
			}
			else
			{
				boost::function<void(ping_mgr_decl::PING_STATUS)> callcmd = this->wrap(bind_s(&biz::biz_lower_impl::test_network, this, jobj_im, false, no_cancel, cmd, external_url,url_opened, _1));
				epius::time_mgr::instance().set_timer(1000, [=](){ 
					epius::ping_mgr::instance().ping( anan_config::instance().get_network_test_url_external(),3000,callcmd);
				});
			}
		}
		else
		{
			delete logon_expired_;
			logon_expired_ = NULL;
			jobj_im["result"] = "fail";
			jobj_im["reason"] = XL("biz.login.not_connected").res_value_utf8;
			cmd_factory::instance().callback(jobj_im);
		}
	}

	void biz_lower_impl::set_logon_expired(verify_eportal_timeout* no_cancel)
	{
		no_cancel->set_timeout();
	}

	void biz_lower_impl::login( json::jobject jobj )
	{
		if( !jobj["sam_done"]) 
		{
			adapt_->login(jobj,boost::bind(&biz_lower_impl::login,this,_1));
			return;
		}
		else if (jobj["args"]["mobile_need_eportal"].get<bool>() || jobj["login_with_eportal"].get<bool>()) // eportal 认证
		{
			boost::function<void(json::jobject)> cmd = boost::bind(&biz::biz_lower_impl::do_login, this, _1);
			eportal_check(jobj, cmd);
		}
		else // 免认证(直连) 或 802.1x sam认证
		{
			do_login(jobj);
		}		
	}

	void biz_lower_impl::recv_update_org_head(json::jobject jobj)
	{
		adapt_->recv_update_org_head(jobj);
	}

	void biz_lower_impl::update_buddy_status( std::string jid, KPresenceType presence, json::jobject msg)
	{
		adapt_->update_buddy_status(jid, presence, msg, biz_.get_user().get_userName());
	}

	biz_lower_impl::biz_lower_impl():user_logout_(0)
	{
		logon_expired_ = NULL;
	}

	void biz_lower_impl::get_user_really_passwd( json::jobject jobj )
	{
		biz_.get_login().get_user_really_passwd(jobj["args"]["user_name"].get<string>(), jobj["args"]["user_passwd"].get<string>(),wrap(bind2f(&biz_lower_impl::get_user_really_passwd_cb,this,jobj,_1)));
	}

	void biz_lower_impl::get_user_really_passwd_cb( json::jobject jobj, std::string passwd )
	{
		jobj["really_passwd"] = passwd;
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::sam_publish_notice( json::jobject jobj )
	{
		biz_.get_notice().sam_publish_notice(jobj["args"]);
	}

	void biz_lower_impl::remove_user(json::jobject jobj)
	{
		if(!jobj || !jobj["args"])return;
		json::jobject params = jobj["args"];
		if(!params["user_name"] || !params["delete_local_file"] )return;
		biz_.get_agent().removeUser(params["user_name"].get<string>(), params["delete_local_file"].get<bool>());
		jobj["result"] = "success";
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::get_storage_dir( json::jobject jobj )
	{
		boost::tuple<bool, std::string> path = file_manager::instance().get_config_dir();

		if (path.get<0>())
		{
			jobj["type"] = "default_dir";
		}
		else
		{
			jobj["type"] = "user_defined";
		}
		jobj["path"] = file_manager::instance().get_bare_config_dir();
		cmd_factory::instance().callback(jobj);
	}


	void biz_lower_impl::move_data_dir_callback(json::jobject jobj, bool error, universal_resource res)
	{
		if (!error)
		{
			jobj["path"] = file_manager::instance().get_config_dir().get<1>();
			jobj["result"] = "success";
		}
		else
		{
			jobj["result"] = "fail";
			jobj["reason"] = res.res_value_utf8;
		}

		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::set_storage_dir( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		json::jobject params = jobj["args"];
		if(!params["type"])return;
		biz_.get_agent().move_data_dir(jobj, wrap(bind2f(&biz_lower_impl::move_data_dir_callback, this, jobj, _1, _2)));
	}

	void biz_lower_impl::recv_item_updated( std::string json_str )
	{
		adapt_->recv_item_updated(json_str, biz_.get_user().get_userName());
	}

	//obj.result = "success/fail"
	//obj.reason = "没有该用户"
	//obj.can_auto_login = true/false
	//obj.curr_auto_login = true/false
	void biz_lower_impl::get_user_auto_login( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		json::jobject params = jobj["args"];
		if(!params["user_id"])return;
		std::string jid = params["user_id"].get<string>();
		if (jid.empty())
		{
			jobj["result"] = "fail";
			jobj["reason"] = XL("biz.get_user_auto_login.nouser").res_value_utf8;
			cmd_factory::instance().callback(jobj);
		}
		jid = jid.substr(0,jid.find_first_of('@'));
		biz_.get_localconfig().ui_loadLocalUsers(jid,wrap(bind2f(&biz_lower_impl::get_user_auto_login_cb, this, jobj, _1)));
	}

	void biz_lower_impl::get_user_auto_login_cb( json::jobject jobj,json::jobject data )
	{
		jobj["can_auto_login"] =data["can_auto_login"];
		jobj["curr_auto_login"] = data["curr_auto_login"];
		jobj["result"] = data["result"];
		jobj["reason"] = data["reason"];
		cmd_factory::instance().callback(jobj);
	}

	//obj.result= "success/fail"
	//obj.reason="没有该用户"
	void biz_lower_impl::set_user_auto_login( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		json::jobject params = jobj["args"];
		if(!params["user_id"] || !params["curr_auto_login"])return;
		std::string jid = params["user_id"].get<string>();
		if (jid.empty())
		{
			jobj["result"] = "fail";
			jobj["reason"] = XL("biz.set_user_auto_login.nouser").res_value_utf8;
			cmd_factory::instance().callback(jobj);
		}
		jid = jid.substr(0,jid.find_first_of('@'));
		bool isautologin = params["curr_auto_login"].get<bool>();
		biz_.get_localconfig().ui_saveLocalUser(jid, isautologin, wrap(bind2f(&biz_lower_impl::set_user_auto_login_cb, this, jobj, _1)));
	}

	void biz_lower_impl::set_user_auto_login_cb( json::jobject jobj,json::jobject data )
	{
		jobj["result"] = data["result"];
		jobj["reason"] = data["reason"];
		cmd_factory::instance().callback(jobj);
	}
	
	//obj.type ="allow_all/deny_all/user_verify"
	void biz_lower_impl::get_addfriend_policy( json::jobject jobj )
	{
		biz_.get_private().get_data("setting", wrap(bind2f(&biz_lower_impl::get_addfriend_policy_cb, this, jobj, _1)));
	}

	//{addfriend_policy:"allow/deny/verify"}
	//obj.result="success/fail"
	//obj.reason = "";
	void biz_lower_impl::set_addfriend_policy( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		json::jobject params = jobj["args"];
		if(!params["addfriend_policy"])return;

		std::string type = params["addfriend_policy"].get<string>();
		if (type.empty() || (type.compare("allow")&&type.compare("deny")&&type.compare("verify")))
		{
			jobj["result"] = "fail";
			cmd_factory::instance().callback(jobj);
			return;
		}

		//所有setting都在同一个json里 保存之前先merge数据 
		biz_.get_private().get_data("setting", wrap(bind2f(&biz_lower_impl::get_setting_cb, this, jobj, _1)));

	}

	void biz_lower_impl::get_addfriend_policy_cb( json::jobject jobj , json::jobject data)
	{
		if (!data || !data["addfriend_policy"])
		{
			jobj["result"] = "fail";
		}
		else
		{
			jobj["result"] = "success";
			jobj["addfriend_policy"] = data["addfriend_policy"];
		}
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::set_addfriend_policy_cb(json::jobject jobj, bool ret)
	{
		if (ret)
		{
			jobj["result"] = "success";
		}
		else
		{
			jobj["result"] = "fail";
		}
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::get_setting_cb(json::jobject jobj, json::jobject data )
	{
		json::jobject params = jobj["args"];

		//所有setting都在同一个json里 保存之前先merge数据 
		data["addfriend_policy"] = params["addfriend_policy"];

		//json {addfriend_policy:"allow/deny/verify"}
		biz_.get_private().store_data("setting", data, wrap(bind2f(&biz_lower_impl::set_addfriend_policy_cb, this, jobj, _1)));
	}

	//obj = {feedback_url:""}
	void biz_lower_impl::get_feedback_uri( json::jobject jobj )
	{
		jobj["feedback_uri"] = anan_config::instance().get_feedback_uri();
		cmd_factory::instance().callback(jobj); 
	}

	void biz_lower_impl::get_open_platform_url( json::jobject jobj )
	{
		jobj["url"] = anan_config::instance().get_open_platform_url();
		cmd_factory::instance().callback(jobj); 
	}

	void biz_lower_impl::is_group_crowd_enable( json::jobject jobj )
	{
		jobj["group"] = anan_config::instance().is_group_enable();
		jobj["crowd"] = anan_config::instance().is_crowd_enable();
		cmd_factory::instance().callback(jobj); 
	}

	void biz_lower_impl::get_auth_types( json::jobject jobj )
	{
		jobj["auth_types"] = anan_config::instance().get_auth_types();
		cmd_factory::instance().callback(jobj); 
	}
	
	void biz_lower_impl::get_version( json::jobject jobj )
	{
		jobj["version"] = anan_config::instance().get_version();
		cmd_factory::instance().callback(jobj); 
	}

	void biz_lower_impl::get_connection_status( json::jobject jobj )
	{
		biz_.get_login().ui_query_state(wrap(bind2f(&biz_lower_impl::get_connection_status_cb, this, jobj, _1)));
	}
	void biz_lower_impl::get_connection_status_cb( json::jobject jobj, json::jobject data )
	{
		jobj["status"] = data["status"];
		cmd_factory::instance().callback(jobj);
	}


	void biz_lower_impl::get_privilege( json::jobject jobj )
	{
		if(!jobj)return;
		if (privilege_)
		{
			jobj["privilege"] = privilege_;
			biz_command_common_callback(jobj,false,XL("")); 
			return;
		}
		biz_.get_user().get_privilege(wrap(bind2f(&biz_lower_impl::get_privilege_cb, this, jobj, _1, _2, _3)));
	}

	void biz_lower_impl::get_privilege_cb( json::jobject jobj, bool err, universal_resource res, json::jobject data)
	{
		if (!err)
		{
			privilege_ = data.clone();
			jobj["privilege"] = data.clone();
		}
		biz_command_common_callback(jobj,err,res);
	}

	void biz_lower_impl::get_product_name( json::jobject jobj )
	{
		jobj["product_name"] = anan_config::instance().get_productionname();
		cmd_factory::instance().callback(jobj); 
	}

	void biz_lower_impl::network_broken( json::jobject jobj )
	{
		biz_.get_login().network_broken();
	}

	void biz_lower_impl::get_chat_group_settings( json::jobject jobj )
	{
		jobj["max_member"] = 20;
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::delete_conversation_history( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		json::jobject params = jobj["args"];
		if(!params["jid"])return;

		biz_.get_localconfig().deleteConversationHistory(params["jid"].get<std::string>(), wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
	}

	void biz_lower_impl::delete_notice_history( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		json::jobject params = jobj["args"];
		if(!params["notice_id"])return;
		biz_.get_localconfig().deleteNoticeHistory(params["notice_id"].get<std::string>(), wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
	}

	void biz_lower_impl::delete_all_notice( json::jobject jobj )
	{
		biz_.get_localconfig().deleteAllNotice(wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
	}

	void biz_lower_impl::delete_all_readed_notice( json::jobject jobj )
	{
		biz_.get_localconfig().deleteAllReadedNotice(wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
	}

	void biz_lower_impl::get_local_recent_list( json::jobject jobj )
	{
		biz_.get_localconfig().getLocalContactList(wrap(bind2f(&biz_lower_impl::get_local_recent_list_cb,this,jobj,_1,_2,_3)));
	}

	void biz_lower_impl::get_local_recent_list_cb( json::jobject jobj, bool err, universal_resource reason, json::jobject data )
	{
		if(!err)
		{
			jobj["result"] = "success";
			jobj["RecentList"] = data;
		}
		else
		{
			jobj["result"] = "fail";
			jobj["reason"] = reason.res_value_utf8;
		}
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::mark_message_read( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])return;
		json::jobject params = jobj["args"];
		if(!params["jid"] || !params["type"])return;
		biz_.get_user().MarkMessageRead(params["type"].get<std::string>(), params["jid"].get<std::string>());
	}

	void biz_lower_impl::statistics_add( json::jobject jobj )
	{
		if(!jobj || !jobj["args"] || !jobj["args"]["item"])return;
		int number = 1;
		if (jobj["args"]["number"])
		{
			number = jobj["args"]["number"].get<int>();
		}

		g_statistics_data::instance().add_data(jobj["args"]["item"].get<std::string>(), number);
	}

	void biz_lower_impl::temporary_attention( json::jobject jobj )
	{
		if(!jobj || !jobj["args"] || !jobj["args"]["jid"])
			return;

		bool cancel = false;
		if (jobj["args"]["cancel"])
		{
			cancel = jobj["args"]["cancel"].get<bool>();
		}

		biz_.get_roster().temporaryAttention(jobj["args"]["jid"].get<std::string>(), cancel, wrap(bind2f(&biz_lower_impl::temporary_attention_cb,this,jobj,_1,_2)));
	}

	void biz_lower_impl::temporary_attention_cb( json::jobject jobj, bool err, universal_resource res )
	{
		if (err)
		{
			jobj["result"] = "fail";
			jobj["reason"] = res.res_value_utf8;
		}
		else
		{
			jobj["result"] = "success";
		}
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::get_stranger_presence( json::jobject jobj )
	{
		if(!jobj || !jobj["args"] || !jobj["args"]["jid"])return;
		biz_.get_roster().get_stranger_presence(jobj["args"]["jid"].get<std::string>());
	}

	void biz_lower_impl::organization_search( json::jobject jobj )
	{
		if(!jobj || !jobj["args"] || !jobj["args"]["name"])return;
		biz_.get_org().organization_search(jobj["args"]["name"].get<std::string>(), wrap(bind2f(&biz_lower_impl::organization_search_cb,this,jobj,_1,_2,_3)));
	}

	void biz_lower_impl::organization_search_cb( json::jobject jobj, bool err, universal_resource res, json::jobject data )
	{
		if (err)
		{
			jobj["result"] = "fail";
			jobj["reason"] = res.res_value_utf8;
		}
		else
		{
			jobj["result"] = "success";
			jobj["user"] = data;
		}
		cmd_factory::instance().callback(jobj);
	}
	void biz_lower_impl::change_user_showname( json::jobject jobj )
	{
		if (!jobj["args"])
		{
			return;
		}
		biz_.get_roster().change_user_showname(jobj["args"]["showNameSelect"].get<std::string>());
	}
	
	void biz_lower_impl::send_file_to( json::jobject jobj )
	{
		if(!jobj || !jobj["args"] || !jobj["args"]["file"]|| !jobj["args"]["uid"]|| !jobj["args"]["jid"])return;
		if(!jobj["args"].is_nil("resumable")&&jobj["args"]["resumable"].get<std::string>()=="false")
			file_transfer::instance().send_file_to(jobj["args"]["file"].get<std::string>(), jobj["args"]["uid"].get<std::string>(),jobj["args"]["jid"].get<std::string>(), wrap(bind2f(&biz_lower_impl::send_file_to_cb,this,jobj,_1,_2,_3)), false);
		else 
			file_transfer::instance().send_file_to(jobj["args"]["file"].get<std::string>(), jobj["args"]["uid"].get<std::string>(),jobj["args"]["jid"].get<std::string>(), wrap(bind2f(&biz_lower_impl::send_file_to_cb,this,jobj,_1,_2,_3)),true);
		biz_.get_roster().UpdateRecentContact( jobj["args"]["jid"].get<std::string>(), kRecentContact);
	}
	void biz_lower_impl::send_file_to_cb( json::jobject jobj, bool err, universal_resource res, std::string filename )
	{
		if (err)
		{
			jobj["result"] = "fail";
			jobj["reason"] = res.res_value_utf8;
		}
		else
		{
			// 统计成功发送文件个数
			g_statistics_data::instance().add_data("send_file_count", 1);
			jobj["result"] = "success";
			jobj["filename"] = filename;
			biz_.get_private().delete_local_data("upload_" + filename,boost::function<void(bool err, universal_resource res)>());
		}
		cmd_factory::instance().callback(jobj);
	}
	void biz_lower_impl::download_file( json::jobject jobj )
	{
		if(!jobj || !jobj["args"] || !jobj["args"]["file"]|| !jobj["args"]["length"]|| !jobj["args"]["uri"]|| !jobj["args"]["uid"]|| !jobj["args"]["jid"])return;
		std::string path = jobj["args"]["file"].get<std::string>();
		path = file_manager::instance().format_recvFile_path(path);
		jobj["file"] = path;				
		std::string relative_path = anan_config::instance().get_file_download_path();
		if(!jobj["args"].is_nil("type"))
		{
			std::string	typestr = jobj["args"]["type"].get();			
			if (typestr == "update")
			{
				relative_path = anan_config::instance().get_whistle_update_uri();
			}
			else if(typestr == "image")
			{
				relative_path = anan_config::instance().get_http_down_path();
			}
		}	
		file_transfer::instance().download_file(path, jobj["args"]["length"].get<boost::uintmax_t>(),relative_path,jobj["args"]["uri"].get<std::string>(), jobj["args"]["uid"].get<std::string>(), wrap(bind2f(&biz_lower_impl::download_file_cb,this,jobj,_1,_2,_3)));
	}

	void biz_lower_impl::file_transfer_status( json::jobject jobj )
	{
		if (jobj["trans_type"].get<string>()=="upload")
		{
			biz_.get_private().store_local_data("upload_" + jobj["uri"].get<string>()+jobj["jid"].get<string>(), jobj["transfer_size"].get<string>(),boost::function<void(bool err, universal_resource res)>());
		}
		adapt_->file_transfer_status(jobj);
	}

	void biz_lower_impl::cancel_transfer_file( json::jobject jobj )
	{
		if(!jobj || !jobj["args"] || !jobj["args"]["uid"])
		{
			return;
		}
		file_transfer::instance().cancel_transfer_file(jobj["args"]["uid"].get<std::string>());
	}

	void biz_lower_impl::save_file_transfer_msg( json::jobject jobj )
	{
		if(!jobj || !jobj["args"]|| !jobj["args"]["msg"]|| !jobj["args"]["jid"])
		{
			jobj["result"] = "fail";
			cmd_factory::instance().callback(jobj);
			return;
		}
		boost::function<void(json::jobject)> callback = [=](json::jobject msg) mutable
		{
			jobj["result"] = "success";
			jobj["rowid"] = msg["rowid"];
			cmd_factory::instance().callback(jobj);
		};
		biz_.get_localconfig().saveFileTransferMsg(jobj["args"]["jid"].get<std::string>(), jobj["args"]["msg"].to_string(), callback);
	}

	void biz_lower_impl::download_file_cb( json::jobject jobj, bool err, universal_resource res, std::string filename )
	{
		if (err)
		{
			jobj["result"] = "fail";
			jobj["reason"] = res.res_value_utf8;
		}
		else
		{
			// 统计成功接收文件个数
			g_statistics_data::instance().add_data("recv_file_count", 1);

			// 统计接收文件大小(按K字节计算)
			g_statistics_data::instance().add_data("recv_file_size", (int)(jobj["args"]["length"].get<boost::uintmax_t>()/1024));

			// 统计接收文件大小(实际接收大小 按K字节计算)
			g_statistics_data::instance().add_data("recv_file_actual_size", (int)(jobj["args"]["length"].get<boost::uintmax_t>()/1024));

			jobj["result"] = "success";
			jobj["filename"] = filename;
		}
		cmd_factory::instance().callback(jobj);
	}

	
	void biz_lower_impl::user_can_change_password_cb( json::jobject jobj, bool can_change )
	{
		jobj["can_change_password"] = can_change;
		cmd_factory::instance().callback(jobj);
	}
	void biz_lower_impl::user_can_change_password( json::jobject jobj )
	{
		biz_.get_login().user_can_change_password(wrap(bind2f(&biz_lower_impl::user_can_change_password_cb, this, jobj, _1)));
	}

	void biz_lower_impl::get_change_password_uri( json::jobject jobj )
	{
		jobj["change_password_uri"] = anan_config::instance().get_whistle_change_password_uri();
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::get_token( json::jobject jobj )
	{
		if(!jobj["args"] )
		{
			jobj["result"] = "fail";
			jobj["reason"] = XL("get_token.no_args").res_value_utf8;
			cmd_factory::instance().callback(jobj);
			return;
		}

		std::string service_id = jobj["args"]["service_id"].get<std::string>();
		if (service_id.empty())
		{
			service_id = "null";
		}
		std::map<std::string,json::jobject>::iterator it = token_.find(service_id);
		if(it == token_.end() || (jobj["args"]&&jobj["args"]["force_new"].get<bool>()) || (it!=token_.end() && it->second.is_nil("expires_in")))
		{
			time_mgr::instance().set_timer(jobj["aux"]["from"].get<std::string>(), 5*1000, wrap(bind2f(&biz_lower_impl::get_token_overtime, this, jobj)));
			gWrapInterface::instance().get_token(service_id, wrap(bind2f(&biz_lower_impl::response_token, this, jobj, _1, _2, _3)));
		}
		else
		{
			response_token(jobj, false, XL(""), it->second);
		}
	}

	void biz_lower_impl::response_token( json::jobject jobj, bool err, universal_resource reason, json::jobject data )
	{
		if(err)
		{
			jobj["result"] = "fail";
			jobj["reason"] = reason.res_value_utf8;
		}
		else
		{
			std::string service_id = jobj["args"]["service_id"].get<std::string>();
			if (service_id.empty())
			{
				service_id = "null";
			}
			jobj["token"] = data["access_token"];
			jobj["expires_in"] = data["expires_in"];
			time_mgr::instance().set_timer(1000*data["expires_in"].get<int>(), wrap(bind2f(&biz_lower_impl::reset_token, this, service_id)));
			std::pair< std::map<std::string,json::jobject>::iterator,bool > ret = token_.insert(make_pair(service_id, data.clone()));
			if ( !ret.second)
			{
				ret.first->second = data.clone();
			}
		}
		time_mgr::instance().kill_timer(jobj["aux"]["from"].get<std::string>());
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::get_token_overtime( json::jobject jobj )
	{
		jobj["result"] = "fail";
		jobj["reason"] = XL("biz.get_token_overtime").res_value_utf8;
		cmd_factory::instance().callback(jobj);
		return;
	}

	void biz_lower_impl::reset_token( std::string service_id)
	{
		std::map<std::string,json::jobject>::iterator it = token_.find(service_id);
		if (it != token_.end())
		{
			token_.erase(it);
		}
	}

	void biz_lower_impl::get_curriculum_uri( json::jobject jobj )
	{
		jobj["curriculum_uri"] = anan_config::instance().get_whistle_curriculum_uri();
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::get_my_app( json::jobject jobj )
	{
		static vector<string> platform_list = list_of("pc")("android")("ios");
		if(!jobj["args"] || !jobj["args"]["platform"])
		{
			jobj["result"] = "fail";
			jobj["reason"] = XL("get_my_app.params_not_specify_platform").res_value_utf8;
			cmd_factory::instance().callback(jobj);
			return;
		}
		std::string platform = jobj["args"]["platform"].get<string>();
		if(std::find(platform_list.begin(),platform_list.end(),platform)==platform_list.end())
		{
			jobj["result"] = "fail";
			jobj["reason"] = XL("get_my_app.unsuport_platform").res_value_utf8;
			cmd_factory::instance().callback(jobj);
		}
		else
		{
			std::string store_key = "my_apps." + platform;
			biz_.get_private().get_local_data(store_key,wrap(bind2f(&biz_lower_impl::get_my_app_callback,this,jobj,platform,_1,_2,_3)));
		}
	}

	void biz_lower_impl::get_my_app_callback( json::jobject jobj, std::string platform, bool error, universal_resource res, string data )
	{
		jobj["result"] = "success";
		if(!data.empty())
		{
			jobj["data"] = json::jobject(data);
		}
		else
		{
			std::string app_path = anan_config::instance().get_app_path(platform);
			json::jobject cfg_obj = json::from_file(app_path);
			jobj["data"] = cfg_obj["default"].clone();
		}
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::save_my_app( json::jobject jobj )
	{
		static vector<string> platform_list = list_of("pc")("android")("ios");
		if(!jobj["args"] || !jobj["args"]["platform"] || !jobj["args"]["data"])
		{
			jobj["result"] = "fail";
			jobj["reason"] = XL("save_my_app.params_not_specify_platform").res_value_utf8;
			cmd_factory::instance().callback(jobj);
			return;
		}
		std::string platform = jobj["args"]["platform"].get<string>();
		if(std::find(platform_list.begin(),platform_list.end(),platform)==platform_list.end())
		{
			jobj["result"] = "fail";
			jobj["reason"] = XL("get_all_my_app.unsuport_platform").res_value_utf8;
			cmd_factory::instance().callback(jobj);
		}
		else
		{
			std::string store_key = "my_apps." + platform;
			biz_.get_private().store_local_data(store_key, jobj["args"]["data"].to_string(),wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
		}
	}

	void biz_lower_impl::get_all_app( json::jobject jobj )
	{
		static vector<string> platform_list = list_of("pc")("android")("ios");
		if(!jobj["args"] || !jobj["args"]["platform"])
		{
			jobj["result"] = "fail";
			jobj["reason"] = XL("get_all_app.params_not_specify_platform").res_value_utf8;
			cmd_factory::instance().callback(jobj);
			return;
		}
		std::string platform = jobj["args"]["platform"].get<string>();
		if(std::find(platform_list.begin(),platform_list.end(),platform)==platform_list.end())
		{
			jobj["result"] = "fail";
			jobj["reason"] = XL("get_all_app.unsuport_platform").res_value_utf8;
			cmd_factory::instance().callback(jobj);
		}
		else
		{
			std::string app_path = anan_config::instance().get_app_path(platform);
			json::jobject cfg_obj = json::from_file(app_path);
			jobj["data"] = cfg_obj["all"].clone();
		}
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::get_app_name_cfg( json::jobject jobj )
	{
		json::jobject data = anan_config::instance().get_app_name_cfg();
		jobj["data"] = data;
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::get_auth_eportal_label( json::jobject jobj )
	{
		jobj["label"] = anan_config::instance().get_auth_eportal_label();
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::get_auth_sam_label( json::jobject jobj )
	{
		jobj["label"] = anan_config::instance().get_auth_sam_label();
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::is_file_exist( json::jobject jobj )
	{
		if(jobj.is_nil("args") || jobj["args"].is_nil("file_path"))
		{
			jobj["result"] = "fail";
			jobj["reason"] = XL("biz.is_file_exist.param_not_right").res_value_utf8;
		}
		else
		{
			jobj["result"] = "success";
			jobj["is_exist"] = epfilesystem::instance().file_exists(jobj["args"]["file_path"].get<std::string>());
		}
		cmd_factory::instance().callback(jobj);
	}

#ifdef _WIN32
	void biz_lower_impl::courses_timestamp( json::jobject jobj )
	{
		courses::instance().get_courses_timestamp(wrap(bind2f(&biz_lower_impl::courses_timestamp_cb,this,jobj,_1,_2)));
	}

	void biz_lower_impl::courses_timestamp_cb( json::jobject jobj, bool succ, std::string timestamp )
	{
		if (succ)
		{
			jobj["timestamp"] = timestamp;
		}

		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::courses_storager( json::jobject jobj )
	{
		if(jobj.is_nil("args") || jobj["args"].is_nil("courses"))
		{
			jobj["result"] = "fail";
			cmd_factory::instance().callback(jobj);
			return;
		}

		courses::instance().courses_storager(jobj["args"]["courses"], wrap(bind2f(&biz_lower_impl::courses_storager_cb,this,jobj,_1)));
	}

	void biz_lower_impl::courses_storager_cb( json::jobject jobj, bool succ )
	{
		if (succ)
		{
			jobj["result"] = "success";
		}
		else
		{
			jobj["result"] = "fail";
		}

		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::courses_search( json::jobject jobj )
	{
		if(jobj.is_nil("args") || jobj["args"].is_nil("day") || jobj["args"].is_nil("lesson") || jobj["args"].is_nil("name"))
		{
			jobj["result"] = "fail";
			cmd_factory::instance().callback(jobj);
			return;
		}

		int day = jobj["args"]["day"].get<int>();
		int lesson = jobj["args"]["lesson"].get<int>();
		std::string name = jobj["args"]["name"].get<std::string>();
		courses::instance().courses_search(day, lesson, name , wrap(bind2f(&biz_lower_impl::courses_search_cb,this,jobj,_1,_2)));
	}

	void biz_lower_impl::courses_search_cb( json::jobject jobj, bool succ, json::jobject data )
	{
		if (succ)
		{
			jobj["result"] = "success";
			jobj["courses"] = data;
		}
		else
		{
			jobj["result"] = "fail";
		}
		cmd_factory::instance().callback(jobj);
	}

#endif
	void biz_lower_impl::get_zodiac( json::jobject jobj )
	{
		if(!jobj.is_nil("args") && !jobj["args"].is_nil("day"))
		{
			std::string day = jobj["args"]["day"].get<std::string>(); // YYYY-MM-DD
			if (day.length() == 10)
			{

				std::string cur_time = biz_.get_localconfig().getCurrentTime(); // YYYY-MM-DD hh:mm:ss
				struct time_ymd {int y,m,d;} b,c;
				b.y = boost::lexical_cast<int>(day.substr(0, 4));
				b.m = boost::lexical_cast<int>(day.substr(5, 2));
				b.d = boost::lexical_cast<int>(day.substr(8, 2));
				c.y = boost::lexical_cast<int>(cur_time.substr(0, 4));
				c.m = boost::lexical_cast<int>(cur_time.substr(5, 2));
				c.d = boost::lexical_cast<int>(cur_time.substr(8, 2));

				int age = 0;
				if (c.y < b.y || c.y == b.y && c.m < b.m || c.y == b.y && c.m == b.m && c.d < b.d)
				{
					age = 0;
				}
				else
				{
					age = c.y - b.y;
					if (c.m < b.m || c.m == b.m && c.d < b.d)
					{
						--age;
					}
				}

				ConvDate cd;
				cd.Source = 0;
				cd.SolarYear = boost::lexical_cast<int>(day.substr(0,4));
				cd.SolarMonth = boost::lexical_cast<int>(day.substr(5,2));
				cd.SolarDay = boost::lexical_cast<int>(day.substr(8,2));

				if (!CalConv(&cd))
				{
					jobj["zh_zodiac"] = gwhistleVcard::instance().zh_zodiacYear_utf8(cd.LunarYear);
					jobj["zodiac"] = gwhistleVcard::instance().zodiacYear_by_XL(cd.SolarMonth, cd.SolarDay);
					jobj["age"] = age;
					jobj["result"] = "success";
					cmd_factory::instance().callback(jobj);
					return;
				}

			}
		}
		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
		return;
	}

	void biz_lower_impl::replace_message_by_rowid( json::jobject jobj )
	{
		if(!jobj.is_nil("args") && !jobj["args"].is_nil("type") && !jobj["args"].is_nil("rowid") && !jobj["args"].is_nil("msg"))
		{
			std::string type = jobj["args"]["type"].get<std::string>();
			std::string rowid = jobj["args"]["rowid"].get<std::string>();
			std::string msg = jobj["args"]["msg"].to_string();

			biz_.get_localconfig().replaceMessageByRowid(type, rowid, msg, wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
			return;
		}
		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
		return;
	}

	void biz_lower_impl::get_recent_app_messages( json::jobject jobj )
	{
		biz_.get_localconfig().GetRecentAppMessages(wrap(bind2f(&biz_lower_impl::get_recent_app_messages_cb,this,jobj,_1,_2)));
	}

	void biz_lower_impl::get_recent_app_messages_cb( json::jobject jobj, bool err, json::jobject data )
	{
		if (err)
		{
			jobj["result"] = "fail";
			jobj["reason"] = "";
		}
		else
		{
			jobj["result"] = "success";
			jobj["msgs"] = data;
		}
		cmd_factory::instance().callback(jobj);
	}


	void biz_lower_impl::get_app_message_history( json::jobject jobj )
	{
		if(!jobj.is_nil("args") && !jobj["args"].is_nil("id") && !jobj["args"].is_nil("begin_idx") && !jobj["args"].is_nil("count"))
		{
			std::string id = jobj["args"]["id"].get<std::string>();
			int begin_idx = jobj["args"]["begin_idx"].get<int>();
			int count = jobj["args"]["count"].get<int>();
			biz_.get_localconfig().GetAppMessageHistory(id, begin_idx, count, wrap(bind2f(&biz_lower_impl::get_app_message_history_cb,this,jobj,_1,_2)));
			return;
		}

		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
		return;
	}

	void biz_lower_impl::get_app_message_list( json::jobject jobj )
	{
		if(!jobj.is_nil("args")  && !jobj["args"].is_nil("begin_idx") && !jobj["args"].is_nil("count"))
		{
			int begin_idx = jobj["args"]["begin_idx"].get<int>();
			int count = jobj["args"]["count"].get<int>();
			biz_.get_localconfig().GetAppMessageHistory("", begin_idx, count, wrap(bind2f(&biz_lower_impl::get_app_message_history_cb,this,jobj,_1,_2)));
			return;
		}

		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
		return;
	}


	void biz_lower_impl::get_lightapp_message_history( json::jobject jobj )
	{
		if(!jobj.is_nil("args") && !jobj["args"].is_nil("appid") && !jobj["args"].is_nil("begin_idx") && !jobj["args"].is_nil("count"))
		{
			std::string appid = jobj["args"]["appid"].get<std::string>();
			int begin_idx = jobj["args"]["begin_idx"].get<int>();
			int count = jobj["args"]["count"].get<int>();
			biz_.get_localconfig().GetLightappMessageHistory(appid, begin_idx, count, wrap(bind2f(&biz_lower_impl::get_app_message_history_cb,this,jobj,_1,_2)));
			return;
		}

		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
		return;
	}

	void biz_lower_impl::get_app_message_history_cb( json::jobject jobj, bool err, json::jobject data )
	{
		if (err)
		{
			jobj["result"] = "fail";
			jobj["reason"] = "";
		}
		else
		{
			jobj["result"] = "success";
			jobj["msgs"] = data["msgs"];
			jobj["count_all"] = data["count_all"];
		}
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::mark_app_message_read( json::jobject jobj )
	{
		if(!jobj.is_nil("args") && (!jobj["args"].is_nil("id") || !jobj["args"].is_nil("message_id")))
		{
			std::string service_id = jobj["args"]["id"].get<std::string>();
			std::string message_id = jobj["args"]["message_id"].get<std::string>();

			biz_.get_localconfig().MarkAppMessage(service_id, message_id, wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));

			return;
		}
		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
		return;
	}

	void biz_lower_impl::delete_app_message( json::jobject jobj )
	{
		if(!jobj.is_nil("args") && !jobj["args"].is_nil("id"))
		{
			std::string id = jobj["args"]["id"].get<std::string>();

			biz_.get_localconfig().DeleteAppMessageByServiceID(id, wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));

			return;
		}
		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
		return;
	}

	void biz_lower_impl::delete_one_app_message( json::jobject jobj )
	{
		if(!jobj.is_nil("args") && !jobj["args"].is_nil("message_id"))
		{
			std::string message_id = jobj["args"]["message_id"].get<std::string>();

			biz_.get_localconfig().DeleteAppMessageByID(message_id, wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));

			return;
		}
		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
		return;
	}

	void biz_lower_impl::delete_all_app_message( json::jobject jobj )
	{
		biz_.get_localconfig().DeleteAllAppMessageByID(wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
	}

	void biz_lower_impl::delete_all_readed_app_message( json::jobject jobj )
	{
		biz_.get_localconfig().DeleteAllReadedAppMessage(wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
	}

	void biz_lower_impl::get_unread_app_message( json::jobject jobj )
	{
		if(!jobj.is_nil("args") && !jobj["args"].is_nil("id"))
		{
			std::string id = jobj["args"]["id"].get<std::string>();

			biz_.get_localconfig().GetUnreadAppMessage(id, wrap(bind2f(&biz_lower_impl::get_unread_app_message_cb,this,jobj,_1,_2)));
			return;
		}

		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
		return;
	}

	void biz_lower_impl::get_unread_app_message_cb( json::jobject jobj, bool err, json::jobject data )
	{
		if (err)
		{
			jobj["result"] = "fail";
			jobj["reason"] = "";
		}
		else
		{
			jobj["result"] = "success";
			jobj["msgs"] = data;
			jobj["count_all"] = data["count_all"];
		}
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::get_all_unread_app_message ( json::jobject jobj )
	{
		bool count_only = false;
		
		if (!jobj.is_nil("args") && !jobj["args"].is_nil("count_only"))
		{
			count_only = jobj["args"]["count_only"].get<bool>();
		}

		biz_.get_localconfig().loadAllUnreadAppMessage(count_only, wrap(bind2f(&biz_lower_impl::get_unread_app_message_cb,this,jobj,_1,_2)));
	}

	void biz_lower_impl::download_lightapp_resources( json::jobject jobj )
	{
		if(!jobj.is_nil("args") && (!jobj["args"].is_nil("uri")||!jobj["args"].is_nil("url")))
		{
			if (!jobj["args"].is_nil("uri"))
			{
				g_lightapp::instance().download_lightapp_resources( jobj["args"]["uri"].get<std::string>(), true, wrap(bind2f(&biz_lower_impl::download_lightapp_resources_cb,this,jobj,_1,_2,_3)));
			}
			else if(!jobj["args"].is_nil("url"))
			{
				g_lightapp::instance().download_lightapp_resources( jobj["args"]["url"].get<std::string>(), false, wrap(bind2f(&biz_lower_impl::download_lightapp_resources_cb,this,jobj,_1,_2,_3)));
			}
			return;
		}
		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
	}
	void biz_lower_impl::download_lightapp_resources_cb(json::jobject jobj, bool err, universal_resource reason, std::string local_path)
	{
		if (!err)
		{
			jobj["result"] = "fail";
			jobj["reason"] = reason.res_value_utf8;
		}
		else
		{
			jobj["result"] = "success";
			jobj["local_path"] = local_path;
		}
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::get_crowd_list( json::jobject jobj )
	{
		g_crowd::instance().get_crowd_list(wrap(bind2f(&biz_lower_impl::get_crowd_list_cb,this,jobj,_1,_2,_3)));
	}

	void biz_lower_impl::get_crowd_list_cb( json::jobject jobj, bool err, universal_resource reason, json::jobject data )
	{
		if (err)
		{
			jobj["result"] = "fail";
			jobj["reason"] = reason.res_value_utf8;
		}
		else
		{
			jobj["result"] = "success";
			jobj["crowd_list"] = data;
		}
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::get_crowd_member_list( json::jobject jobj )
	{
		if(!jobj.is_nil("args") && !jobj["args"].is_nil("session_id"))
		{
			std::string session_id = jobj["args"]["session_id"].get<std::string>();
			std::string role = jobj["args"]["role"].get<std::string>();
			g_crowd::instance().get_crowd_member_list(session_id , role , wrap(bind2f(&biz_lower_impl::get_crowd_member_list_cb,this,jobj,_1,_2,_3)));
			return;
		}

		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
	}
	void biz_lower_impl::get_crowd_member_list_cb( json::jobject jobj, bool err, universal_resource reason, json::jobject data )
	{
		if (err)
		{
			jobj["result"] = "fail";
			jobj["reason"] = reason.res_value_utf8;
		}
		else
		{
			jobj["result"] = "success";
			jobj["member_list"] = data;
		}
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::get_crowd_info( json::jobject jobj )
	{
		if(!jobj.is_nil("args") && !jobj["args"].is_nil("session_id"))
		{
			std::string session_id = jobj["args"]["session_id"].get<std::string>();
			g_crowd::instance().get_crowd_info(session_id, wrap(bind2f(&biz_lower_impl::get_crowd_info_cb,this,jobj,_1,_2,_3)));
			return;
		}

		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::get_crowd_info_cb( json::jobject jobj, bool err, universal_resource reason, json::jobject data )
	{
		if (err)
		{
			jobj["result"] = "fail";
			jobj["reason"] = reason.res_value_utf8;
		}
		else
		{
			jobj["result"] = "success";
			jobj["info"] = data;
		}
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::set_crowd_info( json::jobject jobj )
	{
		if(!jobj.is_nil("args") && !jobj["args"].is_nil("session_id"))
		{
			std::string session_id = jobj["args"]["session_id"].get<std::string>();
			
			
			g_crowd::instance().set_crowd_info(session_id,  jobj["args"], wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
			return;
		}

		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::leave_crowd( json::jobject jobj )
	{
		if(!jobj.is_nil("args") && !jobj["args"].is_nil("session_id"))
		{
			std::string session_id = jobj["args"]["session_id"].get<std::string>();		
			g_crowd::instance().leave_crowd(session_id, wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
			return;
		}
		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::open_crowd_window( json::jobject jobj )
	{
		if(!jobj.is_nil("args") && !jobj["args"].is_nil("session_id"))
		{
			std::string session_id = jobj["args"]["session_id"].get<std::string>();

			g_crowd::instance().open_crowd_window(session_id, wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
			return;
		}
		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::close_crowd_window( json::jobject jobj )
	{
		if(!jobj.is_nil("args") && !jobj["args"].is_nil("session_id"))
		{
			std::string session_id = jobj["args"]["session_id"].get<std::string>();

			g_crowd::instance().close_crowd_window(session_id);
		}
	}

	void biz_lower_impl::get_crowd_file_list( json::jobject jobj )
	{
		if(!jobj.is_nil("args") && !jobj["args"].is_nil("session_id") && !jobj["args"].is_nil("orderby"))
		{
			std::string session_id = jobj["args"]["session_id"].get<std::string>();
			std::string orderby = jobj["args"]["orderby"].get<std::string>();

			g_crowd::instance().get_crowd_file_list(session_id, orderby, wrap(bind2f(&biz_lower_impl::get_crowd_file_list_cb,this,jobj,_1,_2,_3)));
			return;
		}
		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::get_crowd_file_list_cb( json::jobject jobj, bool err, universal_resource reason, json::jobject data )
	{
		if (err)
		{
			jobj["result"] = "fail";
			jobj["reason"] = reason.res_value_utf8;
		}
		else
		{
			jobj["result"] = "success";
			jobj["list"] = data["list"];
			jobj["set"] = data["set"];
		}
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::upload_crowd_file( json::jobject jobj )
	{
		if(!jobj.is_nil("args") && !jobj["args"].is_nil("session_id") && !jobj["args"].is_nil("file") && !jobj["args"].is_nil("uid"))
		{
			std::string session_id = jobj["args"]["session_id"].get<std::string>();
			std::string file = jobj["args"]["file"].get<std::string>();
			std::string uid = jobj["args"]["uid"].get<std::string>();

			g_crowd::instance().upload_crowd_file(session_id, file, uid, wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
			return;
		}
		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::download_crowd_file( json::jobject jobj )
	{
		if(!jobj.is_nil("args") && !jobj["args"].is_nil("session_id") && !jobj["args"].is_nil("file") && !jobj["args"].is_nil("uid")  && !jobj["args"].is_nil("uri") && !jobj["args"].is_nil("id"))
		{
			std::string session_id = jobj["args"]["session_id"].get<std::string>();
			std::string file = jobj["args"]["file"].get<std::string>();
			std::string uid = jobj["args"]["uid"].get<std::string>();
			std::string uri = jobj["args"]["uri"].get<std::string>();
			std::string id = jobj["args"]["id"].get<std::string>();
			g_crowd::instance().download_crowd_file(session_id, id,  uri,  uid, file ,wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
			return;
		}
		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::remove_crowd_file( json::jobject jobj )
	{
		if(!jobj.is_nil("args") && !jobj["args"].is_nil("session_id") && !jobj["args"].is_nil("id"))
		{
			std::string session_id = jobj["args"]["session_id"].get<std::string>();
			std::string id = jobj["args"]["id"].get<std::string>();
			g_crowd::instance().remove_crowd_file(session_id, id, wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
			return;
		}

		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::set_crowd_alert( json::jobject jobj )
	{
		if(!jobj.is_nil("args") && !jobj["args"].is_nil("session_id") && !jobj["args"].is_nil("alert"))
		{
			std::string session_id = jobj["args"]["session_id"].get<std::string>();
			std::string alert = jobj["args"]["alert"].get<std::string>();

			g_crowd::instance().set_crowd_alert(session_id, alert, wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
			return;
		}

		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::find_crowd( json::jobject jobj )
	{
		if(!jobj || !jobj["args"])
		{
			jobj["result"] = "fail";
			cmd_factory::instance().callback(jobj);
			return;
		}

		g_crowd::instance().find_crowd(jobj,wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,_3,_1,_2)));
	}


	void biz_lower_impl::apply_join_crowd( json::jobject jobj )
	{
		if(!jobj.is_nil("args") && !jobj["args"].is_nil("session_id"))
		{
			std::string session_id = jobj["args"]["session_id"].get<std::string>();
			std::string reason = jobj["args"]["reason"].get<std::string>();
			g_crowd::instance().apply_join_crowd(session_id, reason, wrap(bind2f(&biz_lower_impl::apply_join_crowd_cb,this,jobj,_1,_2,_3)));
			return;
		}
		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::apply_join_crowd_cb( json::jobject jobj, bool err, universal_resource reason, json::jobject data )
	{
		if (err)
		{
			jobj["result"] = "fail";
			jobj["reason"] = reason.res_value_utf8;
		}
		else
		{
			jobj["result"] = "success";
			jobj["list"] = data;
		}
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::crowd_list_changed( json::jobject jobj )
	{
		adapt_->crowd_list_changed(jobj);
	}

	void biz_lower_impl::crowd_member_changed( json::jobject jobj )
	{
		adapt_->crowd_member_changed(jobj);
	}

	void biz_lower_impl::crowd_info_changed( json::jobject jobj )
	{
		adapt_->crowd_info_changed(jobj);
	}

	void biz_lower_impl::crowd_file_changed( json::jobject jobj )
	{
		adapt_->crowd_file_changed(jobj);
	}

	void biz_lower_impl::crowd_alert_changed( json::jobject jobj )
	{
		adapt_->crowd_alert_changed(jobj);
	}

	void biz_lower_impl::recv_quit_crowd_ack( json::jobject jobj )
	{
		adapt_->recv_quit_crowd_ack(jobj);
	}
	void biz_lower_impl::recv_apply_join_crowd_response( json::jobject jobj )
	{
		adapt_->recv_apply_join_crowd_response(jobj);
	}
	void biz_lower_impl::create_crowd( json::jobject jobj )
	{
		if(!jobj.is_nil("args") && !jobj["args"].is_nil("name")&& !jobj["args"].is_nil("auth_type")&& !jobj["args"].is_nil("category"))
		{
			json::jobject crowd_detail  = jobj["args"].clone();
			g_crowd::instance().create_crowd(crowd_detail, wrap(bind2f(&biz_lower_impl::create_crowd_cb,this,jobj,_1,_2,_3)));
			return;
		}
		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::create_crowd_cb( json::jobject jobj, bool err, universal_resource reason, json::jobject data )
	{
		if (err)
		{
			jobj["result"] = "fail";
			jobj["reason"] = reason.res_value_utf8;
		}
		else
		{
			jobj["result"] = "success";
			jobj["crowd_info"] = data;
		}
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::dismiss_crowd( json::jobject jobj )
	{
		if(!jobj.is_nil("args") && !jobj["args"].is_nil("session_id"))
		{
			std::string session_id  = jobj["args"]["session_id"].get<std::string>();
			g_crowd::instance().dismiss_crowd(session_id, wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
			return;
		}
		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::crowd_member_kickout( json::jobject jobj )
	{
		if(!jobj.is_nil("args")&&!jobj["args"].is_nil("session_id")&&!jobj["args"].is_nil("jid"))
		{
			std::string session_id  = jobj["args"]["session_id"].get<std::string>();
			std::string jid  = jobj["args"]["jid"].get<std::string>();
			std::string name  = jobj["args"]["name"].get<std::string>();

			g_crowd::instance().crowd_kickout_member(session_id , jid , name, wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
			return;
		}
		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::set_crowd_file_info( json::jobject jobj )
	{
		if(!jobj.is_nil("args") && !jobj["args"].is_nil("session_id")&& !jobj["args"].is_nil("id"))
		{
			std::string session_id  = jobj["args"]["session_id"].get<std::string>();
			std::string id  = jobj["args"]["id"].get<std::string>();
			std::string mode= jobj["args"]["mode"].get<std::string>();
			g_crowd::instance().set_crowd_file_info(session_id,id,mode,wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
			return;
		}
		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::crowd_apply_superadmin( json::jobject jobj )
	{
		if(!jobj.is_nil("args") && !jobj["args"].is_nil("session_id"))
		{
			std::string session_id  = jobj["args"]["session_id"].get<std::string>();
			std::string reason= jobj["args"]["reason"].get<std::string>();
			g_crowd::instance().crowd_apply_superadmin(session_id , reason , wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
			return;
		}
		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::answer_apply_join_crowd( json::jobject jobj )
	{
		if(!jobj.is_nil("args") && !jobj["args"].is_nil("session_id")&& !jobj["args"].is_nil("actor_jid")&& !jobj["args"].is_nil("accept"))
		{
			std::string session_id  = jobj["args"]["session_id"].get<std::string>();
			json::jobject actor;
			actor["jid"]= jobj["args"]["actor_jid"].get<std::string>();
			actor["name"]= jobj["args"]["actor_name"].get<std::string>();
			actor["icon"]= jobj["args"]["actor_icon"].get<std::string>();
			actor["sex"]= jobj["args"]["actor_sex"].get<std::string>();
			actor["identity"]= jobj["args"]["actor_identity"].get<std::string>();
			std::string accept= jobj["args"]["accept"].get<std::string>();
			std::string reason= jobj["args"]["reason"].get<std::string>();
			std::string admin_reason= jobj["args"]["admin_reason"].get<std::string>();
			std::string rowid= jobj["args"]["rowid"].get<std::string>();
			g_crowd::instance().answer_apply_join_crowd(session_id , accept , rowid , actor , reason , admin_reason , wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
			return;
		}
		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::crowd_role_change( json::jobject jobj )
	{
		if(!jobj.is_nil("args") && !jobj["args"].is_nil("session_id"))
		{
			std::string session_id  = jobj["args"]["session_id"].get<std::string>();
			std::string jid  = jobj["args"]["jid"].get<std::string>();
			std::string role= jobj["args"]["role"].get<std::string>();
			g_crowd::instance().crowd_role_change(session_id  ,jid,role,wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
			return;
		}
		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::crowd_member_role_changed( json::jobject jobj )
	{
		adapt_->crowd_member_role_changed(jobj);
	}

	void biz_lower_impl::crowd_role_changed( json::jobject jobj )
	{
		adapt_->crowd_role_changed(jobj);
	}

	void biz_lower_impl::crowd_superadmin_applyed( json::jobject jobj )
	{
		adapt_->crowd_superadmin_applyed(jobj);
	}

	void biz_lower_impl::crowd_superadmin_applyed_response( json::jobject jobj )
	{
		adapt_->crowd_superadmin_applyed_response(jobj);
	}
	void biz_lower_impl::crowd_create_success( json::jobject jobj )
	{
		adapt_->crowd_create_success(jobj);
	}

	void biz_lower_impl::apply_join_groups_accepted_msg( json::jobject jobj )
	{
		adapt_->apply_join_groups_accepted_msg(jobj);
	}

	void biz_lower_impl::invite_into_crowd( json::jobject jobj )
	{
		if(!jobj.is_nil("args") && !jobj["args"].is_nil("session_id")&& !jobj["args"].is_nil("jid"))
		{
			std::string session_id  = jobj["args"]["session_id"].get<std::string>();
			std::string jid = jobj["args"]["jid"].get<std::string>();

			g_crowd::instance().invite_into_crowd(session_id  , jid, wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
			return;
		}
		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
	}
	 
	void biz_lower_impl::answer_crowd_invite( json::jobject jobj )
	{
		if(!jobj.is_nil("args")&& !jobj["args"].is_nil("rowid") && !jobj["args"].is_nil("session_id")&& !jobj["args"].is_nil("jid")&& !jobj["args"].is_nil("accept"))
		{
			g_crowd::instance().answer_crowd_invite(jobj["args"], wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
			return;
		}
		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::crowd_role_demise( json::jobject jobj )
	{
		if(!jobj.is_nil("args") && !jobj["args"].is_nil("session_id")&&!jobj["args"].is_nil("jid"))
		{
			std::string session_id  = jobj["args"]["session_id"].get<std::string>();
			std::string jid= jobj["args"]["jid"].get<std::string>();
			std::string name= jobj["args"]["name"].get<std::string>();

			g_crowd::instance().crowd_role_demise(session_id  , jid  , name , wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
			return;
		}
		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::crowd_system_message( json::jobject jobj )
	{
			adapt_->crowd_system_message(jobj);
	}

	void biz_lower_impl::get_create_crowd_setting( json::jobject jobj )
	{
		g_crowd::instance().get_create_crowd_setting( wrap(bind2f(&biz_lower_impl::get_create_crowd_setting_cb,this,jobj,_1,_2,_3)));
	}
	void biz_lower_impl::get_create_crowd_setting_cb( json::jobject jobj, bool err, universal_resource reason, json::jobject data )
	{
		if (err)
		{
			jobj["result"] = "fail";
			jobj["reason"] = reason.res_value_utf8;
		}
		else
		{
			jobj["result"] = "success";
			jobj["create_enable"] = data["create_enable"];
			jobj["can_create"] = data["can_create"];
			jobj["max_member"] = data["max_member"];
			jobj["max_can_create"] = data["max_can_create"];
		}
		cmd_factory::instance().callback(jobj);
	}


	void biz_lower_impl::connected()
	{
		token_.clear();		
		adapt_->connected(biz_.get_user().get_user().sam_id);
	}

	void biz_lower_impl::disconnected(universal_resource resource)
	{
		adapt_->disconnected(resource,  biz_.get_user().get_user().sam_id);
	}

	void biz_lower_impl::connecting()
	{
		adapt_->connecting();
	}

	void biz_lower_impl::set_crowd_member_info( json::jobject jobj )
	{
		if(!jobj.is_nil("args") && !jobj["args"].is_nil("session_id"))
		{
			std::string session_id  = jobj["args"]["session_id"].get<std::string>();
			g_crowd::instance().set_crowd_member_info(session_id  ,jobj["args"] , wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
			return;
		}
		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::get_crowd_policy( json::jobject jobj )
	{
		jobj["crowd_policy"] = anan_config::instance().get_crowd_policy();
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::get_crowd_vote( json::jobject jobj )
	{
		jobj["crowd_vote"] = anan_config::instance().get_crowd_vote();
		cmd_factory::instance().callback(jobj);
	}
	
	void biz_lower_impl::get_growth_info_url( json::jobject jobj )
	{
		jobj["growth_info_url"] = anan_config::instance().get_growth_info_url();
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::recv_organization_status_update( json::jobject jobj )
	{
		adapt_->recv_organization_status_update(jobj);
	}

	void biz_lower_impl::recv_cloud_config( json::jobject jobj )
	{
		adapt_->recv_cloud_config(jobj);
	}
	
	void biz_lower_impl::get_qrcode( json::jobject jobj )
	{

		epius::fun_exit cmd([=](){cmd_factory::instance().callback(jobj);});
		if(!jobj["args"] || !jobj["args"]["target"])
		{
			jobj["result"] =  "fail";
			jobj["reason"] = "invalid argument";
			return;
		}
		std::string target_name = jobj["args"]["target"].get<std::string>();
		QRcodeMgr qr;
		std::string qr_root = anan_config::instance().get_qr_code(target_name);
		if(qr_root.empty())
		{
			jobj["result"] =  "fail";
			jobj["reason"] = "configuration is wrong";
			return;
		}
		std::string mobile_url = qr_root;
		jobj["result"] =  "success";
		std::string local_file = epius::get_digist(mobile_url) + ".svg";
		local_file = epfilesystem::instance().sub_path(file_manager::instance().get_default_cache_dir(), local_file);
		std::string rgbaColor = "rgba(0,0,0,1.0)";
		if(!jobj["args"].is_nil("rgbaColor"))
		{
			rgbaColor = jobj["args"]["rgbaColor"].get<std::string>();
		}
		qr.qrencode(mobile_url.c_str(),mobile_url.size(),local_file.c_str(),rgbaColor);
		jobj["uri"] = local_file;
	}

	void biz_lower_impl::send_lightapp_message( json::jobject jobj )
	{
		if(!jobj.is_nil("args") && !jobj["args"].is_nil("target")&&!jobj["args"].is_nil("msg"))
		{
			std::string appid  = jobj["args"]["target"].get<std::string>();
			json::jobject msg= jobj["args"]["msg"];

			g_lightapp::instance().send_lightapp_message(appid, msg, wrap(bind2f(&biz_lower_impl::send_lightapp_message_cb,this,jobj,_1,_2,_3)));
			return;
		}
		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::send_lightapp_message_cb( json::jobject jobj, bool err, universal_resource reason, json::jobject data )
	{
		if (err)
		{
			jobj["result"] = "fail";
			jobj["reason"] = reason.res_value_utf8;
		}
		else
		{
			jobj["result"] = "success";
			jobj["rowid"] = data["rowid"];
		}
		cmd_factory::instance().callback(jobj);
	}
	
	void biz_lower_impl::get_lightapp_message( json::jobject jobj )
	{
		g_lightapp::instance().can_recv_lightapp_message(wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
		return;
	}

		void biz_lower_impl::delete_lightapp_message( json::jobject jobj )
	{
		if(!jobj.is_nil("args") && !jobj["args"].is_nil("appid"))
		{
			std::string appid = jobj["args"]["appid"].get<std::string>();
			std::string rowid = jobj["args"]["rowid"].get<std::string>();

			biz_.get_localconfig().DeleteLightappMessage(appid, rowid, wrap(bind2f(&biz_lower_impl::biz_command_common_callback,this,jobj,_1,_2)));
			return;
		}
		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::app_icon_update( json::jobject jobj )
	{
		adapt_->app_icon_update(jobj);
	}

	void biz_lower_impl::cloud_config_find_school(json::jobject jobj)
	{
		if(!jobj || !jobj["args"] || !jobj["args"]["search_school"])return;
		json::jobject school_jobj;
		school_jobj = biz_.get_login().search_school(jobj)["school"];
		jobj["school"] = school_jobj;
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::set_language( json::jobject jobj )
	{
		if (!jobj || !jobj["args"]["language"])
		{
			return;
		}
		std::string language = "chinese";
		//设置语言
		if (jobj["args"]["language"].get<std::string>() == "CN")
		{
			language = "chinese";
		}
		else if (jobj["args"]["language"].get<std::string>() == "EN")
		{
			language = "english";
		}
		uni_res::instance().SetLanguage(language);
		//发送广播给每个窗口
		adapt_->set_language(jobj["args"]["language"]);
	}

	void biz_lower_impl::async_http_get( json::jobject jobj )
	{
		if(!jobj.is_nil("args") && !jobj["args"].is_nil("url"))
		{
			std::string url = jobj["args"]["url"].get<std::string>();

			epius::http_requests::instance().get(url, bind2f(&biz_lower_impl::async_http_get_cb, this, jobj, _1, _2 ));
			return;
		}

		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::async_http_get_cb( json::jobject jobj, bool succ, std::string result )
	{
		if (!succ)
		{
			jobj["result"] = "fail";
			jobj["data"] = result;
		}
		else
		{
			jobj["result"] = "success";
			jobj["data"] = result;
		}
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::async_http_post( json::jobject jobj )
	{
		if(!jobj.is_nil("args") && !jobj["args"].is_nil("url"))
		{
			std::string url = jobj["args"]["url"].get<std::string>();
			boost::function<void(std::string, json::jobject value)> append_url = [&url](std::string key, json::jobject value) mutable {
				url=url + key + "=" +value.get<std::string>()+"&";
			};
			jobj["args"]["data"].each(append_url);

			std::map<std::string, std::string> header;
			header.insert(std::make_pair("Content-Length", "0"));
			epius::http_requests::instance().post(url, header, bind2f(&biz_lower_impl::async_http_post_cb, this, jobj, _1, _2 ));
			return;
		}

		jobj["result"] = "fail";
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::async_http_post_cb( json::jobject jobj, bool succ, std::string result )
	{
		if (!succ)
		{
			jobj["result"] = "fail";
			jobj["data"] = result;
		}
		else
		{
			jobj["result"] = "success";
			jobj["data"] = result;
		}
		cmd_factory::instance().callback(jobj);
	}

	void biz_lower_impl::recv_growth_info_message( json::jobject jobj )
	{
		adapt_->recv_growth_info_message(jobj);
	}

	void biz_lower_impl::get_http_download_url( json::jobject jobj )
	{
		jobj["url"] = anan_config::instance().get_http_down_path();
		cmd_factory::instance().callback(jobj); 
	}

}


