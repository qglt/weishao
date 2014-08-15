//---------------------------------------------------
// Copyright (C) 2012, All rights reserved
//
// descrption: entrypoint file.
// ver: 2.0
// auther: majiazhi
// date: (YMD)2012/07/04
//---------------------------------------------------
#include <boost/bind.hpp>
#include "base/tcpproactor/TcpProactor.h"
#include "anan_biz.h"
#include "anan_biz_impl.h"
#include "an_roster_manager.h"
#include "base/cmd_wrapper/command_wrapper.h"
#include "base/tcpproactor/TcpProactor.h"
#include "login.h"
#include "agent.h"
#include "conversation.h"
#include "an_roster_manager.h"
#include "user.h"
#include "local_config.h"
#include "client_anan.h"
#include "anan_private.h"


namespace biz {
using namespace gloox;

anan_biz::anan_biz(void)
	: impl_(new anan_biz_impl())
{
}

anan_biz::~anan_biz(void)
{
	impl_->bizAgent_->uninit();
}

login& anan_biz::get_login()
{
	return *impl_->bizLogin_;
}

agent& anan_biz::get_agent()
{
	return *impl_->bizAgent_;
}

anan_private& anan_biz::get_private()
{
    return *impl_->bizAnanPrivate_;
}

conversation& anan_biz::get_conversation()
{
	return *impl_->bizConversation_;
}

AnRosterManager& anan_biz::get_roster()
{
	return *impl_->bizRoster_;
}

user& anan_biz::get_user()
{
    return *impl_->bizUser_;
}

organization& anan_biz::get_org()
{
	return *impl_->bizOrg_.get();
}

notice_msg& anan_biz::get_notice()
{
	return *impl_->bizNotice_.get();
}

LocalConfig& anan_biz::get_localconfig()
{
	return *impl_->bizLocalConfig_;
}

}; // biz