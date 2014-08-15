#include "notice_msg_ack.h"
#include "common.h"
#include "gloox_src/iq.h"
#include "anan_biz_impl.h"
#include "client_anan.h"
#include "notice_msg.h"
#include "anan_config.h"
namespace biz {

notice_msg_ack::notice_msg_ack( std::string id_string, KNoticeAck ack )
	: StanzaExtension(kExtUser_iq_filter_noticeack)
{
	m_tag = new Tag("query", XMLNS, "http://ruijie.com.cn/notification#report");

	Tag *child_tag = new Tag("notification", "id", id_string);
	static const std::string notice_ack[] = {"recv", "read"};
	child_tag->addAttribute("action", notice_ack[ack]);
	m_tag->addChild(child_tag);
}

notice_msg_ack::notice_msg_ack( const Tag *tag )
	: StanzaExtension(kExtUser_iq_filter_noticeack)
	, m_tag(tag->clone())
{
}

notice_msg_ack::~notice_msg_ack(void)
{
	if(m_tag)
		delete m_tag;
}

void notice_msg_ack::send(AnClient* that)
{
	std::string strjid = "notification." + anan_config::instance().get_domain();
	IQ ack_notice(IQ::Set, JID(strjid));
	ack_notice.addExtension(clone());
	that->send(ack_notice, true, false);
}

const std::string& notice_msg_ack::filterString() const
{
	static const std::string sfilter = "/iq/query/notification[@action='recv']" \
									   "/iq/query/notification[@action='read']";
	return sfilter;
}

StanzaExtension* notice_msg_ack::newInstance( const Tag* tag ) const
{
	return new notice_msg_ack( tag );
}

Tag* notice_msg_ack::tag() const
{
	return m_tag->clone();
}

StanzaExtension* notice_msg_ack::clone() const
{
	return newInstance(m_tag->clone());
}

}; // namespace biz