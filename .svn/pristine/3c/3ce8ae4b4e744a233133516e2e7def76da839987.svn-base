#include "base/txtutil/txtutil.h"
#include <base/local_search/local_search.h>
#include <base/local_search/pin_yin_dict_impl.h>
#include <boost/tuple/tuple.hpp>
#include <boost/algorithm/string.hpp>
namespace epius
{
	class local_search_impl
	{
	public:
		std::map<std::wstring, boost::tuple<std::vector<std::vector<std::string> >, std::vector<std::vector<std::string> > > > key_quanpin_headpin_;
		local_search_impl()
		{
			//初始化拼音数组
			std::map<wchar_t,std::set<std::string> > do_filter_dup;
			for(int i = 0;pinyinTab[i].word;++i)
			{
				std::string yin = pinyinTab[i].pinyin;
				while (isdigit(*yin.rbegin()))
				{
					yin.erase(yin.length() - 1,1);
				}
				do_filter_dup[pinyinTab[i].word].insert(yin);
			}

			for(std::map<wchar_t,std::set<std::string> >::iterator it = do_filter_dup.begin();it!=do_filter_dup.end();++it)
			{
				if(it->second.size() > 2)
				{
					std::set<std::string>::iterator itend = it->second.begin();
					std::advance(itend,2);
					std::copy(it->second.begin(),itend,std::back_inserter(py_map_[it->first]));
				}
				else
				{
					std::copy(it->second.begin(),it->second.end(),std::back_inserter(py_map_[it->first]));
				}
			}
		}

		std::vector<std::string> look_up_pinyin( wchar_t chinese_char)
		{
			std::map<wchar_t,std::list<std::string> >::const_iterator it = py_map_.find(chinese_char);
			std::vector<std::string> conv_res;
			if (it != py_map_.end())
			{		
				std::copy(it->second.begin(),it->second.end(),std::back_inserter(conv_res));
				return conv_res;
			}
			else
			{
				return std::vector<std::string>();
			}
		}

		void build_pinyin( std::wstring unicode_name,std::vector<std::vector<std::string> >& quan_pin, std::vector<std::vector<std::string> >& head_str )
		{
			if(key_quanpin_headpin_.find(unicode_name) != key_quanpin_headpin_.end())
			{
				quan_pin = key_quanpin_headpin_[unicode_name].get<0>();
				head_str = key_quanpin_headpin_[unicode_name].get<1>();
				return;
			}
			std::for_each(unicode_name.begin(),	unicode_name.end(),[&](wchar_t word)
			{
				std::vector<std::string> pinyin = look_up_pinyin(word);
				quan_pin.push_back(pinyin);
				head_str.push_back(std::vector<std::string>());
				std::for_each(pinyin.begin(),pinyin.end(),[&](std::string word_pinyin)
				{
					head_str.rbegin()->push_back(word_pinyin.substr(0,1));
				});
			});
			key_quanpin_headpin_[unicode_name] = boost::make_tuple(quan_pin, head_str);
		}

		//递归匹配查找
		bool deep_find(std::string& filterString, int deep, std::string tmp_result, std::vector<std::vector<std::string> >& quan_pin )
		{
			if(tmp_result.find(filterString, 0) != std::string::npos)
			{
				return true;
			}
			if(deep<quan_pin.size())
			{
				for (int j = quan_pin[deep].size() - 1;j >= 0;--j)//第二重循环，取每个字对应的多个音节,假设为n个音节.结果集应为 n1*n2...*nm个字符串
				{
					if(deep_find(filterString, deep+1, tmp_result+quan_pin[deep][j], quan_pin)) return true;
				}
			}
			return false;
		}
		
		//字符串格式化
		static wchar_t width_char2halfwidth_char( wchar_t filterType )
		{
			const std::wstring converFrom = L"０１２３４５６７８９！～＠＃￥％＾＆×（）－＋＝｛｝【】＼｜“‘”’：；·。、？，《》ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｘｔｕｖｗｘｙｚ";
			const std::wstring converTo = L"0123456789!~@#$%^&*()-+={}[]\\|\"\'\"\':;`./?,<>abcdefghijklmnoprstuvwxyz";
			int pos = converFrom.find(filterType);
			return (pos == std::wstring::npos) ? std::towlower(filterType) : converTo[pos];
		}

		//用宽字符是为了方便中文字符串
		bool match_string(std::string filter_string,std::string name)
		{
			std::wstring wname = epius::txtutil::convert_utf8_to_wcs(name);
			std::wstring wfilter_string = epius::txtutil::convert_utf8_to_wcs(filter_string);
			//通过字符串查找
			if (!wname.empty())
			{
				std::transform(wfilter_string.begin(), wfilter_string.end(), wfilter_string.begin(),width_char2halfwidth_char);
				boost::to_lower(wname);
				boost::to_lower(wfilter_string);
				if (wname.find(wfilter_string, 0) != std::wstring::npos)
				{
					return true;
				}
			}	
			return false;
		}

		//处理拼音查找
		bool match_pinyin(std::string filter_string,std::string name)
		{
			// 预处理拼音字串匹配
			std::vector<std::vector<std::string> > quan_pin;
			std::vector<std::vector<std::string> >head_str;
			build_pinyin(epius::txtutil::convert_utf8_to_wcs(name),quan_pin,head_str);
			std::wstring wfilter_string = epius::txtutil::convert_utf8_to_wcs(filter_string);
			std::transform(wfilter_string.begin(), wfilter_string.end(), wfilter_string.begin(),width_char2halfwidth_char);
			std::string filter = epius::txtutil::convert_wcs_to_utf8(wfilter_string);
			// 全拼拼音匹配
			if (!quan_pin.empty())
			{	
				if (deep_find(filter, 0, "", quan_pin))
				{			
					return true;
				}
			}
			// 拼音首字母匹配
			if (!head_str.empty()) 
			{
				if (deep_find(filter, 0, "", head_str))
				{
					return true;
				}
			}	
			return false;
		}

	private:
		std::map<wchar_t,std::list<std::string> > py_map_;
	};


	local_search::local_search()
	{
		//初始化指针
		impl_.reset(new local_search_impl);
	}

	bool local_search::match( std::string filter_string,std::string name )
	{
		if (impl_->match_string(filter_string,name))
		{
			return true;
		}
		if (impl_->match_pinyin(filter_string,name))
		{
			return true;
		}
		return false;
	}
};



		
