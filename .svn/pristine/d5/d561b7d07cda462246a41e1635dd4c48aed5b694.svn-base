#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include "glooxWrapInterface.h"
#include "../gloox_src/error.h"
#include "invite_into_groups_handler.h"
namespace gloox
{


	InviteIntoGroupsHandler::InviteIntoGroupsHandler( Result_Callback callback ):callback_(callback)
	{
	}

	bool InviteIntoGroupsHandler::handleIq( const IQ& iq )
	{
		return true;
	}
	/*
	　<iq type=’result’from=’112@groups.ruijie.com.cn’ to=’123456@ruijie.com.cn’>
	 <queryxmlns=’groups:share:file:delete’>
	 <item id=‘2’ />
	 </query>
	 </iq>
	*/
	void InviteIntoGroupsHandler::handleIqID( const IQ& iq, int context )
	{
		json::jobject jobj;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			const Error* e = iq.error();
			if (!e)
			{
				ELOG("app")->error(WCOOL(L"邀请加入群时，服务器返回未知错误类型！") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
				callback_(true,XL("biz.InviteIntoGroups.fail"));
				return;
			}

			if ( e->error() == StanzaErrorBadRequest)
			{
				ELOG("app")->error(WCOOL(L"邀请加入群时，请求协议错误！。"));
				callback_(true,XL("biz.crwod.iq_error.bad-request"));
			}
			else if (e->error() == StanzaErrorInternalServerError)
			{
				ELOG("app")->error(WCOOL(L"邀请加入群时，处理错误(服务器处理错误)。"));
				callback_(true,XL("biz.crwod.iq_error.internal-server-error"));
			}
			else if (e->error() == StanzaErrorConflict)
			{
				ELOG("app")->error(WCOOL(L"邀请加入群时，被邀请人已经在群里。"));
				callback_(true,XL("biz.crwod.iq_error.invite_conflict"));
			}
			else if (e->error() == StanzaErrorResourceConstraint)
			{
				ELOG("app")->error(WCOOL(L"邀请加入群时，群已经满员。"));
				callback_(true,XL("biz.crwod.iq_error.invite_resource-constraint"));
			}
			else if (e->error() == StanzaErrorNotAllowed)
			{
				ELOG("app")->error(WCOOL(L"邀请加入群时，邀请人不是管理员。"));
				callback_(true,XL("biz.crwod.iq_error.invite_not-allowed"));
			}else
			{
				ELOG("app")->error(WCOOL(L"邀请加入群时，服务器返回未知错误类型！") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
				callback_(true,XL("biz.InviteIntoGroups.fail"));
			}
		}else{
			callback_(false,XL(""));
		}
	}

}