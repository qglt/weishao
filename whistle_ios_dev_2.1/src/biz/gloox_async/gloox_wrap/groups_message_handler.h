#pragma once
#include <boost/shared_ptr.hpp>
#include <base/utility/singleton/singleton.hpp>
#include "../gloox_src/messagehandler.h"

namespace gloox {

	class GroupsMessageHandler :public MessageHandler
	{
		template<class> friend struct boost::utility::singleton_holder;
	public:
		GroupsMessageHandler();
		virtual ~GroupsMessageHandler();
		GroupsMessageHandler* get(){ return this;};

		//handle message ÏûÏ¢
		virtual void handleMessage( const Message& msg, MessageSession* session = 0 );
	};

	typedef boost::utility::singleton_holder<GroupsMessageHandler> g_groupsMessageHandler;
};