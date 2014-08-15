#pragma once
#include "base/fsm/fmsbase.hpp"
#include <boost/signal.hpp>
#include <base/log/elog/elog.h>
#include "base/universal_res/uni_res.h"
#include <typeinfo>


namespace biz
{
	class login;
	enum CONN_STATE{CONN_DISCONNECTED, CONN_CONNECTING, CONN_CONFIG_GOT, CONN_CONNECTED};
	//定义事件
	DEFINE_EVENT(event_connected);
	DEFINE_EVENT(event_login);
	DEFINE_EVENT(event_network_broken);
	DEFINE_EVENT(event_disconnected);
	DEFINE_EVENT(event_user_go_offline);
	DEFINE_EVENT(event_cancel);
	//获取云配置
	DEFINE_EVENT(event_cloud_config_got);
	//用户选择学校
	DEFINE_EVENT(event_user_select_school);

	DEFINE_MACHINE(conn_msm)
	{
		boost::signal<void ()> connected_signal_;
		boost::signal<void (universal_resource res)> disconnected_signal_;
		boost::signal<void ()> connecting_signal_;
		login* machine_owner_;
		conn_msm();
		void set_owner(login* owner);
		void before_logout();
		void prepare_login();
		void cloud_config_got();
		void to_login_with_got_config();
		CONN_STATE getCurrentState();

		template<typename Event, typename FSM>
		void on_entry(Event const& e, FSM& fsm)
		{			
			ELOG("msm")->debug("conn_msm: enter msm on " + std::string(typeid(Event).name()));
		}

		DEFINE_STATE(Disconnected)
		{
			template<typename Event, typename FSM>
			void on_entry(Event const& e, FSM& fsm)
			{				
				ELOG("msm")->debug("conn_msm: enter Disconnected on " + std::string(typeid(Event).name()));
			}
		};
		
		DEFINE_STATE(Connecting)
		{
			template<typename Event, typename FSM>
			void on_entry(Event const& e, FSM& fsm)
			{
				fsm.connecting_signal_();
				ELOG("msm")->debug("conn_msm: enter connecting on " + std::string(typeid(Event).name()));
			}
		};

		DEFINE_STATE(Connected)
		{
			template<typename Event, typename FSM>
			void on_entry(Event const& e, FSM& fsm)
			{
				fsm.connected_signal_();
				ELOG("msm")->debug("conn_msm: enter Connected on " + std::string(typeid(Event).name()));
			}
		};

		DEFINE_STATE(Cloud_Config_Got)
		{
			template<typename Event, typename FSM>
			void on_entry(Event const& e, FSM& fsm)
			{
				ELOG("msm")->debug("conn_msm: enter get_cloud_config " + std::string(typeid(Event).name()));
			}
		};

		typedef Disconnected initial_state;//初始状态
		template <class FSM,class Event>
		void no_transition(Event const& e, FSM&, int state)
		{			
			ELOG("msm")->debug("conn_msm: no_transition by " + std::string(typeid(Event).name()));
		}

		struct Act_Disconnected
		{
			template <class Fsm>
			void operator()(event_login const& e, Fsm&fsm, Disconnected&, Connecting& conn_stat) const
			{
				fsm.prepare_login();
			}			

			template <class Fsm>
			void operator()(event_network_broken const& e, Fsm&fsm, Disconnected&, Disconnected& conn_stat) const
			{
				ELOG("msm")->debug("conn_msm: msm from Disconnected to Disconnected by event_logoff");
			}		
		};
		
		struct Act_Connecting
		{
			template <class Fsm>
			void operator()(event_connected const& e, Fsm&fsm, Connecting&, Connected& conn_stat) const
			{
				ELOG("msm")->debug("conn_msm: msm from Connecting to Connected by event_connect");
			}

			template <class Fsm>
			void operator()(event_disconnected const& e, Fsm&fsm, Connecting&, Disconnected& conn_stat) const
			{
				json::jobject jobj = e.env_data_;
				universal_resource res = XL(jobj["res"].get<std::string>());
				fsm.disconnected_signal_(res);
				ELOG("msm")->debug("conn_msm: msm from Connecting to Disconnected by event_disconnected");
			}
			
			template <class Fsm>
			void operator()(event_cancel const& e, Fsm&fsm, Connecting&, Disconnected& conn_stat) const
			{
				universal_resource res = XL("");
				fsm.disconnected_signal_(res);
				ELOG("msm")->debug("conn_msm: msm from Connecting to Disconnected by event_cancel");
			}
			//取配置
			template <class Fsm>
			void operator()(event_cloud_config_got const& e, Fsm&fsm, Connecting&, Cloud_Config_Got& conn_stat) const
			{
				ELOG("msm")->debug("conn_msm: msm from Connecting to Cloud_Config_Got by event_get_cloud_config");
				fsm.cloud_config_got();
			}
		};

		struct Act_Connected
		{
			template <class Fsm>
			void operator()(event_network_broken const& e, Fsm&fsm, Connected&, Disconnected& conn_stat) const
			{				
				json::jobject jobj = e.env_data_;
				universal_resource res = XL(jobj["res"].get<std::string>());
				fsm.disconnected_signal_(res);
				ELOG("msm")->debug("conn_msm: msm from Connected to Disconnected by event_logoff");
			}		

			template <class Fsm>
			void operator()(event_disconnected const& e, Fsm&fsm, Connected&, Disconnected& conn_stat) const
			{
				json::jobject jobj = e.env_data_;				
				universal_resource res = XL(jobj["res"].get<std::string>());
				fsm.disconnected_signal_(res);
				ELOG("msm")->debug("conn_msm: msm from Connected to Disconnected by event_disconnected");
			}	

			template <class Fsm>
			void operator()(event_user_go_offline const& e, Fsm&fsm, Connected&, Disconnected& conn_stat) const
			{
				fsm.before_logout();
				universal_resource res;
				res = XL("biz.disconnect_by_user_disconnect");
				fsm.disconnected_signal_(res);
				ELOG("msm")->debug("conn_msm: msm from Connected to Disconnected by event_disconnected");
			}	
		};

		struct Act_Cloud_Config_Got
		{
			template <class Fsm>
			void operator()(event_user_select_school const& e, Fsm&fsm, Cloud_Config_Got&, Connecting& conn_stat) const
			{				
				ELOG("msm")->debug("conn_msm: msm from Cloud_Config_Got to Connecting by event_user_select_school");
				fsm.to_login_with_got_config();
			}					
		};

		struct Guard_Cancel
		{			
			template <class Event, class Fsm>
			bool operator()(Event const& e, Fsm&fsm, Connecting&, Disconnected& conn_stat) const
			{			
				return true;
			}

			template <class Event, class Fsm>
			bool operator()(Event const& e, Fsm&fsm, Connecting&, Connected& conn_stat) const
			{
				return false;
			}
		};
		
		//迁移表
		struct transition_table : mpl::vector<		
			msmf::Row<Disconnected, event_login, Connecting, Act_Disconnected>,
			msmf::Row<Connecting, event_connected, Connected, Act_Connecting>,
			msmf::Row<Connecting, event_disconnected, Disconnected, Act_Connecting>,
			msmf::Row<Connecting, event_cancel, Disconnected, Act_Connecting, Guard_Cancel>,
			//新增加的取到配置的状态
			msmf::Row<Connecting, event_cloud_config_got, Cloud_Config_Got, Act_Connecting>,
			msmf::Row<Cloud_Config_Got, event_user_select_school, Connecting, Act_Cloud_Config_Got>,
			//
			msmf::Row<Connected, event_network_broken, Disconnected, Act_Connected>,
			msmf::Row<Connected, event_user_go_offline, Disconnected, Act_Connected>,
			msmf::Row<Connected, event_disconnected, Disconnected, Act_Connected>
		>{};
	};
}

