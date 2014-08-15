#pragma once
#include <boost/function.hpp>
#include "base/universal_res/uni_res.h"
#include "../gloox_src/iqhandler.h"
#include "base/json/tinyjson.hpp"
#include "../gloox_src/tag.h"
#include <base/utility/callback_def/callback_define.hpp>
#include "base/thread/thread_align/thread_align.hpp"
namespace gloox
{
	class findFriendHandler:public IqHandler
	{
	public:
		findFriendHandler(boost::function<void(bool,json::jobject)> callback);
		virtual bool handleIq( const IQ& iq );
		virtual void handleIqID( const IQ& iq, int context );
	private:
		boost::function<void(bool,json::jobject)> callback_;
	};
}