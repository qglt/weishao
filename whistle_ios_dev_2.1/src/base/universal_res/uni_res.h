#pragma once
#include <string>
#include <boost/shared_ptr.hpp>
#include <base/config/configure.hpp>
#include <base/utility/singleton/singleton.hpp>
#include "base/json/tinyjson.hpp"

#define XL(val)  uni_res::instance().GetResourceByKey(val)

struct universal_resource
{
    std::string res_key;        //×Ö·û´® key
    std::string res_value_utf8;      //×Ö·û´®·­ÒëºóÖµ utf-8 ±àÂë
#ifdef _WIN32
    std::wstring res_comment;    //×Ö·û´® ×¢ÊÍ, unicode ±àÂë
    std::wstring res_value;          //×Ö·û´®·­ÒëºóÖµ£¬unicode±àÂë
#endif
};
struct uni_res_trans_impl;
class uni_res_trans
{
    template<class> friend struct boost::utility::singleton_holder;
    uni_res_trans();
public:
	void init();
    universal_resource GetResourceByKey(std::string const& key);
    void SetLanguage(std::string const& lang);
private:
    boost::shared_ptr<uni_res_trans_impl> impl_;
};
typedef boost::utility::singleton_holder<uni_res_trans> uni_res;