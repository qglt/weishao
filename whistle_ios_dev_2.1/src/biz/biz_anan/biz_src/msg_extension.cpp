#include "msg_extension.h"
#include "organization.h"
#include "anan_biz_impl.h"
#include "notice_msg.h"
#include "client_anan.h"
#include "gloox_src/tag.h"
#include "common.h"
#include "anan_config.h"

namespace biz 
{
	msg_ext_notification::msg_ext_notification(void) : StanzaExtension( kExtUser_iq_filter_noticemsg ), m_p_inner_tag(NULL)
	{

	}

	msg_ext_notification::msg_ext_notification(const Tag* tag) : StanzaExtension( kExtUser_iq_filter_noticemsg )
	{
		m_p_inner_tag = tag->clone();
	}

	msg_ext_notification::~msg_ext_notification(void)
	{
		if (m_p_inner_tag)
		{
			delete m_p_inner_tag;
		}
	}

	const std::string& msg_ext_notification::filterString() const
	{
		static const std::string filter = "/message[@from='notification." + anan_config::instance().get_domain() +  "']";
		return filter;
	}

	StanzaExtension* msg_ext_notification::newInstance( const Tag* tag ) const
	{
		return new msg_ext_notification( tag );
	}

	Tag* msg_ext_notification::tag() const
	{
		return m_p_inner_tag->clone();
	}

	StanzaExtension* msg_ext_notification::clone() const
	{
		return newInstance(m_p_inner_tag);
	}

	const Tag& msg_ext_notification::reftag() const
	{
		return *m_p_inner_tag;
	}





	//-----------------
	// iq_ext_notice
	//-----------------

	const std::string iq_ext_notice::NOTICE_MSG_DOMAIN = "notification.";
	const std::string iq_ext_notice::QUERY_NODE = "query";
	const std::string iq_ext_notice::NAME_ATTR = "name";
	const std::string iq_ext_notice::ADDRESS_NODE = "addresses";
	const std::string iq_ext_notice::NOTICE_NODE = "notification";

	iq_ext_notice::iq_ext_notice( const Tag* tag )
		: StanzaExtension( kExtUser_iq_filter_notice )
		, m_p_inner_tag(NULL)
		, m_state(kqnm_unknown)
	{
		assert(tag);
		if (tag->name() == QUERY_NODE)
		{
			m_p_inner_tag = tag->clone();
		} 
		else if (tag->name() == "iq") 
		{
			if (Tag* child_tag = tag->findChild(QUERY_NODE, XMLNS, XMLNS_ORG))
			{
				m_p_inner_tag = child_tag->clone();
				m_state = kqnm_publish;
			} 
			else if (Tag* child_tag = tag->findChild(NOTICE_NODE, XMLNS, XMLNS_NOTICE)) 
			{
				m_p_inner_tag = child_tag->clone();
				m_state = kqnm_pingpong;
			}
		}
		else if (tag->name() == "id")
		{
			m_p_inner_tag = tag->clone();
		}
	}

	iq_ext_notice::iq_ext_notice( json::jobject jobj ) : StanzaExtension( kExtUser_iq_filter_notice ), m_state(kqnm_publish)
	{
		m_p_inner_tag = new Tag(QUERY_NODE, XMLNS, "http://ruijie.com.cn/notification");
		add_notification(*m_p_inner_tag, jobj);
		add_addresses(*m_p_inner_tag, jobj);
	}

	iq_ext_notice::iq_ext_notice() : StanzaExtension( kExtUser_iq_filter_notice ) , m_p_inner_tag(NULL), m_state(kqnm_unknown)
	{
	}

	iq_ext_notice::~iq_ext_notice()
	{
		if (m_p_inner_tag)
		{
			delete m_p_inner_tag;
		}
	}

	const std::string& iq_ext_notice::filterString() const
	{
		static const std::string filter = "/iq/query/notification|/iq[@type='result']/query[@xmlns='http://ruijie.com.cn/notification']/id";
		return filter;
	}

	StanzaExtension* iq_ext_notice::newInstance( const Tag* tag ) const
	{
		return new iq_ext_notice( tag );
	}

	StanzaExtension* iq_ext_notice::clone() const
	{
		return newInstance(m_p_inner_tag->clone());
	}

	Tag* iq_ext_notice::tag() const
	{
		return m_p_inner_tag->clone();
	}


	void iq_ext_notice::add_sub_nodes(Tag& tag, const std::string nodes[])
	{
		for (int i=0;!nodes[i].empty();++i)
		{
			tag.addChild(new Tag(nodes[i]));
		}
	}

	void iq_ext_notice::add_notification(Tag& tag_query, json::jobject jobj)
	{
		std::string title = jobj["title"].get<std::string>();
		std::string expired_time = jobj["expired_time"].get<std::string>();
		std::string body = jobj["body"].get<std::string>();
		std::string html_body = jobj["html"].get<std::string>();
		std::string priority = jobj["priority"].get<std::string>();
		std::string signature = jobj["signature"].get<std::string>();
		std::string hyperlink = jobj["hyperlink"].get<std::string>();
		

		Tag tag(NOTICE_NODE);
		tag.addChild(new Tag("priority", priority));
		tag.addChild(new Tag("signature", signature));
		tag.addChild(new Tag("title", title));
		tag.addChild(new Tag("expired_time", expired_time));
		tag.addChild(new Tag("body", body));
		tag.addChild(new Tag("html", html_body));
		tag.addChild(new Tag("hyperlink", hyperlink));
		tag_query.addChild(tag.clone());
	}

	void iq_ext_notice::add_addresses(Tag& tag_query, json::jobject jobj)
	{
		json::jobject addr_jobj = jobj["address"];
		std::string identity = jobj["identity"].get<std::string>();
		Tag tag(ADDRESS_NODE, "identity", identity);
		for (int i=0; i<addr_jobj.arr_size(); ++i) 
		{
			std::string name = addr_jobj[i]["name"].get<std::string>();
			std::string type =addr_jobj[i]["type"].get<std::string>();
			std::string val =addr_jobj[i]["value"].get<std::string>();
			Tag* tag_item = new Tag("address", NAME_ATTR, name);
			tag_item->addAttribute("type", type);
			tag_item->addAttribute("value", val);
			tag.addChild(tag_item);
		}
		tag_query.addChild(tag.clone());
	}

	void iq_ext_notice::send(std::string domain_, notice_msg* that, int context/*=0*/)
	{
		IQ iq(IQ::Set, JID(NOTICE_MSG_DOMAIN + domain_));
		iq.addExtension(clone());
		that->get_parent_impl()->bizClient_->send(iq, (IqHandler*)that, context, false, true, false);
	}

	std::string iq_ext_notice::parent_id() const
	{
		std::string val = m_p_inner_tag->findAttribute("id");
		return val;
	}

}; // namespace biz