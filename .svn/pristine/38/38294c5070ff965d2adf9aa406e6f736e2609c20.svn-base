//---------------------------------------------------
// Copyright (C) 2012, All rights reserved
//
// descrption: entrypoint file.
// ver: 2.0
// auther: majiazhi
// date: (YMD)2012/07/04
//---------------------------------------------------

#pragma once

namespace biz {

template<class T>
class anan_biz_bind
{
public:
	void set_parent_impl(T* pthat);
	T* get_parent_impl() const;
private:
	T* pthat_;
};

template<class T>
T* anan_biz_bind<T>::get_parent_impl() const
{
	return pthat_;
}

template<class T>
void anan_biz_bind<T>::set_parent_impl( T* pthat )
{
	pthat_ = pthat;
}


#define THREAD_FUNCTION1() \
	if (!get_parent_impl()->_p_private_task_->is_in_work_thread()) { \
	do ; while(0)

#define THREAD_FUNCTION2() \
	return; } \
	do;while(0)

#define NEXT_THREAD_PART1( F ) get_parent_impl()->_p_private_task_->post(boost::bind(F
#define NEXT_THREAD_PART2() this
#define NEXT_THREAD_FUNCTION0( F ) \
	NEXT_THREAD_PART1(F), NEXT_THREAD_PART2()))

#define NEXT_THREAD_FUNCTIONx( F, ... ) \
	NEXT_THREAD_PART1(F), NEXT_THREAD_PART2(), __VA_ARGS__))
	
#define IN_TASK_THREAD_WORKx(F, ... ) \
	THREAD_FUNCTION1(); \
	NEXT_THREAD_FUNCTIONx( &F, __VA_ARGS__); \
	THREAD_FUNCTION2()

#define IN_TASK_THREAD_WORKxo(F, ... ) \
	THREAD_FUNCTION1(); \
	NEXT_THREAD_FUNCTIONx( F, __VA_ARGS__); \
	THREAD_FUNCTION2()

#define IN_TASK_THREAD_WORK0(F) \
	THREAD_FUNCTION1(); \
	NEXT_THREAD_FUNCTION0(&F); \
	THREAD_FUNCTION2()


}; // biz