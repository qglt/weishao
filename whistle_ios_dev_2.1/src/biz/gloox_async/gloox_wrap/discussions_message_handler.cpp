#include "discussions_message_handler.h"
#include "glooxWrapInterface.h"
#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include "../gloox_src/message.h"
#include <boost/assign/list_of.hpp>
#include <map>

namespace gloox
{
	using namespace boost::assign;
	static std::map<std::string, std::string> status_map = map_list_of("Online", "Online")("Offline", "Offline")("away","Away")("xa","Away")("dnd", "Busy")("invisible","Invisible");
	DiscussionsMessageHandler::DiscussionsMessageHandler()
	{
	}

	DiscussionsMessageHandler::~DiscussionsMessageHandler()
	{

	}

	void DiscussionsMessageHandler::handleMessage( const Message& msg, MessageSession* session /*= 0 */ )
	{
		//讨论组列表更新
		if(msg.findExtension(kExtUser_msg_filter_discussionslistchange))
		{
			boost::shared_ptr<gloox::Tag> tag(msg.findExtension(kExtUser_msg_filter_discussionslistchange)->tag());
			if (tag)
			{
				json::jobject jobj;
				std::string type = tag->findAttribute("type");
				jobj["type"] = type;
				if (type == "modify")
				{
					//讨论组修改主题
					/*
					<message type="headline" from="3841@discussions.wuyiu.edu.cn" to="392@wuyiu.edu.cn">
					<x xmlns="list" type="modify">
					<actor uid="392" name="test6"/>
					<item id="3841" topic="whistler"/>
					</x>
					</message>		
					*/
					std::string uid = tag->findChild("actor")->findAttribute("uid");
					std::string name = tag->findChild("actor")->findAttribute("name");
					std::string id = tag->findChild("item")->findAttribute("id");
					std::string topic = tag->findChild("item")->findAttribute("topic");
					jobj["uid"] = uid;
					jobj["name"] = name;
					jobj["id"] = gWrapInterface::instance().append_discussions_domain(id);
					jobj["topic"] = topic;
				}
				else
 				{
					//循环取得item
					gloox::TagList items;
					items = tag->findChildren("item");
					TagList::const_iterator it = items.begin();
					for( ; it != items.end(); ++it )
					{
						json::jobject group;
						std::string did = gWrapInterface::instance().append_discussions_domain((*it)->findAttribute("id"));
						std::string topic = (*it)->findAttribute( "topic" );
						group["session_id"] = did;
						group["group_name"] = topic;

						if (type.compare("add") != 0 && type.compare("remove") != 0	&& type.compare("modify") != 0 && type.compare("destroy") != 0 )
						{
							ELOG("app")->error(WCOOL(L"未知的操作类型 : ") + type);
						}

						jobj["group_info"].arr_push(group);
					}
 				}
				gWrapInterface::instance().discussions_list_change(jobj);
			}
			return;
		}

		//讨论组成员更新
		if(msg.findExtension(kExtUser_msg_filter_discussionsmemberchange))
		{
			boost::shared_ptr<gloox::Tag> tag(msg.findExtension(kExtUser_msg_filter_discussionsmemberchange)->tag());
			if (tag)
			{
				json::jobject jobj;
				std::string type = tag->findAttribute("type");
				jobj["type"] = type;
				jobj["session_id"] = msg.from().bare();

				//循环取得item
				gloox::TagList items;
				items = tag->findChildren("item");
				TagList::const_iterator it = items.begin();
				for( ; it != items.end(); ++it )
				{
					if ((*it)->findAttribute( "userid" ).empty())
					{
						ELOG("app")->error(WCOOL(L"收到讨论组成员更新通知 成员jid是空 : ") + (*it)->xml());
						continue;
					}

					json::jobject member;
					member["jid"] = (*it)->findAttribute( "userid" ) + "@" + gWrapInterface::instance().get_domain();

					if (!(*it)->findAttribute( "name" ).empty())
					{
						member["showname"] = (*it)->findAttribute( "name" );
					}
					
					if (!(*it)->findAttribute( "status" ).empty())
					{
						member["presence"] = status_map[(*it)->findAttribute( "status" )];
					}
					
					if (!(*it)->findAttribute( "sex" ).empty())
					{
						member["sex"] = (*it)->findAttribute( "sex" );
					}
					
					if (!(*it)->findAttribute( "identity" ).empty())
					{
						member["identity"] = (*it)->findAttribute( "identity" );
					}
					
					if (!(*it)->findAttribute( "photo_credential" ).empty())
					{
						member["photo_credential"] = (*it)->findAttribute( "photo_credential" );
					}

					jobj["member_info"].arr_push(member);
				}

				gWrapInterface::instance().discussions_member_change(jobj);
			}
			return;
		}

		//讨论组会话
		if (!msg.from().resource().empty() && !msg.from().bare().empty() && !msg.html().empty())
		{
			gWrapInterface::instance().discussions_get_image(msg, session);

			if(msg.findExtension(kExtUser_msg_filter_messageid))
			{
				std::string id = boost::shared_ptr<gloox::Tag>(msg.findExtension(kExtUser_msg_filter_messageid)->tag())->cdata();

				json::jobject jmsg;
				jmsg["jid"] = msg.from().resource();
				jmsg["from"] = msg.from().bare();
				jmsg["html"] = msg.html();
				jmsg["id"] = id;

				gWrapInterface::instance().discussions_get_message(jmsg);
			}
		}	
	}

}



