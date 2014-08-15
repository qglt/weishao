
#pragma once
#include <boost/function.hpp>
#include "base/universal_res/uni_res.h"
#include "../gloox_src/iqhandler.h"
#include "base/json/tinyjson.hpp"
#include "../gloox_src/tag.h"
#include <base/utility/callback_def/callback_define.hpp>


namespace gloox {

	class LeaveGroupsHandler :public IqHandler
	{
	public:
		LeaveGroupsHandler( );

		virtual bool handleIq( const IQ& iq );
		virtual void handleIqID( const IQ& iq, int context );
	private:
	};
}