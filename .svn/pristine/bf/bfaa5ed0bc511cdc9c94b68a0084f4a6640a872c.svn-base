#pragma once

#include <string>
#include <deque>

#include <boost/function.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/system/error_code.hpp>
#include <base/config/configure.hpp>
#include <base/json/tinyjson.hpp>

namespace epius
{
	using boost::shared_ptr;
	namespace proactor
	{
		enum stream_error_id {SERR_ALREADY_CONNECT,SERR_NOT_CONNECT, SERR_PLACEHOLDER};
		class stream_error:public boost::system::error_category
		{
			std::string err_msg_;
		public:
			stream_error(std::string const& errMsg):err_msg_(errMsg){}
			virtual const char* name() const BOOST_SYSTEM_NOEXCEPT { return "stream_error"; }
			virtual std::string message(int ev) const {return err_msg_;}
		};
		boost::system::error_code getStreamError(stream_error_id val);
	}
}


namespace epius
{
	namespace proactor
	{
		class epSocket;
		class tcp_proactor;
		class tcp_stream_ctrl;
		class tcp_client;
		class tcp_server;
		struct stream_action
		{
			json::jobject jobj;
			boost::function<void()> cmd;
		};
		class CStreamBase
		{
			friend class tcp_proactor;
			friend class tcp_stream_ctrl;
			friend class tcp_client;
			friend class tcp_server;
		protected:
			// return true will close the stream
			virtual bool handle_accept_fail(const boost::system::error_code& error){return true;}
			virtual bool handle_write_fail(const boost::system::error_code& error){return true;}
			virtual bool handle_read_fail(const boost::system::error_code& error){return true;}

			virtual void handle_write(std::size_t bytes_transferred){}
			virtual void handle_read(std::string const& str){}
			virtual void handle_accept(shared_ptr<epSocket> key){}
			virtual void handle_close(){}
		public:
			void write(std::string const& str);
			void close(void);
			void set_timer(int nInterval, boost::function<void()> cmd);
			//only post have the queue lock of io_service, post is thread safe
			void post(boost::function<void(void)>cmd);
			CStreamBase();
			virtual ~CStreamBase(void);
		private:
			//commands are set in the call of connect for client stream. for server side stream, they will be available after accept. 
			//but, even the client stream is not created, the buffer still can be write, they will be kept in the buffer and send out once the stream created.
			void setActionCmd(shared_ptr<boost::function<void(stream_action)> > cmd = shared_ptr<boost::function<void(stream_action)> >());
		private:
			shared_ptr<boost::function<void(stream_action)> > actionCmd_;
		};
	}
}
