#include "groups_role_demise_handler.h"
#include <base/log/elog/elog.h>
#include <base/time/time_format.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include <boost/lexical_cast.hpp>
#include <boost/date_time/gregorian/conversion.hpp>
#include "glooxWrapInterface.h"
#include "../gloox_src/error.h"

namespace gloox
{
	GroupsRoleDemiseHandler::GroupsRoleDemiseHandler( Result_Callback callback ):callback_(callback)
	{
	}
	bool GroupsRoleDemiseHandler::handleIq( const IQ& iq )
	{
		return true;
	}
	void GroupsRoleDemiseHandler::handleIqID( const IQ& iq, int context )
	{
		json::jobject jobj;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			const Error* e = iq.error();
			
			if (!e)
			{
				ELOG("app")->error(WCOOL(L"管理员转让身份时，服务端返回未知类型错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
				callback_(true,XL("biz.GroupsRoleDemise.fail"));
				return;
			}

			switch(e->error())
			{
			case StanzaErrorBadRequest:
				ELOG("app")->error(WCOOL(L"管理员转让身份时，请求协议错误！。"));
				callback_(true,XL("biz.crwod.iq_error.bad-request"));
				break;
			case StanzaErrorInternalServerError:
				ELOG("app")->error(WCOOL(L"管理员转让身份时，处理错误(服务器处理错误)。"));
				callback_(true,XL("biz.crwod.iq_error.internal-server-error"));
				break;
			case StanzaErrorResourceConstraint:
				ELOG("app")->error(WCOOL(L"管理员转让身份时，转让群失败，对方已达到创建群上限。"));
				callback_(true,XL("biz.crwod.iq_error.demise_resourceconstraint"));
				break;
			case StanzaErrorForbidden:
				ELOG("app")->error(WCOOL(L"管理员转让身份时，不是管理员"));
				callback_(true,XL("biz.crwod.iq_error.demise_forbidden"));
				break;
			case StanzaErrorNotAllowed:
				ELOG("app")->error(WCOOL(L"管理员转让身份时，被转让人不在群内"));
				callback_(true,XL("biz.crwod.iq_error.demise_notallowed"));
				break;
			case StanzaErrorItemNotFound:
				ELOG("app")->error(WCOOL(L"管理员转让身份时，找不到此群。"));
				callback_(true,XL("biz.crwod.iq_error.item-not-found"));
				break;
			default :
				ELOG("app")->error(WCOOL(L"管理员转让身份时,服务器返回未知错误类型！") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
				callback_(true,XL("biz.GroupsRoleDemise.fail"));
				break;
			}
		}else{
			callback_(false,XL(""));		
		}
	}

}