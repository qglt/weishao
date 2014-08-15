#pragma once
#include "gloox_src/stanzaextension.h"
#include <string>
#include "gloox_src/tag.h"

namespace biz {
	using namespace gloox;

	enum KNoticeAck {
		kna_recv,
		kna_read
	};

// 通知消息确认指令
class AnClient;
class notice_msg;
class notice_msg_ack : public StanzaExtension
{
public:
	notice_msg_ack( std::string id_string, KNoticeAck ack );
	notice_msg_ack( const Tag *tag );
	~notice_msg_ack();
	virtual const std::string& filterString() const;
	// reimplemented from StanzaExtension
	virtual StanzaExtension* newInstance( const Tag* tag ) const;
	// reimplemented from StanzaExtension
	virtual Tag* tag() const;
	// reimplemented from StanzaExtension
	virtual StanzaExtension* clone() const;
	void send(AnClient* that);
private:
	Tag* m_tag;
};

}; // namespace biz