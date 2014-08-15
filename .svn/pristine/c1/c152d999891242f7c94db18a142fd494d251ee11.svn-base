#include "upload_file_groups_share_handler.h"
#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include "glooxWrapInterface.h"
#include "../gloox_src/error.h"
namespace gloox
{


	UploadFileGroupsShareHandler::UploadFileGroupsShareHandler( Result_Callback callback ):callback_(callback)
	{

	}

	bool UploadFileGroupsShareHandler::handleIq( const IQ& iq )
	{
		return true;
	}
	/*
	　<iq type=’result’from=’112@groups.ruijie.com.cn’ to=’123456@ruijie.com.cn’>
	 <queryxmlns=’groups:share:file:create’>
	 <item id=‘2’
	 filename=”苍老师.avi” size=”80000” owner=”123456@ruijie.com.cn”
	 nick_name=”奥巴马”
	 uri=”http://file.ruijie.com.cn/downlaod/xxxx.xx” />
	 </query>
	 </iq>

	*/
	void UploadFileGroupsShareHandler::handleIqID( const IQ& iq, int context )
	{
		json::jobject jobj;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			const Error* e = iq.error();
			if (!e)
			{
				callback_(true,XL("biz.UploadFileGroupsShare.fail"));
				return;
			}

			if ( e->error() == StanzaErrorBadRequest)
			{
				ELOG("app")->error(WCOOL(L"上传共享文件时，请求协议错误！。"));
				callback_(true,XL("biz.crwod.iq_error.bad-request"));
			}
			else if (e->error() == StanzaErrorInternalServerError)
			{
				ELOG("app")->error(WCOOL(L"上传共享文件时，处理错误(服务器处理错误)。"));
				callback_(true,XL("biz.crwod.iq_error.internal-server-error"));
			}
			else if (e->error() == StanzaErrorItemNotFound)
			{
				ELOG("app")->error(WCOOL(L"上传共享文件时，找不到此群。"));
				callback_(true,XL("biz.crwod.iq_error.item-not-found"));
			}else
			{
				ELOG("app")->error(WCOOL(L"上传共享文件时,服务器返回未知错误类型！") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
				callback_(true,XL("biz.UploadFileGroupsShare.fail"));
			}
		}else{
			callback_(false,XL(""));		
		}
	}

}