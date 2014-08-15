#pragma once
#include "anan_biz_bind.h"
#include "boost/function.hpp"
#include "boost/shared_ptr.hpp"
#include "base/json/tinyjson.hpp"
#include "anan_type.h"
#include <string>
#include "iq_filter.h"
#include "gloox_src/iqhandler.h"
#include "event_collection.h"

namespace biz
{

struct anan_biz_impl;
struct organization_impl;

class AnClient;
class organization : public anan_biz_bind<anan_biz_impl> , public IqHandler
{
	BIZ_FRIEND();
public:
	organization(void);
	virtual ~organization(void);

public:
	void get_sub_tree(	std::string parent_id,JsonCallback callback);
	void get_user_head(	json::jobject userjobj);

	void get_notice_tree( std::string parent_id, JsonCallback callback);
	void organization_search( std::string name, boost::function<void(bool, universal_resource, json::jobject)> callback);
	void organization_search_cb( bool err, universal_resource reason, json::jobject data, boost::function<void(bool, universal_resource, json::jobject)> callback);
	void update_search_result(json::jobject jobj);
	void is_show_organization( boost::function<void(bool,universal_resource,json::jobject)> callback );
	
protected: // IqHandler
      virtual bool handleIq( const IQ& iq );
      virtual void handleIqID( const IQ& iq, int context );

protected:
	void disconting(universal_resource res);
	void regist_to_gloox( AnClient* p_client );
	void unregist_to_gloox( AnClient* p_client );

protected:
	query_organization::KOrg_query_type paser_type( std::string content_type );
	json::jobject recv_organization(std::string tree_type, std::string timestamp, std::string parent_id, query_organization* query_org, query_organization::KOrg_query_type type);
	void notice_result(json::jobject self, std::string tree_type, std::string parent_id, query_organization::KOrg_query_type type, JsonCallback callback);
	void finished_syncdown_image(json::jobject jobj, std::string field_name,bool succ,std::string uri_string);
	void syncdown_head_image(json::jobject jobj, std::string field_name, std::string uri_string);
private:
	boost::shared_ptr<organization_impl> impl_;
};

}; // namespace biz