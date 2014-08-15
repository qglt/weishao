
#pragma once

#include <boost/bind.hpp>
#include <boost/function.hpp>
#include <base/utility/typelist/type_algo.h>
#include <base/utility/macro_helper/meta_macro.h>
#include <boost/bind/apply.hpp>

#ifdef __APPLE__
#include "TargetConditionals.h"
#endif

namespace epius
{
template<class funParamType, int functionPos>
struct remember_type_pos
{
	enum {funPos = functionPos};
	typedef	funParamType rem_type;
};
template<class func_type>
struct Bind2TypeList
{
	typedef Loki::NullType result_type;
};
//----------------------------------for normal functions------------------------------------------------------------

#define MAKE_NON_MEMBER_FUN_TYPELIST_ONELINE(n,y)																								\
	template<class return_type, LINE_EXPAND_N(n,RBIND,TYPE_PARAM)>																	\
	struct Bind2TypeList<return_type(*)( LINE_EXPAND_N(n,RBIND,TYPE_PURE) )>														\
	{																																\
		typedef typename Loki::TL::MakeTypelist<return_type, LINE_EXPAND_N(n,RBIND,TYPE_PURE) >::Result result_type;				\
	}

template <class return_type>
struct Bind2TypeList<return_type(*)()>
{
	typedef typename Loki::TL::MakeTypelist<return_type>::Result result_type;
};
CONSTRUCT(9,MAKE_NON_MEMBER_FUN_TYPELIST_ONELINE);

#ifdef _WIN32

#define MAKE_NON_MEMBER_STD_FUN_TYPELIST_ONELINE(n,y)																								\
	template<class return_type, LINE_EXPAND_N(n,RBIND,TYPE_PARAM)>																	\
struct Bind2TypeList<return_type(__stdcall *)( LINE_EXPAND_N(n,RBIND,TYPE_PURE) )>														\
{																																\
	typedef typename Loki::TL::MakeTypelist<return_type, LINE_EXPAND_N(n,RBIND,TYPE_PURE) >::Result result_type;				\
}

template <class return_type>
struct Bind2TypeList<return_type(__stdcall *)()>
{
	typedef typename Loki::TL::MakeTypelist<return_type>::Result result_type;
};
CONSTRUCT(9,MAKE_NON_MEMBER_STD_FUN_TYPELIST_ONELINE);
#endif
//------------------------------------for class member functions----------------------------------------------------
#define MAKE_MEMBER_FUN_TYPELIST_ONELINE(n,y)																					\
	template<template<LINE_EXPAND_N(n,RBIND,ONLY_TYPE)>class Container, LINE_EXPAND_N(n,RBIND,TYPE_PARAM)>							\
	struct Bind2TypeList<Container< LINE_EXPAND_N(n,RBIND,TYPE_PURE) > >														\
	{																															\
		typedef typename Loki::TL::MakeTypelist< LINE_EXPAND_N(n,RBIND,TYPE_PURE) >::Result result_type;						\
	};
CONSTRUCT(10, MAKE_MEMBER_FUN_TYPELIST_ONELINE);
//-------------------------end-----------for class member functions----------------------------------------------------
//------------------------------------for std and boost function----------------------------------------------------
#ifndef TARGET_OS_IPHONE 
template <class return_type>
struct Bind2TypeList< std::function <return_type()> >
{
	typedef typename Loki::TL::MakeTypelist<return_type>::Result result_type;
};
#define MAKE_STD_FUNCTION_TYPELIST_ONELINE(n,y)																					\
	template<class return_type, LINE_EXPAND_N(n, RBIND, TYPE_PARAM) >														\
	struct Bind2TypeList<std::function< return_type(LINE_EXPAND_N(n,RBIND,TYPE_PURE) ) > >													\
	{																															\
		typedef typename Loki::TL::MakeTypelist< return_type, LINE_EXPAND_N(n,RBIND,TYPE_PURE) >::Result result_type;						\
	};
CONSTRUCT(10, MAKE_STD_FUNCTION_TYPELIST_ONELINE);

#endif
    
template <class return_type>
struct Bind2TypeList< boost::function <return_type()> >
{
	typedef typename Loki::TL::MakeTypelist<return_type>::Result result_type;
};
#define MAKE_BOOST_FUNCTION_TYPELIST_ONELINE(n,y)																					\
	template<class return_type, LINE_EXPAND_N(n, RBIND, TYPE_PARAM) >														\
struct Bind2TypeList<boost::function< return_type(LINE_EXPAND_N(n,RBIND,TYPE_PURE) ) > >													\
{																															\
	typedef typename Loki::TL::MakeTypelist< return_type, LINE_EXPAND_N(n,RBIND,TYPE_PURE) >::Result result_type;						\
};
CONSTRUCT(10, MAKE_BOOST_FUNCTION_TYPELIST_ONELINE);

//------------------------------------for std and boost function end---------------------------------------------------

//given a typelist, that may having arg<i>, deduce a new typelist that contain type_pos, func_pos typelist.



template<int type_index,class fun_type_list, class arg_type_list>
struct Bind2ArgList;

template<int type_index, class fun_type_list>
struct Bind2ArgList<type_index,fun_type_list, Loki::NullType>
{
	typedef typename Loki::TL::MakeTypelist<>::Result result_type;
};
template<int type_index,class fun_type_list,class Head,class Tail>
struct Bind2ArgList<type_index,fun_type_list,Loki::Typelist<Head,Tail> >
{
	typedef typename Bind2ArgList<type_index+1,fun_type_list,Tail>::result_type tmp_type;
	typedef typename boost::conditional<(boost::is_placeholder<Head>::value != 0),
		typename Loki::TL::Append<typename Loki::TL::MakeTypelist<remember_type_pos< typename Loki::TL::TypeAt<fun_type_list,type_index>::Result ,boost::is_placeholder<Head>::value - 1> >::Result, tmp_type>::Result,
		tmp_type>::type possible_duplicate_type;
	typedef typename Loki::TL::NoDuplicates<possible_duplicate_type>::Result result_type; 
};

template<class rem1,class rem2>
struct rem1_before_rem2
{
	enum {value = ((int)rem1::funPos < (int)rem2::funPos)};
};
template<class rem1>
struct rem1_before_rem2<rem1,Loki::NullType>
{
	enum {value=true};
};

template<class typelist>
struct MinType;

template<>
struct MinType<Loki::NullType>
{
	typedef Loki::NullType result_type;
};

template<class Head,class Tail>
struct MinType<Loki::Typelist<Head,Tail> >
{
	typedef typename MinType<Tail>::result_type min_tail_type;
	typedef typename boost::conditional< rem1_before_rem2<Head,min_tail_type>::value,
		Head,min_tail_type>::type result_type;
};

template<class type_list>
struct OrderTypelist
{
	typedef typename MinType<type_list>::result_type Head;
	typedef typename Loki::TL::Erase<type_list,Head>::Result left_types;
	typedef typename OrderTypelist<left_types>::result_type Tail;
	typedef typename Loki::TL::Append<typename Loki::TL::MakeTypelist<Head>::Result, Tail>::Result result_type;
};

template<>
struct OrderTypelist<Loki::NullType>
{
	typedef Loki::NullType result_type;
};
template<class typelist, int id>
struct type_having_id;

template<int id>
struct type_having_id<Loki::NullType, id>
{
	typedef typename Loki::TL::MakeTypelist<int>::Result result_type;
};

template<class Head,class Tail, int id>
struct type_having_id<Loki::Typelist<Head,Tail>, id>
{
	enum {value=(Head::funPos==id)};
	typedef typename boost::conditional<value,
		typename Loki::TL::MakeTypelist<typename Head::rem_type>::Result,typename type_having_id<Tail,id>::result_type>::type result_type;
};

template<class typelist, int index, int max_index>
struct build_fun_full_typelist_helper
{
	typedef typename build_fun_full_typelist_helper<typelist,index+1,max_index>::result_type tail_type;
	typedef typename type_having_id<typelist,index>::result_type id_type;
	typedef typename Loki::TL::Append<id_type, tail_type>::Result result_type;
};
template<class typelist, int max_index>
struct build_fun_full_typelist_helper<typelist,max_index,max_index>
{
	typedef typename Loki::TL::MakeTypelist<typename Loki::TL::TypeAt<typelist, Loki::TL::Length<typelist>::value - 1  >::Result::rem_type>::Result result_type;
};

template<class typelist>
struct build_fun_full_typelist
{
	enum {len = Loki::TL::Length<typelist>::value, max_fun_pos = Loki::TL::TypeAt<typelist,len-1>::Result::funPos};
	typedef typename build_fun_full_typelist_helper<typelist, 0, max_fun_pos>::result_type result_type;
};

template<>
struct build_fun_full_typelist<Loki::NullType>
{
	typedef Loki::NullType result_type;	
};
//-----------------------------------------------------------for function type ------------------------------------------------
template<template<class>class desttype, class return_type, class typelist, int N>
struct build_type_helper;

template<template<class>class desttype, class return_type, class typelist>
struct build_type_helper<desttype, return_type, typelist,0>
{
	typedef desttype<return_type()> result_type;
};

template<template<class>class desttype, class return_type, class typelist>
struct build_type_helper<desttype, return_type, typelist,1>
{
	typedef typename Loki::TL::TypeAt<typelist,0>::Result A0;
	typedef desttype<return_type(A0)> result_type;
};
template<template<class>class desttype, class return_type, class typelist>
struct build_type_helper<desttype, return_type, typelist,2>
{
	typedef typename Loki::TL::TypeAt<typelist,0>::Result A0;
	typedef typename Loki::TL::TypeAt<typelist,1>::Result A1;
	typedef desttype<return_type(A0,A1)> result_type;
};
template<template<class>class desttype, class return_type, class typelist>
struct build_type_helper<desttype, return_type, typelist,3>
{
	typedef typename Loki::TL::TypeAt<typelist,0>::Result A0;
	typedef typename Loki::TL::TypeAt<typelist,1>::Result A1;
	typedef typename Loki::TL::TypeAt<typelist,2>::Result A2;
	typedef desttype<return_type(A0,A1,A2)> result_type;
};
template<template<class>class desttype, class return_type, class typelist>
struct build_type_helper<desttype, return_type, typelist,4>
{
	typedef typename Loki::TL::TypeAt<typelist,0>::Result A0;
	typedef typename Loki::TL::TypeAt<typelist,1>::Result A1;
	typedef typename Loki::TL::TypeAt<typelist,2>::Result A2;
	typedef typename Loki::TL::TypeAt<typelist,3>::Result A3;
	typedef desttype<return_type(A0,A1,A2,A3)> result_type;
};
template<template<class>class desttype, class return_type, class typelist>
struct build_type_helper<desttype, return_type, typelist,5>
{
	typedef typename Loki::TL::TypeAt<typelist,0>::Result A0;
	typedef typename Loki::TL::TypeAt<typelist,1>::Result A1;
	typedef typename Loki::TL::TypeAt<typelist,2>::Result A2;
	typedef typename Loki::TL::TypeAt<typelist,3>::Result A3;
	typedef typename Loki::TL::TypeAt<typelist,4>::Result A4;
	typedef desttype<return_type(A0,A1,A2,A3,A4)> result_type;
};
template<template<class>class desttype, class return_type, class typelist>
struct build_type_helper<desttype, return_type, typelist,6>
{
	typedef typename Loki::TL::TypeAt<typelist,0>::Result A0;
	typedef typename Loki::TL::TypeAt<typelist,1>::Result A1;
	typedef typename Loki::TL::TypeAt<typelist,2>::Result A2;
	typedef typename Loki::TL::TypeAt<typelist,3>::Result A3;
	typedef typename Loki::TL::TypeAt<typelist,4>::Result A4;
	typedef typename Loki::TL::TypeAt<typelist,5>::Result A5;
	typedef desttype<return_type(A0,A1,A2,A3,A4,A5)> result_type;
};
template<template<class>class desttype, class return_type, class typelist>
struct build_type_helper<desttype, return_type, typelist,7>
{
	typedef typename Loki::TL::TypeAt<typelist,0>::Result A0;
	typedef typename Loki::TL::TypeAt<typelist,1>::Result A1;
	typedef typename Loki::TL::TypeAt<typelist,2>::Result A2;
	typedef typename Loki::TL::TypeAt<typelist,3>::Result A3;
	typedef typename Loki::TL::TypeAt<typelist,4>::Result A4;
	typedef typename Loki::TL::TypeAt<typelist,5>::Result A5;
	typedef typename Loki::TL::TypeAt<typelist,6>::Result A6;
	typedef desttype<return_type(A0,A1,A2,A3,A4,A5,A6)> result_type;
};
template<template<class>class desttype, class return_type, class typelist>
struct build_type_helper<desttype, return_type, typelist,8>
{
	typedef typename Loki::TL::TypeAt<typelist,0>::Result A0;
	typedef typename Loki::TL::TypeAt<typelist,1>::Result A1;
	typedef typename Loki::TL::TypeAt<typelist,2>::Result A2;
	typedef typename Loki::TL::TypeAt<typelist,3>::Result A3;
	typedef typename Loki::TL::TypeAt<typelist,4>::Result A4;
	typedef typename Loki::TL::TypeAt<typelist,5>::Result A5;
	typedef typename Loki::TL::TypeAt<typelist,6>::Result A6;
	typedef typename Loki::TL::TypeAt<typelist,7>::Result A7;
	typedef desttype<return_type(A0,A1,A2,A3,A4,A5,A6,A7)> result_type;
};
template<template<class>class desttype, class return_type, class typelist>
struct build_type_helper<desttype, return_type, typelist,9>
{
	typedef typename Loki::TL::TypeAt<typelist,0>::Result A0;
	typedef typename Loki::TL::TypeAt<typelist,1>::Result A1;
	typedef typename Loki::TL::TypeAt<typelist,2>::Result A2;
	typedef typename Loki::TL::TypeAt<typelist,3>::Result A3;
	typedef typename Loki::TL::TypeAt<typelist,4>::Result A4;
	typedef typename Loki::TL::TypeAt<typelist,5>::Result A5;
	typedef typename Loki::TL::TypeAt<typelist,6>::Result A6;
	typedef typename Loki::TL::TypeAt<typelist,7>::Result A7;
	typedef typename Loki::TL::TypeAt<typelist,8>::Result A8;
	typedef desttype<return_type(A0,A1,A2,A3,A4,A5,A6,A7,A8)> result_type;
};
//-----------------------------------------------------------for function type end ------------------------------------------------

template <class return_type, class typelist>
struct build_fun_type_helper
{
	typedef typename build_type_helper<boost::function, return_type, typelist,Loki::TL::Length<typelist>::value>::result_type result_type;
};

template <class return_type, class typelist>
struct build_fun_type
{
	typedef typename build_fun_type_helper<return_type, typelist>::result_type result_type;
};
template<class BindType>
struct BindTypeHelper;

template<class R,class F, class L>
struct BindTypeHelper<boost::_bi::bind_t<R,F,L> >
{
	typedef R return_type;
	typedef F function_type;
	typedef L args_type_list;
};
template<class R, class L>
struct BindTypeHelper<boost::_bi::bind_t<boost::_bi::unspecified, boost::apply<R>, L> >
{
	typedef typename Bind2TypeList<L>::result_type apply_type_list;
	typedef typename Bind2TypeList<typename apply_type_list::Head>::result_type fun_type_list;
	typedef R return_type;
	typedef typename apply_type_list::Tail args_type_list;
	typedef typename fun_type_list::Head function_type;
};
/*
//bindtype will be one of the following types:
1. ordinary functions
              R=int,
              F=int (__cdecl *)(int,int,int),
              L=boost::_bi::list3<boost::_bi::value<int>,boost::_bi::value<int>,boost::_bi::value<int>>

2. member functions, like void FickrPics::work(int,int), it will be
			R=void
   		    F=boost::_mfi::mf2<void,FlickrPics,int,int>,
			L=boost::_bi::list3<boost::_bi::value<FlickrPics *>,boost::arg<1>,boost::arg<2>>
3. boost::apply<int> functions 

            R=boost::_bi::unspecified,
            F=boost::apply<int>,
            L=boost::_bi::list4<boost::_bi::value<int (__cdecl *)(int,int,int)>,boost::_bi::value<int>,boost::_bi::value<int>,boost::_bi::value<int>>
4. lambda funcions
            R=boost::_bi::unspecified,
            F=boost::apply<int>,
            L=boost::_bi::list4<boost::_bi::value<std::function<int (int,int,int)> >,boost::_bi::value<int>,boost::_bi::value<int>,boost::_bi::value<int>>

// in fact,pos=>new_pos map should be deduced, for example, L=boost::_bi::list3<boost::_bi::value<FlickrPics *>,boost::arg<3>,boost::arg<7>>
// so function should be fuction(return_value, int, int,int, type_0, int, int, int, type_1
// we need a <pos, new_pos> list for the caculation, let's go

*/
template<class BindType>
struct Bind2Fun
{
	typedef typename BindTypeHelper<BindType>::return_type return_type;
	typedef typename BindTypeHelper<BindType>::function_type function_type;
	/* function_type can be one of the following
	int (__cdecl *)(int)
	boost::_mfi::mf2<void,FlickrPics,int,int>
	std::function<int (int,int,int)>
	boost::function<int(int,int,int)>
	*/
	typedef typename BindTypeHelper<BindType>::args_type_list args_type_list;
	/* args_type_list is like this
	Loki::Typelist<boost:arg<1>, Loki::NullType>
	Loki::Typelist<boost::_bi::value<int>, Loki::NullType>
	*/
 	typedef typename Bind2TypeList<function_type>::result_type typelist_with_return_type;
 	typedef typename typelist_with_return_type::Tail typelist;
	/* typelist will be all parameters for the function, and represented by Loki::Typelist
	Loki::Typelist<int, Loki::NullType>
	*/
 	typedef typename Bind2TypeList<args_type_list>::result_type arg_typelist;
 	typedef typename Bind2ArgList<0,typelist,arg_typelist>::result_type no_duplicate_fun_argu_type;
 	typedef typename OrderTypelist<no_duplicate_fun_argu_type>::result_type ordered_typelist;
 	typedef typename build_fun_full_typelist<ordered_typelist>::result_type full_typelist;
	//build function type
	typedef typename build_fun_type<return_type, full_typelist>::result_type result_fun_type;
	typedef typename build_fun_type<void, full_typelist>::result_type void_result_fun_type;
	//build signal type
	typedef typename function2signal<result_fun_type>::result_type result_sig_type;
	typedef typename function2signal<void_result_fun_type>::result_type void_result_sig_type;
};

template<class BindType>
typename Bind2Fun<BindType>::result_fun_type bind2fun(BindType cmd)
{
	typename Bind2Fun<BindType>::result_fun_type cmd2 = cmd;
	return cmd2;
}

template<class BindType>
typename Bind2Fun<BindType>::void_result_fun_type bind2voidfun(BindType cmd)
{
	typename Bind2Fun<BindType>::void_result_fun_type cmd2 = cmd;
	return cmd2;
}

template<class BindType>
typename Bind2Fun<BindType>::result_fun_type bind_safe(BindType cmd)
{
	typedef typename Bind2Fun<BindType>::result_sig_type signal_type;
	typedef typename Bind2Fun<BindType>::void_result_fun_type function_type;
	enum {argument_len = Loki::TL::Length<typename Bind2Fun<BindType>::full_typelist>::value};
	boost::shared_ptr<signal_type> tmpSig = boost::make_shared<signal_type>();
	tmpSig->connect(cmd);
	return Signal_To_Command<signal_type,function_type,argument_len>::get_command(tmpSig);
}

template<class BindType>
typename Bind2Fun<BindType>::void_result_fun_type bind_voidsafe(BindType cmd)
{
	typename Bind2Fun<BindType>::void_result_fun_type cmd2 = cmd;
	return cmd2;
}

#define bind2f(...) epius::bind2fun(boost::bind(__VA_ARGS__))
#define bind_s(...) epius::bind_safe(boost::bind(__VA_ARGS__))
#define bind_vs(...) epius::bind_voidsafe(boost::bind(__VA_ARGS__))
}//end namespace epius