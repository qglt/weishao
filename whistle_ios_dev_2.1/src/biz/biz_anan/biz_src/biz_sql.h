#pragma once
#include <string>
namespace biz {

namespace biz_sql
{
	// �����ݿ�(common.dat)����Accounts
	static const std::wstring s_sqlInsertAccounts			=		L"replace into accounts values(?,?,?,?,?,?,?,?,?)";
	static const std::wstring s_sqlUpdateAccountByName	=		L"update accounts set last_login_time = ?, password = ?, presence = ?, auto_login = ?, save_password = ?, user_id = ? where sam_id = ?";
	static const std::wstring s_sqlDeleteAccountsOnSamID	=		L"delete from accounts where sam_id=?";
	static const std::wstring s_sqlSelectUserFromAccountsByName =	L"select * from accounts where sam_id=?";
	static const std::wstring s_sqlUpdateUserAccountByName	=		L"update accounts set last_login_time = ?, password = ?, presence = ?, auto_login = ?, save_password = ? where sam_id = ?";
	static const std::wstring s_sqlSelectAccounts			=		L"select * from accounts order by last_login_time desc";
	static const std::wstring s_sqlUpdateHeadForAccounts    =		L"update accounts set avatar_file = ? where user_id= ?";

	// �û����ݿ�(user.dat)����roster
	extern const std::wstring s_sqlReplaceRoster; // replace
	extern const std::wstring s_sqlSelectRoster; // select

	// �û����ݿ�(user.dat)����RecentContact
	extern const std::wstring s_sqlDeleteRecentContact;   // delete
	extern const std::wstring s_sqlDeleteRecentContactByJID;   // delete
#ifndef _WIN32
	extern const std::wstring s_sqlDeleteSystemRecentContact;   // delete
#endif
	extern const std::wstring s_sqlReplaceRecentContact; // insert
	extern const std::wstring s_sqlSelectRecentContact; // select
	// �û����ݿ�(user.dat)����RequestFriends
	extern const std::wstring s_sqlSelectOneRequest;

	// ���ݻ������ݿ�(setting.dat)����special
	extern const std::wstring s_sqlReplaceSpecial; // insert
	extern const std::wstring s_sqlSelectSpecial; // select
	extern const std::wstring s_sqlDeleteSpecial; // select
	// ��ʷ��¼���ݿ�(history.dat)��
	// �����շ���conversation ���������¼
	// �����շ���crowdȺ��Ϣ��ʷ��¼
	// �����շ���group��������ʷ��¼
	// �����գ�  notice����֪ͨ��ʷ��¼
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

	//ȡ���Ựʱ�� ����Ϣ����������ʾ
	extern const std::wstring s_sqlLastConversation;
	extern const std::wstring s_sqlLastGroup;

}; // biz_sql

}; // biz