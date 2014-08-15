#pragma once
namespace json
{
    typedef boost::shared_ptr< boost::any > variant;
    typedef std::deque< variant > array;
	template<class T> bool try_any_cast_no_error(const variant &px, T*& p_px);
    template<class T> bool try_any_cast(const variant &px, T*& p_px);
    template<class T> T try_any_cast(const variant &px);
}
