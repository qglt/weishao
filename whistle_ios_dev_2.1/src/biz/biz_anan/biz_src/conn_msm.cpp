#include "conn_msm.h"
#include "login.h"
#include "biz_recent_contact.h"
#include "anan_biz_impl.h"
#include "file_transfer_manager.h"
namespace biz
{
	CONN_STATE conn_msm::getCurrentState()
	{
		msm::back::state_machine<conn_msm> &fsm = static_cast<msm::back::state_machine<conn_msm> &>(*this);
		return static_cast<CONN_STATE>(*fsm.current_state());
	}

	void conn_msm::set_owner(login* owner)
	{
		machine_owner_ = owner;
	}

	void conn_msm::before_logout()
	{
		if(machine_owner_ && machine_owner_->get_parent_impl() && machine_owner_->get_parent_impl()->bizRecent_)
		{
			machine_owner_->get_parent_impl()->bizRecent_->UploadRecentContact();			
		}
		file_transfer::instance().cancel_all_transfer_file();
	}

	conn_msm::conn_msm():machine_owner_(NULL)
	{		
	}	

	void conn_msm::cloud_config_got()
	{
		if (machine_owner_)
		{
			machine_owner_->cloud_config_got();
		}
	}

	void conn_msm::to_login_with_got_config()
	{
		if (machine_owner_)
		{
			machine_owner_->to_login_with_got_config();
		}
	}

	void conn_msm::prepare_login()
	{
		if (machine_owner_)
		{
			machine_owner_->prepare_login();
		}
	}
}

