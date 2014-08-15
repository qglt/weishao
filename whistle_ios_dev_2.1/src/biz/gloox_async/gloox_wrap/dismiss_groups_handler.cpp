#include "dismiss_groups_handler.h"
#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include "glooxWrapInterface.h"
#include "../gloox_src/error.h"
namespace gloox
{


	DismissGroupsHandler::DismissGroupsHandler( Result_Callback callback ):callback_(callback)
	{

	}

	bool DismissGroupsHandler::handleIq( const IQ& iq )
	{
		return true;
	}
	/*
	　<iq type=’result’ from=’112@groups.ruijie.com.cn’ to=’123456@ruijie.com.cn’>
　　	<query xmlns=’groups:dismiss’>
　　		<item name=’吃货群’ />
　　</query>
　　</iq>
	*/
	void DismissGroupsHandler::handleIqID( const IQ& iq, int context )
	{
		json::jobject jobj;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			const Error* e = iq.error();
			if (!e)
			{
				callback_(true,XL("biz.DismissGroups.fail"));
				return;
			}
			if ( e->error() == StanzaErrorBadRequest)
			{
				ELOG("app")->error(WCOOL(L"解散群时，请求协议错误！。"));
				callback_(true,XL("biz.crwod.iq_error.bad-request"));
			}
			else if (e->error() == StanzaErrorInternalServerError)
			{
				ELOG("app")->error(WCOOL(L"解散群时，处理错误(服务器处理错误)。"));
				callback_(true,XL("biz.crwod.iq_error.internal-server-error"));
			}
			else if (e->error() == StanzaErrorForbidden)
			{
				ELOG("app")->error(WCOOL(L"解散群时，不是超级管理员"));
				callback_(true,XL("biz.crwod.iq_error.dismiss_forbidden"));
			}			
			else if (e->error() == StanzaErrorNotAllowed)
			{
				ELOG("app")->error(WCOOL(L"解散群时，群组不可解散"));
				callback_(true,XL("biz.crwod.iq_error.dismiss_not-allowed"));
			}
			else if (e->error() == StanzaErrorItemNotFound)
			{
				ELOG("app")->error(WCOOL(L"解散群时，找不到此群。"));
				callback_(true,XL("biz.crwod.iq_error.item-not-found"));
			}else
			{
				ELOG("app")->error(WCOOL(L"解散群时,服务器返回未知错误类型！") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
				callback_(true,XL("biz.DismissGroups.fail"));
			}
		}else{
			callback_(false,XL(""));		
		}
	}

}