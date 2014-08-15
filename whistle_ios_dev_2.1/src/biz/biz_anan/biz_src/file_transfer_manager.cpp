#include <fstream>
#include <iostream>
#include <base/utility/bind2f/bind2f.hpp>
#include <base/module_path/epfilesystem.h>
#include <base/utility/file_digest/file2uri.hpp>
#include <base/http_trans/http_request.h>
#include "base/log/elog/elog.h"
#include "file_transfer_manager.h"
#include "anan_config.h"
#include "gloox_wrap/glooxWrapInterface.h"
#include "statistics_data.h"
#include "local_config.h"
#include "an_roster_manager.h"
#include "an_roster_manager_impl.h"
#include "whistle_vcard.h"
#include "conversation.h"

using namespace epius;
using namespace epius::proactor;
namespace biz
{
	void file_transfer_manager::set_biz_bind_impl( anan_biz_impl* impl )
	{
		anan_biz_impl_ = impl;
	}

	void file_transfer_manager::init()
	{
	}

	void file_transfer_manager::send_file_to( std::string filename, std::string uid, std::string jid, boost::function<void(bool,universal_resource,std::string)> callback, bool resumable )
	{
		IN_TASK_THREAD_WORKx( file_transfer_manager::send_file_to, filename, uid, jid, callback, resumable);
		if(!epfilesystem::instance().file_exists(filename))
			callback(true, XL("upload_file_not_exists"), "");
		cancle_trans_file_map_.insert(make_pair(uid,false));

		epius::async_get_uri(filename,boost::bind(&file_transfer_manager::do_send_file_to, this, filename, _1, uid, jid, callback, resumable));
	}

	void file_transfer_manager::do_send_file_to( std::string filename, std::string uri, std::string uid, std::string jid, boost::function<void(bool,universal_resource,std::string)> callback, bool resumable )
	{
		IN_TASK_THREAD_WORKx( file_transfer_manager::do_send_file_to, filename, uri, uid, jid, callback, resumable);
		std::map<std::string, std::string> header;
		header.insert(std::make_pair("Content-Length", "0"));
		header.insert(std::make_pair("Method", "check"));
		header.insert(std::make_pair("Filename", uri));
		std::map<std::string,bool>::iterator it;
		it = cancle_trans_file_map_.find(uid);
		if (it != cancle_trans_file_map_.end() && it->second)
		{
			//取消上传文件
			callback(true,XL("user_cancel_file_transfer"), "");
			cancle_trans_file_map_.erase(it);
			return;
		}
		epius::http_requests::instance().post(anan_config::instance().get_file_upload_path(), header, bind2f(&file_transfer_manager::check_file_on_server_cb, this,	filename, uri, uid, jid, resumable, callback, _1, _2 ));
	}

	void file_transfer_manager::send_file_msg_cb( boost::function<void(bool,universal_resource,std::string)> callback, std::string result, bool check_succ, std::string uid, boost::uintmax_t filesize, json::jobject jobj_msg, bool err, universal_resource reason )
	{
		if (err)
		{
			ELOG("app")->error("file_transfer_manager::send_file_msg_cb: send transfer file message failed.");
			callback(true, reason, "");
		}
		else
		{
			if (check_succ)
			{
				json::jobject jobj;
				jobj["status"] = "ok";
				jobj["uid"] = uid;
				jobj["filesize"] = boost::str(boost::format("%ld")%filesize);
				epius::http_requests::instance().file_transfer_status(jobj);
				epius::time_thread tmp_thread;
				tmp_thread.timed_wait(1000);
			}
			callback(false, XL(""), result);
		}
	}

	void file_transfer_manager::upload_file_cb( boost::function<void(bool,universal_resource,std::string)> callback, std::string jid, std::string filename,	time_t starttime, bool succ, std::string result )
	{
		if (succ)
		{
			json::jobject upload_obj(result);
			if(upload_obj)
			{
				result = upload_obj["uri"].get<std::string>();
			}
			else
			{
				callback(true, XL(result), "");
				return;
			}

			boost::uintmax_t filesize =  epius::epfilesystem::instance().file_size(filename);
			// 发送文件大小(按K字节计算)
			g_statistics_data::instance().add_data("send_file_size", (int)(filesize/1024));
			// 发送文件大小(实际上传大小 按K字节计算)
			g_statistics_data::instance().add_data("send_file_actual_size", (int)(filesize/1024));
			// 发送文件实际上传时间(按秒计算)
			time_t endtime;
			time(&endtime);
			g_statistics_data::instance().add_data("send_file_actual_time", (int)(endtime - starttime));
			// 去掉文件路径 发送文件名
			filename = epius::epfilesystem::instance().file_name(filename);
			// send file transfer iq to server
			json::jobject jobj;
			jobj["args"]["target"] = jid;
			jobj["args"]["msg"]["msg_extension"] = "send_file";
			jobj["args"]["msg"]["msg"]["uri"] = result;
			jobj["args"]["msg"]["msg"]["file_name"] = filename;
			jobj["args"]["msg"]["msg"]["file_length"] = (int)filesize;
			get_parent_impl()->bizConversation_->send_message(jobj,boost::bind(&file_transfer_manager::send_file_msg_cb, this, callback, result, false, "", 0, _1, _2, _3));

		}
		else
		{
			callback(true, XL(result), "");
		}
	}

	void file_transfer_manager::download_file(std::string filename, boost::uintmax_t filesize, std::string relative_path, std::string uri, std::string uid, boost::function<void(bool,universal_resource,std::string)> callback)
	{
		IN_TASK_THREAD_WORKx( file_transfer_manager::download_file, filename, filesize,relative_path, uri, uid, callback);

		//创建文件夹
		epfilesystem::instance().create_directories(epius::epfilesystem::instance().branch_path(filename));
		//下载开始时间
		time_t starttime;
		time(&starttime);
		boost::function<void(bool,std::string)> download_callback = boost::bind(&file_transfer_manager::download_file_cb, this, callback, starttime, filename, _1, _2);		
		epius::http_requests::instance().resume_download(relative_path, filename, uri, uid, get_common_progress_callback("download", uid , uri, ""), download_callback);
	}

	void file_transfer_manager::download_file_cb( boost::function<void(bool,universal_resource,std::string)> callback, time_t starttime, std::string filename, bool succ, std::string result )
	{
		IN_TASK_THREAD_WORKx( file_transfer_manager::download_file_cb, callback, starttime, filename, succ, result);

		if (succ)
		{
			// 接收文件实际下载时间(按秒计算)
			time_t endtime;
			time(&endtime);
			g_statistics_data::instance().add_data("recv_file_actual_time", (int)(endtime - starttime));

			callback(false, XL(""), result);
		}
		else
		{
			epfilesystem::instance().remove_file(filename);

			callback(true, XL(result), "");
		}
	}
	
	// 	POST /image/upload HTTP/1.1
	// 	Content-Length: 0
	// 	Method: check
	// 	Digest: 5dac0b7427284b73f242508b.zip
	//  -----------------------------------------
	// 	HTTP/1.1 200 OK
	// 	Content- Length: 123
	// 	{
	// 		error: 
	// 		     0: 文件不存在, 需要上传文件
	// 		     1: 文件存在, 不需要上传, 并且在URI中带有文件的下载路径的相对URI 
	// 		    -1: 文件名错误(比如太短)
	// 		    -2: 服务器保存文件失败
	// 		uri:"5dac0b7427284b73f242508b.zip”
	// 	}
	void file_transfer_manager::check_file_on_server_cb( std::string filename, std::string uri, std::string uid, std::string jid, bool resumable, boost::function<void(bool,universal_resource,std::string)> callback, bool succ, std::string response )
	{
		
		/*	
		enum status_type
		{
		ok = 200,
		created = 201,
		accepted = 202,
		no_content = 204,
		multiple_choices = 300,
		moved_permanently = 301,
		moved_temporarily = 302,
		not_modified = 304,
		bad_request = 400,
		unauthorized = 401,
		forbidden = 403,
		not_found = 404,
		not_supported = 405,
		not_acceptable = 406,
		internal_server_error = 500,
		not_implemented = 501,
		bad_gateway = 502,
		service_unavailable = 503
		} status;
		*/
		if (succ)
		{
			//取消上传文件
			std::map<std::string,bool>::iterator it;
			it = cancle_trans_file_map_.find(uid);
			if (it != cancle_trans_file_map_.end())
			{						
				if(it->second)
				{
					callback(true, XL("user_cancel_file_transfer"), "");
					cancle_trans_file_map_.erase(it);
					return;
				}
				cancle_trans_file_map_.erase(it);
			}

			json::jobject result_jobj(response);
			if (result_jobj)
			{
				if (result_jobj["error"].get<int>() == 1)
				{
					boost::uintmax_t filesize =  epius::epfilesystem::instance().file_size(filename);
					// 发送文件大小(按K字节计算)
					g_statistics_data::instance().add_data("send_file_size", (int)(filesize/1024));
					// 去掉文件路径 发送文件名
					filename = epius::epfilesystem::instance().file_name(filename);					
					// send file transfer iq to server
					json::jobject jobj;
					jobj["args"]["target"] = jid;
					jobj["args"]["msg"]["msg_extension"]="send_file";
					jobj["args"]["msg"]["msg"]["uri"]=uri;
					jobj["args"]["msg"]["msg"]["file_name"]=filename;
					jobj["args"]["msg"]["msg"]["file_length"]=(int)filesize;
					get_parent_impl()->bizConversation_->send_message(jobj,boost::bind(&file_transfer_manager::send_file_msg_cb, this, callback, uri, true, uid, filesize, _1, _2, _3));
					return;
				}
				else
				{
					//上传开始时间
					

					time_t starttime;
					time(&starttime);
					boost::function<void(bool /*succ*/, std::string)> upload_callback = boost::bind(&file_transfer_manager::upload_file_cb, this, callback, jid, filename, starttime, _1, _2);
					if (resumable)
					{
						std::string size_s = get_parent_impl()->bizLocalConfig_->loadData("upload_" + uri + jid);
						epius::http_requests::instance().resume_upload_file(anan_config::instance().get_file_upload_path(), filename, size_s , uri+"."+jid.substr(0,jid.find_first_of('@')), uid, get_common_progress_callback("upload", uid , uri, jid), upload_callback);
					}
					else
						epius::http_requests::instance().upload(anan_config::instance().get_file_upload_path(), filename, uri, uid, get_common_progress_callback("upload", uid , uri, jid), upload_callback);

				}
			}
		}
		else
		{
			callback(true, XL("check_file_on_server_broken"), "");
		}
	}

	void file_transfer_manager::cancel_transfer_file( std::string uid )
	{
		IN_TASK_THREAD_WORKx( file_transfer_manager::cancel_transfer_file, uid);
		
		std::map<std::string,bool>::iterator it;
		it = cancle_trans_file_map_.find(uid);
		if (it != cancle_trans_file_map_.end())
		{
			it->second = true;
		}
		epius::http_requests::instance().cancel(uid);
	}

	boost::function<void(int)> file_transfer_manager::get_common_progress_callback(std::string uid , std::string uri)
	{
		time_t start=0;
		time_t pretime = 0;
		int old_size = 0;
		time(&start);
		boost::function<void(int)> progress_call = [=](int curr_size) mutable {
			time_t tmp_time;
			time(&tmp_time);
			if(tmp_time - pretime <= 1 || curr_size - old_size == 0) return;
			old_size = curr_size;
			pretime = tmp_time;
			json::jobject jobj;
			jobj["uid"] = uid;
			jobj["uri"] = uri;
			jobj["transfer_size"] = curr_size;
			jobj["elapse_time"] = (int)(tmp_time - start);
			http_requests::instance().file_transfer_status(jobj);
		};
		return progress_call;
	}
	boost::function<void(int)> file_transfer_manager::get_common_progress_callback(std::string trans_type, std::string uid , std::string uri, std::string jid)
	{
		time_t start=0;
		time_t pretime = 0;
		int old_size = 0;
		time(&start);

		boost::function<void(int)> progress_call = [=](int curr_size) mutable {
			time_t tmp_time;
			time(&tmp_time);
			if(tmp_time - pretime <= 1 || curr_size - old_size == 0) return;
			old_size = curr_size;
			pretime = tmp_time;
			json::jobject jobj;
			jobj["uid"] = uid;
			jobj["uri"] = uri;
			jobj["jid"] = jid;
			jobj["trans_type"] = trans_type;
			jobj["transfer_size"] = curr_size;
			jobj["elapse_time"] = (int)(tmp_time - start);
			http_requests::instance().file_transfer_status(jobj);
		};
		return progress_call;
	}
	bool file_transfer_manager::is_file_trans_canceled( std::string uid )
	{
		std::map<std::string,bool>::iterator it;
		it = cancle_trans_file_map_.find(uid);
		if (it != cancle_trans_file_map_.end() && it->second)
		{
			//取消上传文件
			cancle_trans_file_map_.erase(it);
			return true;
		}
		return false;
	}

	void file_transfer_manager::insert_cancle_trans_file_map( std::string uid )
	{
		std::map<std::string,bool>::iterator it;
		it = cancle_trans_file_map_.find(uid);
		if (it == cancle_trans_file_map_.end() )
		{
			cancle_trans_file_map_.insert(make_pair(uid,false));
		}
	}

	void file_transfer_manager::cancel_all_transfer_file()
	{
		std::map<std::string,bool>::iterator it=cancle_trans_file_map_.begin();
		for (;it!=cancle_trans_file_map_.end();it++)
		{
			cancel_transfer_file(it->first);
		}
		epius::http_requests::instance().cancel_all("user_cancel_file_transfer");
	}

}

