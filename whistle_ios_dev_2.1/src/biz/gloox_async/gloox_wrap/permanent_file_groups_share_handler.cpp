#include "permanent_file_groups_share_handler.h"
#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include "glooxWrapInterface.h"
namespace gloox
{


	PermanentFileGroupsShareHandler::PermanentFileGroupsShareHandler( Result_Callback callback ):callback_(callback)
	{

	}

	bool PermanentFileGroupsShareHandler::handleIq( const IQ& iq )
	{
		return true;
	}
	/*
	　<iq type=’result’from=’112@groups.ruijie.com.cn’ to=’123456@ruijie.com.cn’>
	 <queryxmlns=’groups:share:file:permanent’>
	 <item id=‘2’ />
	 </query>
	 </iq>

	*/
	void PermanentFileGroupsShareHandler::handleIqID( const IQ& iq, int context )
	{
		json::jobject jobj;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			universal_resource error_groups;
			ELOG("app")->error(WCOOL(L"变更永久文件时服务端返回错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
			error_groups = XL("biz.PermanentFileGroupsShare.fail");

			callback_(true, error_groups);
		}else{
			callback_(false,XL(""));		
		}
	}

}