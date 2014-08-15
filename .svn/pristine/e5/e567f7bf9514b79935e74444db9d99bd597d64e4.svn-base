#pragma once

#include <map>
#include <string>
#include <boost/assign/list_of.hpp>
#include "../gloox_src/gloox.h"

using namespace boost::assign;
using namespace gloox;

#define SE_NAME(x) (x, std::string(#x).substr(11))
static std::map<gloox::StanzaError, std::string> StanzaError2String = map_list_of(StanzaErrorBadRequest, std::string("StanzaErrorBadRequest", 11))
	SE_NAME(StanzaErrorConflict) SE_NAME(StanzaErrorFeatureNotImplemented) SE_NAME(StanzaErrorForbidden) SE_NAME(StanzaErrorGone) SE_NAME(StanzaErrorInternalServerError) SE_NAME(StanzaErrorItemNotFound)
	SE_NAME(StanzaErrorJidMalformed) SE_NAME(StanzaErrorNotAcceptable) SE_NAME(StanzaErrorNotAllowed) SE_NAME(StanzaErrorNotAuthorized) SE_NAME(StanzaErrorNotModified)
	SE_NAME(StanzaErrorPaymentRequired) SE_NAME(StanzaErrorRecipientUnavailable) SE_NAME(StanzaErrorRedirect) SE_NAME(StanzaErrorRegistrationRequired) SE_NAME(StanzaErrorRemoteServerNotFound)
	SE_NAME(StanzaErrorRemoteServerTimeout) SE_NAME(StanzaErrorResourceConstraint) SE_NAME(StanzaErrorServiceUnavailable) SE_NAME(StanzaErrorSubscribtionRequired)
	SE_NAME(StanzaErrorUndefinedCondition) SE_NAME(StanzaErrorUnexpectedRequest) SE_NAME(StanzaErrorUnknownSender) SE_NAME(StanzaErrorUndefined);
