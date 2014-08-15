#include "preLoginHandler.h"
#include "xmpp_error_info.h"
#include "../gloox_src/error.h"
#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include <base/log/elog/elog.h>
#include "base/module_path/epfilesystem.h"
#include <base/module_path/file_manager.h>

namespace gloox
{
	preLoginHandler::preLoginHandler(Result_Data_Callback callback ):callback_(callback)
	{

	}

	bool preLoginHandler::handleIq( const IQ& iq )
	{
		return true;
	}

	void preLoginHandler::handleIqID( const IQ& iq, int context )
	{
		json::jobject jobj;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			const Error* e = iq.error();
			if(!e)return;
 			universal_resource error_desc;
 			std::string err_code = std::string("biz.prelogin.err_") + StanzaError2String[e->error()];
 			error_desc = XL(err_code);
#ifdef _WIN32
			//当服务器不再支持本地版本时
			if (e->error() == StanzaErrorConflict)
			{							
				Tag* error = iq.tag()->findChild("error");
				if (error)
				{
					boost::shared_ptr<gloox::Tag> info(error->findChild("info"));
					if (info)
					{
						std::string url = info->findChild("uri")->cdata();
						jobj["url"] = url;						
						jobj["size"] = info->findChild("size")->cdata();	
						std::string ext = epius::epfilesystem::instance().file_extension(url);
						std::string filename_no_ext = url.substr(0, url.find(ext));
						jobj["path"] = epius::epfilesystem::instance().sub_path(
							epius::epfilesystem::instance().sub_path(
								epius::epfilesystem::instance().sub_path(
									biz::file_manager::instance().get_default_config_dir(),
									"localupdate"
								),
							filename_no_ext),
						url);							
						jobj["reason_id"] = error_desc;
						jobj["md5sum"] = info->findChild("md5sum")->cdata();						
		
					}
				}
			}
#endif			
			ELOG("app")->error(error_desc.res_value_utf8);
			callback_(true, error_desc, jobj);
		}
		else
		{
			if(iq.findExtension(KExtUser_iq_filter_prelogin))
			{
				boost::shared_ptr<gloox::Tag> tag(iq.findExtension(KExtUser_iq_filter_prelogin)->tag());
				if (tag)
				{
					jobj["aid"] = tag->findChild("aid")->cdata();
					jobj["username"] = tag->findChild("username")->cdata();
					jobj["version"] = tag->findChild("version")->cdata();
					jobj["timestamp"] = tag->findChild("timestamp")->cdata();
					std::string account_type = tag->findChild("account")->findAttribute("type");
					jobj["account_type"] = account_type;
					if(tag->findChild("challenge"))
					{
						std::string challenge = tag->findChild("challenge")->cdata();
						jobj["challenge"] = challenge;
					}
					callback_(false,XL(""),jobj);
					return;
				}
			}
			ELOG("app")->error(WCOOL(L"预登录时服务端返回的数据格式错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
			callback_(true, XL("biz.prelogin_server_return_wrong_data"), jobj);
		}
	}
}

