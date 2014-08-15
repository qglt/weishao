#ifndef whistleVcard_H__
#define whistleVcard_H__
#pragma once
#include <string>
#include <base/utility/bind2f/bind2f.hpp>
#include "base/json/tinyjson.hpp"
#include "boost/bind.hpp"
#include "boost/function.hpp"
#include <boost/filesystem.hpp>
#include "anan_biz_impl.h"
#include "gloox_src/rosteritem.h"
#include "gloox_src/presence.h"
#include "gloox_src/stanzaextension.h"
#include "gloox_src/vcardhandler.h"
#include "biz_presence_type.h"
namespace biz {

	extern const std::string JSON_VCARD_VERSION_NAME;// "version";
	extern const std::string JSON_VCARD_VERSION;// "3.0";
	extern const std::string s_VcardHead; // "head";
	extern const std::string s_VcardHead_up; // "head_up";
	extern const std::string s_VcardHeadURI;// "head_bin";
	extern const std::string s_VcardLivePhoto; // "live_photo";
	extern const std::string s_VcardLivePhoto_up; // "live_photo_up";
	extern const std::string s_VcardLivePhotoURI;// "live_photo_bin";
	extern const std::string s_VcardJid;// "jid";
	extern const std::string s_VcardRemarkPinYin;// "remark_pinyin";
	extern const std::string s_VcardNickPinYin;// "nick_pinyin";
	extern const std::string s_VcardNamePinYin;// "name_pinyin";
	extern const std::string s_VcardShowname;// "showname";
	extern const std::string s_VcardNickname;// "nickname";
	extern const std::string s_VcardName;// "name";
	extern const std::string s_VcardSex;// "sex";
	extern const std::string s_VcardIdentity;// "identity";
	extern const std::string s_VcardSexShow;// "sex_show";
	extern const std::string s_VcardIdentityShow;// "identity_show";
	extern const std::string s_Vcardbirthday; // "birthday";
	extern const std::string s_VcardAge; // "age";
	extern const std::string s_Vcardzh_zodiac; // "zh_zodiac";
	extern const std::string s_Vcardzodiac; // "zodiac";
	extern const std::string s_VcardPrivacy; // "vcard_privacy";
	extern const std::string s_VcardGroup; // "group";
	extern const std::string s_VcardDefaultPrivacy; // "default_privacy";
	extern const std::string s_VcardModificationDate;
	extern const std::string s_VcardStatus;
	const char* const s_trans[] = {"Online","Away","Busy","Offline","Android","IOS","Invisible"};
	class whistleVcard
	{
		template<class> friend struct boost::utility::singleton_holder;
		public:
			whistleVcard();
			virtual ~whistleVcard();
			void set_biz_bind_impl(anan_biz_impl* impl);
			anan_biz_impl*	get_parent_impl() { return anan_biz_impl_;};

			void sync_replaceVCard(json::jobject& vcardinfo, json::jobject data);
			void sync_replaceEachField(json::jobject& vcardinfo, json::jobject data );
			void update_vcard(json::jobject& vcardinfo, std::string key, json::jobject val);
			void build_birthday(json::jobject& vcardinfo);
			void syncBuildShowFieldByXL(json::jobject& vcardinfo, std::string uiString, std::string dbString);
			std::string zh_zodiacYear_utf8(int y);
			std::string zodiacYear_by_XL(int m, int d);
			void buildShowname(json::jobject& vcardinfo);
			void updateByRosterItem(json::jobject& vcardinfo, const RosterItem& item);
			void updateGroup(json::jobject& vcardinfo, const RosterItem& item);
			void syncdown_live_image(json::jobject& vcardinfo);
			void syncdown_head_image(json::jobject& vcardinfo);
			bool is_need_download_image(json::jobject& vcardinfo, std::string ui_image_field, std::string uri_image_field, std::string &download_path );
			void FinishFields(json::jobject& vcardinfo);
			void appendStoreFields(Tag*& v, std::string key, json::jobject val);
			void appendPreFields(json::jobject& presence, std::string key, json::jobject val);
			void insertField( gloox::Tag* vcard, const char* field, const std::string& var ) const;
			void handleVCard( JID jid, json::jobject jobj, json::jobject status, boost::function<void()> callback);
			void doHandleVCard( JID jid, json::jobject jobj, json::jobject status, boost::function<void()> callback);
			void handleVCardResult( VCardHandler::VCardContext context, const JID& jid, StanzaError se = StanzaErrorUndefined );
			void updatedVcard(const JID& jid);
			boost::shared_ptr<boost::signal<void(void)> > process_iqs_;
		private:
			anan_biz_impl*	anan_biz_impl_;
	};

	typedef boost::utility::singleton_holder<whistleVcard> gwhistleVcard;
}

#endif
