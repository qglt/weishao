#include "organization_search_handler.h"
#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include "glooxWrapInterface.h"

namespace gloox {

	organizationSearchHandler::organizationSearchHandler( Result_Data_Callback callback )
	{
		callback_ = callback;
	}

	bool organizationSearchHandler::handleIq( const IQ& iq )
	{
		return true;
	}

	void organizationSearchHandler::handleIqID( const IQ& iq, int context )
	{
		json::jobject jobj;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			universal_resource error_desc;
			ELOG("app")->error(WCOOL(L"搜索组织结构成员时出错") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
			error_desc = XL("biz.organizationSearch.fail");

			callback_(true, error_desc, jobj);
		}
		else		
		{
			if(iq.findExtension(kExtUser_iq_filter_organization_search))
			{
				boost::shared_ptr<gloox::Tag> tag(iq.findExtension(kExtUser_iq_filter_organization_search)->tag());
				if (tag)
				{
					gloox::TagList items;
					items = tag->findChildren("item");
					TagList::const_iterator it = items.begin();
					if (it == items.end())
					{
						callback_(true,XL(""),jobj);
						return;
					}
					for( ; it != items.end(); ++it )
					{
						json::jobject user;
						if((*it)->findChild("name"))
						{
							user["name"] = (*it)->findChild("name")->cdata();
						}
						if((*it)->findChild("organization"))
						{
							user["organization"] = (*it)->findChild("organization")->cdata();
						}
						if((*it)->findChild("username"))
						{
							user["jid"] = (*it)->findChild("username")->cdata() + "@" + gWrapInterface::instance().get_domain();
						}
						if((*it)->findChild("sex"))
						{
							user["sex"] = (*it)->findChild("sex")->cdata();
						}
						if((*it)->findChild("identity"))
						{
							user["identity"] = (*it)->findChild("identity")->cdata();
						}
						if((*it)->findChild("mood_words"))
						{
							user["mood_words"] = (*it)->findChild("mood_words")->cdata();
						}
						if((*it)->findChild("photo_credential"))
						{
							user["photo_credential"] = (*it)->findChild("photo_credential")->cdata();
						}
						if((*it)->findChild("photo_live"))
						{
							user["photo_live"] = (*it)->findChild("photo_live")->cdata();
						}
						jobj.arr_push(user);
					}
					callback_(false,XL(""),jobj);
					return;
				}
			}
			ELOG("app")->error(WCOOL(L"搜索组织结构成员时服务端返回的数据格式错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
			callback_(true, XL("biz.organizationSearch.fail"), jobj);
		}
	}

}