#include "answer_groups_invite_handler.h"
#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include "../gloox_src/error.h"
#include "glooxWrapInterface.h"
namespace gloox
{
	AnswerGroupsInviteHandler::AnswerGroupsInviteHandler( Result_Callback callback ):callback_(callback)
	{
	}

	bool AnswerGroupsInviteHandler::handleIq( const IQ& iq )
	{
			return true;
	}
	/*
	　<iq type=’result’from=’112@groups.ruijie.com.cn’ to=’123456@ruijie.com.cn’>
	 <queryxmlns=’groups:member:info’>
	 <item id=‘112’alert=’1’ />
	 </query>
	 </iq>

	*/
	void AnswerGroupsInviteHandler::handleIqID( const IQ& iq, int context )
	{
		json::jobject jobj;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			const Error* e = iq.error();
			if (!e)
			{
				ELOG("app")->error(WCOOL(L"应答加入群邀请时返回未知格式错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
				callback_(true,XL("biz.AnswerGroupsInvite.fail"));
				return;
			}

			if ( e->error() == StanzaErrorBadRequest)
			{
				ELOG("app")->error(WCOOL(L"应答加入群邀请时返回错误，请求协议错误！。"));
				callback_(true,XL("biz.crwod.iq_error.bad-request"));
			}
			else if (e->error() == StanzaErrorInternalServerError)
			{
				ELOG("app")->error(WCOOL(L"应答加入群邀请时返回错误，处理错误(服务器处理错误)。"));
				callback_(true,XL("biz.crwod.iq_error.internal-server-error"));
			}
			else if (e->error() == StanzaErrorConflict)
			{
				universal_resource err;
				err.res_key="biz.crwod.iq_error.AnswerGroupsInvite_Conflict";
				ELOG("app")->error(WCOOL(L"应答加入群邀请时返回错误，该成员已加入群"));
				callback_(false,err);
			}
			else if (e->error() == StanzaErrorGone)
			{
				universal_resource err;
				err.res_key="biz.crwod.iq_error.answer_GroupsInvite_gone";
				ELOG("app")->error(WCOOL(L"应答加入群邀请时返回错误，消息已过期！"));
				callback_(false,err);
			}
			else if (e->error() == StanzaErrorResourceConstraint)
			{
				ELOG("app")->error(WCOOL(L"应答加入群邀请时返回错误，群成员已经满"));
				callback_(true,XL("biz.crwod.iq_error.admin_resource-constraint"));
			}
			else if (e->error() == StanzaErrorItemNotFound)
			{
				ELOG("app")->error(WCOOL(L"应答加入群邀请时返回错误，找不到此群。"));
				callback_(true,XL("biz.crwod.iq_error.item-not-found"));
			}else
			{
				ELOG("app")->error(WCOOL(L"应答加入群邀请时返回未知格式错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
				callback_(true,XL("biz.AnswerGroupsInvite.fail"));
			}
		}else{
			callback_(false,XL(""));		
		}
	}

}