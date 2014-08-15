#pragma once

namespace json
{

template<typename T, typename TValue> struct jsonType;

template<typename T>
class jobject_basic
{
	template<typename, typename> friend struct jsonType;
	typedef jobject_basic<T> this_type;
	typedef typename json::grammar<T>::object object;
	typedef std::basic_string<T> json_string_type;

	struct json_value_helper
	{
		variant ptr_value_;
		json_value_helper(variant val):ptr_value_(val){}
		json_value_helper(json_value_helper const& dst):ptr_value_(dst.ptr_value_){}
		operator json_string_type() {return jsonType<T, json_string_type>().uniform_output(ptr_value_);}
		operator bool() {return jsonType<T, bool>().uniform_output(ptr_value_);}
		operator int() {return jsonType<T, int>().uniform_output(ptr_value_);}
		operator double() {return jsonType<T, double>().uniform_output(ptr_value_);}
		bool operator==(T const* val)
		{
			return operator json_string_type() == val;
		}
		template<class TValue> bool operator==(TValue const& cmp_val)
		{
			TValue tmp = jsonType<T, TValue>().uniform_output(ptr_value_);
			return tmp == cmp_val;
		}
		template<class TValue> bool operator!=(TValue const& cmp_val)
		{
			return !(operator==(cmp_val));
		}
	};

	class jobject_basic_ref:public this_type  //trait class, invisible to outside.
	{
	public:
		jobject_basic_ref(variant& p):this_type(p),px(p){}
		jobject_basic_ref(jobject_basic_ref const& refObj):this_type(refObj.px),px(refObj.px){}
        jobject_basic_ref& operator=(jobject_basic_ref const& refObj)
		{
			if(this != &refObj)
			{
				this_type::px = refObj.px;
				px = refObj.px;
			}
			return *this;
		}
		template<class TValue> jobject_basic_ref operator=(TValue val)
		{
			px = uniformValue(val);return *this;
		}
		jobject_basic_ref operator[](json_string_type const&key)
		{
			return getObjectByKey(key,px);
		}
		jobject_basic_ref operator[](int nIndex) 
		{
			return getObjectByIndex(nIndex,px);
		}
		template<class TValue> void arr_push(TValue val)
		{
			do_arr_push(val,px);
		}
		variant &px;
	};
protected:
	jobject_basic_ref getObjectByKey(json_string_type const&key, variant &px)
	{
        if(!px){px.reset(new boost::any(object()));}
        object* p_obj;
        if(try_any_cast(px,p_obj))
        {
            return (*p_obj)[key];
        }
        return px;
	}
	jobject_basic_ref getObjectByIndex(int nIndex,variant &px) 
	{
		if(nIndex<0) throw std::runtime_error("bad index");
		if(!px){px.reset(new boost::any(array()));}
		array* p_arr;
        if(try_any_cast(px,p_arr))
        {
            if(p_arr->size()<=(unsigned int)nIndex)
            {
                p_arr->resize(nIndex+1);
            }
            return (*p_arr)[nIndex];
        }
		object* p_obj;
        if(try_any_cast(px,p_obj))
        {
            if(p_obj->size()<=(unsigned int)nIndex)
            {
				throw std::runtime_error("index exceed max limit");
            }
			typename object::iterator it = p_obj->begin();
			std::advance(it, nIndex);
			return it->second;
        }

        return px;
	}
	template<class TValue> void do_arr_push(TValue val, variant &px)
	{
		if(!px){px.reset(new boost::any(array()));}
        array* p_arr;
        if(try_any_cast(px,p_arr))
        {
            p_arr->push_back(uniformValue(val));
        }
	}
public:
	//construct an object
	jobject_basic(){}
	jobject_basic(T const* p_str) {px = parse(p_str);}
	jobject_basic(json_string_type const& str){px = parse(str);}
	jobject_basic(variant const& val) {px = val;}
	//copy construct
	jobject_basic(jobject_basic const& obj):px(obj.px){}
	//assign value interface
	template<class TValue> jobject_basic operator=(TValue val)
	{
		px = uniformValue(val);return *this;
	}
	//array object interface
	jobject_basic_ref operator[](json_string_type const&key)
	{
		return getObjectByKey(key,px);
	}
	jobject_basic_ref operator[](int nIndex) 
	{
		return getObjectByIndex(nIndex,px);
	}
	template<class TValue> void arr_push(TValue val)
	{
		do_arr_push(val,px);
	}
	jobject_basic find_if(boost::function<bool(jobject_basic)> cmd)
	{
		if(!px) return px;
		array* p_arr;
		if(try_any_cast(px,p_arr))
		{
			array::iterator it = std::find_if(p_arr->begin(),p_arr->end(),cmd);
			if(it != p_arr->end())
			{
				return *it;
			}
		}
		return jobject_basic();
	}
	jobject_basic find_if(boost::function<bool(json_string_type, jobject_basic)> cmd)
	{
		if(!px) return px;
		object *p_obj;
		if(try_any_cast(px,p_obj))
		{
            typedef typename object::value_type val_type;//by LiMing
			typename object::iterator it = std::find_if(p_obj->begin(),p_obj->end(),boost::bind(boost::apply<bool>(),cmd, boost::bind(&val_type::first,_1), boost::bind(&val_type::second,_1)));
			if(it!=p_obj->end())
			{
				return it->second;
			}
		}
		return jobject_basic();
	}

	bool is_nil(json_string_type key)
	{
        if(!px) return true;
        object *p_obj;
        if(try_any_cast(px,p_obj))
		{
            typename object::iterator it = p_obj->find(key);
            if(it!=p_obj->end())
            {
                if(it->second) return false;
            }
		}
        return true;
	}

	bool is_nil(int index)
	{
		if(index<0)return true;
        if(!px) return true;
        array *p_obj;
        if(try_any_cast(px,p_obj))
		{
			if(p_obj->size()>index)return false;
		}
        return true;
	}

    bool erase_if(boost::function<bool(jobject_basic)> cmd)
    {
        if(!px) return false;
        array* p_arr;
        if(try_any_cast(px,p_arr))
        {
            array::iterator it = std::find_if(p_arr->begin(),p_arr->end(),cmd);
            if(it!=p_arr->end())
            {
                p_arr->erase(it);
                return true;
            }
        }
        return false;
    }

    bool erase_if(boost::function<bool(json_string_type, jobject_basic)> cmd)
    {
        if(!px) return false;
        object *p_obj;
        if(try_any_cast(px,p_obj))
        {
            typedef typename object::value_type val_type;//by LiMing
            typename object::iterator it = std::find_if(p_obj->begin(),p_obj->end(),boost::bind(boost::apply<bool>(),cmd, boost::bind(&val_type::first,_1), boost::bind(&val_type::second,_1)));
            if(it!=p_obj->end())
            {
                p_obj->erase(it);
                return true;
            }
        }
        return false;
    }
    
    void each(boost::function<void(jobject_basic)> cmd)
    {
        if(!px) return;
        array* p_arr;
        if(try_any_cast(px,p_arr))
        {
            for_each(p_arr->begin(),p_arr->end(),cmd);
        }
    }
    void each(boost::function<void(json_string_type,jobject_basic)> cmd)
    {
        if(!px) return;
        object *p_obj;
        if(try_any_cast(px,p_obj))
        {
            typedef typename object::value_type val_type;
            for_each(p_obj->begin(),p_obj->end(),boost::bind(boost::apply<void>(),cmd, boost::bind(&val_type::first,_1), boost::bind(&val_type::second,_1)));
        }
    }
	bool is_array()
	{
		if(!px) return false;
		array* p_arr;
		if(try_any_cast(px,p_arr)) return true;
		return false;
	}
	bool is_object()
	{
		if(!px) return false;
		object* p_obj;
		if(try_any_cast(px,p_obj)) return true;
		return false;
	}
	int size()
	{
		if(!px) return 0;
        array* p_arr;
        if(try_any_cast_no_error(px,p_arr))
        {
            return p_arr->size();
        }
		object* p_obj;
        if(try_any_cast_no_error(px,p_obj))
        {
            return p_obj->size();
        }
		return 0;
	}
	int arr_size()
	{
		if(!px) return 0;
        array* p_arr;
        if(try_any_cast(px,p_arr))
        {
            return p_arr->size();
        }
        return 0;
	}
	bool operator==(jobject_basic const& otherObj)
	{
		if(px == otherObj.px)return true;//if px == null and otherObj.px == null, return true. if they refer to the same obj, return true.
		if((!px&&otherObj.px) || (px&&!otherObj.px))return false;//only one of them is null, return false
		if(px->type() != otherObj.px->type()) return false;
		if(to_string() == otherObj.to_string()) return true;//to be easily, using the string compare, should compare field by field to get better performance
		return false;
	}
    bool operator!=(jobject_basic const& otherObj)
    {
        return ! (operator==(otherObj));
    }
	//value get interface
	json_value_helper get()
	{
		return json_value_helper(px);
	}
	template<class TValue> TValue get(json_string_type const& key) 
	{
		return this->operator [](key).template get<TValue>();
	}
	template<class TValue> TValue get(int key) 
	{
		return this->operator [](key).template get<TValue>();
	}
	template<class TValue> TValue get() 
	{
		return uniformOutput<TValue>(px);
	}
	//jobject_basic to string
	json_string_type to_string() const;
    jobject_basic clone() const {return jobject_basic(to_string());}
	//null object check
	typedef boost::shared_ptr<boost::any> this_type::*unspecified_bool_type;
	operator unspecified_bool_type() const
	{
		return (px == 0 || px->empty()) ? 0: &this_type::px;
	}
protected:
	variant parse(json_string_type str);
	template<class TValue> variant uniformValue(TValue val);
	template<class TValue> TValue uniformOutput(variant px);
private:
	json_string_type to_string(int ndepth) const;
	variant px;
};

template<typename T> template<class TValue>
variant jobject_basic<T>::uniformValue(TValue val)
{
	return jsonType<T, TValue>().uniform_input(val);
}
template<typename T> template<class TValue>
TValue jobject_basic<T>::uniformOutput(variant px)
{
	return jsonType<T, TValue>().uniform_output(px);
}
namespace {
	struct json_process_time
	{
		json_process_time(int i)
		{
			if(i==0)
			{
				m_dur.reset(new boost::progress_timer(m_stream));
			}
		}
		~json_process_time()
		{
			if(m_dur)
			{
				m_dur.reset();
				std::string str_info = m_stream.str();
				boost::replace_all(str_info,"\n", "");
				json_error::instance().sig("json cost time : " + str_info);
			}
		}
		std::ostringstream m_stream;
		boost::shared_ptr<boost::progress_timer> m_dur;
	};
}
template<typename T>
typename jobject_basic<T>::json_string_type jobject_basic<T>::to_string(int ndepth) const
{
	json_process_time time_dur(ndepth);
	if(!px || px->empty())
	{
		return StringHelper::getNull<T>();
	}
	else if(px->type()==typeid(int))
	{
		return boost::lexical_cast<json_string_type>(try_any_cast<int>(px));
	}
	else if(px->type()==typeid(double))
	{
		return boost::lexical_cast<json_string_type>(try_any_cast<double>(px));
	}
	else if(px->type()==typeid(json_string_type))
	{
		json_string_type strFmt = StringHelper::getStringFmt<T>();
		json_string_type elem = try_any_cast<json_string_type>(px);
		json_string_type dst_elem;
		BOOST_FOREACH(T val, elem)
		{
			if(json_string_type(&val,1) == StringHelper::getStringB<T>())
			{
				dst_elem += StringHelper::getDStringB<T>();
			}
			else if(json_string_type(&val,1) == StringHelper::getStringF<T>())
			{
				dst_elem += StringHelper::getDStringF<T>();
			}
			else if(json_string_type(&val,1) == StringHelper::getStringN<T>())
			{
				dst_elem += StringHelper::getDStringN<T>();
			}
			else if(json_string_type(&val,1) == StringHelper::getStringR<T>())
			{
				dst_elem += StringHelper::getDStringR<T>();
			}
			else if(json_string_type(&val,1) == StringHelper::getStringT<T>())
			{
				dst_elem += StringHelper::getDStringT<T>();
			}
			else if(json_string_type(&val,1) == StringHelper::getStringRS<T>())
			{
				dst_elem += StringHelper::getDStringRS<T>();
			}
			else if(json_string_type(&val,1) == StringHelper::getStringS<T>())
			{
				dst_elem += StringHelper::getDStringS<T>();
			}
			else if(json_string_type(&val,1) == StringHelper::getStringQM<T>())
			{
				dst_elem += StringHelper::getDStringQM<T>();
			}
			else
			{
				dst_elem += val;
			}
		}
		return boost::str(boost::basic_format<T>(strFmt) % dst_elem);
	}
	else if(px->type()==typeid(bool))
	{
		bool nValue = try_any_cast<bool>(px);
		return nValue?StringHelper::getTrue<T>():StringHelper::getFalse<T>();
	}
	else if(px->type()==typeid(typename grammar<T>::object))
	{
		json_string_type strSubObjs;
		object *p_obj;
		try_any_cast(px,p_obj);
		json_string_type subObjFmt = StringHelper::getSubObjFmt<T>();// "%s":%s,
		for(typename object::iterator crit = p_obj->begin();crit!=p_obj->end();++crit)
		{
			json_string_type firstPart = crit->first;
			json_string_type secondPart = jobject_basic<T>(crit->second).to_string(ndepth+1);
			strSubObjs = boost::str(boost::basic_format<T>(subObjFmt) % firstPart % secondPart) + strSubObjs;
		}
		if(!strSubObjs.empty())
		{
			strSubObjs.erase(strSubObjs.size()-1);
		}
		json_string_type objFmtStr = StringHelper::getObjFmt<T>();
		return boost::str(boost::basic_format<T>(objFmtStr)%strSubObjs);
	}
	else if(px->type()==typeid(array))
	{
		json_string_type strSubObjs;
		array * p_obj;
		try_any_cast(px,p_obj);
		json_string_type subObjFmt = StringHelper::getSubArrFmt<T>();//%s,
		for(unsigned int i=0;i<p_obj->size();++i)
		{
			strSubObjs += boost::str(boost::basic_format<T>(subObjFmt) % jobject_basic<T>((*p_obj)[i]).to_string(ndepth+1));
		}
		if(!strSubObjs.empty())
		{
			strSubObjs.erase(strSubObjs.size()-1);
		}
		json_string_type objFmt = StringHelper::getArrFmt<T>();
		return boost::str(boost::basic_format<T>(objFmt)%strSubObjs);
	}
	else
	{
		json_error::instance().sig("json::jobject error: unknown jobject type");
		return StringHelper::getEmpty<T>();
	}
}
template<typename T>
typename jobject_basic<T>::json_string_type jobject_basic<T>::to_string() const
{
	return to_string(0);
}
template <typename T>
variant jobject_basic<T>::parse(typename jobject_basic<T>::json_string_type str)
{
	json_process_time dur(0);
	typename json::grammar<T>::stack st;
	typename json::grammar<T> gr(st);
	gr.do_parse(str);
	// 3: if the input's end wasn't reached or if there is more than one object on the stack => cancel...
	if(st.size()==0)
	{
		return variant();
	}
	// 4: otherwise, return the result...
	return st.top();
}

template<class T> bool try_any_cast_no_error(const variant &px, T*& p_px)
{
	p_px = boost::any_cast<T>(px.get());
	if(p_px)return true;
	return false;
}
template<class T> bool try_any_cast(const variant &px, T*& p_px)
{
	p_px = boost::any_cast<T>(px.get());
	if(p_px)return true;
	json_error::instance().sig("json::jobject error: any_cast failed, the obj is:" + jobject_basic<char>(px).to_string() + "\n");
	return false;
}
template<class T> T try_any_cast(const variant &px)
{
	T* p_px = boost::any_cast<T>(px.get());
	if(p_px)return *p_px;
	json_error::instance().sig("json::jobject error: any_cast failed, the obj is:" + jobject_basic<char>(px).to_string() + "\n");
	return T();
}

typedef jobject_basic<char> jobject;
typedef jobject_basic<wchar_t> jwobject;

};//namespace json

