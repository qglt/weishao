#pragma once
#include "base/json/tinyjson.hpp"
#include "gloox_src/stanzaextension.h"
#include "gloox_src/tag.h"
#include <string>

namespace biz {
	using namespace gloox;

class msg_ext_notification : public StanzaExtension
{
public:
	msg_ext_notification(void);
	msg_ext_notification(const Tag* tag);
	~msg_ext_notification(void);

public:
	virtual const std::string& filterString() const;
	// reimplemented from StanzaExtension
	virtual StanzaExtension* newInstance( const Tag* tag ) const;
	// reimplemented from StanzaExtension
	virtual Tag* tag() const;
	// reimplemented from StanzaExtension
	virtual StanzaExtension* clone() const;

public:
	const Tag& reftag() const;

private:
	Tag *m_p_inner_tag;
};


//----------------
// notice_msg_iq
//----------------

class notice_msg;
class iq_ext_notice : public StanzaExtension
{
public:
	iq_ext_notice();
	iq_ext_notice( json::jobject jobj );
	iq_ext_notice( const Tag* tag );
	~iq_ext_notice();

public:
	void send(std::string domain_, notice_msg* that, int context=0);
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
	void add_addresses(Tag& tag_query, json::jobject jobj);
	void add_notification(Tag& tag_query, json::jobject jobj);

private:
	Tag *m_p_inner_tag;
	enum {
		kqnm_unknown,
		kqnm_pingpong,
		kqnm_publish
	} m_state;

private: // static
	static const std::string QUERY_NODE;// "query";
	static const std::string NAME_ATTR;// "name";
	static const std::string ADDRESS_NODE;// "addresses";
	static const std::string NOTICE_NODE;// "notification";
	static const std::string NOTICE_MSG_DOMAIN; // "notification.ruijie.com.cn"
};

}; // namespace biz