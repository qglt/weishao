#pragma once
#ifndef __MACRO_EPEIUS_LIB__
#define __MACRO_EPEIUS_LIB__

#include "macro_helper.hpp"

#define EXPAND(...) __VA_ARGS__
#define NAME_AND_VAR(x,y) #x,x
#define PAD_COMMA ,
#define PAD_SEMICOLON ;

#define ONE_NUM(x,y) y
#define NUM_SEQ_MACRO(n,...) RBIND(n,COMMA,ONE_NUM,__VA_ARGS__)

#define TYPE_PARAM(x,y) typename T##y
#define TYPE_PURE(x,y) T##y
#define ONLY_TYPE(x,y)	typename

#define FUN_CONST_REF_PARAM(x,y) T##y const &p##y
#define FUN_REF_PARAM(x,y) T##y &p##y
#define FUN_PARAM(x,y) T##y p##y
#define BOOST_ARG(x,y) _##y
#define FUN_IMPL(x,y) p##y
#define BIND_ARG(x,y) _##y

#define ELEMENT_EXPAND(n,expand_way, pad, x) expand_way(n,pad,x)

#define LINE_EXPAND(expand_way,parttern) ELEMENT_EXPAND(MAX_MEMBER_NUMBER,expand_way,COMMA,parttern)
#define LINE_EXPAND_N(n, expand_way,parttern) ELEMENT_EXPAND(n,expand_way,COMMA,parttern)
#define CONSTRUCT(n,p) TBIND(n,SEMICOLON,p,NUM_SEQ_MACRO(n))

#endif