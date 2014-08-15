/* 
 *
 * �ο�	 ����Ҫ���-΢����֯�ṹ����.docx
 * ����	 : ��ʱ���ģ�ȡ����ʱ���Ĵ�����
 * �����ˣ�ȫ��
 * ����ʱ�䣺2013.03.13
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