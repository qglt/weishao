#include "get_groups_recent_messages_handler.h"
#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include "glooxWrapInterface.h"
namespace gloox
{


	GetGroupsRecentMessagesHandler::GetGroupsRecentMessagesHandler()
	{

	}

	bool GetGroupsRecentMessagesHandler::handleIq( const IQ& iq )
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
	void GetGroupsRecentMessagesHandler::handleIqID( const IQ& iq, int context )
	{
		json::jobject jobj;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			universal_resource error_group;
			ELOG("app")->error(WCOOL(L"获取群最近消息时服务端返回错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
			error_group = XL("biz.GetGroupsRecentMessages.fail");
		}
	}

}