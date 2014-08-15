// json_test.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "../tinyjson.hpp"
#include "../jsonfile.hpp"
#include <iostream>
#include <base/log/elog/elog.h>
using namespace json;
using namespace std;

int _tmain(int argc, char* argv[])
{
	//test construct and assign value
	jobject obj;
	obj["test_string"] = "test_string";
	obj["test_int"] = 5;
	obj["test_float"] = 6.0;
	obj["test_bool"]=true;
	obj["test_array"][0] = 1;
	obj["test_array"][1] = 2;
	obj["test_array"][2] = 3;
	//test convert to string
	jobject obj2;
	obj2["kkk"] = "222";
	obj["kkk"] = obj2["kkk"];

	assert(obj2["kkk"] == obj["kkk"]);
	string str = obj.to_string();
	cout<<str<<endl;

	json::jobject ppp = obj["kkk"];
	string str2 = ppp.get<string>();
	cout<<str2<<endl;
	//test parser 
	jobject verifier(str);
	//test values is same as previous
	assert(verifier["test_string"].get<string>() == obj["test_string"].get<string>());
	assert(verifier["test_int"].get<int>() == obj["test_int"].get<int>());
	assert(verifier["test_float"].get<double>() == obj["test_float"].get<double>());
	assert(verifier["test_bool"].get<bool>() == obj["test_bool"].get<bool>());
	assert(verifier["test_array"][0].get<int>() == obj["test_array"][0].get<int>());
	assert(verifier["test_array"][1].get<int>() == obj["test_array"][1].get<int>());
	assert(verifier["test_array"][2].get<int>() == obj["test_array"][2].get<int>());
	//test data conversion

	assert(verifier["test_int"].get<string>()=="5");
	assert(verifier["test_float"].get<string>()=="6");
	string kankan = verifier["test_bool"].get<string>();
	assert(verifier["test_bool"].get<string>()=="1");
	assert(verifier["test_array"][0].get<string>()=="1");
	
    jobject jobj = from_file(L"antconfig.json");
    string kankan2 = jobj.to_string();
    assert(jobj["server"].get<string>()=="172.16.3.82");
    assert(jobj["domain"].get<string>()=="anan.jabber");
    assert(jobj["login_ui"]["start_page"].get<string>()=="../../src/html/pages/Login/login.html");
    assert(jobj["login_ui"]["default_size"]["x"].get<int>()==340);
	
    {
        jobject jobj;
        jobj["a"] = 1;
        jobj["b"] = 2;
        jobj["d"] = "d";
        jobj["c"] = "c";
        //if(jobj["hello"]["a"][0]){}
        cout<<jobj.to_string()<<endl;
    }


	std::string strfmt= "{		\
						\"log_init\":{				\
						\"appenders\":[			\
						{\"name\":\"app_appender\", \"destination\":\"./%s/app_info.log\", \"append_mode\":true},\
						{\"name\":\"json_appender\", \"destination\":\"./%s/json_info.log\", \"append_mode\":true},\
						{\"name\":\"jstune_appender\", \"destination\":\"./%s/jstune.log\", \"append_mode\":true},\
						{\"name\":\"network_appender\", \"destination\":\"./%s/network.log\", \"append_mode\":true}\
						],\
						\"elogs\":[\
						{\"name\":\"app\",\"filter\":0,\"log_appenders\":[\"app_appender\"]},\
						{\"name\":\"log_json\",\"filter\":0,\"log_appenders\":[\"app_appender\",\"json_appender\"]},\
						{\"name\":\"log_jstune\",\"filter\":0,\"log_appenders\":[\"app_appender\",\"jstune_appender\"]},\
						{\"name\":\"log_network\",\"filter\":0,\"log_appenders\":[\"app_appender\",\"network_appender\"]}\
						]\
						}}";

	std::string path;

	if(argc > 1) {
		std::string s = argv[1];
		path = s.substr(0, s.find_first_of("."));
	} else{
		path="log";
	}
	std::string kankan3 = boost::str(boost::format(strfmt)%path%path%path%path);
	json::jobject jobj33(kankan3);

	std::cout << "初始化日志库（" << path << "）...." << std::endl;
	json::jobject jobj4("{\"kkk\":null}");
	cout<<jobj4.to_string()<<endl;
	jobj4["kkk"][0] = "hello";
//	jobj4["kkk"][0][1] = "world";
	std::cout<<jobj4.to_string()<<endl;
	epius::elog_factory::instance().init(jobj33["log_init"]);
	ELOG("app")->debug("kick");

	return 0;
}

