#include "iq_filter.h"
#include "organization.h"
#include "anan_biz_impl.h"
#include "notice_msg.h"
#include "client_anan.h"
#include "gloox_src/tag.h"
#include "common.h"

namespace biz
{	
	// organization_iq
	const std::string query_organization::QUERY_NODE = "query";
	const std::string query_organization::ITEM_NODE = "item";
	const std::string query_organization::IQ_TO = "organization.";
	
	query_organization::query_organization( const Tag* tag ) : StanzaExtension( kExtUser_iq_filter_tree ) , m_p_inner_tag(NULL)
	{
		assert(tag);
		if (tag->name() == QUERY_NODE) 
		{
			m_p_inner_tag = tag->clone();
		} 
		else if (tag->name() == "iq")
		{
			if (Tag* child_tag = m_p_inner_tag = tag->findChild(QUERY_NODE, XMLNS, XMLNS_ORG))
			{
				m_p_inner_tag = child_tag->clone();
			} 
			else if (Tag* child_tag = m_p_inner_tag = tag->findChild(QUERY_NODE, XMLNS, XMLNS_NOTICE))
			{
				m_p_inner_tag = child_tag->clone();
			}
		}
	}

	query_organization::query_organization( query_organization::KOrg_query_type type, std::string parent_id, std::string xmlns, std::string timestamp )	: StanzaExtension( kExtUser_iq_filter_tree )
	{
		m_p_inner_tag = new Tag(QUERY_NODE, XMLNS, xmlns /*XMLNS_ORG*/);
		m_p_inner_tag->addAttribute("id", parent_id);
		m_p_inner_tag->addAttribute("timestamp", timestamp);

		if( type & korg_query_organization )
		{
			add_org_node(*m_p_inner_tag);
		}
		if( type & korg_query_user )
		{
			add_user_node(*m_p_inner_tag);
		}
	}

	query_organization::query_organization() : StanzaExtension( kExtUser_iq_filter_tree ) , m_p_inner_tag(NULL)
	{

	}

	query_organization::~query_organization()
	{
		if (m_p_inner_tag)
			delete m_p_inner_tag;
	}

	const std::string& query_organization::filterString() const
	{
 		static const std::string filter = 
			 "/iq/query[@xmlns='" XMLNS_ORG "']" \
			"|/iq/query[@xmlns='" XMLNS_NOTICE "']";
		return filter;
	}

	StanzaExtension* query_organization::newInstance( const Tag* tag ) const
	{
		return new query_organization( tag );
	}

	StanzaExtension* query_organization::clone() const
	{
		return newInstance(m_p_inner_tag->clone());
	}

	Tag* query_organization::tag() const
	{
		return m_p_inner_tag->clone();
	}


	void query_organization::add_sub_nodes(Tag& tag, const std::string nodes[])
	{
		for (int i=0;!nodes[i].empty();++i)
		{
			tag.addChild(new Tag(nodes[i]));
		}
	}

	void query_organization::add_org_node(Tag& tag_query)
	{
		static const std::string node_names[] = {"id", "parent", "name", "sort_string",""};
		Tag tag(ITEM_NODE, std::string("type"), std::string("organization"));
		add_sub_nodes(tag, node_names);
		tag_query.addChild(tag.clone());
	}

	void query_organization::add_user_node(Tag& tag_query)
	{
		static const std::string node_names[] = {"username", "name", "photo_credential","photo_live","sex", "identity", "mood_words","sort_string",""};
		Tag tag(ITEM_NODE, std::string("type"), std::string("user"));
		add_sub_nodes(tag, node_names);
		tag_query.addChild(tag.clone());
	}

	void query_organization::send(std::string domain_, organization* that, int context/*=0*/)
	{
		IQ iq(IQ::Get, JID(IQ_TO + domain_ ));
		iq.addExtension(clone());
		that->get_parent_impl()->bizClient_->send(iq, (IqHandler*)that, context, false, true, false);
	}

	std::string query_organization::parent_id() const
	{
		std::string val = m_p_inner_tag->findAttribute("id");
		return val;
	}

}; // namespace biz

