#include "filedak_message_handler.h"
#include "glooxWrapInterface.h"
#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include "../gloox_src/message.h"

namespace gloox
{
	FiledakMessageHandler::FiledakMessageHandler()
	{
	}

	FiledakMessageHandler::~FiledakMessageHandler()
	{

	}

	void FiledakMessageHandler::handleMessage( const Message& msg, MessageSession* session /*= 0 */ )
	{
		if (!msg.from().bare().empty() && !msg.html().empty())
		{
			if(msg.findExtension(kExtUser_msg_filter_filedak_message))
			{
				std::string fileid;
				boost::shared_ptr<gloox::Tag> filetag = boost::shared_ptr<gloox::Tag>(msg.findExtension(kExtUser_msg_filter_filedak_message)->tag());
				if (filetag)
				{
					fileid = filetag->findAttribute("id");
				}
				json::jobject jmsg;
				jmsg["resource"] = msg.from().resource();
				jmsg["from"] = msg.from().bare();
				json::jobject jobj(msg.html());
				jobj["id"] = fileid;
				jmsg["html"] = jobj.to_string();

				gWrapInterface::instance().filedak_get_message(jmsg);
			}
		}
	}

}