#include "base/tcpproactor/TcpProactor.h"
#include "anan_biz_impl.h"
#include <boost/make_shared.hpp>
#include "login.h"
#include "agent.h"
#include "conversation.h"
#include "an_roster_manager.h"
#include "user.h"
#include "local_config.h"
#include "client_anan.h"
#include "anan_private.h"
#include "organization.h"
#include "notice_msg.h"
#include "biz_recent_contact.h"

namespace biz {
    anan_biz_impl::anan_biz_impl()
    {
        using boost::make_shared;
        bizClient_ = NULL;
		bizConversation_ = NULL;
		only_inc_times_ = 0;
        bizAgent_ = make_shared<agent>();
        bizLogin_ = make_shared<login>();
		bizLocalConfig_ = make_shared<LocalConfig>();
		bizUser_ = make_shared<user>();
		bizOrg_ = make_shared<organization>();
		bizNotice_ = make_shared<notice_msg>();
        bizAnanPrivate_ = make_shared<anan_private>();
		bizGroups_ = make_shared<BizGroups>();
		bizRecent_ = make_shared<biz_recent_contact>();
		bizAgent_->set_parent_impl(this);
        bizLogin_->set_parent_impl(this);
        bizUser_->set_parent_impl(this);
		bizOrg_->set_parent_impl(this);
		bizNotice_->set_parent_impl(this);
        bizLocalConfig_->set_parent_impl(this);
        bizAnanPrivate_->set_parent_impl(this);
        bizGroups_->set_parent_impl(this);
		bizRecent_->set_parent_impl(this);
    }
}; //biz
