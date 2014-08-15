namespace json
{

    template <typename T, typename TValue>
    struct jsonType
    {
        typedef std::basic_string<T> json_string_type;//support string to other typeof values
        TValue report_error(std::string const& reason)
        {
            json_error::instance().sig(reason);
            return TValue();
        }
        variant uniform_input(TValue val)
        {
            return variant(new boost::any(val));
        }
        TValue uniform_output(variant px)
        {
            if(!px)
            {
                return report_error("get value from nil object");
            }
            TValue* value_ptr;
            if(try_any_cast_no_error(px,value_ptr))return *value_ptr;
            return TryDiffType(px);
        }
        TValue TryDiffType(variant px)
        {
            //px can be string, int, double, bool, TValue can be string, int, double, bool, QString, or something else
            //TValues more than int, double, bool, string will be handled by specialize jsonType
            //to avoid compile warning, first transfer value to string, then to the dest value
            if(px->type()==typeid(json_string_type))
            {
                try{
                    return boost::lexical_cast<TValue>(try_any_cast<json_string_type>(px));
                }catch(boost::bad_lexical_cast const&)
                {
                    return report_error(std::string("cannot cast from string to ") + typeid(TValue).name());
                }
            }
            else if(px->type() == typeid(int))
            {
                try{
                    json_string_type tmpstr = boost::lexical_cast<json_string_type>(try_any_cast<int>(px));
                    return boost::lexical_cast<TValue>(tmpstr);
                }catch(boost::bad_lexical_cast const&)
                {
                    return report_error(std::string("cannot cast from int to ") + typeid(TValue).name());
                }
            }
            else if(px->type() == typeid(double))
            {
                try{
                    json_string_type tmpstr = boost::lexical_cast<json_string_type>(try_any_cast<double>(px));
                    return boost::lexical_cast<TValue>(tmpstr);
                }catch(boost::bad_lexical_cast const&)
                {
                    return report_error(std::string("cannot cast from double to ") + typeid(TValue).name());
                }
            }
            else if(px->type() == typeid(bool))
            {
                try{
                    json_string_type tmpstr = boost::lexical_cast<json_string_type>(try_any_cast<bool>(px));
                    return boost::lexical_cast<TValue>(tmpstr);
                }catch(boost::bad_lexical_cast const&)
                {
                    return report_error(std::string("cannot cast from bool to ") + typeid(TValue).name());
                }
            }
            else
            {
                return report_error(std::string("current object type is not fit for conversion"));
            }
        }
    };

    template <typename T>
    struct jsonType<T, jobject_basic<T> >
    {
        variant uniform_input(jobject_basic<T> val)
        {
            return val.px;
        }
    };

    template <typename T>
    struct jsonType<T, typename jobject_basic<T>::jobject_basic_ref >
    {
        variant uniform_input(typename jobject_basic<T>::jobject_basic_ref val)
        {
            return val.px;
        }
    };

    template <typename T>
    struct jsonType<T, variant >
    {
        variant uniform_input(variant val)
        {
            return val;
        }
    };
    //force char* char const* wchar* wchar const* to string or wstring
    template <typename T>
    struct jsonType<T, T const *>
    {
        variant uniform_input(T const* val)
        {
            return variant(new boost::any(typename jobject_basic<T>::json_string_type(val)) );
        }
    };

    template <typename T>
    struct jsonType<T, T *>
    {
        variant uniform_input(T * val)
        {
            return variant(new boost::any(typename jobject_basic<T>::json_string_type(val)) );
        }
    };
}//namespace json

