//---------------------------------------------------
// Copyright (C) 2012, All rights reserved
//
// descrption: entrypoint file.
// ver: 2.0
// auther: majiazhi
// date: (YMD)2012/07/04
//---------------------------------------------------
#pragma once
#include "boost/shared_ptr.hpp"
#include "anan_type.h"
#include "base/cmd_wrapper/command_wrapper.h"
#include "base/tcpproactor/TcpProactor.h"

namespace gloox {};
namespace epius
{
	namespace proactor
	{
		class tcp_proactor;
	}
}

namespace biz {
	using namespace gloox;
    class AnClient;
    class AnRosterManager;
    class BizGroups;
    class agent;
    class login;
    class conversation;
    class user;
    class LocalConfig;
	class AsynTasks;
    class anan_private;
	class multipart_http_op;
	class organization;
	class notice_msg;
	class biz_recent_contact;

struct anan_biz_impl
{
	anan_biz_impl();
	int only_inc_times_;
	AnClient * bizClient_;
	AnRosterManager * bizRoster_;
	conversation* bizConversation_;
	boost::shared_ptr<BizGroups> bizGroups_;
	boost::shared_ptr<biz_recent_contact> bizRecent_;
	boost::shared_ptr<agent> bizAgent_;
	boost::shared_ptr<login> bizLogin_;
	boost::shared_ptr<user> bizUser_;
	boost::shared_ptr<organization> bizOrg_;
	boost::shared_ptr<notice_msg> bizNotice_;
	boost::shared_ptr<LocalConfig> bizLocalConfig_;
    boost::shared_ptr<anan_private> bizAnanPrivate_;
	boost::shared_ptr<epius::proactor::tcp_proactor> _p_private_task_; // 必须加在最后。
	template<class FunType>
	FunType wrap(FunType fun)
	{
		return epius::thread_switch::CmdWrapper(_p_private_task_->get_post_cmd(),fun);
	}
};

}; //biz
