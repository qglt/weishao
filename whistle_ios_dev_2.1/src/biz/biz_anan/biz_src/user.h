#pragma once
#include "boost/smart_ptr.hpp"
#include "boost/signal.hpp"
#include "boost/function.hpp"
#include "base/json/tinyjson.hpp"
#include "anan_biz_bind.h"
#include "biz_presence_type.h"
#include "anan_type.h"
#include "gloox_src/tag.h"
#include "gloox_src/privatexmlhandler.h"
#include "user_type.h"
#include "agent_type.h"
#include "base/universal_res/uni_res.h"
#include <base/thread/time_thread/time_thread.h>
namespace biz {
	using namespace gloox;
	class user_impl;
	struct anan_biz_impl;
	class AnClient;

class user : public anan_biz_bind<anan_biz_impl>
{
	enum KUser_presence_scheme {
		kups_do_nothing,
		kups_by_logon,
		kups_direct_do
	};

public:
	user(void);
	virtual ~user(void);

	boost::signal<void(std::string /*seqID*/,
		std::string /*error*/,
		std::map<std::string, std::string> /*userInfo*/ )> recvUserInfo_;

public:
	void set_Presence(KPresenceType presence);
	void set_Presence(std::string msg = "");
	KPresenceType syncquery_MyPresence();
	//取历史通知
	void loadNoticeMessage(int offset, int count,boost::function<void(json::jobject)> callback );
	void loadOneNoticeMessage(std::string id_string,boost::function<void(json::jobject)> callback );

	void loadMessage( std::string type_string, std::string id_string, int offset, int count, boost::function<void(json::jobject)> callback );
	void loadpublishMessage(std::string id_string,boost::function<void(json::jobject)> callback );
	
	void loadUnReadMessage( std::string type_string, std::string id_string, bool mark_read, boost::function<void(json::jobject)> callback );
	void loadUnReadMessageCount( boost::function<void(json::jobject)> callback );
	void MarkMessageRead(std::string type_string, std::string id_string);
	void disposeMessage( json::jobject jobj, UIVCallback callback );
 	std::string get_userName() const;
	void get_privilege(boost::function<void(bool err, universal_resource res, json::jobject data)> callback);	
	void unregist_to_gloox( AnClient* p_client );
	Tuser_info const& get_user();
	void set_user(Tuser_info const& user);
	void inner_set_presence(KPresenceType presence);
	void store_data(std::string private_ns, std::string str, PrivateXMLHandler* callback);
	void get_data(std::string private_ns, PrivateXMLHandler* callback);
	void regist_to_gloox( AnClient* p_client );

protected:
	void connected();
	void disconnection(universal_resource res);
	KUser_presence_scheme switch_scheme_by_login_state();
	void notice_presence();

private:
	boost::shared_ptr<user_impl> impl_;
};

}; // biz