#include "get_discussions_memberlist_handler.h"
#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include "glooxWrapInterface.h"
#include "boost/assign/list_of.hpp"
#include <map>
namespace gloox
{
	using namespace boost::assign;
	static std::map<std::string, std::string> status_map = map_list_of("Online", "Online")("Offline", "Offline")("away","Away")("xa","Away")("dnd", "Busy")("invisible","Invisible");
	GetDiscussionsMemberListHandler::GetDiscussionsMemberListHandler( Result_Data_Callback callback ):callback_(callback)
	{

	}

	bool GetDiscussionsMemberListHandler::handleIq( const IQ& iq )
	{
		return true;
	}

	void GetDiscussionsMemberListHandler::handleIqID( const IQ& iq, int context )
	{
		json::jobject jobj;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			universal_resource error_desc;
			ELOG("app")->error(WCOOL(L"取讨论组成员列表时服务端返回错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
			error_desc = XL("biz.GetDiscussionsMemberList.fail");

			callback_(true, error_desc, jobj);
		}
		else
		{
			if(iq.findExtension(kExtUser_iq_filter_getdiscussionsmemberlist))
			{
				boost::shared_ptr<gloox::Tag> tag(iq.findExtension(kExtUser_iq_filter_getdiscussionsmemberlist)->tag());
				if (tag)
				{
					//循环取得item
					gloox::TagList items;
					items = tag->findChildren("item");
					TagList::const_iterator it = items.begin();
					for( ; it != items.end(); ++it )
					{
						if ((*it)->findAttribute( "userid" ).empty())
						{
							ELOG("app")->error(WCOOL(L"取讨论组成员列表时 成员jid是空 : ") + (*it)->xml());
							continue;
						}
						json::jobject item;
						item["jid"] = (*it)->findAttribute( "userid" ) + "@" + gWrapInterface::instance().get_domain();
						item["showname"] = (*it)->findAttribute( "name" );
						item["presence"] =  status_map[(*it)->findAttribute( "status" )];
						item["sex"] = (*it)->findAttribute( "sex" );
						item["identity"] = (*it)->findAttribute( "identity" );
						item["photo_credential"] = (*it)->findAttribute( "photo_credential" );
						item["resource"] = (*it)->findAttribute( "resource" );
						jobj.arr_push(item);
					}

					if (jobj.arr_size())
					{
						callback_(false,XL(""),jobj);
					}
					else
					{
						ELOG("app")->error(WCOOL(L"讨论组成员为空。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
						callback_(true, XL("biz.GetDiscussionsMemberList.fail"), jobj);
					}					
					return;
				}
			}
			ELOG("app")->error(WCOOL(L"取讨论组成员列表时服务端返回的数据格式错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
			callback_(true, XL("biz.GetDiscussionsMemberList.fail"), jobj);
		}
	}
}