#include "get_groups_memberlist_handler.h"
#include <base/log/elog/elog.h>
#include <base/time/time_format.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include <boost/lexical_cast.hpp>
#include <boost/date_time/gregorian/conversion.hpp>
#include "glooxWrapInterface.h"
#include "../gloox_src/error.h"
#include "boost/assign/list_of.hpp"
#include <map>
#include <boost/date_time/c_local_time_adjustor.hpp>

namespace gloox
{

	using namespace boost::assign;
	static std::map<std::string, std::string> status_map = map_list_of("Online", "Online")("Offline", "Offline")("away","Away")("xa","Away")("dnd", "Busy")("invisible","Invisible");
	GetGroupsMemberListHandler::GetGroupsMemberListHandler( Result_Data_Callback callback ):callback_(callback)
	{

	}

	bool GetGroupsMemberListHandler::handleIq( const IQ& iq )
	{
		return true;
	}
	/*
	　　<iq type=’result from=’112@groups.ruijie.com.cn’ to=’123456@ruijie.com.cn/pc’>
　　 	<query xmlns=’ groups:member:list’ >
　　		<item jid=’1234567@ruijie.com.cn’ name=’张三’ icon=”icon_url” status=”online”/>
　　		<item jid=’7654321@ruijie.com.cn’ name=’李四’ icon=”icon_url”/>
		　　…
　　	</query>
　　</iq>
	*/
	void GetGroupsMemberListHandler::handleIqID( const IQ& iq, int context )
	{
		json::jobject jobj;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			const Error* e = iq.error();
			if (!e)
			{
				callback_(true,XL("biz.GetGroupsMemberList.fail"),jobj);
				return;
			}
			if ( e->error() == StanzaErrorBadRequest)
			{
				ELOG("app")->error(WCOOL(L"取群成员列表时，请求协议错误！。"));
				callback_(true,XL("biz.crwod.iq_error.bad-request"),jobj);
			}
			else if (e->error() == StanzaErrorInternalServerError)
			{
				ELOG("app")->error(WCOOL(L"取群成员列表时，处理错误(服务器处理错误)。"));
				callback_(true,XL("biz.crwod.iq_error.internal-server-error"),jobj);
			}
			else if (e->error() == StanzaErrorItemNotFound)
			{
				ELOG("app")->error(WCOOL(L"取群成员列表时，找不到此群。"));
				callback_(true,XL("biz.crwod.iq_error.item-not-found"),jobj);
			}else
			{
				ELOG("app")->error(WCOOL(L"取群成员列表时,服务器返回未知错误类型！") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
				callback_(true,XL("biz.GetGroupsMemberList.fail"),jobj);
			}
		}
		else
		{
			if(iq.findExtension(kExtUser_iq_filter_getgroupsmemberlist))
			{
				boost::shared_ptr<gloox::Tag> tag(iq.findExtension(kExtUser_iq_filter_getgroupsmemberlist)->tag());
				if (tag)
				{
					//循环取得item
					gloox::TagList items;
					items = tag->findChildren("item");
					TagList::const_iterator it = items.begin();
					for( ; it != items.end(); ++it )
					{
						if ((*it)->findAttribute( "jid" ).empty())
						{
							ELOG("app")->error(WCOOL(L"取群成员列表时 成员jid是空 : ") + (*it)->xml());
							continue;
						}
						json::jobject item;
						item["jid"] = (*it)->findAttribute( "jid" ) ;
						item["showname"] = (*it)->findAttribute( "name" );
						item["status"] =  status_map[(*it)->findAttribute( "status" )];
						item["photo_credential"] = (*it)->findAttribute( "photo_credential" );
						item["sex"] = (*it)->findAttribute( "sex" );
						item["identity"] = (*it)->findAttribute( "identity" );
						item["role"] = (*it)->findAttribute( "role" );
						item["resource"] = (*it)->findAttribute( "resource" );
						item["aid"] = (*it)->findAttribute( "aid" );

						std::string timestamp = (*it)->findAttribute( "last_talk_time" );
						if (!timestamp.empty())
						{
							boost::posix_time::ptime t = boost::posix_time::from_time_t(boost::lexical_cast<intmax_t>(timestamp)/1000);
							boost::posix_time::ptime local_time = boost::date_time::c_local_adjustor<boost::posix_time::ptime>::utc_to_local(t);							
							item["last_talk_time"] = epius::time_format(local_time);
						}
						else
						{
							item["last_talk_time"] = "";
						}						
						jobj.arr_push(item);
					}

					callback_(false,XL(""),jobj);
					return;
				}
			}
			ELOG("app")->error(WCOOL(L"取群成员列表时服务端返回的数据格式错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
			callback_(true, XL("biz.GetGroupsMemberList.fail"), jobj);
		}
	}

}