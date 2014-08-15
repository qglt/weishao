//---------------------------------------------------
// Copyright (C) 2012, All rights reserved
//
// descrption: entrypoint file.
// ver: 2.0
// auther: majiazhi
// date: (YMD)2012/07/04
//---------------------------------------------------

#pragma once

#include "boost/function.hpp"
#include "boost/shared_ptr.hpp"
#include <string>
#include "anan_type.h"
#include "notice_msg.h"

namespace biz {

struct anan_biz_impl;
class LocalConfig;
class login;
class agent;
class AnRosterManager;
class conversation;
class anan_private;
class user;
class organization;

class anan_biz
{
public:
	anan_biz(void);
	virtual ~anan_biz(void);
public:
	LocalConfig& get_localconfig();
	login& get_login();
	agent& get_agent();
	conversation& get_conversation();
	AnRosterManager& get_roster();
    anan_private& get_private();
	user& get_user();
	organization& get_org();
	notice_msg& get_notice();
public:
	boost::shared_ptr<anan_biz_impl> impl_;
};

}; // biz
