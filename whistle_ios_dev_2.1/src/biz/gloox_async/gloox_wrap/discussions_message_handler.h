/* 
 *
 * �ο�	 ����Ҫ���-�������Ҫ���˵����.docx 
 * ����	 ��������Ϣ��ȡ
 * �����ˣ�ȫ��
 * ����ʱ�䣺2012.12.14
 */

#pragma once
#include <boost/shared_ptr.hpp>
#include <base/utility/singleton/singleton.hpp>
#include "../gloox_src/messagehandler.h"

namespace gloox {

	class DiscussionsMessageHandler :public MessageHandler
	{
		template<class> friend struct boost::utility::singleton_holder;
	public:
		DiscussionsMessageHandler();
		virtual ~DiscussionsMessageHandler();
		DiscussionsMessageHandler* get(){ return this;};

		//handle message ��Ϣ
		virtual void handleMessage( const Message& msg, MessageSession* session = 0 );
	};

	typedef boost::utility::singleton_holder<DiscussionsMessageHandler> g_discussionsMessageHandler;
};