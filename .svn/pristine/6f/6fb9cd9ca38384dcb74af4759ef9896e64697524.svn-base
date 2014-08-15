#include <base/utility/file_digest/file2uri.hpp>
#include <base/module_path/epfilesystem.h>
#include "crowd.h"
#include "gloox_wrap/glooxWrapInterface.h"
#include <base/utility/bind2f/bind2f.hpp>
#include "base/module_path/file_manager.h"
#include "login.h"
#include "event_collection.h"
#include "user.h"
#include "agent.h"
#include "an_roster_manager.h"
#include "an_roster_manager_impl.h"
#include "conversation.h"
#include "agent_impl.h"
#include "local_config.h"
#include "whistle_vcard.h"
#include "biz_app_settings.h"
#include <base/local_search/local_search.h>
#include "base/http_trans/http_request.h"
#include "anan_config.h"
#include "file_transfer_manager.h"

using namespace epius::proactor;
namespace biz {


	Crowd::Crowd()
 	{
		had_fetch_list_ = false;
		gWrapInterface::instance().groups_list_change.connect(boost::bind(&Crowd::handler_crowd_list_changed, this, _1));
		gWrapInterface::instance().groups_info_change.connect(boost::bind(&Crowd::handler_crowd_info_changed, this, _1));
		gWrapInterface::instance().groups_member_list_change.connect(boost::bind(&Crowd::handler_crowd_member_changed, this, _1));
		gWrapInterface::instance().groups_member_quit.connect(boost::bind(&Crowd::handler_get_quit_crowd_message, this, _1));//退出的系统消息
		gWrapInterface::instance().groups_get_message.connect(boost::bind(&Crowd::handler_get_crowd_message, this, _1));//群会话接受消息
		gWrapInterface::instance().groups_upload_file_share.connect(boost::bind(&Crowd::handler_crowd_upload_file, this, _1));//文件上传
		gWrapInterface::instance().apply_join_groups_wait.connect(boost::bind(&Crowd::handler_apply_join_crowd_wait, this, _1));//等待管理员审批
		gWrapInterface::instance().recv_apply_join_crowd_response.connect(boost::bind(&Crowd::handler_recv_apply_join_crowd_response, this, _1));//管理员拒绝申请加入通知
		gWrapInterface::instance().groups_member_role_changed.connect(boost::bind(&Crowd::handler_crowd_member_role_change, this, _1));//群成员角色被改变
		gWrapInterface::instance().groups_role_changed.connect(boost::bind(&Crowd::handler_crowd_role_change, this, _1));//群成员角色被改变
		gWrapInterface::instance().groups_role_applyed.connect(boost::bind(&Crowd::handler_crowd_role_applyed, this, _1));//群管理员已被申请
		gWrapInterface::instance().groups_role_applyed_self.connect(boost::bind(&Crowd::handler_crowd_superadmin_applyed_self, this, _1));//通知申请者，申请已审批 
		gWrapInterface::instance().crowd_superadmin_applyed_response.connect(boost::bind(&Crowd::handler_crowd_superadmin_applyed_response, this, _1));//通知用户，管理员身份申请已审批，更新界面
		gWrapInterface::instance().groups_role_demised.connect(boost::bind(&Crowd::handler_crowd_role_demise, this, _1));//通知群新管理员，身份已经变更
		gWrapInterface::instance().apply_join_groups_accepted.connect(boost::bind(&Crowd::handler_apply_join_groups_accepted, this, _1));//(开放群)通知管理员有人加入了群
		gWrapInterface::instance().invited_into_gropus.connect(boost::bind(&Crowd::handler_recv_invited_into_crowd, this, _1));//(开放群)通知管理员有人加入了群
		gWrapInterface::instance().recv_answer_groups_invite.connect(boost::bind(&Crowd::handler_recv_answer_crowd_invite, this, _1));//管理员收到了被邀请人的应答消息
		gWrapInterface::instance().recv_groups_member_web_change_self.connect(boost::bind(&Crowd::handler_recv_groups_member_web_change_self, this, _1));//管理端更改成员信息，被更改者收到信息
		gWrapInterface::instance().recv_groups_member_kickout_admin_other.connect(boost::bind(&Crowd::handler_recv_groups_member_kickout_admin_other, this, _1));//移出某成员时其他管理员收到的通知
		gWrapInterface::instance().recv_groups_member_kickout_admin_self.connect(boost::bind(&Crowd::handler_recv_groups_member_kickout_admin_self, this, _1));//移出成员的管理员收到的通知
		gWrapInterface::instance().recv_groups_member_apply_accept.connect(boost::bind(&Crowd::handler_recv_groups_member_apply_accept, this, _1));//某管理员同意某人申请加入群后通知其他管理员
	
	}
	
	Crowd::~Crowd()
	{

	}

	void Crowd::init()
	{
		if (get_parent_impl() && get_parent_impl()->bizLogin_)
		{
			get_parent_impl()->bizLogin_->conn_msm_.connected_signal_.connect(boost::bind(&Crowd::connected,this));
		}
	}

	void Crowd::connected()
	{
		clear_crowd_list();
		had_fetch_list_ = false;
	}

	void Crowd::set_biz_bind_impl( anan_biz_impl* impl )
	{
		anan_biz_impl_ = impl;
	}

	void Crowd::get_crowd_list( Result_Data_Callback callback )
	{
		IN_TASK_THREAD_WORKx(Crowd::get_crowd_list, callback);

		if (had_fetch_list_)
		{
			json::jobject jobj;
			std::map<std::string, crowd_info>::iterator it;
			for (it = crowd_list_.begin(); it!= crowd_list_.end(); it++)
			{
				json::jobject data;
				data["session_id"] = it->first;
				data["name"] = it->second.name;
				data["icon"] = it->second.icon;
				data["alert"] = it->second.alert;
				data["role"] = it->second.role;
				data["quit"] = it->second.quit;
				data["status"] = it->second.status;
				data["official"] = it->second.official;
				data["active"] = it->second.active;
				data["category"] = it->second.category;
				data["dismiss"] = it->second.dismiss;
				data["remark"] = it->second.remark;
				jobj.arr_push(data);
			}

			std::set<std::string>::iterator it2 = get_parent_impl()->bizRoster_->can_return_recent_.find("crowdlist");
			if (it2 == get_parent_impl()->bizRoster_->can_return_recent_.end())
			{
				get_parent_impl()->bizRoster_->can_return_recent_.insert("crowdlist");
				get_parent_impl()->bizRecent_->noticeRecentContactChanged();
			}
			if(!callback.empty())
			{
				json::jobject quit_crowd_jobj;
				json::jobject crowd_jobj;
				get_parent_impl()->bizLocalConfig_->get_quit_crowd_list(jobj.clone(),quit_crowd_jobj);
				crowd_jobj["quit_crowd_list"] = quit_crowd_jobj; 
				crowd_jobj["crowd_list"] = jobj;
				callback(false, XL(""), crowd_jobj);
				return;
			}
		}
		gWrapInterface::instance().get_groups_list( boost::bind(&Crowd::get_crowd_list_cb, this, callback, _1, _2, _3));
	}

	void Crowd::get_crowd_list2(std::vector<std::string>& crowd_list)
	{
		std::map<std::string, crowd_info>::iterator it = crowd_list_.begin();

		for (; it!= crowd_list_.end(); it++)
		{
			crowd_list.push_back(it->first);
		}
	}

	void Crowd::get_crowd_list_cb( Result_Data_Callback callback, bool err, universal_resource reason, json::jobject data )
	{
		if (!err)
		{
			//清除缓存
			crowd_list_.clear();

			for (int i=0; i< data.arr_size(); i++)
			{
				crowd_info dinfo;
				dinfo.name = data[i]["name"].get<std::string>();
				std::string uri_string = data[i]["icon"].get<std::string>();

				dinfo.icon = "";
				data[i]["icon"] = "";

				if(!uri_string.empty())
				{
					std::string local_string = biz::file_manager::instance().from_uri_to_valid_path(uri_string);
					if (local_string.empty())
					{
						download_uri(uri_string,bind2f(&Crowd::set_head , this , data[i]["session_id"].get<std::string>(), _1 , _2 , _3));
					}else{
						dinfo.icon = local_string;
						data[i]["icon"]= local_string;
					}
				}
				dinfo.alert = data[i]["alert"].get<std::string>();
				dinfo.role = data[i]["role"].get<std::string>();
				dinfo.quit = data[i]["quit"].get<std::string>();
				dinfo.status = data[i]["status"].get<std::string>();
				dinfo.official = data[i]["official"].get<std::string>();
				dinfo.active = data[i]["active"].get<std::string>();
				dinfo.category = data[i]["category"].get<std::string>();
				dinfo.dismiss = data[i]["dismiss"].get<std::string>();
				dinfo.remark = data[i]["remark"].get<std::string>();

				crowd_list_.insert(make_pair(data[i]["session_id"].get<std::string>(), dinfo));

				//更新群名称聊天记录
				get_parent_impl()->bizLocalConfig_->UpdateCrowdName(data[i]["session_id"].get<std::string>(), dinfo.name);
			}

			had_fetch_list_=true;
		}

		if (!callback.empty())
		{
			json::jobject quit_crowd_jobj;
			json::jobject crowd_jobj;
			get_parent_impl()->bizLocalConfig_->get_quit_crowd_list(data.clone(),quit_crowd_jobj);
			crowd_jobj["quit_crowd_list"] = quit_crowd_jobj; 
			crowd_jobj["crowd_list"] = data;	
			callback(err, reason, crowd_jobj);
		}
		std::set<std::string>::iterator it = get_parent_impl()->bizRoster_->can_return_recent_.find("crowdlist");
		if (it == get_parent_impl()->bizRoster_->can_return_recent_.end())
		{
			get_parent_impl()->bizRoster_->can_return_recent_.insert("crowdlist");
			get_parent_impl()->bizRecent_->noticeRecentContactChanged();
		}
	}

	void Crowd::get_crowd_member_list( std::string session_id , std::string role , Result_Data_Callback callback )
	{
		IN_TASK_THREAD_WORKx(Crowd::get_crowd_member_list, session_id, role , callback);
		if (role=="admin")
		{
			gWrapInterface::instance().get_groups_admin_list( session_id, bind2f(&Crowd::get_crowd_member_list_cb,this,session_id, callback,_1,_2,_3));
		}
		else 
		{
			gWrapInterface::instance().get_groups_member_list( session_id, bind2f(&Crowd::get_crowd_member_list_cb,this,session_id, callback,_1,_2,_3));
		}

	}
	void Crowd::get_crowd_member_list_cb( std::string session_id,  Result_Data_Callback callback, bool err, universal_resource reason, json::jobject data )
	{
		IN_TASK_THREAD_WORKx(Crowd::get_crowd_member_list_cb, session_id, callback,err,reason,data);
		if (!err)
		{
			data = build_member_info(data);
		}
		callback(err, reason, data);
	}

	void Crowd::build_one_member_info(json::jobject jobj)
	{
		// 判断显示姓名规则：
		// 1. 可以在vcard中找到，使用vcard中的showname
		// 2. 找不到，显示服务端返回的姓名
		if (!jobj.size())
		{
			return;
		}
		std::string show_name;
		KContactType ct = get_parent_impl()->bizRoster_->is_my_friend_(jobj["jid"].get<std::string>());
		if (ct != kctNone)
		{
			ContactMap::iterator itvcard = get_parent_impl()->bizRoster_->syncget_VCard(jobj["jid"].get<std::string>());
			show_name = itvcard->second.get_vcardinfo()[s_VcardShowname].get<std::string>();
			jobj[s_VcardShowname] = show_name;
		}

		// 性别和身份 需要转译
		if (jobj[s_VcardSex])
		{
			if (!jobj[s_VcardSex].get<std::string>().empty())
			{
				jobj[s_VcardSexShow] = XL(jobj[s_VcardSex].get<std::string>()).res_value_utf8;
			}
		}
		if (jobj[s_VcardIdentity])
		{
			if (!jobj[s_VcardIdentity].get<std::string>().empty())
			{
				jobj[s_VcardIdentityShow] = XL(jobj[s_VcardIdentity].get<std::string>()).res_value_utf8;
			}
		}			

		// 下载个性图片
		if (jobj[s_VcardHeadURI])
		{
			if (!jobj[s_VcardHeadURI].get<std::string>().empty())
			{
				jobj[s_VcardHead] = "";
				std::string uri_string = jobj[s_VcardHeadURI].get<std::string>();
				std::string local_string;
				if(!uri_string.empty())
				{
					local_string = biz::file_manager::instance().from_uri_to_valid_path(uri_string);
					if (local_string.empty())
					{
						syncdown_head_image(jobj, s_VcardHead, uri_string);
					}else{
						jobj[s_VcardHead] = local_string;
					}
				}
			}
		}
	}

	json::jobject Crowd::build_member_info( json::jobject jobj )
	{
		//获取vcard信息
		for (int i=0; i< jobj.arr_size(); i++)
		{
				build_one_member_info(jobj[i]);	
		}		
		return jobj;
	}
	void Crowd::syncdown_head_image(json::jobject jobj, std::string field_name, std::string uri_string)
	{
		if (uri_string.empty())
		{
			return;
		}
		boost::function<void(bool,std::string)> callback = boost::bind(&Crowd::finished_syncdown_image, this, jobj, field_name, _1, _2);
		std::string download_path = file_manager::instance().from_uri_to_path(uri_string);
		epius::http_requests::instance().download(anan_config::instance().get_http_down_path(), download_path, uri_string, "", boost::function<void(int)>(), callback);
	}

	void Crowd::finished_syncdown_image(json::jobject jobj,std::string field_name,bool succ,std::string uri_string)
	{
		IN_TASK_THREAD_WORKx(Crowd::finished_syncdown_image, jobj, field_name, succ, uri_string);

		if (succ) {
			std::string local_path = file_manager::instance().from_uri_to_path(uri_string);
			json::jobject update_jobj;
			update_jobj["jid"] = jobj["jid"].get<std::string>();
			update_jobj[field_name] = local_path;
			update_member_head(update_jobj);
		}
		else
		{
			json::jobject update_jobj;
			update_jobj["jid"] = jobj["jid"].get<std::string>();
			update_jobj[s_VcardSexShow] = XL(jobj[s_VcardSex].get<std::string>()).res_value_utf8;
			update_jobj[s_VcardIdentityShow] = XL(jobj[s_VcardIdentity].get<std::string>()).res_value_utf8;
			update_jobj[field_name] = "";
			update_member_head(update_jobj);
		}
	}
	void Crowd::get_crowd_info( std::string session_id, Result_Data_Callback callback )
	{
		IN_TASK_THREAD_WORKx(Crowd::get_crowd_info, session_id, callback);

		gWrapInterface::instance().get_groups_info( session_id , boost::bind(&Crowd::get_crowd_info_cb,this,session_id, callback, _1,_2,_3));

	}
	void Crowd::get_crowd_info_cb( std::string session_id, Result_Data_Callback callback ,bool err , universal_resource reason , json::jobject jobj)
	{
		IN_TASK_THREAD_WORKx(Crowd::get_crowd_info_cb, session_id, callback, err ,  reason ,  jobj);
		if (!err)
		{
			jobj["session_id"] = session_id;
			if (jobj["icon"] .get<std::string>()!="")
			{
				
				std::string local_string = biz::file_manager::instance().from_uri_to_valid_path(jobj["icon"] .get<std::string>());
				if (local_string.empty())
				{
					jobj["icon"] = "";
				}else
				{
					jobj["icon"] = local_string;
				}
			}
		}
		callback(err,reason,jobj);
	}
	//JS应检查角色自己是否是群管理员
	void Crowd::set_crowd_info(std::string session_id, json::jobject jobj, Result_Callback callback)
	{

		IN_TASK_THREAD_WORKx(Crowd::set_crowd_info, session_id, jobj, callback);
		json::jobject actor;

	   actor["name"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardName];
	   actor["nike_name"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardNickname];
	   actor["jid"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardJid];
	   actor["sex"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardSex];
	   if (!jobj.is_nil("icon"))
	   {
		   if (epfilesystem::instance().file_exists(jobj["icon"].get<std::string>()))
		   {
			   boost::function<void(bool /*succ*/, std::string)> upload_callback = boost::bind(&Crowd::set_crowd_info_cb, this, actor, jobj,session_id,callback,_1, _2);
			   epius::http_requests::instance().upload(anan_config::instance().get_http_upload_path(), jobj["icon"].get<std::string>(), "", "", boost::function<void(int)>(), upload_callback);
			   return;
		   }
		   std::map<std::string, crowd_info>::iterator it = crowd_list_.find(session_id);
		   if (it!=crowd_list_.end())
		   {
			   it->second.icon=biz::file_manager::instance().from_uri_to_valid_path(jobj["icon"].get<std::string>());
		   }
	   }
		
	   gWrapInterface::instance().change_groups_info( session_id, actor, jobj, callback);
	}
	void Crowd::set_crowd_info_cb(json::jobject actor,json::jobject item ,  std::string session_id ,Result_Callback callback ,bool succ,std::string uri)
	{
		IN_TASK_THREAD_WORKx(Crowd::set_crowd_info_cb, actor, item, session_id, callback, succ, uri);
		if (!succ)
		{
			callback(true,XL("头像上传失败！"));
			return;
		}
		json::jobject upload_obj(uri);
		if (upload_obj)
		{
			uri = upload_obj["file_uri"].get<std::string>();
		}
		item["icon"]= uri;
		gWrapInterface::instance().change_groups_info( session_id, actor, item, callback);
		std::map<std::string, crowd_info>::iterator it = crowd_list_.find(session_id);
		if (it!=crowd_list_.end())
		{
			it->second.icon=biz::file_manager::instance().from_uri_to_valid_path(uri);
		}
	}
	void Crowd::leave_crowd( std::string session_id, Result_Callback callback )
	{
		IN_TASK_THREAD_WORKx(Crowd::leave_crowd, session_id, callback);

		json::jobject item;
		item["name"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardName];
		item["nike_name"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardNickname];
		item["jid"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardJid];
		item["icon"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardHeadURI];
		item["sex"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardSex];
		item["identity"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardIdentity];
		
		gWrapInterface::instance().quit_groups( session_id, item, callback);

	}

	void Crowd::open_crowd_window( std::string session_id, Result_Callback callback )
	{
		
		IN_TASK_THREAD_WORKx(Crowd::open_crowd_window, session_id, callback);
		gWrapInterface::instance().enter_groups( session_id, callback);
	}

	void Crowd::close_crowd_window( std::string session_id )
	{
		
		IN_TASK_THREAD_WORKx(Crowd::close_crowd_window, session_id);
		gWrapInterface::instance().leave_groups( session_id);
	}

	void Crowd::get_crowd_file_list( std::string session_id , std::string orderby , Result_Data_Callback callback )
	{
		IN_TASK_THREAD_WORKx(Crowd::get_crowd_file_list , session_id , orderby , callback);

		gWrapInterface::instance().get_groups_share_list( session_id, orderby, bind2f(&Crowd::get_crowd_file_list_cb, this, _1 ,_2, _3, callback));
	}

	void Crowd::get_crowd_file_list_cb(bool err, universal_resource reason, json::jobject data, Result_Data_Callback callback)
	{
		IN_TASK_THREAD_WORKx(Crowd::get_crowd_file_list_cb , err , reason , data, callback);
		if (!err)
		{
			json::jobject temp;
			for(int i=0;i<data["list"].arr_size();i++)
			{
				for(int j=0;j<data["list"].arr_size()-i-1;j++)
				{
					if(data["list"][j]["timestamp"].get<std::string>()>data["list"][j+1]["timestamp"].get<std::string>())
					{
						temp=data["list"][j].clone();
						data["list"][j]=data["list"][j+1].clone();
						data["list"][j+1] =temp.clone();
					}
				}
			}
		}
		callback(err, reason , data);
	}

	void Crowd::upload_crowd_file( std::string session_id, std::string file,std::string uid , Result_Callback callback )
	{
		IN_TASK_THREAD_WORKx(Crowd::upload_crowd_file , session_id , file , uid , callback);
		file_transfer::instance().insert_cancle_trans_file_map(uid);
		epius::async_get_uri(file,boost::bind(&Crowd::do_upload_file , this , file ,  _1 , session_id , uid , callback));
	}
	void Crowd::do_upload_file( std::string filename, std::string uri, std::string session_id , std::string uid, Result_Callback callback )
	{
		IN_TASK_THREAD_WORKx(Crowd::do_upload_file , filename, uri, session_id , uid, callback);
		std::map<std::string, std::string> header;
		header.insert(std::make_pair("Content-Length", "0"));
		header.insert(std::make_pair("Method", "check"));
		header.insert(std::make_pair("Filename", uri));
		epius::http_requests::instance().post(anan_config::instance().get_file_upload_path(), header, bind2f(&Crowd::check_file_on_server_cb, this, 
			filename, uri,session_id, uid, callback, _1, _2 ));
	}

	void Crowd::check_file_on_server_cb(std::string filename, std::string uri , std::string session_id , std::string uid,  Result_Callback callback, bool succ, std::string response )
	{
		IN_TASK_THREAD_WORKx(Crowd::check_file_on_server_cb , filename,  uri ,  session_id ,uid,   callback,  succ,  response );
		if (succ)
		{
			if(file_transfer::instance().is_file_trans_canceled(uid))
			{
				callback(true, XL("user_cancel_file_transfer"));
				return ;
			}
			json::jobject result_jobj(response);
			if (result_jobj)
			{
				boost::uintmax_t filesize =  epius::epfilesystem::instance().file_size(filename);
				if (result_jobj["error"].get<int>() == 1)
				{
					json::jobject jobj;
					jobj["status"] = "ok";
					jobj["uid"] = uid;
					jobj["filesize"] = boost::str(boost::format("%ld")%filesize);
					epius::http_requests::instance().file_transfer_status(jobj);
					epius::time_thread tmp_thread;
					tmp_thread.timed_wait(1000);

					filename = epius::epfilesystem::instance().file_name(filename);
					file_already_exists(  callback,  uri ,  filename , uid, session_id, filesize);
					return;
				}
				else
				{
					std::string size_s = get_parent_impl()->bizLocalConfig_->loadData("upload_" + uri +session_id);
					std::string jid = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardJid].get<std::string>();
					boost::function<void(bool /*succ*/, std::string)> upload_callback = boost::bind(&Crowd::upload_crowd_file_cb, this, session_id, filename,boost::str(boost::format("%ld")%filesize),_1, _2,uri,callback);
					epius::http_requests::instance().resume_upload_file(anan_config::instance().get_file_upload_path(), filename, size_s, uri+"."+jid.substr(0,jid.find_first_of('@')), uid, file_transfer::instance().get_common_progress_callback("upload", uid , uri, session_id), upload_callback);
					return;
				}
			}
		}
		
		callback(true, XL("Crowd::check_file_on_server_broken"));
	}
	void Crowd::upload_crowd_file_cb( std::string session_id , std::string file , std::string size , bool succ ,std::string reason , std::string uri ,Result_Callback callback )
	{	
		IN_TASK_THREAD_WORKx(Crowd::upload_crowd_file_cb , session_id , file , size ,succ ,reason , uri, callback);

		if (succ)
		{
			json::jobject actor;
			json::jobject item;

			actor["jid"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardJid];
			item["name"] = epius::epfilesystem::instance().file_name(file);
			item["size"] = size;
			item["uri"] = uri;
			get_parent_impl()->bizLocalConfig_->deleteData("upload_" + uri);
			gWrapInterface::instance().upload_file_groups_share( session_id,actor,item,callback);
		}	
		else{
			callback(true, XL(reason));
		}
	}

	void Crowd::file_already_exists( Result_Callback callback, std::string uri , std::string filename , std::string uid , std::string session_id, boost::uintmax_t filesize )
	{
		json::jobject actor;
		json::jobject item;

		actor["jid"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardJid];

		item["name"] = filename;
		item["size"] = boost::str(boost::format("%ld")%filesize);
		item["owner_name"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardNickname];
		item["uri"] = uri;
		if (file_transfer::instance().is_file_trans_canceled(uid))
		{
			callback(true, XL("user_cancel_file_transfer"));
			return ;
		}
		gWrapInterface::instance().upload_file_groups_share( session_id,actor,item,callback);		
	}
	void Crowd::download_crowd_file( std::string session_id, std::string id, std::string uri, std::string uid , std::string filename,  Result_Callback callback )
	{
		IN_TASK_THREAD_WORKx(Crowd::download_crowd_file , session_id , id , uri , uid ,filename , callback);

		epfilesystem::instance().create_directories(epius::epfilesystem::instance().branch_path(filename));

		boost::function<void(bool,std::string)> download_callback = boost::bind(&Crowd::download_crowd_file_cb, this, callback, session_id , id,  _1, _2);
		epius::http_requests::instance().resume_download(anan_config::instance().get_file_download_path(), filename, uri, uid, file_transfer::instance().get_common_progress_callback("download", uid,uri, ""), download_callback);
	}

	void Crowd::download_crowd_file_cb( Result_Callback callback , std::string session_id, std::string id, bool succ, std::string reason)
	{
		IN_TASK_THREAD_WORKx(Crowd::download_crowd_file_cb , callback , session_id , id, succ, reason );

		if (succ)
		{
			gWrapInterface::instance().download_file_groups_share( session_id,id,callback);
		}
		else{
			callback(true,XL(reason));
		}
	}

	void Crowd::remove_crowd_file( std::string session_id, std::string id, Result_Callback callback )
	{
		IN_TASK_THREAD_WORKx(Crowd::remove_crowd_file , session_id , id , callback);
		gWrapInterface::instance().delete_file_groups_share( session_id,id,callback);
	}

	void Crowd::set_crowd_alert( std::string session_id ,std::string alert , Result_Callback callback )
	{
		IN_TASK_THREAD_WORKx(Crowd::set_crowd_alert , session_id , alert , callback);

		gWrapInterface::instance().change_groups_member_info( session_id, alert ,boost::bind(&Crowd::set_crowd_alert_cb, this, session_id, alert, callback, _1, _2));
	}

	void Crowd::set_crowd_alert_cb(std::string session_id, std::string alert , Result_Callback callback, bool err, universal_resource reason)
	{
		//更新缓存
		if (!err)
		{
			std::map<std::string, crowd_info>::iterator it = crowd_list_.find(session_id);
			if (it!= crowd_list_.end())
			{
				it->second.alert = alert;
			}
		}

		json::jobject jobj;
		jobj["alert"] = alert;
		jobj["session_id"] = session_id;
		crowd_member_info_changed(jobj);

		callback(err, reason);
	}

	void Crowd::apply_join_crowd( std::string session_id, std::string reason , Result_Data_Callback callback )
	{
		IN_TASK_THREAD_WORKx(Crowd::apply_join_crowd , session_id , reason , callback);

		json::jobject actor;
		actor["name"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardName];
		actor["jid"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardJid];
		actor["icon"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardHeadURI];
		actor["sex"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardSex];
		actor["identity"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardIdentity];

		gWrapInterface::instance().apply_join_groups( session_id , actor , reason , boost::bind(&Crowd::apply_join_crowd_cb, this, session_id, callback, _1, _2, _3) );
	}

	void Crowd::apply_join_crowd_cb(std::string session_id, Result_Data_Callback callback, bool err, universal_resource reason, json::jobject data)
	{

		callback(err, reason, data);
	}

	static void get_search_conditions(std::map<std::string,std::string> &search_info, std::string key, json::jobject jobj)
	{
		search_info[key] = jobj.get<std::string>();
	}
	void Crowd::find_crowd( json::jobject jobj, Result_Data_Callback callback  )
	{
		IN_TASK_THREAD_WORKx(Crowd::find_crowd, jobj, callback);
		std::map<std::string,std::string> crowd_info;

		jobj["args"].each(bind2f(&get_search_conditions,boost::ref(crowd_info),_1,_2));

		gWrapInterface::instance().find_groups( crowd_info, boost::bind(&Crowd::find_crowd_cb, this, jobj, callback, _1 ,_2 , _3) );
	}

	void Crowd::download_uri_callback( bool bsuccess , std::string reason, std::string local_path, boost::function<void(bool err, universal_resource res, std::string local_path)> callback )
	{
		IN_TASK_THREAD_WORKx(Crowd::download_uri_callback, bsuccess, reason , local_path , callback );

		if(bsuccess)
		{
			callback(bsuccess ,XL(""), local_path);
		}
		else
		{
			callback(false,XL("Crowd.failed_to_download_uri"),"");
		}
	}

	void Crowd::download_uri( std::string uri,boost::function<void(bool err, universal_resource res, std::string local_path)> callback )
	{
		std::string uri_file_str = file_manager::instance().from_uri_to_path(uri);
		bool is_need = epius::epfilesystem::instance().file_exists(uri_file_str);
		if(is_need)
		{
			callback(true,XL(""),uri_file_str);
			return;
		}
		else
		{
			epius::http_requests::instance().download(anan_config::instance().get_http_down_path(), uri_file_str, uri, "", boost::function<void(int)>(), bind2f(&Crowd::download_uri_callback,this,_1,_2, uri_file_str,callback));
		}
	}

	void Crowd::find_crowd_cb( json::jobject jobj, Result_Data_Callback callback, bool err,  universal_resource reason,  json::jobject data )
	{
		if (err)
		{
			callback(true , reason , jobj);
			return;
		} 

		for (int i=0; i!=data.arr_size();++i)
		{
			data[i]["id"] = gWrapInterface::instance().append_groups_domain(data[i]["id"].get<std::string>());
			std::string uri =data[i]["icon"].get<std::string>();
			if (!uri.empty())
			{
				std::string uri_file_str = biz::file_manager::instance().from_uri_to_valid_path(uri);
				if (!uri_file_str.empty())
				{
					data[i]["icon"] = uri_file_str;
				}
				else
				{
					data[i]["icon"] = "";
					download_uri(uri,bind2f(&Crowd::set_head , this , data[i]["id"].get<std::string>(), _1 , _2 , _3));
				}
			}
		}
		jobj["crowd_list"] = data;
		callback(false, XL(""),jobj);
	}
	void Crowd::set_head(std::string id,bool succ , universal_resource reason , std::string local_path)
	{
		if (succ)
		{
			std::map<std::string, crowd_info>::iterator it = crowd_list_.find(id);
			if (it!= crowd_list_.end())
			{
				it->second.icon = local_path;
			}

			json::jobject jobj;
			jobj["session_id"] = id;
			jobj["icon"]= local_path;
			crowd_info_changed(jobj);
		}
		else
		{
			ELOG("app")->error("cannot download crowd icon: "  + id);
		}
	}

	void Crowd::do_get_crowd_message()
	{

		if(msg_queue_.empty())return;
		json::jobject jobj = msg_queue_.front();
		msg_queue_.pop_front();

		std::string jid = jobj["jid"].get<std::string>();
		if (jid.empty() || jid==get_parent_impl()->bizUser_->get_userName())
		{
			// 是自己的会话不处理
			return;
		}

		jid += "@";
		jid += app_settings::instance().get_domain();

		std::string crowd_name;
		if (had_fetch_list_)
		{
			//get discussion topic
			std::map<std::string, crowd_info>::iterator it = crowd_list_.find(jobj["from"].get<std::string>());
			if (it!= crowd_list_.end())
			{
				crowd_name = it->second.name;
			}
			else
			{
				ELOG("app")->error(WCOOL(L"收到群会话消息 但自己不在这个群里 session_id : ") + jobj["from"].get<std::string>());
				return;
			}
		}


		json::jobject msg_html_jobj(jobj["html"].get<std::string>());
		if (!msg_html_jobj.is_nil("image_ready") || !msg_html_jobj.is_nil("voice_ready")){
			return;
		}


		//群会话祛重, id是消息的id
 		if (get_parent_impl()->bizLocalConfig_->isCrowdMessageExist(jobj["from"].get<std::string>(), jid, jobj["id"].get<std::string>()))
 		{
 			ELOG("app")->error(WCOOL(L"收到群会话消息 但此消息已经接收过 session_id : ") + jobj["from"].get<std::string>() + 
 				" msg :" + jobj["html"].get<std::string>() + " id : " + jobj["id"].get<std::string>());
 			return;
 		}


		//取 showname
		ContactMap::iterator itvcard = get_parent_impl()->bizRoster_->syncget_VCard(jid);
		std::string show_name;
		if (itvcard != get_parent_impl()->bizRoster_->impl_->vcard_manager_.end()){
			std::set<std::string>::iterator it_req = get_parent_impl()->bizRoster_->requestVcard_jids_.find(jid);
			if (it_req != get_parent_impl()->bizRoster_->requestVcard_jids_.end())
			{
				show_name = WS2UTF(L"微哨用户");
			}
			else
			{
				KContactType ct = get_parent_impl()->bizRoster_->is_my_friend_(jid);
				if (ct != kctNone)
				{
					show_name =itvcard->second.get_vcardinfo()[s_VcardShowname].get<std::string>();
				}
				else
				{
					show_name = itvcard->second.get_vcardinfo()[s_VcardName].get<std::string>();
				}
			}
		}
		else{
			ELOG("app")->error(WCOOL(L"addgetRequestVCardWait 群组没有找到会话人的名片 session_id : ") + jid + " msg_queue_ size: " + lexical_cast<std::string>(msg_queue_.size()));
			get_parent_impl()->bizRoster_->addgetRequestVCardWait(jid, S10nNone, vard_type_full, bind_s(&AnRosterManager::updateMessageShowname, get_parent_impl()->bizRoster_, jid, _1));
			get_parent_impl()->bizRoster_->requestVcard_jids_.insert(jid);
			show_name = WS2UTF(L"微哨用户");
		}
	 

		json::jobject msg(jobj["html"].get<std::string>());
		get_parent_impl()->bizLocalConfig_->saveCrowdMessage(crowd_name, jobj["from"].get<std::string>(), jid, show_name, msg, jobj["id"].get<std::string>(), false);
		get_parent_impl()->bizRoster_->UpdateRecentContact(jobj["from"].get<std::string>() , kRecentCrowd);
		event_collect::instance().recv_session_msg(jobj["from"].get<std::string>(), jid, show_name, msg.to_string());

		// 处理下一条会话消息
		get_parent_impl()->_p_private_task_->post(bind2f(&Crowd::do_get_crowd_message, this));
	}

	void Crowd::handler_get_crowd_message( json::jobject jobj )
	{
		msg_queue_.push_back(jobj);
		do_get_crowd_message();
	}

	void Crowd::handler_get_quit_crowd_message( json::jobject jobj )
	{
		build_one_member_info(jobj["member_info"]);

		std::string session_id = jobj["session_id"].get<std::string>();
		json::jobject  info;
		std::map<std::string, crowd_info>::iterator it = crowd_list_.find(session_id);
		if (it!= crowd_list_.end())
		{
			info["txt"] = WS2UTF(L"已退出了群");
			info["category"] = it->second.category;
			info["icon"] = it->second.icon;
			info["crowd_name"] = it->second.name;
			info["crowd_remark"] = it->second.remark;
			info["actor_name"] = jobj["member_info"]["showname"];
			info["actor_jid"] = jobj["member_info"]["jid"];
		
			//写系统消息
			json::jobject req_jobj;
			req_jobj["info"] = info;//xxx 已退出群 xxx
			req_jobj["msg_type"] = "crowd_quit";
			req_jobj["server_time"] = jobj["server_time"];
			req_jobj["is_read"] = false;
			std::string rowid = get_parent_impl()->bizLocalConfig_->saveRequestMsg(session_id, req_jobj);

			json::jobject system_message;
			system_message["session_id"] = session_id;
			system_message["rowid"] = rowid;
			system_message["msg_type"] = "crowd_quit";
			system_message["info"] = info;
			crowd_system_message(system_message);
		}
	}


	void Crowd::handler_crowd_list_changed( json::jobject jobj )
	{
		if (!jobj.is_nil("actor"))
		{
			build_one_member_info(jobj["actor"]);
		}
		if (!jobj.is_nil("member_info"))
		{
			build_one_member_info(jobj["member_info"]);
		}
		
		json::jobject req_jobj;
		req_jobj["server_time"] = jobj["server_time"];
		req_jobj["is_read"] = false;
		std::string session_id;

		if (!jobj.is_nil("session_id"))
		{
			session_id = jobj["session_id"].get<std::string>();
		}
		else if (!jobj["crowd_info"].is_nil("session_id"))
		{
			session_id = jobj["crowd_info"]["session_id"].get<std::string>();
		}
		
		if (jobj["type"].get<std::string>()=="quit")
		{
			std::map<std::string, crowd_info>::iterator it = crowd_list_.find(session_id);
			if (it!= crowd_list_.end())
			{
				json::jobject info;
				info["txt"] = WS2UTF(L"你已退出了群");
				info["category"] = it->second.category;
				info["icon"] = it->second.icon;
				info["crowd_name"] = it->second.name;
				info["crowd_remark"] = it->second.remark;

				//写系统消息
				req_jobj["info"] = info;//xxx 已退出群 xxx
				req_jobj["msg_type"] = "crowd_quit_self";
				std::string rowid = get_parent_impl()->bizLocalConfig_->saveRequestMsg(session_id, req_jobj);
				crowd_list_.erase(it);

				//发送系统通知
				json::jobject system_message;
				system_message["session_id"] = session_id;
				system_message["rowid"] = rowid;
				system_message["msg_type"] = "crowd_quit_self";
				system_message["info"] = info;
				crowd_system_message(system_message);

				//更新列表
				jobj["type"] = "remove";
				crowd_list_changed(jobj);
			}
		}
		else if(jobj["type"].get<std::string>()=="kickout")
		{
			build_one_member_info(jobj["actor"]);
			std::map<std::string, crowd_info>::iterator it = crowd_list_.find(session_id);
			if (it!= crowd_list_.end())
			{
				json::jobject info;
				info["txt"] = WS2UTF(L"你被管理员请出群");
				info["category"] = it->second.category;
				info["icon"] = it->second.icon;
				info["crowd_name"] = it->second.name;
				info["crowd_remark"] = it->second.remark;
				info["actor_name"] = jobj["actor"]["showname"];
				info["actor_jid"] = jobj["actor"]["jid"];

				//写系统消息
				req_jobj["info"] = info;
				req_jobj["session_id"] = jobj["session_id"].get<std::string>();
				req_jobj["msg_type"] = "crowd_kickout";
				std::string rowid = get_parent_impl()->bizLocalConfig_->saveRequestMsg(session_id, req_jobj);
				
				//更新列表
				json::jobject crowd_jobj;
				crowd_jobj["type"]="remove";
				crowd_jobj["crowd_info"]=jobj["crowd_info"];
				crowd_list_changed(crowd_jobj);
				
				//向界面层通知
				req_jobj["rowid"] = rowid;
				crowd_system_message(req_jobj);

				crowd_list_.erase(it);
			}
			else
			{
				json::jobject info;
				info["txt"] = WS2UTF(L"你被管理员请出群");
				info["category"] = jobj["crowd_info"]["category"].get<std::string>();
				info["crowd_name"] = jobj["crowd_info"]["name"].get<std::string>();

				std::string uri = jobj["crowd_info"]["icon"].get<std::string>();
				if (!uri.empty())
				{
					std::string uri_file_str = biz::file_manager::instance().from_uri_to_valid_path(uri);
					if (!uri_file_str.empty())
					{
						info["icon"] = uri_file_str;
					}
					else
					{
						download_uri( uri , bind2f(&Crowd::set_head , this , jobj["session_id"].get<std::string>(), _1 , _2 , _3));
					}
				}

				//写系统消息
				req_jobj["info"] = info;
				req_jobj["session_id"] = jobj["session_id"].get<std::string>();
				req_jobj["msg_type"] = "crowd_kickout";
				std::string rowid = get_parent_impl()->bizLocalConfig_->saveRequestMsg(session_id, req_jobj);

				//向界面层通知
				req_jobj["rowid"] = rowid;
				crowd_system_message(req_jobj);
			}
		}
		else if(jobj["type"].get<std::string>()=="dismiss") 
		{
			json::jobject info;			
			build_one_member_info(jobj["actor"]);
			std::map<std::string, crowd_info>::iterator it = crowd_list_.find(session_id);
			if (it!= crowd_list_.end())
			{
				if (jobj["actor"]["jid"].get<std::string>()==get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardJid].get<std::string>())
				{	
					info["txt"] = WS2UTF(L"你已经解散群");
					req_jobj["msg_type"] = "crowd_dismiss_success";
				}
				else{
				info["txt"] = WS2UTF(L"你所在的群被解散");
				info["result"] = WS2UTF(L"已解散");
				req_jobj["msg_type"] = "crowd_dismiss";
				}
				info["crowd_name"] = it->second.name;
				info["crowd_remark"] = it->second.remark;
				info["category"] = it->second.category;
				info["icon"] = it->second.icon;
				info["actor_name"] = jobj["actor"]["showname"];
				info["actor_jid"] = jobj["actor"]["jid"];
				crowd_list_.erase(it);

				//写系统消息
				req_jobj["info"] = info;
				req_jobj["session_id"] = session_id;
				std::string rowid = get_parent_impl()->bizLocalConfig_->saveRequestMsg(session_id, req_jobj);
				req_jobj["rowid"] = rowid;
				crowd_system_message(req_jobj);
				
				json::jobject crowd_jobj;
				crowd_jobj["type"]="remove";
				crowd_jobj["crowd_info"]=jobj["crowd_info"];
				crowd_jobj["crowd_info"]["session_id"]=session_id;
				crowd_list_changed(crowd_jobj);
			}
			else
			{
				json::jobject info;
				info["txt"] = WS2UTF(L"你所在的群被解散");
				info["result"] = WS2UTF(L"已解散");
				info["crowd_name"] = jobj["crowd_info"]["name"].get<std::string>();
				info["category"] = jobj["crowd_info"]["category"].get<std::string>();

				std::string uri = jobj["crowd_info"]["icon"].get<std::string>();
				if (!uri.empty())
				{
					std::string uri_file_str = biz::file_manager::instance().from_uri_to_valid_path(uri);
					if (!uri_file_str.empty())
					{
						info["icon"] = uri_file_str;
					}
					else
					{
						download_uri( uri , bind2f(&Crowd::set_head , this , jobj["session_id"].get<std::string>(), _1 , _2 , _3));
					}
				}
				
				//写系统消息
				req_jobj["info"] = info;
				req_jobj["session_id"] = session_id;
				req_jobj["msg_type"] = "crowd_dismiss";
				std::string rowid = get_parent_impl()->bizLocalConfig_->saveRequestMsg(session_id, req_jobj);
				req_jobj["rowid"] = rowid;
				crowd_system_message(req_jobj);
			}
		}
		else if (jobj["type"].get<std::string>()=="create")
		{
			//更新缓存
			jobj["role"]="super";
			build_one_crowd_info(session_id,jobj);
			json::jobject info;
			info["txt"] = epius::txtutil::convert_wcs_to_utf8(L"你成功创建了群");
			info["icon"] = jobj["icon"];
			info["crowd_name"]=jobj["name"];
			info["category"]=jobj["category"];

			//写系统消息
			req_jobj["info"] = info;
			req_jobj["msg_type"] = "create_crowd";
			std::string rowid = get_parent_impl()->bizLocalConfig_->saveRequestMsg(session_id, req_jobj);

			//发送系统通知
			json::jobject system_message;
			system_message["session_id"] = session_id;
			system_message["rowid"] = rowid;
			system_message["msg_type"] = "create_crowd";
			system_message["info"] = info;
			crowd_system_message(system_message);

			//发送群列表变更通知
			json::jobject crowd_jobj;
			crowd_jobj["type"]="add";
			crowd_jobj["crowd_info"]=jobj;
			crowd_list_changed(crowd_jobj);
		}
		else if (jobj["type"].get<std::string>()=="accept")
		{
			//更新缓存
//			build_one_crowd_info(session_id,jobj["crowd_info"]);
			build_one_member_info(jobj["member_info"]);
			json::jobject info;
			info["txt"] =WS2UTF(L"你申请加入群");
			info["result"]=WS2UTF(L"已加入");
			info["actor_name"]=jobj["member_info"]["showname"];
			info["actor_jid"]=jobj["member_info"]["jid"];
			info["server_time"] = jobj["server_time"];
			get_crowd_info(session_id,bind2f(&Crowd::system_message_common_cb, this, session_id,info,"crowd_apply_accept" , "add" , _1, _2,_3));				
			

		}
		else if (jobj["type"].get<std::string>()=="no_auth_accept")//无验证直接加入
		{
			json::jobject info;
			info["txt"] =WS2UTF(L"你已加入群");
			info["icon"] = jobj["crowd_info"]["icon"];
			info["crowd_name"]=jobj["crowd_info"]["name"];
			info["category"]=jobj["crowd_info"]["category"];

			//写系统消息
			get_crowd_info(session_id,bind2f(&Crowd::system_message_common_cb, this, session_id,info,"crowd_apply_no_auth_accept" , "add" , _1, _2,_3));		
		}
		else if (jobj["type"].get<std::string>()=="invite")
		{
			get_crowd_info(session_id,bind2f(&Crowd::system_message_common_cb, this, session_id,"","","add" , _1, _2,_3));				

		}
	}
	void Crowd::handler_crowd_member_changed( json::jobject jobj )
	{
		build_one_member_info(jobj["member_info"]);

		crowd_member_changed(jobj);
	}

	void Crowd::handler_crowd_info_changed( json::jobject jobj )
	{
		std::string uri , status ,old_status;
		std::string session_id = jobj["session_id"].get<std::string>();
		std::map<std::string, crowd_info>::iterator it = crowd_list_.find(session_id);

		//查找不到缓存时 群在管理端被删除
		if (jobj.is_nil("status"))
		{
			status="";
		}
		else{
			status = jobj["status"].get<std::string>();
			old_status=jobj["old_status"].get<std::string>();
		}
		json::jobject info;
		if (!status.empty())
		{
			info["crowd_name"]= jobj["name"].get<std::string>();
			info["category"]=jobj["category"].get<std::string>();
			std::string uri = jobj["icon"].get<std::string>();
			if (!uri.empty())
			{
				std::string uri_file_str = biz::file_manager::instance().from_uri_to_valid_path(uri);
				if (!uri_file_str.empty())
				{
					info["icon"] = uri_file_str;
				}
				else
				{
					info["icon"] = "";
					download_uri( uri , bind2f(&Crowd::set_head , this , session_id , _1 , _2 , _3));
				}
			}
			if (it == crowd_list_.end())
			{
				if (status=="0"&&old_status == "2")
				{
					info["server_time"] = jobj["server_time"];
					info["txt"] =WS2UTF(L"你所在的群已被管理系统恢复");
					get_crowd_info(session_id,bind2f(&Crowd::system_message_common_cb, this, session_id,info,"crowd_web_groups_list" , "add",_1, _2,_3));
					return ;
				}
				else if (status == "2")
				{
					info["txt"] = WS2UTF(L"你所在的群已被管理系统删除");
				}
				else{
					return ;
				}
				
			}
			else if (it != crowd_list_.end())
			{
				info["icon"] = it->second.icon;
				info["crowd_name"]=it->second.name;
				info["crowd_remark"]=it->second.remark;
				info["category"]=it->second.category;
				it->second.status = status;
				if (status == "2")
				{
					info["txt"] = WS2UTF(L"你所在的群已被管理系统删除");
					if (it!=crowd_list_.end())
						crowd_list_.erase(it);

					json::jobject crowd_jobj;
					crowd_jobj["type"]="remove";
					crowd_jobj["crowd_info"]["session_id"]=session_id;
					crowd_list_changed(crowd_jobj);
				}
				else if (old_status == "0" && status == "1")
				{
					info["txt"] =WS2UTF(L"你所在的群已被管理系统冻结");
				}
				else if (old_status == "1" && status == "0")
				{
					info["txt"] =WS2UTF(L"你所在的群已被管理系统解冻");
				}
				else if (old_status == "2" && status=="0")
				{
					info["txt"] =WS2UTF(L"你所在的群已被管理系统恢复");
				}
				

				json::jobject crowd_info;
				crowd_info["session_id"]=session_id;
				crowd_info["status"]=status;
				crowd_info_changed(crowd_info);
			}
			json::jobject req_jobj;
			req_jobj["server_time"] = jobj["server_time"];
			req_jobj["is_read"] = false;
			req_jobj["info"] = info;
			req_jobj["msg_type"] = "crowd_web_groups_list";
			std::string rowid = get_parent_impl()->bizLocalConfig_->saveRequestMsg(session_id, req_jobj);
			//发送系统通知
			json::jobject system_message;
			system_message["session_id"] = session_id;
			system_message["rowid"] = rowid;
			system_message["msg_type"] = "crowd_web_groups_list";
			system_message["info"] = info;
			crowd_system_message(system_message);

			return;
		}
		
		if(it!=crowd_list_.end())
		{
			if (jobj.is_nil("icon"))
			{
				uri="";
			}
			else{
				uri = jobj["icon"].get<std::string>();
			}
			if (!uri.empty())
			{
				std::string uri_file_str = biz::file_manager::instance().from_uri_to_valid_path(uri);
				if (!uri_file_str.empty())
				{
					jobj["icon"] = uri_file_str;
					if (it!= crowd_list_.end())
					{
						it->second.icon = uri_file_str;
					}
				}
				else
				{
					jobj["icon"] = "";
					download_uri( uri , bind2f(&Crowd::set_head , this , session_id , _1 , _2 , _3));
				}
			}

			if (jobj.is_nil("name"))
			{
				jobj["name"]=it->second.name;
			}
			else{
				it->second.name = jobj["name"].get<std::string>();
			}
			if (jobj["category"].get<std::string>().empty())
			{
				jobj["category"]=it->second.category;
			}
			else{
				it->second.category = jobj["category"].get<std::string>();
			}
			if (jobj.is_nil("remark"))
			{
				jobj["remark"]=it->second.remark;
			}
			else{
				it->second.remark = jobj["remark"].get<std::string>();
			}
			if (jobj.is_nil("official"))
			{
				jobj["official"]=it->second.official;
			}
			else{
				it->second.official = jobj["official"].get<std::string>();
			}
			crowd_info_changed(jobj);
		}
	}

	bool Crowd::is_crowd_exist( std::string session_id )
	{
		return crowd_list_.find(session_id) != crowd_list_.end();
	}

	std::string Crowd::get_crowd_icon_by_id(std::string session_id)
	{
		std::map<std::string, crowd_info>::iterator it = crowd_list_.find(session_id);
		if (it!= crowd_list_.end())
		{
			return it->second.icon;
		}
		else
		{
			return "";
		}
	}


	std::string Crowd::get_crowd_category_by_id( std::string session_id )
	{
		std::map<std::string, crowd_info>::iterator it = crowd_list_.find(session_id);
		if (it!= crowd_list_.end())
		{
			return it->second.category;
		}
		else
		{
			return "";
		}
	}
	std::string Crowd::get_crowd_name(std::string session_id)
	{
		std::map<std::string, crowd_info>::iterator it = crowd_list_.find(session_id);
		if (it!= crowd_list_.end())
		{
			return it->second.name;
		}
		return "";
	}
	std::string Crowd::send_msg( std::string session_id, std::string const& txt_msg, std::string const& msg )
	{
		std::map<std::string, crowd_info>::iterator it = crowd_list_.find(session_id);
		std::string crowd_name;
		if (it!= crowd_list_.end())
		{
			crowd_name = it->second.name;
		}
		else
		{
			ELOG("app")->error(WCOOL(L"发送讨论组会话消息 但查找不到相应讨论组信息 session_id : ") + session_id);
			return crowd_name;
		}

		gWrapInterface::instance().send_msg(session_id, txt_msg, msg);

		return crowd_name;
	}


	void Crowd::search_local_crowd(std::string filterString, json::jobject& jobj )
	{
		if (filterString.empty())
			return;

		std::map<std::string, crowd_info>::iterator it;
		for (it = crowd_list_.begin(); it!= crowd_list_.end(); it++)
		{
			std::string remark = it->second.remark;
			std::string name = it->second.name;
			if(!remark.empty())
			{
				// 执行匹配。
				if (_MatchEach(jobj, filterString,remark,it->first, it->second.icon, it->second.category, it->second.official, it->second.active))
				{
					return;
				}
			}
			else if(!name.empty())
			{			
				// 执行匹配。
				_MatchEach(jobj, filterString, name,it->first, it->second.icon, it->second.category, it->second.official, it->second.active);
			}
		}
		
	}

	bool Crowd::_MatchEach( json::jobject& jobj, const std::string& filterString, const std::string& name, const std::string session_id, std::string head_uri, std::string categroy, std::string official, std::string active)
	{
		if (eplocal_find::instance().match(filterString,name))
		{
			fireMatch(jobj, session_id, name, head_uri, categroy, official, active);
			return true;
		}
		return false;
	}

	void Crowd::fireMatch( json::jobject& jobj, std::string session_id, std::string name, std::string head_uri, std::string category, std::string official, std::string active)
	{
		jobj[session_id][s_VcardJid] = session_id;
		jobj[session_id]["name"] = name;
		jobj[session_id]["icon"] = head_uri;
		jobj[session_id]["category"] = category;
		jobj[session_id]["type"] = message_crowd_chat;
		jobj[session_id]["official"] = official;
		jobj[session_id]["active"] = active;
	}

	void Crowd::handler_crowd_upload_file( json::jobject jobj )
	{
		KContactType ct = get_parent_impl()->bizRoster_->is_my_friend_(jobj["actor"]["jid"].get<std::string>());
		if (ct != kctNone)
		{
			ContactMap::iterator itvcard = get_parent_impl()->bizRoster_->syncget_VCard(jobj["actor"]["jid"].get<std::string>());
			jobj["actor"][s_VcardShowname] = itvcard->second.get_vcardinfo()[s_VcardShowname].get<std::string>();
			jobj["file"]["owner_name"] = itvcard->second.get_vcardinfo()[s_VcardName].get<std::string>();
		}

		crowd_share_file_changed(jobj);
	}

	

	void Crowd::set_crowd_file_info( std::string session_id ,std::string id , std::string mode ,Result_Callback callback )
	{
		IN_TASK_THREAD_WORKx(Crowd::set_crowd_file_info, session_id, id , mode, callback );

		gWrapInterface::instance().set_groups_share_info( session_id, id , mode, callback );
	}

	void Crowd::create_crowd( json::jobject crowd_detail ,Result_Data_Callback callback )
	{		
		IN_TASK_THREAD_WORKx(Crowd::create_crowd, crowd_detail , callback);

		gWrapInterface::instance().create_groups(crowd_detail,bind2f(&Crowd::create_crowd_cb ,this , callback,_1 , _2 , _3));
	}
	void Crowd::create_crowd_cb(Result_Data_Callback callback , bool err, universal_resource reason, json::jobject data )
	{
		callback(err,reason,data);
	}

	void Crowd::dismiss_crowd( std::string session_id, Result_Callback callback )
	{
		IN_TASK_THREAD_WORKx(Crowd::dismiss_crowd, session_id, callback );


		json::jobject actor;
		actor["name"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardName];
		actor["jid"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardJid];

		std::map<std::string, crowd_info>::iterator it=crowd_list_.find(session_id);
		if (it!=crowd_list_.end())
		{
			json::jobject item;
			item["name"] = it->second.name;
			item["category"] = it->second.category;
			item["icon"] = epius::epfilesystem::instance().file_name(it->second.icon);

			gWrapInterface::instance().dismiss_groups( session_id , actor, item, boost::bind(&Crowd::dismiss_crowd_cb, this, session_id, callback, _1, _2));
		}
		else
		{
			//本地找不到群， 无法解散
			callback(true, XL("biz.crwod.iq_error.item-not-found"));
		}
	}

	void Crowd::dismiss_crowd_cb( std::string session_id, Result_Callback callback, bool err, universal_resource reason )
	{
		callback(err, reason);
	}

	void Crowd::crowd_kickout_member( std::string session_id , std::string jid,std::string name, Result_Callback callback )
	{
		IN_TASK_THREAD_WORKx(Crowd::crowd_kickout_member, session_id , jid , name , callback );

		std::map<std::string, crowd_info>::iterator it=crowd_list_.find(session_id);
		if (it!=crowd_list_.end())
		{
			json::jobject actor;
			actor["name"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardName];
			actor["jid"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardJid];

			json::jobject item;
			item["jid"] = jid;
			item["name"]=name;

			json::jobject crowd;
			crowd["name"] = it->second.name;
			crowd["category"] = it->second.category;
			crowd["icon"] = epius::epfilesystem::instance().file_name(it->second.icon);

			gWrapInterface::instance().groups_kickout_member( session_id , actor , item , crowd , callback );
		}
		else
		{
			//查找不到群 不能踢人
			callback(true, XL("biz.crwod.iq_error.item-not-found"));
		}
	}
	void Crowd::handler_apply_join_crowd_wait( json::jobject jobj )
	{
		json::jobject info, req_jobj;
		info["actor_sex"]=jobj["member_info"]["sex"];
		info["actor_identity"]=jobj["member_info"]["identity"];
		info["actor_icon"]=jobj["member_info"]["photo_credential"];
		build_one_member_info(jobj["member_info"]);
		std::string session_id=jobj["session_id"].get<std::string>();
		
		std::map<std::string, crowd_info>::iterator it=crowd_list_.find(session_id);
		if (it!=crowd_list_.end())
		{
			info["icon"] = it->second.icon;
			info["crowd_name"]= it->second.name;
			info["category"]= it->second.category;
			info["crowd_remark"]= it->second.remark;
		
			info["txt"] =WS2UTF(L"申请加入群");
			info["reason"]=jobj["member_info"]["html"];
			info["actor_name"]=jobj["member_info"]["showname"];
			info["actor_jid"]=jobj["member_info"]["jid"];
			info["result"]=WS2UTF(L"未处理");
			//写系统消息
			req_jobj["server_time"] = jobj["server_time"];
			req_jobj["is_read"] = false;
			req_jobj["info"] = info;
			req_jobj["msg_type"] = "crowd_apply_authen";
			std::string rowid = get_parent_impl()->bizLocalConfig_->saveRequestMsg(session_id, req_jobj);
			//发送系统通知
			json::jobject system_message;
			system_message["session_id"] = session_id;
			system_message["rowid"] = rowid;
			system_message["msg_type"] = "crowd_apply_authen";
			system_message["info"] = info;
			crowd_system_message(system_message);
		}
	}
	void Crowd::answer_apply_join_crowd( std::string session_id , std::string accept,std::string rowid , json::jobject actor , std::string reason, std::string admin_reason , Result_Callback callback )
	{
		IN_TASK_THREAD_WORKx(Crowd::answer_apply_join_crowd, session_id ,  accept , rowid , actor , reason , admin_reason ,  callback );
		json::jobject item,crowd;
		item["name"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardName];
		item["jid"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardJid];
		item["icon"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardHeadURI];
		item["sex"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardSex];
		item["identity"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardIdentity];
		actor["admin_reason"]=admin_reason;
		std::map<std::string, crowd_info>::iterator it=crowd_list_.find(session_id);
		if (it!=crowd_list_.end())
		{
			crowd["name"] = it->second.name;
			crowd["icon"] = epfilesystem::instance().file_name(it->second.icon);
			crowd["quit"] = it->second.quit;
			crowd["status"] = it->second.status;
			crowd["official"] = it->second.official;
			crowd["active"] = it->second.active;
			crowd["category"] = it->second.category;
			crowd["dismiss"] = it->second.dismiss;
		}


		gWrapInterface::instance().groups_admin_manage_member(session_id, accept, admin_reason , reason , actor , item , crowd, bind2f(&Crowd::answer_apply_join_crowd_cb, this, session_id,accept , rowid , actor , reason, callback, _1, _2));
	}
	void Crowd::answer_apply_join_crowd_cb( std::string session_id , std::string accept, std::string rowid , json::jobject actor , std::string apply_reason , Result_Callback callback, bool err, universal_resource reason_err )
	{

		if (!err)
		{
			actor["photo_credential"]=actor["icon"];
			actor["showname"]=actor["name"];

			build_one_member_info(actor);	
			std::map<std::string, crowd_info>::iterator it=crowd_list_.find(session_id);
			json::jobject info,req_jobj,member_jobj;
			if (it!=crowd_list_.end())
			{
				info["icon"] =it->second.icon;
				info["crowd_name"]=it->second.name;
				info["crowd_remark"]=it->second.remark;
				info["category"]=it->second.category;
			}
			info["txt"] =WS2UTF(L"申请加入群");
			if (accept=="no")
			{
				info["result"] =WS2UTF(L"已拒绝");
				info["reason"]=actor["admin_reason"];
			}
			else{
				info["result"] =WS2UTF(L"已同意");
				info["reason"]=apply_reason;
				member_jobj["session_id"]=session_id;
				member_jobj["member_info"]=actor;
				member_jobj["type"]="add";
				crowd_member_changed(member_jobj);
			}
			info["actor_name"]=actor["name"];
			info["actor_jid"]=actor["jid"];
			info["name"]=get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardName];
			info["jid"]= get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardJid];

			//写系统消息
			req_jobj["server_time"] = "";
			req_jobj["is_read"] = false;
			req_jobj["info"] = info;
			req_jobj["msg_type"] = "crowd_apply_accept_admin_self";
			get_parent_impl()->bizLocalConfig_->replaceRequestMsg(session_id, req_jobj,rowid);
			//发送系统通知
			if (reason_err.res_key.empty())
			{
				json::jobject system_message;
				system_message["session_id"] = session_id;
				system_message["rowid"] = rowid;
				system_message["msg_type"] = "crowd_apply_accept_admin_self";
				system_message["info"] = info;
				crowd_system_message(system_message);
			}
			
		}
		
		callback(err,reason_err);
	}
	void Crowd::handler_recv_apply_join_crowd_response( json::jobject jobj )
	{
		std::string session_id = jobj["session_id"].get<std::string>();
		build_crowd_icon(session_id , jobj["crowd_info"]);
		build_one_member_info(jobj["member_info"]);
		json::jobject info,req_jobj;
		info["txt"] =WS2UTF(L"你申请加入群");
		info["icon"] = jobj["crowd_info"]["icon"];
		info["crowd_name"]=jobj["crowd_info"]["name"];
		info["category"]=jobj["crowd_info"]["category"];
		info["actor_name"]=jobj["member_info"]["showname"];
		info["actor_jid"]=jobj["member_info"]["jid"];
		info["result"] =WS2UTF(L"被拒绝");
		info["reason"] =jobj["reason"];

		//写系统消息
		req_jobj["server_time"] = jobj["server_time"];
		req_jobj["is_read"] = false;
		req_jobj["info"] = info;
		req_jobj["msg_type"] = "crowd_apply_not_accept";
		std::string rowid = get_parent_impl()->bizLocalConfig_->saveRequestMsg(session_id, req_jobj);
		//发送系统通知
		json::jobject system_message;
		system_message["session_id"] = session_id;
		system_message["rowid"] = rowid;
		system_message["msg_type"] = "crowd_apply_not_accept";
		system_message["info"] = info;
		crowd_system_message(system_message);
	}

	void Crowd::crowd_apply_superadmin( std::string session_id , std::string reason , Result_Callback callback )
	{
		IN_TASK_THREAD_WORKx(Crowd::crowd_apply_superadmin, session_id,  reason  ,  callback );

		gWrapInterface::instance().groups_role_apply(session_id,  reason ,  callback);
	}

	void Crowd::handler_crowd_member_role_change( json::jobject jobj )
	{
		build_one_member_info(jobj["actor"]);
		build_one_member_info(jobj["member_info"]);
		crowd_member_role_changed(jobj);
	}

	void Crowd::handler_crowd_role_change( json::jobject jobj )
	{
		build_one_member_info(jobj["actor"]);
		std::string session_id=jobj["session_id"].get<std::string>();
		json::jobject info,req_jobj;
		if (jobj["member_info"]["role"].get<std::string>()=="admin")
		{
			info["txt"] =WS2UTF(L"你成为群管理员");
		}
		else
		{
			info["txt"] =WS2UTF(L"你被取消群管理员");
		}
		std::map<std::string, crowd_info>::iterator it = crowd_list_.find(session_id);
		if (it!= crowd_list_.end())
		{
			info["icon"] = it->second.icon;
			it->second.role=jobj["member_info"]["role"].get<std::string>();
		}
		else
		{
			ELOG("app")->error(WCOOL(L"成员身份更改时，查找不到相应讨论组信息 session_id : ") +session_id);
			return;		
		}
		info["crowd_name"]=it->second.name;
		info["crowd_remark"]=it->second.remark;
		info["category"]=it->second.category;
		info["actor_name"]=""/*jobj["actor"]["name"]*/;
		info["actor_jid"]=""/*jobj["actor"]["jid"]*/;

		//写系统消息
		req_jobj["server_time"] = jobj["server_time"];
		req_jobj["is_read"] = false;
		req_jobj["info"] = info;
		req_jobj["msg_type"] = "crowd_role_change";
		std::string rowid = get_parent_impl()->bizLocalConfig_->saveRequestMsg(session_id, req_jobj);
		//发送系统通知
		json::jobject system_message;
		system_message["session_id"] = session_id;
		system_message["rowid"] = rowid;
		system_message["msg_type"] = "crowd_role_change";
		system_message["info"] = info;
		crowd_system_message(system_message);
	}

	void Crowd::crowd_role_change( std::string session_id , std::string jid ,std::string role , Result_Callback callback )
	{
		IN_TASK_THREAD_WORKx(Crowd::crowd_role_change, session_id,   jid , role ,  callback );
		json::jobject actor , item;
		actor["name"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardName];
		actor["jid"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardJid];
		item["jid"]=jid;
		item["role"]=role;
		gWrapInterface::instance().groups_role_change(session_id,   actor , item ,  callback);

	}

	void Crowd::handler_crowd_role_applyed( json::jobject jobj )
	{
		std::map<std::string, crowd_info>::iterator it = crowd_list_.find(jobj["session_id"].get<std::string>());
		if (it!=crowd_list_.end())
		{
			crowd_superadmin_applyed(jobj);
		}
	}

	void Crowd::handler_crowd_superadmin_applyed_self( json::jobject jobj )
	{
		std::string session_id=jobj["session_id"].get<std::string>();
		json::jobject info;
		std::map<std::string, crowd_info>::iterator it = crowd_list_.find(session_id);
		if (it!=crowd_list_.end())
		{
			info["icon"] =it->second.icon;
			info["crowd_name"]=it->second.name;
			info["crowd_remark"]=it->second.remark;
			info["category"]=it->second.category;
		}
		else{
			ELOG("app")->error("cannot find crowd " + session_id);
			return;
		}
		if (jobj["accept"].get<std::string>()=="true")
		{
			info["txt"] = WS2UTF(L"你成为群超级管理员");
			it->second.role=jobj["member_info"]["role"].get<std::string>();
			info["result"]=WS2UTF(L"");
		}
		else
		{
			info["result"]=WS2UTF(L"");
			info["txt"] = WS2UTF(L"你被拒绝成为群超级管理员");
		}
		info["actor_name"]=WS2UTF(L"");
		
		//写系统消息
		json::jobject req_jobj;
		req_jobj["server_time"] = jobj["server_time"];
		req_jobj["is_read"] = false;
		req_jobj["info"] = info;
		req_jobj["msg_type"] = "crowd_superadmin_apply_response";
		std::string rowid = get_parent_impl()->bizLocalConfig_->saveRequestMsg(session_id, req_jobj);
		//发送系统通知
		json::jobject system_message;
		system_message["session_id"] = session_id;
		system_message["rowid"] = rowid;
		system_message["msg_type"] = "crowd_superadmin_apply_response";
		system_message["info"] = info;
		crowd_system_message(system_message);
	}

	void Crowd::handler_crowd_superadmin_applyed_response( json::jobject jobj )
	{
		if (jobj["accept"].get<std::string>()=="true")
		{
			jobj["accept"]="yes";
		}
		else
		{
			jobj["accept"]="no";
		}
		crowd_superadmin_applyed_response(jobj);
	}

	void Crowd::crowd_role_demise( std::string session_id ,std::string jid, std::string name , Result_Callback callback )
	{
		IN_TASK_THREAD_WORKx(Crowd::crowd_role_demise, session_id,  jid , name ,  callback );
		json::jobject actor,jobj;
		actor["name"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardName];
		actor["jid"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardJid];
		gWrapInterface::instance().groups_role_demise(session_id , jid ,actor, bind2f(&Crowd::crowd_role_demise_cb ,this ,session_id , jid , name , callback,_1 , _2 ));
	}

	void Crowd::crowd_role_demise_cb( std::string session_id , std::string jid , std::string name , Result_Callback callback, bool err, universal_resource reason )
	{
		callback(err,reason);
		if (!err)
		{
			json::jobject info;
			std::map<std::string, crowd_info>::iterator it = crowd_list_.find(session_id);
			if (it!=crowd_list_.end())
			{
				it->second.role="none";
				info["icon"] =it->second.icon;
				info["crowd_name"]=it->second.name;
				info["crowd_remark"]=it->second.remark;
				info["category"]=it->second.category;
			}
			else{
				ELOG("app")->error("cannot find crowd " + session_id);
				return;
			}
			
			info["txt"] = WS2UTF(L"你将超级管理员转让给");
			info["result"]=WS2UTF(L"已成功转让");
		    info["name"]=name;
			info["jid"]=jid;

			//写系统消息
			json::jobject req_jobj;
			req_jobj["server_time"] = "";
			req_jobj["is_read"] = false;
			req_jobj["info"] = info;
			req_jobj["msg_type"] = "crowd_demise_success";
			std::string rowid = get_parent_impl()->bizLocalConfig_->saveRequestMsg(session_id, req_jobj);
			//发送系统通知
			json::jobject system_message;
			system_message["session_id"] = session_id;
			system_message["rowid"] = rowid;
			system_message["msg_type"] = "crowd_demise_success";
			system_message["info"] = info;
			crowd_system_message(system_message);
		}	
	}

	void Crowd::handler_crowd_role_demise( json::jobject jobj )
	{
		build_one_member_info(jobj["actor"]);
		//更新缓存
		json::jobject info,req_jobj;
		std::string session_id =  jobj["session_id"].get<std::string>();
		info["txt"] = WS2UTF(L"将超级管理员转让给你");
		std::map<std::string, crowd_info>::iterator it = crowd_list_.find(session_id);
		if (it!=crowd_list_.end())
		{
			it->second.role="super";
			info["icon"] = it->second.icon;
			info["crowd_name"]=it->second.name;
			info["crowd_remark"]=it->second.remark;
			info["category"]=it->second.category;
		}
		info["actor_name"] =jobj["actor"]["showname"].get<std::string>();
		info["actor_jid"] =jobj["actor"]["jid"].get<std::string>();
		

		//写系统消息
		req_jobj["server_time"] = jobj["server_time"];
		req_jobj["is_read"] = false;
		req_jobj["info"] = info;
		req_jobj["msg_type"] = "crowd_demise";
		std::string rowid = get_parent_impl()->bizLocalConfig_->saveRequestMsg(session_id, req_jobj);

		//发送系统通知
		json::jobject system_message;
		system_message["session_id"] = session_id;
		system_message["rowid"] = rowid;
		system_message["msg_type"] = "crowd_demise";
		system_message["info"] = info;
		crowd_system_message(system_message);
	}

	void Crowd::handler_apply_join_groups_accepted( json::jobject jobj )
	{
		//更新缓存
		std::string session_id=jobj["session_id"].get<std::string>();
		build_crowd_icon(session_id,jobj["crowd_info"]);
		build_one_member_info(jobj["member_info"]);
		json::jobject info,req_jobj;
		info["txt"] =WS2UTF(L"加入了群");
		info["icon"] = jobj["crowd_info"]["icon"];
		info["crowd_name"]=jobj["crowd_info"]["name"];
		info["category"]=jobj["crowd_info"]["category"];
		info["actor_name"]=jobj["member_info"]["showname"];
		info["actor_jid"]=jobj["member_info"]["jid"];
		std::map<std::string, crowd_info>::iterator it = crowd_list_.find(session_id);
		if (it!=crowd_list_.end())
		{
			info["crowd_remark"]=it->second.remark;
		}
		//写系统消息
		req_jobj["server_time"] = jobj["server_time"];
		req_jobj["is_read"] = false;
		req_jobj["info"] = info;
		req_jobj["msg_type"] = "crowd_apply_no_auth_accept_adimn";
		std::string rowid = get_parent_impl()->bizLocalConfig_->saveRequestMsg(session_id, req_jobj);
		//发送系统通知
		json::jobject system_message;
		system_message["session_id"] = session_id;
		system_message["rowid"] = rowid;
		system_message["msg_type"] = "crowd_apply_no_auth_accept_adimn";
		system_message["info"] = info;
		crowd_system_message(system_message);
	}

	void Crowd::invite_into_crowd( std::string session_id , std::string jid, Result_Callback callback)
	{
		IN_TASK_THREAD_WORKx(Crowd::invite_into_crowd, session_id, jid, callback );
		
		json::jobject actor;
		actor["name"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardName];
		actor["jid"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardJid];

		json::jobject crowd;
		std::map<std::string, crowd_info>::iterator it = crowd_list_.find(session_id);
		if (it != crowd_list_.end())
		{
			crowd["name"] = it->second.name;
			crowd["icon"] =epfilesystem::instance().file_name( it->second.icon);
			crowd["category"] = it->second.category;
			gWrapInterface::instance().invite_into_groups(session_id , actor , jid , crowd , callback);
		}
		else
		{
			// 本地找不到群，无法邀请
			callback(true, XL("biz.crwod.iq_error.invite_not-allowed"));
		}
	}
	void Crowd::build_crowd_icon( std::string session_id,json::jobject crowd_jobj )
	{
		if (!crowd_jobj["icon"].get<std::string>().empty())
		{
			std::string local_string = biz::file_manager::instance().from_uri_to_valid_path(crowd_jobj["icon"].get<std::string>());
			if (local_string.empty())
			{
				download_uri(crowd_jobj["icon"].get<std::string>(), bind2f(&Crowd::set_head , this , session_id, _1 , _2 , _3));
				crowd_jobj["icon"]="";
			}else{
				crowd_jobj["icon"] = local_string;
			}
		}
	}
	void Crowd::build_one_crowd_info( std::string session_id,json::jobject crowd_jobj )
	{
		crowd_info crowd;
		if (!crowd_jobj["icon"].get<std::string>().empty())
		{
			std::string local_string = biz::file_manager::instance().from_uri_to_valid_path(crowd_jobj["icon"].get<std::string>());
			if (local_string.empty())
			{
				download_uri(crowd_jobj["icon"].get<std::string>(), bind2f(&Crowd::set_head , this , session_id, _1 , _2 , _3));
				crowd_jobj["icon"]="";
				crowd.icon="";
			}else{
				crowd_jobj["icon"] = local_string;
				crowd.icon=local_string;
			}
		}
		else{
			crowd_jobj["icon"] = "";
			crowd.icon="";
		}
		if (!crowd_jobj.is_nil("alert"))
		{
			crowd.alert=crowd_jobj["alert"].get<std::string>();
		}else{
			crowd.alert = "0";
			crowd_jobj["alert"]="0";
		}
		if (!crowd_jobj.is_nil("quit"))
		{
			crowd.quit=crowd_jobj["quit"].get<std::string>();
		}else{
			crowd.quit = "true";
			crowd_jobj["quit"]="true";
		}
		if (!crowd_jobj.is_nil("role"))
		{
			crowd.role=crowd_jobj["role"].get<std::string>();
		}else{
			crowd.role = "none";
			crowd_jobj["role"]="none";
		}
		if (!crowd_jobj.is_nil("status"))
		{
			crowd.status=crowd_jobj["status"].get<std::string>();
		}else{
			crowd.status = "0";
			crowd_jobj["status"]="0";
		}
		if (!crowd_jobj.is_nil("official"))
		{
			crowd.official=crowd_jobj["official"].get<std::string>();
		}else{
			crowd.official = "false";
			crowd_jobj["official"]="false";
		}
		if (!crowd_jobj.is_nil("active"))
		{
			crowd.active=crowd_jobj["active"].get<std::string>();
		}else{
			crowd.active = "false";
			crowd_jobj["active"]="false";
		}
		if (!crowd_jobj.is_nil("category"))
		{
			crowd.category=crowd_jobj["category"].get<std::string>();
		}else{
			crowd.category = "17";
			crowd_jobj["category"]="17";
		}
		if (!crowd_jobj.is_nil("dismiss"))
		{
			crowd.dismiss=crowd_jobj["dismiss"].get<std::string>();
		}else{
			crowd.dismiss = "true";
			crowd_jobj["dismiss"]="true";
		}
		crowd.name = crowd_jobj["name"].get<std::string>();
		std::map<std::string, crowd_info>::iterator it = crowd_list_.find(session_id);
		if (it == crowd_list_.end())
		{
			crowd_list_.insert(make_pair(session_id, crowd));
		}
	}
	void Crowd::handler_recv_invited_into_crowd( json::jobject jobj )
	{
		build_one_member_info(jobj["actor"]);
		build_one_member_info(jobj["member_info"]);
		std::string session_id = jobj["session_id"].get<std::string>();
		build_crowd_icon( session_id , jobj["crowd_info"]);
		
		json::jobject info;
		info["icon"] = jobj["crowd_info"]["icon"].get<std::string>();
		info["crowd_name"] = jobj["crowd_info"]["name"].get<std::string>();
		info["category"] = jobj["crowd_info"]["category"].get<std::string>();
		info["txt"] = WS2UTF(L"邀请你加入群");
		info["actor_name"] = jobj["actor"]["showname"].get<std::string>();
		info["actor_jid"] = jobj["actor"]["jid"].get<std::string>();
		info["result"] = WS2UTF(L"未处理");

		//写系统消息
		json::jobject req_jobj;
		req_jobj["info"] = info;
		req_jobj["is_read"] = false;
		req_jobj["server_time"] = jobj["server_time"];
		req_jobj["session_id"] = session_id;
		req_jobj["msg_type"] = "crowd_invite";
		std::string rowid = get_parent_impl()->bizLocalConfig_->saveRequestMsg(session_id, req_jobj);

		
		req_jobj["rowid"] = rowid;
		crowd_system_message(req_jobj);
	}

	void Crowd::handler_recv_answer_crowd_invite( json::jobject jobj )
	{
		std::string session_id;
		session_id = jobj["session_id"].get<std::string>();
		std::map<std::string, crowd_info>::iterator it = crowd_list_.find(session_id);
		if (it!= crowd_list_.end())
		{
			build_one_member_info(jobj["member_info"]);
			build_one_member_info(jobj["actor"]);

			json::jobject req_jobj;
			req_jobj["is_read"] = false;
			req_jobj["session_id"] = session_id;

			json::jobject info;
			info["actor_jid"] = jobj["actor"]["jid"].get<std::string>();
			info["actor_name"] = jobj["actor"]["showname"].get<std::string>();
			info["actor_jid"] = jobj["actor"]["jid"].get<std::string>();
			
			info["jid"] = jobj["member_info"]["jid"].get<std::string>();
			info["name"] = jobj["member_info"]["showname"].get<std::string>();

			if (jobj["type"].get<std::string>() == "accept")
			{
				if (jobj["actor"]["jid"].get<std::string>()==get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardJid].get<std::string>())
				{
					info["txt"]  = WS2UTF(L"你邀请");
					req_jobj["msg_type"] = "answer_crowd_invite_accept_self";
					info["result"] = WS2UTF(L"已同意");
				}else{
					info["txt"] = WS2UTF(L"邀请");
					req_jobj["msg_type"] = "answer_crowd_invite_accept";
					info["result"] = WS2UTF(L"已加入");
				}
				
			}
			else
			{
				info["txt"]  = WS2UTF(L"你邀请");
				req_jobj["msg_type"] = "answer_crowd_invite_deny_self";
				info["result"] = WS2UTF(L"已拒绝");
				info["reason"] = jobj["reason"].get<std::string>();
			}
			
			info["crowd_name"] = it->second.name;
			info["crowd_remark"] = it->second.remark;
			info["icon"] = it->second.icon;
			info["category"] = it->second.category;
			req_jobj["info"] = info;
			req_jobj["server_time"] = jobj["server_time"];

			//写系统消息
			std::string rowid = get_parent_impl()->bizLocalConfig_->saveRequestMsg(session_id, req_jobj);

			req_jobj["rowid"] = rowid;
			crowd_system_message(req_jobj);
		}
	}

	void Crowd::answer_crowd_invite(json::jobject jobj, Result_Callback callback )
	{
		IN_TASK_THREAD_WORKx(Crowd::answer_crowd_invite, jobj, callback );

		std::string rowid = jobj["rowid"].get<std::string>();
		std::string session_id  = jobj["session_id"].get<std::string>();
		std::string crowd_name = jobj["crowd_name"].get<std::string>();
		std::string icon = jobj["icon"].get<std::string>();
		std::string category = jobj["category"].get<std::string>();
		std::string jid  = jobj["jid"].get<std::string>();
		std::string name  = jobj["name"].get<std::string>();
		std::string reason  = jobj["reason"].get<std::string>();
		std::string accept  = jobj["accept"].get<std::string>();
		bool never_accept  = jobj["never_accept"].get<bool>();

		json::jobject item;
		item["name"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardName];
		item["jid"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardJid];
		item["icon"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardHeadURI];
		item["sex"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardSex];
		item["identity"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardIdentity];

		json::jobject actor;
		actor["jid"] = jid;
		actor["name"] = name;

		// 取uri
		icon = epius::epfilesystem::instance().file_name(icon);

		gWrapInterface::instance().answer_groups_invite(session_id, crowd_name, icon, category, accept, actor, item, reason, never_accept, boost::bind(&Crowd::answer_crowd_invite_cb, this, jobj, callback, _1, _2));
	}

	void Crowd::answer_crowd_invite_cb( json::jobject jobj, Result_Callback callback, bool err, universal_resource reason_err )
	{
		if (!err)
		{
			//覆盖系统消息
			std::string rowid = jobj["rowid"].get<std::string>();
			std::string session_id  = jobj["session_id"].get<std::string>();
			std::string crowd_name = jobj["crowd_name"].get<std::string>();
			std::string icon = jobj["icon"].get<std::string>();
			std::string category = jobj["category"].get<std::string>();
			std::string jid  = jobj["jid"].get<std::string>();
			std::string name  = jobj["name"].get<std::string>();
			std::string reason  = jobj["reason"].get<std::string>();
			std::string accept  = jobj["accept"].get<std::string>();
			bool never_accept  = jobj["never_accept"].get<bool>();

			if(accept == "yes")
			{
				//写系统消息
				json::jobject info;
				json::jobject req_jobj;
				info["actor_name"] = name;
				info["actor_jid"] = jid;
				info["txt"] = WS2UTF(L"邀请你加入群");
				info["result"] = WS2UTF(L"已加入");
				info["crowd_name"] = crowd_name;
				info["icon"] = icon;
				info["category"] = category;

				req_jobj["server_time"] = "";
				req_jobj["is_read"] = false;
				req_jobj["info"] = info;
				req_jobj["msg_type"] = "crowd_invite_accept";
				req_jobj["session_id"] = session_id;
				get_parent_impl()->bizLocalConfig_->replaceRequestMsg(session_id, req_jobj, rowid);

				if (reason_err.res_key.empty())
				{
					req_jobj["rowid"] = rowid;
					crowd_system_message(req_jobj);
				}
				
			}
			else
			{
				//写系统消息
				json::jobject info;
				json::jobject req_jobj;
				info["actor_name"] = name;
				info["actor_jid"] = jid;
				info["txt"] = WS2UTF(L"邀请你加入群");
				info["result"] = WS2UTF(L"已拒绝");
				info["crowd_name"] = crowd_name;
				info["icon"] = icon;
				info["category"] = category;
				info["reason"] = reason;

				req_jobj["server_time"] = "";
				req_jobj["is_read"] = false;
				req_jobj["info"] = info;
				req_jobj["msg_type"] = "crowd_invite_deny";
				req_jobj["session_id"] = session_id;
				get_parent_impl()->bizLocalConfig_->replaceRequestMsg(session_id, req_jobj, rowid);

				if (reason_err.res_key.empty())
				{
					req_jobj["rowid"] = rowid;
					crowd_system_message(req_jobj);
				}
			}

		}

		callback(err, reason_err);
	}
	void Crowd::send_save_sys_msg( json::jobject jobj , std::string txt )
	{
		std::string session_id=jobj["session_id"].get<std::string>();
		std::map<std::string, crowd_info>::iterator it = crowd_list_.find(session_id);
		json::jobject req_jobj,info;
		info["txt"] = txt;
		info["icon"] = it->second.icon;
		info["crowd_name"]=it->second.name;
		info["crowd_remark"]=it->second.remark;
		info["category"]=it->second.category;
		//写系统消息

		req_jobj["server_time"] = jobj["server_time"];
		req_jobj["is_read"] = false;
		req_jobj["info"] = info;
		req_jobj["msg_type"] = "crowd_web_groups_member_list";
		std::string rowid = get_parent_impl()->bizLocalConfig_->saveRequestMsg(session_id, req_jobj);

		//发送系统通知
		json::jobject system_message;
		system_message["session_id"] = session_id;
		system_message["rowid"] = rowid;
		system_message["msg_type"] = "crowd_web_groups_member_list";
		system_message["info"] = info;
		crowd_system_message(system_message);
	}
	void Crowd::handler_recv_groups_member_web_change_self( json::jobject jobj )
	{
		std::string session_id=jobj["session_id"].get<std::string>();
		std::map<std::string, crowd_info>::iterator it = crowd_list_.find(session_id);
		json::jobject req_jobj;
		if (jobj["type"].get<std::string>()=="delete")
		{
			if (it!= crowd_list_.end())
			{
				json::jobject info;
				info["txt"] = WS2UTF(L"你被管理系统请出群");
				info["icon"] = it->second.icon;
				info["crowd_name"]=it->second.name;
				info["crowd_remark"]=it->second.remark;
				info["category"]=it->second.category;
				//写系统消息

				req_jobj["server_time"] = jobj["server_time"];
				req_jobj["is_read"] = false;
				req_jobj["info"] = info;
				req_jobj["msg_type"] = "crowd_web_groups_member_list";
				std::string rowid = get_parent_impl()->bizLocalConfig_->saveRequestMsg(session_id, req_jobj);
				crowd_list_.erase(it);

				//发送系统通知
				json::jobject system_message;
				system_message["session_id"] = session_id;
				system_message["rowid"] = rowid;
				system_message["msg_type"] = "crowd_web_groups_member_list";
				system_message["info"] = info;
				crowd_system_message(system_message);

				//发送群列表变更通知
				json::jobject crowd_jobj;
				crowd_jobj["type"]="remove";
				jobj["crowd_info"]["session_id"]=session_id;
				crowd_jobj["crowd_info"]=jobj["crowd_info"];
				crowd_list_changed(crowd_jobj);

			}
		}
		else if (jobj["type"].get<std::string>()=="update")
		{
			if (it!= crowd_list_.end())
			{
				std::string new_role=jobj["member_info"]["role"].get<std::string>();
				json::jobject info;
				if (new_role=="none"&&it->second.role=="admin")
				{
					it->second.role=new_role;
					send_save_sys_msg(jobj,WS2UTF(L"你已被管理系统取消群管理员"));
				}
				else if (new_role=="none"&&it->second.role=="super")
				{
					it->second.role=new_role;
					send_save_sys_msg(jobj,WS2UTF(L"你已被管理系统取消群超级管理员"));
				}
				else if (new_role=="super"&&it->second.role=="none")
				{
					it->second.role=new_role;
					send_save_sys_msg(jobj,WS2UTF(L"你已被管理系统授予群超级管理员"));
				}
				else if (new_role=="admin"&&it->second.role=="none")
				{
					it->second.role=new_role;
					send_save_sys_msg(jobj,WS2UTF(L"你已被管理系统授予群管理员"));
				}
				else if (new_role=="super"&&it->second.role=="admin")
				{
					it->second.role=new_role;
					send_save_sys_msg(jobj,WS2UTF(L"你已被管理系统取消群管理员"));
					send_save_sys_msg(jobj,WS2UTF(L"你已被管理系统授予群超级管理员"));
				}
				else if (new_role=="admin"&&it->second.role=="super")
				{
					it->second.role=new_role;
					send_save_sys_msg(jobj,WS2UTF(L"你已被管理系统取消群超级管理员"));
					send_save_sys_msg(jobj,WS2UTF(L"你已被管理系统授予群管理员"));
				}
			}
		}
		else
		{
			json::jobject info;
			build_crowd_icon(session_id,jobj["crowd_info"]);
			info["txt"] = WS2UTF(L"你已被管理系统添加至群");
			get_crowd_info(session_id,bind2f(&Crowd::system_message_common_cb, this, session_id,info,"crowd_web_groups_member_list" ,"add", _1, _2,_3));
		}
	}

	void Crowd::get_create_crowd_setting( Result_Data_Callback callback )
	{
		IN_TASK_THREAD_WORKx(Crowd::get_create_crowd_setting, callback );

		gWrapInterface::instance().get_create_groups_setting(callback);
	}

	void Crowd::handler_recv_groups_member_kickout_admin_other( json::jobject jobj )
	{
		std::string session_id=jobj["session_id"].get<std::string>();
		std::map<std::string, crowd_info>::iterator it = crowd_list_.find(session_id);
		if (it!=crowd_list_.end())
		{
			json::jobject info,req_jobj;
			info["txt"] = WS2UTF(L"被管理员");
			info["icon"] =it->second.icon;
			info["crowd_name"] = it->second.name;
			info["category"] = it->second.category;
			info["crowd_remark"] = it->second.remark;
			info["result"] = WS2UTF(L"请出群");
			info["actor_name"] = jobj["actor"]["showname"];
			info["actor_jid"] = jobj["actor"]["jid"];
			info["name"] = jobj["member_info"]["showname"];
			info["jid"] = jobj["member_info"]["jid"];
			//写系统消息

			req_jobj["server_time"] = jobj["server_time"];
			req_jobj["is_read"] = false;
			req_jobj["info"] = info;
			req_jobj["msg_type"] = "crowd_kickout_admin_other";
			std::string rowid = get_parent_impl()->bizLocalConfig_->saveRequestMsg(session_id, req_jobj);

			//发送系统通知
			json::jobject system_message;
			system_message["session_id"] = session_id;
			system_message["rowid"] = rowid;
			system_message["msg_type"] = "crowd_kickout_admin_other";
			system_message["info"] = info;
			crowd_system_message(system_message);
		}
		
	}

	void Crowd::handler_recv_groups_member_kickout_admin_self( json::jobject jobj )
	{
		std::string session_id=jobj["session_id"].get<std::string>();
		std::map<std::string, crowd_info>::iterator it = crowd_list_.find(session_id);
		if (it!=crowd_list_.end())
		{
			json::jobject info,req_jobj;
			info["txt"] = WS2UTF(L"被你请出群");
			info["icon"] =it->second.icon;
			info["crowd_name"] = it->second.name;
			info["category"] = it->second.category;
			info["crowd_remark"] = it->second.remark;
			info["name"] = jobj["member_info"]["showname"];
			info["jid"] = jobj["member_info"]["jid"];
			//写系统消息

			req_jobj["server_time"] = jobj["server_time"];
			req_jobj["is_read"] = false;
			req_jobj["info"] = info;
			req_jobj["msg_type"] = "crowd_kickout_admin_self";
			std::string rowid = get_parent_impl()->bizLocalConfig_->saveRequestMsg(session_id, req_jobj);

			//发送系统通知
			json::jobject system_message;
			system_message["session_id"] = session_id;
			system_message["rowid"] = rowid;
			system_message["msg_type"] = "crowd_kickout_admin_self";
			system_message["info"] = info;
			crowd_system_message(system_message);
		}
		
	}

	void Crowd::handler_recv_groups_member_apply_accept( json::jobject jobj )
	{
		std::string session_id=jobj["session_id"].get<std::string>();
		std::map<std::string, crowd_info>::iterator it = crowd_list_.find(session_id);
		if (it!=crowd_list_.end())
		{
			build_member_info(jobj["actor"]);
			build_member_info(jobj["member_info"]);
			json::jobject info,req_jobj;
			info["txt"] = WS2UTF(L"申请加入群");
			info["icon"] =it->second.icon;
			info["crowd_name"] = it->second.name;
			info["category"] = it->second.category;
			info["result"] = WS2UTF(L"已同意");
			info["actor_name"] = jobj["actor"]["showname"];
			info["actor_jid"] = jobj["actor"]["jid"];
			info["name"] = jobj["member_info"]["showname"];
			info["jid"] = jobj["member_info"]["jid"];
			info["reason"] = jobj["reason"];
			//写系统消息

			req_jobj["server_time"] = jobj["server_time"];
			req_jobj["is_read"] = false;
			req_jobj["info"] = info;
			req_jobj["msg_type"] = "crowd_apply_accept_admin_other";
			std::string rowid = get_parent_impl()->bizLocalConfig_->saveRequestMsg(session_id, req_jobj);

			//发送系统通知
			json::jobject system_message;
			system_message["session_id"] = session_id;
			system_message["rowid"] = rowid;
			system_message["msg_type"] = "crowd_apply_accept_admin_other";
			system_message["info"] = info;
			crowd_system_message(system_message);
		}
	}

	void Crowd::set_crowd_member_info( std::string session_id , json::jobject jobj , Result_Callback callback )
	{
		IN_TASK_THREAD_WORKx(Crowd::set_crowd_member_info, session_id , jobj , callback );
		json::jobject actor;
		actor["name"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardName];
		actor["jid"] = get_parent_impl()->bizRoster_->getSelfVcardInfo()[s_VcardJid];
		gWrapInterface::instance().set_groups_member_info(session_id,jobj,actor,bind2f(&Crowd::set_crowd_member_info_cb,this,session_id, jobj,callback,_1,_2));

	}

	void Crowd::set_crowd_member_info_cb( std::string session_id, json::jobject jobj , Result_Callback callback, bool err, universal_resource reason )
	{
		json::jobject info;
		if (!err)
		{
			std::map<std::string, crowd_info>::iterator it = crowd_list_.find(session_id);
			if (it!=crowd_list_.end())
			{
				if (!jobj.is_nil("remark"))
				{
					info["remark"]=jobj["remark"];
					info["name"]=it->second.name;
					info["session_id"]=session_id;
					crowd_info_changed(info);
					it->second.remark=jobj["remark"].get<std::string>();
				}
			}
		}
		callback(err,reason);
	}

	std::string Crowd::get_alert_by_session_id( std::string session_id )
	{
		std::map<std::string, crowd_info>::iterator it = crowd_list_.find(session_id);
		if (it!=crowd_list_.end())
		{
			return it->second.alert;
		}
		else{
			return "1";
		}
	}

	void Crowd::system_message_common_cb( std::string session_id , json::jobject info , std::string msg_type , std::string type , bool err, universal_resource reason, json::jobject data )
	{
		if (!err)
		{
			std::map<std::string, crowd_info>::iterator it = crowd_list_.find(session_id);
			crowd_info dinfo;		
			if (it==crowd_list_.end())
			{
				dinfo.name = data["name"].get<std::string>();
				std::string uri_string = data["icon"].get<std::string>();

				dinfo.icon = "";
				data["icon"] = "";

				if(!uri_string.empty())
				{
					std::string local_string = biz::file_manager::instance().from_uri_to_valid_path(uri_string);
					if (local_string.empty())
					{
						download_uri(uri_string,bind2f(&Crowd::set_head , this , data["session_id"].get<std::string>(), _1 , _2 , _3));
					}else{
						dinfo.icon = local_string;
						data["icon"]= local_string;
					}
				}
				dinfo.alert = data["alert"].get<std::string>();
				dinfo.role = data["role"].get<std::string>();
				dinfo.quit = data["quit"].get<std::string>();
				dinfo.status = data["status"].get<std::string>();
				dinfo.official = data["official"].get<std::string>();
				dinfo.active = data["active"].get<std::string>();
				dinfo.category = data["category"].get<std::string>();
				dinfo.dismiss = data["dismiss"].get<std::string>();
				dinfo.remark = data["remark"].get<std::string>();
				crowd_list_.insert(make_pair(session_id, dinfo));
			}
			else
			{
				dinfo=it->second;
			}
			json::jobject crowd_jobj;
			if (type=="remove")
			{
				//发送群列表变更通知

				std::map<std::string, crowd_info>::iterator it = crowd_list_.find(session_id);
				if (it!=crowd_list_.end())
					crowd_list_.erase(it);

				crowd_jobj["type"]=type;
				crowd_jobj["crowd_info"]["session_id"]=session_id;
				crowd_list_changed(crowd_jobj);
			}
			else if(type=="add")
			{
				crowd_jobj["type"]=type;
				crowd_jobj["crowd_info"]["session_id"]=session_id;
				crowd_list_changed(crowd_jobj);
			}
			if (!msg_type.empty())
			{
				info["icon"] = dinfo.icon;
				info["crowd_name"] = dinfo.name;
				info["category"] = dinfo.category;
				json::jobject req_jobj;
				req_jobj["server_time"] = info["server_time"];
				req_jobj["is_read"] = false;
				req_jobj["info"] = info;
				req_jobj["msg_type"] = msg_type;
				std::string rowid = get_parent_impl()->bizLocalConfig_->saveRequestMsg(session_id, req_jobj);

				//发送系统通知
				json::jobject system_message;
				system_message["session_id"] = session_id;
				system_message["rowid"] = rowid;
				system_message["msg_type"] = msg_type;
				system_message["info"] = info;
				crowd_system_message(system_message);
			}
		}
	}

	void Crowd::crowd_list_changed( json::jobject jobj )
	{
		if(jobj["type"].get<std::string>()=="add")
			get_parent_impl()->bizUser_->set_Presence(get_parent_impl()->bizUser_->syncquery_MyPresence());
		crowd_list_changed_signal(jobj);
	}


}
