#include "create_discussions_handler.h"
#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include "glooxWrapInterface.h"
namespace gloox
{


	CreateDiscussionsHandler::CreateDiscussionsHandler( Result_Data_Callback callback ):callback_(callback)
	{

	}

	bool CreateDiscussionsHandler::handleIq( const IQ& iq )
	{
		if(iq.findExtension(kExtUser_iq_filter_creatediscussions))
		{
			boost::shared_ptr<gloox::Tag> tag(iq.findExtension(kExtUser_iq_filter_creatediscussions)->tag());
			if (tag)
			{
				gloox::Tag* tag2 = tag->findChild("item");
				if (tag2)
				{
					json::jobject jobj;
					jobj["type"] = "add";
					json::jobject group;
					group["session_id"] = gWrapInterface::instance().append_discussions_domain(tag2->findAttribute("id"));
					group["group_name"] =  tag2->findAttribute("topic");
					jobj["group_info"].arr_push(group);
					gWrapInterface::instance().discussions_list_change(jobj);
					return true;
				}
			}
		}

		ELOG("app")->error(WCOOL(L"创建讨论组时服务端返回的数据格式错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
		return false;
	}

	void CreateDiscussionsHandler::handleIqID( const IQ& iq, int context )
	{
		json::jobject jobj;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			universal_resource error_desc;
			ELOG("app")->error(WCOOL(L"创建讨论组时服务端返回错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
			error_desc = XL("biz.CreateDiscussions.fail");

			callback_(true, error_desc, jobj);
		}else{
			if(iq.findExtension(kExtUser_iq_filter_creatediscussions))
			{
				boost::shared_ptr<gloox::Tag> tag(iq.findExtension(kExtUser_iq_filter_creatediscussions)->tag());
				if (tag)
				{
					gloox::Tag* tag2 = tag->findChild("item");
					if (tag)
					{
						jobj["session_id"] = gWrapInterface::instance().append_discussions_domain(tag2->findAttribute("id"));
						jobj["group_name"] = tag2->findAttribute("topic");

						callback_(false,XL(""),jobj);
						return;
					}
				}
			}
			ELOG("app")->error(WCOOL(L"创建讨论组时服务端返回的数据格式错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
			callback_(true, XL("biz.CreateDiscussions.fail"), jobj);
		}
	}

}