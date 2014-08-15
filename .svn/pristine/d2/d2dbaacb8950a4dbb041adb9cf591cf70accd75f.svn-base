/* 
 *
 * 参考	 ：概要设计-微哨组织结构管理.docx
 * 功能	 : 临时订阅，取消临时订阅处理类
 * 创建人：全立
 * 创建时间：2013.03.13
 */
#pragma once
#include <boost/function.hpp>
#include "base/universal_res/uni_res.h"
#include "../gloox_src/iqhandler.h"
#include "base/json/tinyjson.hpp"
#include "../gloox_src/tag.h"
#include <base/utility/callback_def/callback_define.hpp>


namespace gloox {

	class SendFileMsgHandler :public IqHandler
	{
	public:
		SendFileMsgHandler(boost::function<void(bool,universal_resource)> callback);
		virtual bool handleIq( const IQ& iq );
		virtual void handleIqID( const IQ& iq, int context );
	private:
		boost::function<void(bool,universal_resource)> callback_;
	};
}