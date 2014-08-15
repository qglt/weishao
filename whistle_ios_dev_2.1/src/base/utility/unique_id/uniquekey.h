// Copyright (c) 2009 YangCheng. All rights reserved.

#pragma once
#ifndef __UNIQUE_KEY__
#define __UNIQUE_KEY__
#include <boost/shared_ptr.hpp>
#include <boost/enable_shared_from_this.hpp>
#include <base/config/configure.hpp>
namespace epius
{
	class CUKeyPool;
	class CUKeyImpl;
	//< @brief CUniqueKey
	//introduction: For a CUniqueKey object, it can be used as an integer,
	//it's unique and can be copied, moved. Once it is destroyed, it will 
	//return its value to 
	//the key pool.
	//operator< to support such containers as set, map.
	class CUKey
	{
	public:
		CUKey(int key);
		CUKey(int key, boost::shared_ptr<CUKeyPool> const& owner);
		CUKey(const CUKey& other);
		bool operator==(CUKey const& dst) const;
		bool operator<(CUKey const& dst) const;
		operator int();
	private:
		boost::shared_ptr<CUKeyImpl> m_keyimpl;
	};
	//< @brief CUKeyPool
	//introduction: CUKeyPool is used to generate the CUniqueKey. It can be 
	//used in a class to generate the unique key for the special object, 
	//also it can be a global variable to generate the application-level
	//unique key. It's thread safe.
	//GetKey() the only interface to get the unique key.
	class CUKeyPool:public boost::enable_shared_from_this<CUKeyPool>
	{
		class CUKeyPoolImpl;
	public:
		CUKeyPool(void);
		~CUKeyPool(void);
		CUKey GetKey();
	private:
		friend class CUKeyImpl;
		void ReturnKey(int key);
		boost::shared_ptr<CUKeyPoolImpl> impl_;
	};
}
#endif
