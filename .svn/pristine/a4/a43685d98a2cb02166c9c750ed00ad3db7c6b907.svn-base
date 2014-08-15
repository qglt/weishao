// test_send_file.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <fstream>
#include <vector>
#include <boost/bind.hpp>
#include <boost/algorithm/string/predicate.hpp>
#include <boost/algorithm/string/classification.hpp>
#include <boost/algorithm/string/split.hpp>
#include <base/tcpproactor/TcpProactor.h>
#include <base/tcpproactor/StreamBase.h>
#include <base/utility/singleton/singleton.hpp>


using namespace epius::proactor;
using namespace std;
struct SuperTransferImpl_Data
{

};
class SuperTransferImpl
{
public:
    SuperTransferImpl(){}
    void SendTo(std::string dest, std::string port, std::string filename);
    void Recieve(int port);
};
typedef boost::utility::singleton_holder<SuperTransferImpl> SuperTrans;

class SuperReciever:public epius::proactor::CStreamBase
{
    virtual bool handle_accept_fail(const boost::system::error_code& error){return true;}
    virtual bool handle_write_fail(const boost::system::error_code& error){return true;}
    virtual bool handle_read_fail(const boost::system::error_code& error){return true;}
    virtual void handle_write(std::size_t bytes_transferred){}
    virtual void handle_read(std::string const& str){}
    virtual void handle_accept(boost::shared_ptr<epSocket> key){}
    virtual void handle_close(){}
};
const int package_size = 1024*4;
int _tmain(int argc, _TCHAR* argv[])
{

    string user_cmd;
    getline(cin, user_cmd);
    while(user_cmd!="quit")
    {
        vector<string> cmd_parts;
        boost::split(cmd_parts, user_cmd, boost::algorithm::is_any_of(" \t"));
        if(cmd_parts[0] == "send"))
        {
            SuperTrans
        }
    }
	return 0;
}

