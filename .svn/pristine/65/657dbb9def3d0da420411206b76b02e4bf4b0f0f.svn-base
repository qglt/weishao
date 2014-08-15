/*
* The file is to chain a series of commands to one
* Copyright (c) 2009 Yang Cheng
*
* Use, modification, and distribution are  subject to the
* Boost Software License, Version 1.0. (See accompanying  file
* LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
*
* 
*/
namespace epius { 
    template<class T> class chain_base
    {
    public:
        void add(T cmd){cmd_list_.push_back(cmd);}
    private:
        std::deque<T> cmd_list_;
    };
    template<class T> class Chain:public chain_base<T>;

    template<>
	class Chain<boost::function<void()> >:public chain_base<boost::function<void()> >
	{
    public:
		void operator()() {for_each(cmd_list_.begin(),cmd_list_.end())}
	};
	template<class L> L fun_chain(boost::function<void()> cmd,L l)
	{
		Chain<L> ret;
        ret.add(cmd);

	}
}

