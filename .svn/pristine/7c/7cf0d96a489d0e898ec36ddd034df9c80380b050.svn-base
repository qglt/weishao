#pragma once
#include "boost/shared_ptr.hpp"
#include "boost/signal.hpp"
#include "base/universal_res/uni_res.h"
#include "anan_biz_bind.h"
#include "anan_type.h"
#include "roster_type.h"
#include "an_roster_manager_type.h"
#include <vector>
#include <string>

namespace gloox { class Client;};

namespace biz
{
	struct Tbiz_recent_contactImpl;
	struct anan_biz_impl;

	using namespace gloox;

	typedef std::pair<std::string /*jid*/, std::string /*name*/> JIDRemarkItem;
	typedef std::list<JIDRemarkItem> JIDRemarkList;

class biz_recent_contact : public anan_biz_bind<anan_biz_impl>
{
	BIZ_FRIEND();
public:
	biz_recent_contact(void);
	virtual ~biz_recent_contact(void);

public:
	void listRecentContact(JsonCallback callback);
	void UploadRecentContact();
#ifndef _WIN32
	void removeSystemRecentContact(UIVCallback callback);
#endif
	void removeRecentContact(std::string jid_string, UIVCallback callback);
	void noticeRecentContactChanged();
protected:
	void regist_to_gloox( Client* p_client );
	void unregist_to_gloox( Client* p_client );
	void BuildRecentContactJson(json::jobject& jobj);
	KRecentJIDType RPaserRecentContactType(std::string typeString);
	void PaserRecentContactJson(json::jobject& jobj);
	void UpdateRecentContact(std::string jid_string, KRecentJIDType type);
	void queryRecentContact_callback(json::jobject jobj);
	void connected();

private:
	boost::shared_ptr<Tbiz_recent_contactImpl> impl_;
};

}; // biz