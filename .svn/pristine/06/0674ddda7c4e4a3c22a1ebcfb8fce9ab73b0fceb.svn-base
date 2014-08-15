#include <string>
#include <boost/format.hpp>
#include <boost/shared_ptr.hpp>
#include <third_party/libcurl/include/curl/curl.h>
#include <base/thread/time_thread/time_thread.h>
#include <base/txtutil/txtutil.h>
#include <base/log/elog/elog.h>
#include <base/module_path/epfilesystem.h>
#include <base/utility/uuid/uuid.hpp>
#include <base/http_trans/http_request.h>
#include <base/utility/bind2f/bind2f.hpp>
#include <iostream>
#define  MAX_HANDLES	20
#define  SEGMENT_SIZE   5242880 //1024*1024*5
namespace epius{
static size_t request_result_callback(void *ptr, size_t size, size_t nmemb, void *userp);
static int progress_callback(void *clientp, double dltotal, double dlnow, double ultotal, double ulnow);

static size_t read_write_data_callback(void *ptr, size_t size, size_t nmemb, void *stream) {
	int len = size * nmemb;
	boost::function<size_t(char* buffer, int len)>* data_process = (boost::function<size_t(char* buffer, int len)>*)stream;
	return (*data_process)(reinterpret_cast<char *>(ptr), len);
}

struct http_request_impl {

	enum http_request_type {
		http_none,
		http_upload,
		http_resume_upload,
		http_download,
		http_resume_download,
		http_post,
		http_get
	};

	struct result_tag{
		result_tag()
		{
			type = http_none;
			cancel = false;
			headerlist = NULL;
			post = NULL;
			callback.reset(new boost::signal<void(bool, std::string)>);
			post_work.reset(new boost::signal<void()>);
		}
		std::string describe_error()
		{
			if(type == http_upload)
			{
				return boost::str(boost::format("upload %s to %s failed")%filename%url);
			}
			else if(type == http_download)
			{
				return boost::str(boost::format("download %s to %s failed")%uri%real_filename);
			}
			else
			{
				return boost::str(boost::format("http action %d no %s failed")%filename%url);
			}
		}
		void progress(int curr_progress){if(progress_sig) (*progress_sig)(curr_progress);}
		boost::shared_ptr<boost::signal<void(bool, std::string)> > callback;
		boost::shared_ptr<boost::signal<void()> > post_work;
		boost::shared_ptr<boost::signal<void(int)> > progress_sig;
		std::string result_string;
		std::string filename;
		std::string uid;
		std::string uri;
		std::string url;
		std::string cancel_callback_str;
		http_request_type type;
		bool cancel;
		boost::function<size_t(char* buffer, int len)> data_process;
		std::string real_filename;
		curl_slist *headerlist;
		curl_httppost *post;
	};
	struct parm{
		std::string url;
		std::string uri;
		std::string filename;
		std::string uid;
		int numb;
	};//参数列表
	http_request_impl()
	{
		isStop_ = false;
		allow_more_check_ = true;
		segment_size_ = 0;
	}

	virtual ~http_request_impl()
	{
		curl_multi_cleanup(multi_handle_);
		curl_global_cleanup();
	}

	bool init()
	{
		// 初始化
#ifdef _WIN32
		curl_global_init(CURL_GLOBAL_WIN32);
#else
		curl_global_init(CURL_GLOBAL_NOTHING);
#endif
		multi_handle_ = curl_multi_init();

		http_thread_.reset(new time_thread);

		if (multi_handle_){
			return true;
		}
		return false;
	}
	void do_stop()
	{
		isStop_ = true;
	}

	void cleanup_curl(std::map<CURL*, result_tag>::iterator it)
	{
		if (it == handles_.end())
		{
			return;
		}

		// clean the memory
		if (it->second.headerlist)
		{
			curl_slist_free_all(it->second.headerlist);
		}
		if (it->second.post)
		{
			curl_formfree(it->second.post);
		}
		curl_multi_remove_handle(multi_handle_, it->first);

		curl_easy_cleanup(it->first);

		handles_.erase(it);
	}

	void check_process()
	{
		int nmsgs = 0;
		CURLMsg * msg = NULL;
		do{
			msg = curl_multi_info_read( multi_handle_, &nmsgs);
			if (!msg)
			{
				// get nothing
				return;
			}

			std::map<CURL*, result_tag>::iterator it = handles_.find(msg->easy_handle);
			if(it == handles_.end())
			{
				char* url = new char[1000];
				curl_easy_getinfo(msg->easy_handle, CURLINFO_EFFECTIVE_URL, url);
				if (url)
				{
					ELOG("http")->error("curl: cannot find the handle in the vector. url:" + std::string(url));
					delete []url;
				}
				return;
			}

			int retcode =0 ;
			if (msg->msg == CURLMSG_DONE)
			{
				bool bSuccess = false;

				std::string callback_str;
				switch(msg->data.result)
				{
					case CURLE_OK: //成功
						curl_easy_getinfo(it->first, CURLINFO_RESPONSE_CODE, &retcode);
						ELOG("http")->debug("curl: done url " + it->second.url + " retcode:" + boost::lexical_cast<std::string>(retcode));
						if(retcode==200)
						{
							bSuccess = true;
							if(it->second.type == http_download)
							{
								callback_str = it->second.uri;
							}
							else if(it->second.type == http_upload || it->second.type == http_post || it->second.type == http_get)
							{
								callback_str = it->second.result_string;
							}
							else if (it->second.type == http_resume_upload )
							{
								bSuccess = true;
								callback_str = it->second.result_string;
							}
						}
						else if (retcode==201&&it->second.type == http_resume_upload)//服务器返回201，继续传输
						{
							bSuccess = true;
							callback_str = boost::lexical_cast<std::string>(retcode);
						}
						else if(it->second.type == http_resume_download || retcode == 206)//服务器返回206，获取部分文件成功
						{
							bSuccess = true;
							callback_str = it->second.uri;
						}
						else
						{
							bSuccess = false;
						}
						break;
					case CURLE_WRITE_ERROR:
						callback_str = "http_request_diskfull";
						ELOG("http")->debug("curl: disk full " + it->second.url);
						break;
					case CURLE_ABORTED_BY_CALLBACK: // 用户cancel
						callback_str = it->second.cancel_callback_str;
						ELOG("http")->debug("curl: cancel url " + it->second.url);
						break;
					case CURLE_OPERATION_TIMEDOUT: //  超时
						callback_str = "http_request_timeout";
						if(it->second.type == http_resume_download)
						ELOG("http")->debug("curl: timeout url " + it->second.url);
						break;
					case CURLE_REMOTE_FILE_NOT_FOUND: // 错误的文件名，文件不存在
						callback_str = "http_file_not_found";
						ELOG("http")->debug("curl: file not found url " + it->second.url);
						break;
					default:
						ELOG("http")->debug("curl: " +  it->second.describe_error() +  " error code:" + boost::lexical_cast<std::string>(msg->data.result));
						break;
				}
				
				if(it->second.type == http_download || it->second.type == http_resume_download)
				{
					it->second.data_process.clear();
					if(bSuccess) 
					{
						epfilesystem::instance().rename_file(it->second.filename, it->second.real_filename);

						//下载成功后 进行拷贝操作
						if (it->second.post_work->num_slots()>0)
						{
							(*it->second.post_work)();
						}
					}
					else
					{//下载不成功，删除站位文件
						epfilesystem::instance().remove_file(it->second.real_filename);
					}
				}

				(*it->second.callback)(bSuccess,callback_str);
				cleanup_curl(it);
			} // done
		}while(nmsgs);
	}

	void timed_working_process()
	{
		allow_more_check_ = true;
		working_process();
	}

	void working_process()
	{
		if(isStop_) return;
		if(!allow_more_check_) return;

		int loop = 100;
		int running_handle_count = 0;
		while(loop>0)
		{
			while (CURLM_CALL_MULTI_PERFORM == curl_multi_perform(multi_handle_, &running_handle_count))
			{
				;
			}
			
			if (running_handle_count == 0)
			{
				break;
			}
			
			--loop;
		}

		if (running_handle_count)
		{
			allow_more_check_ = false;
			http_thread_->set_timer(1, boost::bind(&http_request_impl::timed_working_process, this));
		}

		check_process();
	}
	
	void do_cancel(std::string uid)
	{
		if (uid.empty())
		{
			return;
		}

		std::map<CURL*, http_request_impl::result_tag>::iterator it = handles_.begin();
		for (; it != handles_.end(); it++)
		{
			if(it->second.uid == uid)
			{
				it->second.cancel = true;
				it->second.cancel_callback_str = "user_cancel_file_transfer";
				break;
			}
		}
	}

	// 终止所有文件传输
	void do_cancel_all(std::string reason)
	{
		std::map<CURL*, http_request_impl::result_tag>::iterator it = handles_.begin();
		for(;it != handles_.end();it++)
		{
			if(!it->second.uid.empty())
			{
				it->second.cancel = true;
				it->second.cancel_callback_str = reason;//"cancel_by_logon_different_pc";
			}
		}
	}

	void init_curl_timeout(CURL* curl)
	{
		// 初始化设置超时9秒， 或低于1字节每秒超过20秒
		curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, 9);
		curl_easy_setopt(curl, CURLOPT_LOW_SPEED_LIMIT, 1);
		curl_easy_setopt(curl, CURLOPT_LOW_SPEED_TIME, 20);
	}

	void do_post(std::string url, const std::map<std::string, std::string>& header, boost::function<void(bool,std::string)> callback)
	{
		if (url.empty() || header.size()==0)
		{
			callback(false, "");
			return;
		}

		if (handles_.size() >= MAX_HANDLES)
		{
			http_thread_->set_timer(50, boost::bind(&http_request_impl::do_post, this, url, header, callback));
			return;
		}

		CURL *curl = curl_easy_init();
		if (!curl) return;

		std::map<CURL*, result_tag>::iterator itc = handles_.find(curl);
		if (itc != handles_.end())
		{
			http_thread_->post(boost::bind(&http_request_impl::do_post, this, url, header, callback));
			return;
		}
		

		// 初始化设置超时3秒， 或低于1字节每秒超过20秒
		curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, 3);
		curl_easy_setopt(curl, CURLOPT_LOW_SPEED_LIMIT, 1);
		curl_easy_setopt(curl, CURLOPT_LOW_SPEED_TIME, 20);

		curl_easy_setopt(curl, CURLOPT_URL, url.c_str());

		curl_slist *headerlist = NULL;
		std::map<std::string, std::string>::const_iterator it;
		for (it = header.begin(); it!= header.end(); it++)
		{
			std::string header = it->first + ":" + it->second;
			headerlist = curl_slist_append(headerlist, header.c_str());
		}

		curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headerlist);
		curl_easy_setopt(curl, CURLOPT_POST, 1L);
		curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, request_result_callback);

		// 放入检查列表
		result_tag rtag;
		rtag.callback->connect(callback);
		rtag.type = http_post;
		rtag.url = url;
		
		handles_.insert(std::make_pair(curl, rtag));
		curl_easy_setopt(curl, CURLOPT_WRITEDATA,  &(handles_[curl]));
		curl_multi_add_handle(multi_handle_, curl);
		working_process();
	}

	void do_upload_file( std::string url, std::string filename, std::string uri, std::string uid, boost::function<void(int)> progress_call, boost::function<void(bool /*succ*/, std::string)> callback )
	{
		if (url.empty() || !epfilesystem::instance().file_exists(filename))
		{
			callback(false, "url_empty_or_file_not_exist");
			return;
		}

		if (handles_.size() >= MAX_HANDLES)
		{
			http_thread_->set_timer(50, boost::bind(&http_request_impl::do_upload_file, this, url, filename, uri, uid, progress_call, callback));
			return;
		}

		CURL *curl = curl_easy_init();
		if (!curl) return;
		
		std::map<CURL*, result_tag>::iterator it = handles_.find(curl);
		if (it != handles_.end())
		{
			http_thread_->post(boost::bind(&http_request_impl::do_upload_file, this, url, filename, uri, uid, progress_call, callback));
			return;
		}

		// url
		curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
		curl_easy_setopt(curl, CURLOPT_POST, 1L);
		// header
		curl_slist *headerlist = NULL;
		std::string digeststr = "Digest:" + uri;
		if(!uri.empty())
		{
			headerlist = curl_slist_append(headerlist, digeststr.c_str());
		}
		headerlist = curl_slist_append(headerlist, "Connection: Keep-Alive");

		std::string boundary = gen_uuid();
		std::string content_type = "Content-Type: multipart/form-data; boundary=" + boundary;
		headerlist = curl_slist_append(headerlist, content_type.c_str());
		std::string content_len = "Content-Length: ";
		long nFileSize = epfilesystem::instance().file_size(filename);
		long one_boundary_size = boundary.size() + 4;//extra pre -- plus \r\n
		std::string extra_data = (boost::format("--%s\r\nContent-Disposition: form-data; name=\"upload\"; filename=\"%s\"\r\nContent-Type: application/octet-stream\r\n\r\n")%boundary%epfilesystem::instance().file_name(filename)).str();
		int total_length = nFileSize + 2 + extra_data.size() + one_boundary_size + 2; //extra post --
		content_len += boost::lexical_cast<std::string>(total_length);
		headerlist = curl_slist_append(headerlist, content_len.c_str());
		curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headerlist);

		// write callback
		// process callback
		curl_easy_setopt(curl, CURLOPT_NOPROGRESS, false);
		curl_easy_setopt(curl, CURLOPT_PROGRESSFUNCTION, progress_callback);

		curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, request_result_callback);
		curl_easy_setopt(curl, CURLOPT_INFILESIZE, (curl_off_t)nFileSize);

		// 放入检查列表
		result_tag rtag;
		rtag.callback->connect(callback);
		rtag.filename = filename;
		rtag.uid = uid;
		rtag.url = url + " " + filename;
		rtag.type = http_upload;
		rtag.data_process = [=]() -> boost::function<size_t(char* buffer, int len)> {
			boost::shared_ptr<std::ifstream> ifs(new std::ifstream);
			epfilesystem::instance().open_stream(filename, *ifs, std::ios::binary);
			boost::uintmax_t total_size = epfilesystem::instance().file_size(filename);
			int http_multi_part0 = 0;
			int tail_is_wrote = 0;
			return [=](char* buffer, int len) mutable ->size_t {
				if(extra_data.size()>http_multi_part0)
				{
					if(len + http_multi_part0 >= extra_data.size())
					{
						int write_len = extra_data.size() - http_multi_part0;
						std::copy(extra_data.begin()+http_multi_part0, extra_data.end(), buffer);
						http_multi_part0 = extra_data.size();
						return write_len;
					}
					else
					{
						std::copy(extra_data.c_str()+http_multi_part0, extra_data.c_str()+http_multi_part0+len,buffer);
						http_multi_part0 += len;
						return len;
					}
				}
				if(total_size > len)
				{
					total_size -= len;
					ifs->read(buffer,len);
					return len;
				}
				else if(total_size > 0)
				{
					len = total_size;
					ifs->read(buffer,total_size);
					total_size = 0;
					return len;
				}
				else
				{
					if(tail_is_wrote == 0)
					{
						std::string tail_str = (boost::format("\r\n--%s--\r\n")%boundary).str();
						std::copy(tail_str.begin(), tail_str.end(), buffer);
						tail_is_wrote = 1;
						return tail_str.size();
					}
					else return 0;
				}
			};
		}();
		if(!progress_call.empty())
		{
			rtag.progress_sig.reset(new boost::signal<void(int)>);
			rtag.progress_sig->connect(progress_call);
		}
		handles_.insert(std::make_pair(curl, rtag));
		curl_easy_setopt(curl, CURLOPT_WRITEDATA, &handles_[curl]);
		curl_easy_setopt(curl, CURLOPT_PROGRESSDATA, &handles_[curl]);
		curl_easy_setopt(curl, CURLOPT_READFUNCTION, read_write_data_callback);
		curl_easy_setopt(curl, CURLOPT_INFILE, &handles_[curl].data_process);
		curl_easy_setopt(curl, CURLOPT_READDATA, &handles_[curl].data_process);

		
		curl_multi_add_handle(multi_handle_, curl);
		working_process();
	}
	
	void resume_upload_cb(parm parm_,boost::function<void(int)> progress_call, boost::function<void(bool /*succ*/, std::string)> callback ,bool succ ,std::string result_str)
	{
		//根据上一块传输的返回结果，确定下一块的传输状态
			if (succ&&result_str.find("\"error\":")!=result_str.npos)
			{
				callback(succ , result_str);
				return ; 
			}
			else if (succ&&result_str=="201")
			{
				parm_.numb++;
				std::string filename_tmp = parm_.filename;
				boost::uintmax_t total_size = epfilesystem::instance().file_size(filename_tmp);
				if (total_size > parm_.numb*segment_size_ )
				{
					http_thread_->post(boost::bind(&http_request_impl::do_resume_upload_file, this , parm_.url, parm_.filename, parm_.uri,parm_.numb , parm_.uid, resume_upload_file_progress_call(parm_,progress_call),
						bind2f(&http_request_impl::resume_upload_cb,this , parm_, (progress_call) , callback , _1 , _2)));	
				}
				else{
					callback(false , "");
					return ;
				}
			}
			else
			{
				callback(succ , result_str);
				return ; 
			}
	}
	boost::function<void(int)> resume_upload_file_progress_call(parm parm_,boost::function<void(int)> progress_call)
	{//计算当前已传输文件进度
		boost::function<void(int)> L_progress_call = [=](int curr_size_part) mutable {
			int curr_size = parm_.numb*segment_size_ + curr_size_part;
			progress_call(curr_size);
		};
		return L_progress_call;
	}
	void resume_upload_file( std::string url, std::string filename, int uploaded_size, std::string uri, std::string uid, boost::function<void(int)> progress_call, boost::function<void(bool /*succ*/, std::string)> callback )
	{
		if (url.empty() || !epfilesystem::instance().file_exists(filename))
		{
			callback(false, "url_empty_or_file_not_exist");
			return;
		}
		if (segment_size_==0)
		{
			segment_size_=SEGMENT_SIZE;
		}
		std::string filename_tmp = filename;
		boost::uintmax_t total_size = epfilesystem::instance().file_size(filename_tmp);
		parm parm_s;
		parm_s.numb = uploaded_size/segment_size_;//根据已传输文件大小，计算从第几块传输。
		parm_s.url = url;
		parm_s.uid = uid;
		parm_s.uri = uri;
		parm_s.filename = filename;
		boost::function<void(bool /*succ*/, std::string)> callback_tmp=boost::bind(&http_request_impl::resume_upload_cb,this ,parm_s, (progress_call) , callback , _1 , _2);

		do_resume_upload_file(url, filename , uri , parm_s.numb , uid , resume_upload_file_progress_call(parm_s,progress_call) , callback_tmp);	
	}
	void do_resume_upload_file( std::string url , std::string filename, std::string uri, int numb , std::string uid, boost::function<void(int)> progress_call, boost::function<void(bool /*succ*/, std::string)> callback )
	{
		
		if (handles_.size() >= MAX_HANDLES)
		{
			http_thread_->set_timer(50, boost::bind(&http_request_impl::do_resume_upload_file, this, url, filename, uri, numb , uid, progress_call, callback));
			return;
		}

		CURL *curl = curl_easy_init();
		if (!curl) return;

		std::map<CURL*, result_tag>::iterator it = handles_.find(curl);
		if (it != handles_.end())
		{
			http_thread_->post(boost::bind(&http_request_impl::do_resume_upload_file, this, url, filename, uri , numb , uid, progress_call, callback));
			return;
		}

		// url
		curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
		curl_easy_setopt(curl, CURLOPT_POST, 1L);
		// header
		curl_slist *headerlist = NULL;
		std::string jid = uri.substr(uri.find_last_of('.')+1,uri.length());
		uri = uri.substr(0,uri.find_last_of('.'));
		
		//依据协议封装http头
		std::string content_type = "Content-Type: application/octet-stream";
		headerlist = curl_slist_append(headerlist, content_type.c_str());
		std::string content_disposition = "Content-Disposition: attachment; filename=\""+ uri+"\"";
		std::string session_id = "Session-ID: "+uri.substr(0,uri.find_last_of('.'))+jid;
		headerlist = curl_slist_append(headerlist, content_disposition.c_str());
		headerlist = curl_slist_append(headerlist, session_id.c_str());
		std::string content_len = "Content-Length: ";
		std::string filename_tmp = filename;
		boost::uintmax_t total_size = epfilesystem::instance().file_size(filename_tmp);
		std::string content_="X-Content-Range: bytes %s-%s/"+boost::lexical_cast<std::string>(total_size);
		boost::uintmax_t need_send_size= 0 , content_length = 0;
		//计算需要传输的块的大小
		if (total_size > numb*segment_size_)
		{
			need_send_size=total_size - numb*segment_size_;
		}
		else{
			callback(false , "");
			return ;
		}
		if (need_send_size>segment_size_)
		{
			content_length = segment_size_;
		}
		else
		{
			content_length =need_send_size;
		}
		std::string content_range=boost::str(boost::format(content_)%boost::lexical_cast<std::string>(numb*segment_size_) %boost::lexical_cast<std::string>(numb*segment_size_+content_length-1));

		content_len += boost::lexical_cast<std::string>(content_length);
		headerlist = curl_slist_append(headerlist, content_len.c_str());
		headerlist = curl_slist_append(headerlist, content_range.c_str());
		
		curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headerlist);

		// write callback
		// process callback
		curl_easy_setopt(curl, CURLOPT_NOPROGRESS, false);
		curl_easy_setopt(curl, CURLOPT_PROGRESSFUNCTION, progress_callback);

		curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, request_result_callback);
		curl_easy_setopt(curl, CURLOPT_INFILESIZE, (curl_off_t)content_length);

		// 放入检查列表
		result_tag rtag;
		rtag.callback->connect(callback);
		rtag.filename = uri;
		rtag.uid = uid;
		rtag.url = url + " " + uri;
		rtag.type = http_resume_upload;
		rtag.data_process = [=]() -> boost::function<size_t(char* buffer, int len)> {
			boost::shared_ptr<std::ifstream> ifs(new std::ifstream);
			epfilesystem::instance().open_stream(filename, *ifs, std::ios::binary);
			ifs->seekg(numb*segment_size_,std::ios::beg);
			int numb = 0;
			boost::uintmax_t total_size = content_length;
			return [=](char* buffer, int len) mutable ->size_t {
				if(total_size > len)
				{
					total_size -= len;
					ifs->read(buffer,len);
					return len;
				}
				else if(total_size > 0)
				{
					len = total_size;
					ifs->read(buffer,total_size);
					total_size = 0;
					return len;
				}
				else
				{
					return 0;
				}
			};
		}();
		if(!progress_call.empty())
		{
			rtag.progress_sig.reset(new boost::signal<void(int)>);
			rtag.progress_sig->connect(progress_call);
		}
		handles_.insert(std::make_pair(curl, rtag));
		curl_easy_setopt(curl, CURLOPT_WRITEDATA, &handles_[curl]);
		curl_easy_setopt(curl, CURLOPT_PROGRESSDATA, &handles_[curl]);
		curl_easy_setopt(curl, CURLOPT_READFUNCTION, read_write_data_callback);
		curl_easy_setopt(curl, CURLOPT_INFILE, &handles_[curl].data_process);
		curl_easy_setopt(curl, CURLOPT_READDATA, &handles_[curl].data_process);


		curl_multi_add_handle(multi_handle_, curl);
		working_process();
	}
	void do_download( std::string url, std::string filename, std::string uri, std::string uid, boost::function<void(int)> progress_call, boost::function<void(bool, std::string)> callback )
	{
		if (url.empty() || filename.empty())
		{
			if (!callback.empty())
			{
				callback(false, "");
				return;
			}
		}

		std::map<CURL*, result_tag>::iterator it = handles_.begin();
		for(;it != handles_.end(); it++)
		{
			if(it->second.type == http_download && it->second.url == (url + uri))
			{
				// 新下载请求 与正在下载的地址相同 但保存文件的路径不同 下载成功后拷贝下载文件到此路径
				if (it->second.real_filename != filename)
				{
					boost::function<void()> copyfunc = [=]()->boost::function<void()>{
						std::string srcfilename = it->second.real_filename;
						std::string descfilename = filename;
						return [=](){
							if (epfilesystem::instance().file_exists(srcfilename))
							{
								epfilesystem::instance().copy_file(srcfilename, descfilename, true);
							}
						};
					}();

					// 绑定进度通知
					if (!progress_call.empty())
					{
						it->second.progress_sig->connect(progress_call);
					}
					
					it->second.post_work->connect(copyfunc);
				}

				it->second.callback->connect(callback);
				return;
			}
		}

		if (handles_.size() >= MAX_HANDLES)
		{
			http_thread_->set_timer(50, boost::bind(&http_request_impl::do_download, this, url, filename, uri, uid, progress_call, callback));
			return;
		}

		CURL *curl = curl_easy_init();
		if (!curl) return;

		it = handles_.find(curl);
		if (it != handles_.end())
		{
			http_thread_->post(boost::bind(&http_request_impl::do_download, this, url, filename, uri, uid, progress_call, callback));
			return;
		}

		result_tag rtag;
		rtag.real_filename = filename;
		init_curl_timeout(curl);

		//使用临时文件
		filename = epfilesystem::instance().sub_path(epfilesystem::instance().branch_path(filename), gen_uuid());
 		rtag.data_process = [=]() -> boost::function<size_t(char* buffer, int len)> {
 			boost::shared_ptr<std::ofstream> ofs(new std::ofstream);
 			epfilesystem::instance().open_stream(filename, *ofs, std::ios::binary);
				return [=](char* buffer, int len) mutable ->size_t {
					std::ios::iostate wstate = (ofs->write(buffer, len)).rdstate();
					if ( ((wstate & std::ofstream::failbit) != 0) ||
						((wstate & std::ofstream::badbit) != 0) )
					{
						return 0;
					}
					return len;
 			};
 		}();

		// url
		std::string download_addr = url + uri;
		curl_easy_setopt(curl, CURLOPT_URL, download_addr.c_str());

		// get
		curl_easy_setopt(curl, CURLOPT_HTTPGET, 1L);

		// 放入检查列表
		rtag.callback->connect(callback);
		rtag.filename = filename;
		rtag.uri = uri;
		rtag.url = url + uri;
		rtag.type = http_download;
		rtag.uid = uid;
		// process callback
		if (!progress_call.empty())
		{
			rtag.progress_sig.reset(new boost::signal<void(int)>);
			rtag.progress_sig->connect(progress_call);
			handles_.insert(std::make_pair(curl, rtag));
			curl_easy_setopt(curl, CURLOPT_NOPROGRESS, false);
			curl_easy_setopt(curl, CURLOPT_PROGRESSFUNCTION, progress_callback);
			curl_easy_setopt(curl, CURLOPT_PROGRESSDATA, &handles_[curl]);
		}
		else
		{
			handles_.insert(std::make_pair(curl, rtag));
		}
		// write callback
		curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, read_write_data_callback);
		curl_easy_setopt(curl, CURLOPT_WRITEDATA, &(handles_[curl].data_process));

		curl_multi_add_handle(multi_handle_, curl);
		http_thread_->post([this](){working_process();});
	}
	boost::function<void(int)> resume_download_cb(std::string filename , std::string uri, boost::function<void(int)> progress_call)
	{//获取已下载的文件大小，通知界面传输进度
		int size_ = 0;
		filename = epfilesystem::instance().sub_path(epfilesystem::instance().branch_path(filename), uri.substr(0,uri.find_last_of('.')));
		if (epfilesystem::instance().is_regular_file(filename))
		{
			size_= epfilesystem::instance().file_size(filename);
		}
		boost::function<void(int)> L_progress_call = [=](int curr_size_part) mutable {
			int curr_size = size_ + curr_size_part;
			progress_call(curr_size);
		};
		return L_progress_call;
	}
	void resume_download( std::string url, std::string filename, std::string uri, std::string uid, boost::function<void(int)> progress_call, boost::function<void(bool, std::string)> callback )
	{
		do_resume_download(url, filename, uri, uid, resume_download_cb(filename, uri, progress_call), callback);
	}
	void do_resume_download( std::string url, std::string filename, std::string uri, std::string uid, boost::function<void(int)> progress_call, boost::function<void(bool, std::string)> callback )
	{
		if (url.empty() || filename.empty())
		{
			if (!callback.empty())
			{
				callback(false, "");
				return;
			}
		}

		std::map<CURL*, result_tag>::iterator it = handles_.begin();
		for(;it != handles_.end(); it++)
		{
			if(it->second.type == http_download && it->second.url == (url + uri))
			{
				// 新下载请求 与正在下载的地址相同 但保存文件的路径不同 下载成功后拷贝下载文件到此路径
				if (it->second.real_filename != filename)
				{
					boost::function<void()> copyfunc = [=]()->boost::function<void()>{
						std::string srcfilename = it->second.real_filename;
						std::string descfilename = filename;
						return [=](){
							if (epfilesystem::instance().file_exists(srcfilename))
							{
								epfilesystem::instance().copy_file(srcfilename, descfilename, true);
							}
						};
					}();

					// 绑定进度通知
					if (!progress_call.empty())
					{
						it->second.progress_sig->connect(progress_call);
					}

					it->second.post_work->connect(copyfunc);
				}

				it->second.callback->connect(callback);
				return;
			}
		}

		if (handles_.size() >= MAX_HANDLES)
		{
			http_thread_->set_timer(50, boost::bind(&http_request_impl::do_resume_download, this, url, filename, uri, uid, progress_call, callback));
			return;
		}

		CURL *curl = curl_easy_init();
		if (!curl) return;

		it = handles_.find(curl);
		if (it != handles_.end())
		{
			http_thread_->post(boost::bind(&http_request_impl::do_resume_download, this, url, filename, uri, uid, progress_call, callback));
			return;
		}
		
		result_tag rtag;
		rtag.real_filename = filename;
		init_curl_timeout(curl);

		//使用临时文件
		filename = epfilesystem::instance().sub_path(epfilesystem::instance().branch_path(filename), uri.substr(0,uri.find_last_of('.')));
		rtag.data_process = [=]() -> boost::function<size_t(char* buffer, int len)> {
			boost::shared_ptr<std::ofstream> ofs(new std::ofstream);
			epfilesystem::instance().open_stream(filename, *ofs, std::ios::binary|std::ios::app);
			return [=](char* buffer, int len) mutable ->size_t {
				std::ios::iostate wstate = (ofs->write(buffer, len)).rdstate();
				if ( ((wstate & std::ofstream::failbit) != 0) ||
					((wstate & std::ofstream::badbit) != 0) )
				{
					return 0;
				}
				return len;
			};
		}();

		// url
		std::string download_addr = url + uri;
		curl_easy_setopt(curl, CURLOPT_URL, download_addr.c_str());

		// get
		curl_easy_setopt(curl, CURLOPT_HTTPGET, 1L);

		// 放入检查列表
		rtag.callback->connect(callback);
		rtag.filename = filename;
		rtag.uri = uri;
		rtag.url = url + uri;
		rtag.type = http_resume_download;
		rtag.uid = uid;
		// process callback

		long size_=0;
		if (epfilesystem::instance().is_regular_file(filename))
		{
			size_= epfilesystem::instance().file_size(filename);
		}
		if (!progress_call.empty())
		{
			rtag.progress_sig.reset(new boost::signal<void(int)>);
			rtag.progress_sig->connect(progress_call);
			handles_.insert(std::make_pair(curl, rtag));
			curl_easy_setopt(curl, CURLOPT_NOPROGRESS, false);
			curl_easy_setopt(curl, CURLOPT_PROGRESSFUNCTION, progress_callback);
			curl_easy_setopt(curl, CURLOPT_RESUME_FROM, size_);
			curl_easy_setopt(curl, CURLOPT_PROGRESSDATA, &handles_[curl]);
		}
		else
		{
			handles_.insert(std::make_pair(curl, rtag));
		}
		// write callback
		curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, read_write_data_callback);
		curl_easy_setopt(curl, CURLOPT_WRITEDATA, &(handles_[curl].data_process));

		curl_multi_add_handle(multi_handle_, curl);
		http_thread_->post([this](){working_process();});
	}
	void do_get(std::string url, boost::function<void(bool,std::string)> callback)
	{
		if (url.empty() )
		{
			if (!callback.empty())
			{
				callback(false, "");
				return;
			}
		}

		if (handles_.size() >= MAX_HANDLES)
		{
			http_thread_->set_timer(50, boost::bind(&http_request_impl::do_get, this, url, callback));
			return;
		}

		CURL *curl = curl_easy_init();
		if (!curl) return;

		std::map<CURL*, result_tag>::iterator it = handles_.find(curl);
		if (it != handles_.end())
		{
			http_thread_->post(boost::bind(&http_request_impl::do_get, this, url, callback));
			return;
		}

		init_curl_timeout(curl);

		curl_easy_setopt(curl, CURLOPT_URL, url.c_str());


		// get
		curl_easy_setopt(curl, CURLOPT_HTTPGET, 1L);

		// write callback
		curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, request_result_callback);

		// 放入检查列表
		result_tag rtag;
		rtag.callback->connect(callback);
		rtag.url = url;
		rtag.type = http_get;

		handles_.insert(std::make_pair(curl, rtag));
		curl_easy_setopt(curl, CURLOPT_WRITEDATA, &handles_[curl]);
		curl_multi_add_handle(multi_handle_, curl);
		working_process();
	}

		
	bool isStop_;
	bool allow_more_check_;
	int segment_size_;
	CURLM *multi_handle_;
	boost::shared_ptr<epius::time_thread> http_thread_;
	std::map<CURL*, result_tag > handles_;
};


static size_t request_result_callback(void *ptr, size_t size, size_t nmemb, void *userp) 
{
	http_request_impl::result_tag* p_tag = (http_request_impl::result_tag*) userp;
	size_t real_size = size * nmemb;
	if (p_tag)
	{
		p_tag->result_string.append(reinterpret_cast<char *>(ptr), real_size);
	}
	return real_size;
}

static int progress_callback(void *clientp, double dltotal, double dlnow, double ultotal, double ulnow)
{
	http_request_impl::result_tag* p_tag = (http_request_impl::result_tag*) clientp;
	if (p_tag)
	{
		if (p_tag->cancel)
		{
			// 返回非0值，终止这个传输
			return 1;
		}
		if(p_tag->type == http_request_impl::http_upload || p_tag->type == http_request_impl::http_resume_upload)
		{
			p_tag->progress(ulnow);
		}
		else if(p_tag->type == http_request_impl::http_download || p_tag->type == http_request_impl::http_resume_download)
		{
			p_tag->progress(dlnow);
		}
	}
	return 0;
}

http_request::~http_request(void)
{
}

http_request::http_request(void)
	: impl_(new http_request_impl())
{

}

void http_request::init()
{
	impl_->init();
}

void http_request::upload( std::string url, std::string filename, std::string uri, std::string uid, boost::function<void(int)> progress_call, boost::function<void(bool /*succ*/, std::string)> callback )
{
	
	impl_->http_thread_->post(boost::bind(&http_request_impl::do_upload_file, impl_, url, filename, uri, uid, progress_call, callback));

}
void http_request::resume_upload_file( std::string url, std::string filename, std::string uploaded_size_s, std::string uri, std::string uid, boost::function<void(int)> progress_call, boost::function<void(bool /*succ*/, std::string)> callback )
{

	int uploaded_size = 0;
	if (!uploaded_size_s.empty())
	{
		uploaded_size =  boost::lexical_cast<int>(uploaded_size_s);
	}
	impl_->http_thread_->post(boost::bind(&http_request_impl::resume_upload_file, impl_, url, filename, uploaded_size, uri, uid, progress_call, callback));
}

void http_request::cancel( std::string uid )
{
	impl_->http_thread_->post(boost::bind(&http_request_impl::do_cancel, impl_, uid));
}

void http_request::post( std::string url, const std::map<std::string, std::string>& header, boost::function<void(bool,std::string)> callback )
{
	impl_->http_thread_->post(boost::bind(&http_request_impl::do_post, impl_, url, header, callback));
}

void http_request::download( std::string url, std::string filename, std::string uri, std::string uid, boost::function<void(int)> progress_call, boost::function<void(bool, std::string)> callback )
{
	impl_->http_thread_->post(boost::bind(&http_request_impl::do_download, impl_, url, filename, uri, uid, progress_call, callback));
}

void epius::http_request::resume_download( std::string url, std::string filename, std::string uri, std::string uid, boost::function<void(int)> progress_call, boost::function<void(bool, std::string)> callback )
{
	impl_->http_thread_->post(boost::bind(&http_request_impl::resume_download, impl_, url, filename, uri, uid, progress_call, callback));
}

void http_request::stop()
{
	impl_->http_thread_->post(boost::bind(&http_request_impl::do_stop, impl_));
}


void http_request::get( std::string url, boost::function<void(bool,std::string)> callback )
{
	impl_->http_thread_->post(boost::bind(&http_request_impl::do_get, impl_, url, callback));
}


}; // namespace biz

void epius::http_request::cancel_all(std::string reason)
{
	impl_->http_thread_->post(boost::bind(&http_request_impl::do_cancel_all, impl_, reason));
}


