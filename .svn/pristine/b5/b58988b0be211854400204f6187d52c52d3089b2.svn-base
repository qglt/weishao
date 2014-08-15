/* 
 *
 * 参考	 ：概要设计-讨论组概要设计说明书.docx 协议3.6
 * 功能	 ：邀请他人进入讨论组
 * 创建人：全立
 * 创建时间：2012.12.13
 */
#pragma once
#include <boost/function.hpp>
#include "base/universal_res/uni_res.h"
#include "../gloox_src/iqhandler.h"
#include "base/json/tinyjson.hpp"
#include "../gloox_src/tag.h"
#include <base/utility/callback_def/callback_define.hpp>


namespace gloox {

	class InviteDiscussionsHandler :public IqHandler
	{
	public:
		InviteDiscussionsHandler(Result_Data_Callback callback);
		virtual bool handleIq( const IQ& iq );
		virtual void handleIqID( const IQ& iq, int context );
	private:
		Result_Data_Callback callback_;
	};
}