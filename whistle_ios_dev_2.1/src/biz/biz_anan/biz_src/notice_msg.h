#pragma once
#include "anan_biz_bind.h"
#include "boost/function.hpp"
#include "boost/shared_ptr.hpp"
#include "base/json/tinyjson.hpp"
#include "anan_type.h"
#include <string>
#include "iq_filter.h"
#include "base/universal_res/uni_res.h"
#include "gloox_src/iqhandler.h"
#include "gloox_src/messagesessionhandler.h"
#include "gloox_src/messageeventhandler.h"
#include "gloox_src/messagehandler.h"
#include "event_collection.h"
namespace biz {
 	using namespace gloox;
	struct notice_msg_impl;
	struct anan_biz_impl;
	

class AnClient;
class notice_msg : public anan_biz_bind<anan_biz_impl>,
	public IqHandler,
	public MessageSessionHandler,
	public MessageHandler
{
	BIZ_FRIEND();
public:
	notice_msg(void);
	virtual ~notice_msg(void);
public:
	void publish(json::jobject jobj, UIVCallback callback);
	void notice_result( UIVCallback callback );
	void sam_publish_notice(json::jobject jobj);

	bool is_need_download_icon(json::jobject& service, std::string &download_path );
	void finished_syncdown_icon(std::string service_id, std::string service_name, std::string download_path, bool succ, std::string uri_string);

protected: // MessageSessionHandler
	virtual void handleMessage( const Message& msg, MessageSession* session = 0 );
	virtual void handleMessageSession( MessageSession* session );

	void regist_to_gloox( AnClient* p_client );
public: // IqHandler
	virtual bool handleIq( const IQ& iq );
	virtual void handleIqID( const IQ& iq, int context );
private:
	boost::shared_ptr<notice_msg_impl> impl_;
};


};