#pragma once
#include "an_roster_manager.h"

namespace biz 
{

	_BEGIN_IMPL_E(AnRosterManager, biz.roster)
		_IMPL_E(kbizRosterMgrError_NoError,"no_error") // �޴���
		_IMPL_E(kbizRosterMgrError_GroupNameNotExists,"group_name_not_exists") // ��ϵ�˷����������ڡ�
		_IMPL_E(kbizRosterMgrError_ContactNameNotExists,"contact_name_not_exists") // ��ϵ���������ڡ�
		_IMPL_E(kbizRosterMgrError_IOError,"io_error") // IO����
		_END_IMPL_E();

};