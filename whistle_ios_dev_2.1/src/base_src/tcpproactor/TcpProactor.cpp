#include <base/tcpproactor/TcpProactor.h>
#include <base/tcpproactor/StreamBase.h>
#include <boost/signal.hpp>
#include <base/utility/bind2f/bind2f.hpp>
#include <base/cmd_wrapper/command_wrapper.h>

using namespace std;
using epius::proactor::CStreamBase;


#define SWITCH_THREAD(function_name, ...)					\
if(!is_in_work_thread())                                				\
{																		\
	post(boost::bind(function_name,this,__VA_ARGS__));					\
	return;																\
}

namespace epius
{
	namespace proactor
	{
		epSocket::epSocket()
		{
		}
		epSocket::~epSocket()
		{
		}
		class tcp_proactor::tcp_proactor_impl
		{
		public:
			tcp_proactor_impl():work_(new asio::io_service::work(io_service_)), clients_(new tcp_client)
			{
			}
			asio::io_service io_service_;
			std::map<unsigned short, boost::shared_ptr<tcp_server> > servers_;
			boost::shared_ptr<tcp_client> clients_;
			boost::shared_ptr<thread> proactor_thread_;
			boost::shared_ptr<asio::io_service::work> work_;
		};
		tcp_proactor::tcp_proactor():impl_(new tcp_proactor::tcp_proactor_impl)
		{
			impl_->proactor_thread_ = shared_ptr<boost::thread>(new boost::thread(boost::bind(&tcp_proactor::run, this)));
		}
		tcp_proactor::~tcp_proactor()
		{
			stop();
		}
		void tcp_proactor::run()
		{
			impl_->io_service_.run();
		}
        void tcp_proactor::do_stop()
        {
            std::map<unsigned short, shared_ptr<tcp_server> >::iterator it = impl_->servers_.begin();
            for(;it!=impl_->servers_.end();++it)
            {
                if(it->second)it->second->closeAll();
            }
            impl_->clients_->closeAll();
            impl_->io_service_.post(boost::bind(&boost::asio::io_service::stop,&impl_->io_service_));
        }
        void tcp_proactor::stop()
        {
            post(boost::bind(&tcp_proactor::do_stop,this));
            impl_->work_.reset();
			try {impl_->proactor_thread_->join();}catch(...){}
        }
		void tcp_proactor::stop_listen(unsigned short port)
		{
			SWITCH_THREAD(&tcp_proactor::stop_listen, port);
			if(impl_->servers_.find(port)==impl_->servers_.end())return;
			impl_->servers_[port]->stop_listen();
		}

		void tcp_proactor::post( boost::function<void()>cmd )
		{
			impl_->io_service_.post(cmd);
		}

		void tcp_proactor::connect( std::string host,std::string port,shared_ptr<CStreamBase>object )
		{
            impl_->clients_->init(host,port,object,impl_->io_service_);
		}

		void tcp_proactor::timed_connect( int timeoutMs, std::string host,std::string port,boost::shared_ptr<CStreamBase>object )
		{
			impl_->clients_->init(timeoutMs, host,port,object,impl_->io_service_);
		}

        bool tcp_proactor::is_in_work_thread()
        {
            return (impl_->proactor_thread_->get_id() == boost::this_thread::get_id());
        }

        void tcp_proactor::set_timer( int ms,boost::function<void()> cmd )
        {
			shared_ptr<steady_timer> timer_key(new steady_timer(impl_->io_service_));
			timer_key->expires_from_now(boost::chrono::milliseconds(ms));
            timer_key->async_wait(bind_s(&tcp_proactor::handle_timer,this,timer_key,cmd,_1));
        }

        void tcp_proactor::handle_timer( shared_ptr<steady_timer> time_key, boost::function<void()> cmd, const error_code& e )
        {
			if(time_key)
			{
				if(!e)cmd();
			}
        }

		act_post_cmd tcp_proactor::get_post_cmd()
		{
			return boost::bind(&tcp_proactor::post,this,_1);
		}

		thread_teller_cmd tcp_proactor::get_thread_tell_cmd()
		{
			return boost::bind(&tcp_proactor::is_in_work_thread, this);
		}

		unsigned short tcp_proactor::start_listen(int port, boost::function<boost::shared_ptr<CStreamBase>()> cmd)
		{
			boost::shared_ptr<tcp_server> obj(new tcp_server(port,impl_->io_service_, cmd));
			unsigned short realport = obj->get_listen_port();
			impl_->servers_[realport] = obj;
			return realport;
		}

		asio::io_service& epSocketNormal::get_io_service()
		{
			return socket_.get_io_service();
		}
		void epSocketNormal::post(boost::function<void()> cmd)
		{
			get_io_service().post(cmd);
		}
		void epSocketNormal::async_write( std::string& buf, boost::function<void(const error_code&, std::size_t)> cmd )
		{
			asio::async_write(socket_, asio::buffer(buf), boost::bind(&boost::function<void(const error_code&, std::size_t)>::operator(), cmd,_1,_2 ));
		}

		void epSocketNormal::async_read_some( asio::mutable_buffers_1 const &buf, boost::function<void(const error_code&, std::size_t)> cmd )
		{
			socket_.async_read_some(buf, cmd);
		}

		void epSocketNormal::async_connect( tcp::endpoint const& endpt, boost::function<void(const error_code&)> cmd )
		{
			socket_.async_connect(endpt,cmd);
		}

		void epSocketNormal::shutdown()
		{
			boost::system::error_code er;//avoid exception
			socket_.shutdown(asio::ip::tcp::socket::shutdown_both,er);
			socket_.close(er);
		}

		void epSocketNormal::async_accept( tcp::acceptor &tmpAcceptor, boost::function<void(const error_code&,int)>cmd )
		{
			boost::function<void(const error_code)> cmd2 = boost::bind(&boost::function<void(const error_code&,int)>::operator(),cmd,_1,0);
			tmpAcceptor.async_accept(socket_,cmd2);
		}

		boost::function<void(boost::function<void()>) > epSocketNormal::get_post_command()
		{
			return boost::bind(&epSocketNormal::post, this, _1);
		}

        std::string epSocketNormal::get_host_ip()
        {
            return socket_.local_endpoint().address().to_string();
        }

		void tcp_stream_ctrl::set_timer( shared_ptr<epSocket> key,int ms,boost::function<void()> cmd )
		{
			if(vstreams_.find(key)==vstreams_.end())return;
			shared_ptr<steady_timer> timer_key(new steady_timer(key->get_io_service()));
			timer_key->expires_from_now(boost::chrono::milliseconds(ms));
            timer_key->async_wait(bind_s(&tcp_stream_ctrl::handle_timer,this,key,timer_key,cmd,_1));
		}

		void tcp_stream_ctrl::handle_timer( shared_ptr<epSocket> key, shared_ptr<steady_timer> time_key, boost::function<void()> cmd, const error_code& e )
		{
			if(time_key)
			{
				if(vstreams_.find(key)==vstreams_.end())return;
				if(!e)cmd();
			}
		}

		void tcp_stream_ctrl::do_write( shared_ptr<epSocket> key, shared_ptr<std::string> buffer )
		{
			if(vstreams_.find(key)==vstreams_.end())return;
            key->async_write(*buffer, bind_s(&tcp_stream_ctrl::handle_write, this,key, buffer, asio::placeholders::error, asio::placeholders::bytes_transferred));
		}

		void tcp_stream_ctrl::do_close( shared_ptr<epSocket> key )
		{
			if(vstreams_.find(key)==vstreams_.end())return;
			const shared_ptr<CStreamBase>& epstream = vstreams_[key].get<0>();
			epstream->handle_close();
			key->shutdown();
            vstreams_.erase(key);
		}

		void tcp_stream_ctrl::do_action(shared_ptr<epSocket> key, stream_action act)
		{
            if(vstreams_.find(key)==vstreams_.end())return;
            if(!act.jobj)return;
            std::string command = act.jobj["command"].get<string>();
            if(command=="post")
            {
                act.cmd();
            }
            else if(command == "write")
            {
                do_write(key, make_shared_ptr(act.jobj["to_write"].get<string>()));
            }
            else if(command ==  "set_timer")
            {
                set_timer(key,act.jobj["interval"].get<int>(),act.cmd);
            }
            else if(command == "close")
            {
                do_close(key);
            }
            else
            {
                //unknown command
            }
		}

		void tcp_stream_ctrl::handle_read( shared_ptr<epSocket> key,const error_code& error,std::size_t bytes_transferred )
		{
			if(vstreams_.find(key)==vstreams_.end())return;
			if (!error)
			{
				vstreams_[key].get<0>()->handle_read(std::string(vstreams_[key].get<1>().begin(),bytes_transferred));
				key->async_read_some(asio::buffer(vstreams_[key].get<1>()),bind_s(&tcp_stream_ctrl::handle_read, this, key, asio::placeholders::error,asio::placeholders::bytes_transferred));
			}
			else
			{
				if(vstreams_[key].get<0>()->handle_read_fail(error))
				{
					do_close(key);
				}
			}
		}

		void tcp_stream_ctrl::handle_write( shared_ptr<epSocket> key,shared_ptr<std::string> to_write_str,const error_code& error, std::size_t bytes_transferred )
		{
			if(vstreams_.find(key)==vstreams_.end()) return;
			if(error)
			{
				if (vstreams_[key].get<0>()->handle_write_fail(error))
				{
					do_close(key);
				}
			}
			else
			{
				vstreams_[key].get<0>()->handle_write(bytes_transferred);
				assert(bytes_transferred == to_write_str->length());
			}
		}
        void tcp_stream_ctrl::closeAll()
        {
            typedef this_stream_type::iterator ittype;
            ittype it = vstreams_.begin();
            for(;it!=vstreams_.end();++it)
            {
                shared_ptr<epSocket> key = it->first;
                const shared_ptr<CStreamBase>& epstream = it->second.get<0>();
                epstream->handle_close();
                key->shutdown();
            }
        }

		tcp_stream_ctrl::~tcp_stream_ctrl()
		{
		}

		tcp_server::tcp_server(int port,asio::io_service& ioService, boost::function<boost::shared_ptr<CStreamBase>()> cmd)
			:io_service_(ioService),acceptor_(ioService,tcp::endpoint(tcp::v4(),port),false),stream_creator_(cmd)//false to avoid port reuse
		{
			shared_ptr<epSocket> key(new epSocketNormal(io_service_));
			init(key);
		}

		void tcp_server::init( shared_ptr<epSocket> key )
		{
			this->vstreams_[key].get<0>() = stream_creator_();
			this->vstreams_[key].get<0>()->setActionCmd(make_shared_ptr(thread_switch::CmdWrapper(key->get_post_command(),bind_s(&tcp_stream_ctrl::do_action,this,key,_1))));
			key->async_accept(acceptor_, bind_s(&tcp_server::handle_accept, this, key, asio::placeholders::error, _2));
		}
		//here we use a delay_success trick: 0, all code run, 1, stream not ready, 2, stream ready and no need to accept again.

		void tcp_server::handle_accept( shared_ptr<epSocket> key, const error_code& error, int delay_success )
		{
			if(this->vstreams_.find(key)==this->vstreams_.end()) 
			{
				shared_ptr<epSocket> newkey(key->clone());
				init(newkey);
				return;
			}
			if(error)
			{
				shared_ptr<epSocket> newkey(key->clone());
				if(this->vstreams_[key].get<0>()->handle_accept_fail(error))
				{
					this->do_close(key);
				}
				init(newkey);
				return;
			}
			if(delay_success != 1)
			{
				this->vstreams_[key].get<0>()->handle_accept(key);
				key->async_read_some(asio::buffer(this->vstreams_[key].get<1>()),bind_s(&tcp_stream_ctrl::handle_read, this, key, asio::placeholders::error,asio::placeholders::bytes_transferred));
			}
			if(delay_success != 2)
			{
				shared_ptr<epSocket> newkey(key->clone());
				init(newkey);
			}
		}

		void tcp_server::stop_listen()
		{
			acceptor_.close();
		}

		tcp_client::tcp_client()
		{
		}

		void tcp_client::handle_resolve(shared_ptr<epSocket> key,boost::shared_ptr<tcp::resolver>,const boost::system::error_code& error,tcp::resolver::iterator endpoint_iterator)
		{
			if (!error)
			{
				tcp::endpoint endpoint = *endpoint_iterator;
				key->async_connect(endpoint,bind_s(&tcp_client::handle_connect,this,key,asio::placeholders::error,++endpoint_iterator));
			}
			else
			{
				if(this->vstreams_.find(key)==this->vstreams_.end())return;
				if(this->vstreams_[key].get<0>()->handle_accept_fail(error))
				{
					do_close(key);
				}
			}
		}

		void tcp_client::init(std::string const& strIp, std::string const& port, const shared_ptr<CStreamBase>& obj, asio::io_service& ioService)
		{
            shared_ptr<epSocket> key(new epSocketNormal(ioService));
			vstreams_[key].get<0>() = obj;
            obj->setActionCmd(make_shared_ptr(thread_switch::CmdWrapper(key->get_post_command(),bind_s(&tcp_stream_ctrl::do_action,this,key,_1))));
			tcp::resolver::query query(strIp, port);
            boost::shared_ptr<tcp::resolver> resolver_var(new tcp::resolver(ioService));//boost::make_shared<tcp::resolver>(ioService);
			resolver_var->async_resolve(query,bind_s(&tcp_client::handle_resolve, this, key,resolver_var, asio::placeholders::error, boost::asio::placeholders::iterator));
		}

		void tcp_client::init(int timeoutMs, std::string const& strIp, std::string const& port, const shared_ptr<CStreamBase>& obj, asio::io_service& ioService)
		{
			shared_ptr<epSocket> key(new epSocketNormal(ioService));
			vstreams_[key].get<0>() = obj;
			obj->setActionCmd(make_shared_ptr(thread_switch::CmdWrapper(key->get_post_command(),bind_s(&tcp_stream_ctrl::do_action,this,key,_1))));
			tcp::resolver::query query(strIp, port);
			boost::shared_ptr<tcp::resolver> resolver_var(new tcp::resolver(ioService));//boost::make_shared<tcp::resolver>(ioService);
			resolver_var->async_resolve(query,bind_s(&tcp_client::handle_resolve, this, key,resolver_var, asio::placeholders::error, boost::asio::placeholders::iterator));
			error_code timeout_err = make_error_code(boost::system::errc::stream_timeout);
			set_timer(key, timeoutMs, boost::bind(&tcp_client::handle_connect, this, key, timeout_err, tcp::resolver::iterator()));
		}
		void tcp_client::handle_connect(shared_ptr<epSocket> key, const error_code& error,tcp::resolver::iterator endpoint_iterator)
		{
			//when timeout come first, !error come second, then vstreams will have no key, and will just return.
			//when !error come first and timeout come second, we need to ignore timeout error
			if (!error)
			{
				if(this->vstreams_.find(key)==this->vstreams_.end())return;
				this->vstreams_[key].get<2>() = "connected";//mark a flag so we can ignore timeout event
				this->vstreams_[key].get<0>()->handle_accept(key);
				key->async_read_some(asio::buffer(this->vstreams_[key].get<1>()),bind_s(&tcp_stream_ctrl::handle_read, this, key, asio::placeholders::error,asio::placeholders::bytes_transferred));
			}
			else if (endpoint_iterator != tcp::resolver::iterator())
			{
				key->shutdown();
				tcp::endpoint endpoint = *endpoint_iterator;
				key->async_connect(endpoint,bind_s(&tcp_client::handle_connect, this, key, asio::placeholders::error, ++endpoint_iterator));
			}
			else
			{
				if(this->vstreams_.find(key)==this->vstreams_.end())return;
				if(error.value() == boost::system::errc::stream_timeout && this->vstreams_[key].get<2>() == "connected")
				{
					return;
				}
				if(this->vstreams_[key].get<0>()->handle_accept_fail(error))
				{
					do_close(key);
				}
			}
		}

		shared_ptr<epSocket> tcp_client::clntSocket()
		{
			if(this->vstreams_.empty())return shared_ptr<epSocket>();
			return this->vstreams_.begin()->first;
		}

	}
}
