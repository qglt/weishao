#include <boost/shared_ptr.hpp>
#include <base/utility/singleton/singleton.hpp>
#include "../gloox_src/messagehandler.h"
#include "../gloox_src/messagesessionhandler.h"

namespace gloox {

	class GrowthLevelInfoMessageHandler :public MessageHandler
	{
		template<class> friend struct boost::utility::singleton_holder;
	public:
		GrowthLevelInfoMessageHandler();
		virtual ~GrowthLevelInfoMessageHandler();
		GrowthLevelInfoMessageHandler* get(){ return this;};
		//handle message ÏûÏ¢
		virtual void handleMessage( const Message& msg, MessageSession* session = 0 );
	};

	typedef boost::utility::singleton_holder<GrowthLevelInfoMessageHandler> g_growthlevelinfoMessageHandler;
};