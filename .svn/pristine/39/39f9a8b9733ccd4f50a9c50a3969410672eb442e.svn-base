#pragma once

namespace biz {

	struct NoticeResult {
		json::jobject jobj;
		UIVCallback callback;
	};

typedef std::map<int, NoticeResult> NoticeMapJsonCallback;

struct notice_msg_impl
{
	notice_msg_impl()
	{
		autoinc_context_ = 0;
		current_msg_id_ = 0;
	}

	long autoinc_context_;
	long current_msg_id_;
	NoticeMapJsonCallback callback_;
};

}; // namespace biz