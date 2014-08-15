#pragma once
#include <boost/shared_ptr.hpp>
#include <boost/multi_index_container.hpp>
#include <boost/multi_index/member.hpp>
#include <boost/multi_index/ordered_index.hpp>
#include <boost/multi_index/sequenced_index.hpp>
#include <boost/multi_index/hashed_index.hpp>
#include <boost/tuple/tuple.hpp>

namespace epius
{
    template<class _Kty, class _Ty>
    class linkedhashmap
    {
		struct l_hash_map_pair
		{
			_Kty	first;
			_Ty		second;
		};
		static l_hash_map_pair make_l_hash_map_pair(_Kty const& key, _Ty const& val)
		{
			l_hash_map_pair ret_val;
			ret_val.first = key;
			ret_val.second = val;
			return ret_val;
		}
    public:
		typedef l_hash_map_pair value_type;
        typedef boost::multi_index_container<
            value_type,
            boost::multi_index::indexed_by<
            boost::multi_index::sequenced<>, // list-like index
            boost::multi_index::hashed_unique< boost::multi_index::member<value_type, _Kty, &value_type::first> > // hashed index
            >
        > elements;
		typedef typename elements::size_type size_type;
        typedef typename elements::template nth_index<0>::type seq_type;
        typedef typename elements::template nth_index<1>::type map_type;
        typedef typename map_type::iterator map_iterator;
        typedef typename seq_type::iterator iterator;
        struct change_value
        {
            change_value(_Ty const& val):val_(val)
            {
            }
            void operator()(value_type& elem)
            {
                elem.second = val_;
            }
            _Ty val_;
        };
        struct node_for_map_of_linkedhashmap
        {
            map_type& map_idx_;
            map_iterator curr_it;
            node_for_map_of_linkedhashmap(map_type& idx, map_iterator it):map_idx_(idx), curr_it(it){}
            operator _Ty&(){return const_cast<_Ty&>(curr_it->second);}
            void operator = (_Ty const& val)
            {
                map_idx_.modify(curr_it,change_value(val));
            }
            _Ty* operator -> ()
            {
                return &curr_it->second;
            }
        };
        bool insert(const value_type& _Val)
        {
            map_type &idx = link_elem_.template get<1>();
            std::pair<iterator, bool> result = idx.insert(_Val);
            return result.second;
        }
		size_type size() const
		{
			return link_elem_.size();
		}
		// iterator will follow the insert order
        iterator begin()
        {
            //key_type idx = link_elem_.get<key_type>();
            return link_elem_.begin();
        }
        iterator end()
        {
            return link_elem_.end();
        }
		// map_iterator will follow the key order
		map_iterator kbegin()
		{
			map_type &idx = link_elem_.template get<1>();
			return idx.end();
		}
		map_iterator kend()
		{
			map_type &idx = link_elem_.template get<1>();
			return idx.end();
		}
		map_iterator find(_Kty const& key)
		{
			map_type &idx = link_elem_.template get<1>();
			map_iterator it = idx.find(key);
			return it;
		}
        void erase(_Kty const& key)
        {
            map_type &idx = link_elem_.template get<1>();
            idx.erase(key);
        }
        node_for_map_of_linkedhashmap operator[](_Kty const& key)
        {
            map_type &idx = link_elem_.template get<1>();
            map_iterator it = idx.find(key);
            if(it!=idx.end())
            {
                return node_for_map_of_linkedhashmap(idx,it);
            }
            else
            {
                std::pair<map_iterator, bool> result = idx.insert(make_l_hash_map_pair(key, _Ty()));
                return node_for_map_of_linkedhashmap(idx,result.first);
            }
        }
        protected:
            elements link_elem_;
    };
}
