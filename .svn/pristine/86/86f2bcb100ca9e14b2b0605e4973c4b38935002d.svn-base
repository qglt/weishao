// test_sender.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <iostream>
#include <base/json/tinyjson.hpp>
#include <base/utility/bind2f/bind2f.hpp>
#include "../../eipc_rpc.h"
#include "base/txtutil/txtutil.h"
using namespace epius;
using namespace std;

void print_log(std::string msg)
{
	wstring wmsg = epius::txtutil::convert_utf8_to_wcs(msg);
	wprintf(L"%s\n",wmsg.c_str());
	//wcout<<epius::txtutil::convert_utf8_to_wcs(msg)<<endl;
}
void test(json::jobject jobj)
{
	cout<<jobj["args"]["answer"].get<string>()<<endl;
}
void recv_event(json::jobject jobj)
{
}
void recv_msg(json::jobject jobj)
{
}
void recv_ping(json::jobject jobj)
{
	eipc_rpc::instance().callback(jobj);
}
string card_guid = "{7D54C7CB-7185-48EE-BD56-5867D157F55E}",service_name = "default";

void get_net_card_cb(json::jobject jobj)
{
	card_guid = jobj["card_list"][0]["card_guid"].get<string>();
}

void get_services_list_cb(json::jobject jobj)
{
	if(jobj["result"].get<string>()=="success")
	{
		service_name = jobj["service_list"][0].get<string>();
	}
	else
	{
		print_log("get service list failed");
	}
}

void get_net_card()
{
	json::jobject jobj;
	jobj["method"] = "get_net_card_list";
	eipc_rpc::instance().async_call("anan_platform",jobj,bind2f(&get_net_card_cb,_1));
}
void get_services_list()
{
	json::jobject jobj;
	jobj["method"] = "get_services_list";
	jobj["args"]["card_guid"] = card_guid;
	eipc_rpc::instance().async_call("anan_platform",jobj,bind2f(&get_services_list_cb,_1));
}
void connect_service_cb(json::jobject jobj)
{
}
void connect_service()
{
	json::jobject jobj;
	jobj["method"] = "connect_network";
	jobj["args"]["user_name"] = "yangcheng";
	jobj["args"]["user_passwd"] = "123123";
	jobj["args"]["card_uuid"] = card_guid;
	jobj["args"]["server"] = service_name;
	eipc_rpc::instance().async_call("anan_platform",jobj,bind2f(&connect_service_cb,_1));
}
void disconnect()
{
	json::jobject jobj;
	jobj["method"] = "disconnect_network";
	eipc_rpc::instance().async_call("anan_platform",jobj);
}

int main(int argc, char* argv[ ]) 
{
	eipc_rpc::instance().eipc_log_.connect(bind2f(&print_log,_1));
	eipc_rpc::instance().init("anan_application");
	eipc_rpc::instance().on("recv_event",boost::bind(&recv_event, _1));
	eipc_rpc::instance().on("recv_msg", boost::bind(&recv_msg, _1));
	eipc_rpc::instance().on("ping_anan", boost::bind(&recv_ping,_1));
	eipc_rpc::instance().start();

	string command;
	do 
	{
		cin>>command;
		if(command=="get_card")
		{
			get_net_card();
		}
		else if(command=="get_service")
		{
			get_services_list();
		}
		else if(command=="connect")
		{
			connect_service();
		}
		else if(command=="disconnect")
		{
			disconnect();
		}
	} 
	while (command!="quit");
	disconnect();
	::system("pause");	eipc_rpc::instance().stop();
}