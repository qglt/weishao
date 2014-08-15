#include "quit_groups_handler.h"
#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include "../gloox_src/error.h"
#include "glooxWrapInterface.h"
namespace gloox
{
	QuitGroupsHandler::QuitGroupsHandler( Result_Callback callback ):callback_(callback)
	{
	}
	bool QuitGroupsHandler::handleIq( const IQ& iq )
	{
		//自己通知群减少
		json::jobject remove;
		remove["session_id"]=iq.from().bare();
		remove["type"]="quit";
		gWrapInterface::instance().groups_list_change(remove);
		return true;
	}
	/*
	　<iq type=’result’ from=’112@groups.ruijie.com.cn’ to=’123456@ruijie.com.cn’>
　　 	<query xmlns=’groups: member:quit’>
　　		<item jid=” 123456@ruijie.com.cn” 
　　name=’奥巴马’ icon=’icon_url’/>
　　</query>
　　</iq>
	*/
	void QuitGroupsHandler::handleIqID( const IQ& iq, int context )
	{
		json::jobject jobj;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			const Error* e = iq.error();
			if (!e)
			{
				callback_(true,XL("biz.QuitGroups.fail"));
				return;
			}
			if ( e->error() == StanzaErrorBadRequest)
			{
				ELOG("app")->error(WCOOL(L"退出群时发生错误，请求协议错误！。"));
				callback_(true,XL("biz.crwod.iq_error.bad-request"));
			}
			else if (e->error() == StanzaErrorInternalServerError)
			{
				ELOG("app")->error(WCOOL(L"退出群时发生错误，处理错误(服务器处理错误)。"));
				callback_(true,XL("biz.crwod.iq_error.internal-server-error"));
			}
			else if (e->error() == StanzaErrorForbidden)
			{
				ELOG("app")->error(WCOOL(L"退出群时发生错误，不是该群成员"));
				callback_(true,XL("biz.crwod.iq_error.quit_forbidden"));
			}			
			else if (e->error() == StanzaErrorNotAllowed)
			{
				ELOG("app")->error(WCOOL(L"退出群时发生错误，管理员不允许退出群组"));
				callback_(true,XL("biz.crwod.iq_error.quit_not-allowed"));
			}
			else if (e->error() == StanzaErrorItemNotFound)
			{
				ELOG("app")->error(WCOOL(L"退出群时发生错误，找不到此群。"));
				callback_(true,XL("biz.crwod.iq_error.item-not-found"));
			}else
			{
				ELOG("app")->error(WCOOL(L"退出群时发生错误,服务器返回未知错误类型！") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
				callback_(true,XL("biz.QuitGroups.fail"));
			}

		}else{

			//自己通知群减少
			json::jobject remove;
			remove["crowd_info"]["session_id"]=iq.from().bare();
			remove["session_id"]=iq.from().bare();
			remove["type"]="quit";
			gWrapInterface::instance().groups_list_change(remove);

			callback_(false,XL(""));		
		}
	}

}