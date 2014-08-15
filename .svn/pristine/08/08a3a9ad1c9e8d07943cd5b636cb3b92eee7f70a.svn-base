// Client.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <base/tcpproactor/TcpProactor.h>
#include <base/tcpproactor/StreamBase.h>
#include <iostream>
#include <vector>
#include <boost/foreach.hpp>
#include <boost/lexical_cast.hpp>
#include <base/json/tinyjson.hpp>

using namespace epius::proactor;
using namespace std;

class ChatClient:public CStreamBase
{
public:
	bool handle_accept_fail(const boost::system::error_code& error){cout<<"accept failed"<<endl;return true;}
	bool handle_write_fail(const boost::system::error_code& error)
	{
		int test = boost::lexical_cast<int>(L"1");
		int test2 = boost::lexical_cast<int>("2");
		cout<<"write failed"<<endl;return true;
	}
	bool handle_read_fail(const boost::system::error_code& error)
	{
		cout<<"read failed"<<endl;return true;
	}
	void handle_read(std::string const& str)
	{
		static int i=0;
		if(str == "byebye")
		{
			cout<<"byebye le"<<endl;
			close();
		}
		else if(str == "your name?")
		{
			cout<<"my name?....yangcheng"<<endl;
			write("yangcheng");
		}
		else
		{
			cout<<str<<endl;
			if(i<5)
			{
				//close();
				write("i love you");
				i++;
			}
			else
			{
				//write("bye");
			}
		}
	}
	void handle_accept(boost::shared_ptr<epSocket> key)
	{
		cout<<"connected to server"<<endl;
		write("hello server?");
	}
};

int _tmain(int argc, _TCHAR* argv[])
{
	tcp_proactor actor;
	{
		boost::shared_ptr<ChatClient> p(new ChatClient);
		actor.connect("127.0.0.1","5564",p);
		//::system("pause");
// 		p->write("kick your pp1");
// 		p->write("kick your pp2");
// 		p->write("kick your pp3");
		Sleep(2000);
	}
	::system("pause");
	return 0;
}

