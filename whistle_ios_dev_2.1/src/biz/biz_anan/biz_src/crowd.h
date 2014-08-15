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


namespace biz {

	class Crowd 
	{
		typedef struct crowd_info{
			std::string name;				//Ⱥ��
			std::string icon;					//ͼ��
			std::string alert;					//����
			std::string role;					//����Ⱥ�еĽ�ɫ	
			std::string quit;					//�Ƿ����
			std::string status;				//Ⱥ��״̬�����ᣬ������ɾ����
			std::string official;				//�ٷ���Ⱥ
			std::string active;				//��Ծ��Ⱥ
			std::string category;			//Ⱥ����
			std::string dismiss;			//Ⱥ�ܷ��ɢ
			std::string remark;				//��ע
		}crowd_info;

		template<class> friend struct boost::utility::singleton_holder;
	public:
		Crowd ();
		virtual ~Crowd();

		void init();

		void set_biz_bind_impl(anan_biz_impl* impl);
	
		//����Ⱥ
		void get_create_crowd_setting(Result_Data_Callback callback);
		void create_crowd(json::jobject crowd_detail ,Result_Data_Callback callback);
		void create_crowd_cb(Result_Data_Callback callback ,bool err, universal_resource reason, json::jobject data);
		boost::signal< void(json::jobject) > crowd_create_success;
		//����Աĳ���������Ⱥ
		void invite_into_crowd(std::string session_id, std::string jid, Result_Callback callback); 
		void handler_recv_invited_into_crowd(json::jobject jobj);

		void answer_crowd_invite(json::jobject jobj, Result_Callback callback); 
		void answer_crowd_invite_cb(json::jobject jobj, Result_Callback callback, bool err, universal_resource reason_err); 
		void handler_recv_answer_crowd_invite(json::jobject jobj);

		//��ɢȺ
		void dismiss_crowd(std::string session_id, Result_Callback callback);
		void dismiss_crowd_cb(std::string session_id, Result_Callback callback, bool err, universal_resource reason);
		void handler_crowd_dismiss(json::jobject jobj);

		//�����Ϊ����Ա
		void crowd_apply_superadmin(std::string session_id , std::string reason , Result_Callback callback);
		
		void handler_crowd_role_applyed(json::jobject jobj);//���������Ϊ����Ա
		boost::signal< void(json::jobject) > crowd_superadmin_applyed;
		
		void handler_crowd_superadmin_applyed_self(json::jobject jobj);

		void handler_crowd_superadmin_applyed_response(json::jobject jobj);
		boost::signal< void(json::jobject) > crowd_superadmin_applyed_response;

		//����Ա���ת��
		void crowd_role_demise(std::string session_id ,std::string jid, std::string name , Result_Callback callback);
		void crowd_role_demise_cb( std::string session_id , std::string jid , std::string name , Result_Callback callback, bool err, universal_resource reason );
		
		void handler_crowd_role_demise(json::jobject jobj);
		
		//��ȡȺ�б�
		void get_crowd_list(Result_Data_Callback callback);	
		void get_crowd_list_cb(Result_Data_Callback callback, bool err, universal_resource reason, json::jobject data);

		//��ȡȺ��Ա�б�
		void get_crowd_member_list(std::string session_id ,std::string role , Result_Data_Callback callback);
		void get_crowd_member_list_cb( std::string session_id,  Result_Data_Callback callback, bool err, universal_resource reason, json::jobject data );
		//�޸�Ⱥ��Ա����
		void set_crowd_member_info(std::string session_id , json::jobject jobj , Result_Callback callback);
		void set_crowd_member_info_cb(std::string session_id, json::jobject jobj , Result_Callback callback, bool err, universal_resource reason );
		//��ȡȺ����
		void get_crowd_info(std::string session_id, Result_Data_Callback callback);
		void get_crowd_info_cb( std::string session_id, Result_Data_Callback callback ,bool err , universal_resource reason , json::jobject jobj);

		//����Ⱥ����
		void set_crowd_info(std::string session_id , json::jobject jobj, Result_Callback callback);
		void set_crowd_info_cb(json::jobject actor,json::jobject item ,  std::string session_id ,Result_Callback callback ,bool succ,std::string uri);
		
		void do_upload_icon(json::jobject actor,json::jobject item ,  std::string uri , std::string session_id ,Result_Callback callback);

		//����Ա�߳�Ա
		void crowd_kickout_member(std::string session_id , std::string jid,std::string name, Result_Callback callback);
		void handler_recv_groups_member_kickout_admin_other( json::jobject jobj);
		void handler_recv_groups_member_kickout_admin_self( json::jobject jobj);
		
		
		//�˳�Ⱥ
		void leave_crowd(std::string session_id, Result_Callback callback);

		//��Ⱥ����
		void open_crowd_window(std::string session_id, Result_Callback callback);
		
		//�ر�Ⱥ����
		void close_crowd_window(std::string session_id);

		//��ȡȺ�����ļ��б�
		void get_crowd_file_list(std::string session_id, std::string orderby, Result_Data_Callback callback);
		void get_crowd_file_list_cb(bool err, universal_resource reason, json::jobject data, Result_Data_Callback callback);
		//�ϴ�Ⱥ�����ļ�
		void upload_crowd_file(std::string session_id, std::string file, std::string uid, Result_Callback callback);
		void do_upload_file( std::string filename, std::string uri, std::string session_id , std::string uid, Result_Callback callback );
		void check_file_on_server_cb(std::string filename, std::string uri , std::string session_id , std::string uid, Result_Callback callback, bool succ, std::string response );
		void file_already_exists( Result_Callback callback, std::string uri , std::string filename , std::string uid , std::string session_id, boost::uintmax_t filesize);
		
		void upload_crowd_file_cb(std::string session_id , std::string file , std::string size , bool succ , std::string reason ,std::string uri ,Result_Callback callback);
		//����Ⱥ�����ļ�
		void download_crowd_file(std::string session_id, std::string id, std::string uri, std::string uid , std::string file , Result_Callback callback);
		void download_crowd_file_cb( Result_Callback callback , std::string session_id, std::string id, bool succ, std::string reason);

		//ɾ��Ⱥ�����ļ�
		void remove_crowd_file(std::string session_id, std::string id, Result_Callback callback);

		//�����ļ�����
		void set_crowd_file_info( std::string did ,std::string id , std::string mode ,Result_Callback callback );

		//����Ⱥ������Ϣ
		void set_crowd_alert(std::string session_id, std::string alert , Result_Callback callback);
		void set_crowd_alert_cb(std::string session_id, std::string alert , Result_Callback callback, bool err, universal_resource reason);

		//�������Ⱥ
		void apply_join_crowd(std::string session_id, std::string reason , Result_Data_Callback callback);
		void apply_join_crowd_cb(std::string session_id, Result_Data_Callback callback, bool err, universal_resource reason, json::jobject data);
		
		void system_message_common_cb(std::string session_id , json::jobject info , std::string msg_type , std::string type , bool err, universal_resource reason, json::jobject data );
		void handler_apply_join_groups_accepted( json::jobject jobj);
		boost::signal< void(json::jobject) >apply_join_groups_accepted_msg;
		//�ȴ�����Ա����
		void handler_apply_join_crowd_wait( json::jobject jobj);
		boost::signal< void(json::jobject) > apply_join_crowd_wait;

		//����Ա������������
		void answer_apply_join_crowd( std::string session_id , std::string accept,std::string rowid , json::jobject actor , std::string reason, std::string admin_reason , Result_Callback callback );
		void answer_apply_join_crowd_cb( std::string session_id , std::string accept, std::string rowid , json::jobject actor , std::string apply_reason , Result_Callback callback, bool err, universal_resource reason_err );
		void handler_recv_groups_member_apply_accept( json::jobject jobj );
		//����Ա�������֪ͨ
		void handler_recv_apply_join_crowd_response(json::jobject jobj);
		boost::signal< void(json::jobject) > recv_apply_join_crowd_response;

		boost::signal< void(json::jobject) > crowd_member_apply_accept_msg;

		//��������Ա�ı����������
		void crowd_role_change(std::string session_id , std::string jid ,std::string role , Result_Callback callback );
		void handler_crowd_member_role_change(json::jobject jobj);//֪ͨȺ��Ա���û�����ݱ��ı�
		boost::signal< void(json::jobject) > crowd_member_role_changed;

		void handler_crowd_role_change(json::jobject jobj);//֪ͨ�û�������ݱ��ı�
		boost::signal< void(json::jobject) > crowd_role_changed;

		//����Ⱥ
		void find_crowd(json::jobject jobj, Result_Data_Callback callback);
		void find_crowd_cb( json::jobject jobj, Result_Data_Callback callback, bool err ,  universal_resource reason, json::jobject data );
		void download_uri_callback( bool bsuccess , std::string reason , std::string local_path, boost::function<void(bool err, universal_resource res, std::string local_path)> callback );
		void download_uri( std::string uri,boost::function<void(bool err, universal_resource res, std::string local_path)> callback );
		void find_crowd_and_finish_download(std::string jid, bool err, universal_resource res, std::string local_path);
		void set_head(std::string id , bool succ , universal_resource reason , std::string local_path);
		void send_save_sys_msg(json::jobject jobj , std::string txt);
		
		//��������֪ͨ
		void handler_recv_groups_member_web_change_self(json::jobject jobj);
		//�źŴ���,ϵͳ��Ϣ��ͳһ�ӿ�
		boost::signal< void(json::jobject) > crowd_system_message;
		//�źŴ������Ⱥ��Աͷ��
		boost::signal< void(json::jobject) > update_member_head;

		//�źŴ����յ�Ⱥ�б����
		void handler_crowd_list_changed(json::jobject jobj);
		void crowd_list_changed(json::jobject jobj);
		boost::signal< void(json::jobject) > crowd_list_changed_signal;

		//�źŴ����յ�Ⱥ��Ա�б����
		void handler_crowd_member_changed(json::jobject jobj);
		boost::signal< void(json::jobject) > crowd_member_changed;

		//�ļ��б����仯
		void handler_crowd_upload_file(json::jobject jobj);
		boost::signal< void(json::jobject) > crowd_share_file_changed;

		//�źŴ����յ�Ⱥ���ϸ���
		void handler_crowd_info_changed(json::jobject jobj);
		boost::signal< void(json::jobject) > crowd_info_changed;

		//�������øı�
		boost::signal< void(json::jobject) > crowd_member_info_changed;

		//֪ͨ��Ⱥϵͳ��Ϣ
		boost::signal< void( json::jobject) > recv_quit_crowd_ack;

		//�źŴ��� �յ�Ⱥ�Ự��Ϣ
		void handler_get_crowd_message(json::jobject jobj);

		//�źŴ��� �յ��г�Ա��Ⱥ��Ϣ
		void handler_get_quit_crowd_message(json::jobject jobj);

		//Ⱥ�Ƿ����
		bool is_crowd_exist(std::string session_id);

		//Ⱥͼ��
		std::string get_crowd_icon_by_id(std::string session_id);

		//Ⱥ����
		std::string get_crowd_category_by_id(std::string session_id);

		std::string get_crowd_name(std::string session_id);
		//����Ⱥ�Ự��Ϣ
		std::string send_msg(std::string session_id, std::string const& txt_msg, std::string const& msg);

		//���ز���
		void search_local_crowd(std::string filterString, json::jobject& jobj );

		//Ⱥ�б�
		void get_crowd_list2(std::vector<std::string>& crowd_list);
		std::string get_alert_by_session_id(std::string session_id);
	private:
		void do_get_crowd_message();
		std::deque<json::jobject>  msg_queue_;
		std::map<std::string, crowd_info> crowd_list_;
		
		//����Ѿ�ȡ��Ⱥ�б����ٴӷ���˶�ȡ
		bool had_fetch_list_;

		// ����Ⱥ��Ա��ϸ��Ϣ������ͼƬ���ж���ʾ����
		json::jobject build_member_info(json::jobject jobj);
		void build_one_member_info(json::jobject jobj);
		void build_one_crowd_info(std::string session_id,json::jobject crowd_jobj);
		void build_crowd_icon( std::string session_id,json::jobject crowd_jobj );

		// ������״̬�źŴ���
		void connected();

		// ���Ⱥ
		void clear_crowd_list(){ crowd_list_.clear();};

		// ����ͼƬ
		void syncdown_head_image(json::jobject jobj, std::string field_name, std::string uri_string);
		void finished_syncdown_image(json::jobject jobj, std::string field_name,bool succ,std::string uri_string);

		bool _MatchEach( json::jobject& jobj, const std::string& filterString,const std::string& name,const std::string session_id, 
			std::string head_uri, std::string category, std::string official, std::string active);
		void fireMatch(json::jobject& jobj, std::string session_id, std::string name, std::string head_uri, std::string category,
			std::string official, std::string active);

		anan_biz_impl*	get_parent_impl() { return anan_biz_impl_;};
		anan_biz_impl*	anan_biz_impl_;
	};

	typedef boost::utility::singleton_holder<Crowd> g_crowd;
};
