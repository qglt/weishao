//  tuple_basic.hpp -----------------------------------------------------

// Copyright (C) 1999, 2000 Jaakko Jarvi (jaakko.jarvi@cs.utu.fi)
//
// Distributed under the Boost Software License, Version 1.0. (See
// accompanying file LICENSE_1_0.txt or copy at
// http://www.boost.org/LICENSE_1_0.txt)

// For more information, see http://www.boost.org

// Outside help:
// This and that, Gary Powell.
// Fixed return types for get_head/get_tail
// ( and other bugs ) per suggestion of Jens Maurer
// simplified element type accessors + bug fix  (Jeremy Siek)
// Several changes/additions according to suggestions by Douglas Gregor,
// William Kempf, Vesa Karvonen, John Max Skaller, Ed Brey, Beman Dawes,
// David Abrahams.

// Revision history:
// 2002 05 01 Hugo Duncan: Fix for Borland after Jaakko's previous changes
// 2002 04 18 Jaakko: tuple element types can be void or plain function
//                    types, as long as no object is created.
//                    Tuple objects can no hold even noncopyable types
//                    such as arrays.
// 2001 10 22 John Maddock
//      Fixes for Borland C++
// 2001 08 30 David Abrahams
//      Added default constructor for cons<>.
// -----------------------------------------------------------------

#ifndef EPIUS_TUPLE_BASIC_HPP
#define EPIUS_TUPLE_BASIC_HPP


#include <utility> // needed for the assignment from pair to tuple

#include "boost/type_traits/cv_traits.hpp"
#include "boost/type_traits/function_traits.hpp"
#include "boost/utility/swap.hpp"

#include "boost/detail/workaround.hpp" // needed for BOOST_WORKAROUND
#include <base/utility/macro_helper/meta_macro.h>
namespace epius {
	//using namespace boost;
	using boost::reference_wrapper;
namespace tuples {

// -- null_type --------------------------------------------------------
struct null_type {};

// a helper function to provide a const null_type type temporary
namespace detail {
  inline const null_type cnull() { return null_type(); }


// -- if construct ------------------------------------------------
// Proposed by Krzysztof Czarnecki and Ulrich Eisenecker

template <bool If, class Then, class Else> struct IF { typedef Then RET; };

template <class Then, class Else> struct IF<false, Then, Else> {
  typedef Else RET;
};

} // end detail

// - cons forward declaration -----------------------------------------------
template <class HT, class TT> struct cons;

#define TYPE_PARAM_NULL(x,y) typename T##y = null_type
// - tuple forward declaration -----------------------------------------------
template < LINE_EXPAND(RBIND,TYPE_PARAM_NULL) >
class tuple;

// template <
// 	class T0 = null_type, class T1 = null_type, class T2 = null_type,
// 	class T3 = null_type, class T4 = null_type, class T5 = null_type,
// 	class T6 = null_type, class T7 = null_type, class T8 = null_type,
// 	class T9 = null_type>
// class tuple;

// tuple_length forward declaration
template<class T> struct length;



namespace detail {

// -- generate error template, referencing to non-existing members of this
// template is used to produce compilation errors intentionally
template<class T>
class generate_error;

template<int N>
struct drop_front {
    template<class Tuple>
    struct apply {
        typedef BOOST_DEDUCED_TYPENAME drop_front<N-1>::BOOST_NESTED_TEMPLATE
            apply<Tuple> next;
        typedef BOOST_DEDUCED_TYPENAME next::type::tail_type type;
        static const type& call(const Tuple& tup) {
            return next::call(tup).tail;
        }
    };
};

template<>
struct drop_front<0> {
    template<class Tuple>
    struct apply {
        typedef Tuple type;
        static const type& call(const Tuple& tup) {
            return tup;
        }
    };
};

} // end of namespace detail


// -cons type accessors ----------------------------------------
// typename tuples::element<N,T>::type gets the type of the
// Nth element ot T, first element is at index 0
// -------------------------------------------------------

#ifndef BOOST_NO_CV_SPECIALIZATIONS

template<int N, class T>
struct element
{
  typedef BOOST_DEDUCED_TYPENAME detail::drop_front<N>::BOOST_NESTED_TEMPLATE
      apply<T>::type::head_type type;
};

template<int N, class T>
struct element<N, const T>
{
private:
  typedef BOOST_DEDUCED_TYPENAME detail::drop_front<N>::BOOST_NESTED_TEMPLATE
      apply<T>::type::head_type unqualified_type;
public:
#if BOOST_WORKAROUND(__BORLANDC__,<0x600)
  typedef const unqualified_type type;
#else
  typedef BOOST_DEDUCED_TYPENAME boost::add_const<unqualified_type>::type type;
#endif
};
#else // def BOOST_NO_CV_SPECIALIZATIONS

namespace detail {

template<int N, class T, bool IsConst>
struct element_impl
{
  typedef BOOST_DEDUCED_TYPENAME detail::drop_front<N>::BOOST_NESTED_TEMPLATE
      apply<T>::type::head_type type;
};

template<int N, class T>
struct element_impl<N, T, true /* IsConst */>
{
  typedef BOOST_DEDUCED_TYPENAME detail::drop_front<N>::BOOST_NESTED_TEMPLATE
      apply<T>::type::head_type unqualified_type;
  typedef const unqualified_type type;
};

} // end of namespace detail


template<int N, class T>
struct element:
  public detail::element_impl<N, T, ::boost::is_const<T>::value>
{
};

#endif


// -get function templates -----------------------------------------------
// Usage: get<N>(aTuple)

// -- some traits classes for get functions

// access traits lifted from detail namespace to be part of the interface,
// (Joel de Guzman's suggestion). Rationale: get functions are part of the
// interface, so should the way to express their return types be.

template <class T> struct access_traits {
  typedef const T& const_type;
  typedef T& non_const_type;

  typedef const typename boost::remove_cv<T>::type& parameter_type;

// used as the tuple constructors parameter types
// Rationale: non-reference tuple element types can be cv-qualified.
// It should be possible to initialize such types with temporaries,
// and when binding temporaries to references, the reference must
// be non-volatile and const. 8.5.3. (5)
};

template <class T> struct access_traits<T&> {

  typedef T& const_type;
  typedef T& non_const_type;

  typedef T& parameter_type;
};

// get function for non-const cons-lists, returns a reference to the element

template<int N, class HT, class TT>
inline typename access_traits<
                  typename element<N, cons<HT, TT> >::type
                >::non_const_type
get(cons<HT, TT>& c BOOST_APPEND_EXPLICIT_TEMPLATE_NON_TYPE(int, N)) {
  typedef BOOST_DEDUCED_TYPENAME detail::drop_front<N>::BOOST_NESTED_TEMPLATE
      apply<cons<HT, TT> > impl;
  typedef BOOST_DEDUCED_TYPENAME impl::type cons_element;
  return const_cast<cons_element&>(impl::call(c)).head;
}

// get function for const cons-lists, returns a const reference to
// the element. If the element is a reference, returns the reference
// as such (that is, can return a non-const reference)
template<int N, class HT, class TT>
inline typename access_traits<
                  typename element<N, cons<HT, TT> >::type
                >::const_type
get(const cons<HT, TT>& c BOOST_APPEND_EXPLICIT_TEMPLATE_NON_TYPE(int, N)) {
  typedef BOOST_DEDUCED_TYPENAME detail::drop_front<N>::BOOST_NESTED_TEMPLATE
      apply<cons<HT, TT> > impl;
  typedef BOOST_DEDUCED_TYPENAME impl::type cons_element;
  return impl::call(c).head;
}

// -- the cons template  --------------------------------------------------
namespace detail {

//  These helper templates wrap void types and plain function types.
//  The reationale is to allow one to write tuple types with those types
//  as elements, even though it is not possible to instantiate such object.
//  E.g: typedef tuple<void> some_type; // ok
//  but: some_type x; // fails

template <class T> class non_storeable_type {
  non_storeable_type();
};

template <class T> struct wrap_non_storeable_type {
  typedef typename IF<
    ::boost::is_function<T>::value, non_storeable_type<T>, T
  >::RET type;
};
template <> struct wrap_non_storeable_type<void> {
  typedef non_storeable_type<void> type;
};

} // detail

template <class HT, class TT>
struct cons {

  typedef HT head_type;
  typedef TT tail_type;

  typedef typename
    detail::wrap_non_storeable_type<head_type>::type stored_head_type;

  stored_head_type head;
  tail_type tail;

  typename access_traits<stored_head_type>::non_const_type
  get_head() { return head; }

  typename access_traits<tail_type>::non_const_type
  get_tail() { return tail; }

  typename access_traits<stored_head_type>::const_type
  get_head() const { return head; }

  typename access_traits<tail_type>::const_type
  get_tail() const { return tail; }

  cons() : head(), tail() {}
  //  cons() : head(detail::default_arg<HT>::f()), tail() {}

  // the argument for head is not strictly needed, but it prevents
  // array type elements. This is good, since array type elements
  // cannot be supported properly in any case (no assignment,
  // copy works only if the tails are exactly the same type, ...)

  cons(typename access_traits<stored_head_type>::parameter_type h,
       const tail_type& t)
    : head (h), tail(t) {}

  template < LINE_EXPAND(RBIND,TYPE_PARAM) >
  cons( LINE_EXPAND(RBIND,FUN_REF_PARAM) )
    : head (p1),
      tail (LINE_EXPAND(RBIND2BG,FUN_IMPL), detail::cnull())
      {}

//   template <class T1, class T2, class T3, class T4, class T5,
//             class T6, class T7, class T8, class T9, class T10>
//   cons( T1& t1, T2& t2, T3& t3, T4& t4, T5& t5,
//         T6& t6, T7& t7, T8& t8, T9& t9, T10& t10 )
//     : head (t1),
//       tail (t2, t3, t4, t5, t6, t7, t8, t9, t10, detail::cnull())
//       {}
  template <LINE_EXPAND(RBIND,TYPE_PARAM)>
  cons( const null_type& /*p1*/, LINE_EXPAND(RBIND2BG,FUN_REF_PARAM))
    : head (),
      tail (LINE_EXPAND(RBIND2BG,FUN_IMPL), detail::cnull())
      {}

//   template <class T2, class T3, class T4, class T5,
//             class T6, class T7, class T8, class T9, class T10>
//   cons( const null_type& /*t1*/, T2& t2, T3& t3, T4& t4, T5& t5,
//         T6& t6, T7& t7, T8& t8, T9& t9, T10& t10 )
//     : head (),
//       tail (t2, t3, t4, t5, t6, t7, t8, t9, t10, detail::cnull())
//       {}


  template <class HT2, class TT2>
  cons( const cons<HT2, TT2>& u ) : head(u.head), tail(u.tail) {}

  template <class HT2, class TT2>
  cons& operator=( const cons<HT2, TT2>& u ) {
    head=u.head; tail=u.tail; return *this;
  }

  // must define assignment operator explicitly, implicit version is
  // illformed if HT is a reference (12.8. (12))
  cons& operator=(const cons& u) {
    head = u.head; tail = u.tail;  return *this;
  }

  template <class T1, class T2>
  cons& operator=( const std::pair<T1, T2>& u ) {
    BOOST_STATIC_ASSERT(length<cons>::value == 2); // check length = 2
    head = u.first; tail.head = u.second; return *this;
  }

  // get member functions (non-const and const)
  template <int N>
  typename access_traits<
             typename element<N, cons<HT, TT> >::type
           >::non_const_type
  get() {
    return epius::tuples::get<N>(*this); // delegate to non-member get
  }

  template <int N>
  typename access_traits<
             typename element<N, cons<HT, TT> >::type
           >::const_type
  get() const {
    return epius::tuples::get<N>(*this); // delegate to non-member get
  }
};

template <class HT>
struct cons<HT, null_type> {

  typedef HT head_type;
  typedef null_type tail_type;
  typedef cons<HT, null_type> self_type;

  typedef typename
    detail::wrap_non_storeable_type<head_type>::type stored_head_type;
  stored_head_type head;

  typename access_traits<stored_head_type>::non_const_type
  get_head() { return head; }

  null_type get_tail() { return null_type(); }

  typename access_traits<stored_head_type>::const_type
  get_head() const { return head; }

  const null_type get_tail() const { return null_type(); }

  //  cons() : head(detail::default_arg<HT>::f()) {}
  cons() : head() {}

  cons(typename access_traits<stored_head_type>::parameter_type h,
       const null_type& = null_type())
    : head (h) {}

#define CONS_NULL_TYPE(x,y) const null_type&

  template<class T1>
  cons(T1& t1, LINE_EXPAND(RBIND2BG,CONS_NULL_TYPE))
  : head (t1) {}

//   template<class T1>
//   cons(T1& t1, const null_type&, const null_type&, const null_type&,
//        const null_type&, const null_type&, const null_type&,
//        const null_type&, const null_type&, const null_type&)
//   : head (t1) {}
  cons(LINE_EXPAND(RBIND,CONS_NULL_TYPE))
  : head () {}

//   cons(const null_type&,
//        const null_type&, const null_type&, const null_type&,
//        const null_type&, const null_type&, const null_type&,
//        const null_type&, const null_type&, const null_type&)
//   : head () {}

  template <class HT2>
  cons( const cons<HT2, null_type>& u ) : head(u.head) {}

  template <class HT2>
  cons& operator=(const cons<HT2, null_type>& u )
  { head = u.head; return *this; }

  // must define assignment operator explicitely, implicit version
  // is illformed if HT is a reference
  cons& operator=(const cons& u) { head = u.head; return *this; }

  template <int N>
  typename access_traits<
             typename element<N, self_type>::type
            >::non_const_type
  get(BOOST_EXPLICIT_TEMPLATE_NON_TYPE(int, N)) {
    return epius::tuples::get<N>(*this);
  }

  template <int N>
  typename access_traits<
             typename element<N, self_type>::type
           >::const_type
  get(BOOST_EXPLICIT_TEMPLATE_NON_TYPE(int, N)) const {
    return epius::tuples::get<N>(*this);
  }

};

// templates for finding out the length of the tuple -------------------

template<class T>
struct length  {
  BOOST_STATIC_CONSTANT(int, value = 1 + length<typename T::tail_type>::value);
};

template<>
struct length<tuple<> > {
  BOOST_STATIC_CONSTANT(int, value = 0);
};

template<>
struct length<tuple<> const> {
  BOOST_STATIC_CONSTANT(int, value = 0);
};

template<>
struct length<null_type> {
  BOOST_STATIC_CONSTANT(int, value = 0);
};

template<>
struct length<null_type const> {
  BOOST_STATIC_CONSTANT(int, value = 0);
};

namespace detail {

// Tuple to cons mapper --------------------------------------------------

//#define CONSTRUCT_MAP_TUPLE_CONS(x,y) template< EXPAND(x) > struct map_tuple_to_cons{typedef cons<T1, typename map_tuple_to_cons< EXPAND(y), null_type>::type> type; };
//CONSTRUCT_ONELINE(MAX_MEMBER_NUMBER,CONSTRUCT_MAP_TUPLE_CONS,RBIND,TYPE_PARAM,RBIND2BG,TYPE_PURE)
template <LINE_EXPAND(RBIND,TYPE_PARAM)>
struct map_tuple_to_cons
{
  typedef cons<T1,
               typename map_tuple_to_cons<LINE_EXPAND(RBIND2BG,TYPE_PURE), null_type>::type
              > type;
};

// template <class T0, class T1, class T2, class T3, class T4,
//           class T5, class T6, class T7, class T8, class T9>
// struct map_tuple_to_cons
// {
//   typedef cons<T0,
//                typename map_tuple_to_cons<T1, T2, T3, T4, T5,
//                                           T6, T7, T8, T9, null_type>::type
//               > type;
// };

// The empty tuple is a null_type
#define NULL_TYPE(x,y) null_type

template <>
struct map_tuple_to_cons< LINE_EXPAND(RBIND,NULL_TYPE) >
{
	typedef null_type type;
};
// template <>
// struct map_tuple_to_cons<null_type, null_type, null_type, null_type, null_type, null_type, null_type, null_type, null_type, null_type>
// {
// 	typedef null_type type;
// };

} // end detail

// -------------------------------------------------------------------
// -- tuple ------------------------------------------------------
template < LINE_EXPAND(RBIND,TYPE_PARAM)>
// template <class T0, class T1, class T2, class T3, class T4,
//           class T5, class T6, class T7, class T8, class T9>

class tuple :
		public detail::map_tuple_to_cons<LINE_EXPAND(RBIND,TYPE_PURE)>::type
	//  public detail::map_tuple_to_cons<T0, T1, T2, T3, T4, T5, T6, T7, T8, T9>::type
{
public:
  typedef typename
	  detail::map_tuple_to_cons<LINE_EXPAND(RBIND,TYPE_PURE)>::type inherited;
//    detail::map_tuple_to_cons<T0, T1, T2, T3, T4, T5, T6, T7, T8, T9>::type inherited;
  typedef typename inherited::head_type head_type;
  typedef typename inherited::tail_type tail_type;


// access_traits<T>::parameter_type takes non-reference types as const T&
  tuple() {}
#define TUPLE_CONSTRUCT_PARAM_PARTERN(x,y)  typename access_traits<T ##y>::parameter_type p ##y
#define TUPLE_CONSTRUCT_NULL_TYPE(x,y) detail::cnull()
#define TUPLE_CONSTRUCT_PARAM(n) LINE_EXPAND_N(n,RBIND,FUN_IMPL), LINE_EXPAND_N(MAX_MEMBER_NUMBER_DEC_##n , RBIND, TUPLE_CONSTRUCT_NULL_TYPE)
#define TYPLE_CONSTRUCT_ONELINE(n,y) tuple(LINE_EXPAND_N(n,RBIND,TUPLE_CONSTRUCT_PARAM_PARTERN)):inherited(TUPLE_CONSTRUCT_PARAM(n)){}
CONSTRUCT(MAX_MEMBER_NUMBER_DEC_1,TYPLE_CONSTRUCT_ONELINE);
//   tuple(LINE_EXPAND_N(1,RBIND,TUPLE_CONSTRUCT_PARAM_PARTERN))
//     : inherited(TUPLE_CONSTRUCT_PARAM(1)) {}
// 
//   tuple(LINE_EXPAND_N(2,RBIND,TUPLE_CONSTRUCT_PARAM_PARTERN))
//     : inherited(TUPLE_CONSTRUCT_PARAM(2)) {}

//   tuple(typename access_traits<T1>::parameter_type t0,
//         typename access_traits<T2>::parameter_type t1,
//         typename access_traits<T3>::parameter_type t2)
//     : inherited(t0, t1, t2, detail::cnull(), detail::cnull(),
//                 detail::cnull(), detail::cnull(), detail::cnull(),
//                 detail::cnull(), detail::cnull()) {}
// 
// ......
  tuple(LINE_EXPAND(RBIND,TUPLE_CONSTRUCT_PARAM_PARTERN))
    : inherited(LINE_EXPAND(RBIND,FUN_IMPL)) {}


  template<class U1, class U2>
  tuple(const cons<U1, U2>& p) : inherited(p) {}

  template <class U1, class U2>
  tuple& operator=(const cons<U1, U2>& k) {
    inherited::operator=(k);
    return *this;
  }

  template <class U1, class U2>
  tuple& operator=(const std::pair<U1, U2>& k) {
    BOOST_STATIC_ASSERT(length<tuple>::value == 2);// check_length = 2
    this->head = k.first;
    this->tail.head = k.second;
    return *this;
  }

};

// The empty tuple
template <>
class tuple<LINE_EXPAND(RBIND,NULL_TYPE)>  :
  public null_type
{
public:
  typedef null_type inherited;
};


// Swallows any assignment   (by Doug Gregor)
namespace detail {

struct swallow_assign;
typedef void (detail::swallow_assign::*ignore_t)();
struct swallow_assign {
  swallow_assign(ignore_t(*)(ignore_t)) {}
  template<typename T>
  swallow_assign const& operator=(const T&) const {
    return *this;
  }
};


} // namespace detail

// "ignore" allows tuple positions to be ignored when using "tie".
inline detail::ignore_t ignore(detail::ignore_t) { return 0; }

// ---------------------------------------------------------------------------
// The call_traits for make_tuple
// Honours the reference_wrapper class.

// Must be instantiated with plain or const plain types (not with references)

// from template<class T> foo(const T& t) : make_tuple_traits<const T>::type
// from template<class T> foo(T& t) : make_tuple_traits<T>::type

// Conversions:
// T -> T,
// references -> compile_time_error
// reference_wrapper<T> -> T&
// const reference_wrapper<T> -> T&
// array -> const ref array


template<class T>
struct make_tuple_traits {
  typedef T type;

  // commented away, see below  (JJ)
  //  typedef typename IF<
  //  boost::is_function<T>::value,
  //  T&,
  //  T>::RET type;

};

// The is_function test was there originally for plain function types,
// which can't be stored as such (we must either store them as references or
// pointers). Such a type could be formed if make_tuple was called with a
// reference to a function.
// But this would mean that a const qualified function type was formed in
// the make_tuple function and hence make_tuple can't take a function
// reference as a parameter, and thus T can't be a function type.
// So is_function test was removed.
// (14.8.3. says that type deduction fails if a cv-qualified function type
// is created. (It only applies for the case of explicitly specifying template
// args, though?)) (JJ)

template<class T>
struct make_tuple_traits<T&> {
  typedef typename
     detail::generate_error<T&>::
       do_not_use_with_reference_type error;
};

// Arrays can't be stored as plain types; convert them to references.
// All arrays are converted to const. This is because make_tuple takes its
// parameters as const T& and thus the knowledge of the potential
// non-constness of actual argument is lost.
template<class T, int n>  struct make_tuple_traits <T[n]> {
  typedef const T (&type)[n];
};

template<class T, int n>
struct make_tuple_traits<const T[n]> {
  typedef const T (&type)[n];
};

template<class T, int n>  struct make_tuple_traits<volatile T[n]> {
  typedef const volatile T (&type)[n];
};

template<class T, int n>
struct make_tuple_traits<const volatile T[n]> {
  typedef const volatile T (&type)[n];
};

template<class T>
struct make_tuple_traits<reference_wrapper<T> >{
  typedef T& type;
};

template<class T>
struct make_tuple_traits<const reference_wrapper<T> >{
  typedef T& type;
};

template<>
struct make_tuple_traits<detail::ignore_t(detail::ignore_t)> {
  typedef detail::swallow_assign type;
};



namespace detail {

// a helper traits to make the make_tuple functions shorter (Vesa Karvonen's
// suggestion)
template < LINE_EXPAND(RBIND,TYPE_PARAM_NULL)>
struct make_tuple_mapper {
  typedef
#define MAKE_TUPLE_TRAIT_TYPES(x,y) typename make_tuple_traits<T ##y>::type 
    tuple<LINE_EXPAND(RBIND,MAKE_TUPLE_TRAIT_TYPES)> type;
};

} // end detail

// -make_tuple function templates -----------------------------------
inline tuple<> make_tuple() {
  return tuple<>();
}
#define MAKE_TUPLE_FUNCTION_DEFINE_ONELINE(n,x)																					\
template<LINE_EXPAND_N(n,RBIND,TYPE_PARAM)> inline typename detail::make_tuple_mapper< LINE_EXPAND_N(n,RBIND,TYPE_PURE) >::type \
make_tuple(LINE_EXPAND_N(n,RBIND,FUN_CONST_REF_PARAM)) {																		\
  typedef typename detail::make_tuple_mapper<LINE_EXPAND_N(n,RBIND,TYPE_PURE)>::type t;											\
  return t(LINE_EXPAND_N(n,RBIND,FUN_IMPL));																					\
}

CONSTRUCT(MAX_MEMBER_NUMBER, MAKE_TUPLE_FUNCTION_DEFINE_ONELINE)


namespace detail {

template<class T>
struct tie_traits {
  typedef T& type;
};

template<>
struct tie_traits<ignore_t(ignore_t)> {
  typedef swallow_assign type;
};

template<>
struct tie_traits<void> {
  typedef null_type type;
};
#define TYPE_VOID(x,y) class T##y = void
template <LINE_EXPAND(RBIND,TYPE_VOID)
>
#define TIE_TYPE_TRAIT(x,y) typename tie_traits<T ##y>::type
struct tie_mapper {
  typedef
    tuple< LINE_EXPAND(RBIND,TIE_TYPE_TRAIT)
	> type;
};

}

// Tie function templates -------------------------------------------------
#define TIE_FUNCTION_ONELINE(n,x) \
template<LINE_EXPAND_N(n,RBIND,TYPE_PARAM)>	\
inline typename detail::tie_mapper<LINE_EXPAND_N(n,RBIND,TYPE_PURE)>::type	\
tie(LINE_EXPAND_N(n,RBIND,FUN_REF_PARAM)) {			\
  typedef typename detail::tie_mapper<LINE_EXPAND_N(n,RBIND,TYPE_PURE)>::type t;	\
  return t(LINE_EXPAND_N(n,RBIND,FUN_IMPL));\
}

CONSTRUCT(MAX_MEMBER_NUMBER,TIE_FUNCTION_ONELINE)


template <LINE_EXPAND(RBIND,TYPE_PARAM)>
void swap(tuple<LINE_EXPAND(RBIND,TYPE_PURE)>& lhs,
          tuple<LINE_EXPAND(RBIND,TYPE_PURE)>& rhs);
inline void swap(null_type&, null_type&) {}
template<class HH>
inline void swap(cons<HH, null_type>& lhs, cons<HH, null_type>& rhs) {
  ::boost::swap(lhs.head, rhs.head);
}
template<class HH, class TT>
inline void swap(cons<HH, TT>& lhs, cons<HH, TT>& rhs) {
  ::boost::swap(lhs.head, rhs.head);
  ::epius::tuples::swap(lhs.tail, rhs.tail);
}
template <LINE_EXPAND(RBIND,TYPE_PARAM)>
inline void swap(tuple<LINE_EXPAND(RBIND,TYPE_PURE)>& lhs,
          tuple<LINE_EXPAND(RBIND,TYPE_PURE)>& rhs) {
  typedef tuple<LINE_EXPAND(RBIND,TYPE_PURE)> tuple_type;
  typedef typename tuple_type::inherited base;
  ::epius::tuples::swap(static_cast<base&>(lhs), static_cast<base&>(rhs));
}

} // end of namespace tuples
} // end of namespace epius


#endif // EPIUS_TUPLE_BASIC_HPP


