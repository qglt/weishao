#pragma once


namespace epius
{
	template <class T>union NetByte
	{
		NetByte(T const & obj){value_ = obj;}
		NetByte(std::string& obj)
		{
			if(IsBigEndian())std::copy(obj.begin(),obj.end(),ucArr);
			else std::copy(obj.rbegin(),obj.rend(),ucArr);
		}
		NetByte(std::string const& obj)
		{
			if(IsBigEndian())std::copy(obj.begin(),obj.end(),ucArr);
			else std::copy(obj.rbegin(),obj.rend(),ucArr);
		}
		operator T() const{return value_;}
		std::string toString() const
		{
			std::string tmpValue(ucArr,sizeof(T));
			if(IsBigEndian())return tmpValue;
			else return std::string(tmpValue.rbegin(),tmpValue.rend());
		}
	private:
		static bool IsBigEndian()
		{
			int testValue = 0x1234abcd;
			if((unsigned char)testValue == 0x12)return true;
			else return false;
		}
		T value_;
		char ucArr[sizeof(T)];
	};
}