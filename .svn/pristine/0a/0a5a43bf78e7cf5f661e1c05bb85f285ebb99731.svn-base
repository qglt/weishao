#include "apply_join_groups_handler.h"
#include <base/log/elog/elog.h>
#include "xmpp_error_info.h"
#include "../gloox_src/error.h"
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include "glooxWrapInterface.h"

namespace gloox
{


	ApplyJoinGroupsHandler::ApplyJoinGroupsHandler( Result_Data_Callback callback ):callback_(callback)
	{

	}

	bool ApplyJoinGroupsHandler::handleIq( const IQ& iq )
	{
		return true;
	}
	/*
	　<iq type=’result’ from=’112@groups.ruijie.com.cn’ to=’123456@ruijie.com.cn/pc’>
　　 	<query xmlns=’groups:member:apply:accept|wait’>//需要返回群相关信息 
　　	</query>
　　</iq>
	*/
	void ApplyJoinGroupsHandler::handleIqID( const IQ& iq, int context )
	{
		json::jobject jobj;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			const Error* e = iq.error();
			if (!e)
			{
				callback_(true,XL("biz.ApplyJoinGroups.fail"),jobj);
				return;
			}
			
			if ( e->error() == StanzaErrorResourceConstraint)
			{
				ELOG("app")->error(WCOOL(L"申请加入群时服务端返回错误，成员已满。"));
				callback_(true,XL("biz.crwod.iq_error.apply_resource-constraint"),jobj);
			}
			else if (e->error() == StanzaErrorNotAuthorized)
			{
				ELOG("app")->error(WCOOL(L"申请加入群时服务端返回错误，群未开放。"));
				callback_(true,XL("biz.crwod.iq_error.apply_not-authorized"),jobj);
			}
			else if (e->error() == StanzaErrorItemNotFound)
			{
				ELOG("app")->error(WCOOL(L"申请加入群时服务端返回错误，找不到此群。"));
				callback_(true,XL("biz.crwod.iq_error.item-not-found"),jobj);
			}else
			{
				callback_(true,XL("biz.ApplyJoinGroups.fail"),jobj);
			}
		}else{
			if(iq.findExtension(kExtUser_iq_filter_applyjoingroups))
			{
				boost::shared_ptr<gloox::Tag> tag(iq.findExtension(kExtUser_iq_filter_applyjoingroups)->tag());
				if (tag)
				{
					jobj["type"] = tag->findAttribute("type");
					if (tag->findAttribute("type")=="accept")
					{
						gloox::Tag* tchild(tag->findChild("item"));
						jobj["session_id"]=iq.from().bare();
						jobj["name"]=tchild->findAttribute("name");
						jobj["icon"]=tchild->findAttribute("icon");
						jobj["quit"]=tchild->findAttribute("quit");
						jobj["dismiss"]=tchild->findAttribute("dismiss");
						jobj["status"]=tchild->findAttribute("status");
						jobj["official"]=tchild->findAttribute("v");
						jobj["active"]=tchild->findAttribute("active");
						jobj["category"]=tchild->findAttribute("category");
						jobj["role"]=tchild->findAttribute("role");
						jobj["alert"]=tchild->findAttribute("alert");
					}
						

					callback_(false,XL(""),jobj);
					return;				
				}
			ELOG("app")->error(WCOOL(L"申请加入群时返回的数据格式错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
			callback_(true, XL("biz.ApplyJoinGroups.fail"), jobj);
			}
		}
	}
}