#include "groups_message_handler.h"
#include "glooxWrapInterface.h"
#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include "../gloox_src/message.h"
#include <base/time/time_format.h>
#include <boost/date_time/c_local_time_adjustor.hpp>


namespace gloox
{
	GroupsMessageHandler::GroupsMessageHandler()
	{
	}

	GroupsMessageHandler::~GroupsMessageHandler()
	{

	}



	/*
	kExtUser_msg_filter_creategroups
	*/

	void GroupsMessageHandler::handleMessage( const Message& msg, MessageSession* session /*= 0 */ )
	{
		boost::shared_ptr<gloox::Tag> msg_tag(msg.tag());
		std::string timestamp =msg_tag->findAttribute("timestamp");
		std::string server_time;
		long diff_secs;
//		_get_timezone(&diff_secs);//取时区
		if (!timestamp.empty())
		{
			boost::posix_time::ptime t = boost::posix_time::from_time_t(boost::lexical_cast<intmax_t>(timestamp)/1000/*+diff_secs*/);
			boost::posix_time::ptime local_time = boost::date_time::c_local_adjustor<boost::posix_time::ptime>::utc_to_local(t);
			server_time = epius::time_format(local_time);
		}
		else
		{
			server_time = "";
		}


		if (!msg.from().resource().empty() && !msg.from().bare().empty() && !msg.html().empty())
		{
			if(msg.findExtension(kExtUser_msg_filter_messageid))
			{
				std::string id = boost::shared_ptr<gloox::Tag>(msg.findExtension(kExtUser_msg_filter_messageid)->tag())->cdata();

				json::jobject jmsg;
				jmsg["jid"] = msg.from().resource();
				jmsg["from"] = msg.from().bare();
				jmsg["html"] = msg.html();
				jmsg["id"] = id;

				gWrapInterface::instance().groups_get_message(jmsg);
			}
			return;
		}

		//更改群信息的message
		/*
		<message type='headline’ from=’112@groups.ruijie.com.cn’ to=’xx@ruijie.com.cn’>
　　 	<query xmlns=’groups:info” notify=”true’>
　　		<actor jid=”123456@ruijie.com.cn” name=”张三” nick_name=”天天甜甜” sex=”boy”  />
　　		<item name=”吃货群” icon=”icon_url” announce =”公告”/>
　　	</query>
　　</message>
		*/
		if(msg.findExtension(kExtUser_msg_filter_changegroupsinfo))
		{
			boost::shared_ptr<gloox::Tag> tag(msg.findExtension(kExtUser_msg_filter_changegroupsinfo)->tag());
			if (tag)
			{
				
				
				json::jobject jobj,crowd;
				gloox::Tag* tchild(tag->findChild("item"));
				if (tchild->hasAttribute("status"))
				{
					jobj["status"]=tchild->findAttribute("status");
					jobj["old_status"]=tchild->findAttribute("old_status");
					jobj["category"]=tchild->findAttribute("category");
					jobj["server_time"]=server_time;
					jobj["name"]=tchild->findAttribute("name");
					jobj["icon"]=tchild->findAttribute("icon");
					if (tchild->findAttribute("status")=="0")
					{
						jobj["quit"]=tchild->findAttribute("quit");
						jobj["status"]=tchild->findAttribute("status");
						jobj["official"]=tchild->findAttribute("v");
						jobj["active"]=tchild->findAttribute("active");
						jobj["dismiss"]=tchild->findAttribute("dismiss");
						jobj["alert"]=tchild->findAttribute("alert");
						jobj["role"]=tchild->findAttribute("role");
					}

				}else
				{
					if (tchild->hasAttribute("announce"))
					{
						jobj["announce"]=tchild->findAttribute("announce");
					}
					if (tchild->hasAttribute("name"))
					{
						jobj["name"]=tchild->findAttribute("name");
					}
					if (tchild->hasAttribute("icon"))
					{
						jobj["icon"]=tchild->findAttribute("icon");
					}
					if (tchild->hasAttribute("category"))
					{
						jobj["category"]=tchild->findAttribute("category");
					}
					if (tchild->hasAttribute("v"))
					{
						jobj["official"]=tchild->findAttribute("v");
					}
				}
				jobj["session_id"]=msg.from().bare();

				gWrapInterface::instance().groups_info_change(jobj);
			}
			return;
		}

		/*
		<message from=’112@groups.ruijie.com.cn’ to=’123456@ruijie.com.cn’>
　　	<query xmlns=’groups:share: file:create’>
　　	<actor jid=”123456@ruijie.com.cn” name=”张三” nick_name=”天天甜甜” sex=”boy”  />	
		<item id=‘2’
　　filename=”苍老师.avi” size=”80000” owner=”123456@ruijie.com.cn” 
　　nick_name=”奥巴马” 
　　uri=”http://file.ruijie.com.cn/downlaod/xxxx.xx” />
　　	</query>
　　</message>
		*/
		if(msg.findExtension(kExtUser_msg_filter_uploadfilegroupsshare))
		{
			boost::shared_ptr<gloox::Tag> tag(msg.findExtension(kExtUser_msg_filter_uploadfilegroupsshare)->tag());
			if (tag)
			{
				json::jobject jobj,actor,item;
				gloox::Tag* tchild(tag->findChild("actor"));

				actor["jid"] =tchild->findAttribute("jid");
				actor["showname"] = tchild->findAttribute("name");
				actor["nick_name"] = tchild->findAttribute("nick_name");
				jobj["actor"]=actor;
				tchild=tag->findChild("item");
				item["id"]=tchild->findAttribute("id");
				item["name"]=tchild->findAttribute("name");
				item["size"]=tchild->findAttribute("size");
				item["owner_jid"]=tchild->findAttribute("owner_jid");
				item["owner_name"]=tchild->findAttribute("owner_name");
				item["uri"]=tchild->findAttribute("uri");
				jobj["file"] = item;

				jobj["server_time"]=server_time;
				jobj["session_id"]=msg.from().bare();
				jobj["type"] = "add";
				
				gWrapInterface::instance().groups_upload_file_share(jobj);
			}
			return;
		}
		/*
		
	<message from=’112@groups.ruijie.com.cn’ to=’xxx@ruijie.com.cn’>
　　<query xmlns=’groups:dismiss’>
　　		<actor jid=”123456@ruijie.com.cn” name=”张三” nick_name=”天天甜甜” sex=”boy” icon=”icon_url”  />
　　		<item name=’吃货群’ />
　　</query>
　　</message>
		*/
		
		if(msg.findExtension(kExtUser_msg_filter_dismissgroups))
		{
			boost::shared_ptr<gloox::Tag> tag(msg.findExtension(kExtUser_msg_filter_dismissgroups)->tag());
			if (tag)
			{
				json::jobject item,jobj,actor;
				jobj["session_id"] = msg.from().bare();

				gloox::Tag* tchild(tag->findChild("actor"));
				actor["jid"]=tchild->findAttribute("jid");
				actor["showname"]=tchild->findAttribute("name");
				jobj["actor"]=actor;

				tchild=tag->findChild("item");
				item["name"]=tchild->findAttribute("name");
				item["icon"]=tchild->findAttribute("icon");
				item["category"]=tchild->findAttribute("category");

				jobj["server_time"]=server_time;
				jobj["crowd_info"]=item;
				jobj["type"]="dismiss";
				gWrapInterface::instance().groups_list_change(jobj);
			}
			return;
		}	

		/*
		<message type=’result’ from=’112@groups.ruijie.com.cn’ to=’xxx@ruijie.com.cn’>
　　 	<query xmlns=’groups: member:quit ‘>
　　		<item jid=” 123456@ruijie.com.cn”name=’奥巴马’ icon=’icon_url’ sex=’girl’ />
　　	</query>
		</ message >
		*/

		if(msg.findExtension(kExtUser_msg_filter_quitgroups))
		{
			boost::shared_ptr<gloox::Tag> tag(msg.findExtension(kExtUser_msg_filter_quitgroups)->tag());
			if (tag)
			{
				json::jobject item,jobj;
				gloox::Tag* tchild(tag->findChild("item"));
				jobj["session_id"]=msg.from().bare();
				jobj["type"]="remove";
				item["jid"]=tchild->findAttribute("jid");
				item["showname"]=tchild->findAttribute("name");
				item["nike_name"]=tchild->findAttribute("nike_name");
				item["photo_credential"]=tchild->findAttribute("icon");
				item["sex"]=tchild->findAttribute("sex");
				item["identity"]=tchild->findAttribute("identity");
				item["role"]=tchild->findAttribute("role");
				jobj["member_info"]=item;
				jobj["server_time"]=server_time;
				if (msg.subtype() == gloox::Message::MessageType::Headline) // 普通成员收到用于更新成员列表的
				{
					// 其他成员通知成员减少
					gWrapInterface::instance().groups_member_list_change(jobj);//
				}
				else{ //管理员收到，离线也可以收到，用于系统消息提醒

					gWrapInterface::instance().groups_member_quit(jobj);
					gWrapInterface::instance().groups_member_list_change(jobj);//
				}
			}		
			return;
		}
		/*
		　　<message from=’112@groups.ruijie.com.cn’ to=’123456@ruijie.com.cn’>
　　 	<query xmlns=’groups: member:apply:accept‘>
　　		<item jid=”123456@ruijie.com.cn” name=”张三” nick_name=”天天甜甜” sex=”boy” icon=”icon_url’ msg=’我想加入’ />
　　	</query>
</ massage >
		*/
		if(msg.findExtension(kExtUser_msg_filter_applyjoingroups))
		{
			boost::shared_ptr<gloox::Tag> tag(msg.findExtension(kExtUser_msg_filter_applyjoingroups)->tag());
			if (tag)
			{
				
				gloox::Tag* tchild(tag->findChild("actor"));
				if (tag->findAttribute("type")=="accept")
				{
					if (msg.to().bare() == tchild->findAttribute("jid")) //申请人是自己
					{
						json::jobject groups,jobj;
						//通知申请入群成功 更新群列表
						jobj["session_id"]=msg.from().bare();
						jobj["type"]="no_auth_accept";
						tchild=tag->findChild("item");
						groups["name"] = tchild->findAttribute( "name" );
						groups["icon"]  = tchild->findAttribute( "icon" );
						groups["category"] = tchild->findAttribute( "category" );
						jobj["crowd_info"]=groups;
						jobj["server_time"]=server_time;
						gWrapInterface::instance().groups_list_change(jobj);
					}else
					{
						 if (msg.subtype() == gloox::Message::MessageType::Headline) 
						 {
							 json::jobject actor,jobj;

							 //群内其他成员
							 jobj["session_id"]=msg.from().bare();
							 jobj["type"]="add";
							 actor["jid"]=tchild->findAttribute("jid");
							 actor["showname"]=tchild->findAttribute("name");
							 actor["photo_credential"]=tchild->findAttribute("icon");
							 actor["sex"]=tchild->findAttribute("sex");
							 actor["identity"]=tchild->findAttribute("identity");
							 actor["role"]="none";
							 jobj["member_info"]=actor;
							 jobj["server_time"]=server_time;
							 gWrapInterface::instance().groups_member_list_change(jobj);
						 }
						 else
						 {
							 json::jobject actor , item , jobj;
							 jobj["session_id"]=msg.from().bare();
							 jobj["type"]="add";
							 actor["jid"]=tchild->findAttribute("jid");
							 actor["showname"]=tchild->findAttribute("name");
							 actor["photo_credential"]=tchild->findAttribute("icon");
							 actor["sex"]=tchild->findAttribute("sex");
							 actor["identity"]=tchild->findAttribute("identity");
							 actor["role"]="none";
							 jobj["member_info"]=actor;
							 jobj["server_time"]=server_time;
							 gWrapInterface::instance().groups_member_list_change(jobj.clone());

							//通知管理员有人加入了群
							 tchild=tag->findChild("item");
							 item["name"]=tchild->findAttribute("name");
							 item["icon"]=tchild->findAttribute("icon");
							 item["category"]=tchild->findAttribute("category");
							 jobj["crowd_info"]=item;
							 gWrapInterface::instance().apply_join_groups_accepted(jobj);
						 }
					}
				}
				else{//通知管理员有人申请加入
					json::jobject actor , item , jobj;
					jobj["session_id"]=msg.from().bare();
					jobj["type"]="add";
					actor["jid"]=tchild->findAttribute("jid");
					actor["showname"]=tchild->findAttribute("name");
					actor["photo_credential"]=tchild->findAttribute("icon");
					actor["sex"]=tchild->findAttribute("sex");
					actor["identity"]=tchild->findAttribute("identity");
					actor["role"]="none";

					tchild=tag->findChild("html");//理由
					if (tchild)
					{
						actor["html"] = tchild->cdata();
					}
					jobj["member_info"]=actor;

					tchild=tag->findChild("item");
					item["name"]=tchild->findAttribute("name");
					item["icon"]=tchild->findAttribute("icon");
					item["category"]=tchild->findAttribute("category");
					jobj["crowd_info"]=item;
					jobj["server_time"]=server_time;

					gWrapInterface::instance().apply_join_groups_wait(jobj);
				}
			}
			return;
		}	
	
		
		if(msg.findExtension(kExtUser_msg_filter_groupsmemberkickout))
		{
			boost::shared_ptr<gloox::Tag> tag(msg.findExtension(kExtUser_msg_filter_groupsmemberkickout)->tag());
			if (tag)
			{
				json::jobject item,actor,groups;
				gloox::Tag* tchild(tag->findChild("actor"));
				actor["jid"]=tchild->findAttribute("jid");
				actor["showname"]=tchild->findAttribute("name");
				
				tchild=tag->findChild("item");
				item["jid"]=tchild->findAttribute("jid");
				item["showname"]=tchild->findAttribute("name");
				
				tchild=tag->findChild("groups");
				groups["session_id"]=msg.from().bare();
				groups["name"]=tchild->findAttribute("name");
				groups["icon"]=tchild->findAttribute("icon");
				groups["category"]=tchild->findAttribute("category");

				json::jobject jobj;
				jobj["session_id"] = msg.from().bare();
				jobj["member_info"]=item;
				jobj["type"]="remove";
				jobj["server_time"]=server_time;

				gWrapInterface::instance().groups_member_list_change(jobj);// 所有成员收到用于更新成员列表的

				if (msg.subtype() != gloox::Message::MessageType::Headline) 
				{
					if (msg.to().bare() == item["jid"].get<std::string>())//被提出人收到的通知
					{
						json::jobject jobj;
						jobj["session_id"] = msg.from().bare();
						jobj["actor"]=actor;
						jobj["crowd_info"]=groups;
						jobj["type"]="kickout";
						jobj["server_time"]=server_time;

						gWrapInterface::instance().groups_list_change(jobj);
					}
					else if(msg.to().bare() == actor["jid"].get<std::string>())//移出成员的管理员收到的通知
					{
						json::jobject jobj;
						jobj["session_id"] = msg.from().bare();
						jobj["member_info"]=item;
						jobj["crowd_info"]=groups;
						jobj["type"]="kickout";
						jobj["server_time"]=server_time;
						gWrapInterface::instance().recv_groups_member_kickout_admin_self(jobj);
					}
					else //其他管理员收到的通知
					{
						json::jobject jobj;
						jobj["session_id"] = msg.from().bare();
						jobj["actor"]=actor;
						jobj["member_info"]=item;
						jobj["crowd_info"]=groups;
						jobj["type"]="kickout";
						jobj["server_time"]=server_time;
						gWrapInterface::instance().recv_groups_member_kickout_admin_other(jobj);
					}
				}
				
			}
			return;
		}
	
		if(msg.findExtension(kExtUser_msg_filter_groupsmemberapplyaccept))
		{
			boost::shared_ptr<gloox::Tag> tag(msg.findExtension(kExtUser_msg_filter_groupsmemberapplyaccept)->tag());
			if (tag)
			{
				json::jobject actor,crowd,item;
				gloox::Tag* tchild(tag->findChild("item"));//申请人
				actor["jid"]=tchild->findAttribute("jid");
				actor["showname"]=tchild->findAttribute("name");
				actor["photo_credential"]=tchild->findAttribute("icon");
				actor["sex"]=tchild->findAttribute("sex");
				actor["identity"]=tchild->findAttribute("identity");

				tchild=tag->findChild("actor");
				item["jid"]=tchild->findAttribute("jid");//管理员
				item["showname"]=tchild->findAttribute("name");
				item["photo_credential"]=tchild->findAttribute("icon");
				item["sex"]=tchild->findAttribute("sex");
				item["identity"]=tchild->findAttribute("identity");

				tchild=tag->findChild("groups");//群相关信息
				crowd["name"]=tchild->findAttribute("name");
				crowd["icon"]=tchild->findAttribute("icon");
				crowd["quit"]=tchild->findAttribute("quit");
				crowd["status"]=tchild->findAttribute("status");
				crowd["official"]=tchild->findAttribute("v");
				crowd["active"]=tchild->findAttribute("active");
				crowd["category"]=tchild->findAttribute("category");
				crowd["dismiss"]=tchild->findAttribute("dismiss");

				if (msg.subtype() == gloox::Message::MessageType::Headline) // 普通成员收到用于更新成员列表的
				{
					json::jobject jobj;
					jobj["session_id"] = msg.from().bare();
					jobj["member_info"]=actor;
					jobj["type"]="add";
					jobj["server_time"]=server_time;
					gWrapInterface::instance().groups_member_list_change(jobj);
				}
				else{ 
					json::jobject jobj;
					if (msg.to().bare() == actor["jid"].get<std::string>())
					{
						jobj["session_id"] = msg.from().bare();
						jobj["crowd_info"]=crowd;
						jobj["member_info"]=item;
						jobj["type"]="accept";
						jobj["server_time"]=server_time;
						gWrapInterface::instance().groups_list_change(jobj.clone());
					}
					else{
						jobj["session_id"] = msg.from().bare();
						jobj["member_info"]=actor;
						jobj["type"]="add";
						jobj["server_time"]=server_time;
						gWrapInterface::instance().groups_member_list_change(jobj.clone());

						jobj["crowd_info"]=crowd;
						jobj["member_info"]=actor;
						jobj["actor"]=item;
						jobj["type"]="accept";
						tchild=tag->findChild("html");//理由
						if (tchild)
						{
							jobj["reason"]=tchild->cdata();
						}
						gWrapInterface::instance().recv_groups_member_apply_accept(jobj);
						
					}
				}
			}
			return;
		}

		if(msg.findExtension(kExtUser_msg_filter_groupsmemberapplydeny))
		{
			boost::shared_ptr<gloox::Tag> tag(msg.findExtension(kExtUser_msg_filter_groupsmemberapplydeny)->tag());
			if (tag)
			{
				json::jobject actor,crowd,item,jobj;
				gloox::Tag* tchild(tag->findChild("actor"));//管理员
				item["jid"]=tchild->findAttribute("jid");
				item["showname"]=tchild->findAttribute("name");
				item["photo_credential"]=tchild->findAttribute("icon");
				item["sex"]=tchild->findAttribute("sex");
				item["identity"]=tchild->findAttribute("identity");

				tchild=tag->findChild("groups");//群相关信息
				crowd["name"]=tchild->findAttribute("name");
				crowd["icon"]=tchild->findAttribute("icon");
				crowd["category"]=tchild->findAttribute("category");
				
				tchild=tag->findChild("html");//理由
				if (tchild)
				{
					jobj["reason"]=tchild->cdata();
				}
				jobj["session_id"] = msg.from().bare();
				jobj["crowd_info"]=crowd;
				jobj["member_info"]=item;
				jobj["type"]="deny";
				jobj["server_time"]=server_time;
				gWrapInterface::instance().recv_apply_join_crowd_response(jobj);//管理员审批完申请后通知被申请人

			}
			return;
		}

		if(msg.findExtension(kExtUser_msg_filter_groupsrolechange))
		{
			boost::shared_ptr<gloox::Tag> tag(msg.findExtension(kExtUser_msg_filter_groupsrolechange)->tag());
			if (tag)
			{
				
				json::jobject item,jobj;
				gloox::Tag* tchild(tag->findChild("item"));
				jobj["session_id"] = msg.from().bare();
				item["jid"]=tchild->findAttribute("jid");
				item["role"]=tchild->findAttribute("role");
				jobj["member_info"]=item;
				jobj["type"]="modify";
				jobj["server_time"]=server_time;
				gWrapInterface::instance().groups_member_list_change(jobj.clone());//所有人打开群窗口的人收到，用已更新列表

				if (msg.subtype() != gloox::Message::MessageType::Headline) 
				{ 
					json::jobject actor;
					gloox::Tag* tchild(tag->findChild("actor"));
					actor["showname"]=tchild->findAttribute("name");
					actor["jid"]=tchild->findAttribute("jid");
					jobj["actor"]=actor;
					gWrapInterface::instance().groups_role_changed(jobj);//被改变角色的成员收到
				}

			}
			return;
		}
		if(msg.findExtension(kExtUser_msg_filter_groupsroleapply))
		{
			boost::shared_ptr<gloox::Tag> tag(msg.findExtension(kExtUser_msg_filter_groupsroleapply)->tag());
			if (tag)
			{
				json::jobject jobj;
				jobj["session_id"]=msg.from().bare();
				jobj["server_time"]=server_time;
				if (!tag->hasChild("item"))
				{
					gWrapInterface::instance().groups_role_applyed(jobj.clone());
				}
			}
			return;
		}

		if(msg.findExtension(kExtUser_msg_filter_groupsroleapplyreply))
		{
			boost::shared_ptr<gloox::Tag> tag(msg.findExtension(kExtUser_msg_filter_groupsroleapplyreply)->tag());
			if (tag)
			{
				json::jobject jobj;

				jobj["server_time"]=server_time;
				jobj["session_id"]=msg.from().bare();
				if (tag->hasChild("item"))
				{
					gloox::Tag* tchild(tag->findChild("item"));
					json::jobject item;

					jobj["accept"]=tchild->findAttribute("accept");
					jobj["jid"]=tchild->findAttribute("jid");
					gWrapInterface::instance().crowd_superadmin_applyed_response(jobj.clone());//通知所有成员超级管理员的申请已经被审批

					if (tchild->findAttribute("accept")=="true")
					{
						item["role"]=tchild->findAttribute("role");
						item["jid"]=tchild->findAttribute("jid");
						jobj["member_info"]=item;
						jobj["type"]="modify";
						gWrapInterface::instance().groups_member_list_change(jobj);
					}
					if (msg.subtype() != gloox::Message::MessageType::Headline) 
					{
						gWrapInterface::instance().groups_role_applyed_self(jobj);//被改变角色的成员收到
					}
				}
			}
			return;
		}
		

		if(msg.findExtension(kExtUser_msg_filter_groupsroledemise))
		{
			boost::shared_ptr<gloox::Tag> tag(msg.findExtension(kExtUser_msg_filter_groupsroledemise)->tag());
			if (tag)
			{
				json::jobject item,jobj,actor,crowd;
				gloox::Tag* tchild(tag->findChild("actor"));
				actor["jid"]=tchild->findAttribute("jid");
				jobj["session_id"] = msg.from().bare();
				jobj["server_time"]=server_time;
				
				actor["role"]="none";
				jobj["member_info"]=actor;
				jobj["type"]="modify";
				gWrapInterface::instance().groups_member_list_change(jobj.clone());//被转让者之外的人收到，更改原超级管理员为普通成员

				tchild=tag->findChild("item");
				item["jid"]=tchild->findAttribute("jid");
				item["role"]="super";
				jobj["member_info"]=item;
				jobj["type"]="modify";
				gWrapInterface::instance().groups_member_list_change(jobj);//被转让者之外的人收到，被转让者更改为超级管理员
				if(msg.subtype() != gloox::Message::MessageType::Headline)
				{
				json::jobject jobj;
				jobj["server_time"]=server_time;
				actor["showname"]=tchild->findAttribute("name");
				jobj["session_id"] = msg.from().bare();
				jobj["actor"]=actor;
				gWrapInterface::instance().groups_role_demised(jobj);//被改变角色的成员收到
				}
			}
			return;
		}	
	
		if(msg.findExtension(kExtUser_msg_filter_inviteintogroups))
		{
			boost::shared_ptr<gloox::Tag> tag(msg.findExtension(kExtUser_msg_filter_inviteintogroups)->tag());
			if (tag)
			{
				json::jobject item,jobj,actor,crowd;
				gloox::Tag* tchild(tag->findChild("actor"));
				
				jobj["server_time"]=server_time;
				jobj["session_id"] = msg.from().bare();
				
				actor["jid"]=tchild->findAttribute("jid");
				actor["showname"]=tchild->findAttribute("name");
				jobj["actor"]=actor;

				tchild=tag->findChild("groups");
				crowd["name"]=tchild->findAttribute("name");
				crowd["icon"]=tchild->findAttribute("icon");
				crowd["category"]=tchild->findAttribute("category");
				jobj["crowd_info"]=crowd;
				gWrapInterface::instance().invited_into_gropus(jobj);//被改变角色的成员收到

			}
			return;
		}

		if(msg.findExtension(kExtUser_msg_filter_answergroupsinviteaccept))
		{
			boost::shared_ptr<gloox::Tag> tag(msg.findExtension(kExtUser_msg_filter_answergroupsinviteaccept)->tag());
			if (tag)
			{
				json::jobject item,actor,crowd;
				gloox::Tag* tchild(tag->findChild("actor")); // 管理员
				actor["jid"]=tchild->findAttribute("jid");
				actor["showname"]=tchild->findAttribute("name");

				tchild=tag->findChild("item");
				item["jid"]=tchild->findAttribute("jid");
				item["showname"]=tchild->findAttribute("name"); //被邀请人
				item["photo_credential"]=tchild->findAttribute("icon");
				item["sex"]=tchild->findAttribute("sex");
				item["identity"]=tchild->findAttribute("identity");

				tchild=tag->findChild("groups");
				crowd["name"]=tchild->findAttribute("name");
				crowd["icon"]=tchild->findAttribute("icon");
				crowd["category"]=tchild->findAttribute("category");

				if (msg.subtype() == gloox::Message::MessageType::Headline) // 普通成员收到用于更新群成员列表的
				{
					json::jobject jobj;
					jobj["session_id"] = msg.from().bare();
					jobj["member_info"]=item;
					jobj["type"]="add";
					jobj["server_time"]=server_time;
					gWrapInterface::instance().groups_member_list_change(jobj);
				}
				else{ 
					json::jobject jobj;
					if (msg.to().bare() == item["jid"].get<std::string>())
					{
						jobj["session_id"] = msg.from().bare();
						jobj["crowd_info"] = crowd;
						jobj["type"]="invite";
						jobj["server_time"]=server_time;
						gWrapInterface::instance().groups_list_change(jobj);//被邀请人收到，更新群列表
					}
					else
					{
						json::jobject jobj;
						jobj["session_id"] = msg.from().bare();
						jobj["member_info"]=item;
						jobj["type"]="add";
						jobj["server_time"]=server_time;
						gWrapInterface::instance().groups_member_list_change(jobj.clone());//管理员收到用于更新群成员列表

						jobj["crowd_info"]=crowd;
						jobj["actor"] = actor;
						jobj["type"]="accept";
						gWrapInterface::instance().recv_answer_groups_invite(jobj);//管理员收到用于通知管理员有人接受邀请
					}
				}
			}
			return;
		}

		if(msg.findExtension(kExtUser_msg_filter_answergroupsinvitedeny))
		{
			boost::shared_ptr<gloox::Tag> tag(msg.findExtension(kExtUser_msg_filter_answergroupsinvitedeny)->tag());
			if (tag)
			{
				json::jobject item,actor,crowd;
				gloox::Tag* tchild(tag->findChild("actor")); // 管理员
				actor["jid"]=tchild->findAttribute("jid");
				actor["showname"]=tchild->findAttribute("name");

				tchild=tag->findChild("item");
				item["jid"]=tchild->findAttribute("jid");
				item["showname"]=tchild->findAttribute("name"); //被邀请人
				
				tchild=tag->findChild("groups");
				crowd["name"]=tchild->findAttribute("name");
				crowd["icon"]=tchild->findAttribute("icon");
				crowd["category"]=tchild->findAttribute("category");

				std::string reason;
				tchild=tag->findChild("html");
				if (tchild)
				{
					reason = tchild->cdata();
				}

				json::jobject jobj;
				jobj["session_id"] = msg.from().bare();
				jobj["crowd_info"] = crowd;
				jobj["member_info"] = item;
				jobj["actor"] = actor;
				jobj["type"]="deny";
				jobj["reason"]=reason;
				jobj["server_time"]=server_time;
				gWrapInterface::instance().recv_answer_groups_invite(jobj);//管理员收到用于通知管理员有人拒绝邀请

			}
			return;
		}
		if(msg.findExtension(kExtUser_msg_filter_groupsmemberset))
		{
			boost::shared_ptr<gloox::Tag> tag(msg.findExtension(kExtUser_msg_filter_groupsmemberset)->tag());
			if (tag)
			{
				json::jobject item,actor,crowd;
				if (msg.subtype() != gloox::Message::MessageType::Headline) 
				{
					gloox::Tag* tchild(tag->findChild("member")); 
					if (msg.to().bare() == tchild->findAttribute("jid")) //被操作者
					{
						json::jobject groups,jobj,member;
						//通知申请入群成功 更新群列表
						member["showname"]=tchild->findAttribute("name");
						member["icon"]=tchild->findAttribute("icon");
						member["sex"]=tchild->findAttribute("sex");
						member["identity"]=tchild->findAttribute("identity");
						member["role"]=tchild->findAttribute("role");
						jobj["member_info"]=member;
						jobj["session_id"]=msg.from().bare();
						jobj["type"]=tchild->findAttribute( "type" );
						if (tchild->findAttribute( "type" )=="update")
						{
							json::jobject jobj,member;
							member["role"]=tchild->findAttribute("role");
							member["jid"]=tchild->findAttribute("jid");
							jobj["member_info"]=member;
							jobj["session_id"]=msg.from().bare();
							jobj["type"]="modify";
							jobj["server_time"]=server_time;
							gWrapInterface::instance().groups_member_list_change(jobj);
						}
						tchild=tag->findChild("item");
						groups["name"] = tchild->findAttribute( "name" );
						groups["icon"]  = tchild->findAttribute( "icon" );
						groups["category"] = tchild->findAttribute( "category" );
						jobj["crowd_info"]=groups;

						jobj["server_time"]=server_time;
						gWrapInterface::instance().recv_groups_member_web_change_self(jobj);
					}
				}
				else//群内其他成员,更新群列表
				{
					json::jobject actor,jobj;
					jobj["session_id"]=msg.from().bare();
					jobj["type"]="refresh";
					jobj["server_time"]=server_time;
					gWrapInterface::instance().groups_member_list_change(jobj);
				}
			}
			return;
		}
		
	}
	

	
}



