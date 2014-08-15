//---------------------------------------------------
// Copyright (C) 2012, All rights reserved
//
// descrption: entrypoint file.
// ver: 2.0
// auther: majiazhi
// date: (YMD)2012/06/28
//---------------------------------------------------

#pragma once

# ifndef a_assert
#	 if defined(_DEBUG)
#	    define a_assert(x) do{ if (!(x)) __asm { int 3 } }while(0)
#	 else
#	    define a_assert(x)
#	 endif
# endif


# ifndef assert_times
#	 if defined(_DEBUG)
#	    define assert_times(x) do{static int ___times__ = (x);a_assert(___times__--);}while(0)
#	 else
#	    define assert_times(x)
#	 endif
# endif

#define do_times(x, doing) \
	do {int __i_tmp_times__ = (x); while(--__i_tmp_times__) {doing;} }while(0)

#define do_if(x, doing) do if((x)){ doing; }while(0)
#define rif(x,ret) do if((x)){return (ret);}while(0)
#define rifn(x,ret) do if(!(x)){return (ret);}while(0)
#define rifeq(x,val,ret) do if((x) == (val)){return (ret);}while(0)
#define rifne(x,val,ret) do if((x) != (val)){return (ret);}while(0)
#define riflt(x,val,ret) do if((x) < (val)){return (ret);}while(0)
#define rifgt(x,val,ret) do if((x) > (val)){return (ret);}while(0)
#define rifle(x,val,ret) do if((x) <= (val)){return (ret);}while(0)
#define rifge(x,val,ret) do if((x) >= (val)){return (ret);}while(0)

#define do_if_assert(x, doing) do if((x)){ a_assert(false); doing; }while(0)
#define rif_assert(x,ret) do if((x)){a_assert(false); return (ret);}while(0)
#define rifn_assert(x,ret) do if(!(x)){a_assert(false); return (ret);}while(0)
#define rifeq_assert(x,val,ret) do if((x)==(val)){a_assert(false); return (ret);}while(0)
#define rifne_assert(x,val,ret) do if((x)!=(val)){a_assert(false); return (ret);}while(0)
#define riflt_assert(x,val,ret) do if((x)<(val)){a_assert(false); return (ret);}while(0)
#define rifgt_assert(x,val,ret) do if((x)>(val)){a_assert(false); return (ret);}while(0)
#define rifle_assert(x,val,ret) do if((x)<=(val)){a_assert(false); return (ret);}while(0)
#define rifge_assert(x,val,ret) do if((x)>=(val)){a_assert(false); return (ret);}while(0)
