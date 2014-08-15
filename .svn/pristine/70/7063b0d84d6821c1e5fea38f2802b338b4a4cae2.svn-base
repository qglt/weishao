#include "get_groups_admin_list_handler.h"
#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include "glooxWrapInterface.h"
#include "../gloox_src/error.h"
namespace gloox
{


	GetGroupsAdminListHandler::GetGroupsAdminListHandler( Result_Data_Callback callback ):callback_(callback)
	{

	}

	bool GetGroupsAdminListHandler::handleIq( const IQ& iq )
	{
		return true;
	}
	void GetGroupsAdminListHandler::handleIqID( const IQ& iq, int context )
	{
		json::jobject jobj;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			const Error* e = iq.error();
			if (!e)
			{
				callback_(true,XL("biz.GetGroupsAdminList.fail"),jobj);
				return;
			}

			if ( e->error() == StanzaErrorBadRequest)
			{
				ELOG("app")->error(WCOOL(L"取群管理员列表时，请求协议错误！。"));
				callback_(true,XL("biz.crwod.iq_error.bad-request"),jobj);
			}
			else if (e->error() == StanzaErrorInternalServerError)
			{
				ELOG("app")->error(WCOOL(L"取群管理员列表时，处理错误(服务器处理错误)。"));
				callback_(true,XL("biz.crwod.iq_error.internal-server-error"),jobj);
			}
			else if (e->error() == StanzaErrorItemNotFound)
			{
				ELOG("app")->error(WCOOL(L"取群管理员列表时，找不到此群。"));
				callback_(true,XL("biz.crwod.iq_error.item-not-found"),jobj);
			}else
			{
				ELOG("app")->error(WCOOL(L"取群管理员列表时,服务器返回未知错误类型！") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
				callback_(true,XL("biz.GetGroupsAdminList.fail"),jobj);
			}
		}else{
			if(iq.findExtension(kExtUser_iq_filter_getgroupsadminlist))
			{
				boost::shared_ptr<gloox::Tag> tag(iq.findExtension(kExtUser_iq_filter_getgroupsadminlist)->tag());
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
							ELOG("app")->error(WCOOL(L"取群管理员列表时 成员jid是空 : ") + (*it)->xml());
							continue;
						}
						json::jobject item;
						item["jid"] = (*it)->findAttribute( "jid" ) ;
						item["showname"] = (*it)->findAttribute( "name" );
						item["status"] = (*it)->findAttribute( "status" );
						item["photo_credential"] = (*it)->findAttribute( "photo_credential" );
						item["sex"] = (*it)->findAttribute( "sex" );
						item["identity"] = (*it)->findAttribute( "identity" );
						item["role"] = (*it)->findAttribute( "role" );
						jobj.arr_push(item);
					}

					callback_(false,XL(""),jobj);
					return;
				}
			}
			ELOG("app")->error(WCOOL(L"取群管理员列表时,服务端返回的数据格式错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
			callback_(true, XL("biz.GetGroupsAdminList.fail"), jobj);
		}
	}

}