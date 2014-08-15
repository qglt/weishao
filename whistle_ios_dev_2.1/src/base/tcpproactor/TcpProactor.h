
#pragma once

#include <set>

#include <boost/bind.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/asio.hpp>
#include <boost/function.hpp>
#include <boost/thread.hpp>
#include <boost/array.hpp>
#include <boost/tuple/tuple.hpp>
#include <boost/signals/trackable.hpp>

#include <base/config/configure.hpp>
#include <base/utility/shared_ptr/make_shared_ptr.hpp>
#include <base/cmd_wrapper/command_wrapper.h>
#include <boost/asio/steady_timer.hpp>

namespace epius
{
	namespace proactor
	{
		//all calls except in tcp_proactor in this file will occur in network thread
		typedef boost::asio::basic_waitable_timer<boost::chrono::steady_clock> steady_timer;
		class CStreamBase;
		using namespace boost;
		using boost::asio::ip::tcp;
		using boost::system::error_code;
		using boost::tuple;
		struct stream_action;
		class epSocket
		{
		public:
			epSocket();
			virtual ~epSocket();
			virtual asio::io_service& get_io_service() = 0;
			virtual void async_write(std::string& buf, boost::function<void(const error_code&, std::size_t)> cmd) = 0;
			virtual void async_read_some(asio::mutable_buffers_1 const &buf, boost::function<void(const error_code&, std::size_t)> cmd) = 0;
			virtual void async_connect(tcp::endpoint const& endpt, boost::function<void(const error_code&)> cmd) = 0;
			virtual void async_accept(tcp::acceptor &tmpAcceptor, boost::function<void(const error_code&, int)>cmd) = 0;
			virtual void shutdown() = 0;
			virtual epSocket* clone() = 0;
			virtual boost::function<void(boost::function<void()>) > get_post_command() = 0;
            virtual std::string get_host_ip() = 0;
		};

		class epSocketNormal:public epSocket
		{
		public:
			epSocketNormal(asio::io_service & ios):socket_(ios){}
			virtual asio::io_service& get_io_service();
			virtual void async_write(std::string& buf, boost::function<void(const error_code&, std::size_t)> cmd);
			virtual void async_read_some(asio::mutable_buffers_1 const &buf, boost::function<void(const error_code&, std::size_t)> cmd);
			virtual ~epSocketNormal() {socket_.close();}
			virtual void async_connect(tcp::endpoint const& endpt, boost::function<void(const error_code&)> cmd);
			virtual void shutdown();
			virtual void async_accept(tcp::acceptor &tmpAcceptor, boost::function<void(const error_code&, int)>cmd);
			virtual epSocket* clone() {return new epSocketNormal(get_io_service());}
			boost::function<void(boost::function<void()>) > get_post_command();
            virtual std::string get_host_ip();
			void post(boost::function<void()>);
		private:
			tcp::socket socket_;
		};

		class tcp_stream_ctrl:public boost::signals::trackable
		{
			enum {streamsize = 2*1024};
		protected:
			typedef std::map< boost::shared_ptr<epSocket>, tuple< boost::shared_ptr<CStreamBase>, boost::array<char,streamsize>, std::string> > this_stream_type;
			this_stream_type vstreams_;
		protected:
			void do_write(boost::shared_ptr<epSocket> key, boost::shared_ptr<std::string> str);
            void do_close(boost::shared_ptr<epSocket> key);
			void action_in_work_thread(boost::shared_ptr<epSocket> key, stream_action act);
		public:
			void set_timer(boost::shared_ptr<epSocket> key,int ms,boost::function<void()> cmd);
			void do_action(boost::shared_ptr<epSocket> key, stream_action act);
			void closeAll();
			void handle_read(boost::shared_ptr<epSocket> key, const error_code& error,std::size_t bytes_transferred);
			void handle_write(boost::shared_ptr<epSocket> key, boost::shared_ptr<std::string> to_write, const error_code& error, std::size_t bytes_transferred);
			void handle_timer(boost::shared_ptr<epSocket> key, shared_ptr<steady_timer> time_key, boost::function<void()> cmd, const error_code& e);
			virtual ~tcp_stream_ctrl();
		};
		
		class tcp_server:public tcp_stream_ctrl
		{
		private:
			asio::io_service& io_service_;
			tcp::acceptor acceptor_;
			boost::function<boost::shared_ptr<CStreamBase>()> stream_creator_;
			void handle_accept(boost::shared_ptr<epSocket> key, const error_code& error, int delay_success);
			void init(boost::shared_ptr<epSocket> key);
		public:
			tcp_server(int port,asio::io_service& ioService,boost::function<boost::shared_ptr<CStreamBase>()> cmd);
			void stop_listen();
			unsigned short get_listen_port() {return acceptor_.local_endpoint().port();}
		};

		class tcp_client:public tcp_stream_ctrl
		{
		public:
            tcp_client();
            void init(std::string const& strIp, std::string const& port, const boost::shared_ptr<CStreamBase>& obj,asio::io_service& ioService);
			void init(int timeoutMs, std::string const& strIp, std::string const& port, const shared_ptr<CStreamBase>& obj, asio::io_service& ioService);
			boost::shared_ptr<epSocket> clntSocket();
            ~tcp_client(){}
			void handle_resolve(boost::shared_ptr<epSocket> key, boost::shared_ptr<tcp::resolver>, const boost::system::error_code& error,tcp::resolver::iterator endpoint_iterator);
			void handle_connect(boost::shared_ptr<epSocket> key, const error_code& error,tcp::resolver::iterator endpoint_iterator);
		};
/* Useage of tcp_proactor
Server:
	tcp_proactor actor;
	unsigned short a1 = actor.start_listen<ChatSession>(2000);//a1 = 2000, the port used
Client:
	tcp_proactor actor;
	boost::shared_ptr<CChatClient> clntObj(new CChatClient);
	actor.connect("127.0.0.1","2000",clntObj);
	//also we can, clntObj.close(); actor.connect("127.0.0.1","2000",clntObj); again.
	//shall we add the check to prevent one stream from being connect many times?
*/
/*

*/
		class tcp_proactor
		{
			class tcp_proactor_impl;
		public:
			tcp_proactor();
			~tcp_proactor();
			void stop_listen(unsigned short port);
			template<class StreamProcess> unsigned short start_listen(int port)
			{
				return start_listen(port,boost::bind(&boost::make_shared<StreamProcess>));
			}
			unsigned short start_listen(int port, boost::function<boost::shared_ptr<CStreamBase>()> cmd);
			void connect(std::string host,std::string port,boost::shared_ptr<CStreamBase>object);
			void timed_connect(int timeoutMs, std::string host,std::string port,boost::shared_ptr<CStreamBase>object);
			void post(boost::function<void()>cmd);
			act_post_cmd get_post_cmd();
			thread_teller_cmd get_thread_tell_cmd();
            bool is_in_work_thread();
            void set_timer( int ms,boost::function<void()> cmd );
			void stop();
		private:
			void run();
            void do_stop();
            void handle_timer(shared_ptr<steady_timer> time_key, boost::function<void()> cmd, const error_code& e );
		private:
			boost::shared_ptr<tcp_proactor_impl> impl_;
		};
	}
}
