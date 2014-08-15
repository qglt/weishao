#pragma once
#include "biz_presence_type.h"
#include <string>
#include <list>

namespace biz {

enum KContactType
{
	kctNone     = 0x00,
	kctContact  = 0x01,
	kctStranger = 0x02,
	kctBlacked  = 0x04,
	kctSelf     = 0x08
};

enum whistle_vcard_type { vard_type_none, vard_type_base, vard_type_full};

}; // biz