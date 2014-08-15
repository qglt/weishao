// Copyright (C) 2012, All rights reserved
//
// descrption: entrypoint file.
// ver: 2.0
// auther: majiazhi
// date: (YMD)2012/07/04
//---------------------------------------------------
#include <boost/assign/list_of.hpp>
#include <base/utility/uuid/uuid.hpp>
#include <base/http_trans/http_request.h>
#include "base/universal_res/uni_res.h"
#include <base/thread/time_thread/time_thread_mgr.h>
#include "gloox_src/AsyncConnectionTcpClient.h"
#include "gloox_src/compressiondefault.h"
#include "gloox_src/disco.h"
#include <gloox_wrap/glooxWrapInterface.h>
#include "anan_biz_impl.h"
#include "anan_assert.h"
#include "agent.h"
#include "client_anan.h"
#include "agent_impl.h"
#include "user.h"
#include "user_impl.h"
#include "conversation.h"
#include "local_config.h"
#include "anan_config.h"
#include "biz_app_settings.h"
#include "biz_recent_contact.h"
#include "login.h"

#ifdef _WIN32
#include "courses.h"
#endif

#ifdef __APPLE__
#include "TargetConditionals.h"
#endif
#include "base/module_path/epfilesystem.h"
#include "base/local_search/local_search.h"
#include "base/cmd_factory/cmd_factory.h"

using namespace std;
using namespace boost;
using namespace boost::assign;
namespace biz 
{
	using namespace gloox;

#ifdef _MJZ_TEST_interval_
	static const int sKeeyAliveInterval = 5*60*100;
#else
	static const int sKeeyAliveInterval = 5*60*1000;
#endif


	struct login_impl
	{
		login_impl()
		{

		}
		/*
		tmp_passwd_to_real_passwd is in such format:
		tmp_passwd_to_real_passwd[user_sam_id][fake_password]=real_password
		*/
		json::jobject tmp_passwd_to_real_passwd;
		Tuser_info user_prelogin_;
		json::jobject tsys_info_;
		json::jobject school_list_jobj_;
		json::jobject user_select_;
		json::jobject config_jobj_;
	};
#define VAL_NAME(x) (x,"biz.conn."#x)
	static map<ConnectionError, string> error_map_value2string = map_list_of(ConnNoError, "biz.conn.ConnNoError")\
		VAL_NAME(ConnStreamError) VAL_NAME(ConnStreamVersionError) VAL_NAME(ConnStreamClosed)\
		VAL_NAME(ConnProxyAuthRequired) VAL_NAME(ConnProxyAuthFailed) VAL_NAME(ConnProxyNoSupportedAuth)\
		VAL_NAME(ConnParseError) VAL_NAME(ConnConnectionRefused)\
		VAL_NAME(ConnDnsError) VAL_NAME(ConnOutOfMemory) VAL_NAME(ConnNoSupportedAuth)\
		VAL_NAME(ConnTlsFailed) VAL_NAME(ConnTlsNotAvailable) VAL_NAME(ConnCompressionFailed)\
		VAL_NAME(ConnAuthenticationFailed) VAL_NAME(ConnUserDisconnected) VAL_NAME(ConnNotConnected);


	login::login(): impl_( new login_impl())
	{
		conn_msm_.set_owner(this);
	}

	login::~login(void)
	{
	}

	void login::onConnect()
	{
		if(!login_callback_.empty())
		{
			json::jobject jobj;
			login_callback_(false,XL(""),jobj);
			login_callback_ = LoginCallback();
		}

		get_parent_impl()->bizUser_->inner_set_presence((KPresenceType)impl_->user_prelogin_.presence);
		Tuser_info info = get_parent_impl()->bizUser_->get_user();
		info.last_login_time = boost::posix_time::second_clock::local_time();
		get_parent_impl()->bizUser_->set_user(info);

		// 3分钟后取个性化登入页面的配置
		epius::time_mgr::instance().set_timer(3*1000*60, boost::bind(&login::get_customize_login_config, this));

#ifdef _WIN32

		courses::instance().init(info.anan_id);
		courses::instance().set_aligner(epius::thread_align(get_parent_impl()->_p_private_task_->get_thread_tell_cmd(), get_parent_impl()->_p_private_task_->get_post_cmd()));
#endif
		conn_msm_.process_event(event_connected());
		_KeepAlive();
	}

	void login::onDisconnect( ConnectionError e )
	{
#ifdef _WIN32
		db_connection::instance().remove("courses.dat");
#endif
		if(!login_callback_.empty())
		{
			json::jobject jobj;
			login_callback_(true,XL(error_map_value2string[e]),jobj);
			login_callback_ = LoginCallback();
		}
		json::jobject res_jobj;		
		if(e == ConnStreamError)
		{
			if(StreamErrorConflict == get_parent_impl()->bizClient_->streamError())
			{
				res_jobj["res"] = "biz.disconnect_by_logon_different_pc";
				//终止未完成的文件传输
				epius::http_requests::instance().cancel_all("cancel_by_logon_different_pc");
			}
		}		
		conn_msm_.process_event(event_disconnected(res_jobj));
	}

	bool login::onTLSConnect( const CertInfo& info )
	{
		return true;
	}

	bool login::init_to_discontion(/*std::string const host, int port*/)
	{
		conn_msm_.start();
		return true;
	}

	void login::user_can_change_password(boost::function<void(bool)> callback)
	{
		IN_TASK_THREAD_WORKx(login::user_can_change_password, callback);
		if((get_parent_impl()->bizLogin_->conn_msm_.getCurrentState()) != CONN_CONNECTED)
		{
			callback(false);//offline cannot change password
		}
		Tuser_info user = get_parent_impl()->bizUser_->get_user();
		if(user.account_type == "local")
		{
			callback(true);
		}
		else
		{
			callback(false);
		}
	}

	void login::to_offline_from_connected()
	{
		// 注意顺序
		conn_msm_.process_event(event_user_go_offline());
		get_parent_impl()->bizClient_->disconnect();
	}

	void login::change_user( boost::function<void(bool, universal_resource)> callback )
	{
		IN_TASK_THREAD_WORKx(login::change_user, callback);

		if((get_parent_impl()->bizLogin_->conn_msm_.getCurrentState()) == CONN_CONNECTED)
		{	
			conn_msm_.process_event(event_user_go_offline());
			get_parent_impl()->bizClient_->disconnect();
		}
		get_parent_impl()->bizLocalConfig_->uninitdbs();
		callback(false,XL(""));
	}

	void login::load_local_users(boost::function<void(std::list<Tuser_info>)> callback)
	{
		IN_TASK_THREAD_WORKx(login::load_local_users, callback);

		if (callback.empty())return;
		std::list<Tuser_info> user_list;
		get_parent_impl()->bizLocalConfig_->loadLocalUsers(user_list);
		for (std::list<Tuser_info>::iterator it = user_list.begin();it != user_list.end(); ++it) 
		{
			Tuser_info& user = *it;
			if (user.savePasswd) 
			{
				std::string tmp_passwd = gen_uuid();
				tmp_passwd.erase(10);
				impl_->tmp_passwd_to_real_passwd[user.sam_id][tmp_passwd] = user.password;
				user.password = tmp_passwd;
			}
		}
		callback(user_list);
	}

	void login::get_user_really_passwd(std::string userName, std::string passWd, boost::function<void(std::string)> callback)
	{
		IN_TASK_THREAD_WORKx(login::get_user_really_passwd, userName, passWd,callback);
		if(impl_->tmp_passwd_to_real_passwd[userName][passWd])
		{
			callback(impl_->tmp_passwd_to_real_passwd[userName][passWd].get<string>());
		}
		else
		{
			callback(passWd);
		}
	}

	void login::processPasswdAndCertIt(Tuser_info& user)
	{
		std::string userName = user.sam_id;
		if(impl_->tmp_passwd_to_real_passwd[user.sam_id][user.password])
		{
			user.password = impl_->tmp_passwd_to_real_passwd[user.sam_id][user.password].get<string>();
		}
	}

	void login::to_login_with_got_config()
	{
		//云配置
		std::string cloud_config_url = anan_config::instance().get_cloud_config_url();
		//从配置列表中查找默认配置，带"config"字段。
		boost::function<bool(json::jobject)> find_config = [](json::jobject jobj){return !jobj.is_nil("config");};
		//向服务器请求获取对应的学校配置的回调
		boost::function<void(bool,std::string)> school_config_cb = [=](bool is_succ,std::string config_str) mutable
		{
			json::jobject school_jobj(config_str);
			json::jobject school_config_obj = school_jobj["data"]["items"].find_if(find_config);
			if (is_succ && school_config_obj)
			{
				if (school_config_obj["config"].is_nil("server") || school_config_obj["config"].is_nil("port"))
				{
					//状态机回归初始
					conn_msm_.process_event(event_cancel());
					if ( get_parent_impl()->bizClient_ != NULL)
					{
						get_parent_impl()->bizClient_->disconnect();
					}	
					//通知界面获取学校列表失败
					ELOG("app")->debug(WCOOL(L"获取服务器server为空"));
					json::jobject nil_jobj;
					login_callback_(true, XL("biz.server_nil_error"),nil_jobj);
					return;
				}
				this->set_config_and_login(school_config_obj);
			}
			else
			{
				//通知界面获取学校列表失败
				ELOG("app")->debug(WCOOL(L"get 服务端配置文件失败"));
				json::jobject nil_jobj;
				login_callback_(true, XL("biz.get_school_config_error"),nil_jobj);
				return;
			}
		};

		//如果选择的学校和配置文件中的默认配置的学校名称相同则利用默认配置直接登陆
		std::string whistle_domain;
		if (impl_->user_select_["domain"])
		{
			whistle_domain = impl_->user_select_["domain"].get<std::string>();
		}
		json::jobject school_config_obj = impl_->school_list_jobj_["data"]["items"].find_if(find_config);
		if(school_config_obj && school_config_obj["config"]["domain"].get() == whistle_domain )
		{
			this->set_config_and_login(school_config_obj);
		}
		else
		{
			std::string resource = impl_->tsys_info_["client_type"].get<std::string>();
			std::string whistle_version = anan_config::instance().get_version();
			std::string url = cloud_config_url + "?device=" + resource + "&version=" + whistle_version + "&domain=" + whistle_domain; 
			epius::http_requests::instance().get(url,school_config_cb);	
		}
	}

	void login::cloud_config_got()
	{
		boost::function<bool(json::jobject)> find_config = [](json::jobject jobj){return !jobj.is_nil("config");};
		//用户选择学校配置后的回调, user_sel 的格式为 user_sel["domain"]
		boost::function<void(json::jobject)> cloud_config_cmd = [=](json::jobject user_sel) mutable
		{	
			this->impl_->user_select_ = user_sel;
			conn_msm_.process_event(event_user_select_school());					
		};
		//展示学校，配置列表post到界面去
		std::string uuid = epius::gen_uuid();
		cmd_factory::instance().register_callback(uuid,get_parent_impl()->wrap(cloud_config_cmd));						
		json::jobject school_config_cb_jobj;
		school_config_cb_jobj["callback_id"] = uuid;
		school_config_cb_jobj["callback_name"] = "cloud_config_cmd";
		school_config_cb_jobj["config"] = impl_->school_list_jobj_;
		school_config_cb_jobj["result"] = "success";
		event_collect::instance().recv_cloud_config(school_config_cb_jobj);		
	}

	void login::to_login(json::jobject tsys_info,Tuser_info user, boost::function<void(bool, universal_resource,json::jobject)> callback)
	{
		IN_TASK_THREAD_WORKx(login::to_login,tsys_info, user, callback);
		user.last_login_time = boost::posix_time::second_clock::local_time();
		if(user.presence == kptOffline)
		{
			json::jobject nil_jobj;
			callback(true, XL("biz.login_cannot_logon_to_offline_status"),nil_jobj);
			return;
		}
		login_callback_ = callback;
		processPasswdAndCertIt(user);
		impl_->user_prelogin_ = user;
		impl_->tsys_info_ = tsys_info;	
		conn_msm_.process_event(event_login());
	}

	void login::to_pre_login()
	{
		ELOG("log_network")->debug((boost::format("will logon into %s:%d, domain is %s")%anan_config::instance().get_server()%anan_config::instance().get_port()%app_settings::instance().get_domain()).str());
		ELOG("log_network")->debug((boost::format("image upload path is %s")%anan_config::instance().get_http_upload_path()).str());
		reset_gloox();
		AsyncConnectionTcpClient* conn0 = new AsyncConnectionTcpClient(*get_parent_impl()->_p_private_task_.get(),get_parent_impl()->bizClient_,anan_config::instance().get_server(),anan_config::instance().get_port());
		conn0->set_connect_timeout(anan_config::instance().get_network_connect_timeout());
		get_parent_impl()->bizClient_->setTls(TLSOptional);
		get_parent_impl()->bizClient_->setConnectionImpl(conn0);
		get_parent_impl()->bizClient_->connect( false );
	}

	void login::to_logon(KPresenceType pt)
	{
		IN_TASK_THREAD_WORKx(login::to_logon, pt);
		Tuser_info user = get_parent_impl()->bizUser_->get_user();
		user.presence = pt;
		to_login(impl_->tsys_info_,user, LoginCallback());
	}

	void login::to_real_login(bool err,universal_resource res, json::jobject jobj)
	{
		if(err)
		{
			if(!login_callback_.empty())
			{
				json::jobject tmp_jobj = jobj;
				login_callback_(true,res,tmp_jobj);
				login_callback_ = LoginCallback();
			}
		}
		else
		{
			std::string user_name = jobj["username"].get<string>();
			std::string aid = jobj["aid"].get<string>();
			impl_->user_prelogin_.user_id = user_name;
			impl_->user_prelogin_.anan_id = aid;
			impl_->user_prelogin_.account_type = jobj["account_type"].get<string>();
			get_parent_impl()->bizUser_->set_user(impl_->user_prelogin_);
			get_parent_impl()->bizClient_->setUsername(impl_->user_prelogin_.user_id);
			if(jobj["challenge"])
			{
				std::string compose_password = "RJ_" + jobj["challenge"].get<std::string>()+"_" + impl_->user_prelogin_.password;
				get_parent_impl()->bizClient_->setPassword(compose_password);
			}
			else
			{
				get_parent_impl()->bizClient_->setPassword(impl_->user_prelogin_.password);
			}
			get_parent_impl()->bizClient_->selectResource(anan_config::instance().get_client_type());

			get_parent_impl()->bizClient_->header();

			get_parent_impl()->bizClient_->setCompressionImpl(new CompressionDefault(get_parent_impl()->bizClient_));
			ELOG("log_network")->debug("has been connected ");
		}
	}

	void login::regist_to_gloox( gloox::Client* p_client )
	{
		p_client->registerConnectionListener( (gloox::ConnectionListener*) this );
		p_client->disco()->setVersion( "AnAn", GLOOX_VERSION, "Windows" );
		p_client->disco()->setIdentity( "Client", "Agent" );
		p_client->disco()->addFeature( XMLNS_CHAT_STATES );
	}

	void login::reset_gloox()
	{
		get_parent_impl()->bizClient_->cleanup();
	}

	void login::to_cancel( boost::function<void(bool, universal_resource)> callback)
	{
		IN_TASK_THREAD_WORKx(login::to_cancel, callback);

		if((get_parent_impl()->bizLogin_->conn_msm_.getCurrentState()) == CONN_CONFIG_GOT)
		{
			callback(true, XL("biz.login.cannot_cancel_because_is_getting_cloud_config"));
			return;
		}

		if ((get_parent_impl()->bizLogin_->conn_msm_.getCurrentState()) == CONN_CONNECTED)
		{
			callback(true, XL("biz.login.cannot_cancel_because_already_connected"));
			return;
		}

		if(!login_callback_.empty())
		{
			json::jobject nil_jobj;
			login_callback_(true,XL("biz.login.user_cancel"),nil_jobj);
		}
		conn_msm_.process_event(event_cancel());
		if ( get_parent_impl()->bizClient_ != NULL)
		{
			get_parent_impl()->bizClient_->disconnect();
		}	
		callback(false, XL(""));
	}

	void login::to_quit( boost::function<void(bool, universal_resource)> callback )
	{
		IN_TASK_THREAD_WORKx(login::to_quit, callback);

		switch((get_parent_impl()->bizLogin_->conn_msm_.getCurrentState()))
		{
		case CONN_CONNECTING:
			conn_msm_.process_event(event_user_go_offline());
			get_parent_impl()->bizClient_->disconnect();
			break;
		case CONN_CONNECTED:
			conn_msm_.process_event(event_user_go_offline());
			get_parent_impl()->bizClient_->disconnect();
			break;
		}
		if(!callback.empty())
		{
			callback(false,XL(""));
		}
	}

	void login::_KeepAlive()
	{
		if (impl_.get() && (get_parent_impl()->bizLogin_->conn_msm_.getCurrentState() == CONN_CONNECTED))
		{
			get_parent_impl()->bizClient_->xmppPing(JID(app_settings::instance().get_domain()), NULL);
			get_parent_impl()->_p_private_task_->set_timer(sKeeyAliveInterval, boost::bind(&login::_KeepAlive, this));
		}
	}

	void login::to_offline( boost::function<void(bool, universal_resource)> callback )
	{
		IN_TASK_THREAD_WORKx(login::to_offline, callback);
		if((get_parent_impl()->bizLogin_->conn_msm_.getCurrentState()) == CONN_CONNECTED)
		{
			to_offline_from_connected();
		}
		if(!callback.empty())callback(false,XL(""));
	}

	void login::ui_query_state( boost::function<void(json::jobject)> callback )
	{
		IN_TASK_THREAD_WORKx(login::ui_query_state, callback);

		json::jobject jobj;
		if((get_parent_impl()->bizLogin_->conn_msm_.getCurrentState()) == CONN_CONNECTED)
		{
			//connected
			jobj["status"] = "online";
		}
		else
		{
			jobj["status"] = "offline";
		}
		if(!callback.empty())callback(jobj);
	}

	void login::network_broken()
	{
		if (!get_parent_impl()->_p_private_task_->is_in_work_thread()) 
		{
			get_parent_impl()->_p_private_task_->post(boost::bind(&login::network_broken,this));
			return;
		}
		if(!login_callback_.empty())
		{
			json::jobject nil_jobj;
			login_callback_(false,XL("biz.login_fail_for_network_broken"),nil_jobj);
			login_callback_ = LoginCallback();
		}
		conn_msm_.process_event(event_network_broken());
		get_parent_impl()->bizClient_->handleDisconnect(NULL,ConnNotConnected);
	}

	void login::onStreamEvent( StreamEvent event )
	{
		if(event == StreamEventConnecting)
		{
			gWrapInterface::instance().prelogin_with_sam_account(impl_->user_prelogin_.sam_id,impl_->tsys_info_,bind2f(&login::to_real_login, this, _1, _2, _3));
		}
	}

	int login::get_user_prelogin_presence()
	{
		return impl_->user_prelogin_.presence;
	};

	json::jobject login::search_school( json::jobject jobj )
	{
		json::jobject school_jobj;
		for (int i = 0;i < impl_->school_list_jobj_["data"]["items"].arr_size();i++)
		{
			if (eplocal_find::instance().match(jobj["args"]["search_school"].get<string>(),impl_->school_list_jobj_["data"]["items"][i]["name"].get<std::string>()))
			{
				school_jobj["school"].arr_push(impl_->school_list_jobj_["data"]["items"][i]);	
			}
		}	

		//进行拼音排序
		std::set<std::string> name_set;
		for (int l = 0;l < school_jobj["school"].arr_size();l++)
		{
			name_set.insert(school_jobj["school"][l]["pinyin"].get<std::string>());
		}
		//重组学校列表json
		json::jobject tmp_jobj;
		for (std::set<std::string>::iterator it = name_set.begin();it != name_set.end();++it)
		{
			for (int j = 0;j < school_jobj["school"].arr_size();j++)
			{
				if (school_jobj["school"][j]["pinyin"].get<std::string>() == *it)
				{
					tmp_jobj["school"].arr_push(school_jobj["school"][j]);
					break;
				}
			}
		}
		return tmp_jobj;
	}

	void login::set_config_and_login( json::jobject jobj )
	{
		anan_config::instance().set_config_domain(jobj["config"]["domain"].get<std::string>());
		anan_config::instance().set_config_port(jobj["config"]["port"].get<int>());
		anan_config::instance().set_config_server(jobj["config"]["server"].get<std::string>());
		anan_config::instance().set_config_http_root(jobj["config"]["http_root"].get<std::string>());
		anan_config::instance().set_config_eportal_url(jobj["config"]["eportal_explorer_url"].get<std::string>());

		this->impl_->tsys_info_["domain"] = jobj["config"]["domain"].get<std::string>();
		//gloox初始化，通知初始化
		get_parent_impl()->bizAgent_->init(jobj["config"]["domain"].get<std::string>());				
		//存在本地配置登陆微哨
		to_pre_login();
	}

	void login::prepare_login()
	{
		//查看本地是否有配置文件
		std::string config_file_path = file_manager::instance().get_default_config_dir();	
		std::string cloud_config_file_path =  epfilesystem::instance().sub_path(config_file_path, "config_from_cloud.json");
		if (epfilesystem::instance().file_exists(cloud_config_file_path) || (anan_config::instance().get_mconfig()["repack"] && anan_config::instance().get_mconfig()["repack"].get<bool>()))
		{
			impl_->tsys_info_["domain"] = anan_config::instance().get_domain();				
			//gloox初始化，通知初始化
			get_parent_impl()->bizAgent_->init(anan_config::instance().get_domain());
			//存在本地配置登陆微哨			
			to_pre_login();
		}
		else
		{
			//云配置
			std::string resource = impl_->tsys_info_["client_type"].get<std::string>();
			std::string whistle_version = anan_config::instance().get_version();
			std::string cloud_config_url = anan_config::instance().get_cloud_config_url() + "?device=" + resource + "&version=" + whistle_version;
			boost::function<bool(json::jobject)> find_config = [](json::jobject jobj){return !jobj.is_nil("config");};
			//第一次向服务器请求学校列表和默认配置，失败重试3次
			boost::shared_ptr<boost::function<void(bool,std::string)> > school_list_cb(new boost::function<void(bool,std::string)>);
			int retry_times = 0;
			*school_list_cb = [=](bool is_succ,std::string config_str) mutable
			{
				login* login_ptr = this;
				if(!is_succ)
				{
					if(retry_times >= 3 )
					{						
						//通知界面获取学校列表失败
						ELOG("app")->debug(WCOOL(L"get 服务端配置文件失败"));
						ELOG("http")->debug(WCOOL(L"get 服务端配置文件失败"));
						json::jobject nil_jobj;
						login_ptr->login_callback_(true, XL("biz.get_school_config_error"),nil_jobj);
						return;
					}
					retry_times++;
					epius::time_thread delay_time_;
					boost::function<void()> retry_get_config = [=]()
					{
						epius::http_requests::instance().get(cloud_config_url,*school_list_cb);
					};
					delay_time_.set_timer(2000,retry_get_config);
					return;
				}
				json::jobject school_list = json::jobject(config_str); 
				login_ptr->impl_->school_list_jobj_ = school_list;

				//如果是802.1x智能获取配置成功则直接登陆	
				json::jobject school_config_obj = login_ptr->impl_->school_list_jobj_["data"]["items"].find_if(find_config);
				if (login_ptr->impl_->tsys_info_["network_type"].get<std::string>() == "802.1x" && school_config_obj && login_ptr->impl_->tsys_info_["client_type"].get<std::string>() == "pc")
				{
					login_ptr->set_config_and_login(school_config_obj);
				}
				else
				{
					boost::function<void()> switch_state = [=]()
					{
						login_ptr->conn_msm_.process_event(event_cloud_config_got());
					};
					(login_ptr->get_parent_impl()->wrap(switch_state))();
				}	
			};
			//去服务器获取配置
			epius::http_requests::instance().get(cloud_config_url,*school_list_cb);
		}
	}

	void login::get_customize_login_config()
	{
		IN_TASK_THREAD_WORK0(login::get_customize_login_config);

		// get config from global data base
		std::string config_str = get_parent_impl()->bizLocalConfig_->loadGlobalData("login.customize.config");

		std::string url = anan_config::instance().get_http_root() + "/msapi/?m=customize&a=" +  anan_config::instance().get_client_type() + "&timestamp=";
		if ( config_str.empty() )
		{
			// get config from server without timestamp
			epius::http_requests::instance().get(url, bind2f(&login::get_customize_cb, this, json::jobject(), _1, _2 ));
		}
		else
		{
			json::jobject config(config_str);
			// get config from server use timestamp
			url = url + config["timestamp"].get<std::string>();
			epius::http_requests::instance().get(url, bind2f(&login::get_customize_cb, this, config, _1, _2 ));
		}

	}

	void login::get_customize_cb( json::jobject old_config, bool succ, std::string result )
	{
		IN_TASK_THREAD_WORKx(login::get_customize_cb, old_config, succ, result);

		if (succ)
		{
			if ( !result.empty() && result != "{}")
			{
				json::jobject config(result);

				// 下载图片
				std::string uri = config["login_img"].get<std::string>();
				std::string uri_file_str = file_manager::instance().from_uri_to_path(uri);
				bool is_exist = epius::epfilesystem::instance().file_exists(uri_file_str);
				if(is_exist)
				{
					config["login_img_path"] = uri_file_str;

					// 保存个性化登入页面配置
					get_parent_impl()->bizLocalConfig_->saveGlobalData("login.customize.config", config.to_string());

					event_collect::instance().update_customize_login(config.clone());
				}
				else
				{
					// 保存个性化登入页面配置
					get_parent_impl()->bizLocalConfig_->saveGlobalData("login.customize.config", config.to_string());

					epius::http_requests::instance().download(anan_config::instance().get_http_down_path(), uri_file_str, uri, "", 
						boost::function<void(int)>(), bind2f(&login::download_uri_callback,this,config,_1,_2));
				}
			}
			else
			{
				// 没有新的配置，使用现有配置， 重新检查图片是否存在，不存在则下载图片
				if (old_config != json::jobject())
				{
					// 下载图片
					std::string uri = old_config["login_img"].get<std::string>();
					std::string uri_file_str = file_manager::instance().from_uri_to_path(uri);
					bool is_exist = epius::epfilesystem::instance().file_exists(uri_file_str);
					if(!is_exist)
					{
						epius::http_requests::instance().download(anan_config::instance().get_http_down_path(), uri_file_str, uri, "", 
							boost::function<void(int)>(), bind2f(&login::download_uri_callback,this, old_config,_1,_2));
					}
				}

			}
		}
		

	}

	void login::download_uri_callback( json::jobject config, bool succ, std::string uri )
	{
		IN_TASK_THREAD_WORKx(login::download_uri_callback, config, succ, uri);

		if (succ) {
			std::string local_path = file_manager::instance().from_uri_to_path(uri);
			config["login_img_path"] = local_path;

			get_parent_impl()->bizLocalConfig_->saveGlobalData("login.customize.config", config.to_string());

			event_collect::instance().update_customize_login(config.clone());
		}
	}

	json::jobject login::get_config_jobj()
	{
		return impl_->config_jobj_;
	}

}; // namespace biz
