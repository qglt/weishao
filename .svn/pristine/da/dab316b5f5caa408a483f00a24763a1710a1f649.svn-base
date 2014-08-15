#pragma once
#include <string>
#include "boost/function.hpp"
#include "boost/shared_ptr.hpp"
#include <base/utility/singleton/singleton.hpp>
#include "base/json/tinyjson.hpp"

namespace epius {
	struct http_request_impl;
	class http_request
	{
		template<class> friend struct boost::utility::singleton_holder;

		public:
			http_request(void);
			virtual ~http_request(void);
	
			void init();
			void stop();
			void download(std::string url, std::string filename, std::string uri, std::string uid, boost::function<void(int)> progress_call, boost::function<void(bool, std::string)> callback);
			void resume_download(std::string url, std::string filename, std::string uri, std::string uid, boost::function<void(int)> progress_call, boost::function<void(bool, std::string)> callback);
			void upload( std::string url, std::string filename, std::string uri, std::string uid, boost::function<void(int)> progress_call, boost::function<void(bool /*succ*/, std::string)> callback);
			void resume_upload_file( std::string url, std::string filename, std::string uploaded_size_s, std::string uri, std::string uid, boost::function<void(int)> progress_call, boost::function<void(bool /*succ*/, std::string)> callback );
			void cancel(std::string uid);
			void cancel_all(std::string reason);
			void post(std::string url, const std::map<std::string, std::string>& header, boost::function<void(bool,std::string)> callback);
			void get(std::string url, boost::function<void(bool,std::string)> callback);

			//通知文件传输状态
			boost::signal<void(json::jobject)> file_transfer_status;
		private:
			boost::shared_ptr<http_request_impl> impl_;
	};


	typedef boost::utility::singleton_holder<http_request> http_requests;
}; // namespace biz