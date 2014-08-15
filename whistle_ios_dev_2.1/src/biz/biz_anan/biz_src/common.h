#pragma once
#include "gloox_src/stanzaextension.h"

#define XMLNS_NOTICE "http://ruijie.com.cn/notification"
#define XMLNS_ORG "organization:membership"

namespace biz {
	using namespace gloox;

	enum KStanzaExtensionUserType 
	{
		kExtUser_iq_filter_tree = ExtUser,//组织结构树
		kExtUser_iq_filter_notice,//发送通知
		kExtUser_iq_filter_noticemsg, // 接收通知
		kExtUser_iq_filter_noticeack // 通知确认
	};

}; // namespace biz


