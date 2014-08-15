#include "create_groups_handler.h"
#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include "glooxWrapInterface.h"
#include "../gloox_src/error.h"
namespace gloox
{


	CreateGroupsHandler::CreateGroupsHandler( Result_Data_Callback callback ):callback_(callback)
	{

	}

	bool CreateGroupsHandler::handleIq( const IQ& iq )
	{
		if(iq.findExtension(kExtUser_iq_filter_creategroups))
		{
			boost::shared_ptr<gloox::Tag> tag(iq.findExtension(kExtUser_iq_filter_creategroups)->tag());
			if (tag)
			{
				gloox::Tag* tag2 = tag->findChild("item");
				if (tag)
				{
					json::jobject jobj;
					jobj["session_id"] = gWrapInterface::instance().append_groups_domain(tag2->findAttribute("id"));
					jobj["type"] = "create";
					jobj["name"] = tag2->findAttribute("name");
					if (tag2->hasAttribute("icon"))
					{
						jobj["icon"] = tag2->findAttribute("icon");
					}
					jobj["category"] = tag2->findAttribute("category");
					gWrapInterface::instance().groups_list_change(jobj);
					return true;
				}
			}
		}
		return true;
	}
	/*
	　<iq type=’result’ from=’groups.ruijie.com.cn’  to=’123456@ruijie.com.cn’>
　　	<query xmlns=’groups:create’>
　　<item id=’122’ name=”吃货群” icon=”icon_url” type=”0” announce=”公告”
		description=”吃遍全天下” category=”0” />
　　</query>
　　</iq>
	*/
	void CreateGroupsHandler::handleIqID( const IQ& iq, int context )
	{
		json::jobject jobj;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			const Error* e = iq.error();
			if (!e)
			{
				callback_(true,XL("biz.CreateGroups.fail"),jobj);
				return;
			}

			if ( e->error() == StanzaErrorBadRequest)
			{
				ELOG("app")->error(WCOOL(L"创建群失败，请求协议错误！。"));
				callback_(true,XL("biz.crwod.iq_error.bad-request"),jobj);
			}
			else if (e->error() == StanzaErrorInternalServerError)
			{
				ELOG("app")->error(WCOOL(L"创建群失败，处理错误(服务器处理错误)。"));
				callback_(true,XL("biz.crwod.iq_error.internal-server-error"),jobj);
			}
			else if (e->error() == StanzaErrorResourceConstraint)
			{
				ELOG("app")->error(WCOOL(L"无法创建新群，你已达到创建群上限"));
				callback_(true,XL("biz.crwod.iq_error.create_resource-constraint"),jobj);
			}
			else
			{
				ELOG("app")->error(WCOOL(L"创建群失败。服务器返回未知错误类型！") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
				callback_(true,XL("biz.CreateGroups.fail"),jobj);
			}
		}else{
			if(iq.findExtension(kExtUser_iq_filter_creategroups))
			{
				boost::shared_ptr<gloox::Tag> tag(iq.findExtension(kExtUser_iq_filter_creategroups)->tag());
				if (tag)
				{
					gloox::Tag* tag2 = tag->findChild("item");
					if (tag2)
					{
						jobj["type"] = "create";

						jobj["name"] = tag2->findAttribute("name");
						if (tag2->hasAttribute("icon"))
						{
							jobj["icon"] = tag2->findAttribute("icon");
						}
						jobj["category"] = tag2->findAttribute("category");
						jobj["session_id"] = gWrapInterface::instance().append_groups_domain(tag2->findAttribute("id"));
						gWrapInterface::instance().groups_list_change(jobj);
						callback_(false, XL(""), jobj);
						return;
					}
				}
			}
			ELOG("app")->error(WCOOL(L"创建群时服务端返回的数据格式错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
			callback_(true, XL("biz.CreateGroups.fail"), jobj);
		}
	}

}