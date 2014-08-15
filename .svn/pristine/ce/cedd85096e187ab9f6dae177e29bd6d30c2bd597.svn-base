#include "thread_id.h"
#include <base/utility/uuid/uuid.hpp>
#include <base/utility/bind2f/bind2f.hpp>
#include <base/thread/time_thread/time_thread_mgr.h>
namespace biz{

	biz_thread_id::biz_thread_id()
	{

	}

	std::string biz_thread_id::gen_id()
	{
		std::string uuid = epius::gen_uuid();

		std::pair< std::set<std::string>::iterator, bool > ret;
		ret = id_set_.insert(uuid);

		if (ret.second)
		{
			// 30秒以后自动删除
			epius::time_mgr::instance().set_timer(30000, wrap_helper_.wrap(bind2f(&biz_thread_id::delete_id, this, uuid)));

			return uuid;
		}
		else
		{
			return "";
		}
	}

	void biz_thread_id::delete_id( std::string id )
	{
		std::set<std::string>::iterator it = id_set_.find(id);
		if (it!=id_set_.end())
		{
			id_set_.erase(it);
		}
	}

	bool biz_thread_id::is_id_exist( std::string id )
	{
		std::set<std::string>::iterator it = id_set_.find(id);
		if (it!=id_set_.end())
		{
			return true;
		}
		else
		{
			return false;
		}
	}

}