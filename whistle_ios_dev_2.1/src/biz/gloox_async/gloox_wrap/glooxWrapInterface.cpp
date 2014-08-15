#include "glooxWrapInterface.h"
#include "privilegeHandler.h"
#include "base/txtutil/txtutil.h"
#include "preLoginHandler.h"
#include "basicStanza.hpp"
#include "UserStanzaExtensionType.h"
#include "create_discussions_handler.h"
#include "get_discussions_list_handler.h"
#include "get_discussions_memberlist_handler.h"
#include "invite_discussions_handler.h"
#include "quit_discussions_handler.h"
#include "temporary_attention_handler.h"
#include "organization_search_handler.h"
#include "send_file_msg_handler.h"
#include "change_discussions_name_handler.h"
#include "addAStrangerHandler.h"
#include "removeAStrangerHandler.h"
#include "getStrangerListHandler.h"
#include "../gloox_src/message.h"
#include "../gloox_src/messagesession.h"
#include "../gloox_src/messagesessionhandler.h"
#include "discussions_message_handler.h"
#include "filedak_message_handler.h"
#include "base/log/elog/elog.h"
#include <boost/assign/list_of.hpp>
#include <boost/date_time/posix_time/posix_time.hpp>
#include "iq_handler_helper.h"
#include "xmpp_error_info.h"
#include "../gloox_src/error.h"
#include "find_friend_handler.h"
#include "get_groups_list_handler.h"
#include "get_groups_memberlist_handler.h"
#include "get_groups_info_handler.h"
#include "change_groups_info_handler.h"
#include "quit_groups_handler.h"
#include "groups_message_handler.h"
#include "groups_kickout_member_handler.h"
#include "create_groups_handler.h"
#include "dismiss_groups_handler.h"
#include "apply_join_groups_handler.h"
#include "enter_groups_handler.h"
#include "leave_groups_handler.h"
#include "change_groups_member_info_handler.h"
#include "get_groups_share_list_handler.h"
#include "upload_file_groups_share_handler.h"
#include "download_file_groups_share_handler.h"
#include "delete_file_groups_share_handler.h"
#include "permanent_file_groups_share_handler.h"
#include "find_groups_handler.h"
#include "get_groups_recent_messages_handler.h"
#include "add_privacy_handler.h"
#include "groups_amdin_manage_member_handler.h"
#include "groups_role_change_handler.h"
#include "get_groups_admin_list_handler.h"
#include "groups_role_demise_handler.h"
#include "groups_role_apply_handler.h"
#include "invite_into_groups_handler.h"
#include "answer_groups_invite_handler.h"
#include "get_create_groups_setting_handler.h"
#include "set_groups_member_info_handler.h"
#include "organization_show_hadler.h"
#include "lightapp_iq_callback.h"
#include "lightapp_message_handler.h"
#include "growth_level_info_message_handler.h"

using namespace boost::assign;

namespace gloox {

	glooxWrapInterface::glooxWrapInterface()
	{
		session_ = NULL;
		filedak_session_ = NULL;
		groups_session_=NULL;
	}
	glooxWrapInterface::~glooxWrapInterface()
	{
		if (session_)
		{
			session_->removeMessageHandler();
			delete session_;
			session_ = NULL;
		}
		if (groups_session_)
		{
			groups_session_->removeMessageHandler();
			delete groups_session_;
			groups_session_ = NULL;
		}
		if (filedak_session_)
		{
			filedak_session_->removeMessageHandler();
			delete filedak_session_;
			filedak_session_ = NULL;
		}
	}

	void glooxWrapInterface::get_privilege( Result_Data_Callback callback )

	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","http://ruijie.com.cn/permission");

		gloox::IQ iq(gloox::IQ::Get, JID("permission." + domain_));
		iq.addExtension(new iq_privilege(tag_query));
		pclient_->send(iq, new privilegeHandler(pclient_ ,callback), 0, true, false, true);
	}

	void glooxWrapInterface::set_client( Client* client )
	{
		pclient_ = client;

		//注册message的扩展标签
		typedef BasicStanza<kExtUser_msg_filter_discussionslistchange> msg_chat_group_list_change;
		pclient_->registerStanzaExtension(new msg_chat_group_list_change(NULL, "/message/x[@xmlns='list']"));

		typedef BasicStanza<kExtUser_msg_filter_discussionsmemberchange> msg_chat_group_member_change;
		pclient_->registerStanzaExtension(new msg_chat_group_member_change(NULL, "/message/x[@xmlns='member']"));

		typedef BasicStanza<kExtUser_msg_filter_messageid> msg_chat_group_message_id;
		pclient_->registerStanzaExtension(new msg_chat_group_message_id(NULL, "/message/id"));

		typedef BasicStanza<kExtUser_msg_filter_messagebody> msg_messagebody;
		pclient_->registerStanzaExtension(new msg_messagebody(NULL, "/message/body"));
		

		typedef BasicStanza<kExtUser_msg_filter_filedak_message> msg_filedak_message_id;
		pclient_->registerStanzaExtension(new msg_filedak_message_id(NULL, "/message/file"));

		typedef BasicStanza<kExtUser_presence_filter_threadid> presence_filter_threadid;
		pclient_->registerStanzaExtension(new presence_filter_threadid(NULL, "/presence/ext_threadid"));

		typedef BasicStanza<kExtUser_iq_filter_quitdiscussions> iq_quitdiscussions;
		pclient_->registerStanzaExtension(new iq_quitdiscussions(NULL, "/iq/query[@xmlns='quit']"));
		pclient_->registerIqHandler(new QuitDiscussionsHandler(), kExtUser_iq_filter_quitdiscussions);

		typedef BasicStanza<kExtUser_iq_filter_creatediscussions> iq_creatediscussions;
		pclient_->registerStanzaExtension(new iq_creatediscussions(NULL, "/iq/query[@xmlns='create']"));
		pclient_->registerIqHandler(new CreateDiscussionsHandler(), kExtUser_iq_filter_creatediscussions);

		typedef BasicStanza<kExtUser_iq_filter_creategroups> iq_creategroups;
		pclient_->registerStanzaExtension(new iq_creategroups(NULL, "/iq/query[@xmlns='groups:create']"));
		pclient_->registerIqHandler(new CreateGroupsHandler(), kExtUser_iq_filter_creategroups);

		typedef BasicStanza<kExtUser_iq_filter_setgroupsmemberinfo> iq_setgroupsmemberinfo;
		pclient_->registerStanzaExtension(new iq_setgroupsmemberinfo(NULL, "/iq/query[@xmlns='groups:member:info-v2']"));
		pclient_->registerIqHandler(new SetGroupsMemerInfoHandler(), kExtUser_iq_filter_setgroupsmemberinfo);

		typedef BasicStanza<kExtUser_iq_filter_quitgroups> iq_quitgroups;
		pclient_->registerStanzaExtension(new iq_quitgroups(NULL, "/iq/query[@xmlns='groups:member:quit']"));
		pclient_->registerIqHandler(new QuitGroupsHandler(), kExtUser_iq_filter_quitgroups);

		//注册群相关的message
		typedef BasicStanza<kExtUser_msg_filter_changegroupsinfo> msg_change_groups_info;
		pclient_->registerStanzaExtension(new msg_change_groups_info(NULL, "/message/query[@xmlns='groups:info']"));

		typedef BasicStanza<kExtUser_msg_filter_creategroups> msg_create_groups;
		pclient_->registerStanzaExtension(new msg_create_groups(NULL, "/message/query[@xmlns='groups:create']"));

		typedef BasicStanza<kExtUser_msg_filter_dismissgroups> msg_dismiss_groups;
		pclient_->registerStanzaExtension(new msg_dismiss_groups(NULL, "/message/query[@xmlns='groups:dismiss']"));

		typedef BasicStanza<kExtUser_msg_filter_quitgroups> msg_quit_groups;
		pclient_->registerStanzaExtension(new msg_quit_groups(NULL, "/message/query[@xmlns='groups:member:quit']"));

		typedef BasicStanza<kExtUser_msg_filter_changegroupsmemberinfo> msg_change_groups_member_info;
		pclient_->registerStanzaExtension(new msg_change_groups_member_info(NULL, "/message/query[@xmlns='groups:member:info']"));

		typedef BasicStanza<kExtUser_msg_filter_applyjoingroups> msg_apply_join_groups_accept;
		pclient_->registerStanzaExtension(new msg_apply_join_groups_accept(NULL, "/message/query[@xmlns='groups:member:apply']"));

		typedef BasicStanza<kExtUser_msg_filter_uploadfilegroupsshare> msg_upload_file_groups_share;
		pclient_->registerStanzaExtension(new msg_upload_file_groups_share(NULL, "/message/query[@xmlns='groups:share:create']"));

		typedef BasicStanza<kExtUser_msg_filter_inviteintogroups> msg_groups_member_invite;
		pclient_->registerStanzaExtension(new msg_groups_member_invite(NULL, "/message/query[@xmlns='groups:member:invite']"));

		typedef BasicStanza<kExtUser_msg_filter_answergroupsinviteaccept> msg_groups_member_invite_accept;
		pclient_->registerStanzaExtension(new msg_groups_member_invite_accept(NULL, "/message/query[@xmlns='groups:member:invite:accept']"));

		typedef BasicStanza<kExtUser_msg_filter_answergroupsinvitedeny> msg_groups_member_invite_deny;
		pclient_->registerStanzaExtension(new msg_groups_member_invite_deny(NULL, "/message/query[@xmlns='groups:member:invite:deny']"));

		typedef BasicStanza<kExtUser_msg_filter_groupsmemberkickout> msg_groups_member_kickout;
		pclient_->registerStanzaExtension(new msg_groups_member_kickout(NULL, "/message/query[@xmlns='groups:member:kickout']"));

		typedef BasicStanza<kExtUser_msg_filter_groupsmemberapplyaccept> msg_groups_member_apply_accept;
		pclient_->registerStanzaExtension(new msg_groups_member_apply_accept(NULL, "/message/query[@xmlns='groups:member:apply:accept']"));

		typedef BasicStanza<kExtUser_msg_filter_groupsmemberapplydeny> msg_groups_member_apply_deny;
		pclient_->registerStanzaExtension(new msg_groups_member_apply_deny(NULL, "/message/query[@xmlns='groups:member:apply:deny']"));

		typedef BasicStanza<kExtUser_msg_filter_groupsrolechange> msg_groups_role_change;
		pclient_->registerStanzaExtension(new msg_groups_role_change(NULL, "/message/query[@xmlns='groups:role:change']"));

		typedef BasicStanza<kExtUser_msg_filter_groupsroleapply> msg_groups_role_apply;
		pclient_->registerStanzaExtension(new msg_groups_role_apply(NULL, "/message/query[@xmlns='groups:role:apply']"));

		typedef BasicStanza<kExtUser_msg_filter_groupsroleapplyreply> msg_groups_role_applyreply;
		pclient_->registerStanzaExtension(new msg_groups_role_applyreply(NULL, "/message/query[@xmlns='groups:role:apply:reply']"));

		typedef BasicStanza<kExtUser_msg_filter_groupsroledemise> msg_groups_role_demise;
		pclient_->registerStanzaExtension(new msg_groups_role_demise(NULL, "/message/query[@xmlns='groups:role:demise']"));

		typedef BasicStanza<kExtUser_msg_filter_groupsmemberset> msg_groups_member_set;
		pclient_->registerStanzaExtension(new msg_groups_member_set(NULL, "/message/query[@xmlns='groups:member:set']"));

		//用户等级升级信息

		typedef BasicStanza<kExtUser_msg_filter_growthlevelinfo> msg_growth_level_info;
		pclient_->registerStanzaExtension(new msg_growth_level_info(NULL, "/message/query[@xmlns='growth:level:info']"));

		//新message session
		if (!session_)
		{
			session_ = new MessageSession( pclient_, JID(DISCUSSIONS_DOMAIN), true, Message::Groupchat | Message::Headline 
				| Message::Normal | Message::Error, false );

			//注册handler到新session
			session_->registerMessageHandler( g_discussionsMessageHandler::instance().get());
		}

		if (!groups_session_)
		{
			groups_session_ = new MessageSession( pclient_, JID(GROUPS_DOMAIN), true, Message::Groupchat | Message::Headline 
				| Message::Normal | Message::Error, false );
			//注册handler到新session
			groups_session_->registerMessageHandler(g_groupsMessageHandler::instance().get());
		}

		if (!lightapp_session_)
		{
			lightapp_session_ = new MessageSession( pclient_, JID(LIGHTAPP_DOMAIN), true, Message::Headline 
				| Message::Normal | Message::Error, false );
			//注册handler到新session
			lightapp_session_->registerMessageHandler(g_lightappMessageHandler::instance().get());
		}
		//用户升级
		if (!growth_session_)
		{
			growth_session_ = new MessageSession( pclient_, JID(GROWTH_DOMAIN), true, Message::Headline 
				| Message::Normal | Message::Error, false );
			//注册handler到新session
			growth_session_->registerMessageHandler(g_growthlevelinfoMessageHandler::instance().get());
		}

		if (!filedak_session_)
		{
			filedak_session_ = new MessageSession( pclient_, JID(FILEDAK_DOMAIN), true, Message::Headline 
				| Message::Normal | Message::Error, false );

			//注册handler到新session
			filedak_session_->registerMessageHandler( g_filedakMessageHandler::instance().get());
		}
	}

	static gloox::Tag* create_tag(std::string tag_name,std::map<std::string, std::string> attrs, std::string data)
	{
		gloox::Tag* chile_tag = new gloox::Tag(tag_name);
		std::map<std::string, std::string>::iterator it = attrs.begin();
		while(it!=attrs.end())
		{
			chile_tag->addAttribute(it->first,it->second);
			++it;
		}
		if (data != "")
		{
			chile_tag->addCData(data);
		}
		return chile_tag;
	}

	static gloox::Tag* create_tag(std::string tag_name,std::string attr_type,std::string attr_value,std::string data)
	{
		gloox::Tag* chile_tag = new gloox::Tag(tag_name);
		if (attr_type != "")
		{
			chile_tag->addAttribute(attr_type,attr_value);
		}
		if (data != "")
		{
			chile_tag->addCData(data);
		}
		return chile_tag;
	}
	/*
	<iq id="uid:131e4c30:00000001" type="set">
	<query xmlns="login">
	<account type="sam">zhangsan</account>
	<network type="sam">1</network>    <!--sam/direct/802.1x-->
	<client type = "pc">
	<software>
	<whistle>
	<version>1.0005.2342</version>
	</whistle>
	<os>
	<system>windows</system>
	<version>6.1.7601</version>     <!--6.1.7601 -->
	</os>
	</software>
	<hardware>
	<cpu> CoreT7250 2.0GHZ</cpu>
	<memory>4GB</memory>
	<displaycard> ATI Mobility Radeon HD 5650</displaycard>
	</hardware>
	</client>    
	</query>
	</iq>
	*/
	void glooxWrapInterface::prelogin_with_sam_account( std::string sam_account,json::jobject jobj_sys_info,Result_Data_Callback callback )
	{		
		gloox::Tag* tag_query = NULL;
		if (jobj_sys_info["client_type"].get<std::string>() == "pc")
		{
			tag_query = create_pc_tag(sam_account,jobj_sys_info);
		}
		else if(jobj_sys_info["client_type"].get<std::string>() == "android" || jobj_sys_info["client_type"].get<std::string>() == "ios")
		{
			tag_query = create_mobile_tag(sam_account,jobj_sys_info);
		}
		typedef BasicStanza<KExtUser_iq_filter_prelogin> iq_prelogin;
		gloox::IQ iq(gloox::IQ::Set, JID(""));
		iq.addExtension(new iq_prelogin(tag_query));
		pclient_->registerStanzaExtension(new iq_prelogin(NULL, "/iq/query[@xmlns='sso:login']"));
		pclient_->send(iq, new preLoginHandler(callback), 0, true, false, false);
	}
	/*
	<iq type="get" to="sso.ruijie.com.cn">
	<query xmlns="token">
	<item service_id="1877" />
	</query>
	</iq>

	service_id
	timestamp 客户端时间戳

	success response
	<iq type="result" from="sso.ruijie.com.cn" to="123456@ruijie.com.cn/pc'>
	<query xmlns="token">
	<item appuid="2888">
	<expires_in>3600</expires_in>
	<access_token>550228663L21D2267007007005612</access_token>
	</item>
	</query>
	</iq>

	error response
	<iq type=’error from=’sso.ruijie.com.cn’ to=’123456789@ruijie.com.cn/pc’>
	<query xmlns='token'>
	</query>
	<error type=oauth>
	<bad-requestxmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/>
	</error>
	</iq>

	*/
	struct token_handler:public handler_helper_base<token_handler>
	{
		void do_handleIqID(const IQ& iq, int context)
		{
			json::jobject jobj;
			if (iq.m_subtype != gloox::IQ::Result)
			{
				const Error* e = iq.error();
				if(!e)return;
				universal_resource error_desc;
				std::string err_code = std::string("biz.token.err_") + StanzaError2String[e->error()];
				error_desc = XL(err_code);
				ELOG("app")->error(error_desc.res_value_utf8);
				do_callback(true, error_desc, jobj);
			}
			else
			{
				if(iq.findExtension(kExtUser_iq_filter_get_token))
				{
					boost::shared_ptr<gloox::Tag> tag(iq.findExtension(kExtUser_iq_filter_get_token)->tag());
					if (tag)
					{
						if(tag->findChild("item"))
						{
							if(tag->findChild("item")->findChild("expires_in"))
							{
								jobj["expires_in"] = tag->findChild("item")->findChild("expires_in")->cdata();
							}
							if(tag->findChild("item")->findChild("access_token"))
							{
								jobj["access_token"] = tag->findChild("item")->findChild("access_token")->cdata();
							}
						}
						if(jobj.is_nil("expires_in") || jobj.is_nil("access_token"))
						{
							do_callback(true,XL("biz.token.server_return_wrong_data"),jobj);
						}
						else
						{
							do_callback(false,XL(""),jobj);
						}
						return;
					}
				}
				ELOG("app")->error(WCOOL(L"获取token时，服务器返回的数据格式错误。") + boost::shared_ptr<gloox::Tag>(iq.tag())->xml());
				do_callback(true, XL("biz.token.server_return_wrong_data"), jobj);
			}			
		}
	};

	void glooxWrapInterface::get_token(std::string service_id, Result_Data_Callback callback)
	{
		if(!work_thread_aligner_.is_in_expect_thread())
		{
			work_thread_aligner_.post(boost::bind(&glooxWrapInterface::get_token, this, service_id, callback));
			return;
		}
		typedef BasicStanza<kExtUser_iq_filter_get_token> iq_prelogin;
		gloox::IQ iq(gloox::IQ::Get, JID("sso." + domain_));
		gloox::Tag* tag_query = create_tag("query","xmlns","token","");
		if (service_id == "null")
		{
			service_id = "";
		}
		std::map<std::string, std::string> child_attrs = map_list_of("service_id",service_id);
		gloox::Tag* tag_child = new gloox::Tag("item");
		if (service_id.empty())
			tag_child->addEmptyAttribute("service_id");
		else
			tag_child->addAttribute("service_id",service_id);
		tag_query->addChild(tag_child);
		iq.addExtension(new iq_prelogin(tag_query));
		pclient_->registerStanzaExtension(new iq_prelogin(NULL, "/iq/query[@xmlns='token']"));
		pclient_->send(iq, new handler_helper<token_handler>(callback), 0, true, false, false);
	}

	//追加域名到指定did
	std::string glooxWrapInterface::append_discussions_domain( std::string id )
	{
		return id + "@" + discussions_domain_;
	}
	
	std::string glooxWrapInterface::append_groups_domain( std::string id )
	{
		return id + "@" + groups_domain_;
	}	
	// 	<iq to='discussions.ruijie.com.cn' id='uid:8ae56538:00000023' type='get'>
	// 		<query xmlns='list'>
	// 		<item id='' topic=''/>
	// 		</query>
	// 	</iq>
	void glooxWrapInterface::get_discussions_list(Result_Data_Callback callback)
	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","list");

		gloox::Tag* child_tag = new gloox::Tag("item");
		child_tag->addEmptyAttribute("id");
		child_tag->addEmptyAttribute("topic");

		tag_query->addChild(child_tag);
		typedef BasicStanza<kExtUser_iq_filter_getdiscussionslist> iq_getdiscussionslist;
		gloox::IQ iq(gloox::IQ::Get, JID(discussions_domain_));

		iq.addExtension(new iq_getdiscussionslist(tag_query));
		pclient_->registerStanzaExtension(new iq_getdiscussionslist(NULL, "/iq/query[@xmlns='list']"));
		pclient_->send(iq, new GetDiscussionsListHandler(callback), 0, true, false, false);
	}

	// 	<iq to='discussions.ruijie.com.cn' id='uid:8ae56538:00000027' type='set'>
	// 		<query xmlns='create'>
	// 		<item topic='普通讨论组'/>
	// 		</query>
	// 	</iq>
	void glooxWrapInterface::create_discussions( std::string topic, Result_Data_Callback callback )
	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","create");

		gloox::Tag* child_tag = new gloox::Tag("item");
		child_tag->addAttribute("topic", topic);

		tag_query->addChild(child_tag);
		typedef BasicStanza<kExtUser_iq_filter_creatediscussions> iq_creatediscussions;
		gloox::IQ iq(gloox::IQ::Set, JID(discussions_domain_));
		iq.addExtension(new iq_creatediscussions(tag_query));
		pclient_->send(iq, new CreateDiscussionsHandler(callback), 0, true, false, false);
	}

	// 	<iq to='384723@discussions.ruijie.com.cn' id='uid:944f6538:00000028' type='set'>
	// 		<query xmlns='invite'>
	// 		<item uid='1430522198011218980@ruijie.com.cn'/>
	// 		<item uid='1430522199011202329@ruijie.com.cn'/>
	// 		<item uid='chenli@ruijie.com.cn'/>
	// 		<item uid='liyingke@ruijie.com.cn'/>
	// 		<item uid='miaoqiang@ruijie.com.cn'/>
	// 		<item uid='shibb@ruijie.com.cn'/>
	// 		</query>
	// 	</iq>
	void glooxWrapInterface::invite_discussions( std::string did, std::vector<std::string> uid, Result_Data_Callback callback )
	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","invite");

		std::vector<std::string>::iterator it;
		for (it = uid.begin(); it!= uid.end(); it++)
		{
			JID iuser(*it);
			gloox::Tag* child_tag = new gloox::Tag("item");
			child_tag->addAttribute("userid", iuser.username());
			child_tag->addEmptyAttribute("name");
			child_tag->addEmptyAttribute("status");
			child_tag->addEmptyAttribute("sex");
			child_tag->addEmptyAttribute("identity");
			child_tag->addEmptyAttribute("photo_credential");
			tag_query->addChild(child_tag);
		}

		typedef BasicStanza<kExtUser_iq_filter_invitediscussions> iq_invitediscussions;
		gloox::IQ iq(gloox::IQ::Set, JID(did));

		iq.addExtension(new iq_invitediscussions(tag_query));
		pclient_->registerStanzaExtension(new iq_invitediscussions(NULL, "/iq/query[@xmlns='invite']"));
		pclient_->send(iq, new InviteDiscussionsHandler(callback), 0, true, false, false);
	}


	// 	<iq to='1231312@discussions.ruijie.com.cn' id='uid:9fe56538:00000027' type='get'>
	// 		<query xmlns='member'>
	// 		<item uid='' name='' status='' sex='' identity='' photo_credential=''/>
	// 		</query>
	// 	</iq>
	void glooxWrapInterface::get_discussions_memberlist( std::string did, Result_Data_Callback callback )
	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","member");

		gloox::Tag* child_tag = new gloox::Tag("item");
		child_tag->addEmptyAttribute("userid");
		child_tag->addEmptyAttribute("name");
		child_tag->addEmptyAttribute("status");
		child_tag->addEmptyAttribute("sex");
		child_tag->addEmptyAttribute("identity");
		child_tag->addEmptyAttribute("photo_credential");

		tag_query->addChild(child_tag);
		typedef BasicStanza<kExtUser_iq_filter_getdiscussionsmemberlist> iq_getdiscussionsmemberlist;
		gloox::IQ iq(gloox::IQ::Get, JID(did));

		iq.addExtension(new iq_getdiscussionsmemberlist(tag_query));
		pclient_->registerStanzaExtension(new iq_getdiscussionsmemberlist(NULL, "/iq/query[@xmlns='member']"));
		pclient_->send(iq, new GetDiscussionsMemberListHandler(callback), 0, true, false, false);
	}

	// 	<iq to='1231312@discussions.ruijie.com.cn' id='uid:a5f36538:00000028' type='set'>
	// 		<query xmlns='quit'>
	// 		<actor uid='quanli'/>
	// 		</query>
	// 	</iq>
	void glooxWrapInterface::quit_discussions( std::string did, std::string uid, Result_Data_Callback callback )
	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","quit");

		gloox::Tag* child_tag = new gloox::Tag("actor");
		child_tag->addAttribute("userid", uid);

		tag_query->addChild(child_tag);
		typedef BasicStanza<kExtUser_iq_filter_quitdiscussions> iq_quitdiscussions;
		gloox::IQ iq(gloox::IQ::Set, JID(did));
		iq.addExtension(new iq_quitdiscussions(tag_query));
		pclient_->send(iq, new QuitDiscussionsHandler(callback), 0, true, false, false);
	}


	//发送讨论组会话消息
	void glooxWrapInterface::send_msg( std::string did, std::string const& txt_msg, std::string const& msg )
	{
		Message smessage( Message::Groupchat, did, txt_msg, EmptyString, msg );
		pclient_->send( smessage );
	}

	gloox::Tag* glooxWrapInterface::create_mobile_tag( std::string sam_account,json::jobject jobj_sys_info )
	{
		gloox::Tag* tag_query = create_tag("query","xmlns","login","");
		gloox::Tag* child_mobile_tag = create_tag("account","","",sam_account);
		tag_query->addChild(child_mobile_tag);
		child_mobile_tag = create_tag("network","type",jobj_sys_info["network_type"].get<std::string>(),"");
		tag_query->addChild(child_mobile_tag);
		child_mobile_tag = create_tag("domain","","",jobj_sys_info["domain"].get<std::string>());
		tag_query->addChild(child_mobile_tag);

		std::map<std::string, std::string> client_attr = map_list_of("type", jobj_sys_info["client_type"].get<std::string>())("xmlns", "ruijie:statistics");
		gloox::Tag* child_mobile_client = create_tag("client",client_attr,"");
		gloox::Tag* child_mobile = create_tag("software","","","");
		gloox::Tag* child_mobile_soft = create_tag("whistle","","","");
		gloox::Tag* child_mobile_version = create_tag("version","","",jobj_sys_info["whistle_version"].get<std::string>());
		child_mobile_soft->addChild(child_mobile_version);
		child_mobile->addChild(child_mobile_soft);
		child_mobile_soft = create_tag("os","","","");
		gloox::Tag* child_mobile_system = create_tag("system","","",jobj_sys_info["system"].get<std::string>());
		child_mobile_version = create_tag("version","","",jobj_sys_info["system_version"].get<std::string>());
		child_mobile_soft->addChild(child_mobile_system);
		child_mobile_soft->addChild(child_mobile_version);
		child_mobile->addChild(child_mobile_soft);
		child_mobile_soft = create_tag("carrier","","",jobj_sys_info["carrier"].get<std::string>());
		child_mobile->addChild(child_mobile_soft);
		child_mobile_client->addChild(child_mobile);

		child_mobile = create_tag("hardware","","","");
		gloox::Tag* child_mobile_hardware = create_tag("model","","",jobj_sys_info["model"].get<std::string>());
		child_mobile->addChild(child_mobile_hardware);
		child_mobile_hardware = create_tag("ram","","",jobj_sys_info["ram"].get<std::string>());
		child_mobile->addChild(child_mobile_hardware);
		child_mobile_hardware = create_tag("rom","","",jobj_sys_info["rom"].get<std::string>());
		child_mobile->addChild(child_mobile_hardware);
		child_mobile_hardware = create_tag("sd","","",jobj_sys_info["sd"].get<std::string>());
		child_mobile->addChild(child_mobile_hardware);
		child_mobile_client->addChild(child_mobile);
		tag_query->addChild(child_mobile_client);
		return tag_query;
	}

	gloox::Tag* glooxWrapInterface::create_pc_tag( std::string sam_account,json::jobject jobj_sys_info )
	{
		gloox::Tag* tag_query = create_tag("query","xmlns","login","");
		gloox::Tag* child_pc_tag = create_tag("account","","",sam_account);
		tag_query->addChild(child_pc_tag);
		child_pc_tag = create_tag("network","type",jobj_sys_info["network_type"].get<std::string>(),"");
		tag_query->addChild(child_pc_tag);
		child_pc_tag = create_tag("domain","","",jobj_sys_info["domain"].get<std::string>());
		tag_query->addChild(child_pc_tag);

		std::map<std::string, std::string> client_attr = map_list_of("type", jobj_sys_info["client_type"].get<std::string>())("xmlns", "ruijie:statistics");
		gloox::Tag* child_pc_client = create_tag("client",client_attr,"");
		gloox::Tag* child_pc = create_tag("software","","","");
		gloox::Tag* child_pc_soft = create_tag("whistle","","","");
		gloox::Tag* child_pc_version = create_tag("version","","",jobj_sys_info["whistle_version"].get<std::string>());
		child_pc_soft->addChild(child_pc_version);
		child_pc->addChild(child_pc_soft);
		child_pc_soft = create_tag("os","","","");
		gloox::Tag* child_pc_system = create_tag("system","","",jobj_sys_info["system"].get<std::string>());
		child_pc_version = create_tag("version","","",jobj_sys_info["system_version"].get<std::string>());
		child_pc_soft->addChild(child_pc_system);
		child_pc_soft->addChild(child_pc_version);
		child_pc->addChild(child_pc_soft);
		child_pc_client->addChild(child_pc);
		child_pc = create_tag("hardware","","","");
		gloox::Tag* child_pc_hardware = create_tag("cpu","","",jobj_sys_info["cpu"].get<std::string>());
		child_pc->addChild(child_pc_hardware);
		child_pc_hardware = create_tag("memory","","",jobj_sys_info["memory"].get<std::string>());
		child_pc->addChild(child_pc_hardware);
		child_pc_hardware = create_tag("displaycard","","",jobj_sys_info["displaycard"].get<std::string>());
		child_pc->addChild(child_pc_hardware);
		child_pc_client->addChild(child_pc);
		tag_query->addChild(child_pc_client);
		return tag_query;
	}

	//<iq to='status.wuyiu.edu.cn' id='uid:2e4e3c30:00000013' type='set'>
	//<query xmlns='status:unsubscribe'>
	//<item node='presence' user='48'/>
	//</query>
	//</iq>
	void glooxWrapInterface::temporary_attention( std::string uid, bool cancel, boost::function<void(bool,universal_resource)> callback )
	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		std::string query_space;
		if (cancel)
		{
			//取消订阅
			query_space = "memory:status:unsubscribe";
		}
		else
		{
			//增加订阅
			query_space = "memory:status:subscribe";

		}
		tag_query->addAttribute("xmlns",query_space);
		gloox::Tag* child_tag = new gloox::Tag("item");
		child_tag->addAttribute("node", "presence");
		child_tag->addAttribute("user", uid);
		tag_query->addChild(child_tag);

		typedef BasicStanza<kExtUser_iq_filter_temporary_attention> iq_temporary_attention;
		gloox::IQ iq(gloox::IQ::Set, JID("pubsub."+ domain_));
		iq.addExtension(new iq_temporary_attention(tag_query));
		pclient_->registerStanzaExtension(new iq_temporary_attention(NULL, std::string("\"/iq/query[@xmlns='") + query_space + std::string("inactive']\"")));
		pclient_->send(iq, new TemporaryAttentionHandler(callback), 0, true, false, false);
	}

	// 	<iq to='organization.wuyiu.edu.cn' id='uid:e5603c30:00000021' type='get'>
	// 		<query xmlns='organization:search'>
	// 			<condition>
	// 				<name>汪奇</name>
	// 			</condition>
	// 			<result>
	// 				<organization/>
	// 				<username/>
	// 				<name/>
	// 				<sex/>
	// 				<identity/>
	// 				<mood_words/>
	// 				<photo_credential/>
	// 				<photo_live/>
	// 			</result>
	// 		</query>
	// 	</iq>
	void glooxWrapInterface::organization_search( std::string name, Result_Data_Callback callback )
	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","organization:search");
		gloox::Tag* child_tag = new gloox::Tag("condition");
		gloox::Tag* condition = new gloox::Tag("name", name);
		child_tag->addChild(condition);
		tag_query->addChild(child_tag);
		gloox::Tag* child_tag2 = new gloox::Tag("result");
		child_tag2->addChild(new gloox::Tag("organization"));
		child_tag2->addChild(new gloox::Tag("username"));
		child_tag2->addChild(new gloox::Tag("name"));
		child_tag2->addChild(new gloox::Tag("sex"));
		child_tag2->addChild(new gloox::Tag("identity"));
		child_tag2->addChild(new gloox::Tag("mood_words"));
		child_tag2->addChild(new gloox::Tag("photo_credential"));
		child_tag2->addChild(new gloox::Tag("photo_live"));
		tag_query->addChild(child_tag2);

		typedef BasicStanza<kExtUser_iq_filter_organization_search> iq_organization_search;
		gloox::IQ iq(gloox::IQ::Get, JID("organization."+ domain_));
		iq.addExtension(new iq_organization_search(tag_query));
		pclient_->registerStanzaExtension(new iq_organization_search(NULL, "/iq/query[@xmlns='organization:search']"));
		pclient_->send(iq, new organizationSearchHandler(callback), 0, true, false, false);
	}

	//<iq to='2@wuyiu.edu.cn' id='uid:bc464c30:0000002e' type='set'>
	//<query xmlns='ruijie:filedak:send'>
	//<file>dEOqHk8eqYLNTRwZjC_GVHwiADvRcVRo.ppt</file>
	//<html>{&quot;msg_extension&quot;:&quot;send_file&quot;,&quot;msg&quot;:{&quot;uri&quot;:&quot;dEOqHk8eqYLNTRwZjC_GVHwiADvRcVRo.ppt&quot;,&quot;file_name&quot;:&quot;D:\\MMV1.0C20120905.ppt&quot;,&quot;file_length&quot;:12639232}}</html>
	//</query>
	//</iq>
	void glooxWrapInterface::send_file_msg( std::string jid, std::string uri, std::string filename, int file_size, boost::function<void(bool,universal_resource)> callback )
	{
		if(!work_thread_aligner_.is_in_expect_thread())
		{
			work_thread_aligner_.post(boost::bind(&glooxWrapInterface::send_file_msg, this, jid, uri, filename, file_size, callback));
			return;
		}
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","ruijie:filedak:send");
		gloox::Tag* fileuri = new gloox::Tag("file", uri);
		tag_query->addChild(fileuri);

		//{msg_extension: “send_file”, msg: { file_name: “测试.zip”, file_length: 4096, uri: “5dac0b7427284b73f242508b.zip”}}
		json::jobject jobj;
		jobj["msg_extension"] = "send_file";
		json::jobject jmsg;
		jmsg["file_name"] = filename;
		jmsg["file_length"] = file_size;
		jmsg["uri"] = uri;
		jobj["msg"] = jmsg;
		gloox::Tag* html = new gloox::Tag("html", jobj.to_string());
		tag_query->addChild(html);

		typedef BasicStanza<kExtUser_iq_filter_send_file_msg> iq_send_file_msg;
		gloox::IQ iq(gloox::IQ::Set, JID(jid).username() + "@" + filedak_domain_);
		iq.addExtension(new iq_send_file_msg(tag_query));
		pclient_->registerStanzaExtension(new iq_send_file_msg(NULL, "/iq/query[@xmlns='ruijie:filedak:send']"));
		pclient_->send(iq, new SendFileMsgHandler(callback), 0, true, false, false);
	}

	//<iq to='2@wuyiu.edu.cn' id='uid:be854c30:0000002f' type='set'>
	//<query xmlns='ruijie:filedak:recv'>
	//<file id='874832'/>
	//</query>
	//</iq>
	void glooxWrapInterface::cancel_send_file_msg( std::string jid, std::string id, boost::function<void(bool,universal_resource)> callback)
	{
		if(!work_thread_aligner_.is_in_expect_thread())
		{
			work_thread_aligner_.post(boost::bind(&glooxWrapInterface::cancel_send_file_msg, this, jid, id, callback));
			return;
		}
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","ruijie:filedak:recv");
		gloox::Tag* file = new gloox::Tag("file");
		file->addAttribute("id",id);
		tag_query->addChild(file);

		typedef BasicStanza<kExtUser_iq_filter_cancel_send_file_msg> iq_cancel_send_file_msg;
		gloox::IQ iq(gloox::IQ::Set, JID(jid).username() + "@" + filedak_domain_);
		iq.addExtension(new iq_cancel_send_file_msg(tag_query));
		pclient_->registerStanzaExtension(new iq_cancel_send_file_msg(NULL, "/iq/query[@xmlns='ruijie:filedak:recv']"));
		pclient_->send(iq, new SendFileMsgHandler(callback), 0, true, false, false);
	}

	/*
	<iq type=’set’to=’100086@discussions.ruijie.com.cn’>
	<query xmlns=’modify>
	<actor uid=’392’name=’test6’ />
	<item id=’100086’topic=’标题党’ />
	</query>
	</iq>
	*/

	void glooxWrapInterface::change_discussions_name(std::string group_chat_jid,std::string group_topic,std::string group_chat_id,std::string uid,std::string user_name,Result_Callback callback)
	{
		if(!work_thread_aligner_.is_in_expect_thread())
		{
			work_thread_aligner_.post(boost::bind(&glooxWrapInterface::change_discussions_name, this, group_chat_jid, group_topic, group_chat_id, uid, user_name, callback));
			return;
		}
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","modify");
		gloox::Tag* tag_child = new gloox::Tag("actor");
		tag_child->addAttribute("uid",uid);
		tag_child->addAttribute("name",user_name);
		tag_query->addChild(tag_child);
		tag_child = new gloox::Tag("item");
		tag_child->addAttribute("id",group_chat_id);
		tag_child->addAttribute("topic",group_topic);
		tag_query->addChild(tag_child);

		typedef BasicStanza<kExtUser_iq_filter_changediscussionsname> iq_change_discussions_name;
		gloox::IQ iq(gloox::IQ::Set, JID(group_chat_jid));

		iq.addExtension(new iq_change_discussions_name(tag_query));
		pclient_->registerStanzaExtension(new iq_change_discussions_name(NULL, "/iq/query[@xmlns='modify']"));
		pclient_->send(iq, new ChangeDiscussionsNameHandler(callback), 0, true, false, false);
	}

	/*
	<presence to='392@wuyiu.edu.cn' type='subscribe' from='55@wuyiu.edu.cn'/>
	*/
	void glooxWrapInterface::ignore_request_to_be_friends( std::string to_jid )
	{
		if(!work_thread_aligner_.is_in_expect_thread())
		{
			work_thread_aligner_.post(boost::bind(&glooxWrapInterface::ignore_request_to_be_friends, this, to_jid));
			return;
		}
		gloox::Tag* presence = new gloox::Tag("presence","type","ignore");
		presence->addAttribute("to",to_jid);
		presence->addAttribute("from",pclient_->jid().bare());
		pclient_->send(presence);
	}
	/*	1.添加陌生人:
	<iq type="set">
	<query xmlns="jabber:iq:private">
	<stranger xmlns="hash:set">
	<item key="123">
	<!-- key 表示 UID -->
	<uid>123</uid>
	<name>老师</name>
	</item>
	</stranger>
	</query>
	</iq>
	*/

	void glooxWrapInterface::add_a_stranger(std::string key,std::string uid,std::string name/*,Result_Callback callback*/)
	{
		if(!work_thread_aligner_.is_in_expect_thread())
		{
			work_thread_aligner_.post(boost::bind(&glooxWrapInterface::add_a_stranger, this, key, uid, name));
			return;
		}
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","jabber:iq:private");
		gloox::Tag* tag_stranger = new gloox::Tag("stranger");
		tag_stranger->addAttribute("xmlns","hash:set");
		gloox::Tag* tag_item = new gloox::Tag("item");
		tag_item->addAttribute("key",key);
		gloox::Tag* tag_child = new gloox::Tag("uid");
		tag_child->addCData(uid);
		tag_item->addChild(tag_child);
		tag_child = new gloox::Tag("name");
		tag_child->addCData(name);
		tag_item->addChild(tag_child);
		tag_stranger->addChild(tag_item);
		tag_query->addChild(tag_stranger);

		typedef BasicStanza<kExtUser_iq_filter_add_a_stranger> iq_add_a_stranger;
		gloox::IQ iq(gloox::IQ::Set, JID(""));

		iq.addExtension(new iq_add_a_stranger(tag_query));
		pclient_->registerStanzaExtension(new iq_add_a_stranger(NULL, "/iq/query[@xmlns='jabber:iq:private']"));
		pclient_->send(iq, NULL/*new addAStrangerHandler(callback)*/, 0, true, false, false);
	}
	/*	2.删除陌生人:
	<iq type="set">
	<query xmlns="jabber:iq:private">
	<stranger xmlns="hash:unset">
	<item key="123"/>
	</stranger>
	</query>
	</iq>
	*/

	void glooxWrapInterface::remove_a_stranger(std::string key,Result_Callback callback)
	{
		if(!work_thread_aligner_.is_in_expect_thread())
		{
			work_thread_aligner_.post(boost::bind(&glooxWrapInterface::remove_a_stranger, this, key, callback));
			return;
		}
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","jabber:iq:private");
		gloox::Tag* tag_stranger = new gloox::Tag("stranger");
		tag_stranger->addAttribute("xmlns","hash:unset");
		gloox::Tag* tag_item = new gloox::Tag("item");
		tag_item->addAttribute("key",key);
		tag_stranger->addChild(tag_item);
		tag_query->addChild(tag_stranger);

		typedef BasicStanza<kExtUser_iq_filter_remove_a_stranger> iq_remove_a_stranger;
		gloox::IQ iq(gloox::IQ::Set, JID(""));
		iq.addExtension(new iq_remove_a_stranger(tag_query));
		pclient_->registerStanzaExtension(new iq_remove_a_stranger(NULL, "/iq/query[@xmlns='jabber:iq:private']"));
		pclient_->send(iq, new removeAStrangerHandler(callback), 0, true, false, false);
	}
	/*
	3.获取陌生人列表
	<iq type="get">
	<query xmlns="jabber:iq:private">
	<stranger xmlns="hash:get"/>
	</query>
	</iq>
	*/

	void glooxWrapInterface::get_stranger_list(Result_Data_Callback callback)
	{
		if(!work_thread_aligner_.is_in_expect_thread())
		{
			work_thread_aligner_.post(boost::bind(&glooxWrapInterface::get_stranger_list, this, callback));
			return;
		}
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","jabber:iq:private");
		gloox::Tag* tag_stranger = new gloox::Tag("stranger","xmlns","hash:get");
		tag_query->addChild(tag_stranger);

		typedef BasicStanza<kExtUser_iq_filter_get_stranger_list> iq_get_stranger_list;
		gloox::IQ iq(gloox::IQ::Get, JID(""));
		iq.addExtension(new iq_get_stranger_list(tag_query));
		pclient_->registerStanzaExtension(new iq_get_stranger_list(NULL, "/iq/query[@xmlns='jabber:iq:private']"));
		pclient_->send(iq, new getStrangerListHandler(callback), 0, true, false, false);
	}
	/*
	4.通知别的设备陌生人列表更新:
	<presence to='33@wuyiu.edu'>
	<query xmlns="jabber:iq:private">
	<stranger xmlns="hash:set">
	<item key="123">  <!-- key 表示 UID--> 
	<uid>123</uid>
	<name>老师</name>
	</item>
	</stranger>
	</query>
	</presence>

	*/
	void glooxWrapInterface::notice_other_stranger_list_updated(std::string jid,std::string key,std::string uid,std::string name)
	{
		if(!work_thread_aligner_.is_in_expect_thread())
		{
			work_thread_aligner_.post(boost::bind(&glooxWrapInterface::notice_other_stranger_list_updated, this, jid, key, uid, name));
			return;
		}
		gloox::Tag* presence = new gloox::Tag("presence","to",jid);
		gloox::Tag* tag_query = new gloox::Tag("query","xmlns","jabber:iq:private");
		gloox::Tag* tag_stranger = new gloox::Tag("stranger","xmlns","hash::set");
		gloox::Tag* tag_item = new gloox::Tag("item","key",key);
		gloox::Tag* tag_child = new gloox::Tag("uid");
		tag_child->addCData(uid);
		tag_item->addChild(tag_child);
		tag_child = new gloox::Tag("name");
		tag_child->addCData(name);
		tag_item->addChild(tag_child);
		tag_stranger->addChild(tag_item);
		tag_query->addChild(tag_stranger);
		presence->addChild(tag_query);
		pclient_->send(presence);
	}

	void glooxWrapInterface::set_aligner( epius::thread_align const& aligner )
	{
		work_thread_aligner_ = aligner;
	}

	//ack_type "read" "recv"
	void glooxWrapInterface::ack_app_message( std::string message_id, std::string ack_type)
	{
		if(!work_thread_aligner_.is_in_expect_thread())
		{
			work_thread_aligner_.post(boost::bind(&glooxWrapInterface::ack_app_message, this, message_id, ack_type));
			return;
		}

		gloox::Tag *tag_sdk = new gloox::Tag("query", XMLNS, "http://ruijie.com.cn/message#report");
		gloox::Tag *child_tag = new gloox::Tag("message", "id", message_id);
		child_tag->addAttribute("action", ack_type);
		tag_sdk->addChild(child_tag);

		std::string strjid = "notification." + get_domain();

		typedef BasicStanza<kExtUser_iq_filter_sdkmessage_ack> iq_appmessage_ack;
		IQ ack_message(IQ::Set, JID(strjid));
		ack_message.addExtension(new iq_appmessage_ack(tag_sdk));
		pclient_->send(ack_message, true, true);
	}


	static gloox::Tag* create_iq_node(std::string field_attr_value,std::string filed_attr_mode,std::string field_attr_value_, std::string value_data)
	{
		gloox::Tag *tag_field = new gloox::Tag("field");
		tag_field->addAttribute("var",field_attr_value);
		if(!filed_attr_mode.empty())
		{
			tag_field->addAttribute("mode",filed_attr_mode);
		}
		tag_field->addAttribute("type",field_attr_value_);
		gloox::Tag *tag_value = new gloox::Tag("value",value_data);
		tag_field->addChild(tag_value);
		return tag_field;
	}

	void glooxWrapInterface::find_friend(std::map<std::string,std::string>& friend_info, boost::function<void(bool ,json::jobject)> callback )
	{
		std::map<std::string,std::string>::iterator it;

		gloox::Tag* tag_query;
		gloox::Tag* tag_x;
		gloox::Tag* tag_set;
		tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","jabber:iq:search");
		tag_query->addAttribute("type","friend");

		tag_x = new gloox::Tag("x");
		tag_x->addAttribute("xmlns","jabber:x:data");
		tag_x->addAttribute("type","submit");
		tag_x->addChild(create_iq_node("FORM_TYPE","", "hidden","jabber:iq:search"));

		std::string mode = "exact";
		if(friend_info.find("mode")!=friend_info.end()) mode = friend_info["mode"];

		//按昵称查找
		it = friend_info.find("nick_name");		
		if (it != friend_info.end())
		{
			tag_x->addChild(create_iq_node("nick_name",mode,"text-single",it->second));
		}
		//按姓名查找
		it = friend_info.find("name");
		if (it != friend_info.end())
		{
			tag_x->addChild(create_iq_node("name",mode,"text-single",it->second));
		}
		//按aid查找
		it = friend_info.find("aid");
		if (it != friend_info.end())
		{
			tag_x->addChild(create_iq_node("aid","exact","text-single",it->second));
		}
		tag_set = new gloox::Tag("set");
		tag_set->addAttribute("xmlns","http://jabber.org/protocol/rsm");
		it = friend_info.find("index");
		if (it != friend_info.end())
		{
			tag_set->addChild(new gloox::Tag("index",it->second));
		}

		it = friend_info.find("max");
		if (it != friend_info.end())
		{
			tag_set->addChild(new gloox::Tag("max",it->second));
		}
		tag_x->addChild(tag_set);
		tag_set = NULL;

		//请求返还的字段
		tag_set = new gloox::Tag("result");
		tag_set->addChild(new gloox::Tag("username"));
		tag_set->addChild(new gloox::Tag("name"));
		tag_set->addChild(new gloox::Tag("sex"));
		tag_set->addChild(new gloox::Tag("nativeplace_province"));
		tag_set->addChild(new gloox::Tag("birthday"));
		tag_set->addChild(new gloox::Tag("hobby"));
		tag_set->addChild(new gloox::Tag("mood_words"));
		tag_set->addChild(new gloox::Tag("photo_credential"));
		tag_set->addChild(new gloox::Tag("organization"));
		tag_set->addChild(new gloox::Tag("identity"));
		tag_set->addChild(new gloox::Tag("aid"));
		tag_set->addChild(new gloox::Tag("vcard_privacy"));

		tag_x->addChild(tag_set);
		tag_query->addChild(tag_x);

		std::string strjid = "search." +domain_;

		typedef BasicStanza<kExtUser_iq_filter_find_friend> iq_find_friend;
		gloox::IQ iq(gloox::IQ::Set, JID(strjid));
		iq.addExtension(new iq_find_friend(tag_query));
		pclient_->registerStanzaExtension(new iq_find_friend(NULL, "/iq/query[@xmlns='jabber:iq:search']"));
		pclient_->send(iq, new findFriendHandler(callback), 0, true, true, true);
	}




	/* get_groups_list
	<iq type=’get’ from=’123456@ruijie.com.cn/pc’ to=’groups.ruijie.com.cn‘>
	　　	<query xmlns=’groups:list’ timestamp=’’>
		　　		<item id=’’ name=’’ icon=”” v=”” />
				</query>
				</iq>
				*/
	void glooxWrapInterface::get_groups_list(Result_Data_Callback callback)
	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","groups:list");
		gloox::Tag* child_tag = new gloox::Tag("item");
		child_tag->addEmptyAttribute("id");
		child_tag->addEmptyAttribute("name");
		child_tag->addEmptyAttribute("icon");
		child_tag->addEmptyAttribute("v");
		child_tag->addEmptyAttribute("alert");
		child_tag->addEmptyAttribute("role");
		child_tag->addEmptyAttribute("quit");
		child_tag->addEmptyAttribute("status");
		child_tag->addEmptyAttribute("dismiss");
		child_tag->addEmptyAttribute("active");
		child_tag->addEmptyAttribute("remark");
		child_tag->addEmptyAttribute("category");

		tag_query->addChild(child_tag);
		typedef BasicStanza<kExtUser_iq_filter_getgroupslist> iq_getgroupslist;
		gloox::IQ iq(gloox::IQ::Get, JID(groups_domain_));

		iq.addExtension(new iq_getgroupslist(tag_query));
		pclient_->registerStanzaExtension(new iq_getgroupslist(NULL, "/iq/query[@xmlns='groups:list']"));
		pclient_->send(iq, new GetGroupsListHandler(callback), 0, true, true, false);
	}

	/*get_groups_memberlist
	　　<iq type=’get’from=’123456@ruijie.com.cn/pc’ to=’112@groups.ruijie.com.cn‘>
	  <query xmlns=’groups:member:list’>
	  <item jid=’’ name=’’ icon=”” status=””role=”all|admin|super|none”/>
	  </query>
	  </iq>
	  */
	void glooxWrapInterface::get_groups_member_list( std::string did , Result_Data_Callback callback)
	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","groups:member:list");

		gloox::Tag* child_tag = new gloox::Tag("item");
		child_tag->addEmptyAttribute("jid");
		child_tag->addEmptyAttribute("name");
		child_tag->addEmptyAttribute("photo_credential");
		child_tag->addEmptyAttribute("status");
		child_tag->addEmptyAttribute("sex");
		child_tag->addEmptyAttribute("identity");
		child_tag->addEmptyAttribute("role");
		child_tag->addEmptyAttribute("last_talk_time");
		child_tag->addEmptyAttribute("aid");
		child_tag->addEmptyAttribute("resource");

		tag_query->addChild(child_tag);
		typedef BasicStanza<kExtUser_iq_filter_getgroupsmemberlist> iq_getgroupsmemberlist;
		gloox::IQ iq(gloox::IQ::Get, JID(did));

		iq.addExtension(new iq_getgroupsmemberlist(tag_query));
		pclient_->registerStanzaExtension(new iq_getgroupsmemberlist(NULL, "/iq/query[@xmlns='groups:member:list']"));
		pclient_->send(iq, new GetGroupsMemberListHandler(callback), 0, true, true, false);
	}

	void glooxWrapInterface::get_groups_admin_list( std::string did , Result_Data_Callback callback)
	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","groups:member:admin-list");

		gloox::Tag* child_tag = new gloox::Tag("item");
		child_tag->addEmptyAttribute("jid");
		child_tag->addEmptyAttribute("name");
		child_tag->addEmptyAttribute("photo_credential");
		child_tag->addEmptyAttribute("status");
		child_tag->addEmptyAttribute("sex");
		child_tag->addEmptyAttribute("identity");
		child_tag->addEmptyAttribute("role");

		tag_query->addChild(child_tag);
		typedef BasicStanza<kExtUser_iq_filter_getgroupsadminlist> iq_getgroupsadminlist;
		gloox::IQ iq(gloox::IQ::Get, JID(did));

		iq.addExtension(new iq_getgroupsadminlist(tag_query));
		pclient_->registerStanzaExtension(new iq_getgroupsadminlist(NULL, "/iq/query[@xmlns='groups:member:admin-list']"));
		pclient_->send(iq, new GetGroupsAdminListHandler(callback), 0, true, true, false);
	}

	void glooxWrapInterface::get_groups_info( std::string did, Result_Data_Callback callback )
	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","groups:info");

		gloox::Tag* child_tag = new gloox::Tag("item");
		child_tag->addEmptyAttribute("name");
		child_tag->addEmptyAttribute("createtime");
		child_tag->addEmptyAttribute("cur_member_size");
		child_tag->addEmptyAttribute("announce");
		child_tag->addEmptyAttribute("max_member_size");
		child_tag->addEmptyAttribute("max_space_size");
		child_tag->addEmptyAttribute("cur_space_size");
		child_tag->addEmptyAttribute("description");
		child_tag->addEmptyAttribute("dismiss");
		child_tag->addEmptyAttribute("auth_type");
		child_tag->addEmptyAttribute("v");
		child_tag->addEmptyAttribute("icon");
		child_tag->addEmptyAttribute("alert");
		child_tag->addEmptyAttribute("category");
		child_tag->addEmptyAttribute("role");
		child_tag->addEmptyAttribute("admin_applying");
		child_tag->addEmptyAttribute("quit");
		child_tag->addEmptyAttribute("remark");
		child_tag->addEmptyAttribute("find");
		child_tag->addEmptyAttribute("active");
		child_tag->addEmptyAttribute("status");

		tag_query->addChild(child_tag);
		typedef BasicStanza<kExtUser_iq_filter_getgroupsinfo> iq_getgroupsinfo;
		gloox::IQ iq(gloox::IQ::Get, JID(did));

		iq.addExtension(new iq_getgroupsinfo(tag_query));
		pclient_->registerStanzaExtension(new iq_getgroupsinfo(NULL, "/iq/query[@xmlns='groups:info']"));
		pclient_->send(iq, new GetGroupsInfoHandler(callback), 0, true, true, false);
	}

	/*change_groups_info　　
	<iq type=’set’ from=’123456@ruijie.com.cn/pc’ to=’122@groups.ruijie.com.cn‘>
	　　	<query xmlns=’groups:info’ notify=”true/false”>
		　　		<actor jid=”123456@ruijie.com.cn” name=”张三” nick_name=”天天甜甜” sex=”boy”  />
				　　		<item name=”吃货群” icon=”icon_url” catgory ="" 分类 announce=”公告”/>
						　　 </query>
						   　</iq>*/

	void glooxWrapInterface::change_groups_info(std::string did, json::jobject actor,json::jobject item ,Result_Callback callback)
	{

		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","groups:info");
		if (!item.is_nil("icon") || !item.is_nil("announce") || !item.is_nil("name") || !item.is_nil("category"))
		{
			tag_query->addAttribute("notify","true");
		}
		else
		{
			tag_query->addAttribute("notify","false");
		}

		gloox::Tag* tag_child = new gloox::Tag("actor");
		tag_child->addAttribute("jid",actor["jid"].get<std::string>());
		tag_child->addAttribute("name",actor["name"].get<std::string>());
		tag_child->addAttribute("nick_name",actor["nick_name"].get<std::string>());
		tag_child->addAttribute("sex",actor["sex"].get<std::string>());
		tag_query->addChild(tag_child);

		tag_child = new gloox::Tag("item");
		if (!item.is_nil("name"))
		{
			tag_child->addAttribute("name", item["name"].get<std::string>());
		}
		if (!item.is_nil("icon"))
		{
			tag_child->addAttribute("icon",item["icon"].get<std::string>());
		}
		if (!item.is_nil("announce"))
		{
			if (item["announce"].get<std::string>().empty())
			{
				tag_child->addEmptyAttribute("announce");
			}
			else
			{
				tag_child->addAttribute("announce",item["announce"].get<std::string>());
			}
		}
		if (!item.is_nil("description"))
		{
			if (item["description"].get<std::string>().empty())
			{
				tag_child->addEmptyAttribute("description");
			}
			else
			{
				tag_child->addAttribute("description",item["description"].get<std::string>());
			}
		}
		if (!item.is_nil("find"))
		{
			tag_child->addAttribute("find",item["find"].get<std::string>());
		}
		if (!item.is_nil("auth_type"))
		{
			tag_child->addAttribute("auth_type",item["auth_type"].get<std::string>());
		}
		if (!item.is_nil("category"))
		{
			tag_child->addAttribute("category",item["category"].get<std::string>());
		}
		tag_query->addChild(tag_child);

		typedef BasicStanza<kExtUser_iq_filter_changegroupsinfo> iq_change_groups_info;
		gloox::IQ iq(gloox::IQ::Set, JID(did));

		iq.addExtension(new iq_change_groups_info(tag_query));
		pclient_->registerStanzaExtension(new iq_change_groups_info(NULL, "/iq/query[@xmlns='groups:info']"));
		pclient_->send(iq, new ChangeGroupsInfoHandler(callback), 0, true, true, false);
	}
	/*　　quit_groups
	<iq type=’set’ from=’123456@ruijie.com.cn/pc’ to=’112@groups.ruijie.com.cn‘>
	　　 	<query xmlns=’groups:member:quit’ />
		　　		<item jid=” 123456@ruijie.com.cn” 
				　　name=’奥巴马’ icon=’icon_url’ sex=’girl’ />
				  　　</query>
					　　</iq>*/
	void glooxWrapInterface::quit_groups( std::string did, json::jobject item, Result_Callback callback )
	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","groups:member:quit");

		gloox::Tag* child_tag = new gloox::Tag("item");
		child_tag->addAttribute("jid", item["jid"].get<std::string>());
		child_tag->addAttribute("name", item["name"].get<std::string>());
		child_tag->addAttribute("nike_name", item["nike_name"].get<std::string>());
		child_tag->addAttribute("icon",item["icon"].get<std::string>());
		child_tag->addAttribute("sex", item["sex"].get<std::string>());
		child_tag->addAttribute("identity", item["identity"].get<std::string>());
		child_tag->addAttribute("role", "none");

		tag_query->addChild(child_tag);

		typedef BasicStanza<kExtUser_iq_filter_quitgroups> iq_quitgroups;
		gloox::IQ iq(gloox::IQ::Set, JID(did));
		iq.addExtension(new iq_quitgroups(tag_query));
		pclient_->registerStanzaExtension(new iq_quitgroups(NULL, "/iq/query[@xmlns='groups:member:quit']"));

		pclient_->send(iq, new QuitGroupsHandler(callback), 0, true, true, false);
	}

	/*　kickout_member_groups　
	<iq type=’set’ from=’123456@ruijie.com.cn/pc’ to=’112@groups.ruijie.com.cn‘>
	　　 	<query xmlns=’groups: member:kickout’ />
		　　<actor jid=”123456@ruijie.com.cn” name=”张三” nick_name=”天天甜甜” sex=”boy” icon=”icon_url” />
		  　　		<item jid=’654321@groups.ruijie.com.cn’ name=’吃货群’ nick_name=’奥巴马’ icon=’icon_url’ />
					　　</query>
					  　　</iq>*/


	void glooxWrapInterface::groups_kickout_member( std::string session_id ,json::jobject actor, json::jobject item ,json::jobject groups, Result_Callback callback )
	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","groups:member:kickout");

		gloox::Tag* tag_child = new gloox::Tag("actor");
		tag_child->addAttribute("jid",actor["jid"].get<std::string>());
		tag_child->addAttribute("name",actor["name"].get<std::string>());
		tag_query->addChild(tag_child);

		tag_child = new gloox::Tag("item");
		tag_child->addAttribute("jid",item["jid"].get<std::string>());
		tag_child->addAttribute("name",item["name"].get<std::string>());
		tag_query->addChild(tag_child);

		tag_child = new gloox::Tag("groups");
		tag_child->addAttribute("id", session_id);
		tag_child->addAttribute("name",groups["name"].get<std::string>());
		tag_child->addAttribute("category",groups["category"].get<std::string>());
		tag_child->addAttribute("icon",groups["icon"].get<std::string>());
		tag_query->addChild(tag_child);

		typedef BasicStanza<kExtUser_iq_filter_groupskickoutmember> iq_kickoutmember;
		gloox::IQ iq(gloox::IQ::Set, JID(session_id));
		iq.addExtension(new iq_kickoutmember(tag_query));
		pclient_->registerStanzaExtension(new iq_kickoutmember(NULL, "/iq/query[@xmlns='groups:member:kickout']"));

		pclient_->send(iq, new GroupsKickoutMemberHandler(callback), 0, true, true, false);
	}
	/*
	　　<iq type=’set’ from=’123456@ruijie.com.cn/pc’ to=’groups.ruijie.com.cn’>
	  　　	<query xmlns=’groups:create’>
			　　		<item name=”吃货群” icon=”icon_url” dismiss=”false” announce=”公告”
					description=”吃遍全天下” category=”15” />
					　　</query>
					  　　</iq>
						*/
	void glooxWrapInterface::create_groups( json::jobject item, Result_Data_Callback callback )//
	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","groups:create");

		gloox::Tag* child_tag = new gloox::Tag("item");
		child_tag->addAttribute("name", item["name"].get<std::string>());

		if (!item.is_nil("icon")) //创建群时可以不设置群图标
		{
			child_tag->addAttribute("icon", item["icon"].get<std::string>());
		}

		child_tag->addAttribute("category", item["category"].get<std::string>());
		child_tag->addAttribute("auth_type", item["auth_type"].get<std::string>());

		tag_query->addChild(child_tag);
		typedef BasicStanza<kExtUser_iq_filter_creategroups> iq_creategroups;
		gloox::IQ iq(gloox::IQ::Set, JID(groups_domain_));
		iq.addExtension(new iq_creategroups(tag_query));

		pclient_->registerStanzaExtension(new iq_creategroups(NULL,"/iq/query[@xmlns='groups:create']"));
		pclient_->send(iq, new CreateGroupsHandler(callback), 0, true, true, false);
	}
	/*dismiss_groups
	　　<iq type=’set’ from=’123456@ruijie.com.cn/pc’ to=’112@groups.ruijie.com.cn‘>
	  　　	<query xmlns=’groups:dismiss’>
			　　		<actor jid=”123456@ruijie.com.cn” name=”张三” nick_name=”天天甜甜” sex=”boy” icon=”icon_url” />
					　　		<item name=’吃货群’ />
							　　</query>
							  　　</iq>

								*/

	void glooxWrapInterface::dismiss_groups( std::string session_id, json::jobject actor, json::jobject item, Result_Callback callback )
	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","groups:dismiss");

		gloox::Tag* tag_child = new gloox::Tag("actor");
		tag_child->addAttribute("jid",actor["jid"].get<std::string>());
		tag_child->addAttribute("name",actor["name"].get<std::string>());
		tag_query->addChild(tag_child);

		tag_child = new gloox::Tag("item");
		tag_child->addAttribute("name", item["name"].get<std::string>());
		tag_child->addAttribute("icon", item["icon"].get<std::string>());
		tag_child->addAttribute("category", item["category"].get<std::string>());
		tag_query->addChild(tag_child);

		typedef BasicStanza<kExtUser_iq_filter_dismissgroups> iq_dismissgroups;
		gloox::IQ iq(gloox::IQ::Set, JID(session_id));
		iq.addExtension(new iq_dismissgroups(tag_query));

		pclient_->registerStanzaExtension(new iq_dismissgroups(NULL,"/iq/query[@xmlns='groups:dismiss']"));
		pclient_->send(iq, new DismissGroupsHandler(callback), 0, true, true, false);
	}
	/*
	　　<iq type=’set’ from=’123456@ruijie.com.cn/pc’ to=’112@groups.ruijie.com.cn‘>
	  　　	<query xmlns=’groups:member:apply’>
			　　		<actor jid=”123456@ruijie.com.cn” name=”张三” nick_name=”天天甜甜” sex=”boy” icon=”icon_url’ msg=’我想加入’ />
					　　</query>
					  　　</iq>
						*/

	void glooxWrapInterface::apply_join_groups( std::string did , json::jobject actor ,std::string reason, Result_Data_Callback callback )
	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","groups:member:apply");

		gloox::Tag* tag_child = new gloox::Tag("actor");

		tag_child->addAttribute("jid",actor["jid"].get<std::string>());
		tag_child->addAttribute("name",actor["name"].get<std::string>());
		tag_child->addAttribute("sex",actor["sex"].get<std::string>());
		tag_child->addAttribute("icon",actor["icon"].get<std::string>());
		tag_child->addAttribute("identity",actor["identity"].get<std::string>());
		tag_query->addChild(tag_child);

		gloox::Tag* tag_child_item = new gloox::Tag("item");
		tag_child_item->addEmptyAttribute("name");
		tag_child_item->addEmptyAttribute("icon");
		tag_child_item->addEmptyAttribute("quit");
		tag_child_item->addEmptyAttribute("dismiss");
		tag_child_item->addEmptyAttribute("status");
		tag_child_item->addEmptyAttribute("v");
		tag_child_item->addEmptyAttribute("active");
		tag_child_item->addEmptyAttribute("category");
		tag_child_item->addEmptyAttribute("role");
		tag_child_item->addEmptyAttribute("alert");
		tag_query->addChild(tag_child_item);

		gloox::Tag* tag_child_html = new gloox::Tag("html");
		tag_child_html->addCData(reason);
		tag_query->addChild(tag_child_html);
		typedef BasicStanza<kExtUser_iq_filter_applyjoingroups> iq_applyjoingroups;
		gloox::IQ iq(gloox::IQ::Set, JID(did));
		iq.addExtension(new iq_applyjoingroups(tag_query));

		pclient_->registerStanzaExtension(new iq_applyjoingroups(NULL,"/iq/query[@xmlns='groups:member:apply']"));
		pclient_->send(iq, new ApplyJoinGroupsHandler(callback), 0, true, true, false);
	}

	/*
	<iq type=’set’ from=’123456@ruijie.com.cn/pc’ to=’112@groups.ruijie.com.cn‘>
	<query xmlns=’groups:member:enter’  >
	</query>
	</iq>

	*/
	void glooxWrapInterface::enter_groups( std::string did , Result_Callback callback )
	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","groups:member:enter");

		typedef BasicStanza<kExtUser_iq_filter_entergroups> iq_entergroups;
		gloox::IQ iq(gloox::IQ::Set, JID(did));
		iq.addExtension(new iq_entergroups(tag_query));

		pclient_->registerStanzaExtension(new iq_entergroups(NULL,"/iq/query[@xmlns='groups:member:enter']"));
		pclient_->send(iq, new EnterGroupsHandler(callback), 0, true, true, false);
	}
	/*<iq type=’set’ from=’123456@ruijie.com.cn/pc’ to=’112@groups.ruijie.com.cn‘>
	<query xmlns=’groups: member:leave’ >
	</query>
	</iq>
	*/
	void glooxWrapInterface::leave_groups( std::string did  )
	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","groups:member:leave");

		typedef BasicStanza<kExtUser_iq_filter_leavegroups> iq_entergroups;
		gloox::IQ iq(gloox::IQ::Set, JID(did));
		iq.addExtension(new iq_entergroups(tag_query));

		pclient_->registerStanzaExtension(new iq_entergroups(NULL,"/iq/query[@xmlns='groups:member:leave']"));
		pclient_->send(iq, new LeaveGroupsHandler(), 0, true, true, false);
	}

	/*change_groups_member_info
	<iq type=’set’from=’123456@ruijie.com.cn/pc’ to=’112@groups.ruijie.com.cn‘>
	<queryxmlns=’groups:member:info’ />
	<item alert=’1’ />
	</query>
	</iq>

	*/

	void glooxWrapInterface::change_groups_member_info( std::string did ,std::string alert ,Result_Callback callback )
	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","groups:member:setting");
		tag_query->addAttribute("notify","true");
		JID jid(did);
		gloox::Tag* tag_child = new gloox::Tag("item");

		tag_child->addAttribute("alert",alert);
		tag_query->addChild(tag_child);

		typedef BasicStanza<kExtUser_iq_filter_changegroupsmemberinfo> iq_changegroupsmemberinfo;
		gloox::IQ iq(gloox::IQ::Set, jid);
		iq.addExtension(new iq_changegroupsmemberinfo(tag_query));

		pclient_->registerStanzaExtension(new iq_changegroupsmemberinfo(NULL,"/iq/query[@xmlns='groups:member:setting']"));
		pclient_->send(iq, new ChangeGroupsMemberInfoHandler(callback), 0, true, true, false);
	}

	/*
	<iq type=’get’from=’123456@ruijie.com.cn/pc’ to=’112@groups.ruijie.com.cn‘>
	<queryxmlns=’groups:share:list’ />
	<set page=’1’pagesize=’10’pagetotal=”” />
	<item id=””name=”” size=”” owner=””uri=””/>
	</query>
	</iq>

	*/
	void glooxWrapInterface::get_groups_share_list( std::string did, std::string orderby, Result_Data_Callback callback)
	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","groups:share:list");
		std::string index="0";//暂时加上，共享列表暂时不分页，故起始值为零
		std::string max="65536";//暂时加上，共享列表暂时不分页，故给出较大值
		gloox::Tag* tag_child = new gloox::Tag("set");
		gloox::Tag* tag_index = new gloox::Tag("index",index);
		tag_child->addChild(tag_index);
		gloox::Tag* tag_max = new gloox::Tag("max",max);
		tag_child->addChild(tag_max);
		gloox::Tag* tag_order = new gloox::Tag("order_by",orderby);
		tag_child->addChild(tag_order);

		tag_query->addChild(tag_child);

		tag_child = new gloox::Tag("item");
		tag_child->addEmptyAttribute("id");
		tag_child->addEmptyAttribute("name");
		tag_child->addEmptyAttribute("size");
		tag_child->addEmptyAttribute("owner_jid");
		tag_child->addEmptyAttribute("owner_name");
		tag_child->addEmptyAttribute("download_count");
		tag_child->addEmptyAttribute("create_time");
		tag_child->addEmptyAttribute("uri");
		tag_query->addChild(tag_child);

		typedef BasicStanza<kExtUser_iq_filter_getgroupssharelist> iq_kickoutmember;
		gloox::IQ iq(gloox::IQ::Get, JID(did));
		iq.addExtension(new iq_kickoutmember(tag_query));
		pclient_->registerStanzaExtension(new iq_kickoutmember(NULL, "/iq/query[@xmlns='groups:share:list']"));

		pclient_->send(iq, new GetGroupsShareListHandler(callback), 0, true, true, false);
	}

	/*
	<iq type=’set’from=’123456@ruijie.com.cn/pc’ to=’112@groups.ruijie.com.cn‘>
	<query xmlns=’groups:share:create’ />
	<actor jid=’123456@ruijie.com.cn’nick_name=”奥巴马” />
	<item id=‘’
	name=”苍老师.avi” size=”80000” owner_jid=”123456@ruijie.com.cn”
	owner_name=”奥黑”uri=”xxxx.xx”/>
	</query>
	</iq>


	*/
	void glooxWrapInterface::upload_file_groups_share( std::string did ,json::jobject actor,json::jobject item ,Result_Callback callback )
	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","groups:share:create");

		gloox::Tag* tag_child = new gloox::Tag("actor");
		tag_child->addAttribute("jid",actor["jid"].get<std::string>());
		tag_query->addChild(tag_child);

		tag_child = new gloox::Tag("item");
		tag_child->addEmptyAttribute("id");
		tag_child->addAttribute("name",item["name"].get<std::string>());
		tag_child->addAttribute("size",item["size"].get<std::string>());
		tag_child->addAttribute("owner_jid",actor["jid"].get<std::string>());
		tag_child->addAttribute("uri",item["uri"].get<std::string>());
		tag_query->addChild(tag_child);

		typedef BasicStanza<kExtUser_iq_filter_uploadfilegroupsshare> iq_uploadfilegroupsshare;
		gloox::IQ iq(gloox::IQ::Set, JID(did));
		iq.addExtension(new iq_uploadfilegroupsshare(tag_query));

		pclient_->registerStanzaExtension(new iq_uploadfilegroupsshare(NULL,"/iq/query[@xmlns='groups:share:create']"));
		pclient_->send(iq, new UploadFileGroupsShareHandler(callback), 0, true, true, false);
	}

	/*
	<iq type=’set’from=’123456@ruijie.com.cn/pc’ to=’112@groups.ruijie.com.cn‘>
	<queryxmlns=’groups:share:download’ />
	<item id=‘1’ />
	</query>
	</iq>

	*/

	void glooxWrapInterface::download_file_groups_share( std::string did ,std::string id,Result_Callback callback )
	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","groups:share:download");

		gloox::Tag* tag_child = new gloox::Tag("item");

		tag_child->addAttribute("id",id);
		tag_query->addChild(tag_child);

		typedef BasicStanza<kExtUser_iq_filter_downloadfilegroupsshare> iq_downloadfilegroupsshare;
		gloox::IQ iq(gloox::IQ::Set, JID(did));
		iq.addExtension(new iq_downloadfilegroupsshare(tag_query));

		pclient_->registerStanzaExtension(new iq_downloadfilegroupsshare(NULL,"/iq/query[@xmlns='groups:share:download']"));
		pclient_->send(iq, new DownloadFileGroupsShareHandler(callback), 0, true, true, false);
	}

	/*
	<iq type=’set’from=’123456@ruijie.com.cn/pc’ to=’112@groups.ruijie.com.cn‘>
	<queryxmlns=’groups:share:delete’ />
	<item id=‘2’/>
	</query>
	</iq>

	*/

	void glooxWrapInterface::delete_file_groups_share( std::string did ,std::string id,Result_Callback callback )
	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","groups:share:delete");

		gloox::Tag* tag_child = new gloox::Tag("item");

		tag_child->addAttribute("id",id);
		tag_query->addChild(tag_child);

		typedef BasicStanza<kExtUser_iq_filter_deletefilegroupsshare> iq_deletefilegroupsshare;
		gloox::IQ iq(gloox::IQ::Set, JID(did));
		iq.addExtension(new iq_deletefilegroupsshare(tag_query));

		pclient_->registerStanzaExtension(new iq_deletefilegroupsshare(NULL,"/iq/query[@xmlns='groups:share:delete']"));
		pclient_->send(iq, new DeleteFileGroupsShareHandler(callback), 0, true, true, false);
	}

	/*<iq type=’set’from=’123456@ruijie.com.cn/pc’ to=’112@groups.ruijie.com.cn‘>
	<queryxmlns=’groups:share:permanent’ />
	<item id=‘2’ />
	</query>
	</iq>
	*/

	void glooxWrapInterface::set_groups_share_info( std::string did ,std::string id , std::string mode ,Result_Callback callback )
	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","groups:share:info	");

		gloox::Tag* tag_child = new gloox::Tag("item");

		tag_child->addAttribute("id",id);
		tag_child->addAttribute("mode",mode);//具体待定义，可以是永久变更或其他
		tag_query->addChild(tag_child);

		typedef BasicStanza<kExtUser_iq_filter_setgroupsshareinfo> iq_permanentfilegroupsshare;
		gloox::IQ iq(gloox::IQ::Set, JID(did));
		iq.addExtension(new iq_permanentfilegroupsshare(tag_query));

		pclient_->registerStanzaExtension(new iq_permanentfilegroupsshare(NULL,"/iq/query[@xmlns='groups:share:info']"));
		pclient_->send(iq, new PermanentFileGroupsShareHandler(callback), 0, true, true, false);
	}

	/*
	<iq type='get'  from='123456@ruijie.com.cn/pc ' to='search.ruijie.com.cn'
	xmlns='jabber:client'>
	<query xmlns='jabber:iq:search' type=’group’>
	<x xmlns='jabber:x:data' type='submit'>
	<field var='FORM_TYPE' type='hidden'>
	<value>jabber:iq:search</value>
	</field>
	<field var='id'  type='text-single'>
	<value>112</value>
	</field>
	<field var=’name’  mode=’exact/pre_fuzzy/suf_fuzzy/fuzzy’ type='text-single'>
	<value>吃货群 </value>
	</field>

	<set xmlns='http://jabber.org/protocol/rsm'>
	<index>0</index>
	<max>7</max>
	</set>
	<result>
	<name />
	<auth_type />
	<dismiss />
	<icon />
	</result>
	</x>
	</query>
	</iq>

	*/

	void glooxWrapInterface::find_groups(std::map<std::string,std::string>& groups_info, Result_Data_Callback callback )
	{
		std::map<std::string,std::string>::iterator it;

		gloox::Tag* tag_query;
		gloox::Tag* tag_x;
		gloox::Tag* tag_set;
		tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","jabber:iq:search");
		tag_query->addAttribute("type","groups");

		tag_x = new gloox::Tag("x");
		tag_x->addAttribute("xmlns","jabber:x:data");
		tag_x->addAttribute("type","submit");
		tag_x->addChild(create_iq_node("FORM_TYPE","", "hidden","jabber:iq:search"));

		std::string mode = "exact";
		if(groups_info.find("mode")!=groups_info.end()) mode = groups_info["mode"];

		//按id查找
		it = groups_info.find("id");		
		if (it != groups_info.end())
		{
			tag_x->addChild(create_iq_node("id","","text-single",it->second));
		}
		//按群名查找
		it = groups_info.find("name");
		if (it != groups_info.end())
		{
			tag_x->addChild(create_iq_node("name",mode,"text-single",it->second));
		}

		tag_set = new gloox::Tag("set");
		tag_set->addAttribute("xmlns","http://jabber.org/protocol/rsm");
		it = groups_info.find("index");
		if (it != groups_info.end())
		{
			tag_set->addChild(new gloox::Tag("index",it->second));
		}

		it = groups_info.find("max");
		if (it != groups_info.end())
		{
			tag_set->addChild(new gloox::Tag("max",it->second));
		}
		tag_x->addChild(tag_set);
		tag_set = NULL;

		//请求返还的字段
		tag_set = new gloox::Tag("result");
		tag_set->addChild(new gloox::Tag("id"));
		tag_set->addChild(new gloox::Tag("name"));
		tag_set->addChild(new gloox::Tag("auth_type"));
		tag_set->addChild(new gloox::Tag("icon"));
		tag_set->addChild(new gloox::Tag("category"));
		tag_set->addChild(new gloox::Tag("cur_member_size"));
		tag_set->addChild(new gloox::Tag("description"));
		tag_set->addChild(new gloox::Tag("max_member_size"));
		tag_set->addChild(new gloox::Tag("quit"));
		tag_set->addChild(new gloox::Tag("v"));
		tag_set->addChild(new gloox::Tag("active"));
		tag_set->addChild(new gloox::Tag("status"));
		tag_x->addChild(tag_set);
		tag_query->addChild(tag_x);
		std::string strjid = "search." +domain_;

		typedef BasicStanza<kExtUser_iq_filter_findgroups> iq_findgroups;
		gloox::IQ iq(gloox::IQ::Get, JID(strjid));
		iq.addExtension(new iq_findgroups(tag_query));
		pclient_->registerStanzaExtension(new iq_findgroups(NULL, "/iq/query[@xmlns='jabber:iq:search']"));
		pclient_->send(iq, new FindGroupsHandler(callback), 0, false, true, true);
	}

	/*
	<iq type=’get’from=’123456@ruijie.com.cn/pc’ to=’groups.ruijie.com.cn‘>
	<query xmlns=’groups:recent”>
	<item id=”112” conversation_id=”xxxx” />
	<item id=”132” conversation_id=”yyyy” />
	…
	</query>
	</iq>

	*/

	void glooxWrapInterface::get_groups_recent_messages( std::map<std::string , std::string> ids)
	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","groups:recent");
		std::map<std::string , std::string>::iterator its=ids.begin();

		for (;its!=ids.end();its++)
		{
			gloox::Tag* tag_child = new gloox::Tag("item");;
			tag_child->addAttribute("id",(*its).first);
			tag_child->addAttribute("conversation_id",(*its).second);
			tag_query->addChild(tag_child);
		}

		typedef BasicStanza<kExtUser_iq_filter_getgroupsrecentmessages> iq_getgroupsrecentmessages;
		gloox::IQ iq(gloox::IQ::Set, JID(groups_domain_));
		iq.addExtension(new iq_getgroupsrecentmessages(tag_query));

		pclient_->registerStanzaExtension(new iq_getgroupsrecentmessages(NULL,"/iq/query[@xmlns='groups:recent']"));
		pclient_->send(iq, new GetGroupsRecentMessagesHandler(), 0, true, true, false);
	}


	//增加或者编辑隐私列表或者黑名单
	// <iq from='romeo@example.net/orchard' type='set' id='edit1'>
	// 	<query xmlns='jabber:iq:privacy'>
	// 	<list name='public'>
	// 	<item type='jid' value='tybalt@example.com'	action='deny' order='3'/>
	// 	<item type='jid' value='paris@example.org' action='deny'	order='5'> <message/> </item>
	// 	</list>
	// 	</query>
	// 	</iq>

	void glooxWrapInterface::edit_privacy_list(json::jobject jobj,Result_Data_Callback callback )
	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","jabber:iq:privacy");
		gloox::Tag* tag_list = new gloox::Tag("list");
		tag_list->addAttribute("name","invisable");

		if (jobj["jids"] && jobj["orders"])
		{
			int jid_count = jobj["jids"].arr_size();
			for (int i = 0;i < jid_count;i++)
			{
				gloox::Tag* tag_item = new gloox::Tag("item");	
				gloox::Tag* tag_message = new gloox::Tag("message");
				tag_item->addAttribute("type","jid");
				tag_item->addAttribute("action","deny");
				tag_item->addAttribute("value",jobj["jids"][i].get<std::string>());
				tag_item->addAttribute("order",jobj["orders"][i].get<std::string>());
				tag_item->addChild(tag_message);
				tag_list->addChild(tag_item);	
			}	
		}	
		tag_query->addChild(tag_list);

		//向外发送
		typedef BasicStanza<kExtUser_iq_filter_move_to_privacy_list> iq_add_or_edit_privacy_list;
		gloox::IQ iq(gloox::IQ::Set, JID(""));
		iq.addExtension(new iq_add_or_edit_privacy_list(tag_query));
		pclient_->registerStanzaExtension(new iq_add_or_edit_privacy_list(NULL,"/iq/query[@xmlns='jabber:iq:privacy']"));
		pclient_->send(iq, new EditPrivacyHandler(callback),0, true, true, false);
	}



	/*　　<iq type=’set’from=’123456@ruijie.com.cn/pc’ to=’112@groups.ruijie.com.cn‘>
	　　	<query xmlns=’groups:member:apply:accept| deny’>
		　　		<actor jid=”123456@ruijie.com.cn” name=”张三”nick_name=”天天甜甜” sex=”boy”  />
				　　		<item jid=’654321@ruijie.com.cn’ name=’被审批人的昵称’ />
						　　</query>
						  　　</iq>*/

	void glooxWrapInterface::groups_admin_manage_member( std::string session_id , std::string accept, std::string reject_reason , std::string apply_reason , json::jobject actor, json::jobject item, json::jobject crowd ,Result_Callback callback )
	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		gloox::Tag* tag_child;
		if (accept=="yes")
		{
			tag_query->addAttribute("xmlns","groups:member:apply:accept");
			tag_child = new gloox::Tag("html");
			tag_child->addCData(apply_reason);
			tag_query->addChild(tag_child);
		}
		else{
			tag_query->addAttribute("xmlns","groups:member:apply:deny");
			tag_child = new gloox::Tag("html");
			tag_child->addCData(reject_reason);
			tag_query->addChild(tag_child);
		}

		tag_child = new gloox::Tag("item");
		tag_child->addAttribute("jid",actor["jid"].get<std::string>());
		tag_child->addAttribute("name",actor["name"].get<std::string>());
		tag_child->addAttribute("sex",actor["sex"].get<std::string>());
		tag_child->addAttribute("identity",actor["identity"].get<std::string>());
		tag_child->addAttribute("icon",actor["icon"].get<std::string>());
		tag_query->addChild(tag_child);

		tag_child = new gloox::Tag("actor");
		tag_child->addAttribute("jid",item["jid"].get<std::string>());
		tag_child->addAttribute("name",item["name"].get<std::string>());
		tag_child->addAttribute("sex",item["sex"].get<std::string>());
		tag_child->addAttribute("role",item["role"].get<std::string>());
		tag_child->addAttribute("identity",item["identity"].get<std::string>());
		tag_query->addChild(tag_child);

		tag_child = new gloox::Tag("groups");
		tag_child->addAttribute("name",crowd["name"].get<std::string>());
		tag_child->addAttribute("icon",crowd["icon"].get<std::string>());
		tag_child->addAttribute("category",crowd["category"].get<std::string>());
		tag_child->addAttribute("quit",crowd["quit"].get<std::string>());
		tag_child->addAttribute("v",crowd["official"].get<std::string>());
		tag_child->addAttribute("status",crowd["status"].get<std::string>());
		tag_child->addAttribute("active",crowd["active"].get<std::string>());
		tag_child->addAttribute("dismiss",crowd["dismiss"].get<std::string>());
		tag_query->addChild(tag_child);

		typedef BasicStanza<kExtUser_iq_filter_groupsadminmanagemember> iq_groupsadminmanagemember;
		gloox::IQ iq(gloox::IQ::Set, JID(session_id));
		iq.addExtension(new iq_groupsadminmanagemember(tag_query));

		if (accept=="yes")
		{
			pclient_->registerStanzaExtension(new iq_groupsadminmanagemember(NULL,"/iq/query[@xmlns='groups:member:apply:accept']"));
		}
		else{
			pclient_->registerStanzaExtension(new iq_groupsadminmanagemember(NULL,"/iq/query[@xmlns='groups:member:apply:deny']"));
		}
		pclient_->send(iq, new GroupsAdminManageMemberHandler(callback), 0, true, true, false);
	}
	/*
	　　<iq type=’set’from=’123456@ruijie.com.cn/pc’to=’112@groups.ruijie.com.cn’>
	  　　	<query xmlns=’groups:role:apply’>
			　　		<item name=’吃货群’ msg=’我想当管理员’/>
					</query>　
					　</iq>
					 */
	void glooxWrapInterface::groups_role_apply( std::string session_id , std::string reason , Result_Callback callback )
	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","groups:role:apply");
		gloox::Tag* tag_child = new gloox::Tag("html");
		tag_child->addCData(reason);
		tag_query->addChild(tag_child);
		typedef BasicStanza<kExtUser_iq_filter_groupsroleapply> iq_groupsroleapply;
		gloox::IQ iq(gloox::IQ::Set, JID(session_id));
		iq.addExtension(new iq_groupsroleapply(tag_query));

		pclient_->registerStanzaExtension(new iq_groupsroleapply(NULL,"/iq/query[@xmlns='groups:role:apply']"));

		pclient_->send(iq, new GroupsRoleApplyHandler(callback), 0, true, true, false);
	}

	/*
	　　<iq type=’set’from=’123456@ruijie.com.cn/pc’ to=’112@groups.ruijie.com.cn‘>
	  　　	<query xmlns=’groups:role:change’ />
			　　		<actor jid=”123456@ruijie.com.cn” name=”张三”nick_name=”天天甜甜” sex=”boy” icon=”icon_url” />
					　　		<item jid=’654321@ruijie.com.cn’ name=’李四’ role=”admin|none”/>
							　　</query>

							  */

	void glooxWrapInterface::groups_role_change( std::string session_id ,json::jobject actor, json::jobject item, Result_Callback callback )
	{
		gloox::Tag* tag_query = new gloox::Tag("query");

		tag_query->addAttribute("xmlns","groups:role:change");


		gloox::Tag* tag_child = new gloox::Tag("actor");
		tag_child->addAttribute("name",actor["name"].get<std::string>());
		tag_child->addAttribute("jid",actor["jid"].get<std::string>());
		tag_query->addChild(tag_child);

		tag_child = new gloox::Tag("item");
		tag_child->addAttribute("jid",item["jid"].get<std::string>());
		tag_child->addAttribute("role",item["role"].get<std::string>());
		tag_query->addChild(tag_child);

		typedef BasicStanza<kExtUser_iq_filter_groupsrolechange> iq_groupsrolechange;
		gloox::IQ iq(gloox::IQ::Set, JID(session_id));
		iq.addExtension(new iq_groupsrolechange(tag_query));

		pclient_->registerStanzaExtension(new iq_groupsrolechange(NULL,"/iq/query[@xmlns='groups:role:change']"));

		pclient_->send(iq, new GroupsRoleChangeHandler(callback), 0, true, true, false);
	}

	void glooxWrapInterface::groups_role_demise( std::string session_id ,std::string jid , json::jobject actor , Result_Callback callback )
	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","groups:role:demise");

		gloox::Tag* tag_child = new gloox::Tag("actor");
		tag_child->addAttribute("jid",actor["jid"].get<std::string>());
		tag_child->addAttribute("name",actor["name"].get<std::string>());
		tag_query->addChild(tag_child);

		tag_child = new gloox::Tag("item");
		tag_child->addAttribute("jid",jid);
		tag_query->addChild(tag_child);

		tag_child = new gloox::Tag("groups");
		tag_query->addChild(tag_child);

		typedef BasicStanza<kExtUser_iq_filter_groupsroledemise> iq_groupsroledemise;
		gloox::IQ iq(gloox::IQ::Set, JID(session_id));
		iq.addExtension(new iq_groupsroledemise(tag_query));

		pclient_->registerStanzaExtension(new iq_groupsroledemise(NULL,"/iq/query[@xmlns='groups:role:demise']"));
		pclient_->send(iq, new GroupsRoleDemiseHandler(callback), 0, true, true, false);
	}
	void glooxWrapInterface::invite_into_groups( std::string session_id , json::jobject actor, std::string jid,json::jobject groups, Result_Callback callback )
	{
		gloox::Tag* tag_query = new gloox::Tag("query");

		tag_query->addAttribute("xmlns","groups:member:invite");


		gloox::Tag* tag_child = new gloox::Tag("actor");
		tag_child->addAttribute("jid",actor["jid"].get<std::string>());
		tag_child->addAttribute("name",actor["name"].get<std::string>());
		tag_query->addChild(tag_child);

		tag_child = new gloox::Tag("item");
		tag_child->addAttribute("jid",jid);
		tag_query->addChild(tag_child);

		tag_child = new gloox::Tag("groups");
		tag_child->addAttribute("id",session_id);
		tag_child->addAttribute("name",groups["name"].get<std::string>());
		tag_child->addAttribute("icon",groups["icon"].get<std::string>());
		tag_child->addAttribute("category",groups["category"].get<std::string>());
		tag_query->addChild(tag_child);

		typedef BasicStanza<kExtUser_iq_filter_inviteintogroups> iq_inviteintogroups;
		gloox::IQ iq(gloox::IQ::Set, JID(session_id));
		iq.addExtension(new iq_inviteintogroups(tag_query));

		pclient_->registerStanzaExtension(new iq_inviteintogroups(NULL,"/iq/query[@xmlns='groups:member:invite']"));
		pclient_->send(iq, new InviteIntoGroupsHandler(callback), 0, true, true, false);
	}

	void glooxWrapInterface::answer_groups_invite( std::string session_id, std::string crowd_name, std::string icon, std::string category, std::string accept ,json::jobject actor, json::jobject item, std::string reason, bool never_accept, Result_Callback callback )
	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		if (accept=="yes")
		{
			tag_query->addAttribute("xmlns","groups:member:invite:accept");
		}
		else{
			tag_query->addAttribute("xmlns","groups:member:invite:deny");
		}

		gloox::Tag* tag_child = new gloox::Tag("actor");
		tag_child->addAttribute("jid",actor["jid"].get<std::string>());
		tag_child->addAttribute("name",actor["name"].get<std::string>());
		tag_query->addChild(tag_child);

		tag_child = new gloox::Tag("item");
		tag_child->addAttribute("jid",item["jid"].get<std::string>());
		tag_child->addAttribute("name",item["name"].get<std::string>());
		tag_child->addAttribute("sex",item["sex"].get<std::string>());
		tag_child->addAttribute("identity",item["identity"].get<std::string>());
		tag_child->addAttribute("icon",item["icon"].get<std::string>());
		tag_query->addChild(tag_child);

		tag_child = new gloox::Tag("groups");
		tag_child->addAttribute("id",session_id);
		tag_child->addAttribute("name",crowd_name);
		tag_child->addAttribute("icon",icon);
		tag_child->addAttribute("category",category);
		tag_query->addChild(tag_child);

		if (accept == "no")
		{
			gloox::Tag* tag_child_html = new gloox::Tag("html");
			tag_child_html->addCData(reason);
			tag_query->addChild(tag_child_html);
		}


		typedef BasicStanza<kExtUser_iq_filter_answergroupsinvite> iq_answergroupsinvite;
		gloox::IQ iq(gloox::IQ::Set, JID(session_id));
		iq.addExtension(new iq_answergroupsinvite(tag_query));

		if (accept =="yes")
		{
			pclient_->registerStanzaExtension(new iq_answergroupsinvite(NULL,"/iq/query[@xmlns='groups:member:invite:accept']"));
		}
		else{
			pclient_->registerStanzaExtension(new iq_answergroupsinvite(NULL,"/iq/query[@xmlns='groups:member:invite:deny']"));
		}
		pclient_->send(iq, new AnswerGroupsInviteHandler(callback), 0, true, true, false);
	}

	void glooxWrapInterface::get_create_groups_setting( Result_Data_Callback callback )
	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","groups:pre-create");
		gloox::Tag* child_tag = new gloox::Tag("item");
		child_tag->addEmptyAttribute("create_enable");
		child_tag->addEmptyAttribute("can_create");
		child_tag->addEmptyAttribute("max_member");
		child_tag->addEmptyAttribute("max_can_create");

		tag_query->addChild(child_tag);
		typedef BasicStanza<kExtUser_iq_filter_groupsprecreate> iq_groupsprecreate;
		gloox::IQ iq(gloox::IQ::Get, JID(groups_domain_));

		iq.addExtension(new iq_groupsprecreate(tag_query));
		pclient_->registerStanzaExtension(new iq_groupsprecreate(NULL, "/iq/query[@xmlns='groups:pre-create']"));
		pclient_->send(iq, new GetCreateGroupsSettingHandler(callback), 0, true, true, false);

	}

	void glooxWrapInterface::set_groups_member_info( std::string session_id , json::jobject jobj , json::jobject actor,Result_Callback callback )
	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","groups:member:info-v2");

		gloox::Tag* child_tag = new gloox::Tag("actor");
		child_tag->addAttribute("name",actor["name"].get<std::string>());
		child_tag->addAttribute("jid",actor["jid"].get<std::string>());
		tag_query->addChild(child_tag);
		if (!jobj.is_nil("name"))
		{
			tag_query->addAttribute("notify","true");
			child_tag = new gloox::Tag("item");
			child_tag->addAttribute("jid",jobj["jid"].get<std::string>());
			if (jobj["name"].get<std::string>().empty())
			{
				child_tag->addEmptyAttribute("name");
			}
			else
			{
				child_tag->addAttribute("name",jobj["name"].get<std::string>());
			}
			tag_query->addChild(child_tag);
		}
		else
		{
			tag_query->addAttribute("notify","false");
			child_tag = new gloox::Tag("item");
			child_tag->addAttribute("jid",actor["jid"].get<std::string>());
			if (!jobj.is_nil("remark"))
			{
				if (jobj["remark"].get<std::string>().empty())
				{
					child_tag->addEmptyAttribute("remark");
				}
				else
				{
					child_tag->addAttribute("remark",jobj["remark"].get<std::string>());
				}
			}
			tag_query->addChild(child_tag);
		}
		typedef BasicStanza<kExtUser_iq_filter_setgroupsmemberinfo> iq_setgroupsmemberinfo;
		gloox::IQ iq(gloox::IQ::Set, JID(session_id));

		iq.addExtension(new iq_setgroupsmemberinfo(tag_query));
		pclient_->registerStanzaExtension(new iq_setgroupsmemberinfo(NULL, "/iq/query[@xmlns='groups:member:info-v2']"));
		pclient_->send(iq, new SetGroupsMemerInfoHandler(callback), 0, true, true, false);
	}

	/*
	<iq to="permission.dev.ruijie.com.cn" id="2391fc380000000e" type="get" xmlns="jabber:client">
	<query xmlns="http://ruijie.com.cn/permission" />
	</iq>
	*/

	void glooxWrapInterface::is_show_organization( std::string to_jid,Result_Data_Callback callback )
	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","http://ruijie.com.cn/permission");		
		//向外发送
		typedef BasicStanza<kExtUser_iq_filter_organization_show> iq_is_show_organization;
		gloox::IQ iq(gloox::IQ::Get, JID(to_jid));
		iq.addExtension(new iq_is_show_organization(tag_query));
		pclient_->registerStanzaExtension(new iq_is_show_organization(NULL,"/iq/query[@xmlns='http://ruijie.com.cn/permission']"));
		pclient_->send(iq, new OrganizationShowHandller(callback),0, true, true, false);
	}

	/*text/image/location/link/event*/
	void glooxWrapInterface::lightapp_addChild(gloox::Tag* tag , std::string type , std::string child_name , std::string child_data)
	{
		if (type=="cdata")
		{
			gloox::Tag* child = new gloox::Tag(child_name);
			child->addCData("<![CDATA[" + child_data + "]]>");
			tag->addChild(child);
		}
		else
		{
			gloox::Tag* child = new gloox::Tag(child_name);
			child->addCData( child_data );
			tag->addChild(child);
		}
	}

	/*<message to='Lightapp.domain/appid' id='ba48dc380000003f' type='Normal' from='4162@wuyiu.edu.cn/pc' xmlns='jabber:client'>
	<body><LightApp></body></message>*/
	void glooxWrapInterface::send_lightapp_message(std::string appid, json::jobject msg, std::string msgid, std::string student_number)
	{
		gloox::Tag* message = new gloox::Tag("message");

		message->addAttribute("to",appid);
		message->addAttribute("type","Normal");
		message->addAttribute("from",pclient_->jid().full());
		message->addAttribute("xmlns","jabber:client");
		gloox::Tag* body = new gloox::Tag("body");
		gloox::Tag* tag_xml = new gloox::Tag("xml");

		lightapp_addChild(tag_xml,"cdata","tousername", appid);
		lightapp_addChild(tag_xml,"cdata","fromusername", pclient_->jid().full());
		lightapp_addChild(tag_xml,"cdata","fromstudentnumber", student_number);
		time_t now_time;
		now_time = time(NULL);
		msg["createtime"]=(int)now_time;
		lightapp_addChild(tag_xml,"string","createtime",msg["createtime"].get<std::string>());
		lightapp_addChild(tag_xml,"cdata","msgtype",msg["type"].get<std::string>());

		lightapp_addChild(tag_xml,"string","msgid", msgid);

		if (msg["type"].get<std::string>()=="text")
			lightapp_addChild(tag_xml,"cdata","content",msg["content"].get<std::string>());
		else if (msg["type"].get<std::string>()=="image")
			lightapp_addChild(tag_xml,"cdata","picurl",msg["image"].get<std::string>());
		else if (msg["type"].get<std::string>()=="voice")
			lightapp_addChild(tag_xml,"cdata","voiceurl",msg["voiceurl"].get<std::string>());
		else if (msg["type"].get<std::string>()=="location")
		{
			lightapp_addChild(tag_xml,"string","location_x",msg["location"]["location_x"].get<std::string>());
			lightapp_addChild(tag_xml,"string","location_y",msg["location"]["location_y"].get<std::string>());
			lightapp_addChild(tag_xml,"string","scale",msg["location"]["scale"].get<std::string>());
			lightapp_addChild(tag_xml,"cdata","label",msg["location"]["label"].get<std::string>());
		}
		else if (msg["type"].get<std::string>()=="link")
		{
			lightapp_addChild(tag_xml,"cdata","title",msg["link"]["title"].get<std::string>());
			lightapp_addChild(tag_xml,"cdata","description",msg["link"]["description"].get<std::string>());
			lightapp_addChild(tag_xml,"cdata","url",msg["link"]["url"].get<std::string>());
		}
		else if (msg["type"].get<std::string>()=="event")
		{
			lightapp_addChild(tag_xml,"cdata","event",msg["event"]["event"].get<std::string>());
			lightapp_addChild(tag_xml,"cdata","eventkey",msg["event"]["eventkey"].get<std::string>());
		}
		else if (msg["type"].get<std::string>()=="hello" )
		{
			lightapp_addChild(tag_xml,"cdata","hello_id",msg["hello_id"].get<std::string>());
		}
		body->addChild(tag_xml);
		message->addChild(body);
		pclient_->send( message );
	}

	void glooxWrapInterface::recv_msg_report( std::string appid , std::string msg_id )
	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","http://ruijie.com.cn/lightapp#report");
		gloox::Tag* child_tag = new gloox::Tag("message");
		child_tag->addAttribute("id",msg_id);
		child_tag->addAttribute("action","recv");
		tag_query->addChild(child_tag);
		//向外发送
		typedef BasicStanza<kExtUser_iq_filter_recv_msg_report> iq_recv_msg_report;
		gloox::IQ iq(gloox::IQ::Set, JID(appid));
		iq.addExtension(new iq_recv_msg_report(tag_query));
		pclient_->registerStanzaExtension(new iq_recv_msg_report(NULL,"/iq/query[@xmlns='http://ruijie.com.cn/lightapp#report']"));
		pclient_->send(iq,new LightAppIQCallback(Result_Callback()),0, true, true, false);
	}

	void glooxWrapInterface::can_recv_lightapp_message( Result_Callback callback )
	{
		gloox::Tag* tag_query = new gloox::Tag("query");
		tag_query->addAttribute("xmlns","get");
		
		//向外发送
		typedef BasicStanza<kExtUser_iq_filter_can_recv_lightapp_msg> iq_can_recv_lightapp_msg;
		gloox::IQ iq(gloox::IQ::Get, JID(LIGHTAPP_DOMAIN+domain_));
		iq.addExtension(new iq_can_recv_lightapp_msg(tag_query));
		pclient_->registerStanzaExtension(new iq_can_recv_lightapp_msg(NULL,"/iq/query[@xmlns='get']"));
		pclient_->send(iq, new LightAppIQCallback(callback),0, true, true, false);
	}

	void glooxWrapInterface::set_domain( std::string domain )
	{
		domain_ = domain;
		discussions_domain_ = DISCUSSIONS_DOMAIN + domain;
		filedak_domain_ = FILEDAK_DOMAIN + domain;
		groups_domain_ = GROUPS_DOMAIN + domain;
	}

}
