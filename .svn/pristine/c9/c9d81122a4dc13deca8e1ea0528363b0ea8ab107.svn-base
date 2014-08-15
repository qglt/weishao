#include <boost/asio.hpp>
#include <boost/bind.hpp>
#include <boost/thread.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/tokenizer.hpp>
#include <base/network/icmp/ping.h>
#include <base/tcpproactor/TcpProactor.h>
#include <base/tcpproactor/StreamBase.h>
#include <base/log/elog/elog.h>


namespace epius
{
	using namespace proactor;
	class pinger:public CStreamBase
	{
	public:
		virtual bool handle_accept_fail(const boost::system::error_code& error)
		{
			ELOG("http")->debug("eportal check, network unavaliable");
			do_callback(ping_mgr_decl::NO_NETWORK);
			return true;
		}
		virtual bool handle_read_fail(const boost::system::error_code& error)
		{
			ELOG("http")->debug("eportal check, and read stream error");
			do_callback(ping_mgr_decl::NO_NETWORK);
			return true;
		}

		virtual void handle_accept(shared_ptr<epSocket> key)
		{
			ELOG("http")->debug("eportal check, stream created");
			std::string info_get = 
				"GET " + dest_url_ + " HTTP/1.1" +
				"\r\nHost: " + get_host_from_url(dest_url_) +
				"\r\nConnection: keep-alive"
				"\r\nAccept: */*"
				"\r\nConnection: close"
				"\r\n\r\n";
			write(info_get);
		}
		//如何检测eportal 跳转规则
		//1) http 返回302
		//2) http 返回200, 返回5个字段，Server 是 Apache, Content-Length, Cache-Control: no-cache, Connection, followed by <script>
		//
		virtual void handle_read(std::string const& str)
		{
			ELOG("http")->debug("eportal check, got string:"+str);
			if(response_body_)
			{
				*response_body_ += str;
			}
			else
			{
				response_header_ += str;
				std::string::size_type str_pos = response_header_.find("\r\n\r\n");
				if((str_pos != std::string::npos))
				{
					std::string header = response_header_.substr(0, str_pos);
					std::string body = response_header_.substr(str_pos+4);
					response_body_.reset(new std::string);
					*response_body_ = body;
					response_header_ = header;
				}
			}
			std::string followed_str = "<script>";
			if(response_body_)
			{
				if(get_http_response_status(response_header_)=="200")
				{
					if(response_body_->size()>=followed_str.size())
					{
						if(match_eportal_page(response_header_, *response_body_))
						{
							do_callback(ping_mgr_decl::NEED_AUTH);
							close();
						}
						else
						{
							do_callback(ping_mgr_decl::AUTHED);
							close();
						}
					}
				}
				else//should be eportal
				{
					do_callback(ping_mgr_decl::NEED_AUTH);
					close();
				}
			}
		}
		std::string get_http_response_status(std::string const& header)
		{
			std::string http_response_head = "HTTP/1.1 ";
			std::string status = header.substr(http_response_head.size(),3);
			return status;
		}
		std::string get_host_from_url(std::string const& url)
		{
			std::string host;
			if(boost::starts_with(url, "http://"))
			{
				host = url.substr(7);
			}
			else
			{
				host = url;
			}
			std::string::size_type split_pos = host.find_first_of('/');
			if(split_pos!=std::string::npos)
			{
				host = host.substr(0, split_pos);
			}
			return host;
		}
		bool match_eportal_page(std::string const& header, std::string const& body)
		{
			std::vector<std::string> header_lines;
			boost::char_separator<char> sep("\r\n");
			boost::tokenizer<boost::char_separator<char> > tok(header, sep);
			std::copy(tok.begin(), tok.end(), std::back_inserter(header_lines));
			if(header_lines.size()>5)return false;
			boost::char_separator<char> sep_line(":");
			for(std::vector<std::string>::iterator it = header_lines.begin(); it != header_lines.end();++it)
			{
				std::vector<std::string> line_parts;
				boost::tokenizer<boost::char_separator<char> > tok_line(*it, sep_line);
				std::copy(tok_line.begin(), tok_line.end(), std::back_inserter(line_parts));
				if(line_parts.size()!=2)continue;
				if(boost::trim_copy(line_parts[0]) == "Server")
				{
					if(boost::trim_copy(line_parts[1])!= "Apache") {return false;}
				}
				if(boost::trim_copy(line_parts[0]) == "Cache-Control")
				{
					if(boost::trim_copy(line_parts[1])!= "no-cache") {return false;}
				}
				if(boost::trim_copy(line_parts[0]) == "Connection")
				{
					if(boost::trim_copy(line_parts[1])!= "close") {return false;}
				}
			};
			if(boost::starts_with(body, "<script>")) return true;
			return false;
		}
		void do_callback(ping_mgr_decl::PING_STATUS status)
		{
			if(!callback_.empty()) callback_(status);
			callback_ = boost::function<void(ping_mgr_decl::PING_STATUS)>();
		}
		std::string response_header_;
		boost::shared_ptr<std::string> response_body_;
		
		std::string dest_url_;
		boost::function<void(ping_mgr_decl::PING_STATUS)> callback_;
	};
	class ping_mgr_impl
	{
	public:
		ping_mgr_impl()
		{
		}
		~ping_mgr_impl()
		{
			stop();
		}
		void stop()
		{
			proactor_.stop();
		}
		void do_ping(std::string dest, int timeout_ms,boost::function<void(ping_mgr_decl::PING_STATUS)> callback )
		{
			boost::shared_ptr<pinger> tmp_pinger(new pinger());
			boost::function<void(ping_mgr_decl::PING_STATUS)> clear_and_callback = [=](ping_mgr_decl::PING_STATUS ret) mutable
			{
				callback(ret);
				proactor_.post([=]()mutable{tmp_pinger.reset();});
			};
			tmp_pinger->dest_url_ = dest;
			dest = tmp_pinger->get_host_from_url(dest);
			tmp_pinger->callback_ = clear_and_callback;
			proactor_.connect(dest,"80", tmp_pinger);
		}
	public:
		tcp_proactor proactor_;
	};

	ping_mgr_decl::ping_mgr_decl():impl_(new ping_mgr_impl)
	{

	}

	void ping_mgr_decl::stop()
	{
		impl_->stop();
	}

	void ping_mgr_decl::ping( std::string dest, int timeout_ms,boost::function<void(ping_mgr_decl::PING_STATUS)> callback )
	{
		impl_->proactor_.post(boost::bind(&ping_mgr_impl::do_ping, impl_, dest, timeout_ms, callback));
	}

}