#include "organization.h"
#include "boost/tuple/tuple.hpp"
#include "base/tcpproactor/TcpProactor.h"
#include "gloox_src/gloox.h"
#include "anan_biz_impl.h"
#include "gloox_src/iq.h"
#include "organization_impl.h"
#include "client_anan.h"
#include "iq_filter.h"
#include "login.h"
#include "local_config.h"
#include "common.h"
#include "boost/filesystem/operations.hpp"
#include "base/txtutil/txtutil.h"
#include "base/module_path/file_manager.h"
#include "biz_app_settings.h"
#include "whistle_vcard.h"
#include "an_roster_manager.h"
#include "gloox_wrap/glooxWrapInterface.h"
#include "base/http_trans/http_request.h"
#include "anan_config.h"
namespace biz
{
	using namespace gloox;
	static const std::string org_serials_storage = "biz.organization._StateChanged.org_tree";
	static const char* const query_types[] = { "user", "organization", "all", NULL };

	organization::organization(void) : impl_(new organization_impl())
	{
	}

	organization::~organization(void)
	{
	}

	query_organization::KOrg_query_type organization::paser_type( std::string content_type )
	{
		int idx = 0;

		while(query_types[idx] && query_types[idx] != content_type) idx++;

		assert(idx < query_organization::korg_query_all);
		return (query_organization::KOrg_query_type)(idx+1);
	}

	void organization::get_notice_tree(	std::string parent_id,	JsonCallback callback)
	{
		IN_TASK_THREAD_WORKx( organization::get_notice_tree, parent_id, /*content_type,*/ callback);

		std::string content_type = "all";
		query_organization::KOrg_query_type qt = paser_type(content_type), qt1 = qt;
		if ((qt & query_organization::korg_query_user) && impl_->m_store_org[TREE_TYPE_NOTICE][parent_id]["user"])
		{
			qt = (query_organization::KOrg_query_type)(qt&~query_organization::korg_query_user);
		}
		if ((qt & query_organization::korg_query_organization) && impl_->m_store_org[TREE_TYPE_NOTICE][parent_id]["organization"])
		{
			qt = (query_organization::KOrg_query_type)(qt&~query_organization::korg_query_organization);
		}
		if (query_organization::korg_none == qt) 
		{
			notice_result(json::jobject(), TREE_TYPE_NOTICE, parent_id, qt1, callback);
			return;
		}

		qt1 = qt = query_organization::korg_query_all;

		// timestamp
		std::string timestamp;
		if (impl_->m_store_org[TREE_TYPE_NOTICE][parent_id]["timestamp"])
		{
			timestamp = impl_->m_store_org[TREE_TYPE_NOTICE][parent_id]["timestamp"].get<std::string>();
		}
		else
		{
			timestamp = "";
		}
		query_organization query(qt, parent_id, XMLNS_NOTICE, timestamp);
		query.send(app_settings::instance().get_domain(), this, ++impl_->autoinc_context_);
		impl_->callback_.insert(std::make_pair(impl_->autoinc_context_, boost::make_tuple(TREE_TYPE_NOTICE,timestamp,qt1,parent_id,callback)));
	}

	void organization::get_sub_tree(std::string parent_id,JsonCallback callback)
	{
		IN_TASK_THREAD_WORKx( organization::get_sub_tree, parent_id, callback);

		//从本地数据库中查找
		if (impl_->m_store_org[TREE_TYPE_ORG][parent_id])
		{
			json::jobject data = get_parent_impl()->bizLocalConfig_->loadOrganizationData( boost::lexical_cast<int>(parent_id));
			if (data != json::jobject())
			{
				get_user_head(data["user"]);
				impl_->m_store_org[TREE_TYPE_ORG][parent_id] = data;
			}
		}

	query_organization::KOrg_query_type qt , qt1 ;
	qt1 = qt = query_organization::korg_query_all;
	// timestamp
	std::string timestamp;
	if (impl_->m_store_org[TREE_TYPE_ORG][parent_id]["timestamp"])
	{
		timestamp = impl_->m_store_org[TREE_TYPE_ORG][parent_id]["timestamp"].get<std::string>();
	}
	else
	{
		timestamp = "";
	}
	query_organization query(qt, parent_id, XMLNS_ORG, timestamp);
	query.send(app_settings::instance().get_domain(), this, ++impl_->autoinc_context_);
	impl_->callback_.insert(std::make_pair(impl_->autoinc_context_, boost::make_tuple(TREE_TYPE_ORG,timestamp,qt1,parent_id,callback)));
}

	void organization::regist_to_gloox( AnClient* p_client )
	{
		p_client->registerStanzaExtension(new query_organization());
		get_parent_impl()->bizLogin_->conn_msm_.disconnected_signal_.connect(boost::bind(&organization::disconting, this, _1));	
	}

	void organization::unregist_to_gloox( AnClient* p_client )
	{
		get_parent_impl()->bizLogin_->conn_msm_.disconnected_signal_.disconnect(&organization::disconting);	
	}

#define apply_field(obj, tag, sour_field, dest_field) \
	do if (Tag* sub_tag = (tag)->findChild((sour_field))) \
	(obj)[(dest_field)] = sub_tag->cdata(); while(0)


json::jobject organization::recv_organization( std::string tree_type, std::string timestamp, std::string parent_id, query_organization* query_org, query_organization::KOrg_query_type type)
{
	json::jobject self = json::jobject();
	boost::shared_ptr<Tag> ptag(query_org->tag());
	if (!impl_->m_store_org[tree_type][parent_id])
	{
		impl_->m_store_org[tree_type][parent_id] = json::jobject();
	}
	// timestamp
	std::string new_timestamp;
	ConstTagList ptag_list = ptag->findTagList("/query");
	ConstTagList::iterator it = ptag_list.begin();
	if ( it != ptag_list.end())
	{
		new_timestamp = ptag->findAttribute("timestamp");
	} 
	else 
	{
		assert(false);
		return self;
	}
	int iuser = 0;
	int iorg = 0;
	json::jobject juser, jorg;

		std::string domain_with_at_ = "@" + app_settings::instance().get_domain();
		ptag_list = ptag->findTagList("//item");
		for (ConstTagList::iterator it = ptag_list.begin(); it != ptag_list.end(); ++it)
		{
			std::string item_type = (*it)->findAttribute("type");
			switch(paser_type(item_type))
			{
			default:
				assert(false);
				break;
			case query_organization::korg_query_organization:
				{
					std::string tag_parent_id, tag_count, tag_name, tag_id;
					if (Tag* sub_tag = (*it)->findChild("parent"))
					{
						tag_parent_id = sub_tag->cdata();
					}
					if (Tag* sub_tag = (*it)->findChild("user_count"))
					{
						tag_count = sub_tag->cdata();
					}
					if (Tag* sub_tag = (*it)->findChild("name"))
					{
						tag_name = sub_tag->cdata();
					}
					if (Tag* sub_tag = (*it)->findChild("id"))
					{
						tag_id = sub_tag->cdata();
					}
					// 根节点返回的0不处理
					if (tag_id == "0")
					{
						break;
					}

					if ( parent_id!= "0" && tag_id == parent_id)
					{
						// 更新请求的节点信息(父节点和根节点更新)
						if (tree_type == TREE_TYPE_ORG)
						{
							int index;
							bool found = false;
							for (index = 0; index < impl_->m_store_org[tree_type][tag_parent_id]["organization"].arr_size(); index++)
							{
								if (impl_->m_store_org[tree_type][tag_parent_id]["organization"][index]["id"].get<std::string>() ==  tag_id)
								{
									found = true;
									impl_->m_store_org[tree_type][tag_parent_id]["organization"][index]["name"] = tag_name;
									impl_->m_store_org[tree_type][tag_parent_id]["organization"][index]["user_count"] = tag_count;

									self["id"] = tag_id;
									self["name"] = tag_name;
									self["user_count"] = tag_count;
								}
							}

							if (found)
							{
								//保存组织树
								get_parent_impl()->bizLocalConfig_->saveOrganizationData(boost::lexical_cast<int>(tag_parent_id), impl_->m_store_org[tree_type][tag_parent_id], impl_->m_store_org[tree_type][tag_parent_id]["timestamp"].get<std::string>());
							}

							found = false;
							for (index = 0; index < impl_->m_store_org[tree_type]["0"]["organization"].arr_size(); index++)
							{
								if (impl_->m_store_org[tree_type]["0"]["organization"][index]["id"].get<std::string>() ==  parent_id)
								{
									found = true;
									impl_->m_store_org[tree_type]["0"]["organization"][index]["name"] = tag_name;
									impl_->m_store_org[tree_type]["0"]["organization"][index]["user_count"] = tag_count;

									self["id"] = tag_id;
									self["name"] = tag_name;
									self["user_count"] = tag_count;
								}
							}

							if (found)
							{
								//保存组织树
								get_parent_impl()->bizLocalConfig_->saveOrganizationData(0, impl_->m_store_org[tree_type]["0"],	impl_->m_store_org[tree_type]["0"]["timestamp"].get<std::string>());
							}
						}
						break;
					}

					apply_field(jorg[iorg], *it, "id",     "id");
					apply_field(jorg[iorg], *it, "parent", "parent_id");
					apply_field(jorg[iorg], *it, "user_count", "user_count");
					apply_field(jorg[iorg], *it, "name",   "name");

					// 根节点获取后，试图更新子节点
					if ( parent_id == "0" && tag_parent_id!= "1")
					{
						// 更新请求的节点信息(父节点和根节点更新)
						if (tree_type == TREE_TYPE_ORG && impl_->m_store_org[tree_type][tag_parent_id])
						{
							int index;
							bool found = false;
							for (index = 0; index < impl_->m_store_org[tree_type][tag_parent_id]["organization"].arr_size(); index++)
							{
								if (impl_->m_store_org[tree_type][tag_parent_id]["organization"][index]["id"].get<std::string>() ==  tag_id)
								{
									found = true;
									impl_->m_store_org[tree_type][tag_parent_id]["organization"][index]["name"] = tag_name;
									impl_->m_store_org[tree_type][tag_parent_id]["organization"][index]["user_count"] = tag_count;
								}
							}
							if (found)
							{
								//保存组织树
								get_parent_impl()->bizLocalConfig_->saveOrganizationData(boost::lexical_cast<int>(tag_parent_id),
									impl_->m_store_org[tree_type][tag_parent_id], impl_->m_store_org[tree_type][tag_parent_id]["timestamp"].get<std::string>());
							}
						}
					}

					//该组织结构的权限，单击能否打开子节点
					if (tree_type == TREE_TYPE_NOTICE)
					{
						if ((*it)->findAttribute("all").compare("true") == 0)
						{
							jorg[iorg]["all"] = true;
						}
						else
						{
							jorg[iorg]["all"] = false;
						}
					}
					++iorg;			
					break;
				}
			case query_organization::korg_query_user:
				apply_field(juser[iuser], *it, "name", "name");
				apply_field(juser[iuser], *it, "sex", "sex");
				apply_field(juser[iuser], *it, "username", "jid");
				apply_field(juser[iuser], *it, "identity", "identity");
				apply_field(juser[iuser], *it, "mood_words", "mood_words");
				apply_field(juser[iuser], *it, "photo_credential", "photo_credential");
				apply_field(juser[iuser], *it, "photo_live", "photo_live");
				apply_field(juser[iuser], *it, "sort_string", "sort_string");
				juser[iuser]["jid"] = juser[iuser]["jid"].get<std::string>() + domain_with_at_;
				KContactType ct = get_parent_impl()->bizRoster_->is_my_friend_(juser[iuser]["jid"].get<std::string>());
				if (ct!= kctSelf && ct == kctContact)
				{
					juser[iuser]["is_my_friend"] = true;
				}
				else
				{
					juser[iuser]["is_my_friend"] = false;
				}
				// 性别和身份 需要转译
				juser[iuser]["sex_show"] = XL(juser[iuser]["sex"].get<std::string>()).res_value_utf8;
				juser[iuser]["identity_show"] = XL(juser[iuser]["identity"].get<std::string>()).res_value_utf8;

				std::string uri_string = juser[iuser][s_VcardHeadURI].get<std::string>();
				std::string local_string;
				juser[iuser][s_VcardHead] = "";
				if(!uri_string.empty())
				{
					local_string = biz::file_manager::instance().from_uri_to_valid_path(uri_string);
					if (local_string.empty())
					{
						syncdown_head_image(juser[iuser], s_VcardHead, uri_string);
					}
					else
					{
						juser[iuser][s_VcardHead] = local_string;
					}
				}
				uri_string = juser[iuser][s_VcardLivePhotoURI].get<std::string>();
				juser[iuser][s_VcardLivePhoto] = "";
				if(!uri_string.empty())
				{
					local_string = biz::file_manager::instance().from_uri_to_valid_path(uri_string);
					if (local_string.empty())
					{
						syncdown_head_image(juser[iuser], s_VcardLivePhoto, uri_string);
					}
					else
					{
						juser[iuser][s_VcardLivePhoto] = local_string;
					}
				}			
				++iuser;
				break;
			}
		}

		//因为时间戳的缘故，服务器可能返回空，也可能返回值。
		//如果服务器返回值，那么需要更新本地数据，更新的依据就是查询类型。
		if(impl_->m_store_org[tree_type][parent_id]["timestamp"].get<std::string>() != new_timestamp)
		{
			if(type & query_organization::korg_query_user )
			{
				impl_->m_store_org[tree_type][parent_id]["user"] = juser;
			}
			if(type & query_organization::korg_query_organization)
			{
				impl_->m_store_org[tree_type][parent_id]["organization"] = jorg;
			}

			if (tree_type == TREE_TYPE_ORG)
			{
				get_parent_impl()->bizLocalConfig_->saveOrganizationData(boost::lexical_cast<int>(parent_id), impl_->m_store_org[tree_type][parent_id], new_timestamp);
			}
		}
		else
		{
			// 更新好友
			bool needstore = false;
			for(int i=0; i< impl_->m_store_org[tree_type][parent_id]["user"].arr_size(); i++)
			{
				KContactType ct = get_parent_impl()->bizRoster_->is_my_friend_(impl_->m_store_org[tree_type][parent_id]["user"][i]["jid"].get<std::string>());
				if (ct!= kctSelf && ct == kctContact)
				{
					if (impl_->m_store_org[tree_type][parent_id]["user"][i]["is_my_friend"].get<bool>() == false)
					{
						impl_->m_store_org[tree_type][parent_id]["user"][i]["is_my_friend"] = true;
						needstore = true;
					}
				}
				else
				{
					if (impl_->m_store_org[tree_type][parent_id]["user"][i]["is_my_friend"].get<bool>() == true)
					{
						impl_->m_store_org[tree_type][parent_id]["user"][i]["is_my_friend"] = false;
						needstore = true;
					}
				}
			}
			if (needstore)
			{
				get_parent_impl()->bizLocalConfig_->saveOrganizationData(boost::lexical_cast<int>(parent_id), impl_->m_store_org[tree_type][parent_id], new_timestamp);
			}
		}
		impl_->m_store_org[tree_type][parent_id]["timestamp"] = new_timestamp;
		return self;
	}
	
	void organization::syncdown_head_image(json::jobject jobj, std::string field_name, std::string uri_string)
	{
		if (uri_string.empty())
		{
			return;
		}
		boost::function<void(bool,std::string)> callback = boost::bind(&organization::finished_syncdown_image, this, jobj, field_name, _1, _2);
		std::string download_path = file_manager::instance().from_uri_to_path(uri_string);
		epius::http_requests::instance().download(anan_config::instance().get_http_down_path(), download_path, uri_string, "", boost::function<void(int)>(), callback);
	}

	void organization::finished_syncdown_image(json::jobject jobj,std::string field_name,bool succ,std::string uri_string)
	{
		IN_TASK_THREAD_WORKx(organization::finished_syncdown_image, jobj, field_name, succ, uri_string);

		if (succ)
		{
			std::string local_path = file_manager::instance().from_uri_to_path(uri_string);
			json::jobject update_jobj;
			update_jobj["jid"] = jobj["jid"].get<std::string>();
			update_jobj[field_name] = local_path;
			event_collect::instance().update_head(update_jobj);
		}
		else
		{
			json::jobject update_jobj;
			update_jobj["jid"] = jobj["jid"].get<std::string>();
			update_jobj["sex_show"] = jobj["sex_show"].get<std::string>();
			update_jobj["identity_show"] = jobj["identity_show"].get<std::string>();
			update_jobj[field_name] = "";
			event_collect::instance().update_head(update_jobj);
		}
	}

	void organization::notice_result(json::jobject self, std::string tree_type, std::string parent_id, query_organization::KOrg_query_type type, JsonCallback callback)
	{
		if (callback.empty())
		{
			return;
		}
		switch(type)
		{
		default:
			assert(false);
			break;
		case query_organization::korg_none:
			callback(json::jobject());
			break;
		case query_organization::korg_query_organization:
			{
				json::jobject jobj;
				assert(impl_->m_store_org[tree_type][parent_id]["organization"]);
				jobj["organization"] = impl_->m_store_org[tree_type][parent_id]["organization"].clone();
				callback(jobj);
			}
			break;
		case query_organization::korg_query_user:
			{
				json::jobject jobj;
				assert(impl_->m_store_org[tree_type][parent_id]["user"]);
				jobj["user"] = impl_->m_store_org[tree_type][parent_id]["user"].clone();
				callback(jobj);
			}
			break;
		case query_organization::korg_query_all:
			{
				json::jobject jobj = impl_->m_store_org[tree_type][parent_id].clone();
				if (self != json::jobject())
				{
					jobj["self"] = self;
				}
				callback(jobj);
			}
			break;
		}
	}

	bool organization::handleIq( const IQ& iq )
	{
		return true;
	}

	void organization::handleIqID( const IQ& iq, int context )
	{
		OrgMapJsonCallback::iterator it = impl_->callback_.find(context);

		if(it != impl_->callback_.end())
		{
			if (iq.subtype() == IQ::Result)
			{
				if (query_organization* qo = (query_organization*)iq.findExtension(kExtUser_iq_filter_tree)) 
				{
					query_organization::KOrg_query_type type = it->second.get<kot_query_type>();
					std::string tree_type = it->second.get<kot_tree_type>();
					std::string parent_id = it->second.get<kot_parent_id>();
					json::jobject self = recv_organization(tree_type, it->second.get<kot_timestamp>(), parent_id, qo, type);
					notice_result(self, tree_type, parent_id, type, it->second.get<kot_callback>());
				} 
				else
				{
					notice_result(json::jobject(), it->second.get<kot_tree_type>(), "", query_organization::korg_none, it->second.get<kot_callback>());
				}
			} 
			else 
			{
				notice_result(json::jobject(), it->second.get<kot_tree_type>(), "", query_organization::korg_none, it->second.get<kot_callback>());
			}
			impl_->callback_.erase(it);
		}
	}

	void organization::disconting(universal_resource res)
	{
		impl_->m_store_org = json::jobject();
	}

	void organization::organization_search( std::string name, boost::function<void(bool, universal_resource, json::jobject)> callback )
	{
		IN_TASK_THREAD_WORKx( organization::organization_search, name, callback);

		gWrapInterface::instance().organization_search(name, bind2f(&organization::organization_search_cb, this, _1, _2, _3, callback));
	}

	void organization::organization_search_cb( bool err, universal_resource reason, json::jobject data, boost::function<void(bool, universal_resource, json::jobject)> callback )
	{
		if (data.arr_size())
		{
			data.each(bind2f(&organization::update_search_result, this, _1));
		}

		callback(err, reason, data);
	}

	void organization::update_search_result( json::jobject jobj )
	{
		jobj["sex_show"] = XL(jobj["sex"].get<std::string>()).res_value_utf8;
		jobj["identity_show"] = XL(jobj["identity"].get<std::string>()).res_value_utf8;

		std::string uri_string = jobj[s_VcardHeadURI].get<std::string>();
		std::string local_string;
		jobj[s_VcardHead] = "";
		if(!uri_string.empty())
		{
			local_string = biz::file_manager::instance().from_uri_to_valid_path(uri_string);
			if (local_string.empty())
			{
				syncdown_head_image(jobj, s_VcardHead, uri_string);
			}
			else
			{
				jobj[s_VcardHead] = local_string;
			}
		}
		uri_string = jobj[s_VcardLivePhotoURI].get<std::string>();
		jobj[s_VcardLivePhoto] = "";
		if(!uri_string.empty())
		{
			local_string = biz::file_manager::instance().from_uri_to_valid_path(uri_string);
			if (local_string.empty())
			{
				syncdown_head_image(jobj, s_VcardLivePhoto, uri_string);
			}
			else
			{
				jobj[s_VcardLivePhoto] = local_string;
			}
		}
	}

	void organization::get_user_head( json::jobject userjobj )
	{
		for(int i=0; i< userjobj.arr_size(); i++)
		{
			std::string photo_credential , head_local;
			photo_credential=userjobj[i]["photo_credential"].get<std::string>();
			if ( !photo_credential.empty())
			{
				head_local = biz::file_manager::instance().from_uri_to_valid_path(photo_credential);
				if (head_local.empty())
				{
					userjobj[i][s_VcardHead] = "";
					syncdown_head_image(userjobj[i], s_VcardHead, photo_credential);
				}
				else
				{
					userjobj[i][s_VcardHead] = head_local;
				}
			}
		}
	}	

	void organization::is_show_organization( boost::function<void(bool,universal_resource,json::jobject)> callback )
	{
		IN_TASK_THREAD_WORKx( organization::is_show_organization, callback);
		std::string to_jid = "permission." + app_settings::instance().get_domain();
		gWrapInterface::instance().is_show_organization(to_jid,callback);
	}

}; // namespace biz