#pragma once
#include <base/json/tinyjson.hpp>
#include <base/universal_res/uni_res.h>

namespace biz {

// BIZ对UI的回调伪函数
typedef boost::function<void(json::jobject)> JsonCallback;
typedef boost::function<void(bool,universal_resource)> UIVCallback;

// 对android的平台屏蔽定义
#ifdef _WIN32
#define normal_member_func __thiscall
#else
#define normal_member_func
#endif

// 声明错误表（用于数字形式表示的错误码到字符串表示的错误码的转换）。
#define _DECLARE_E() private: \
						struct __tv { \
							unsigned long error_id; \
							std::string error_str; \
						}; \
						static const std::string __namespace; \
						static const struct __tv __match_table[]; \
						static const std::string& __match_error_id(unsigned long error_id)

// #define _DEF_E(x) static const std::string x

// 定义错误表的开始。
#define _BEGIN_IMPL_E(t,tname) typedef t private_t; \
						 const std::string private_t::__namespace = #tname; \
						 const std::string& private_t::__match_error_id(unsigned long error_id) \
						 { \
							int i=0; \
						    for(;__match_table[i].error_id != -1 && !__match_table[i].error_str.empty();++i) \
							{ \
								if (__match_table[i].error_id == error_id) \
									return __match_table[i].error_str; \
							} \
							assert(false); \
							return __match_table[i].error_str; \
						 } \
						 const struct private_t::__tv private_t::__match_table[] = {
// 定义错误表的结束。
#define _END_IMPL_E() {static_cast<unsigned long>(-1),""}}
// 定义错误项。
#define _IMPL_E(x,y) {(x),(private_t::__namespace + "." + y)},
// 
#define AE(x) __match_error_id(x)

#define BIZ_FRIEND() \
	friend struct anan_biz_impl; \
	friend class user_impl; \
	friend class AnRosterManager; \
	friend class anan_biz; \
	friend class agent; \
	friend class BizGroups; \
	friend class conversation; \
	friend class LocalConfig; \
	friend class login; \
	friend class AnRosterManager; \
	friend class user;    \
	friend class anan_private; \
	friend class organization; \
	friend class notice_msg; \
	friend class biz_recent_contact; \
	friend class web_request

}; // namespace biz
