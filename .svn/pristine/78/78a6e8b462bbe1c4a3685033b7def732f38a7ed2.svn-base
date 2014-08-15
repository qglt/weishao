#pragma once
#include "gloox_src/stanzaextension.h"
#include <string>
#include "gloox_src/gloox.h"
#include "gloox_src/tag.h"
#include "base/json/tinyjson.hpp"
#include "common.h"

namespace biz
{
	using namespace gloox;
 	//----------------
	// organization_iq
	//----------------
	class organization;
	class query_organization : public StanzaExtension
	{
	public:
		enum KOrg_query_type 
		{
			korg_none = 0,
			korg_query_user = 1,
			korg_query_organization = 2,
			korg_query_all = korg_query_user | korg_query_organization
		};

	public:
		query_organization();
		query_organization(KOrg_query_type type, std::string parent_id, std::string xmlns, std::string timestamp );
		query_organization( const Tag* tag );
		~query_organization();

	public:
		void send(std::string domain_, organization* that, int context=0);
		std::string parent_id() const;

	public:
		virtual const std::string& filterString() const;
		// reimplemented from StanzaExtension
		virtual StanzaExtension* newInstance( const Tag* tag ) const;
		// reimplemented from StanzaExtension
		virtual Tag* tag() const;
		// reimplemented from StanzaExtension
		virtual StanzaExtension* clone() const;
	protected:
		void add_sub_nodes(Tag& tag_query, const std::string nodes[]);
		void add_user_node(Tag& tag_query);
		void add_org_node(Tag& tag_query);

	private:
		Tag *m_p_inner_tag;

	private: // static
		static const std::string QUERY_NODE;// "query";
		static const std::string ITEM_NODE;// "item";
		static const std::string IQ_TO;// "organization";
	};

}; // namespace biz



