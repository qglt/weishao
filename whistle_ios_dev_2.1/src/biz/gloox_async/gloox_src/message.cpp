/*
  Copyright (c) 2007-2012 by Jakob Schroeter <js@camaya.net>
  This file is part of the gloox library. http://camaya.net/gloox

  This software is distributed under a license. The full license
  agreement can be found in the file LICENSE in this distribution.
  This software may not be copied, modified, sold or distributed
  other than expressed in the named license agreement.

  This software is distributed without any warranty.
*/

#include "util.h"
#include "message.h"
#include <base/txtutil/txtutil.h>
#include <boost/lexical_cast.hpp>
#include <boost/date_time/gregorian/conversion.hpp>
#include <base/log/elog/elog.h>
#include <boost/format.hpp>
#include <base/time/time_format.h>
#include <boost/date_time/c_local_time_adjustor.hpp>


namespace gloox
{

  static const char* msgTypeStringValues[] =
  {
    "chat", "error", "groupchat", "headline", "normal"
  };

  static inline const std::string typeString( Message::MessageType type )
  {
    return util::lookup2( type, msgTypeStringValues );
  }

  Message::Message( Tag* tag )
    : Stanza( tag ), m_subtype( Invalid ), m_htmls(0), m_bodies( 0 ), m_subjects( 0 )
  {
    if( !tag || tag->name() != "message" )
      return;

    const std::string& typestring = tag->findAttribute( TYPE );
    if( typestring.empty() )
      m_subtype = Normal;
    else
      m_subtype = (MessageType)util::lookup2( typestring, msgTypeStringValues );

    const TagList& c = tag->children();
    TagList::const_iterator it = c.begin();
    for( ; it != c.end(); ++it )
    {
      if( (*it)->name() == "body" )
        setLang( &m_bodies, m_body, (*it) );
      else if( (*it)->name() == "subject" )
        setLang( &m_subjects, m_subject, (*it) );
	  else if( (*it)->name() == "html" )
		setLang( &m_htmls, m_html, (*it) );
      else if( (*it)->name() == "thread" )
        m_thread = (*it)->cdata();
    }
  }

  Message::Message( MessageType type, const JID& to,
                    const std::string& body, const std::string& subject, const std::string& html,
                    const std::string& thread, const std::string& xmllang )
    : Stanza( to ), m_subtype( type ), m_htmls(0), m_bodies( 0 ), m_subjects( 0 ), m_thread( thread )
  {
    setLang( &m_bodies, m_body, body, xmllang );
	setLang( &m_subjects, m_subject, subject, xmllang );
	setLang( &m_htmls, m_html, html, xmllang );
  }

  Message::~Message()
  {
    delete m_bodies;
    delete m_subjects;
	delete m_htmls;
  }

  Tag* Message::tag() const
  {
    if( m_subtype == Invalid )
      return 0;

    Tag* t = new Tag( "message" );
    if( m_to )
      t->addAttribute( "to", m_to.full() );
    if( m_from )
      t->addAttribute( "from", m_from.full() );
	if( !m_id.empty() )
		t->addAttribute( "id", m_id );
	if( !m_timestamp.empty() )
		t->addAttribute( "timestamp", m_timestamp );
    t->addAttribute( TYPE, typeString( m_subtype ) );

    getLangs( m_bodies, m_body, "body", t );
	getLangs( m_subjects, m_subject, "subject", t );
	getLangs( m_htmls, m_html, "html", t );

    if( !m_thread.empty() )
      new Tag( t, "thread", m_thread );

    StanzaExtensionList::const_iterator it = m_extensionList.begin();
    for( ; it != m_extensionList.end(); ++it )
      t->addChild( (*it)->tag() );

    return t;
  }

  const std::string Message::timestamp() const
  {
	  if (!m_timestamp.empty())
	  {
		  boost::posix_time::ptime t = boost::posix_time::from_time_t(boost::lexical_cast<intmax_t>(m_timestamp)/1000/*+diff_secs*/);
		  boost::posix_time::ptime local_time = boost::date_time::c_local_adjustor<boost::posix_time::ptime>::utc_to_local(t);
		  return  epius::time_format(local_time);
	  }
	  else
	  {
		  return "";
	  }
  }
}
