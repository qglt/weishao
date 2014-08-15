#pragma once

#include "boost/signal.hpp"
#include "anan_biz_bind.h"
#include "anan_type.h"
#include "gloox_src/client.h"
#include "gloox_src/rostermanager.h"
#include "gloox_src/gloox.h"

namespace biz
{
	using namespace gloox;
	struct anan_biz_impl;
	class AnRosterManager;

class AnClient : protected biz::anan_biz_bind<anan_biz_impl>,
	public Client
{
	BIZ_FRIEND();

public:
	AnClient( const std::string& server );
	virtual ~AnClient(void);

#ifdef _DEBUG
	void sendxml( const std::string& xml );
#endif

public:
	void changeRosterManager();

	virtual bool handleIq( const IQ& iq );
	virtual void handleIqID( const IQ& iq, int context );
	virtual void process_hanlded_message();
	void do_process_hanlded_message();
	void cleanup();
protected:
	AnRosterManager* anRosterManager();

private:
	AnRosterManager* m_anRosterManager_;
};

}; // gloox