#pragma once

#include <boost/make_shared.hpp>

template<typename T> boost::shared_ptr<T> make_shared_ptr(T val) {return boost::shared_ptr<T>(new T(val));}
template<typename T> boost::shared_ptr<T> make_shared_ptr(T* ptr) {return boost::shared_ptr<T>(ptr);}
