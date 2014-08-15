#include <base/tcpproactor/TcpProactor.h>
#include <boost/filesystem.hpp>
#include <base/txtutil/txtutil.h>
#include <base/epiusdb/ep_sqlite.h>
#include <gloox_src/privatexmlhandler.h>
#include <gloox_src/tag.h>
#include "anan_private.h"
#include "anan_biz_impl.h"
#include "local_config.h"
#include "user.h"
#include "anan_biz_bind.h"
#include "base/module_path/file_manager.h"
#include "base/module_path/epfilesystem.h"
#include "base/http_trans/http_request.h"
#include "anan_config.h"
using namespace biz;
using namespace std;
using namespace boost;
using namespace epius::epius_sqlite3;
namespace biz
{
    class anan_private_impl
    {
		friend class anan_private;
    public:
        anan_private_impl(){}
        void download_uri_callback(bool bsuccess, std::string local_path, boost::function<void(bool err, universal_resource res, std::string local_path)> callback);
        boost::shared_ptr<epDb> dbimpl_; 
	protected:
		anan_private *parent_;
    };

    void anan_private_impl::download_uri_callback( bool bsuccess, std::string local_path, boost::function<void(bool err, universal_resource res, std::string local_path)> callback )
    {
		if (!parent_->get_parent_impl()->_p_private_task_->is_in_work_thread()) {
			parent_->get_parent_impl()->_p_private_task_->post(boost::bind(&anan_private_impl::download_uri_callback, this, bsuccess, local_path, callback));
			return;
		}

        if(bsuccess)
        {
            callback(false,XL(""),local_path);
        }
        else
        {
            callback(false,XL("biz.private.failed_to_download_uri"),"");
        }
    }

    class anan_private_callback:public gloox::PrivateXMLHandler
    {
    public:
        anan_private_callback(){}
        anan_private_callback(boost::function<void(bool)> cmd):m_setCallback(cmd){}
        anan_private_callback(boost::function<void(string)> cmd):m_getCallback(cmd){}
        anan_private_callback(boost::function<void(json::jobject)> cmd):m_getJsonCallback(cmd){}
        virtual void handlePrivateXML( const std::string& uid, const gloox::Tag* xml );
        virtual void handlePrivateXMLResult( const std::string& uid, gloox::PrivateXMLHandler::PrivateXMLResult pxResult );
        virtual void Destroy();
    private:
        boost::function<void(bool)> m_setCallback;
        boost::function<void(string)> m_getCallback;
        boost::function<void(json::jobject)> m_getJsonCallback;
    };

    void anan_private_callback::handlePrivateXML( const std::string& uid, const gloox::Tag* xml )
    {
        if(!m_getCallback.empty())
        {
            Tag* pTag = xml->findChild("pdata");
            if(pTag)m_getCallback(pTag->findCData("pdata"));
            else m_getCallback("");
        }
        if(!m_getJsonCallback.empty())
        {
            Tag* pTag = xml->findChild("pdata");
            if(pTag)m_getJsonCallback(json::jobject(pTag->findCData("pdata")));
            else m_getJsonCallback(json::jobject());
        }
    }

    void anan_private_callback::handlePrivateXMLResult( const std::string& uid, gloox::PrivateXMLHandler::PrivateXMLResult pxResult )
    {
        if(!m_setCallback.empty())
        {
            if(pxResult == PxmlStoreOk)m_setCallback(true);
            else m_setCallback(false);
        }
    }

    void anan_private_callback::Destroy()
    {
        delete this;
    }

}

void anan_private::store_data( std::string key,json::jobject jobj, boost::function<void(bool)> callback )
{
	if (!get_parent_impl()->_p_private_task_->is_in_work_thread())
	{
		get_parent_impl()->_p_private_task_->post(boost::bind((void (anan_private::*)(std::string,json::jobject jobj, boost::function<void(bool)>))(&anan_private::store_data), this, key, jobj, callback));
		return;
	}
	get_parent_impl()->bizUser_->store_data(key,jobj.to_string(),new anan_private_callback(callback));
}

void biz::anan_private::store_data( std::string key,std::string str, boost::function<void(bool)> callback )
{
	if (!get_parent_impl()->_p_private_task_->is_in_work_thread())
	{
		get_parent_impl()->_p_private_task_->post(boost::bind((void (anan_private::*)(std::string,std::string, boost::function<void(bool)>))(&anan_private::store_data), this, key, str, callback));
		return;
	}
	get_parent_impl()->bizUser_->store_data(key,str,new anan_private_callback(callback));
}

void anan_private::get_data( std::string private_ns,boost::function<void(std::string)>callback )
{
	if (!get_parent_impl()->_p_private_task_->is_in_work_thread())
	{
		get_parent_impl()->_p_private_task_->post(boost::bind((void (anan_private::*)(std::string, boost::function<void(std::string)>))(&anan_private::get_data), this, private_ns, callback));
		return;
	}

	get_parent_impl()->bizUser_->get_data(private_ns,new anan_private_callback(callback));
}

void anan_private::get_data( std::string private_ns,boost::function<void(json::jobject)>callback )
{
	if (!get_parent_impl()->_p_private_task_->is_in_work_thread())
	{
		get_parent_impl()->_p_private_task_->post(boost::bind((void (anan_private::*)(std::string, boost::function<void(json::jobject)>))(&anan_private::get_data), this, private_ns, callback));
		return;
	}
	get_parent_impl()->bizUser_->get_data(private_ns,new anan_private_callback(callback));
}

biz::anan_private::anan_private():anan_impl_(new anan_private_impl)
{
	anan_impl_->parent_ = this;
}

void biz::anan_private::store_global_data( std::string key,std::string data_str, boost::function<void(bool err, universal_resource res)> callback )
{
	IN_TASK_THREAD_WORKx(biz::anan_private::store_global_data, key, data_str, callback);

	get_parent_impl()->bizLocalConfig_->saveGlobalData(key,data_str);
	if(!callback.empty()) callback(false,XL(""));
}

void biz::anan_private::get_global_data( std::string key, boost::function<void(bool,universal_resource res, std::string data_str)> callback )
{
	IN_TASK_THREAD_WORKx(biz::anan_private::get_global_data, key, callback);

	std::string tmp = get_parent_impl()->bizLocalConfig_->loadGlobalData(key);
	if (key == "showNameSelect" && tmp.empty())
	{
		// 默认为按照备注显示
		tmp = "remark_name";
	}
	if(!callback.empty()) callback(false, XL(""), tmp);
}

void biz::anan_private::store_local_data( std::string key,std::string data_str, boost::function<void(bool err, universal_resource res)> callback )
{
	IN_TASK_THREAD_WORKx(biz::anan_private::store_local_data, key, data_str, callback);

	get_parent_impl()->bizLocalConfig_->saveData(key,data_str);
    if(!callback.empty()) callback(false,XL(""));
}
void biz::anan_private::delete_local_data( std::string key , boost::function<void(bool err, universal_resource res)> callback )
{
	IN_TASK_THREAD_WORKx(biz::anan_private::delete_local_data, key , callback);

	get_parent_impl()->bizLocalConfig_->deleteData(key);
	if(!callback.empty()) callback(false,XL(""));
}
void biz::anan_private::get_local_data( std::string key, boost::function<void(bool,universal_resource res, std::string data_str)> callback )
{
	IN_TASK_THREAD_WORKx(biz::anan_private::get_local_data, key, callback);

	std::string tmp = get_parent_impl()->bizLocalConfig_->loadData(key);
    if(!callback.empty()) callback(false, XL(""), tmp);
}

void biz::anan_private::download_uri( std::string uri,boost::function<void(bool err, universal_resource res, std::string local_path)> callback )
{
    std::string uri_file_str = file_manager::instance().from_uri_to_path(uri);
    bool is_need = !epius::epfilesystem::instance().file_exists(uri_file_str);
    if(!is_need)
    {
        callback(false,XL(""),uri_file_str);
    }
    else
    {
		epius::http_requests::instance().download(anan_config::instance().get_http_down_path(), uri_file_str, uri, "", boost::function<void(int)>(), boost::bind(&biz::anan_private_impl::download_uri_callback,anan_impl_,_1, uri_file_str,callback));
    }
}

void biz::anan_private::upload( std::string local_file, boost::function<void(bool /*succ*/, std::string)> callback )
{
	IN_TASK_THREAD_WORKx(biz::anan_private::upload, local_file, callback);
	epius::http_requests::instance().upload(anan_config::instance().get_http_upload_path(), local_file, "", "", boost::function<void(int)>(), callback);
}

