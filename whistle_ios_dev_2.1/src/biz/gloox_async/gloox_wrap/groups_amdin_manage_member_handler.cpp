#include "groups_amdin_manage_member_handler.h"
#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include "glooxWrapInterface.h"
#include "../gloox_src/error.h"
namespace gloox
{
	GroupsAdminManageMemberHandler::GroupsAdminManageMemberHandler( Result_Callback callback ):callback_(callback)
	{
	}

	bool GroupsAdminManageMemberHandler::handleIq( const IQ& iq )
	{
		return true;
	}

	void GroupsAdminManageMemberHandler::handleIqID( const IQ& iq, int context )
	{
		json::jobject jobj;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			const Error* e = iq.error();
			if (!e)
			{
				callback_(true,XL("biz.GroupsAdminManageMember.fail"));
				return;
			}
			if ( e->error() == StanzaErrorBadRequest)
			{
				ELOG("app")->error(WCOOL(L"管理员审批成员加入时，请求协议错误！。"));
				callback_(true,XL("biz.crwod.iq_error.bad-request"));
			}
			else if (e->error() == StanzaErrorInternalServerError)
			{
				ELOG("app")->error(WCOOL(L"管理员审批成员加入时，处理错误(服务器处理错误)。"));
				callback_(true,XL("biz.crwod.iq_error.internal-server-error"));
			}
			else if (e->error() == StanzaErrorGone)
			{
				universal_resource err;
				err.res_key="biz.crwod.iq_error.answer_apply_gone";
				ELOG("app")->error(WCOOL(L"管理员审批成员加入时，消息已过期！"));
				callback_(false,err);
			}
			else if (e->error() == StanzaErrorForbidden)
			{
				ELOG("app")->error(WCOOL(L"管理员审批成员加入时，自己不是管理员"));
				callback_(true,XL("biz.crwod.iq_error.admin_forbidden"));
			}			
			else if (e->error() == StanzaErrorResourceConstraint)
			{
				ELOG("app")->error(WCOOL(L"管理员审批成员加入时，群成员已经满"));
				callback_(true,XL("biz.crwod.iq_error.admin_resource-constraint"));
			}
			else if (e->error() == StanzaErrorConflict)
			{
				universal_resource err;
				err.res_key="biz.crwod.iq_error.admin_Conflict";
				ELOG("app")->error(WCOOL(L"管理员审批成员加入时，该成员已加入群"));
				callback_(false,err);
			}
			else if (e->error() == StanzaErrorItemNotFound)
			{
				ELOG("app")->error(WCOOL(L"管理员审批成员加入时，找不到此群。"));
				callback_(true,XL("biz.crwod.iq_error.item-not-found"));
			}else
			{
				ELOG("app")->error(WCOOL(L"管理员审批成员加入时,服务器返回未知错误类型！") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
				callback_(true,XL("biz.GroupsAdminManageMember.fail"));
			}

		}else{
			callback_(false,XL(""));		
		}
	}

}