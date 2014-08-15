#include <boost/lexical_cast.hpp>

#include "AsyncConnectionTcpClient.h"
#include "../gloox_src/logsink.h"
#include <base/tcpproactor/TcpProactor.h>
#include <base/log/elog/elog.h>
#include <base/utility/bind2f/bind2f.hpp>
extern boost::shared_ptr<epius::elog> appLog;
extern boost::shared_ptr<epius::elog> jsonLog;
extern boost::shared_ptr<epius::elog> jstuneLog;
extern boost::shared_ptr<epius::elog> netLog;
using namespace std;
namespace gloox
{
    AsyncConnectionTcpClient::AsyncConnectionTcpClient(epius::proactor::tcp_proactor & pro, ConnectionDataHandler* cdh, 
        /*const LogSink& logInstance, */const std::string& server, int port ): 
         proactor_(pro), ConnectionBase(cdh)/*,  m_logInstance(logInstance)*/
        {
            m_server = server;
            m_port = port;
			connect_timeout_ = 3000;
			retry_times_ = 3;
        }

    AsyncConnectionTcpClient::~AsyncConnectionTcpClient( void )
    {

    }

    ConnectionBase* AsyncConnectionTcpClient::newInstance() const
    {
        return new AsyncConnectionTcpClient(proactor_, m_handler, m_server, m_port );
    }

    ConnectionError AsyncConnectionTcpClient::connect()
    {
        if(!proactor_.is_in_work_thread())proactor_.post(bind_vs(&AsyncConnectionTcpClient::connect,this));
        if(m_state!=StateDisconnected)
        {
//             m_logInstance.err( LogAreaClassConnectionTCPClient,"try to connect a stream not in disconnected" );
            return ConnStreamError;
        }
        m_state = StateConnecting;
        m_stream.reset(new epius::proactor::GlooxStream);
        m_stream->connect_signal.connect(bind_s(&AsyncConnectionTcpClient::handle_stream_connected, this));
        m_stream->read_signal.connect(bind_s(&ConnectionDataHandler::handleReceivedData,m_handler, this, _1));
        m_stream->close_signal.connect(bind_s(&AsyncConnectionTcpClient::handle_disconnect,this));
        proactor_.timed_connect(connect_timeout_,m_server,boost::lexical_cast<std::string>(m_port),m_stream);
        return ConnNoError;
    }

    gloox::ConnectionError AsyncConnectionTcpClient::receive()
    {
        return ConnNoError;
    }

    void AsyncConnectionTcpClient::disconnect()
    {
		m_stream->read_signal.disconnect_all_slots();
        if(m_stream)m_stream->close();
    }

    void AsyncConnectionTcpClient::getStatistics( long int &totalIn, long int &totalOut )
    {
        if(!m_stream)return;
        totalIn = m_stream->m_read_len;
        totalOut = m_stream->m_write_len;
    }

    gloox::ConnectionError AsyncConnectionTcpClient::recv( int timeout /*= -1 */ )
    {
         return ConnNoError;
    }

    bool AsyncConnectionTcpClient::send( const std::string& data )
    {
        if(m_stream)m_stream->write(data);
        return true;
    }

    void AsyncConnectionTcpClient::handle_stream_connected()
    {
        m_state = StateConnected;
        m_handler->handleConnect(this);
    }

	void AsyncConnectionTcpClient::do_reconnect()
	{
		extra_connect_state_ = "";
		proactor_.timed_connect(connect_timeout_,m_server,boost::lexical_cast<std::string>(m_port),m_stream);
	}

    void AsyncConnectionTcpClient::handle_disconnect()
    {
		if(extra_connect_state_ == "waiting_next_connect")
		{
			return;
		}
        if(m_state == StateConnecting && retry_times_ >0)
		{
			extra_connect_state_ = "waiting_next_connect";
			--retry_times_;
			proactor_.set_timer(2000, bind_s(&AsyncConnectionTcpClient::do_reconnect, this));
		}
		else
		{
			m_state = StateDisconnected;
			m_handler->handleDisconnect(this, ConnNotConnected);
		}
    }

	void AsyncConnectionTcpClient::cleanup()
	{
		m_state = StateDisconnected;
	}

	void AsyncConnectionTcpClient::set_connect_timeout( int ms )
	{
		connect_timeout_ = ms;
	}

}

void epius::proactor::GlooxStream::handle_read( std::string const& str )
{
  //  ELOG("log_network")->debug("recv:\t" + str);
    m_read_len += str.length();
    read_signal(str);
}

bool epius::proactor::GlooxStream::handle_accept_fail( const boost::system::error_code& error )
{
    close_signal();
    return true;
}

bool epius::proactor::GlooxStream::handle_write_fail( const boost::system::error_code& error )
{
	close_signal();
    return true;
}

bool epius::proactor::GlooxStream::handle_read_fail( const boost::system::error_code& error )
{
    close_signal();
    return true;
}

void epius::proactor::GlooxStream::handle_accept( shared_ptr<epSocket> key )
{
    connect_signal();
}

void epius::proactor::GlooxStream::handle_close()
{
    ELOG("log_network")->debug("mygloox: stream closed");
    close_signal();
}

void epius::proactor::GlooxStream::write( std::string const& str )
{
   // ELOG("log_network")->debug("send:\t"+str);
    m_write_len += str.length();
    CStreamBase::write(str);
}

epius::proactor::GlooxStream::GlooxStream():m_read_len(0),m_write_len(0)
{

}
