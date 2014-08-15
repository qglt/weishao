#pragma once


#include "../gloox_src/stanzaextension.h"
namespace gloox {
template<int StanzaExtensionTypeID>
class BasicStanza:public StanzaExtension
{
public:
    BasicStanza(const Tag* tag = 0, std::string const& filters = ""):StanzaExtension(StanzaExtensionTypeID), filters_(filters)
	{
		tag_ = (Tag*)tag;
	}
    /**
    * Virtual destructor.
    */
    virtual ~BasicStanza(){
		delete tag_;
		tag_ = NULL;
	}

    // reimplemented from StanzaExtension
    virtual const std::string& filterString() const
	{
		return filters_;
	}

    // reimplemented from StanzaExtension
    virtual StanzaExtension* newInstance( const Tag* tag ) const
    {
		return new BasicStanza<StanzaExtensionTypeID>(tag->clone(), filters_);
    }

    // reimplemented from StanzaExtension
    virtual Tag* tag() const
	{
		return tag_->clone();
	}

    // reimplemented from StanzaExtension
    virtual StanzaExtension* clone() const
    {
		return new BasicStanza<StanzaExtensionTypeID>( tag_->clone(), filters_ );
    }

private:
    gloox::Tag* tag_;
	std::string filters_;
};
}