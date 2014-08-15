#include "get_groups_info_handler.h"
#include <base/log/elog/elog.h>
#include <base/time/time_format.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include <boost/lexical_cast.hpp>
#include <boost/date_time/gregorian/conversion.hpp>
#include "glooxWrapInterface.h"
#include "../gloox_src/error.h"
#include <boost/date_time/c_local_time_adjustor.hpp>

namespace gloox
{


	GetGroupsInfoHandler::GetGroupsInfoHandler( Result_Data_Callback callback ):callback_(callback)
	{

	}

	bool GetGroupsInfoHandler::handleIq( const IQ& iq )
	{
		return true;
	}
	/*
	　<iq type=’result from=’122@groups.ruijie.com.cn’ to=’123456@ruijie.com.cn/pc’>
　　 	<query xmlns=’groups:data’>
　　		<item name=’’ cur_member_size=”33” announce=’好好学习，天天向上”
　　max_member_size =”200” max_space_size=”2000000” cur_space_size =”8000”
　　category=”15” />
　　	</query>
　　</iq>
	*/
	void GetGroupsInfoHandler::handleIqID( const IQ& iq, int context )
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
				ELOG("app")->error(WCOOL(L"取群资料列表时，请求协议错误！。"));
				callback_(true,XL("biz.crwod.iq_error.bad-request"),jobj);
			}
			else if (e->error() == StanzaErrorInternalServerError)
			{
				ELOG("app")->error(WCOOL(L"取群资料列表时，处理错误(服务器处理错误)。"));
				callback_(true,XL("biz.crwod.iq_error.internal-server-error"),jobj);
			}
			else if (e->error() == StanzaErrorItemNotFound)
			{
				ELOG("app")->error(WCOOL(L"取群资料列表时，找不到此群。"));
				callback_(true,XL("biz.crwod.iq_error.item-not-found"),jobj);
			}else
			{
				ELOG("app")->error(WCOOL(L"取群资料列表时,服务器返回未知错误类型！") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
				callback_(true,XL("biz.GetGroupsInfo.fail"),jobj);
			}
		}else{
			if(iq.findExtension(kExtUser_iq_filter_getgroupsinfo))
			{
				boost::shared_ptr<gloox::Tag> tag(iq.findExtension(kExtUser_iq_filter_getgroupsinfo)->tag());
				if (tag)
				{
					//循环取得item
					gloox::TagList items;
					items = tag->findChildren("item");
					TagList::const_iterator it = items.begin();
					if ((*it)->findAttribute( "name" ).empty())
					{
						ELOG("app")->error(WCOOL(L"取群资料列表时 资料name是空 : ") + (*it)->xml());
						callback_(true, XL("biz.GetGroupsMemberList.fail"), jobj);
					}
					else
					{

						std::string timestamp = (*it)->findAttribute( "createtime" );
						if (!timestamp.empty())
						{
							boost::posix_time::ptime t = boost::posix_time::from_time_t(boost::lexical_cast<intmax_t>(timestamp)/1000);
							boost::posix_time::ptime local_time = boost::date_time::c_local_adjustor<boost::posix_time::ptime>::utc_to_local(t);
							jobj["createtime"] = epius::time_format(t);
						}
						else
						{
							jobj["createtime"] = "";
						}
						
						
						jobj["name"] = (*it)->findAttribute( "name" );
						jobj["cur_member_size"] = (*it)->findAttribute( "cur_member_size" );
						jobj["announce"] = (*it)->findAttribute( "announce" );
						jobj["max_member_size"] = (*it)->findAttribute( "max_member_size" );
						jobj["max_space_size"] = (*it)->findAttribute( "max_space_size" );
						jobj["cur_space_size"] = (*it)->findAttribute( "cur_space_size" );
						jobj["category"] = (*it)->findAttribute( "category" );
						jobj["dismiss"] = (*it)->findAttribute( "dismiss" );
						jobj["auth_type"] = (*it)->findAttribute( "auth_type" );
						jobj["official"] = (*it)->findAttribute( "v" );
						jobj["icon"] = (*it)->findAttribute( "icon" );
						jobj["description"]=(*it)->findAttribute("description");
						jobj["alert"] = (*it)->findAttribute( "alert" );
						jobj["role"] = (*it)->findAttribute( "role" );
						jobj["admin_applying"] = (*it)->findAttribute( "admin_applying" );
						jobj["quit"] = (*it)->findAttribute( "quit" );
						jobj["remark"] = (*it)->findAttribute( "remark" );
						jobj["find"] = (*it)->findAttribute( "find" );
						jobj["active"] = (*it)->findAttribute( "active" );
						jobj["status"] = (*it)->findAttribute( "status" );
						callback_(false,XL(""),jobj);
					}

					return;
				}
			}
			ELOG("app")->error(WCOOL(L"取群资料列表时，服务端返回的数据格式错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
			callback_(true, XL("biz.GetGroupsInfo.fail"), jobj);
		}
	}

}
