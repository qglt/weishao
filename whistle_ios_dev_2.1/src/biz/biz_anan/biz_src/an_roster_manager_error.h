#pragma once
#include "an_roster_manager.h"

namespace biz 
{

	_BEGIN_IMPL_E(AnRosterManager, biz.roster)
		_IMPL_E(kbizRosterMgrError_NoError,"no_error") // 无错误。
		_IMPL_E(kbizRosterMgrError_GroupNameNotExists,"group_name_not_exists") // 联系人分组名不存在。
		_IMPL_E(kbizRosterMgrError_ContactNameNotExists,"contact_name_not_exists") // 联系人名不存在。
		_IMPL_E(kbizRosterMgrError_IOError,"io_error") // IO错误。
		_END_IMPL_E();

};