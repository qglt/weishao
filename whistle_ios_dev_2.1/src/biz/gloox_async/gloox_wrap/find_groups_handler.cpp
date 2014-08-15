#include <base/log/elog/elog.h>
#include <base/txtutil/txtutil.h>
#include <base/module_path/file_manager.h>
#include <base/time/time_format.h>
#include "UserStanzaExtensionType.h"
#include "find_groups_handler.h"
#include "../gloox_src/error.h"
namespace gloox
{
	FindGroupsHandler::FindGroupsHandler( Result_Data_Callback callback ):callback_(callback)
	{

	}

	bool FindGroupsHandler::handleIq( const IQ& iq )
	{
		return true;
	}
	static void fill_search_field(json::jobject& jobj, const gloox::Tag* ptag, std::string field,std::string replace_field = "")
	{
		if(replace_field.empty())replace_field = field;
		gloox::Tag* item_tag = ptag->findChildWithAttrib("var",field);

		if(!item_tag)
		{
			jobj[replace_field] = "";
			return;
		}
		gloox::Tag* value_tag = item_tag->findChild("value");
		if(!value_tag)
		{
			jobj[replace_field] = "";
			return;
		}
		jobj[replace_field] = value_tag->cdata();
	}


	void FindGroupsHandler::handleIqID( const IQ& iq, int context )
	{
		//查找好友

		json::jobject data;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			const Error* e = iq.error();
			if (!e)
			{
				callback_(false,XL("biz.FindGroups.fail"),data);
				return;
			}

			if ( e->error() == StanzaErrorBadRequest)
			{
				ELOG("app")->error(WCOOL(L"查找群时，请求协议错误！。"));
				callback_(false,XL("biz.crwod.iq_error.bad-request"),data);
			}
			else if (e->error() == StanzaErrorInternalServerError)
			{
				ELOG("app")->error(WCOOL(L"查找群时，处理错误(服务器处理错误)。"));
				callback_(false,XL("biz.crwod.iq_error.internal-server-error"),data);
			}
			else if (e->error() == StanzaErrorItemNotFound)
			{
				ELOG("app")->error(WCOOL(L"查找群时，找不到此群。"));
				callback_(false,XL("biz.crwod.iq_error.item-not-found"),data);
			}else
			{
				ELOG("app")->error(WCOOL(L"查找群时,服务器返回未知错误类型！") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
				callback_(false,XL("biz.FindGroups.fail"),data);
			}
		}
		else if(iq.findExtension(kExtUser_iq_filter_findgroups))
		{
			boost::shared_ptr<gloox::Tag> ptag(iq.findExtension(kExtUser_iq_filter_findgroups)->tag());
			if (ptag)
			{
				gloox::ConstTagList ptag_list = ptag->findTagList("//item");
				int i = 0;

				for (gloox::ConstTagList::iterator it = ptag_list.begin();it != ptag_list.end();it++,++i)
				{
					json::jobject contact;
					fill_search_field(contact,*it,"id");
					fill_search_field(contact,*it,"name");
					fill_search_field(contact,*it,"auth_type");
					fill_search_field(contact,*it,"icon");
					fill_search_field(contact,*it,"max_member_size");
					fill_search_field(contact,*it,"cur_member_size");
					fill_search_field(contact,*it,"v","official");
					fill_search_field(contact,*it,"active");
					fill_search_field(contact,*it,"category");
					fill_search_field(contact,*it,"description");
					fill_search_field(contact,*it,"quit");
					fill_search_field(contact,*it,"status");
					data.arr_push(contact);
				}
			}
			else
			{
				ELOG("app")->error(WCOOL(L"查找群时,服务端返回错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
				callback_(false,XL("biz.FindGroups.fail"),data);
				return;
			}
		}
		else
		{
			ELOG("app")->error(WCOOL(L"查找群时,服务端返回错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
			callback_(false,XL("biz.FindGroups.fail"),data);
			return;
		}
		callback_(false,XL(""),data);
	}

}