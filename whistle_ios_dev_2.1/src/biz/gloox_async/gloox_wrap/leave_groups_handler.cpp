#include "leave_groups_handler.h"
#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include "glooxWrapInterface.h"
namespace gloox
{


	LeaveGroupsHandler::LeaveGroupsHandler(  )
	{

	}

	bool LeaveGroupsHandler::handleIq( const IQ& iq )
	{
		return true;
	}
	/*
	　<iq type=’result from=’112@groups.ruijie.com.cn’ to=’123456@ruijie.com.cn/pc’>
	 <query xmlns=’ groups: member:leave’ >
	 </query>
	 </iq>

	*/
	void LeaveGroupsHandler::handleIqID( const IQ& iq, int context )
	{
/*
		json::jobject jobj;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			universal_resource error_groups;
			ELOG("app")->error(WCOOL(L"离开群通知不关心时服务端返回错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
			error_groups = XL("biz.LeaveGroups.fail");

			callback_(true, error_groups);
		}else{
			callback_(false,XL(""));		
		}*/
	}

}