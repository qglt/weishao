// linkedhashmap.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "linkedhashmap.hpp"
#include <string>
#include <map>
#include <boost/shared_ptr.hpp>
#include <boost/multi_index_container.hpp>
#include <boost/multi_index/member.hpp>
#include <boost/multi_index/ordered_index.hpp>
#include <boost/multi_index/sequenced_index.hpp>
#include <boost/multi_index/hashed_index.hpp>
#include <boost/multi_index/identity_fwd.hpp>
#include <boost/tuple/tuple.hpp>
#include <boost/lambda/lambda.hpp>
using namespace std;
using namespace epius;
using namespace boost;
using namespace boost::multi_index;

template<class _Kty,class _Ty>
struct mytest
{
    typedef boost::multi_index_container<
    std::pair<_Kty, _Ty>,
    boost::multi_index::indexed_by<
    boost::multi_index::sequenced<>, // list-like index
    boost::multi_index::hashed_unique< boost::multi_index::member<std::_Pair_base<_Kty,_Ty>,_Kty,&std::pair<_Kty, _Ty>::first > > // hashed index
    >
    > elements;

    elements elems_;
};
struct change_val
{
    void operator()(pair<string,int>& val)
    {
        val = make_pair("hello",33);
    }
};
int _tmain(int argc, _TCHAR* argv[])
{
    typedef multi_index_container<
        pair<string, int>,
        indexed_by<
        sequenced<>,           // 序列索引
        hashed_unique<multi_index::member<_Pair_base<string,int>, string, &pair<string,int>::first > > // 其它索引
        >
    > ss_type;
    ss_type s;
    typedef ss_type::nth_index<1>::type idx_type;
    typedef idx_type::iterator iterator;
    idx_type& idx = s.get<1>();
    pair<iterator, bool> result = idx.insert(std::make_pair("hi",1));
    cout<<"result:"<<result.second<<endl;
    result = idx.insert(std::make_pair("hi",2));
    cout<<"result:"<<result.second<<endl;
    iterator kkk = idx.find("hi");
    idx.modify(idx.begin(),change_val());
    cout<<"kkk is"<<kkk->second<<endl;
    //idx.push_back(std::make_pair("hi",2));
    //s.get<0>().insert(std::make_pair("hi",3));
    //s.get<0>().modify(s.get<0>().begin(),change_val());
    //std::copy(idx.begin(),idx.end(),std::ostream_iterator<int>(std::cout));
    for(idx_type::iterator it = idx.begin();it!=idx.end();++it)
    {
        cout<<it->first<<","<<it->second<<endl;
    }

    mytest<string,int> test_elem;
    //test_elem.elems_.get<0>().insert(std::make_pair(string("hello"),4));

    linkedhashmap<string, int> ttt;
    ttt["dddd"] = 222;
    ttt["eeee"] = 333;
    ttt["cccc"] = 444;
    ttt["cccc"] = 555;
    ttt.erase("cccc");
    for(auto iit = ttt.begin();iit!=ttt.end();++iit)
    {
        cout<<iit->first<<iit->second<<endl;
    }

	return 0;
}

