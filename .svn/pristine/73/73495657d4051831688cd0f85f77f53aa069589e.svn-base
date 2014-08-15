#pragma once

#include <base/utility/typelist/Typelist.h>
#include <boost/bind.hpp>
#include <boost/function.hpp>
#include <boost/signal.hpp>
#include <base/utility/macro_helper/meta_macro.h>

namespace epius
{
//for a given function type, return signal type that has same Signature with it.
template<class T>struct function2signal;
template<class T>struct function2signal<boost::function<T> >
{
	typedef boost::signal<T>	result_type;
};
//for a given function type, return its arguments typelist
template<class fun_type> struct get_fun_arg_typelist;
template<class fun_return_type> struct get_fun_arg_typelist<boost::function<fun_return_type()> >
{
	typedef Loki::NullType result_type;
	typedef fun_return_type return_type;
};
#define MAKE_GET_FUN_ARG_TYPELIST_ONELINE(n,y)				\
template<class fun_return_type, LINE_EXPAND_N(n,RBIND,TYPE_PARAM)>	\
struct get_fun_arg_typelist<boost::function<fun_return_type(LINE_EXPAND_N(n,RBIND,TYPE_PURE))> >		\
{																									\
	typedef typename Loki::TL::MakeTypelist<LINE_EXPAND_N(n,RBIND,TYPE_PURE) >::Result result_type;	\
	typedef fun_return_type return_type;															\
};
CONSTRUCT(10,MAKE_GET_FUN_ARG_TYPELIST_ONELINE);
//for a given typelist, return type, return normal function pointer type


//for a given typelist, return type, and class type, return class member function pointer type


//for a given signal object, return it's member function that represent it.

//for a given function type, and a class, give the match member function type
template<class dest_class, class fun_type> struct get_member_fun_type;
template<class dest_class, class return_type> struct get_member_fun_type<dest_class, boost::function<return_type()> >
{
	typedef return_type (dest_class::*result_type)();
	enum {arg_number = 0};
};
#define MAKE_GET_MEMBER_FUN_TYPE(n,y)		\
template<class dest_class, class return_type, LINE_EXPAND_N(n,RBIND,TYPE_PARAM) >		\
struct get_member_fun_type<dest_class, boost::function<return_type(LINE_EXPAND_N(n,RBIND,TYPE_PURE))> >		\
{																											\
	typedef return_type (dest_class::*result_type)(LINE_EXPAND_N(n,RBIND,TYPE_PURE));						\
	enum {arg_number = ONE_NUM(n,n)};																		\
};
CONSTRUCT(10,MAKE_GET_MEMBER_FUN_TYPE);

template<class signal_type, class function_type, int arg_nums>struct Signal_To_Command;

template<class signal_type, class function_type>
struct Signal_To_Command<signal_type, function_type, 0>
{
	static function_type get_command(boost::shared_ptr<signal_type> sig)
	{
		typedef typename get_member_fun_type<signal_type,function_type>::result_type dest_type;
		return boost::bind((dest_type)&signal_type::operator(), sig);
	}
};

#define MAKE_SIGNAL_TO_COMMAND(n,y)	\
	template<class signal_type, class function_type>	\
struct Signal_To_Command<signal_type, function_type, n>	{	\
	static function_type get_command(boost::shared_ptr<signal_type> sig){	\
	typedef typename get_member_fun_type<signal_type,function_type>::result_type dest_type;	\
	return boost::bind((dest_type)&signal_type::operator(), sig, LINE_EXPAND_N(n,RBIND,BIND_ARG));	\
}	\
};


CONSTRUCT(9,MAKE_SIGNAL_TO_COMMAND);

}//namespace epius