#include "quit_discussions_handler.h"
#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include "glooxWrapInterface.h"
namespace gloox
{


	QuitDiscussionsHandler::QuitDiscussionsHandler( Result_Data_Callback callback ):callback_(callback)
	{

	}

	bool QuitDiscussionsHandler::handleIq( const IQ& iq )
	{
		if(iq.findExtension(kExtUser_iq_filter_quitdiscussions))
		{
			json::jobject jobj;
			jobj["type"] = "remove";
			json::jobject group;
			group["session_id"] = iq.from().bare();
			jobj["group_info"].arr_push(group);
			gWrapInterface::instance().discussions_list_change(jobj);
			return true;
		}

		ELOG("app")->error(WCOOL(L"退出讨论组时服务端返回的数据格式错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
		return false;
	}

	void QuitDiscussionsHandler::handleIqID( const IQ& iq, int context )
	{
		json::jobject jobj;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			universal_resource error_desc;
			ELOG("app")->error(WCOOL(L"退出讨论组时服务端返回错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
			error_desc = XL("biz.QuitDiscussions.fail");

			callback_(true, error_desc, jobj);
		}else{
			if(iq.findExtension(kExtUser_iq_filter_quitdiscussions))
			{
				callback_(false,XL(""),jobj);
				return;
			}
			ELOG("app")->error(WCOOL(L"退出讨论组时服务端返回的数据格式错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
			callback_(true, XL("biz.QuitDiscussions.fail"), jobj);
		}
	}

}