#pragma once
#include <string>
namespace biz {

namespace biz_sql
{
	// 根数据库(common.dat)：表：Accounts
	static const std::wstring s_sqlInsertAccounts			=		L"replace into accounts values(?,?,?,?,?,?,?,?,?)";
	static const std::wstring s_sqlUpdateAccountByName	=		L"update accounts set last_login_time = ?, password = ?, presence = ?, auto_login = ?, save_password = ?, user_id = ? where sam_id = ?";
	static const std::wstring s_sqlDeleteAccountsOnSamID	=		L"delete from accounts where sam_id=?";
	static const std::wstring s_sqlSelectUserFromAccountsByName =	L"select * from accounts where sam_id=?";
	static const std::wstring s_sqlUpdateUserAccountByName	=		L"update accounts set last_login_time = ?, password = ?, presence = ?, auto_login = ?, save_password = ? where sam_id = ?";
	static const std::wstring s_sqlSelectAccounts			=		L"select * from accounts order by last_login_time desc";
	static const std::wstring s_sqlUpdateHeadForAccounts    =		L"update accounts set avatar_file = ? where user_id= ?";

	// 用户数据库(user.dat)：表：roster
	extern const std::wstring s_sqlReplaceRoster; // replace
	extern const std::wstring s_sqlSelectRoster; // select

	// 用户数据库(user.dat)：表：RecentContact
	extern const std::wstring s_sqlDeleteRecentContact;   // delete
	extern const std::wstring s_sqlDeleteRecentContactByJID;   // delete
#ifndef _WIN32
	extern const std::wstring s_sqlDeleteSystemRecentContact;   // delete
#endif
	extern const std::wstring s_sqlReplaceRecentContact; // insert
	extern const std::wstring s_sqlSelectRecentContact; // select
	// 用户数据库(user.dat)：表：RequestFriends
	extern const std::wstring s_sqlSelectOneRequest;

	// 数据缓存数据库(setting.dat)：表：special
	extern const std::wstring s_sqlReplaceSpecial; // insert
	extern const std::wstring s_sqlSelectSpecial; // select
	extern const std::wstring s_sqlDeleteSpecial; // select
	// 历史记录数据库(history.dat)：
	// 表：（收发）conversation 个人聊天记录
	// 表：（收发）crowd群消息历史记录
	// 表：（收发）group讨论组历史记录
	// 表：（收）  notice接收通知历史记录
	extern const std::wstring s_tablename_message;
	extern const std::wstring s_tablename_crowd;
	extern const std::wstring s_tablename_group;
	extern const std::wstring s_tablename_notice;
	extern const std::wstring s_tablename_lightapp;

 	extern const std::wstring s_sqlDeleteMessage;   // delete
	extern const std::wstring s_sqlInsertMessage; // insert
	extern const std::wstring s_sqlInsertGroupMessage;
	extern const std::wstring s_sqlInsert_NoticeMessage; // insert
	extern const std::wstring s_sqlSelectMessage; // select
	extern const std::wstring s_sqlSelectGroupMessage; // select
	extern const std::wstring s_sqlUnRead; // select desc
	extern const std::wstring s_sqlSelectMessageCount; // select count(*)
	extern const std::wstring s_sqlMarkMessageRead; // mark message read
	extern const std::wstring s_sqlInsertCrowdMessage;
	extern const std::wstring s_sqlLastCrowd;
	extern const std::wstring s_sqlSelectCrowdMessage;

	extern const std::wstring s_sqlSelectCountPublish; // select count publish.
	extern const std::wstring s_sqlSelectPublish; // select publish.
	extern const std::wstring s_sqlInsertPublish; // insert into publish.

	//取最后会话时间 在消息管理器里显示
	extern const std::wstring s_sqlLastConversation;
	extern const std::wstring s_sqlLastGroup;

}; // biz_sql

}; // biz