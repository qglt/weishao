#pragma once

#include <base/utility/typelist/type_algo.h>
#include <boost/shared_ptr.hpp>
#include <boost/bind/apply.hpp>

typedef boost::function<void(boost::function<void()>) > act_post_cmd;
typedef boost::function<bool()> thread_teller_cmd;

namespace epius{namespace thread_switch{

inline void DoWrap(act_post_cmd postCmd, boost::function<void()> cmd)
{
	postCmd(cmd);
}
#define MAKE_DOWRAP_FUN_ONELINE(n,y)																		\
template<LINE_EXPAND_N(n,RBIND,TYPE_PARAM)>																	\
void DoWrap(act_post_cmd postCmd, boost::function<void( LINE_EXPAND_N(n,RBIND,TYPE_PURE) )> cmd, LINE_EXPAND_N(n,RBIND,FUN_PARAM))	\
{																											\
	boost::function<void()> cmd2 = boost::bind(boost::apply<void>(),cmd,LINE_EXPAND_N(n,RBIND,FUN_IMPL) );								\
	postCmd(cmd2);																							\
}
CONSTRUCT(10,MAKE_DOWRAP_FUN_ONELINE);

template<class> class CmdWrapperImpl;
template<class fun_type, int fun_arg_number>struct WrapperCmdHelper;
template<class fun_type>struct WrapperCmdHelper<fun_type, 0>
{
	static fun_type get_wrap_cmd(act_post_cmd postCmd, boost::function<void()> cmd)
	{
		return boost::bind(static_cast<void(*)(act_post_cmd, boost::function<void()>)>(&DoWrap), postCmd, cmd);
	}
};
template<class fun_type>struct WrapperCmdHelper<fun_type, 1>
{
	typedef typename get_fun_arg_typelist<fun_type>::result_type typelist;
	typedef typename Loki::TL::TypeAt<typelist,0>::Result A0;
	static fun_type get_wrap_cmd(act_post_cmd postCmd, fun_type cmd)
	{
		return boost::bind(&DoWrap<A0>, postCmd, cmd, _1);
	}
};
template<class fun_type>struct WrapperCmdHelper<fun_type, 2>
{
	typedef typename get_fun_arg_typelist<fun_type>::result_type typelist;
	typedef typename Loki::TL::TypeAt<typelist,0>::Result A0;
	typedef typename Loki::TL::TypeAt<typelist,1>::Result A1;
	static fun_type get_wrap_cmd(act_post_cmd postCmd, fun_type cmd)
	{
		return boost::bind(&DoWrap<A0,A1>, postCmd,cmd, _1,_2);
	}
};
template<class fun_type>struct WrapperCmdHelper<fun_type, 3>
{
    typedef typename get_fun_arg_typelist<fun_type>::result_type typelist;
    typedef typename Loki::TL::TypeAt<typelist,0>::Result A0;
    typedef typename Loki::TL::TypeAt<typelist,1>::Result A1;
    typedef typename Loki::TL::TypeAt<typelist,2>::Result A2;
    static fun_type get_wrap_cmd(act_post_cmd postCmd, fun_type cmd)
    {
        return boost::bind(&DoWrap<A0,A1,A2>, postCmd,cmd, _1,_2,_3);
    }
};
template<class fun_type>struct WrapperCmdHelper<fun_type, 4>
{
    typedef typename get_fun_arg_typelist<fun_type>::result_type typelist;
    typedef typename Loki::TL::TypeAt<typelist,0>::Result A0;
    typedef typename Loki::TL::TypeAt<typelist,1>::Result A1;
    typedef typename Loki::TL::TypeAt<typelist,2>::Result A2;
    typedef typename Loki::TL::TypeAt<typelist,3>::Result A3;
    static fun_type get_wrap_cmd(act_post_cmd postCmd, fun_type cmd)
    {
        return boost::bind(&DoWrap<A0,A1,A2,A3>, postCmd,cmd, _1,_2,_3,_4);
    }
};
template<class fun_type>struct WrapperCmdHelper<fun_type, 5>
{
    typedef typename get_fun_arg_typelist<fun_type>::result_type typelist;
    typedef typename Loki::TL::TypeAt<typelist,0>::Result A0;
    typedef typename Loki::TL::TypeAt<typelist,1>::Result A1;
    typedef typename Loki::TL::TypeAt<typelist,2>::Result A2;
    typedef typename Loki::TL::TypeAt<typelist,3>::Result A3;
    typedef typename Loki::TL::TypeAt<typelist,4>::Result A4;
    static fun_type get_wrap_cmd(act_post_cmd postCmd, fun_type cmd)
    {
        return boost::bind(&DoWrap<A0,A1,A2,A3,A4>, postCmd,cmd, _1,_2,_3,_4,_5);
    }
};
template<class fun_type>struct WrapperCmdHelper<fun_type, 6>
{
    typedef typename get_fun_arg_typelist<fun_type>::result_type typelist;
    typedef typename Loki::TL::TypeAt<typelist,0>::Result A0;
    typedef typename Loki::TL::TypeAt<typelist,1>::Result A1;
    typedef typename Loki::TL::TypeAt<typelist,2>::Result A2;
    typedef typename Loki::TL::TypeAt<typelist,3>::Result A3;
    typedef typename Loki::TL::TypeAt<typelist,4>::Result A4;
    typedef typename Loki::TL::TypeAt<typelist,5>::Result A5;
    static fun_type get_wrap_cmd(act_post_cmd postCmd, fun_type cmd)
    {
        return boost::bind(&DoWrap<A0,A1,A2,A3,A4,A5>, postCmd,cmd, _1,_2,_3,_4,_5,_6);
    }
};

// #define GET_TYPE_LINE_PARTERN(x,y)  typedef  T1
// #define MAKE_WRAPPER_CMD_HELPER(n,y)			                                        \
// 	template<class fun_type>struct WrapperCmdHelper<fun_type,y>{					    \
//         typedef typename get_fun_arg_typelist<fun_type>::result_type typelist;                                      \
//                                                                    \    
// 	    static fun_type get_wrap_cmd(act_post_cmd postCmd, fun_type cmd){	    \
// 	        return boost::bind(&DoWrap< LINE_EXPAND_N(n,RBIND,TYPE_PURE) >, cmd, LINE_EXPAND_N(n,RBIND,BOOST_ARG)); \
//         }																									        \
//     };
//CONSTRUCT(9,MAKE_WRAPPER_CMD_HELPER);
template<class fun_type>
class CmdWrapperImpl
{
public:
	typedef typename get_member_fun_type<CmdWrapperImpl<fun_type>, fun_type>::result_type member_type;
	enum {fun_arg_number = get_member_fun_type<CmdWrapperImpl<fun_type>, fun_type>::arg_number};
	typedef typename fun_type::result_type result_type;	

	CmdWrapperImpl(act_post_cmd postCmd, fun_type cmd):postCmd_(postCmd), m_cmd(cmd){}
	fun_type get_wrap_cmd()
	{
		return WrapperCmdHelper<fun_type, fun_arg_number>::get_wrap_cmd(postCmd_, m_cmd);
	}


private:
	fun_type m_cmd;//cmd is a kind of boost::function
	act_post_cmd postCmd_;
};

//< @brief CmdWrapper
//introduction: the CmdWrapper is used to switch any command to the specified thread. 
//samples: CmdWrapper(postCmd, realCmd)
//CmdWrapper(cmd)() will equal to cmd(), but the cmd() is executed in the UI thread. 
template<class function_type> function_type CmdWrapper(act_post_cmd postCmd, function_type fun)
{
	CmdWrapperImpl<function_type> tmp(postCmd, fun);
	return tmp.get_wrap_cmd();
}

class WrapHelper
{
public:
	WrapHelper(){}
	WrapHelper(act_post_cmd postCmd){postCmd_ = postCmd;}
	void setPostCmd(act_post_cmd postCmd){postCmd_ = postCmd;}
	template<class FunType> FunType wrap(FunType cmd)
	{
		if(postCmd_.empty())
		{	
			return cmd;
		}
		else
		{
			return CmdWrapper(postCmd_,cmd);
		}
	}
private:
	act_post_cmd postCmd_;
};

}//namespace thread_switch
}//namespace epius