#include "groups_role_change_handler.h"
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
	GroupsRoleChangeHandler::GroupsRoleChangeHandler( Result_Callback callback ):callback_(callback)
	{
	}
	bool GroupsRoleChangeHandler::handleIq( const IQ& iq )
	{
		return true;
	}
/*
　　<iq type=’result’from=’112@groups.ruijie.com.cn’ to=’123456@ruijie.com.cn/pc’>
　　	<query xmlns=’groups:role:change’>
　　		<actor jid=”123456@ruijie.com.cn” name=”张三”nick_name=”天天甜甜” sex=”boy” icon=”icon_url” />
　　		<item jid=’654321@ruijie.com.cn’ name=’李四’ />
　　</query>
　　</iq>
*/
	void GroupsRoleChangeHandler::handleIqID( const IQ& iq, int context )
	{
		json::jobject jobj;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			const Error* e = iq.error();
			if (!e)
			{
				ELOG("app")->error(WCOOL(L"改变其他成员身份时服务端返回未知类型错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
				callback_(true,XL("biz.GroupsRoleChange.fail"));
				return;
			}
			if ( e->error() == StanzaErrorBadRequest)
			{
				ELOG("app")->error(WCOOL(L"超级管理员改变其他成员身份时，请求协议错误！。"));
				callback_(true,XL("biz.crwod.iq_error.bad-request"));
			}
			else if (e->error() == StanzaErrorInternalServerError)
			{
				ELOG("app")->error(WCOOL(L"超级管理员改变其他成员身份时，处理错误(服务器处理错误)。"));
				callback_(true,XL("biz.crwod.iq_error.internal-server-error"));
			}
			else if (e->error() == StanzaErrorForbidden)
			{
				ELOG("app")->error(WCOOL(L"超级管理员改变其他成员身份时，不是管理员"));
				callback_(true,XL("biz.crwod.iq_error.role_change_forbidden"));

			}
			else if (e->error() == StanzaErrorItemNotFound)
			{
				ELOG("app")->error(WCOOL(L"超级管理员改变其他成员身份时，找不到此群。"));
				callback_(true,XL("biz.crwod.iq_error.item-not-found"));
			}else
			{
				ELOG("app")->error(WCOOL(L"超级管理员改变其他成员身份时,服务器返回未知错误类型！") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
				callback_(true,XL("biz.GroupsRoleChange.fail"));
			}
		}else{
			callback_(false,XL(""));		
		}
	}

}