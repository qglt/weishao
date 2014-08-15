#pragma once
#include <string>
#include <base/json/tinyjson.hpp>
#include "login.h"

namespace biz
{
	typedef boost::function<void(json::jobject)> biz_cmd;
	class biz_adapter
	{
	public:
		virtual void chat_group_member_changed( json::jobject jobj ) = 0;
		virtual void recv_recent_list( json::jobject jobj ) = 0;
		virtual void recv_buddy_add_request( std::string jid, std::string rowid ,std::string msg ) = 0;
		virtual void recv_add_buddy_ack( std::string jid, std::string rowid,bool bAck, json::jobject msg) = 0;
		virtual void recv_msg(json::jobject jobj) = 0;
		virtual void send_message_failed(json::jobject jobj) = 0;
		virtual void recv_update_org_head( json::jobject jobj ) = 0;
		virtual void update_buddy_status( std::string jid,KPresenceType presence,json::jobject msg, std::string my_jid) = 0;
		virtual void recv_item_updated(std::string json_str, std::string my_jid) = 0;
		virtual void recv_organization_status_update(json::jobject jobj) = 0;
		virtual void recv_cloud_config(json::jobject jobj) = 0;
		virtual void recv_growth_info_message(json::jobject jobj) = 0;
		virtual void set_language(json::jobject jobj) = 0;
		virtual void recv_notice_message(json::jobject jobj) = 0;
		virtual void recv_app_message(json::jobject jobj) = 0;
		virtual void update_app_icon(json::jobject jobj) = 0;
		virtual void chat_group_list_changed(json::jobject jobj) = 0;
		virtual void update_member_head(json::jobject jobj) = 0;
		virtual void close_app_cb(bool err, universal_resource res) = 0;
		virtual void handle_user_not_exist() = 0;
		virtual std::string crop_image_stretch( std::string picture_path, int dst_width, int dst_height, int source_left,int source_top, int source_right, int source_bottom, int stretch_width, int stretch_height) = 0;
		virtual std::string crop_image( std::string picture_path, int dst_width, int dst_height, int source_left,int source_top, int source_right, int source_bottom) = 0;
		virtual void update_recent_contact(json::jobject jobj) = 0;
		virtual json::jobject get_hardware_info() = 0;
		virtual void file_transfer_status(json::jobject jobj) = 0;
		virtual void openURL(std::string url) = 0;
		virtual void crowd_list_changed(json::jobject jobj) = 0;
		virtual void crowd_member_changed(json::jobject jobj) = 0;
		virtual void crowd_info_changed(json::jobject jobj) = 0;
		virtual void crowd_file_changed(json::jobject jobj) = 0;
		virtual void crowd_alert_changed(json::jobject jobj) = 0;
		virtual void recv_quit_crowd_ack(json::jobject jobj) = 0;
		virtual void recv_apply_join_crowd_response(json::jobject jobj) = 0;
		virtual void crowd_member_role_changed(json::jobject jobj) = 0;
		virtual void crowd_role_changed(json::jobject jobj) = 0;
		virtual void crowd_superadmin_applyed(json::jobject jobj) = 0;
		virtual void crowd_superadmin_applyed_response(json::jobject jobj) = 0;
		virtual void crowd_create_success(json::jobject jobj) = 0;
		virtual void apply_join_groups_accepted_msg(json::jobject jobj) = 0;
		virtual void crowd_system_message(json::jobject jobj) = 0;
		virtual void app_icon_update(json::jobject jobj) = 0;
		
		virtual void connected(std::string my_jid) = 0;
		virtual void disconnected(universal_resource resource, std::string my_jid) = 0;
		virtual void connecting() = 0;
		virtual void update_dialog_showname(json::jobject jobj) = 0;
		virtual void update_customize_login(json::jobject jobj) = 0;

		virtual void login( json::jobject jobj, biz_cmd login_cmd ) 
		{
			jobj["sam_done"] = true;
			login_cmd(jobj);
		}
		virtual void cancel_login( json::jobject jobj, biz_cmd cmd )
		{
			jobj["sam_done"] = true;
			cmd(jobj);
		}

		virtual void change_user( json::jobject jobj, biz_cmd cmd )
		{
			jobj["sam_done"] = true;
			cmd(jobj);
		}
		virtual void go_offline( json::jobject jobj, biz_cmd cmd )
		{
			jobj["sam_done"] = true;
			cmd(jobj);
		}
		virtual void set_status( json::jobject jobj, biz_cmd cmd )
		{
			jobj["sam_done"] = true;
			cmd(jobj);
		}
		virtual std::string format_voice_file_format(std::string file_name)
		{
			return file_name;
		}

	};

}
