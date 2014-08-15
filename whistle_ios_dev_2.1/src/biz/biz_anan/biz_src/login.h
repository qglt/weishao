//---------------------------------------------------
// Copyright (C) 2012, All rights reserved
//
// descrption: entrypoint file.
// ver: 2.0
// auther: majiazhi
// date: (YMD)2012/07/04
//---------------------------------------------------

#pragma once
#include "boost/function.hpp"
#include "boost/shared_ptr.hpp"
#include "boost/signal.hpp"
#include "boost/thread.hpp"
#include "anan_biz_bind.h"
#include "gloox_src/gloox.h"
#include "gloox_src/error.h"
#include "gloox_src/connectionlistener.h"
#include <string>
#include "anan_type.h"
#include "biz_presence_type.h"
#include "agent_type.h"
#include "gloox_src/eventhandler.h"
#include "base/universal_res/uni_res.h"
#include "base/json/tinyjson.hpp"
#include "conn_msm.h"

namespace gloox{ class Client; }

namespace biz {

using namespace gloox;

struct anan_biz_impl;
struct login_impl;

typedef boost::function<void(bool,universal_resource,json::jobject)> LoginCallback;
class login : public anan_biz_bind<anan_biz_impl>,public ConnectionListener
{
	BIZ_FRIEND();
public:
	login();
	virtual ~login(void);

public:
	conn_msm_suply conn_msm_;

protected:
	LoginCallback login_callback_;

public:
	void to_login(json::jobject tsys_info,Tuser_info user, boost::function<void(bool, universal_resource,json::jobject)> callback);
	void to_logon(KPresenceType pt);
	void to_offline(boost::function<void(bool, universal_resource)> callback);
	void change_user(boost::function<void(bool, universal_resource)> callback);
 	void to_cancel(boost::function<void(bool, universal_resource)> callback);
 	void to_quit(boost::function<void(bool, universal_resource)> callback);
	void ui_query_state(boost::function<void(json::jobject)> callback);
	void get_user_really_passwd(std::string userName, std::string passWd, boost::function<void(std::string)> callback);
	void network_broken();
	void load_local_users( boost::function<void(std::list<Tuser_info>)> callback  );
	void user_can_change_password(boost::function<void(bool)> callback);
	int get_user_prelogin_presence();
	void to_pre_login();
	void prepare_login();
	void cloud_config_got();
	void to_login_with_got_config();
	json::jobject search_school(json::jobject jobj);
	json::jobject get_config_jobj();
protected: // ConnectionListener
	virtual void onConnect();
	virtual void onDisconnect( ConnectionError e );
	virtual bool onTLSConnect( const CertInfo& info );

	virtual void onResourceBind( const std::string& resource ) { (void)resource; }
	virtual void onResourceBindError( const Error* error ) { (void) (error); }
	virtual void onSessionCreateError( const Error* error ) { (void) (error); }
	virtual void onStreamEvent( StreamEvent event );

protected:
	void _KeepAlive();
	bool init_to_discontion(/*std::string const host, int port*/);
	void to_real_login(bool err,universal_resource res, json::jobject jobj);
	void processPasswdAndCertIt(Tuser_info& user);
	void to_offline_from_connected();
	void reset_gloox();
	void regist_to_gloox(gloox::Client* p_client);	
	void set_config_and_login(json::jobject jobj);
	void get_customize_login_config();
	void get_customize_cb(json::jobject old_config, bool succ, std::string result);
	void download_uri_callback( json::jobject config, bool succ, std::string uri);
private:	
	boost::shared_ptr<login_impl> impl_;
	_DECLARE_E();
};

}; //biz
