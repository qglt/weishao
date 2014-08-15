#include <base/log/elog/elog.h>
#include <base/txtutil/txtutil.h>
#include <base/module_path/file_manager.h>
#include <base/time/time_format.h>
#include "UserStanzaExtensionType.h"
#include "find_friend_handler.h"
namespace gloox
{
	findFriendHandler::findFriendHandler( boost::function<void(bool,json::jobject)> callback ):callback_(callback)
	{

	}

	bool findFriendHandler::handleIq( const IQ& iq )
	{
		return true;
	}
	static std::string getCurrentTime()
	{
		//eg:2012-08-28 15:02:25

		boost::posix_time::ptime time_now(boost::posix_time::second_clock::local_time());
		return epius::time_format(time_now);
	}

	static void fill_search_field(json::jobject& jobj, const gloox::Tag* ptag, std::string field,std::string replace_field = "")
	{
		if(replace_field.empty())replace_field = field;
		gloox::Tag* item_tag = ptag->findChildWithAttrib("var",field);

		if(!item_tag)
		{
			jobj[replace_field] = "";
			return;
		}
		gloox::Tag* value_tag = item_tag->findChild("value");
		if(!value_tag)
		{
			jobj[replace_field] = "";
			return;
		}
		jobj[replace_field] = value_tag->cdata();
	}


	void findFriendHandler::handleIqID( const IQ& iq, int context )
	{
		//查找好友
		json::jobject data;
		if (iq.m_subtype != gloox::IQ::Result)
		{
			callback_(false,data);
			return;
		}
		if(iq.findExtension(kExtUser_iq_filter_find_friend))
		{
			boost::shared_ptr<gloox::Tag> ptag(iq.findExtension(kExtUser_iq_filter_find_friend)->tag());
			std::string nick_name;
			std::string user_name;
			std::string name;
			if (ptag)
			{
				gloox::ConstTagList ptag_list = ptag->findTagList("//item");
				for (gloox::ConstTagList::iterator it = ptag_list.begin();it != ptag_list.end();it++)
				{
					json::jobject contact;
					fill_search_field(contact,*it,"username","jid");
					fill_search_field(contact,*it,"name");
					fill_search_field(contact,*it,"aid");
					fill_search_field(contact,*it,"sex");
					fill_search_field(contact,*it,"nativeplace_province");
					fill_search_field(contact,*it,"birthday");
					fill_search_field(contact,*it,"hobby");
					fill_search_field(contact,*it,"mood_words");
					fill_search_field(contact,*it,"photo_credential");
					fill_search_field(contact,*it,"identity");
					fill_search_field(contact,*it,"vcard_privacy");
					fill_search_field(contact,*it,"organization");
					// 性别身份需要转译
					contact["sex_show"]=XL(contact["sex"].get<std::string>()).res_value_utf8;
					contact["identity_show"] = XL(contact["identity"].get<std::string>()).res_value_utf8;
					//如果查找到birthday 增加年龄 bug 262
					std::string birthday = contact["birthday"].get<std::string>();
					contact["age"] = "";
					if (!birthday.empty())
					{
						std::string cur_time = getCurrentTime(); // YYYY-MM-DD hh:mm:ss
						struct time_ymd {int y,m,d;} b,c;
						b.y = boost::lexical_cast<int>(birthday.substr(0, 4));
						b.m = boost::lexical_cast<int>(birthday.substr(5, 2));
						b.d = boost::lexical_cast<int>(birthday.substr(8, 2));
						c.y = boost::lexical_cast<int>(cur_time.substr(0, 4));
						c.m = boost::lexical_cast<int>(cur_time.substr(5, 2));
						c.d = boost::lexical_cast<int>(cur_time.substr(8, 2));

						int age = 0 ;
						if (c.y < b.y || c.y == b.y && c.m < b.m || c.y == b.y && c.m == b.m && c.d < b.d)
							age = 0;
						else
						{
							age = c.y - b.y;
							if (c.m < b.m || c.m == b.m && c.d < b.d)
								--age;
						}
						contact["age"] = boost::lexical_cast<std::string>(age);
					}
				    data.arr_push(contact);
		        }
	        }
			else
			{
				callback_(false,data);
				return;
			}
		}
		else
		{
			callback_(false,data);
			return;
		}
		callback_(true,data);
	}

}