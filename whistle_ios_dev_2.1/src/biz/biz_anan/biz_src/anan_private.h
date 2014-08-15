#pragma once
#include <boost/function.hpp>
#include <boost/shared_ptr.hpp>
#include <base/json/tinyjson.hpp>
#include <base/universal_res/uni_res.h>
#include "anan_biz_bind.h"
#include "anan_type.h"

namespace biz{
    class anan_private_impl;
    struct anan_biz_impl;
    class anan_private: public anan_biz_bind<anan_biz_impl>
    {
        BIZ_FRIEND();
    public:
        anan_private();
        void upload( std::string local_file, boost::function<void(bool success, std::string uri)> callback );
        void download_uri(std::string uri,boost::function<void(bool err, universal_resource res, std::string local_path)> callback);
		void store_global_data(std::string key, std::string data_str, boost::function<void(bool err, universal_resource res)> callback);
		void get_global_data(std::string key, boost::function<void(bool,universal_resource res, std::string data_str)> callback);
        void store_local_data(std::string key, std::string data_str, boost::function<void(bool err, universal_resource res)> callback);
		void delete_local_data( std::string key , boost::function<void(bool err, universal_resource res)> callback );        
		void get_local_data(std::string key, boost::function<void(bool,universal_resource res, std::string data_str)> callback);
        void store_data(std::string key,json::jobject jobj, boost::function<void(bool err)> callback);
        void store_data(std::string key,std::string str, boost::function<void(bool err)> callback);
        void get_data(std::string private_ns,boost::function<void(std::string)>callback);
        void get_data( std::string private_ns,boost::function<void(json::jobject)>callback );
    private:
        boost::shared_ptr<anan_private_impl> anan_impl_;
    };
}
