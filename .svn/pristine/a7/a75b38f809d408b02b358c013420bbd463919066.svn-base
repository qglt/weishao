#include "set_groups_member_info_handler.h"
#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include "../gloox_src/error.h"
#include "glooxWrapInterface.h"
namespace gloox
{


	SetGroupsMemerInfoHandler::SetGroupsMemerInfoHandler( Result_Callback callback ):callback_(callback)
	{

	}

	bool SetGroupsMemerInfoHandler::handleIq( const IQ& iq )
	{
		if(iq.findExtension(kExtUser_iq_filter_setgroupsmemberinfo))
		{
			boost::shared_ptr<gloox::Tag> tag(iq.findExtension(kExtUser_iq_filter_setgroupsmemberinfo)->tag());
			if (tag)
			{
				gloox::Tag* tag2 = tag->findChild("item");
				if (tag)
				{
					json::jobject jobj;
					jobj["session_id"] = iq.from().bare();
					if (tag2->hasAttribute("remark"))
					{
						jobj["remark"] = tag2->findAttribute("remark");
						gWrapInterface::instance().groups_info_change(jobj);
					}

					return true;
				}
			}
		}
		return true;
	}
	/*
	　<iq type=’result’ from=’112@groups.ruijie.com.cn’ to=’123456@ruijie.com.cn/pc’>
　　 	<query xmlns=’groups:info’ notify=”true”>
　　		<actor jid=”123456@ruijie.com.cn” name=”张三” nick_name=”天天甜甜” sex=”boy”  />
　　		<item name=”吃货群” icon=”icon_url” announce=”公告”/>
　　	</query>
　　</iq>
	*/
	void SetGroupsMemerInfoHandler::handleIqID( const IQ& iq, int context )
	{
		json::jobject jobj;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			const Error* e = iq.error();
			if (!e)
			{
				callback_(true,XL("biz.ApplyJoinGroups.fail"));
				return;
			}

			if ( e->error() == StanzaErrorForbidden)
			{
				ELOG("app")->error(WCOOL(L"修改群资料时服务端返回错误，不是管理员。"));
				callback_(true,XL("biz.crwod.iq_error.set_info_forbidden"));
			}else
			{
				ELOG("app")->error(WCOOL(L"修改群资料时服务端返回错误。"));
				callback_(true,XL("biz.ChangeGroupsInfo.fail"));
			}
		}else{
			callback_(false,XL(""));		
		}
	}

}