//---------------------------------------------------
// Copyright (C) 2012, All rights reserved
//
// descrption: entrypoint file.
// ver: 2.0
// auther: majiazhi
// date: (YMD)2012/07/04
//---------------------------------------------------

#pragma once

#include <string>
#include <boost/format.hpp>
#include <base/log/elog/elog.h>
#include "agent_type.h"
#include "gloox_src/AsyncConnectionTcpClient.h"
#include "gloox_src/loghandler.h"

using namespace epius;
namespace biz {

struct agent_impl
{
    struct gloox_log:public gloox::LogHandler
    {
        virtual void handleLog( LogLevel level, LogArea area, const std::string& message ) 
        {
            std::string mes_str = (boost::format("log-domain:%d, log-message:%s")%area%message).str();
            if(level == LogLevelDebug)
            {
                ELOG("log_network")->debug(mes_str);
            }
            else if(level == LogLevelWarning)
            {
                ELOG("log_network")->warn(mes_str);
            }
            else if(level ==  LogLevelError)
            {
                ELOG("log_network")->error(mes_str);
            }
        }
    };
	agent_impl()
	{
		conn0 = NULL;
		agent = 0;
		init_ = false;
        log_unit_ = new gloox_log;
	}

	~agent_impl()
	{
		assert(!conn0);
		agent = 0;
        delete log_unit_;
        log_unit_ = NULL;
	}
	int agent;
	//std::string update_uri;
	AsyncConnectionTcpClient* conn0;
	bool init_;
    gloox_log *log_unit_;
	bool autorun_;
};

}; // biz