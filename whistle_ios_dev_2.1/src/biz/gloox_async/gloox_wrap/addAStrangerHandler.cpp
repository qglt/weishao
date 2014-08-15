#include "addAStrangerHandler.h"
#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
namespace gloox
{
	addAStrangerHandler::addAStrangerHandler( Result_Callback callback ):callback_(callback)
	{

	}

	bool addAStrangerHandler::handleIq( const IQ& iq )
	{
		return true;
	}

	void addAStrangerHandler::handleIqID( const IQ& iq, int context )
	{
		json::jobject jobj;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			universal_resource error_desc;
			ELOG("app")->error(WCOOL(L"添加陌生人服务端返回错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
			error_desc = XL("biz.addAStrangerHandler.fail");
			callback_(true, error_desc);
		}
		else
		{
			callback_(false, XL(""));
		}
	}
}