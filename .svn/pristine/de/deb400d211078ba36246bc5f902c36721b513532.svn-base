#include "privilegeHandler.h"
#include "UserStanzaExtensionType.h"
#include "base/log/elog/elog.h"
namespace gloox {

static char * perm_names[] = {"tab_friend", //我的好友Tab显示
								"tab_temp", //讨论群组Tab显示 
								"tab_organization", //组织结构Tab显示
								"tab_recent_contacts", //最近联系Tab显示
								"tab_posts", //贴贴Tab显示
								"news", //新闻弹窗显示
								"course_remind", //下节课提醒（图标显示）
								"course_center", //课程中心
								"create_crowd",  //创建群
								"send_posts", //发布贴贴(5条/天 整数)
								"app_box", //应用盒子
								"send_notice"}; //发布通知范围

gloox::privilegeHandler::privilegeHandler(Client * client, GlooxWrapCallback callback ):pclient_(client)
{
	callback_ = callback;
	if (pclient_)
	{
		pclient_->registerStanzaExtension(new iq_privilege());
	}
}

bool gloox::privilegeHandler::handleIq( const IQ& iq )
{
	return true;
}

void gloox::privilegeHandler::handleIqID( const IQ& iq, int context )
{
	json::jobject jobj;
	if (iq.m_subtype != gloox::IQ::Result)
	{
		ELOG("app")->error("server return error to get privilege");
		callback_(true, XL("biz.privilege.get_privilege_failed_from_server"), jobj);
		return;
	}else{
		// set the default perms for false
		for (int i= 0; i < (sizeof(perm_names)/sizeof(char*)); i++){
			jobj[perm_names[i]] = false;
		}

		boost::shared_ptr<gloox::Tag> tag(iq.tag());
		gloox::Tag* tag_child = tag->findChild("query");
		if (tag_child)
		{
			tag_child = tag_child->findChild("basic_permissions");
			if (tag_child)
			{
				gloox::TagList tlist;
				gloox::TagList::iterator it;
				tlist = tag_child->findChildren("permission");
				for (it = tlist.begin(); it!=tlist.end(); it++)
				{
					Tag * permission = *it;
					std::string name = permission->findAttribute("name");
					std::string cdata = permission->cdata();
					if (cdata.compare("true") == 0)
					{
						jobj[name] = true;
					}else{
						jobj[name] = false;
					}
				}
				callback_(false, XL(""), jobj);
				return;
			}
		}
				
		ELOG("app")->error("server return error privilege data");
		callback_(true, XL("biz.privilege.get_privilege_data_failed"), jobj);
		return;
	}
}

gloox::iq_privilege::iq_privilege( const Tag* tag /*= 0 */ ): gloox::StanzaExtension( kExtUser_iq_filter_privilege )	
{
	if (tag)
		m_privilegetag = tag->clone();
	else
		m_privilegetag = NULL;
}

gloox::iq_privilege::iq_privilege( int context, const StringList& msgs ): gloox::StanzaExtension( kExtUser_iq_filter_privilege )	
{

}

gloox::iq_privilege::~iq_privilege()
{
	if (m_privilegetag)
		delete m_privilegetag;
}

const std::string& gloox::iq_privilege::filterString() const
{
	static const std::string filter = "/iq/query[@xmlns='http://ruijie.com.cn/permission']";
	return filter;
}

Tag* gloox::iq_privilege::tag() const
{
	return m_privilegetag->clone();
}



}