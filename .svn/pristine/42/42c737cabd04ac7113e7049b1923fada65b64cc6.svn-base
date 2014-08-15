// Server.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <base/tcpproactor/TcpProactor.h>
#include <base/tcpproactor/StreamBase.h>
#include <iostream>

using namespace epius::proactor;
using namespace std;
class ChatServer:public CStreamBase
{
public:
	bool handle_accept_fail(const boost::system::error_code& error){cout<<"accept failed"<<endl;return true;}
	bool handle_write_fail(const boost::system::error_code& error)
	{
		cout<<"write failed"<<endl;return true;
	}
	bool handle_read_fail(const boost::system::error_code& error){cout<<"read failed"<<endl;return true;}
	void handle_read(std::string const& str)
	{
		if(str == "bye")
		{
			write("byebye");
			cout<<""<<endl;
			close();
		}
		else
		{
			write(str + "feedback");
			cout<<str<<endl;
		}
	}
	void handle_accept(boost::shared_ptr<epSocket> key)
	{
		cout<<"client connected"<<endl;
		cout<<"your name?"<<endl;
		write("your name?");
	}
	void handle_timer(){}

};

int _tmain(int argc, _TCHAR* argv[])
{
	tcp_proactor actor;
	actor.start_listen<ChatServer>(5564);
	::system("pause");
	return 0;
}

