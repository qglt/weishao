#include "invite_discussions_handler.h"
#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include "glooxWrapInterface.h"

namespace gloox
{


	InviteDiscussionsHandler::InviteDiscussionsHandler( Result_Data_Callback callback ):callback_(callback)
	{

	}

	bool InviteDiscussionsHandler::handleIq( const IQ& iq )
	{
		return true;
	}

	void InviteDiscussionsHandler::handleIqID( const IQ& iq, int context )
	{
		json::jobject jobj;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			universal_resource error_desc;
			ELOG("app")->error(WCOOL(L"邀请加入讨论组时服务端返回错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
			error_desc = XL("biz.InviteDiscussions.fail");
			if (!callback_.empty())
			{
				callback_(true, error_desc, jobj);
			}
			
		}else{
			if(iq.findExtension(kExtUser_iq_filter_invitediscussions))
			{
				boost::shared_ptr<gloox::Tag> tag(iq.findExtension(kExtUser_iq_filter_invitediscussions)->tag());
				if (tag)
				{
					//循环取得victim
					gloox::TagList items;
					items = tag->findChildren("item");
					TagList::const_iterator it = items.begin();
					for( ; it != items.end(); ++it )
					{
						json::jobject item;
						item["jid"] = (*it)->findAttribute( "userid" ) + "@" +gWrapInterface::instance().get_domain();
						item["name"] = (*it)->findAttribute( "name" );
						jobj.arr_push(item);
					}

					if (!callback_.empty())
					{
						callback_(false,XL(""),jobj);
					}
					return;
				}
			}
			ELOG("app")->error(WCOOL(L"邀请加入讨论组时服务端返回的数据格式错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
			if (!callback_.empty())
			{
				callback_(true, XL("biz.InviteDiscussions.fail"), jobj);
			}
		}
	}

}