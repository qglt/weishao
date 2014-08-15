#include "growth_level_info_message_handler.h"
#include "glooxWrapInterface.h"
#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include "../gloox_src/message.h"


namespace gloox
{
	GrowthLevelInfoMessageHandler::GrowthLevelInfoMessageHandler()
	{
	}
	
	GrowthLevelInfoMessageHandler::~GrowthLevelInfoMessageHandler()
	{

	}

	void GrowthLevelInfoMessageHandler::handleMessage( const Message& msg, MessageSession* session /*= 0 */ )
	{
		if (!msg.from().bare().empty())
		{
			if(msg.findExtension(kExtUser_msg_filter_growthlevelinfo))
			{
				json::jobject jobj;
				boost::shared_ptr<gloox::Tag> tag = boost::shared_ptr<gloox::Tag>(msg.findExtension(kExtUser_msg_filter_growthlevelinfo)->tag());
				if (tag)
				{
					gloox::Tag* tchild(tag->findChild("item"));
					jobj["jid"] = tchild->findAttribute( "jid" );
					jobj["level"] = tchild->findAttribute( "level" );
					jobj["experience"] = tchild->findAttribute( "experience" );
					jobj["next_experience"] = tchild->findAttribute( "next_experience" );
					jobj["ver"] = tchild->findAttribute( "ver" );
				}
				gWrapInterface::instance().recv_growth_info_message(jobj);
			}
		}
	}

}