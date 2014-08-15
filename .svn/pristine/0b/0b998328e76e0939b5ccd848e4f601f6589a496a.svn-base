#pragma once
#include <string>
#include <boost/function.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/signal.hpp>
#include <boost/signals/trackable.hpp>

#include "../gloox_src/connectionbase.h"
#include <base/tcpproactor/StreamBase.h>
#include <base/tcpproactor/TcpProactor.h>

namespace epius
{
    namespace proactor
    {
        class GlooxStream:public CStreamBase
        {
        public:
            GlooxStream();
            virtual void handle_read(std::string const& str);
            virtual bool handle_accept_fail(const boost::system::error_code& error);
            virtual bool handle_write_fail(const boost::system::error_code& error);
            virtual bool handle_read_fail(const boost::system::error_code& error);
            virtual void handle_close();
            virtual void handle_accept(shared_ptr<epSocket> key);
            void write(std::string const& str);
            boost::signal<void()> connect_signal;
            boost::signal<void(std::string const& str)> read_signal;
            boost::signal<void()> close_signal;
            int m_read_len;
            int m_write_len;
        };
    }
}
namespace gloox{
    class ConnectionDataHandler;
//     class LogSink;
class AsyncConnectionTcpClient :  public ConnectionBase, public boost::signals::trackable
{
public:
    AsyncConnectionTcpClient(epius::proactor::tcp_proactor & pro, ConnectionDataHandler* cdh, const std::string& server, int port = -1);
    ~AsyncConnectionTcpClient(void);
    virtual ConnectionError recv( int timeout = -1 );
    virtual bool send( const std::string& data );
    virtual ConnectionError receive();
    virtual void disconnect();
    virtual void getStatistics( long int &totalIn, long int &totalOut );
    virtual ConnectionError connect();
    virtual ConnectionBase* newInstance() const;
	virtual void cleanup();
    void handle_stream_connected();
    void handle_disconnect();
	void set_connect_timeout(int ms);
private:
	void do_reconnect();
private:
    AsyncConnectionTcpClient &operator=( const AsyncConnectionTcpClient & );
//     const LogSink& m_logInstance;
    boost::shared_ptr<epius::proactor::GlooxStream> m_stream;
    epius::proactor::tcp_proactor & proactor_;
	std::string extra_connect_state_;
	int connect_timeout_;
	int retry_times_;
};
}

