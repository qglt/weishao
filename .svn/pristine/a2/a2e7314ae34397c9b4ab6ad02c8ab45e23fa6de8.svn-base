#include "get_discussions_list_handler.h"
#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include "glooxWrapInterface.h"

namespace gloox
{


	GetDiscussionsListHandler::GetDiscussionsListHandler(Result_Data_Callback callback):callback_(callback)
	{
	}

	bool GetDiscussionsListHandler::handleIq( const IQ& iq )
	{
		return true;
	}

	void GetDiscussionsListHandler::handleIqID( const IQ& iq, int context )
	{
		json::jobject jobj;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			ELOG("app")->error(WCOOL(L"取讨论组列表时服务端返回错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
			if (!callback_.empty())
			{
				universal_resource error_desc;
				error_desc = XL("biz.GetDiscussionsList.fail");
				callback_(true, error_desc, jobj);
			}
		}else{
			if(iq.findExtension(kExtUser_iq_filter_getdiscussionslist))
			{
				boost::shared_ptr<gloox::Tag> tag(iq.findExtension(kExtUser_iq_filter_getdiscussionslist)->tag());
				if (tag)
				{
					//循环取得item
					gloox::TagList items;
					items = tag->findChildren("item");
					TagList::const_iterator it = items.begin();
					for( ; it != items.end(); ++it )
					{
						std::string did = gWrapInterface::instance().append_discussions_domain((*it)->findAttribute( "id" ));
						std::string topic = (*it)->findAttribute( "topic" );
						json::jobject data;
						data["session_id"] = did;
						data["group_name"] = topic;
						jobj.arr_push(data);
					}

					if (!callback_.empty())
					{
						callback_(false, XL(""), jobj);
					}
					
					return;
				}
			}
			
			ELOG("app")->error(WCOOL(L"取讨论组列表时服务端返回的数据格式错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
			if (!callback_.empty())
			{
				universal_resource error_desc;
				error_desc = XL("biz.GetDiscussionsList.fail");
				callback_(true, error_desc, jobj);
			}
		}
	}
}