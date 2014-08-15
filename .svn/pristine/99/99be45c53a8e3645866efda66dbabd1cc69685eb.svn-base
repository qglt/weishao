#include "get_groups_share_list_handler.h"
#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include <base/time/time_format.h>
#include "glooxWrapInterface.h"
#include "../gloox_src/error.h"
#include <boost/date_time/c_local_time_adjustor.hpp>

namespace gloox
{


	GetGroupsShareListHandler::GetGroupsShareListHandler(Result_Data_Callback callback):callback_(callback)
	{
	}

	bool GetGroupsShareListHandler::handleIq( const IQ& iq )
	{
		return true;
	}


/*成功应答　　
	<iq type=’result’from=’112@groups.ruijie.com.cn’ to=’123456@ruijie.com.cn’>
	<query xmlns=’groups:share:list’>
	<set page=’1’pagesize=’10’pagetotal=”1” />
	<item id=”1”
	name=”苍老师1.avi” size=”80000” owner=”123456@ruijie.com.cn”
	uri=”http://file.ruijie.com.cn/downlaod/xxxx.xx”/>
	<item id=”2”
	name=”苍老师2.avi” size=”80000” owner=”123456@ruijie.com.cn”
	uri=”http://file.ruijie.com.cn/downlaod/xxxx.xx” />

	……

	</query>
	</iq>

  */

	void GetGroupsShareListHandler::handleIqID( const IQ& iq, int context )
	{
		json::jobject jobj,items,sets;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			const Error* e = iq.error();
			if (!e)
			{
				callback_(true,XL("biz.GetGroupsShareList.fail"),jobj);
				return;
			}
			if ( e->error() == StanzaErrorBadRequest)
			{
				ELOG("app")->error(WCOOL(L"取群共享列表时，请求协议错误！。"));
				callback_(true,XL("biz.crwod.iq_error.bad-request"),jobj);
			}
			else if (e->error() == StanzaErrorInternalServerError)
			{
				ELOG("app")->error(WCOOL(L"取群共享列表时，处理错误(服务器处理错误)。"));
				callback_(true,XL("biz.crwod.iq_error.internal-server-error"),jobj);
			}
			else if (e->error() == StanzaErrorItemNotFound)
			{
				ELOG("app")->error(WCOOL(L"取群共享列表时，找不到此群。"));
				callback_(true,XL("biz.crwod.iq_error.item-not-found"),jobj);
			}else
			{
				ELOG("app")->error(WCOOL(L"取群共享列表时,服务器返回未知错误类型！") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
				callback_(true,XL("biz.GetGroupsShareList.fail"),jobj);
			}

		}else{
			if(iq.findExtension(kExtUser_iq_filter_getgroupssharelist))
			{
				boost::shared_ptr<gloox::Tag> tag(iq.findExtension(kExtUser_iq_filter_getgroupssharelist)->tag());
				if (tag)
				{
					//循环取得item
					gloox::TagList item;
					item = tag->findChildren("item");
					TagList::const_iterator it = item.begin();

					gloox::Tag* setTag = tag->findChild("set");
					if (setTag)
					{
						if (setTag->findChild( "index" ))
						{
							sets["index"]= setTag->findChild( "index" )->findCData( "index" );
						}
						if (setTag->findChild( "max" ))
						{
							sets["max"]= setTag->findChild( "max" )->findCData( "max" );
						}
						if (setTag->findChild( "total" ))
						{
							sets["total"]= setTag->findChild( "total" )->findCData( "total" );
						}
					}
					
					jobj["set"]=sets;
					for( ; it != item.end(); ++it )
					{
						json::jobject data;
						
						data["id"] = (*it)->findAttribute( "id" );
						data["name"] = (*it)->findAttribute( "name" );
						data["size"]  = (*it)->findAttribute( "size" );
						data["owner_jid"] = (*it)->findAttribute( "owner_jid" );
						
						if ((*it)->findAttribute( "download_count" ).empty())
						{
							data["download_count"] = "0";
						}
						else
						{
							data["download_count"] = (*it)->findAttribute( "download_count" );
						}
						
						std::string timestamp = (*it)->findAttribute( "create_time" );
						data["timestamp"] = timestamp;
						if (!timestamp.empty())
						{
							boost::posix_time::ptime t = boost::posix_time::from_time_t(boost::lexical_cast<intmax_t>(timestamp)/1000);
							boost::posix_time::ptime local_time = boost::date_time::c_local_adjustor<boost::posix_time::ptime>::utc_to_local(t);
							data["create_time"] = epius::time_format(local_time);
						}
						else
						{
							data["create_time"] = "";
						}
						
						data["owner_name"] = (*it)->findAttribute( "owner_name" );
						data["uri"] = (*it)->findAttribute( "uri" );
						items.arr_push(data);
					}
					jobj["list"]=items;
					if (!callback_.empty())
					{
						callback_(false, XL(""), jobj);
					}

					return;
				}
			}

			ELOG("app")->error(WCOOL(L"取群共享列表时服务端返回的数据格式错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
			if (!callback_.empty())
			{
				universal_resource error_desc;
				error_desc = XL("biz.GetGroupsShareList.fail");
				callback_(true, error_desc, jobj);
			}
		}
	}
}