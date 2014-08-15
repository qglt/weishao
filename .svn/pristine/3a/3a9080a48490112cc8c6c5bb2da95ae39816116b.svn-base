#include "change_discussions_name_handler.h"
#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include "glooxWrapInterface.h"
namespace gloox
{
	ChangeDiscussionsNameHandler::ChangeDiscussionsNameHandler( Result_Callback callback ):callback_(callback)
	{

	}

	bool ChangeDiscussionsNameHandler::handleIq( const IQ& iq )
	{
		return true;
	}

	void ChangeDiscussionsNameHandler::handleIqID( const IQ& iq, int context )
	{
		json::jobject jobj;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			universal_resource error_desc;
			ELOG("app")->error(WCOOL(L"讨论组改名时服务端返回错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
			error_desc = XL("biz.ChangeDiscussionsName.fail");
			callback_(true, error_desc);
		}
		else
		{
			callback_(false, XL(""));
		}
	}

}