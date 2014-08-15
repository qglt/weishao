// Copyright (c) 2009 YangCheng. All rights reserved.

#include <set>
#include <boost/noncopyable.hpp>
#include <boost/thread/mutex.hpp>
#include <base/utility/unique_id/uniquekey.h>

using namespace std;

namespace epius
{
	class CUKeyImpl:public boost::noncopyable
	{
	public:
		CUKeyImpl(int key,boost::shared_ptr<CUKeyPool> owner);
		~CUKeyImpl();
		int GetValue() const;
	private:
		int m_key;
		boost::weak_ptr<CUKeyPool> m_owner;
	};
	class CUKeyPool::CUKeyPoolImpl
	{
	public:
		CUKeyPoolImpl():m_key(0){}
		std::set<int> m_keys;
		unsigned int m_key;
		boost::mutex m_mutex;
	};

	CUKeyPool::CUKeyPool(void):impl_(new CUKeyPoolImpl)
	{
	}

	CUKeyPool::~CUKeyPool(void)
	{

	}

	CUKey CUKeyPool::GetKey()
	{
		boost::mutex::scoped_lock lock(impl_->m_mutex);
		if(impl_->m_keys.empty())
		{
			return CUKey(impl_->m_key++,shared_from_this());
		}
		else
		{
			int key = *(impl_->m_keys.begin());
			impl_->m_keys.erase(impl_->m_keys.begin());
			return CUKey(key,shared_from_this());
		}
	}

	void CUKeyPool::ReturnKey( int key )
	{
		boost::mutex::scoped_lock lock(impl_->m_mutex);
		impl_->m_keys.insert(key);
	}

	CUKeyImpl::~CUKeyImpl()
	{
		boost::shared_ptr<CUKeyPool> valid_ptr_tmp(m_owner.lock());
		if(valid_ptr_tmp)
		{
			valid_ptr_tmp->ReturnKey(m_key);
		}
	}

	int CUKeyImpl::GetValue() const
	{
		return m_key;
	}

	CUKeyImpl::CUKeyImpl( int key,boost::shared_ptr<CUKeyPool> owner ):m_key(key),m_owner(owner)
	{

	}
	bool CUKey::operator==( CUKey const& dst ) const
	{
		return m_keyimpl->GetValue() == dst.m_keyimpl->GetValue();
	}

	bool CUKey::operator<( CUKey const& dst ) const
	{
		return m_keyimpl->GetValue() < dst.m_keyimpl->GetValue();
	}

	CUKey::operator int()
	{
		return m_keyimpl->GetValue();
	}

	CUKey::CUKey( int key ):m_keyimpl(new CUKeyImpl(key,boost::shared_ptr<CUKeyPool>()))
	{

	}

	CUKey::CUKey( int key, boost::shared_ptr<CUKeyPool> const& owner ):m_keyimpl(new CUKeyImpl(key,owner))
	{

	}

	CUKey::CUKey( const CUKey& other ):m_keyimpl(other.m_keyimpl)
	{
	}

}