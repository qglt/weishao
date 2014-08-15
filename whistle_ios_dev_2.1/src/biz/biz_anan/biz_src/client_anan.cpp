#include "base/tcpproactor/TcpProactor.h"
#include "client_anan.h"
#include "an_roster_manager.h"
#include "anan_biz_bind.h"
#include "anan_biz_impl.h"
namespace biz
{

AnClient::AnClient( const std::string& server )
	: Client(server)
	, m_anRosterManager_(NULL)
{
// 	changeRosterManager();
}


AnClient::~AnClient(void)
{
	m_anRosterManager_ = NULL; // 基类delete
}


void AnClient::changeRosterManager()
{
	disableRoster();
	get_parent_impl()->bizRoster_ = new AnRosterManager( get_parent_impl() );
	m_anRosterManager_ = get_parent_impl()->bizRoster_; /*new AnRosterManager( this );*/
	m_rosterManager = static_cast<RosterManager*>(m_anRosterManager_);
	m_manageRoster = true;
}

bool AnClient::handleIq( const IQ& iq )
{
	return Client::handleIq(iq);
}

void AnClient::handleIqID( const IQ& iq, int context )
{
	Client::handleIqID(iq, context);
}

void AnClient::cleanup()
{
	Client::cleanup();
}

AnRosterManager* AnClient::anRosterManager()
{
	return m_anRosterManager_;
}


void AnClient::do_process_hanlded_message()
{
	// 有未处理的消息在这里处理
	if (process_msg_ && process_msg_->num_slots())
	{
		(*process_msg_)();
		process_msg_->disconnect_all_slots();
	}
	// 清空指针
	process_msg_.reset();
}


void AnClient::process_hanlded_message()
{
	get_parent_impl()->_p_private_task_->post(boost::bind(&AnClient::do_process_hanlded_message, this));
}

#ifdef _DEBUG
void AnClient::sendxml( const std::string& xml )
{
	send(xml);
}
#endif

}; // biz
