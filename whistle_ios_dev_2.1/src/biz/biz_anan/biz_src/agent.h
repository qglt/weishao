//---------------------------------------------------
// Copyright (C) 2012, All rights reserved
//
// descrption: entrypoint file.
// ver: 2.0
// auther: majiazhi
// date: (YMD)2012/07/04
//---------------------------------------------------

#pragma once
#include "boost/shared_ptr.hpp"
#include "anan_biz_bind.h"
#include <string>
#include "agent_type.h"
#include <list>
#include "boost/function.hpp"
#include "anan_type.h"
#include "base/universal_res/uni_res.h"

namespace biz {

struct anan_biz_impl;
struct agent_impl;

class agent : public anan_biz_bind<anan_biz_impl>
{
	BIZ_FRIEND();
public:
	agent();
	virtual ~agent(void);

public:
	void init(std::string domain);
	void init();
	void removeUser(std::string userName, bool withLocalData);
	std::string get_domain() const;
	void move_data_dir(json::jobject jobj, UIVCallback callback);
	boost::shared_ptr<agent_impl> impl_;
	void uninit();
	void stop_work();

protected:
	std::string get_autorun_dir();
	void createGloox();
	void init_language();
	void update_domain();
};

};