/*
  Copyright (c) 2007-2012 by Jakob Schroeter <js@camaya.net>
  This file is part of the gloox library. http://camaya.net/gloox

  This software is distributed under a license. The full license
  agreement can be found in the file LICENSE in this distribution.
  This software may not be copied, modified, sold or distributed
  other than expressed in the named license agreement.

  This software is distributed without any warranty.
*/

#include "iq.h"
#include "util.h"
#include "../../biz_anan/biz_src/statistics_data.h"
#include <boost/format.hpp>
namespace gloox
{

  static const char * iqTypeStringValues[] =
  {
    "get", "set", "result", "error"
  };

  static inline const char* typeString( IQ::IqType type )
  {
    return iqTypeStringValues[type];
  }

  IQ::IQ( Tag* tag )
    : Stanza( tag ), m_subtype( Invalid )
  {
    if( !tag || tag->name() != "iq" )
      return;

    m_subtype = (IQ::IqType)util::lookup( tag->findAttribute( TYPE ), iqTypeStringValues );
  }

  IQ::IQ( IqType type, const JID& to, const std::string& id )
    : Stanza( to ), m_subtype( type )
  {
    m_id = id;
  }

  IQ::~IQ()
  {
  }

  Tag* IQ::tag() const
  {
    if( m_subtype == Invalid )
      return 0;

    Tag* t = new Tag( "iq" );
    if( m_to )
      t->addAttribute( "to", m_to.full() );
    if( m_from )
      t->addAttribute( "from", m_from.full() );
    if( !m_id.empty() )
      t->addAttribute( "id", m_id );
    t->addAttribute( TYPE, typeString( m_subtype ) );

    StanzaExtensionList::const_iterator itex = m_extensionList.begin();
    for( ; itex != m_extensionList.end(); ++itex )
	{
      t->addChild( (*itex)->tag() );
	  if ( (*itex)->extensionType() == ExtPing)
	  {
		  // 添加统计数据tag
		  std::map<std::string, int> data;
		  biz::g_statistics_data::instance().get_data(data);
		  if (data.size())
		  {
			  Tag* chat_tag = NULL;
			  Tag* file_transfer_tag = NULL;
			  Tag* ui_tag = NULL;
			  Tag* apps_tag = NULL;
			  std::map<std::string, int>::iterator itdata=data.begin();
			  for (; itdata!=data.end(); itdata++)
			  {
				  if (itdata->first == "chat_msg_count" || itdata->first == "discussions_msg_count" || itdata->first == "groups_msg_count")
				  {
					  if (!chat_tag)
					  {
						  chat_tag = new Tag("chat");
					  }

					  Tag* tmp = new Tag(itdata->first);
					  tmp->addCData(boost::str(boost::format("%d")%itdata->second));
					  chat_tag->addChild(tmp);
				  }else if (itdata->first == "send_file_size" || itdata->first == "send_file_actual_size" || itdata->first == "send_file_actual_time" 
					  || itdata->first == "recv_file_count" || itdata->first == "recv_file_size" || itdata->first == "recv_file_actual_size" || itdata->first == "recv_file_actual_time")
				  {
					  if (!file_transfer_tag)
					  {
						  file_transfer_tag = new Tag("file_transport");
					  }

					  Tag* tmp = new Tag(itdata->first);
					  tmp->addCData(boost::str(boost::format("%d")%itdata->second));
					  file_transfer_tag->addChild(tmp);

				  }else if (itdata->first == "send_file_count")
				  {
					  if (!file_transfer_tag)
					  {
						  file_transfer_tag = new Tag("file_transport");
					  }

					  Tag* tmp = new Tag(itdata->first);
					  tmp->addCData(boost::str(boost::format("%d")%itdata->second));
					  file_transfer_tag->addChild(tmp);

					  if (!ui_tag)
					  {
						  ui_tag = new Tag("ui");
					  }

					  tmp = new Tag(itdata->first);
					  tmp->addCData(boost::str(boost::format("%d")%itdata->second));
					  ui_tag->addChild(tmp);
				  }else if (itdata->first == "screenshot_count" || itdata->first == "system_face_count" || itdata->first == "custom_face_count" || itdata->first == "send_picture_count")
				  {
					  if (!ui_tag)
					  {
						  ui_tag = new Tag("ui");
					  }

					  Tag* tmp = new Tag(itdata->first);
					  tmp->addCData(boost::str(boost::format("%d")%itdata->second));
					  ui_tag->addChild(tmp);
				  }
				  else//for apps
				  {
					  if(!apps_tag)apps_tag = new Tag("apps");
					  Tag* tmp = new Tag(itdata->first);
					  tmp->addCData(boost::str(boost::format("%d")%itdata->second));
					  apps_tag->addChild(tmp);
				  }
			  }

			  if (chat_tag || file_transfer_tag || ui_tag || apps_tag)
			  {
				  time_t now;
				  time(&now);
				  Tag* statistics_tag = new Tag("statistics");
				  statistics_tag->addAttribute("timestamp", (int)now);
				  if (chat_tag)
				  {
					  statistics_tag->addChild(chat_tag);
				  }
				  if (file_transfer_tag)
				  {
					  statistics_tag->addChild(file_transfer_tag);
				  }
				  if (ui_tag)
				  {
					  statistics_tag->addChild(ui_tag);
				  }
				  if (apps_tag)
				  {
					  statistics_tag->addChild(apps_tag);
				  }

				  t->addChild(statistics_tag);
			  }  
		  }
	  }
	}

    return t;
  }

}
