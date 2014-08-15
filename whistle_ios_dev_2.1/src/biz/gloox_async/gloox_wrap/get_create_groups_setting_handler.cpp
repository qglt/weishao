#include "get_create_groups_setting_handler.h"
#include <base/log/elog/elog.h>
#include <base/time/time_format.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include <boost/lexical_cast.hpp>
#include <boost/date_time/gregorian/conversion.hpp>
#include "glooxWrapInterface.h"
#include "../gloox_src/error.h"

namespace gloox
{


	GetCreateGroupsSettingHandler::GetCreateGroupsSettingHandler( Result_Data_Callback callback ):callback_(callback)
	{

	}

	bool GetCreateGroupsSettingHandler::handleIq( const IQ& iq )
	{
		return true;
	}
	void GetCreateGroupsSettingHandler::handleIqID( const IQ& iq, int context )
	{
		json::jobject jobj;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			const Error* e = iq.error();
			if (!e)
			{
				callback_(true,XL("biz.GetGroupsInfo.fail"),jobj);
				return;
			}

			if ( e->error() == StanzaErrorBadRequest)
			{
				ELOG("app")->error(WCOOL(L"判断是否可创建按群时，请求协议错误！。"));
				callback_(true,XL("biz.crwod.iq_error.bad-request"),jobj);
			}
			else if (e->error() == StanzaErrorInternalServerError)
			{
				ELOG("app")->error(WCOOL(L"判断是否可创建按群时，处理错误(服务器处理错误)。"));
				callback_(true,XL("biz.crwod.iq_error.internal-server-error"),jobj);
			}else
			{
				ELOG("app")->error(WCOOL(L"判断是否可创建按群时,服务器返回未知错误类型！") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
				callback_(true,XL("biz.GetGroupsInfo.fail"),jobj);
			}
		}else{
				if(iq.findExtension(kExtUser_iq_filter_groupsprecreate))
				{
					boost::shared_ptr<gloox::Tag> tag(iq.findExtension(kExtUser_iq_filter_groupsprecreate)->tag());
					if (tag)
					{
						gloox::Tag* tchild(tag->findChild("item"));
						jobj["create_enable"] = tchild->findAttribute( "create_enable" );
						jobj["can_create"] = tchild->findAttribute( "can_create" );
						jobj["max_member"] = tchild->findAttribute( "max_member" );
						jobj["max_can_create"] = tchild->findAttribute( "max_can_create" );

						callback_(false,XL(""),jobj);
					}
						return;
				}
			}
			ELOG("app")->error(WCOOL(L"判断是否可创建按群时，服务端返回的数据格式错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
			callback_(true, XL("biz.GetGroupsInfo.fail"), jobj);
		
	}

}