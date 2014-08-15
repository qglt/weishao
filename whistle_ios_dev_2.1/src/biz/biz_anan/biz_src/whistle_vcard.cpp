#include "base/tcpproactor/TcpProactor.h"
#include "whistle_vcard.h"
#include "base/universal_res/uni_res.h"
#include "wannianli.h"
#include <base/txtutil/txtutil.h>
#include "an_roster_manager.h"
#include "an_roster_manager_impl.h"
#include "local_config.h"
#include "base/cmd_wrapper/command_wrapper.h"
#include "an_vcard_type.h"
#include <base/log/elog/elog.h>
#include "base/http_trans/http_request.h"
#include "anan_config.h"
#include "login.h"

#define FINISH_VCARD_FIELD(x,y) do if (!(x)) (x) = (y); while(0)
namespace biz{

	const std::string JSON_VCARD_VERSION_NAME = "version";
	const std::string JSON_VCARD_VERSION = "3.0";
	const std::string s_VcardHead = "head";
	const std::string s_VcardHead_up = "head_up";
	const std::string s_VcardHeadURI = "photo_credential";
	const std::string s_VcardLivePhoto = "live_photo";
	const std::string s_VcardLivePhoto_up = "live_photo_up";
	const std::string s_VcardLivePhotoURI = "photo_live";
	const std::string s_VcardJid = "jid";
	const std::string s_VcardRemarkPinYin = "remark_pinyin";
	const std::string s_VcardNickPinYin = "nick_pinyin";
	const std::string s_VcardNamePinYin = "name_pinyin";
	const std::string s_VcardShowname = "showname";
	const std::string s_VcardNickname = "nick_name";
	const std::string s_VcardName = "name";
	const std::string s_VcardSex = "sex";
	const std::string s_VcardIdentity = "identity";
	const std::string s_VcardSexShow = "sex_show";
	const std::string s_VcardIdentityShow = "identity_show";
	const std::string s_Vcardbirthday = "birthday";
	const std::string s_VcardAge = "age";
	const std::string s_Vcardzh_zodiac = "zh_zodiac";
	const std::string s_Vcardzodiac = "zodiac";
	const std::string s_VcardPrivacy = "vcard_privacy";
	const std::string s_VcardGroup = "group";
	const std::string s_VcardModificationDate = "modificationdate";
	const std::string s_VcardStatus = "status";
	const std::string s_VcardDefaultPrivacy = "{\"zodiac\":\"friend\",\"zh_zodiac\":\"friend\",\"weblog\":\"friend\",\"address_extend\":\"friend\",\"landline\":\"friend\",\"information\":\"friend\"," \
		"\"home_page\":\"friend\",\"email\":\"friend\",\"cellphone\":\"friend\",\"blood_type\":\"friend\",\"birthday\":\"friend\",\"student_number\":\"friend\",\"age\":\"friend\"}";


	using namespace epius::proactor;

	whistleVcard::whistleVcard()
	{
		process_iqs_.reset(new boost::signal<void(void)>);
	}

	whistleVcard::~whistleVcard()
	{

	}

	void whistleVcard::set_biz_bind_impl( anan_biz_impl* impl )
	{
		anan_biz_impl_ = impl;
	}

	void whistleVcard::sync_replaceVCard( json::jobject& vcardinfo, json::jobject data )
	{
		sync_replaceEachField(vcardinfo, data);
		build_birthday(vcardinfo);
		syncBuildShowFieldByXL(vcardinfo, s_VcardSexShow, s_VcardSex);
		syncBuildShowFieldByXL(vcardinfo, s_VcardIdentityShow, s_VcardIdentity);		
		buildShowname(vcardinfo);
		syncdown_head_image(vcardinfo);
		syncdown_live_image(vcardinfo);
	}

	void whistleVcard::sync_replaceEachField( json::jobject& vcardinfo, json::jobject data )
	{
		data.each(bind2f(&whistleVcard::update_vcard, this, vcardinfo, _1, _2));
	}

	void whistleVcard::update_vcard(json::jobject& vcardinfo, std::string key, json::jobject val)
	{
		vcardinfo[key] = val;
	}

	void whistleVcard::build_birthday(json::jobject& vcardinfo)
	{
		std::string birthday = vcardinfo[s_Vcardbirthday].get<std::string>(); // YYYY-MM-DD
		if (birthday.length() != 10)
		{
			return;
		}
		std::string cur_time = get_parent_impl()->bizLocalConfig_->getCurrentTime(); // YYYY-MM-DD hh:mm:ss
		struct time_ymd {int y,m,d;} b,c;
		b.y = boost::lexical_cast<int>(birthday.substr(0, 4));
		b.m = boost::lexical_cast<int>(birthday.substr(5, 2));
		b.d = boost::lexical_cast<int>(birthday.substr(8, 2));
		c.y = boost::lexical_cast<int>(cur_time.substr(0, 4));
		c.m = boost::lexical_cast<int>(cur_time.substr(5, 2));
		c.d = boost::lexical_cast<int>(cur_time.substr(8, 2));

		int age = 0;
		if (c.y < b.y || c.y == b.y && c.m < b.m || c.y == b.y && c.m == b.m && c.d < b.d)
		{
			age = 0;
		}
		else
		{
			age = c.y - b.y;
			if (c.m < b.m || c.m == b.m && c.d < b.d)
			{
				--age;
			}
		}

		vcardinfo[s_VcardAge] = age;

		ConvDate cd;
		cd.Source = 0;
		cd.SolarYear = b.y;
		cd.SolarMonth = b.m;
		cd.SolarDay = b.d;
		if (!CalConv(&cd))
		{
			vcardinfo[s_Vcardzh_zodiac] = zh_zodiacYear_utf8(cd.LunarYear);
			vcardinfo[s_Vcardzodiac] = zodiacYear_by_XL(cd.SolarMonth, cd.SolarDay);
		}
	}

	std::string whistleVcard::zh_zodiacYear_utf8(int y)
	{
		static const std::wstring Animals = L"猴鸡狗猪鼠牛虎兔龙蛇马羊";
		return epius::txtutil::convert_wcs_to_utf8(Animals.substr(y%12, 1));
	}

	std::string whistleVcard::zodiacYear_by_XL(int m, int d)
	{
		static const std::string prefix = "zodiac.";
		static const std::string names[] = {
			"Capricorn", // 摩羯座12.22-1.19
			"Aquarius", // 水瓶座1.20-2.18
			"Pisces", // 双鱼座2.19-3.20
			"Aries", // 白羊座3.21-4.20
			"Taurus", // 金牛座4.21-5.20
			"Gemini", // 双子座5.21-6.21
			"Cancer", // 巨蟹座6.22-7.22
			"Leo", // 狮子座7.23-8.22
			"Virgo", // 处女座8.23-9.22
			"Libra", // 天秤座9.23-10.22
			"Scorpio", // 天蝎座10.23-11.21
			"Sagittarius", // 射手座11.22-12.21
		};

		int betweens[][3] = {
			{1222,1231,0},
			{101,119,0},
			{120,218,1},
			{219,320,2},
			{321,420,3},
			{421,520,4},
			{521,621,5},
			{622,722,6},
			{723,822,7},
			{823,922,8},
			{923,1022,9},
			{1023,1121,10},
			{1122,1221,11}
		};

		for (int i=0; i<sizeof(betweens)/sizeof(betweens[0]); ++i)
		{
			int beg_d = betweens[i][0]%100;
			int beg_m = betweens[i][0]/100;
			int end_d = betweens[i][1]%100;
			int end_m = betweens[i][1]/100;
			if ( (m>beg_m || m==beg_m && d>=beg_d) && (m<end_m || m==end_m && d<=end_d) )
			{
				return XL(prefix + names[betweens[i][2]]).res_value_utf8;
			}			
		}
		return "";
	}

	void whistleVcard::syncBuildShowFieldByXL( json::jobject& vcardinfo, std::string uiString, std::string dbString )
	{
		universal_resource myur = XL(vcardinfo[dbString].get<std::string>());
		vcardinfo[uiString] = myur.res_value_utf8;
	}

	void whistleVcard::buildShowname( json::jobject& vcardinfo )
	{
		get_parent_impl()->bizRoster_->buildShownameHelper(vcardinfo);
	}

	void whistleVcard::updateByRosterItem(json::jobject& vcardinfo, const RosterItem& item)
	{
		updateGroup(vcardinfo, item);
	}

	
	void whistleVcard::updateGroup(json::jobject& vcardinfo, const RosterItem& item)
	{
		SubscriptionType type = item.subscription();
		switch (type)
		{
		default:
			vcardinfo[s_VcardGroup] = "";
			break;
		case S10nTo:
		case S10nToIn:
		case S10nBoth:
			{
				StringList sl = item.groups();
				if (!sl.empty())
				{
					std::string group_name = *sl.begin();
					if(group_name == GROUPNAME_BLACKED)
					{
						vcardinfo[s_VcardGroup] = XLVU(GROUPNAME_BLACKED);
					}
					else
					{
						vcardinfo[s_VcardGroup] = group_name;
					}
				}
				else 
				{
					vcardinfo[s_VcardGroup] = XLVU(GROUPNAME_MY_FRIEND);
				}
				break;
			}
		case S10nFrom:
		case S10nFromOut:
			vcardinfo[s_VcardGroup] = XLVU(GROUPNAME_STRANGER);
			break;
		}
	}

	void whistleVcard::syncdown_live_image( json::jobject& vcardinfo )
	{
		std::string jid_string = vcardinfo[s_VcardJid].get<std::string>();

		std::string download_path;
		if (!is_need_download_image(vcardinfo, s_VcardLivePhoto, s_VcardLivePhotoURI, download_path))
			return;

		std::string uri_string = vcardinfo[s_VcardLivePhotoURI].get<std::string>();
		assert(!uri_string.empty());

		get_parent_impl()->bizLocalConfig_->createDirectories();

		boost::function<void(bool,std::string)> callback = bind_s(&AnRosterManager::finished_syncdown_image, get_parent_impl()->bizRoster_, jid_string, s_VcardLivePhoto,download_path,_1, _2);
		epius::http_requests::instance().download(anan_config::instance().get_http_down_path(), download_path, uri_string, "", boost::function<void(int)>(), get_parent_impl()->wrap(callback));
	}

	void whistleVcard::syncdown_head_image( json::jobject& vcardinfo )
	{
		std::string jid_string = vcardinfo[s_VcardJid].get<std::string>();

		std::string download_path;
		if (!is_need_download_image(vcardinfo, s_VcardHead, s_VcardHeadURI, download_path))
			return;

		std::string uri_string = vcardinfo[s_VcardHeadURI].get<std::string>();
		assert(!uri_string.empty());
		
		get_parent_impl()->bizLocalConfig_->createDirectories();

		boost::function<void(bool,std::string)> callback = bind_s(&AnRosterManager::finished_syncdown_image, get_parent_impl()->bizRoster_, jid_string, s_VcardHead,download_path,_1, _2);
		epius::http_requests::instance().download(anan_config::instance().get_http_down_path(), download_path, uri_string, "", boost::function<void(int)>(), epius::thread_switch::CmdWrapper(get_parent_impl()->_p_private_task_->get_post_cmd(),callback));
	}

	bool whistleVcard::is_need_download_image(json::jobject& vcardinfo, std::string ui_image_field, std::string uri_image_field, std::string &download_path )
	{
		std::string ui_path = vcardinfo[ui_image_field].get<std::string>();
		std::string uri_string = vcardinfo[uri_image_field].get<std::string>();
		if (uri_string.empty()) 
		{
			return false;
		}

		std::string the_path_from_uri = file_manager::instance().from_uri_to_path(uri_string);
		bool is_need = !file_manager::instance().file_is_valid(the_path_from_uri);
		if (!is_need) 
		{
			if (the_path_from_uri != ui_path)
			{
				vcardinfo[ui_image_field] = the_path_from_uri;
			}
		}
		else 
		{
			vcardinfo[ui_image_field] = "";
			download_path = the_path_from_uri;
		}
		return (is_need);
	}

	void whistleVcard::FinishFields( json::jobject& vcardinfo )
	{
		FINISH_VCARD_FIELD(vcardinfo[s_VcardPrivacy], json::jobject(s_VcardDefaultPrivacy));

		for (int i=0; !sc_nametb[i].empty(); ++i)
		{
			FINISH_VCARD_FIELD(vcardinfo[sc_nametb[i]],"");
		}

		FINISH_VCARD_FIELD(vcardinfo[s_VcardHead],"");
		FINISH_VCARD_FIELD(vcardinfo[s_VcardHeadURI],"");
		FINISH_VCARD_FIELD(vcardinfo[s_VcardLivePhoto],"");
		FINISH_VCARD_FIELD(vcardinfo[s_VcardLivePhotoURI],"");
		FINISH_VCARD_FIELD(vcardinfo[s_VcardJid],"");
		FINISH_VCARD_FIELD(vcardinfo[s_VcardRemarkPinYin],json::jobject());
		FINISH_VCARD_FIELD(vcardinfo[s_VcardNickPinYin],json::jobject());
		FINISH_VCARD_FIELD(vcardinfo[s_VcardNamePinYin],json::jobject());
		FINISH_VCARD_FIELD(vcardinfo[s_VcardShowname],"");
		FINISH_VCARD_FIELD(vcardinfo[s_VcardNickname],"");
		FINISH_VCARD_FIELD(vcardinfo[s_VcardName],"");
		FINISH_VCARD_FIELD(vcardinfo[s_VcardSex],"");
		FINISH_VCARD_FIELD(vcardinfo[s_VcardIdentity],"");
		FINISH_VCARD_FIELD(vcardinfo[s_VcardSexShow],"");
		FINISH_VCARD_FIELD(vcardinfo[s_VcardIdentityShow],"");
		FINISH_VCARD_FIELD(vcardinfo[s_VcardGroup],"");
		FINISH_VCARD_FIELD(vcardinfo[s_VcardAge],"");
		FINISH_VCARD_FIELD(vcardinfo[s_Vcardzh_zodiac],"");
		FINISH_VCARD_FIELD(vcardinfo[s_Vcardzodiac],"");
	}

	void whistleVcard::appendPreFields(json::jobject& presence, std::string key, json::jobject val)
	{
		// 检查是否是vcard字段
		for (int i=0; !sc_store_name[i].empty(); ++i) 
		{
			if (sc_store_name[i].compare(key) == 0)
			{
				presence[key] = val;
			}
		}
	}

	void whistleVcard::appendStoreFields( Tag*& v, std::string key, json::jobject val )
	{
		// 检查是否是vcard字段
		for (int i=0; !sc_store_name[i].empty(); ++i)
		{
			if (sc_store_name[i].compare(key) == 0)
			{
				std::string varstr;
				if (key == s_VcardPrivacy)
				{
					varstr = val.to_string();
				} 
				else
				{
					varstr = val.get<std::string>();
				}
				insertField( v, key.c_str(), varstr );
				break;
			}
		}
	}

	void whistleVcard::insertField( Tag* vcard, const char* field, const std::string& var ) const
	{
		if( field )
		{
			new Tag( vcard, field, var );
		}
	}

	void whistleVcard::handleVCard( JID jid, json::jobject jobj, json::jobject status, boost::function<void()> callback)
	{

		if (jid == get_parent_impl()->bizClient_->jid().bare())
		{
			// 先处理自己的iq
			doHandleVCard(jid, jobj, status, callback);
			
			json::jobject tell_user_sex;
			ContactMap::iterator itvcard = get_parent_impl()->bizRoster_->syncget_VCard(jid.bare());
			tell_user_sex["set_user_sex"] = itvcard->second.get_vcardinfo()[s_VcardSex];
			event_collect::instance().recv_presence(jid.bare(), sPresenceTypeTransTable[get_parent_impl()->bizClient_->presence().subtype()], tell_user_sex);

			// 处理未处理的好友iq
			if (gwhistleVcard::instance().process_iqs_.get()->num_slots())
			{
				(*gwhistleVcard::instance().process_iqs_.get())();
				gwhistleVcard::instance().process_iqs_.get()->disconnect_all_slots();
			}
			return;
		}
		else
		{
			ContactMap::iterator itvcard = get_parent_impl()->bizRoster_->syncget_VCard(get_parent_impl()->bizClient_->jid().bare());
			if (itvcard != get_parent_impl()->bizRoster_->impl_->vcard_manager_.end() && itvcard->second.fetch_done_)
			{
				// 已经处理过自己， 直接处理iq
				doHandleVCard(jid, jobj, status, callback);
			}
			else
			{
				// 没有处理过自己， 绑定iq到信号量
				gwhistleVcard::instance().process_iqs_.get()->connect(bind2f(&whistleVcard::doHandleVCard, gwhistleVcard::instance(), jid, jobj, status, callback));
			}
		}
	}

	void whistleVcard::doHandleVCard( JID jid, json::jobject jobj, json::jobject status, boost::function<void()> callback)
	{
		bool ret = false;
		bool notice = false;
		ContactMap::iterator itvcard = get_parent_impl()->bizRoster_->syncget_VCard(jid.bare());
		if (itvcard != get_parent_impl()->bizRoster_->impl_->vcard_manager_.end()){
			// 服务器只返回2项数据， jid 和 s_VcardModificationDate， 代表数据时间戳是一致的
			if (jobj.size() == 2)
			{
				//服务端和本地的最后更新时间一致， 直接使用本地数据
				//不保存status到roster表中
				if ( status != json::jobject())
				{
					itvcard->second.get_vcardinfo()[s_VcardStatus] = status;
				}
			}
			else
			{
				notice = true;
				itvcard->second.fetch_done_ = true;

				// bug 811 查找vcard，服务端没有返回的值，应删除
				for (int i=0; !sc_nametb[i].empty(); ++i)
				{
					itvcard->second.get_vcardinfo()[sc_nametb[i]] = "";
				}

				sync_replaceVCard(itvcard->second.get_vcardinfo(), jobj);

				if (itvcard->second.get_vcardinfo()[s_VcardPrivacy] == json::jobject())
				{
					itvcard->second.get_vcardinfo()[s_VcardPrivacy] = json::jobject(s_VcardDefaultPrivacy);
				}

				get_parent_impl()->bizLocalConfig_->scheduleSaveRoster(jid.bare(), itvcard->second.get_vcardinfo());

				//不保存status到roster表中
				if ( status != json::jobject())
				{
					itvcard->second.get_vcardinfo()[s_VcardStatus] = status;
				}
			}
			ret = true;
		}
		else
		{
			//在roster里查找不到指定的联系人， 这个联系人也许在服务端回包前已经被删除了
			ret = false;
			get_parent_impl()->bizLocalConfig_->scheduleSaveRoster(jid.bare(), jobj);
		}

		if (ret)
		{
			if (!callback.empty())
			{
				callback();
			}
			else
			{
				if (notice)
				{
					updatedVcard(jid);
				}
			}
		}
	}

	void whistleVcard::handleVCardResult(VCardHandler::VCardContext context, const JID& jid, StanzaError se)
	{
		switch(context)
		{
		default:
			{
				ELOG("app")->error("whistleVcard::handleVCardResult: vcard store failed.");
				break;
			}
		case VCardHandler::StoreVCard:
			{
				//替换修改成功的vcard字段
				std::string jid_string = get_parent_impl()->bizClient_->jid().bare();
				ContactMap::iterator itvcard = get_parent_impl()->bizRoster_->syncget_VCard(jid_string);
				if (itvcard != get_parent_impl()->bizRoster_->impl_->vcard_manager_.end())
				{
					gwhistleVcard::instance().sync_replaceVCard(itvcard->second.get_vcardinfo(), itvcard->second.get_storeinfo());
					get_parent_impl()->bizLocalConfig_->scheduleSaveRoster(jid_string, itvcard->second.get_storeinfo());
					//通知界面update修改过的字段
					json::jobject changes = itvcard->second.get_storeinfo().clone();
					changes[s_VcardJid] = jid_string;
					//广播vcard变更
					json::jobject changespresence;
					changes.each(bind2f(&whistleVcard::appendPreFields, gwhistleVcard::instance(), boost::ref(changespresence), _1, _2));
					get_parent_impl()->bizRoster_->broad_vcard_in_presence(changespresence);
					changes[s_VcardShowname] = itvcard->second.get_vcardinfo()[s_VcardShowname].get<std::string>();
					event_collect::instance().recv_item_updated(get_parent_impl()->bizRoster_->buildVCardNotice(krntUpdate, changes, krntAdd_none).to_string());
				}
				break;
			}
		}
	}

	void whistleVcard::updatedVcard( const JID& jid )
	{
		if(get_parent_impl())
		{
			event_collect::instance().recv_item_updated(get_parent_impl()->bizRoster_->buildVCardNotice(krntUpdate, jid.bare(), krntAdd_none).to_string());
		}
	}

}


