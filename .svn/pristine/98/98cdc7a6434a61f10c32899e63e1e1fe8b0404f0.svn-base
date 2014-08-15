#ifndef UserStanzaExtensionType_H__
#define UserStanzaExtensionType_H__
#pragma once
#include "../gloox_src/stanzaextension.h"

namespace gloox{
	enum UserStanzaExtensionType 
	{
		kExtUser_iq_filter_privilege = ExtUser+500, //群讨论组
		KExtUser_iq_filter_prelogin,				//预登录
		kExtUser_iq_filter_getdiscussionslist,		//取讨论组列表
		kExtUser_iq_filter_creatediscussions,		//创建讨论组
		kExtUser_iq_filter_changediscussionsname,	//讨论组改名
		kExtUser_iq_filter_getdiscussionsmemberlist,//取讨论组成员
		kExtUser_iq_filter_closediscussions,		//关闭讨论组窗口
		kExtUser_iq_filter_opendiscussions,			//打开讨论组窗口
		kExtUser_iq_filter_quitdiscussions,			//退出讨论组
		kExtUser_iq_filter_invitediscussions,		//邀请人到讨论组
		kExtUser_msg_filter_discussionslistchange,	//讨论组列表变更
		kExtUser_msg_filter_discussionsmemberchange,//讨论组成员变更
		kExtUser_msg_filter_messageid,				//讨论组会话id，用于祛重
		kExtUser_iq_filter_temporary_attention,		//临时订阅presence
		kExtUser_iq_filter_organization_search,		//组织结构树搜索
		kExtUser_iq_filter_send_file_msg,			//发送文件传输msg
		kExtUser_iq_filter_cancel_send_file_msg,	//取消发送文件传输msg
		kExtUser_msg_filter_filedak_message,		//文件传输消息
		kExtUser_iq_filter_add_a_stranger,			//增加一个陌生人
		kExtUser_iq_filter_remove_a_stranger,			//删除一个陌生人
		kExtUser_iq_filter_get_stranger_list,			//获取陌生人列表
		kExtUser_iq_filter_get_token,					//获取会话token
		kExtUser_msg_filter_appmessage,					//收到第三方消息
		kExtUser_iq_filter_sdkmessage_ack,					//第三方消息确认
		kExtUser_presence_filter_threadid,				//自定义presence扩展
		kExtUser_iq_filter_find_friend,             //好友查找
		kExtUser_msg_filter_creategroups	,				//创建群
		kExtUser_iq_filter_groupsprecreate,				//判断能否创建群
		kExtUser_iq_filter_creategroups	,				//创建群
		kExtUser_msg_filter_dismissgroups,					//解散群
		kExtUser_iq_filter_dismissgroups,					//解散群
		kExtUser_iq_filter_applyjoingroups,					//申请加入群 iq
		kExtUser_msg_filter_applyjoingroups,					//同意申请加入群 
		kExtUser_iq_filter_getgroupslist,			//获取群列表 iq
		kExtUser_iq_filter_getgroupsmemberlist,  //获取群成员列表 iq
		kExtUser_iq_filter_getgroupsadminlist,  //获取管理员列表 iq
		kExtUser_iq_filter_getgroupsinfo,				//获取群信息 iq
		kExtUser_msg_filter_changegroupsinfo,			//更改群信息 
		kExtUser_iq_filter_changegroupsinfo,			//更改群信息 
		kExtUser_iq_filter_entergroups,					//进入群	
		kExtUser_iq_filter_leavegroups,					//离开群	
		kExtUser_msg_filter_quitgroups,					//退出群
		kExtUser_iq_filter_quitgroups,					 //退出群
		kExtUser_msg_filter_groupskickoutmember,   //群主踢出成员
		kExtUser_iq_filter_groupskickoutmember,    //群主踢出成员
		kExtUser_msg_filter_changegroupsmemberinfo,	//修改群成员屏蔽消息
		kExtUser_iq_filter_changegroupsmemberinfo,	//修改群成员屏蔽消息
		kExtUser_iq_filter_getgroupssharelist	,		 //获取群共享列表 iq
		kExtUser_msg_filter_uploadfilegroupsshare,	 //上传共享文件
		kExtUser_iq_filter_uploadfilegroupsshare,  	//上传共享文件
		kExtUser_iq_filter_downloadfilegroupsshare,    //下载群共享
		kExtUser_iq_filter_deletefilegroupsshare,	//删除共享文件		
		kExtUser_iq_filter_setgroupsshareinfo,	//变更文件为永久文件	
		kExtUser_iq_filter_getgroupsrecentmessages,	//变更文件为永久文件	
		kExtUser_iq_filter_move_to_privacy_list,//移动某人到黑名单	
		kExtUser_iq_filter_findgroups,					 //群查找 iq
		kExtUser_msg_filter_groupsmemberkickout,  //管理员踢成员
		kExtUser_iq_filter_groupsadminmanagemember,  //管理员踢成员
		kExtUser_msg_filter_groupsmemberapplyaccept,     //管理员员通过申请加入审批通知审批人员
		kExtUser_msg_filter_groupsmemberapplydeny,        //管理员拒绝申请
		kExtUser_iq_filter_groupsroleapply,			 //申请成为管理员	groups:role:apply
		kExtUser_msg_filter_groupsroleapply,        //通知其他成员已经有人申请管理员了
		kExtUser_msg_filter_groupsroleapplyreply, //管理员申请已审批，通知管理员和其他成员
		kExtUser_iq_filter_groupsrolechange,		//超级管理员改变其他成员身份
		kExtUser_iq_filter_groupsroledemise,			 //管理员转让自己身份
		kExtUser_msg_filter_groupsrolechange,        //群成员角色被改变的消息groups:role:demise
		kExtUser_msg_filter_groupsroledemise ,       //群成员角色被改变的消息
		kExtUser_iq_filter_inviteintogroups,				//邀请其他成员加入群
		kExtUser_msg_filter_inviteintogroups,			//被邀请人收到的通知
		kExtUser_iq_filter_answergroupsinvite,				//应答加入群的邀请
		kExtUser_msg_filter_answergroupsinviteaccept,				//被邀请者同意加入群的邀请
		kExtUser_msg_filter_answergroupsinvitedeny,				//被邀请者拒绝加入群的邀请
		kExtUser_msg_filter_groupsmemberset,					//管理端更改群成员信息增、删、改角色
		kExtUser_iq_filter_setgroupsmemberinfo,				//更该群成员信息
		kExtUser_msg_filter_messagebody,				//讨论组会话id，用于祛重
		kExtUser_iq_filter_organization_show,				//查看是否有组织结构树显示权限
		kExtUser_iq_filter_recv_msg_report,					//消息已接受报告
		kExtUser_iq_filter_can_recv_lightapp_msg,			//可以接收lightapp msg
		kExtUser_msg_filter_growthlevelinfo					//微哨等级升级消息
	};

}; // namespace gloox

#endif