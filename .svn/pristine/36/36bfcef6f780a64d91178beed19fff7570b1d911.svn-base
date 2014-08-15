#include "biz_sql.h"

namespace biz {
	namespace biz_sql {
		const std::wstring s_sqlLastConversation = L"select jid, max(dt) from conversation group by jid;";
		const std::wstring s_sqlLastGroup= L"select jid, groupname, max(dt) from groupmsg group by jid;";
		const std::wstring s_sqlLastCrowd= L"select jid, crowdname, max(dt) from crowdmsg group by jid;";

		// history.dat Êý¾Ý¿â£º
		const std::wstring s_tablename_message = L"conversation";
		const std::wstring s_tablename_crowd = L"crowdmsg";
		const std::wstring s_tablename_group = L"groupmsg";
		const std::wstring s_tablename_notice = L"notice";
		const std::wstring s_tablename_lightapp = L"lightapp";
	
		const std::wstring s_sqlDeleteMessage = // delete
			L"delete from %s ";

		const std::wstring s_sqlInsertMessage = // insert
			L"insert into %s (jid,subid,is_read,is_send,showname,msg,dt) values (?,?,?,?,?,?,?);";
		const std::wstring s_sqlInsertGroupMessage = // insert chat group
			L"insert into groupmsg (jid,subid,is_read,is_send,showname,msg,dt,groupname,id) values (?,?,?,?,?,?,?,?,?);";
		const std::wstring s_sqlInsertCrowdMessage = // insert chat crowd
			L"insert into crowdmsg (jid,subid,is_read,is_send,showname,msg,dt,crowdname,id) values (?,?,?,?,?,?,?,?,?);";

		const std::wstring s_sqlInsert_NoticeMessage = // insert
			L"insert into notice values (?,?,?,?,?,?,?,?);";
		const std::wstring s_sqlSelectMessage = // select 
			L"select rowid,jid,is_send,msg,dt, subid,showname,is_read from %s " \
			L"where ";
		const std::wstring s_sqlSelectGroupMessage = // select 
			L"select rowid,jid,is_send,msg,dt, subid,showname,is_read, groupname from groupmsg " \
			L"where ";
		const std::wstring s_sqlSelectCrowdMessage = // select 
			L"select rowid,jid,is_send,msg,dt, subid,showname,is_read, crowdname from crowdmsg " \
			L"where ";
		
		const std::wstring s_sqlUnRead = 
			L"select jid,subid,showname,msg,dt , count(*) from %s where is_send=0 and is_read=0 group by jid ";

		const std::wstring s_sqlSelectMessageCount = // select count(*)
			L"select count(*) from %s where ";

		const std::wstring s_sqlMarkMessageRead = // mark message read
			L"update %s set is_read=1 " \
			L"where ";

		const std::wstring s_sqlInsertPublish = // insert into publish.
			L"insert into publish (id,title,signature,priority,identity,html,expired_time,body,address,dt) "\
			L" values (?,?,?,?,?,?,?,?,?,?);";

		const std::wstring s_sqlSelectCountPublish = // select count publish.
			L"select count(id) from publish;";

		const std::wstring s_sqlSelectPublish = // select publish.
			L"select id,title,signature,priority,identity,html,expired_time,body,address,dt from publish ";
		
		const std::wstring s_sqlReplaceSpecial = // insert
			L"replace into special (id,data) values (?,?);";

		const std::wstring s_sqlDeleteSpecial = // delete
			L"delete from special where id=?;";

		const std::wstring s_sqlSelectSpecial = // select
			L"select id,data from special where id = (?);";


		const std::wstring s_sqlDeleteRecentContact =   // delete
			L"delete from recentcontact;";

#ifdef _WIN32
		const std::wstring s_sqlDeleteRecentContactByJID = L"delete from recentcontact where jid=?;";
#else
		const std::wstring s_sqlDeleteRecentContactByJID = L"delete from recentcontact where jid=? and type != 100;";

		const std::wstring s_sqlDeleteSystemRecentContact = L"delete from recentcontact where type = 100;";
		
#endif

		const std::wstring s_sqlReplaceRecentContact = // insert
			L"replace into recentcontact (jid,type,time) values (?,?,?);";

		const std::wstring s_sqlSelectRecentContact = // select
			L"select jid,type from recentcontact;";

		const std::wstring s_sqlSelectRoster = // select
			L"select jid,info,time from roster;";

		const std::wstring s_sqlReplaceRoster = // insert
			L"replace into roster (jid,info,time) values (?,?,?);";
		//±ísystemmessage
		const std::wstring s_sqlSelectOneRequest = // select
			L"select jid,info,extra_info,time,server_time,rowid,msg_type,is_read from systemmessage where rowid = ?;";
	}; // biz_sql

}; // biz
