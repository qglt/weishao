#define STRING_HELPER_SPECIFIC(name,val)	                		    									\
    template<class T> std::basic_string<T> name();                                                          \
    template<>inline std::string name<char>(){return val;}                                                  \
    template<>inline std::wstring name<wchar_t>(){return L##val;}																
namespace StringHelper
{
    STRING_HELPER_SPECIFIC(getNull,"null")
    STRING_HELPER_SPECIFIC(getTrue,"true")
    STRING_HELPER_SPECIFIC(getFalse,"false")
    STRING_HELPER_SPECIFIC(getObjFmt,"{%s}")
    STRING_HELPER_SPECIFIC(getSubObjFmt,"\"%s\":%s,")
    STRING_HELPER_SPECIFIC(getArrFmt,"[%s]")
    STRING_HELPER_SPECIFIC(getSubArrFmt,"%s,")
    STRING_HELPER_SPECIFIC(getEmpty,"")
    STRING_HELPER_SPECIFIC(getStringFmt,"\"%s\"")
    //for string conversion
    STRING_HELPER_SPECIFIC(getStringB,"\b")
    STRING_HELPER_SPECIFIC(getStringF,"\f")
    STRING_HELPER_SPECIFIC(getStringN,"\n")
    STRING_HELPER_SPECIFIC(getStringR,"\r")
    STRING_HELPER_SPECIFIC(getStringT,"\t")
    STRING_HELPER_SPECIFIC(getStringRS,"\\")
    STRING_HELPER_SPECIFIC(getStringS,"/")
    STRING_HELPER_SPECIFIC(getStringQM,"\"")

    STRING_HELPER_SPECIFIC(getDStringB,"\\b")
    STRING_HELPER_SPECIFIC(getDStringF,"\\f")
    STRING_HELPER_SPECIFIC(getDStringN,"\\n")
    STRING_HELPER_SPECIFIC(getDStringR,"\\r")
    STRING_HELPER_SPECIFIC(getDStringT,"\\t")
    STRING_HELPER_SPECIFIC(getDStringRS,"\\\\")
    STRING_HELPER_SPECIFIC(getDStringS,"\\/")
    STRING_HELPER_SPECIFIC(getDStringQM,"\\\"")
}