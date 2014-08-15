#include "send_file_msg_handler.h"
#include <base/log/elog/elog.h>
#include <base/txtutil/txtutil.h>

namespace gloox {
	SendFileMsgHandler::SendFileMsgHandler( boost::function<void(bool,universal_resource)> callback )
	{
		callback_ = callback;
	}

	bool SendFileMsgHandler::handleIq( const IQ& iq )
	{
		return true;
	}

	void SendFileMsgHandler::handleIqID( const IQ& iq, int context )
	{
		if (iq.m_subtype != gloox::IQ::Result)
		{
			universal_resource error_desc;
			ELOG("app")->error(WCOOL(L"发送文件消息错误") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
			error_desc = XL("biz.SendFileMsg.fail");

			callback_(true, error_desc);
		}else{
			callback_(false,XL(""));
			return;
		}
	}

}