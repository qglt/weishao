/* 
 *
 * 参考	 ：概要设计-讨论组概要设计说明书.docx 
 * 功能	 ：所有消息收取
 * 创建人：全立
 * 创建时间：2012.12.14
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

		//handle message 消息
		virtual void handleMessage( const Message& msg, MessageSession* session = 0 );
	};

	typedef boost::utility::singleton_holder<DiscussionsMessageHandler> g_discussionsMessageHandler;
};