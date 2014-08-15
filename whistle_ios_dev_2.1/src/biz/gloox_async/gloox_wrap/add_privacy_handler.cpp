#include "add_privacy_handler.h"
#include <base/log/elog/elog.h>
#include "UserStanzaExtensionType.h"
#include <base/txtutil/txtutil.h>
#include "glooxWrapInterface.h"
#include "base/utility/bind2f/bind2f.hpp"
namespace gloox
{
	EditPrivacyHandler::EditPrivacyHandler(Result_Data_Callback callback):callback_(callback)
	{

	}

	bool EditPrivacyHandler::handleIq( const IQ& iq )
	{
		return true;
	}

	static void fill_search_field(json::jobject& jobj, const gloox::Tag* ptag)
	{
		if(ptag)
		{
			jobj["jids"].arr_push(ptag->findAttribute("value"));
			jobj["orders"].arr_push(ptag->findAttribute("order"));
		}
	} 

	/*
	<iq type='result' id='4842ecd40000001f' to='119@dev.ruijie.com.cn/pc' timestamp='1376536790706'>
	<query xmlns='jabber:iq:privacy'>
	<list name='invisable'>
	<item type='jid' action='deny' value='123@ruijie.com.cn' order='123'/>
	<item type='jid' action='deny' value='137@dev.ruijie.com.cn' order='137'/>
	<item type='jid' action='deny' value='136@dev.ruijie.com.cn' order='136'/>
	</list>
	</query>
	</iq>
	*/

	void EditPrivacyHandler::handleIqID( const IQ& iq, int context )
	{
		json::jobject jobj;
		if (iq.m_subtype == IQ::Result)
		{
			if(iq.findExtension(kExtUser_iq_filter_move_to_privacy_list))
			{
				boost::shared_ptr<gloox::Tag> ptag(iq.findExtension(kExtUser_iq_filter_move_to_privacy_list)->tag());
				if (ptag)
				{						
					gloox::ConstTagList ptag_list = ptag->findTagList("//item");
					for (gloox::ConstTagList::iterator it = ptag_list.begin();it != ptag_list.end();it++)
					{
						fill_search_field(jobj,*it);
					}
				}
			}
			callback_(false,XL(""),jobj);
		}
		else
		{
			callback_(true,XL(""),jobj);
		}		
	}
}