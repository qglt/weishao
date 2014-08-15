#include "getStrangerListHandler.h"
#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
namespace gloox
{
	getStrangerListHandler::getStrangerListHandler( Result_Data_Callback callback ):callback_(callback)
	{

	}

	bool getStrangerListHandler::handleIq( const IQ& iq )
	{
		return true;
	}
		
	void getStrangerListHandler::handleIqID( const IQ& iq, int context )
	{
		json::jobject jobj;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			universal_resource error_desc;
			ELOG("app")->error(WCOOL(L"获取陌生人列表服务端返回错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
			error_desc = XL("biz.getStrangerListHandler.fail");
			callback_(true, error_desc,jobj);
		}
		else
		{	
// 			<iq type="result">
// 			<query xmlns="jabber:iq:private">
// 			<stranger xmlns="hash:get">
// 			<item key="123">
// 			<!-- key 表示 UID -->
// 			<uid>123</uid>
// 			<name>老师</name>
// 			</item>
// 			<item key="123">
// 			<!-- key 表示 UID -->
// 			<uid>123</uid>
// 			<name>老师</name>
// 			</item>
// 			</stranger>
// 			</query>
// 			</iq>

 			boost::shared_ptr<gloox::Tag> tag(iq.findExtension(kExtUser_iq_filter_get_stranger_list)->tag());
			gloox::Tag* tag_stranger = tag->findChild("stranger");
 			if (tag_stranger)
 			{
 				//循环取得item
 				gloox::TagList items;
 				items = tag_stranger->findChildren("item");
 				TagList::const_iterator it = items.begin();
 				for( ; it != items.end(); ++it )
 				{
 					std::string key = (*it)->findAttribute( "key" );
 					std::string uid = (*it)->findChild( "uid" )->findCData("uid");
 					std::string name = (*it)->findChild( "name" )->findCData("name");
 					json::jobject data;
 					data["key"] = key;
 					data["uid"] = uid;
 					data["name"] = name;
 					jobj.arr_push(data);
 				}
 				if (!callback_.empty())
 				{
 					callback_(false, XL(""), jobj);
 				}
 				return;
 			}
		}
	}
}