#include "organization_show_hadler.h"
#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
namespace gloox
{
	OrganizationShowHandller::OrganizationShowHandller( Result_Data_Callback callback ):callback_(callback)
	{

	}

	bool OrganizationShowHandller::handleIq( const IQ& iq )
	{
		return true;
	}

// 	<iq type="result" id="2391fc380000000e" from="permission.dev.ruijie.com.cn" to="22556@dev.ruijie.com.cn/pc" timestamp="1379935130816">
// 		<query xmlns="http://ruijie.com.cn/permission" timestamp="2013-09-23 18:48:12">
// 			<basic_permissions>
// 				<permission name="tab_posts">true</permission>
// 				<permission name="send_notice">true</permission>
// 				<permission name="app_box">true</permission>
// 				<permission name="show_organization">true</permission>
// 			</basic_permissions>
// 		</query>
// 	</iq>

	void OrganizationShowHandller::handleIqID( const IQ& iq, int context )
	{
		json::jobject jobj = json::jobject();
		if (iq.m_subtype != gloox::IQ::Result)
		{
			universal_resource error_desc;
			ELOG("app")->error(WCOOL(L"组织结构树查看权限获取错误") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
			error_desc = XL("biz.OrganizationShowHandller.fail");
			callback_(true, error_desc,jobj);
		}
		else
		{
			boost::shared_ptr<gloox::Tag> ptag(iq.findExtension(kExtUser_iq_filter_organization_show)->tag());
			if (ptag)
			{
				gloox::Tag* tag_basic_permission = ptag->findChild("basic_permissions");
				if (tag_basic_permission)
				{
					ConstTagList ptag_list = tag_basic_permission->findTagList("//permission");
					for (ConstTagList::iterator it = ptag_list.begin(); it != ptag_list.end(); ++it)
					{
						if ((*it)->findAttribute("name") == "show_organization")
						{
							if ((*it)->cdata() == "true")
							{
								jobj["is_show_organization"] = true;
							}
							else
							{
								jobj["is_show_organization"] = false;
							}
							callback_(false, XL(""),jobj);
						}
					}
				}
			}
		}
	}
}