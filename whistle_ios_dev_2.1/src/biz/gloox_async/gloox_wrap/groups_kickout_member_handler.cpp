#include "groups_kickout_member_handler.h"
#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include "glooxWrapInterface.h"
#include "../gloox_src/error.h"
namespace gloox
{
	GroupsKickoutMemberHandler::GroupsKickoutMemberHandler( Result_Callback callback ):callback_(callback)
	{
	}
	bool GroupsKickoutMemberHandler::handleIq( const IQ& iq )
	{
		return true;
	}
	/*
	　<iq type=’result’ from=’112@groups.ruijie.com.cn’ to=’123456@ruijie.com.cn/pc’>
　　 	<query xmlns=’groups: member:kickout’>
　　<actor jid=”123456@ruijie.com.cn” name=”张三” nick_name=”天天甜甜” sex=”boy” icon=”icon_url” />
　　		<item jid=’654321@groups.ruijie.com.cn’ name=’吃货群’ nick_name=’奥巴马’ icon=’icon_url’ />
　　</query>
　　</iq>
	*/
	void GroupsKickoutMemberHandler::handleIqID( const IQ& iq, int context )
	{
		json::jobject jobj;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			const Error* e = iq.error();
			if (!e)
			{
				callback_(true,XL("biz.GroupsKickoutMember.fail"));
				return;
			}
			if ( e->error() == StanzaErrorBadRequest)
			{
				ELOG("app")->error(WCOOL(L"群管理员踢出成员时，请求协议错误！。"));
				callback_(true,XL("biz.crwod.iq_error.bad-request"));
			}
			else if (e->error() == StanzaErrorInternalServerError)
			{
				ELOG("app")->error(WCOOL(L"群管理员踢出成员时，处理错误(服务器处理错误)。"));
				callback_(true,XL("biz.crwod.iq_error.internal-server-error"));
			}
			else if (e->error() == StanzaErrorForbidden)
			{
				ELOG("app")->error(WCOOL(L"群管理员踢出成员时，被踢的人不存在或是管理员"));
				callback_(true,XL("biz.crwod.iq_error.kick_forbidden"));
			}			
			else if (e->error() == StanzaErrorNotAllowed)
			{
				ELOG("app")->error(WCOOL(L"群管理员踢出成员时，不是管理员"));
				callback_(true,XL("biz.crwod.iq_error.kick_not-allowed"));
			}
			else if (e->error() == StanzaErrorItemNotFound)
			{
				ELOG("app")->error(WCOOL(L"群管理员踢出成员时，找不到此群。"));
				callback_(true,XL("biz.crwod.iq_error.item-not-found"));
			}else
			{
				ELOG("app")->error(WCOOL(L"群管理员踢出成员时,服务器返回未知错误类型！") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
				callback_(true,XL("biz.GroupsKickoutMember.fail"));
			}
		}else{
			callback_(false,XL(""));		
		}
	}

}