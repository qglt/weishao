#ifndef whistleVcardHandler_H__
#define whistleVcardHandler_H__
#pragma once
#include "gloox_src/iqhandler.h"
#include "boost/function.hpp"

namespace biz {

	using namespace gloox;

	class whistleVcardHandler : public IqHandler
	{
		public:
			whistleVcardHandler(boost::function<void()> argCallback);
			virtual ~whistleVcardHandler();

			virtual bool handleIq( const IQ& iq );
			virtual void handleIqID( const IQ& iq, int context );

		private:
			boost::function<void()> waitCallback_;
	};
}

#endif