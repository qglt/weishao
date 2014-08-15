#pragma once

namespace biz {
struct TGroupItem
{
// 	std::string groupID;
	std::string groupName;
};

enum KbizGroupError
{
	kbizGroupError_NoError,
	kbizGroupError_GroupNameExists,
	kbizGroupError_GroupNameNotExists,
	kbizGroupError_GroupNameInvalid,
	kbizGroupError_IOError
};

}; // biz