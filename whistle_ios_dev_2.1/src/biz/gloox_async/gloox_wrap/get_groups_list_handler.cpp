#include "get_groups_list_handler.h"
#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include "glooxWrapInterface.h"
#include "../gloox_src/error.h"

namespace gloox
{


	GetGroupsListHandler::GetGroupsListHandler(Result_Data_Callback callback):callback_(callback)
	{
	}

	bool GetGroupsListHandler::handleIq( const IQ& iq )
	{
		return true;
	}
	/*
	
	<iq type=’result’from=’groups.ruijie.com.cn’ to=’123456@ruijie.com.cn/pc’>
	<query xmlns=’groups:list’>
	<item id=’112’ name=’吃货群’ icon=”icon_url”v=”false” alert=”1”/>
	<item id=’113’ name=’开心群’ icon=”icon_url”v=”false” alert=”0”/>
	…
	</query>
	</iq>
*/
	void GetGroupsListHandler::handleIqID( const IQ& iq, int context )
	{
		json::jobject jobj;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			const Error* e = iq.error();
			if (!e)
			{
				callback_(true,XL("biz.GetGroupsList.fail"),jobj);
				return;
			}

			if ( e->error() == StanzaErrorBadRequest)
			{
				ELOG("app")->error(WCOOL(L"取群列表时，请求协议错误！。"));
				callback_(true,XL("biz.crwod.iq_error.bad-request"),jobj);
			}
			else if (e->error() == StanzaErrorInternalServerError)
			{
				ELOG("app")->error(WCOOL(L"取群列表时，处理错误(服务器处理错误)。"));
				callback_(true,XL("biz.crwod.iq_error.internal-server-error"),jobj);
			}
			else if (e->error() == StanzaErrorItemNotFound)
			{
				ELOG("app")->error(WCOOL(L"取群列表时，找不到此群。"));
				callback_(true,XL("biz.crwod.iq_error.item-not-found"),jobj);
			}else
			{
				ELOG("app")->error(WCOOL(L"取群列表时,服务器返回未知错误类型！") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
				callback_(true,XL("biz.GetGroupsList.fail"),jobj);
			}

		}else{
			if(iq.findExtension(kExtUser_iq_filter_getgroupslist))
			{
				boost::shared_ptr<gloox::Tag> tag(iq.findExtension(kExtUser_iq_filter_getgroupslist)->tag());
				if (tag)
				{
					//循环取得item
					gloox::TagList items;
					items = tag->findChildren("item");
					TagList::const_iterator it = items.begin();
					for( ; it != items.end(); ++it )
					{
						json::jobject data;
						data["session_id"] = gWrapInterface::instance().append_groups_domain((*it)->findAttribute( "id" ));
						data["remark"] = (*it)->findAttribute( "remark" );
						data["name"] = (*it)->findAttribute( "name" );
						data["icon"]  = (*it)->findAttribute( "icon" );
						data["official"] = (*it)->findAttribute( "v" );
						data["alert"] = (*it)->findAttribute( "alert" );
						data["role"] = (*it)->findAttribute( "role" );
						data["quit"] = (*it)->findAttribute( "quit" );
						data["status"] = (*it)->findAttribute( "status" );
						data["dismiss"] = (*it)->findAttribute( "dismiss" );
						data["active"] = (*it)->findAttribute( "active" );
						data["category"] = (*it)->findAttribute( "category" );
						jobj.arr_push(data);
					}

					if (!callback_.empty())
					{
						callback_(false, XL(""), jobj);
					}

					return;
				}
			}

			ELOG("app")->error(WCOOL(L"取群列表时服务端返回的数据格式错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
			if (!callback_.empty())
			{
				universal_resource error_desc;
				error_desc = XL("biz.GetGroupsList.fail");
				callback_(true, error_desc, jobj);
			}
		}
	}
}