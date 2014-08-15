#include "lightapp_message_handler.h"
#include "glooxWrapInterface.h"
#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include "../gloox_src/message.h"

namespace gloox
{
	LightAppMessageHandler::LightAppMessageHandler()
	{
	}

	LightAppMessageHandler::~LightAppMessageHandler()
	{

	}

	/*
	kExtUser_msg_filter_creategroups
	*/

	void LightAppMessageHandler::handleMessage( const Message& msg, MessageSession* session /*= 0 */ )
	{
		gWrapInterface::instance().recv_lightapp_msg(msg , session);
	}
}