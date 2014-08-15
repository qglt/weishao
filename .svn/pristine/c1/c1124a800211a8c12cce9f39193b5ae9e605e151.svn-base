#include <vector>
#include <fstream>
#include <algorithm>
#include <boost/make_shared.hpp>
#include <boost/date_time/time_clock.hpp>
#include <boost/date_time/posix_time/ptime.hpp>
#include <boost/date_time/posix_time/time_formatters.hpp>
#include <boost/date_time/gregorian/gregorian.hpp>
#include <base/thread/thread_base/thread_base.h>
#include <base/txtutil/txtutil.h>
#include <base/module_path/epfilesystem.h>
#include <base/log/elog/elog.h>

#ifdef __APPLE__
#include "TargetConditionals.h"
#endif

using namespace std;
using namespace boost;
namespace epius{
    static const char* const log_level[] = {"Debug", "Warn", "Error", "Fatal"};

    class elog_format
    {
    public:
        
    };
    class elog_filter
    {
    public:
        elog_filter(int allow):allowed_lv_(allow){}
        bool is_valid(int nLv){return nLv>=allowed_lv_;}
    private:
        int allowed_lv_;
    };
	class elog_factory_impl
	{
	public:
		std::map<string, boost::shared_ptr<elog> > logs_;
		thread_base thread_worker;
		std::string root_path_;
		boost::shared_ptr<elog> empty_log_;
		std::string version_num;
	public:
		void del_log_file();
		int get_days(std::string log_date); 
		bool exclude_file(std::string file_path)
		{
			if(epfilesystem::instance().is_directory(file_path))return true;
			std::string file_name = epfilesystem::instance().file_name(file_path);
			std::string log_date = file_name.substr(0,file_name.find_last_of("-"));
			int tmp_days = get_days(log_date);
			if (tmp_days <= 6) return true;
			return false;
		}
	};
	void elog_factory_impl::del_log_file()
	{
		std::string log_path = epfilesystem::instance().sub_path(root_path_, "log");
		epfilesystem::instance().remove_files(log_path,boost::bind(&elog_factory_impl::exclude_file,this,_1));
	}

	int elog_factory_impl::get_days(std::string log_date)
	{
		using namespace boost::gregorian;
		try 
		{
			date logday(from_simple_string(log_date));
			date today = day_clock::local_day();  
			days days_alive = today - logday;
			int tmp_datys = days_alive.days();
			return tmp_datys;
		}
		catch(...)
		{
			return 0;
		}
	}
	
    class elog_appender
    {
    public:
        elog_appender(){}
        elog_appender(string file_name):file_name_(file_name){}
        void set_filename(string file_name){file_name_ = file_name;}
        void set_append_mode(bool bAppend){append_mode_ = bAppend;}
        void write(string const&logLev, string info, boost::posix_time::ptime time)
        {
            int year = time.date().year();
            int month = time.date().month();
            int day = time.date().day();
            std::string time_str = boost::str(boost::format("%d-%02d-%02d")%year%month%day);
			boost::gregorian::date local_day = boost::gregorian::day_clock::local_day();
            std::string log_date_time = boost::gregorian::to_iso_extended_string(local_day);
			if(!time.time_of_day().is_special()) {
                char sep = ' ';
                time_str += sep + boost::posix_time::to_simple_string(time.time_of_day());
            }
			if (elog_factory::instance().get_root_path().empty())
			{
				return;
			}
			std::string destfileUtf = epfilesystem::instance().sub_path(elog_factory::instance().get_root_path(), "log");
			std::string fileName = log_date_time + "-" + file_name_;
			destfileUtf = epfilesystem::instance().sub_path(destfileUtf, fileName);
#ifdef _WIN32
			std::wstring destfile = UTF2WS(destfileUtf);
#else
			std::string destfile = destfileUtf;
#endif

            if(!ofs_)
			{
#ifdef _WIN32
				ofs_.reset(new ofstream(destfile.c_str(), (append_mode_?ios::app:0) | ios::binary ));
#else
                if(append_mode_)
                {
                    ofs_.reset(new std::ofstream(destfile.c_str(),ios::app | ios::binary));
                }
                else
                {
                    ofs_.reset(new std::ofstream(destfile.c_str(),ios::binary));
                }                
                
#endif                
			}
			
			// 客户端 IM-2941 密码明文显示的修改
			std::wstring bingo = L"\"user_passwd\":\"";
			std::wstring winfo = txtutil::convert_utf8_to_wcs(info);
			std::wstring::size_type index = std::wstring::npos;
			std::wstring::size_type eindex= std::wstring::npos;
			index = winfo.find(bingo);
			do{
				if (index != std::wstring::npos)
				{
					eindex = winfo.find(L'\"', index + bingo.length());
					if (eindex != std::wstring::npos)
					{
						winfo.erase(index + bingo.length(), eindex-index-bingo.length());
					}

					index = winfo.find(bingo, eindex);
				}
			}while(index != std::wstring::npos);

			info = txtutil::convert_wcs_to_utf8(winfo);

			std::string version_num = elog_factory::instance().get_version_num();
			if (version_num !="")
			{
				 *ofs_ << "[" + time_str +"-"+ version_num +"]" + logLev << ":\t"<<info << endl;
			}
			else
			{
            *ofs_ << "[" + time_str + "]" + logLev << ":\t"<<info << endl;
			}
            ofs_.reset();
        }
    private:
        boost::shared_ptr<ofstream> ofs_;
        string file_name_;
        bool   append_mode_;
        boost::shared_ptr<elog_format> format_;
    };
 
    class elog_impl
    {
        friend class elog_factory_decl;
    public:
        elog_impl(){}

        void log(int nlv, std::string info, boost::posix_time::ptime time)
        {
            if(!elog_factory::instance().is_in_work_thread())
            {
                elog_factory::instance().post(boost::bind(&elog_impl::log,this,nlv,info, time));
                return;
            }
            if(log_filter_ && !log_filter_->is_valid(nlv))return;
            std::string lv = log_level[nlv];
            for_each(appenders_.begin(),appenders_.end(),boost::bind(&elog_appender::write,_1,lv,info, time));
        }
    private:
        vector<boost::shared_ptr<elog_appender> > appenders_; 
        boost::shared_ptr<elog_filter> log_filter_;
    };
    elog::elog():impl_(new elog_impl)
    {

    }

    void elog::debug( std::string info )
    {
        impl_->log(0, info, boost::posix_time::microsec_clock::local_time());
    }

    void elog::warn( std::string info )
    {
        impl_->log(1, info, boost::posix_time::microsec_clock::local_time());
    }

    void elog::error( std::string info )
    {
        impl_->log(2, info, boost::posix_time::microsec_clock::local_time());
    }

    void elog::fatal( std::string info )
    {
        impl_->log(3, info, boost::posix_time::microsec_clock::local_time());
    }

    elog_factory_decl::elog_factory_decl():impl_(new elog_factory_impl)
    {
		impl_->empty_log_.reset(new elog);
    }

    void elog_factory_decl::init()
    {
        boost::shared_ptr<elog> log_app = boost::make_shared<elog>();
        boost::shared_ptr<elog_appender> app_appender = boost::make_shared<elog_appender>("app_info.log");
        app_appender->set_append_mode(true);
        log_app->impl_->appenders_.push_back(app_appender);
        log_app->impl_->log_filter_.reset(new elog_filter(0));
        impl_->logs_["app"] = log_app;

        boost::shared_ptr<elog> log_json = boost::make_shared<elog>();
        boost::shared_ptr<elog_appender> json_appender = boost::make_shared<elog_appender>("json_info.log");
        json_appender->set_append_mode(true);
        log_json->impl_->appenders_.push_back(json_appender);
        log_json->impl_->appenders_.push_back(app_appender);

        impl_->logs_["log_json"] = log_json;

        boost::shared_ptr<elog> log_jstune = boost::make_shared<elog>();
        json_appender = boost::make_shared<elog_appender>("jstune.log");
        json_appender->set_append_mode(true);
        log_jstune->impl_->appenders_.push_back(json_appender);
        log_jstune->impl_->appenders_.push_back(app_appender);
        impl_->logs_["log_jstune"] = log_jstune;

        boost::shared_ptr<elog> log_network = boost::make_shared<elog>();
        json_appender = boost::make_shared<elog_appender>("network.log");
        json_appender->set_append_mode(true);
        log_network->impl_->appenders_.push_back(json_appender);
        log_network->impl_->appenders_.push_back(app_appender);
        impl_->logs_["log_network"] = log_network;
    }

    void elog_factory_decl::init( json::jobject jobj )
    {
		//查找过期日志并删除
		impl_->thread_worker.post(boost::bind(&elog_factory_impl::del_log_file, impl_));
		if(!jobj["appenders"] || !jobj["elogs"])return;
        std::map<std::string, boost::shared_ptr<elog_appender> > appenders;
        for(int i = 0;i<jobj["appenders"].arr_size();i++)
        {
            json::jobject tobj = jobj["appenders"][i];
            boost::shared_ptr<elog_appender> appender = boost::make_shared<elog_appender>(tobj["destination"].get<string>());
            appender->set_append_mode(tobj["append_mode"].get<bool>());
            appenders[tobj["name"].get<string>()] = appender;
        }
        for(int i = 0;i<jobj["elogs"].arr_size();i++)
        {
            json::jobject tobj = jobj["elogs"][i];
            boost::shared_ptr<elog> onelog = boost::make_shared<elog>();
            if(tobj["filter"])
            {
                onelog->impl_->log_filter_.reset(new elog_filter(tobj["filter"].get<int>()));
            }
            for(int j=0;j<tobj["log_appenders"].arr_size();j++)
            {
                onelog->impl_->appenders_.push_back(appenders[tobj["log_appenders"][j].get<string>()]);
            }
            impl_->logs_[tobj["name"].get<string>()] = onelog;
        }

    }

	void elog_factory_decl::set_root_path( std::string root_path )
	{
		if(!is_in_work_thread())
		{
			impl_->thread_worker.post(boost::bind(&elog_factory_decl::set_root_path,this,root_path));
			return;
		}
		impl_->root_path_ = root_path;
		std::string log_path = epfilesystem::instance().sub_path(root_path,"log");
		if(!epfilesystem::instance().file_exists(log_path))
		{
			epfilesystem::instance().create_directories(log_path);
		}
	}

	std::string elog_factory_decl::get_root_path()
	{
		return impl_->root_path_;
	}

	bool elog_factory_decl::is_in_work_thread()
	{
		return impl_->thread_worker.is_in_work_thread();
	}

	void elog_factory_decl::post( boost::function<void()> cmd )
	{
		impl_->thread_worker.post(cmd);
	}
	void elog_factory_decl::set_version_num( std::string version_num )
	{
		impl_->version_num = version_num;
	}

	std::string elog_factory_decl::get_version_num()
	{
		return impl_->version_num;
	}

	void elog_factory_decl::stop()
	{
		impl_->thread_worker.stop();
	}

    boost::shared_ptr<elog> epius::elog_factory_decl::get_elog( std::string elogName )
    {
        if(impl_->logs_.find(elogName)!=impl_->logs_.end())
		{
			return impl_->logs_[elogName];
		}
		else
		{
			return impl_->empty_log_;
		}
    }

}//namespace epius
