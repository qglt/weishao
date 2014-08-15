#include <boost/function.hpp>
#include "base/json/tinyjson.hpp"
#include <base/utility/callback_def/callback_define.hpp>
#include "../gloox_src/iqhandler.h"

/* usage:
	struct me:public handler_helper_base<me>
	{
		void do_handleIqID(const IQ& iq, int context)
		{
			...
			do_callback(true, reason, data);
		}
	};
	pclient_->send(iq, new handler_helper<me>(callback), 0, true, false, false);
*/


template <class T>
class handler_helper_base:public gloox::IqHandler
{
public:
	bool handleIq( const  gloox::IQ& iq )
	{
		return ((T*)(this))->do_handle_iq(iq);
	}
	void handleIqID( const  gloox::IQ& iq, int context ){((T*)(this))->do_handleIqID(iq,context);}
protected:
	bool do_handle_iq(const  gloox::IQ& iq){return true;}
	void do_handleIqID(const  gloox::IQ& iq, int context){}
	virtual void do_callback(bool err, universal_resource reason, json::jobject data){}
private:
	Result_Data_Callback callback_;
};

template<class T>
class handler_helper:public T
{
public:
	handler_helper(Result_Data_Callback callback):callback_(callback){}
	void do_callback(bool err, universal_resource reason, json::jobject data)
	{
		callback_(err, reason, data);
	}
private:
	Result_Data_Callback callback_;
};