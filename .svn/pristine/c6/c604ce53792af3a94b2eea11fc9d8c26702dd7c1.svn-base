#include "lightapp_iq_callback.h"
#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include "glooxWrapInterface.h"
#include "../gloox_src/error.h"
namespace gloox
{


	LightAppIQCallback::LightAppIQCallback( Result_Callback callback ):callback_(callback)
	{

	}

	bool LightAppIQCallback::handleIq( const IQ& iq )
	{
		return true;
	}
	void LightAppIQCallback::handleIqID( const IQ& iq, int context )
	{
		json::jobject jobj;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			const Error* e = iq.error();
			if (!e)
			{
				ELOG("app")->error(WCOOL(L"LightApp IQ消息失败： ")+ boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
				if (!callback_.empty())
				{
					callback_(true,XL(""));
				}
				return;
			}
		}else{
			if (!callback_.empty())
			{
				callback_(false,XL(""));		
			}
		}
	}

}