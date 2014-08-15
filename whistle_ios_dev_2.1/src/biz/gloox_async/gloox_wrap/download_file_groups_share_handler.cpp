#include "download_file_groups_share_handler.h"
#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include "glooxWrapInterface.h"
#include "../gloox_src/error.h"
namespace gloox
{


	DownloadFileGroupsShareHandler::DownloadFileGroupsShareHandler( Result_Callback callback ):callback_(callback)
	{

	}

	bool DownloadFileGroupsShareHandler::handleIq( const IQ& iq )
	{
		return true;
	}
	/*
	　<iq type=’result’from=’112@groups.ruijie.com.cn’ to=’123456@ruijie.com.cn’>
	 <queryxmlns=’groups:share:file:download’>
	 <item id=‘1’/>
	 </query>
	 </iq>


	*/
	void DownloadFileGroupsShareHandler::handleIqID( const IQ& iq, int context )
	{
		json::jobject jobj;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			const Error* e = iq.error();
			if (!e)
			{
				callback_(true,XL("biz.DownloadFileGroupsShare.fail"));
				return;
			}

			if ( e->error() == StanzaErrorBadRequest)
			{
				ELOG("app")->error(WCOOL(L"下载共享文件时，请求协议错误！。"));
				callback_(true,XL("biz.crwod.iq_error.bad-request"));
			}
			else if (e->error() == StanzaErrorInternalServerError)
			{
				ELOG("app")->error(WCOOL(L"下载共享文件时，处理错误(服务器处理错误)。"));
				callback_(true,XL("biz.crwod.iq_error.internal-server-error"));
			}
			else if (e->error() == StanzaErrorGone)
			{
				ELOG("app")->error(WCOOL(L"下载共享文件时，文件已被删除。但是文件已被正常下载！！"));
				callback_(false,XL(""));
			}
			else if (e->error() == StanzaErrorItemNotFound)
			{
				ELOG("app")->error(WCOOL(L"下载共享文件时，找不到此群。"));
				callback_(true,XL("biz.crwod.iq_error.item-not-found"));
			}else
			{
				ELOG("app")->error(WCOOL(L"下载共享文件时,服务器返回未知错误类型！") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
				callback_(true,XL("biz.DownloadFileGroupsShare.fail"));
			}

		}else{
			callback_(false,XL(""));		
		}
	}

}