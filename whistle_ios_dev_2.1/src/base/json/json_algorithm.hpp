#pragma once

namespace json {
	template<class CharType>
	bool search_obj_by_key(std::basic_string<CharType> dst_key, std::basic_string<CharType> key, json::jobject_basic<CharType> jobj)
	{
		if(key==dst_key)return true;
		return false;
	}
	template<class CharType>
	void apply_new_field(json::jobject_basic<CharType> &jobj_dst, std::basic_string<CharType> key, json::jobject_basic<CharType> jobj)
	{
		jobj_dst[key] = jobj;
	}
}
