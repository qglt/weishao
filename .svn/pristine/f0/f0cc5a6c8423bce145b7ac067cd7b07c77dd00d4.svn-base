// test_recv.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <iostream>
#include <base/json/tinyjson.hpp>
#include "../../eipc_rpc.h"
using namespace epius;
using namespace std;
void test(json::jobject jobj)
{
	string input_str = jobj["args"]["data"].get<string>(); 
	cout<<input_str<<endl;
	jobj["args"]["answer"] = "yes, i know you are "+ input_str;
	eipc_rpc::instance().callback(jobj);
}
int main(int argc, char* argv[ ]) 
{
	eipc_rpc::instance().init("test_p1");
	eipc_rpc::instance().on("do_test", boost::bind(&test,_1));
	eipc_rpc::instance().start();
	::system("pause");}