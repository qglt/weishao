/*
 * TinyJson 2.0.0
 * A Minimalistic JSON Reader Based On Boost.Spirit, Boost.Any, and Boost.Smart_Ptr.
 *
 * Copyright (c) 2008 Thomas Jansen (thomas@beef.de)
 *
 * Distributed under the Boost Software License, Version 1.0. (See accompanying
 * file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
 *
 * See http://blog.beef.de/projects/tinyjson/ for documentation.
 *
 * 01 Nov 2011 - support arr_push, support parse array, support data type conversion, fix wstring bug, support QString, refactor the code. (Cheng Yang)
 * 10 Oct 2011 - support [][] to assign value. also support assign char* const* as the value. add unittest for the lib.(Cheng Yang)
 * 15 Jun 2011 - use jobject_basic to access grammar, also add the to_string, and add operations (Cheng Yang)
 * 29 Mar 2008 - use strict_real_p for number parsing, small cleanup (Thomas Jansen)
 * 26 Mar 2008 - made json::grammar a template (Boris Schaeling)
 * 20 Mar 2008 - optimized by using shared_ptr (Thomas Jansen)
 * 29 Jan 2008 - Small bugfixes (Thomas Jansen)
 * 04 Jan 2008 - Released to the public (Thomas Jansen)
 * 13 Nov 2007 - initial release (Thomas Jansen) *
 *
 * 29 Mar 2008
 */
#pragma once

#ifndef	TINYJSON_HPP
#define	TINYJSON_HPP
#define		BOOST_SPIRIT_THREADSAFE
#include	<string>
#include	<stack>
#include	<deque>
#include	<map>
#include	<boost/bind/bind.hpp>
#include    <boost/bind/apply.hpp>
#include	<boost/shared_ptr.hpp>
#include	<boost/any.hpp>
#include	<boost/spirit/include/classic_core.hpp>
#include	<boost/spirit/include/classic_loops.hpp>
#include	<boost/format.hpp>
#include	<boost/lexical_cast.hpp>
#include    <boost/foreach.hpp>
#include	<boost/signal.hpp>
#include    <boost/unordered_map.hpp>
#include	<boost/progress.hpp>
#include	<boost/algorithm/string/replace.hpp>

#include "json_impl/json_error.hpp"
#include "json_impl/json_common.hpp"
#include "json_impl/json_parser.hpp"
#include "json_impl/json_string_helper.hpp"
#include "json_impl/json_operations.hpp"
#include "json_impl/json_type_conversion.hpp"

/* Useage:
first, define a object:
json::jobject jobj;
json::jobject jobj("{\"id\":\"yangcheng\"}");
json::jobject jobj(string("{\"id\":\"yangcheng\"}"));
json::jobject jobj("[1,2,3]");

second: use it:
	get value: obj[key].get<string>(), obj.get<string>(key);
	set value: obj[key]=value; obj[key1][key2][key3]=value; value can be string, int,double, bool, object
	array value: obj.arr_push(value); obj[obj.arr_size()] = value; array[size] = value;
third:convert jobject to string
	to_string: obj.to_string()
last: error handler
	there is a signal to emit error reason, we can find the reason and write log on it.
	json::json_error::instance().connect(function<void(string)> cmd);
*/
#endif	// TINYJSON_HPP
