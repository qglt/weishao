
#ifndef privilegeHandler_H__
#define privilegeHandler_H__

#pragma once
#include <boost/function.hpp>
#include "base/universal_res/uni_res.h"
#include "../gloox_src/iqhandler.h"
#include "base/json/tinyjson.hpp"
#include "../gloox_src/tag.h"
#include "../gloox_src/client.h"
typedef boost::function<void(bool, universal_resource, json::jobject)> GlooxWrapCallback;

namespace gloox {

	class privilegeHandler :public IqHandler
	{
	public:
		privilegeHandler( Client* client, GlooxWrapCallback callback);
		virtual bool handleIq( const IQ& iq );
		virtual void handleIqID( const IQ& iq, int context );
	private:
		GlooxWrapCallback callback_;
		Client * pclient_;
	};

	class iq_privilege : public StanzaExtension
      {
        public:
          /**
           * Constructs a new Offline object from the given Tag.
           * @param tag The Tag to parse.
           */
          iq_privilege( const Tag* tag = 0 );

          /**
           * Constructs a new Offline object for the given context and messages.
           * @param context The context.
           * @param msgs The messages.
           */
          iq_privilege( int context, const StringList& msgs );

          /**
           * Virtual destructor.
           */
          virtual ~iq_privilege();

          // reimplemented from StanzaExtension
          virtual const std::string& filterString() const;

          // reimplemented from StanzaExtension
          virtual StanzaExtension* newInstance( const Tag* tag ) const
          {
            return new iq_privilege( tag );
          }

          // reimplemented from StanzaExtension
          virtual Tag* tag() const;

          // reimplemented from StanzaExtension
          virtual StanzaExtension* clone() const
          {
            return new iq_privilege( *this );
          }

        private:
          gloox::Tag* m_privilegetag;
      };

};

#endif