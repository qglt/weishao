#include "temporary_attention_handler.h"
#include <base/log/elog/elog.h>
#include <base/txtutil/txtutil.h>
namespace gloox {
	TemporaryAttentionHandler::TemporaryAttentionHandler( boost::function<void(bool,universal_resource)> callback )
	{
		callback_ = callback;
	}

	bool TemporaryAttentionHandler::handleIq( const IQ& iq )
	{
		return true;
	}

	void TemporaryAttentionHandler::handleIqID( const IQ& iq, int context )
	{
		if (iq.m_subtype != gloox::IQ::Result)
		{
			universal_resource error_desc;
			ELOG("app")->error(WCOOL(L"临时订阅或取消临时订阅错误") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
			error_desc = XL("biz.TemporaryAttention.fail");

			callback_(true, error_desc);
		}else{
			callback_(false,XL(""));
			return;
		}
	}

}