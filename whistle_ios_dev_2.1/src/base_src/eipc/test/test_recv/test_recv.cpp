// test_recv.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <iostream>
#include <base/json/tinyjson.hpp>
#include "../../eipc_rpc.h"
#include "base/txtutil/txtutil.h"
#include <base/utility/bind2f/bind2f.hpp>
using namespace epius;
using namespace std;

#define MY_IPC_NAME "test_recv"

void test(json::jobject jobj)
{
	string input_str = jobj["args"]["data"].get<string>(); 
	cout<<input_str<<endl;
	jobj["args"]["answer"] = "yes, i know you are "+ input_str;
	eipc_rpc::instance().callback(jobj);
}
void print_log(std::string msg)
{
	wstring wmsg = epius::txtutil::convert_utf8_to_wcs(msg);
	wprintf(L"%s\n",wmsg.c_str());
	//wcout<<epius::txtutil::convert_utf8_to_wcs(msg)<<endl;
}
int main(int argc, char* argv[ ]) 
{
	eipc_rpc::instance().eipc_log_.connect(bind2f(&print_log,_1));
	eipc_rpc::instance().init(MY_IPC_NAME);
	eipc_rpc::instance().on("do_test", boost::bind(&test,_1));
	eipc_rpc::instance().start();
	::system("pause");
}
