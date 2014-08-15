#pragma once
#include "biz_groups.h"

namespace biz {

	_BEGIN_IMPL_E(BizGroups, biz.roster.groups)
		_IMPL_E(kbizGroupError_NoError, "no_error") // �޴���
		_IMPL_E(kbizGroupError_GroupNameExists,"group_name_exists") // ��ϵ�������Ѿ����ڡ�
		_IMPL_E(kbizGroupError_GroupNameNotExists,"group_name_not_exists") // ��ϵ�����������ڡ�
		_IMPL_E(kbizGroupError_IOError,"io_error") // IO����
		_IMPL_E(kbizGroupError_GroupNameInvalid,"group_name_invalid") // ��Ч��������
	_END_IMPL_E();

};