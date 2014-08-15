#include "whistle_vcard_handler.h"
#include "gloox_src/error.h"
#include "gloox_wrap/basicStanza.hpp"
#include "whistle_vcard.h"

namespace biz{


	whistleVcardHandler::whistleVcardHandler(boost::function<void()> argCallback)
	{
		waitCallback_ = argCallback;
	}

	whistleVcardHandler::~whistleVcardHandler()
	{

	}

	bool whistleVcardHandler::handleIq( const IQ& iq )
	{
		return true;
	}

	void whistleVcardHandler::handleIqID( const IQ& iq, int context )
	{
		switch( iq.subtype() )
		{
		case IQ::Result:
			{
				switch( context )
				{
				case VCardHandler::FetchVCard:
					{
						json::jobject jobj;
						json::jobject status = json::jobject();
						if (iq.findExtension( ExtVCard ))
						{
							boost::shared_ptr<gloox::Tag> ptag(iq.findExtension( ExtVCard )->tag());
							for (TagList::const_iterator cit = ptag->children().begin(); cit != ptag->children().end(); ++cit) {
								Tag* ptag = *cit;
								if (ptag->name() == s_VcardPrivacy)
								{
									jobj[ptag->name()] = json::jobject(ptag->cdata());
								}
								else if (ptag->name() == s_VcardStatus)
								{
									//获取vcard协议改变 新的解析iq
									Tag* presource = ptag->findChild("resource");
									Tag* pshow = ptag->findChild("show");
									if ( presource && pshow)
									{
										json::jobject itemdata;
										itemdata["resource"] = presource->cdata();
										itemdata["show"] = pshow->cdata();
										status.arr_push(itemdata);
									}
								}
								else
								{
									jobj[ptag->name()] = ptag->cdata();
								}
							}
							jobj[s_VcardJid] = iq.from().bare();

							gwhistleVcard::instance().handleVCard(iq.from(), jobj, status, waitCallback_);
						}
						break;
					}
				case VCardHandler::StoreVCard:
					gwhistleVcard::instance().handleVCardResult(VCardHandler::StoreVCard, iq.from());
					break;
				}
			}
			break;
		case IQ::Error:
			{
				switch( context )
				{
				case VCardHandler::FetchVCard:
					if (!waitCallback_.empty())
					{
						waitCallback_();
					}
					else
					{
						gwhistleVcard::instance().updatedVcard(iq.from());
					}
					break;
				case VCardHandler::StoreVCard:
					gwhistleVcard::instance().handleVCardResult( (VCardHandler::VCardContext)context,
						iq.from(),
						iq.error() ? iq.error()->error()
						: StanzaErrorUndefined );
					break;
				}
			}
		default:
			break;
		}
	}
}


