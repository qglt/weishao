//
//  ios_biz_higher.h
//  Whistle
//
//  Created by chao.wang on 13-1-5.
//  Copyright (c) 2013年 chao.wang. All rights reserved.
//

#ifndef __Whistle__ios_biz_higher__
#define __Whistle__ios_biz_higher__

#include <iostream>
#include <base/utility/singleton/singleton.hpp>
#include <base/json/tinyjson.hpp>



namespace biz
{
    extern std::string whistle_device_approot;
	class biz_higher_impl;
	class ios_biz_higher 
	{
		template<class> friend struct boost::utility::singleton_holder;

	public : 
		void init();
		void executeCommand(json::jobject jobj);
		void stop();

	private :
		ios_biz_higher();
		boost::shared_ptr<biz_higher_impl> impl_;


	};

	typedef boost::utility::singleton_holder<ios_biz_higher> biz_higher;
}



#endif /* defined(__Whistle__ios_biz_higher__) */
