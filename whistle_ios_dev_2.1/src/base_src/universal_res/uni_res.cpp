#include <map>
#include <boost/shared_ptr.hpp>
#include <base/epiusdb/ep_sqlite.h>
#include <base/txtutil/txtutil.h>
#include <base/log/elog/elog.h>
#include <base/module_path/file_manager.h>
#include <base/module_path/epfilesystem.h>

#include <base/universal_res/uni_res.h>
using namespace std;
using namespace epius;
using namespace epius::epius_sqlite3;

struct uni_res_trans_impl
{
    boost::shared_ptr<epDb> trans_db_;
    wstring language_;// now only support Chinese, English
    map<string, universal_resource> key_value_; //it's a buffer to accelerate resource access
};
universal_resource uni_res_trans::GetResourceByKey( std::string const& key )
{
	if(impl_->key_value_.find(key)!=impl_->key_value_.end())return impl_->key_value_[key];
    universal_resource res;
    wstring sel_sql = L"select " + impl_->language_ + L" from lang_trans where res_key = ?";

	data_iterator it;
	try
	{
		it = impl_->trans_db_->execQuery(sel_sql,epDbBinder(key));
	}
	catch(epius_dberror const& e)
	{
		ELOG("app")->error(WCOOL(L"读取数据库出错，原因是：") + e.what() + " key:" + key);
		return res;
	}

    if(it!=data_iterator())
    {
        res.res_key = key;
#ifdef _WIN32
        res.res_value = it->getField<wstring>(0);
        if(res.res_value.empty())
        {
            res.res_value = txtutil::convert_utf8_to_wcs(key);
            res.res_value_utf8 = key;
        }
        else
        {
            res.res_value_utf8 = txtutil::convert_wcs_to_utf8(res.res_value);
        }
#else
        res.res_value_utf8 = it->getField<string>(0);
        if(res.res_value_utf8.empty())
        {
            res.res_value_utf8 = key;
        }
	
#endif	
    }
    else
    {
        if(!key.empty())
        {
			try
			{
				//need to insert the unknown key into the database
				wstring insert_sql = L"insert into lang_trans (res_key) values (?)";
				impl_->trans_db_->execDML(insert_sql,epDbBinder(key));
			}catch(epius_dberror const& e)
			{
				ELOG("app")->error(WCOOL(L"把新键值写入数据库出错，原因是：") + e.what());
			}
        }
       res.res_key = key;
	   res.res_value_utf8 = key;
#ifdef _WIN32
		res.res_value = txtutil::convert_utf8_to_wcs(key);
#endif
    }
	impl_->key_value_[key] =  res;
    return res;
}

void uni_res_trans::SetLanguage( std::string const& lang )
{
    impl_->language_ = txtutil::convert_utf8_to_wcs(lang);
	//清除缓存
	impl_->key_value_.clear();
}

void uni_res_trans::init()
{
	impl_->language_ = L"chinese";
	std::string root_dir = biz::file_manager::instance().get_app_root_path();
	std::string db_dir = epfilesystem::instance().sub_path(root_dir, "appconfig.dat");
	impl_->trans_db_.reset(new epDb(db_dir));
	try
	{
		data_iterator it;
		try
		{
			impl_->trans_db_->execDML(L"create table if not exists lang_trans (res_key varchar, comment varchar, english varchar, chinese varchar)");
			wstring sel_sql = L"select res_key, " + impl_->language_ + L" from lang_trans";
			it = impl_->trans_db_->execQuery(sel_sql);
		}
		catch(epius_dberror const& e)
		{
			ELOG("app")->error(WCOOL(L"读取数据库出错，原因是：") + e.what());
			return;
		}

		while(it!=data_iterator())
		{
			std::string res_key, res_value_utf8;
			epDbBinder(boost::ref(res_key),boost::ref(res_value_utf8)) = it;
			universal_resource res;
			res.res_key  = res_key;
			if(res_value_utf8.empty())
			{
#ifdef _WIN32
				res.res_value = txtutil::convert_utf8_to_wcs(res_key);
#endif
				res.res_value_utf8 = res_key;
			}
			else
			{
#ifdef _WIN32
				res.res_value = txtutil::convert_utf8_to_wcs(res_value_utf8);
#endif
				res.res_value_utf8 = res_value_utf8;
			}
			impl_->key_value_[res_key] = res;
			++it;
		}
	}
	catch(...)
	{
	}
}

uni_res_trans::uni_res_trans():impl_(new uni_res_trans_impl)
{
   
}

