#include "groups_role_apply_handler.h"
#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include "glooxWrapInterface.h"
#include "../gloox_src/error.h"
namespace gloox
{
	GroupsRoleApplyHandler::GroupsRoleApplyHandler( Result_Callback callback ):callback_(callback)
	{
	}
	bool GroupsRoleApplyHandler::handleIq( const IQ& iq )
	{
		return true;
	}
	void GroupsRoleApplyHandler::handleIqID( const IQ& iq, int context )
	{
		json::jobject jobj;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			const Error* e = iq.error();
			if (!e)
			{
				ELOG("app")->error(WCOOL(L"申请成为管理员时，服务器返回未知错误类型！") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
				callback_(true,XL("biz.GroupsRoleApply.fail"));
				return;
			}
			if ( e->error() == StanzaErrorBadRequest)
			{
				ELOG("app")->error(WCOOL(L"申请成为管理员时，请求协议错误！。"));
				callback_(true,XL("biz.crwod.iq_error.bad-request"));
			}
			else if (e->error() == StanzaErrorInternalServerError)
			{
				ELOG("app")->error(WCOOL(L"申请成为管理员时，处理错误(服务器处理错误)。"));
				callback_(true,XL("biz.crwod.iq_error.internal-server-error"));
			}
			else if (e->error() == StanzaErrorConflict)
			{
				ELOG("app")->error(WCOOL(L"应答加入群邀请时返回错误，该成员已加入群"));
				callback_(true,XL("biz.GroupsRoleApply.Conflict"));
			}
			else if (e->error() == StanzaErrorItemNotFound)
			{
				ELOG("app")->error(WCOOL(L"申请成为管理员时，找不到此群。"));
				callback_(true,XL("biz.crwod.iq_error.item-not-found"));
			}else
			{
				ELOG("app")->error(WCOOL(L"删申请成为管理员时，服务器返回未知错误类型！") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
				callback_(true,XL("biz.GroupsRoleApply.fail"));
			}
		}else{
			callback_(false,XL(""));		
		}
	}

}