#include "change_groups_member_info_handler.h"
#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include "../gloox_src/error.h"
#include "glooxWrapInterface.h"
namespace gloox
{


	ChangeGroupsMemberInfoHandler::ChangeGroupsMemberInfoHandler( Result_Callback callback ):callback_(callback)
	{

	}

	bool ChangeGroupsMemberInfoHandler::handleIq( const IQ& iq )
	{
		return true;
	}
	/*
	　<iq type=’result’from=’112@groups.ruijie.com.cn’ to=’123456@ruijie.com.cn’>
	 <queryxmlns=’groups:member:setting’>
	 <item id=‘112’alert=’1’ />
	 </query>
	 </iq>

	*/
	void ChangeGroupsMemberInfoHandler::handleIqID( const IQ& iq, int context )
	{
		json::jobject jobj;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			const Error* e = iq.error();
			if (!e)
			{
				callback_(true,XL("biz.ChangeGroupsMemberInfo.fail"));
				return;
			}

			if ( e->error() == StanzaErrorBadRequest)
			{
				ELOG("app")->error(WCOOL(L"修改群成员资料时服务端返回错误，请求协议错误！。"));
				callback_(true,XL("biz.crwod.iq_error.bad-request"));
			}
			else if (e->error() == StanzaErrorInternalServerError)
			{
				ELOG("app")->error(WCOOL(L"修改群成员资料时服务端返回错误，处理错误(服务器处理错误)。"));
				callback_(true,XL("biz.crwod.iq_error.internal-server-error"));
			}
			else if (e->error() == StanzaErrorItemNotFound)
			{
				ELOG("app")->error(WCOOL(L"修改群成员资料时服务端返回错误，找不到此群。"));
				callback_(true,XL("biz.crwod.iq_error.item-not-found"));
			}else
			{
				ELOG("app")->error(WCOOL(L"修改群成员资料时服务端返回错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
				callback_(true,XL("biz.ChangeGroupsMemberInfo.fail"));
			}
		}else{
			callback_(false,XL(""));		
		}
	}

}